/*RSA加密公钥*/
var pk = "D691BF626490C18A65EBD5D8B68494D7B7E9E7FDF8CADA49E3314F950505C85F0ADC48014D40DA002DD217D86A1C391EFF1C913FEEDD1BA57C741E6F94E11C4CD4B5D800E53AF2C51CDB0427390119C4F81CBE3322D96F198CF9822F2A08B53C23774D3F9B926B996BA93C1AFC295B00EF89D523488ECA00D8E258680D59A677836607CD7772CC8806DA55539EEAABFAA6C003FFD8FA5734F0F3D54EEB9DBAA249C2FAF1C261E3F05A88B6AE0E13179F748863A18E4D94045C8F9DB432EF32E1846F5E1E45B955F536669273955C87F0CBDE1258AD1F6FDF52320D4981B4D78BAF7808745626C2D2FD4A088123070B6B23747C7FDFE89739760539F866D4288D";

/*使用RSA方式加密*/
function encryptPassword(p){
    setMaxDigits(259);
    var key = new RSAKeyPair("10001", '10001', pk, 2048);
    p = encryptedString(key, p, RSAAPP.PKCS1Padding, RSAAPP.RawEncoding);
    /*base64*/
    return window.btoa(p);
}



function setLocalStorage(key,value){
    var curTime = new Date().getTime();
    localStorage.setItem(key,JSON.stringify({data:value,time:curTime}));
}
function getLocalStorage(key){
    /*localstorage的过期时间*/
    var localExpTime = 7 * 24 * 60 * 60 * 1000;
    var data = localStorage.getItem(key);
    var dataObj = JSON.parse(data);
    if (new Date().getTime() - dataObj.time>localExpTime) {
        console.log('信息已过期');
    }else{
        var dataObjDatatoJson = JSON.parse(dataObj.data)
        return dataObjDatatoJson;
    }
}

var CODE_MSG = (function(){
    var msg = {
        /* 一般错误 */
        801:'登录超时',
        802:'验证码错误',
        803:'密码错误',
        804:'密文密码解密错误',
        805:'邮件发送失败',
        806:'验证码过期',
        807:'用户已经存在',
        808:'邮箱已被用户绑定',
        809:'该ip地址注册过于频繁',
        810:'手机号码已绑定过用户',
        811:'短信发送失败',
        812:"用户不存在",
        813:"用户未激活",
        814:"服务器错误814",
        815:"服务器错误815",
        816:"用户已在其它地方登录，请30秒后再试",/*用户已登陆*/
        817:"非法用户名（要求以字母开头的6-32位字母与数字组合）",
        818:"用户名与手机号不匹配",
        819:"密码不符合要求（要求8-32位字母与数字组合）",
        820:"服务器错误820",
        821:"服务器错误821",
        822:"服务器错误822",
        823:"短信发送失败",
        824:"请联系管理员获取license",
        825:"服务器错误825",
        826:"该终端与用户绑定终端不匹配",

        /* 数据库相关 */
        901:'服务器错误901',          // 数据库查询错误
        902:'服务器错误902',          // 数据库插入错误
        903:'服务器错误903',          // 数据库删除错误
        904:'服务器错误904',          // 数据库更新错误
        905:'服务器错误905',          // 数据库事务开启失败
        906:'服务器错误906',          // 数据库事务提交失败
        907:'服务器错误907',          // 数据库连接失败

        /* SOCKET相关 */
        910:'服务器错误910',          // SOCKET连接失败

        /* HTTP请求相关 */
        920:'服务器错误920',          // POST请求返回空
        921:'服务器错误921',          // GET请求错误
        922:'服务器错误922',          // POST请求错误

        /* LDAP相关相关 */
        930:'服务器错误930',          // LDAP同步失败

        /* 服务器相关*/
        941:'服务器错误941',          // 创建REDIS实例失败

        /* 云主机相关相关 */
        1001:'暂无可用主机（code:1001）',          // 没有可用主机
        1002:'该应用主机无法访问',     // 主机不可用
        1003:'服务器错误1003',        // 主机重置用户名失败
        1004:'服务器错误1004',        // Docker应用启动失败
        1005:'服务器错误1005',        // spice应用宿主机IP未设置
        1006:'暂无可用主机（code:1006）',        // 没有可用主机（未授权或授权主机处于关机或未服务状态）
        1007:'暂无可用主机（code:1007）',        // 没有可用主机（SOCKET连AGENT失败）
        1008:'暂无可用主机（code:1008）',        // 没有可用主机（请求Docker Manager启动应用失败）
        1009:'暂无可用主机（code:1009）',        // 没有可用主机（请求AGENT返回主机不可用）
        1010:'服务器错误1010',        // 主机IP不存在

        /* 计费相关相关 */
        1101:'没有选择应用计费模式',
        1102:'余额不足',
        1103:'使用期限已到',
        1104:'微信请求返回失败',
        1105:'小时计费应用订购出错',
        1106:'服务器错误1106',       // APPID错误（缺失）
        1107:'服务器错误1107',       // USERID错误（缺失）
        1108:'服务器错误1108',       // 记录接口调用信息错误
        1109:'服务器错误1109',       // 使用记录不存在（关闭应用时）
        1110:'订单异常',             // 订单应用价格不一致

        /* 云应用相关 */
        1201:'缺少应用资源，请稍后尝试打开（code:1201）',       // 没有VNC应用
        1202:'当前设备不支持',        // 当前设备不支持
        1203:'挂载/卸载网盘失败',     // 挂载/卸载网盘失败
        1204:'应用类型错误'           // 应用类型错误
    };
    return function(code){
        return msg[code] || "未知错误:" + code;
    }
})();