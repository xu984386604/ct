//setWinAapp();

function init(){
    //调用函数，重新加载页面
    window.app.pageReload();
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
                    init();
                })
            }
        }
        if(typeof qt != 'undefined'){
            buildChannel();
        }
    }else{
        init();
    }
}