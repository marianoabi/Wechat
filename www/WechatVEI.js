var exec = require('cordova/exec');

exports.wechatPay = function (arg0, success, error) {
    exec(success, error, 'WechatVEI', 'wechatPay', [arg0]);
};

exports.sendPaymentRequest = function(arg0, success, error) {
    exec(success, error, 'WechatVEI', 'sendPaymentRequest', [arg0]);
}
