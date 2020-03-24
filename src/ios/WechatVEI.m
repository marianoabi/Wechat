/********* WechatVEI.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#import "WXApi.h"
#import "WXApiObject.h"

@interface WechatVEI : CDVPlugin<WXApiDelegate> {
}

@property (nonatomic, strong) NSString *currentCallbackId;
@property (nonatomic, strong) NSString *wechatAppId;

- (void)wechatPay:(CDVInvokedUrlCommand *)command;
- (void)sendPaymentRequest:(CDVInvokedUrlCommand *)command;

@end

@implementation WechatVEI

- (void)pluginInitialize {
    NSString* appId = [[self.commandDelegate settings] objectForKey:@"wechatappid"];
    
    NSString* universalLink = @"https://ecride.hksr.org.hk/RiderWeb/";
    
    if (appId && ![appId isEqualToString:self.wechatAppId]) {
        self.wechatAppId = appId;
        [WXApi registerApp: appId universalLink: universalLink];
        
        bool appRegistrationSuccess = [WXApi registerApp: appId universalLink: universalLink];
        
        if (appRegistrationSuccess) {
            NSLog(@"cordova-plugin-vei-wechat-pay has been initialized. Wechat SDK Version: %@. APP_ID: %@.", [WXApi getApiVersion], appId);
        } else {
            NSLog(@"Failed to register App.");
        }
    }
}

- (void)wechatPay:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult* pluginResult = nil;
    NSString* echo = [command.arguments objectAtIndex:0];

    if (echo != nil && [echo length] > 0) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:echo];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)sendPaymentRequest:(CDVInvokedUrlCommand *)command
{
    // check arguments
    NSDictionary *params = [command.arguments objectAtIndex:0];
    if (!params)
    {
        [self failWithCallbackID:command.callbackId withMessage:@"No params!"];
        return ;
    }

    // check required parameters
    NSArray *requiredParams;
    if ([params objectForKey:@"mch_id"])
    {
        requiredParams = @[@"mch_id", @"prepay_id", @"timestamp", @"nonce", @"sign"];
    }
    else
    {
        requiredParams = @[@"partnerid", @"prepayid", @"timestamp", @"noncestr", @"sign"];
    }

    for (NSString *key in requiredParams)
    {
        if (![params objectForKey:key])
        {
            [self failWithCallbackID:command.callbackId withMessage:@"Required param missing!"];
            return ;
        }
    }

    PayReq *req = [[PayReq alloc] init];

    req.partnerId = [params objectForKey:requiredParams[0]];
    req.prepayId = [params objectForKey:requiredParams[1]];
    req.timeStamp = [[params objectForKey:requiredParams[2]] intValue];
    req.nonceStr = [params objectForKey:requiredParams[3]];
    req.package = @"Sign=WXPay";
    req.sign = [params objectForKey:requiredParams[4]];

    [WXApi sendReq:req completion:^(BOOL success) {
        if (success) {
            self.currentCallbackId = command.callbackId;
        } else {
            [self failWithCallbackID:command.callbackId withMessage:@"Send request failed"];
        }
    }];
}

- (void)successWithCallbackID:(NSString *)callbackID
{
    [self successWithCallbackID:callbackID withMessage:@"OK"];
}

- (void)successWithCallbackID:(NSString *)callbackID withMessage:(NSString *)message
{
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:message];
    [self.commandDelegate sendPluginResult:commandResult callbackId:callbackID];
}

- (void)failWithCallbackID:(NSString *)callbackID withError:(NSError *)error
{
    [self failWithCallbackID:callbackID withMessage:[error localizedDescription]];
}

- (void)failWithCallbackID:(NSString *)callbackID withMessage:(NSString *)message
{
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:message];
    [self.commandDelegate sendPluginResult:commandResult callbackId:callbackID];
}

@end
