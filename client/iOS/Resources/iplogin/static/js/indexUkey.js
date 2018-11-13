setWinAapp();

var devicetype = DeviceType();

//如果设备类型是windows客户端，则显示退出按钮
if(devicetype == 'Windows'){
    $('#Windowsexit').css('display','block');
}

$(function(){
    $('#Windowsexit').click(function(){
        exit();
    })

    //进入登录页面后，先获取用户的信息
    //获取来自终端Ukey的username
    Promise.all([new Promise((resolve,reject)=>{
        //获取Ukey中的UserName
        if(!window.app || ! window.app.getUserName){
            setTimeout(()=>{reject('客户端不支持获取Ukey信息功能，请升级客户端');},1000);
        }else{
            window.app.getUserName(resolve);
        }
    }),new Promise((resolve,reject)=>{
        //获取客户端的mac地址
        if(!window.app || !window.app.getClientMac){
            setTimeout(()=>{reject('客户端不支持获取MAC功能，请升级客户端');},1000);
        }else{
            window.app.getClientMac(resolve);
        }
    })]).then(result=>{
        var username = result[0];
        var macaddress = result[1];
        $('.statusmsg').html('用户'+username+'正在登录..');
        var authurl = 'http://'+config.locahostRoot+'/cu/index.php/Home/Auth/login.html';
        var locationurl = 'http://'+config.locahostRoot+'/cu/Public/vue/build/index.php?code=';
        //Ukey登录，没有密码
            $.ajax({
                type:'post',
                url:authurl,
                data:{
                        type:devicetype,/*当前终端设备类型*/
                        username:username,
                        logintype:'ukey',
                        mac:macaddress
                }
            })
            .then(res=>{
            if(res.code == 800){
                console.log(res.code)
                //进行地址跳转
                var sendData = {
                    userID:res.data.userID,
                    operation : 'setUserId'
                }
                executeByTerminal(sendData);
                var sendDataurl = {
                    url:config.locahostRoot,
                    operation : 'setIp'
                }
                executeByTerminal(sendDataurl);
                window.location.href = locationurl+res.data.code;
            }else{
                $('.statusmsg').html(res.code == 812 ? '用户'+username+'不存在' :'code出错'+CODE_MSG(res.code));
            }
        });
    },(err)=>{
        $('.statusmsg').html('获取用户信息出错'+err);
    });
})



function operationData(myurl,method,data){
    return $.ajax({
        type:method,
        url:myurl,
        data:data,
        timeout : 1000,
    })
}
function operationDatatest(myurl,method){
    return $.ajax({
        type:method,
        url:myurl,
    })
}
function renderselect(){

    [].slice.call( document.querySelectorAll( 'select.cs-select' ) ).forEach( function(el) {
        console.log(el)
        new SelectFx(el);
    } );

}
function isfocus(){
    if($('.double-input-box').hasClass('y-focus')){
        return true;
    }else{
        return false;
    }
}
function hasParent( e, p ) {
    if (!e) return false;
    var el = e.target||e.srcElement||e||false;
    while (el && el != p) {
        el = el.parentNode||false;
    }
    return (el!==false);
};

//判断ip地址是否合法
function isValidIP(ip) {
    var reg = /^(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])$/;
    return reg.test(ip);
}

//判断用户名和密码是否为空
function isValidinput(data){

}

//与客户端通信，向客户端发送当前打开的ip地址
function executeByTerminal(sendData){
    if(window.app){
        window.app.executeByTerminal(JSON.stringify(sendData));
    }

};

//与window通信，用于应用关闭
function exit(){
    if(window.app){
        window.app.exit();
    }

}
//与安卓端通信，确定页面跳转方向
function getjumpfrom(){
    return window.app.getjumpfrom()
}

//判断客户端是否是ios
function isios(){
    var u = navigator.userAgent;
    var isiOS = !!u.match(/\(i[^;]+;( U;)? CPU.+Mac OS X/);
    return isiOS;
}
//检测当前的客户端类型
function DeviceType(){
    const env = ['Windows',"Android","iPad","iPhone","iPod"];
    const envMap = {
        Windows:"Windows",
        Android:"Android",
        iPad:"IOS",
        iPhone:"IOS",
        iPod:"IOS"
    }
    let userAgent = window.navigator.userAgent;
    for(let i = 0;i < env.length; i++){
        if(userAgent.indexOf(env[i]) != -1){
            return envMap[env[i]];
        }
    }
    return "Windows";
};

//与ios通信，ios调用该函数，确定页面方向
function insertIntoLocal(flag){
    ipstatus = flag;
}

//与ios通信，让ios调用页面上的insertIntoLocal函数，确定页面的跳转方向
function setFlag(){
    window.app.setFlag();

}

//window端设置window.app对象
function setWinAapp(){
    /*连接windows客户端时与其建立通道，获得app对象*/
    if(navigator.userAgent.indexOf('Windows') !=-1){
        var buildChannel = function(){
            if(typeof QWebChannel != 'undefined'){
                new QWebChannel(qt.webChannelTransport,function(channel){
                    window.channel = channel;
                    window.app = channel.objects.app;
                    app.hideHomeButton();
                    console.log(channel);
                })
            }
        }
        if(typeof qt != 'undefined'){
            buildChannel();
        }
    }
}

function GetQueryString(name)
{
    var reg = new RegExp("(^|&)"+ name +"=([^&]*)(&|$)");
    var r = window.location.search.substr(1).match(reg);
    if(r!=null)return  unescape(r[2]); return null;
}

function setActiveIp(){
    var lastIpAddress = localStorage.getItem('lastipaddress');
    if(lastIpAddress){
        $('.iplist option').each(function(){
            console.log('yyyy')
            $(this).removeAttr("selected");
            if(this.dataset.ipaddress == lastIpAddress){
                $(this).attr("selected","selected");
            }
        })
    }

}


//显示错误信息
function errorconsole($el,text,flag){
    if($('.bugtip').length !== 0){
        $('.bugtip').remove();
    }
    var tiphtml = "<div class='bugtip'>"+text+"</div>";
    if(flag == 1){
        $el.after(tiphtml);
    }else{
        $el.append(tiphtml);
    }

}

//判断是否支持国安环境
function supportUkey() {
    if(config.ukey === 1){
        return true;
    }else{
        return false;
    }
}
