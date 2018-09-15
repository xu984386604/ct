    $(function(){
        // 检测屏幕的高度
        $('.mask').height($(document).height());
        //先根据缓存渲染select
        renderselect();
        $(document).on( 'click touchstart', function(ev) {
            
            var target = ev.target;
            if(isfocus() && target !== document.querySelector('.cs-select') && !hasParent( target, document.querySelector('.cs-select') ) ){
                $('div.y-test-box').addClass('y-hide');
                $('div.y-test-box').removeClass('y-show');
                $('.cs-addicon ').addClass('y-hide');
                $('.cs-addicon ').removeClass('y-show');
                $('.y-placeholder').addClass('y-show');
                $('.y-placeholder').removeClass('y-hide');
                $('.cs-options').addClass('y-show');
                $('.cs-options').removeClass('y-hide');
                if($('.cs-placeholder')){
                    $('.cs-placeholder').addClass('y-show');
                    $('.cs-placeholder').removeClass('y-hide')
                }
                $('.double-input-box').removeClass('y-focus');
            }
        } );
        $("#configip").click(function(e){
            var event = e;
            //将按钮设置成loading状态
           // addRippleEffect(event);
           //点击的时候加载html到当前页面
           $('.y-head-icon').addClass('y-hide');
           $('.ant-spin').removeClass('y-hide');
            $.ajax({
                    type:'get',            
                    url:'http://172.20.156.168/ctlogin/logintest.html',                                           
                    data:{},
                    timeout : 3000,
                    success:function(data,status,xhr){ //请求成功的回调函数
                        　　　if(xhr.status == 200){
                                //  $('.maskloading').addClass('y-hide');

                                //window.location.href=ipurl;
                                setTimeout(function(){
                                    $('.ant-spin').addClass('y-hide');
                                    // $('.changebox').append("<iframe src='http://172.20.156.168/cu/Public/vue/build/index.php#/login' frameborder='no' allowtransparency='true' class = 'loginiframe'></iframe>")
                                    $('.changebox').append(data);
                                    $('.collapse').removeClass('in');
                                     $('.ipconboxmask').removeClass('y-hide')
                                },500)
                            

                            }
                　　},
                　　complete : function(XMLHttpRequest,status){ //请求完成后最终执行参数
            　　　　if(status=='timeout'){//超时,status还有success,error等值的情况
                            console.log('ip地址无法访问1')
                            var tiphtml = "<div class='bugtip'>ip地址无法访问</div>"
                                $('.select-box').append(tiphtml);
                                setTimeout(function(){
                                    $('.bugtip').remove();
                                },800)
                        return;
                　　    }
                    }
            })

        })
        // $(".configicon").click(function(e){
        //     if(!$('.collapse').hasClass('in')){
        //         $('.y-head-icon').removeClass('y-hide');
        //     }
        // })
        $(window).resize(function(){
            $('.mask').height($(document).height());
        }); 
          
    })
    
    var addRippleEffect = function (e) {
            var ipstr = $('.y-placeholder').val();
            var reg = /[^:]*:([^:]*)/;
            ipstr=ipstr.replace(reg,"$1");
            var ipurl = 'http://'+ipstr+'/cu';
            $.ajax({
                    type:'get',            
                    url:ipurl,                                           
                    data:{},
                    timeout : 3000,
                    success:function(data,status,xhr){ //请求成功的回调函数
                        　　　if(xhr.status == 200){
                                if(localStorage.getItem('lastip')){
                                    localStorage.setItem('lastip',ipstr);
                                }else{
                                    localStorage.setItem('lastip',ipstr);
                                }
                                //  $('.maskloading').addClass('y-hide');

                                window.location.href=ipurl;
                            }
                　　},
                　　complete : function(XMLHttpRequest,status){ //请求完成后最终执行参数
            　　　　if(status=='timeout'){//超时,status还有success,error等值的情况
                            console.log('ip地址无法访问1')
                            var tiphtml = "<div class='bugtip'>ip地址无法访问</div>"
                                $('.select-box').append(tiphtml);
                                setTimeout(function(){
                                    $('.bugtip').remove();
                                },800)
                        return;
                　　    }
                    }
            })
       
        return false;
    }

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
    // $('.maskloading').addClass('y-hide')
    $('.select-box').html("<select class='cs-select cs-skin-underline optlist'></select>");
    if (localStorage.getItem('iplist')) {
            var opthtml='',iplist = JSON.parse(localStorage.getItem('iplist'));
            iplist.forEach(function(value, index){
                if(index == 0){
                    opthtml = opthtml + "<option selected>"+value+"</option>";
                }else{
                    opthtml = opthtml + "<option value='"+index+"'>"+value+"</option>";
                }  
            })
            $(".optlist").html(opthtml);
        }
    [].slice.call( document.querySelectorAll( 'select.cs-select' ) ).forEach( function(el) {	
        console.log(el)
        new SelectFx(el);
    } );
    $('.cs-placeholder').click(function(){
        $(this).toggleClass("main");
    })
    $(".option-delete").click(function(){
        //删除localstorage中相应的东西
        var iplist = JSON.parse(localStorage.getItem('iplist'));
        var ipindex = iplist.indexOf($(this).parents("span").text());
        iplist.splice(ipindex,1)
        localStorage.setItem('iplist', JSON.stringify(iplist));
        $(this).parents("li").remove();
    })
    // $('.y-placeholder').click(function(ev){
    //     //console.log('dianjile')
    //     ev.preventDefault();
    //     if($('div.y-test-box').length == 0){
    //         var testSelEl = document.createElement( 'div' );
    //         var ipinputHtml = "<div class='y-test-box'><input class='y-form-control-test y-address'></input><span>:</span><input class='y-form-control-test y-ipcontent y-ipcontent-one'></input><span>.</span><input class='y-form-control-test y-ipcontent y-ipcontent-two'></input><span>.</span><input class='y-form-control-test y-ipcontent y-ipcontent-three'></input><span>.</span><input class='y-form-control-test y-ipcontent y-ipcontent-four'></input><span>:</span><input class='y-form-control-test y-port'></input></div>";
    //         var ipaddhtml = "<span class='cs-addicon iconfont icon-plus-circle' id='addip'></span>";
    //         var html = "<div class='y-test-box col-xs-11'><div class='col-xs-2'><div class='row'><input class='y-address col-xs-10 y-form-control-test'></input><span class=''>:</span></div></div><div class='col-xs-2'><div class='row'><input class='y-ipcontent col-xs-10 y-form-control-test'></input><span class=''>.</span></div></div><div class='col-xs-2'><div class='row'><input class='y-ipcontent col-xs-10 y-form-control-test'></input><span class=''>.</span></div></div><div class='col-xs-2'><div class='row'><input class='y-ipcontent col-xs-10 y-form-control-test'></input><span class=''>.</span></div></div><div class='col-xs-2'><div class='row'><input class='y-ipcontent col-xs-10 y-form-control-test'></input><span class=''>:</span></div></div><div class='col-xs-2'><div class='row'><input class='y-port col-xs-10 y-form-control-test'></input></div></div> </div><span class='cs-addicon iconfont icon-plus-circle col-xs-1' id='addip'></span>";
    //         $('.double-input-box').append(html);
    //         $('.y-placeholder').addClass('y-hide');
    //         $('.y-placeholder').removeClass('y-show');
    //         $('.cs-options').addClass('y-hide');
    //         $('.cs-options').removeClass('y-show');
    //         if($('.cs-placeholder')){
    //             $('.cs-placeholder').addClass('y-hide');
    //             $('.cs-placeholder').removeClass('y-show')
    //         }
    //         $('select.cs-select') .addClass('cs-focus')
    //     }else{
    //         $('div.y-test-box').addClass('y-show');
    //         $('div.y-test-box').removeClass('y-hide');
    //         $('.cs-addicon ').addClass('y-show');
    //         $('.cs-addicon ').removeClass('y-hide');
    //         $('.y-placeholder').addClass('y-hide');
    //         $('.y-placeholder').removeClass('y-show');
    //         $('.cs-options').addClass('y-hide');
    //         $('.cs-options').removeClass('y-show');
    //         if($('.cs-placeholder')){
    //             $('.cs-placeholder').addClass('y-hide');
    //             $('.cs-placeholder').removeClass('y-show')
    //         }
    //      }
    //     $('.double-input-box').addClass('y-focus');
        
    //     $("#addip").click(function(){
    //         //将ip加入localstorage中
    //         //先判断ip地址是否合
    //         var ipstr = $('.y-address').val() + ':';
    //         var flag = true;
    //         $('.y-ipcontent').each(function(index){
    //             if(!isValidIP($(this).val()) || !$(this).val()){
    //                 //console.log('ip地址格式错误')
    //                 //显示提示框ip错
    //                 flag =false;
    //             }
    //             //alert(flag)
    //             if(index == 0){
    //                 ipstr = ipstr + $(this).val()
    //             }else{
    //                 ipstr = ipstr +'.'+ $(this).val()
    //             }
    //         })
    //         //alert(flag+ipstr);
    //         if(flag && (ipstr !=='undefined:')){
    //             if($('.y-port').val()){
    //                 ipstr =ipstr + ':' + $('.y-port').val();
    //             }
    //             if(ipstr !== ''){
    //                 if (localStorage.getItem('iplist')) {
    //                     var iplist = JSON.parse(localStorage.getItem('iplist'));
    //                     //如果已经存在则不添加
    //                     if(iplist.indexOf(ipstr) == -1){
    //                         console.log("ip不存在")
    //                         iplist.push(ipstr);
    //                         localStorage.setItem('iplist', JSON.stringify(iplist));
    //                     }else{
    //                         console.log("ip已存在")
    //                     }   
    //                 }else{
    //                     var testarr = [];
    //                     localStorage.setItem('iplist', JSON.stringify(testarr));
    //                     var iplist = JSON.parse(localStorage.getItem('iplist'));
    //                     iplist.push(ipstr);
    //                     localStorage.setItem('iplist', JSON.stringify(iplist));
    //                 }
    //             }
    //             renderselect();
    //         }else{
    //             if((ipstr =='undefined:') && flag){
    //                 return;
    //             }else{
    //                 var tiphtml = "<div class='bugtip'>ip地址格式错误</div>"
    //                 $('.select-box').append(tiphtml);
    //                 setTimeout(function(){
    //                     $('.bugtip').remove();
    //                 },800)
    //             }
                
    //         }
            
    //     })
    // })
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

//与客户端通信，向客户端发送当前打开的ip地址
function getCUAddress(ipurl){
    window.app.getCUAddress(JSON.stringify({url:ipurl}))
};

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
        var script = document.createElement('script');
        script.src = "./static/js/qwebchannel.js";
        document.body.appendChild(script);
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
    }
}
