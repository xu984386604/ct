setWinAapp();
//先检测是否要自动登录
var jumpfrom = GetQueryString('isAutoLogin');
var canClearCookie = GetQueryString('canClearCookie');
var devicetype = DeviceType();

//如果设备类型是windows客户端，则显示退出按钮
if(devicetype == 'Windows'){
    $('#Windowsexit').css('display','block');
}
//如果注销则清空localstorage
if(canClearCookie == '1'){
    localStorage.setItem('autologin','false');
    localStorage.removeItem('enpw');
    localStorage.clear();
}


//判断是否要自动登录
if(jumpfrom !== '0'){

    var autologin = localStorage.getItem('autologin');
    if(autologin == 'true'){
        //获取用户的输入
        var username =  localStorage.getItem('user');
        var encryptedPassword = localStorage.getItem('enpw');
        //获取缓存中的ip地址
        var ipstr = localStorage.getItem('ipaddress');
        var authurl = 'http://'+ipstr+'/cu/index.php/Home/Auth/login.html';
        var locationurl = 'http://'+ipstr+'/cu/Public/vue/build/index.php?code=';
        //将信息发给后台验证
        $.ajax({
            url : authurl,
            method : 'post',
            data : {
                        type:devicetype,
                        username:username,
                        password:encryptedPassword
                    }
        })
        .then(function(res){
            if(res.code == 800){
            var sendData = {
                userID:res.data.userID,
                operation : 'setUserId'
            }
            executeByTerminal(sendData);
            var sendDataurl = {
                url:ipstr,
                operation : 'setIp'
            }
            executeByTerminal(sendDataurl);
            window.location.href = locationurl+res.data.code;
            }else{

            }
        },function(err){

        })
    }
}
 $(function(){

    $('#Windowsexit').click(function(){
        exit();
    })
     $('.ant-checkbox-wrapper').click(function(){
         $(this).toggleClass('ant-checkbox-checked');
     })
    //根据缓存更改当前的选中
    setActiveIp();
    //先根据缓存渲染select
    renderselect();

    if(localStorage.getItem('lastipaddress')){
        var ipstr = localStorage.getItem('lastipaddress');
        var ipurl = 'http://'+ipstr+'/cu/iplogin/login.html?v=2';
        var authurl = 'http://'+ipstr+'/cu/index.php/Home/Auth/login.html';
        var locationurl = 'http://'+ipstr+'/cu/Public/vue/build/index.php?code=';
        var registurl = 'http://'+ipstr+'/cu/Public/vue/build/index.php#/regist';
        var forgeturl = 'http://'+ipstr+'/cu/Public/vue/build/index.php#/reset-password';
        //将按钮设置成loading状态
        $('.y-head-icon').addClass('y-hide');
        $('.ant-spin').removeClass('y-hide');
        if($('#username').length !== 0){
            // $('.insertbox').html('');
            $('.insertbox').css('opacity','none');
        }
       //点击的时候加载html到当前页面
        $.ajax({
                type:'get',
                url:ipurl,
                data:{},
                timeout : 3000
        })
        .then(function(res,status,xhr){
            if($('.bugtip').length !== 0){
                $('.bugtip').remove();
            }
            if(xhr.status == 200){
                setTimeout(function(){
                    $('.ant-spin').addClass('y-hide');
                    // $('.insertbox').html(res)
                    $('.insertbox').css('display','block');
                    $('.insertbox').addClass('animated fadeInRight')
                    $('.insertbox').one('webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', function () {

                        $('.insertbox').removeClass('animated fadeInRight');
                    })
                    //替换注册和忘记密码的地址
                    if($('.collapse').hasClass('in')){
                        $('.collapse').removeClass('in');
                    }
                    //
                    $('#username').val(localStorage.getItem('user'));
                    //
                    localStorage.setItem('lastipaddress',ipstr);
                    //连接时发送ip地址
                    var sendData = {
                        url:ipstr,
                        operation : 'setIp'
                    }
                    executeByTerminal(sendData);
                    //点击登录按钮
                    $('#login').click(function(){
                        //获取用户的输入
                        var username = $('#username').val();
                        var password = $('#password').val();
                        //这里要对密码进行加密
                        var encryptedPassword =  encryptPassword(password);
                        //将信息发给后台验证
                        $.ajax({
                            url : authurl,
                            method : 'post',
                            data : {
                                        // mac:mac/*终端mac地址*/,
                                        type:devicetype,
                                        username:username,
                                        password:encryptedPassword
                                    },
                            timeout : 5000,
                        })
                        .then(function(res){
                            if(res.code == 800){
                                if($('.bugtip').length !== 0){
                                    $('.bugtip').remove();
                                }
                                //用localstorage存储是否自动登录的信息
                                if($('.ant-checkbox-wrapper').hasClass('ant-checkbox-checked')){
                                    localStorage.setItem('autologin','true');
                                    //localStorage.setItem('ipaddress','')
                                }else{
                                    localStorage.setItem('autologin','false')
                                }
                                //用localstorage存储上一次的ip地址信息
                                localStorage.setItem('ipaddress',ipstr)
                                //存localstorage为自动登录做准备
                                localStorage.setItem('user',username);
                                localStorage.setItem('enpw',encryptedPassword);
                                //进行地址跳转
                                var sendData = {
                                    userID:res.data.userID,
                                    operation : 'setUserId'
                                }
                                executeByTerminal(sendData);
                                window.location.href = locationurl+res.data.code;
                            }else{
                                errorconsole($('.loginbox'),CODE_MSG(res.code),0);
                            }
                        },function(err, status){
                            if(status=='timeout'){//超时,status还有success,error等值的情况
                                errorconsole($('.loginbox'),'登录超时',0);
                            }else if(status=='error'){
                                errorconsole($('.loginbox'),'登录失败',0);
                            }
                        })

                    })
                    $('.regist a').click(function(event){
                        event.preventDefault();
                        window.location.href = registurl;
                    })
                    $('.reset-password a').click(function(event){
                        event.preventDefault();
                        window.location.href = forgeturl;
                    })
                    $('.exit a').click(function(event){
                        event.preventDefault();
                        //调用
                        exit();
                    })
                },300)
            }

        },function(err,status){
            if(status=='timeout' || status== 'error'){//超时,status还有success,error等值的情况
                console.log('ip地址无法访问1')
                if($('#username').length !== 0){
                        $('.ant-spin').addClass('y-hide');
                        $('.y-head-icon').removeClass('y-hide');
                        if(!$('.collapse').hasClass('in')){
                            $('.collapse').addClass('in');
                        }
                    // })
                }else{
                    setTimeout(function(){
                        $('.ant-spin').addClass('y-hide');
                        $('.y-head-icon').removeClass('y-hide');
                        if(!$('.collapse').hasClass('in')){
                            $('.collapse').addClass('in');
                        }

                    },300)
                }
                    errorconsole($('.cs-placeholder'),'ip地址无法访问',1);

                return;
            }
        })
    }else{
        $('.collapse').addClass('in');
    }
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
