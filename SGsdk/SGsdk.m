//
//  SGsdk.m
//  SGsdk
//
//  Created by twksky on 2016/10/17.
//  Copyright © 2016年 twksky. All rights reserved.
//

#import "SGsdk.h"
#import "WXApi.h"
#import "WXApiObject.h"
#import "WechatAuthSDK.h"
#import "SGHTTPManager.h"
#import "SGAudioManger.h"
#import "HappyDNS.h"
#import "SGAppUtils.h"
#import "SGShareManager.h"

#define AppID @"wx26a155be7ae79410"

#define  AppSecret @"1a351dcf65f5cfb8f2ef161e82455de6"

/** 微信跳转：第三方程序本身用来标识其请求的唯一性，最后跳转回第三方程序时，由微信终端回传。*/
#define kWeiXinState      @ "login"//登录时候传login

//@protocol SGApiDelegate <NSObject>
//@optional
//
///*! @brief 收到一个来自微信的请求，第三方应用程序处理完后调用sendResp向微信发送结果
// *
// * 收到一个来自微信的请求，异步处理完成后必须调用sendResp发送处理结果给微信。
// * 可能收到的请求有GetMessageFromWXReq、ShowMessageFromWXReq等。
// * @param req 具体请求内容，是自动释放的
// */
//-(void) onReq:(BaseReq*)req;
//
//
///*! @brief 发送一个sendReq后，收到微信的回应
// *
// * 收到一个来自微信的处理结果。调用一次sendReq后会收到onResp。
// * 可能收到的处理结果有SendMessageToWXResp、SendAuthResp等。
// * param resp具体的回应内容，是自动释放的
// */
//-(void) onResp:(BaseResp*)resp;
//
//@end

NSString *KHostName = @"http://wanba.imyingqi.com/wechat/";

@interface SGsdk()<WXApiDelegate>

@property (nonatomic, weak) id<SGApiDelegate> delegate;

@end

static NSString *kAppID = nil;
static NSString *kAppSecret = nil;

@implementation SGsdk

+ (SGsdk *)instance{
    static SGsdk *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(void)sg_show{
    NSLog(@"酸果SDK");
}

+(void)sg_showBuild{
    NSLog(@"酸果新版本SDK");
    NSLog(@"%@",[WXApi getApiVersion]);
}

+(BOOL)isIntallWX{
    return [WXApi isWXAppInstalled];
}

+(void)Channel:(NSString *)channel{
    [[NSUserDefaults standardUserDefaults] setObject:channel forKey:@"channel"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(void)GameCode:(NSString *)gameCode{
    [[NSUserDefaults standardUserDefaults] setObject:gameCode forKey:@"gameCode"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(void)HostName:(NSString *)HostName{
    KHostName = HostName;
}

+(void)sg_RegisterApp:(NSString *)appKey{
    [WXApi registerApp:appKey];
}

+(BOOL)sg_HandleOpenURL:(NSURL *)url delegate:(id<SGApiDelegate>)delegate{
    [SGsdk instance].delegate = delegate;
    return [WXApi handleOpenURL:url delegate:[SGsdk instance]];
}

+(BOOL)auth:(NSString *)scope withAppID:(NSString *)appID withAppSecret:(NSString *)appSecret{
    if (![WXApi isWXAppInstalled]) {
        return NO;
    }
    kAppID = appID;
    kAppSecret = appSecret;
    // 构造SendAuthReq结构体
    SendAuthReq *req = [[SendAuthReq alloc] init];
    req.scope = scope;
    req.state = kWeiXinState;
    // 第三方向微信终端发送一个SendAuthReq消息结构
    return [WXApi sendReq:req];
}

+(void)checkAccount:(NSString *)gameToken withSuccusBlock:(void (^)())succusBlock withFaildBlock:(void (^)(NSError *error))faildBlock{
    
    NSString *code = [[NSUserDefaults standardUserDefaults] objectForKey:@"gameCode"];
    if (!code) {
        code = @"2";
    }
    
    [[SGHTTPManager sharedManager] sg_AsyncPostRequestWithEncrypt:[NSString stringWithFormat:@"%@userCheck.do",KHostName] content:[NSMutableDictionary dictionaryWithObjectsAndKeys:gameToken,@"gameToken",@(code.intValue),@"gameCode", nil] successBlock:^(NSData *data) {
        
        NSDictionary *responseObject = [SGAppUtils JsonDataToObject:data];
        
        if ([responseObject[@"state"] intValue] == 1) {
            succusBlock();
        }else{
//            [self sg_WXloginWithScope:@"snsapi_userinfo" withAppID:AppID withAppSecret:AppSecret];
            NSError *er = [[NSError alloc]initWithDomain:[NSString stringWithFormat:@"请重新登录"] code:1 userInfo:nil];
            faildBlock(er);
        }
    } failedBlock:^(NSError *error) {
        NSError *er = [[NSError alloc]initWithDomain:[NSString stringWithFormat:@"失败"] code:0 userInfo:nil];
        faildBlock(er);
    }];
}

#pragma mark 回调 
-(void)onReq:(BaseReq *)req{
//    if ([self.delegate respondsToSelector:@selector(sg_LoginHandle:)]) {
//        [self.delegate performSelector:@selector(sg_LoginHandle:) withObject:req];
//    }
    NSLog(@"回调回调回调回调回调回调:%d",req.type);
}

-(void)onResp:(BaseResp *)resp{
    
//    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
//        SendMessageToWXResp *sendResult = (SendMessageToWXResp *)resp;
//        
//        if (sendResult.errCode == 0) {
//            
//        }
//    }

    if ([resp isKindOfClass:[SendAuthResp class]]) {
        /*
         *   ErrCode ERR_OK = 0(用户同意)
         *   ERR_AUTH_DENIED = -4（用户拒绝授权）
         *   ERR_USER_CANCEL = -2（用户取消）
         *   code    用户换取access_token的code，仅在ErrCode为0时有效
         *   state   第三方程序发送时用来标识其请求的唯一性的标志，由第三方程序调用sendReq时传入，由微信终端回传，state字符串长度不能超过1K
         *   lang    微信客户端当前语言
         *   country 微信用户当前国家信息
         */
        SendAuthResp *aresp = (SendAuthResp *)resp;
        
        if ((aresp.errCode == 0) && [aresp.state isEqualToString:kWeiXinState]) {
            NSString *code = aresp.code;
//            NSLog(@"twk.SGsdk_code=====%@",code);
            [self getWeiXinTokenByCode:code];
        }
    }
    else {
//    NSLog(@"aaaaaaa:%zd",resp.errCode);
        if ([self.delegate respondsToSelector:@selector(sg_shareHandle:)]) {
            [self.delegate performSelector:@selector(sg_shareHandle:) withObject:[NSString stringWithFormat:@"%zd",resp.errCode]];
        }
    }
}

#pragma  mark - 获取微信的token
- (void)getWeiXinTokenByCode:(NSString *)code
{
    NSString *url = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code", kAppID, kAppSecret, code];
    
    NSString *codeee = [[NSUserDefaults standardUserDefaults] objectForKey:@"gameCode"];
    if (!codeee) {
        codeee = @"2";
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *zoneUrl = [NSURL URLWithString:url];
        NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                NSMutableDictionary *jsonDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                [dic objectForKey:@"openid"], @"openid",
                                                [dic objectForKey:@"access_token"], @"accessToken",
                                                @(codeee.intValue), @"gameCode",
                                                dic[@"unionid"], @"unionid",
                                                nil];

//                NSLog(@"twk.SGsdk_dic=======%@",dic);
//                NSLog(@"twk.SGsdk_jsonDic=======%@",jsonDic);

                [self venderLoginWithInfo:jsonDic];
            }
        });
    });
}

#pragma mark - 登录请求
- (void)venderLoginWithInfo:(NSMutableDictionary *)dictM
{
    
    [[SGHTTPManager sharedManager] sg_AsyncPostRequestWithEncrypt:[NSString stringWithFormat:@"%@userLogin.do",KHostName] content:dictM successBlock:^(NSData *data) {
        NSLog(@"地址：%@",[NSString stringWithFormat:@"%@userLogin.do",KHostName]);
        NSDictionary *responseObject = [SGAppUtils JsonDataToObject:data];
        if ([self.delegate respondsToSelector:@selector(sg_LoginHandle:)]) {
            [self.delegate performSelector:@selector(sg_LoginHandle:) withObject:responseObject];
        }
        
        NSLog(@"sg_venderLoginWithInfo ==== success");
        NSLog(@"%@",responseObject);
        
    } failedBlock:^(NSError *error) {
        if ([self.delegate respondsToSelector:@selector(sg_LoginHandle:)]) {
            [self.delegate performSelector:@selector(sg_LoginHandle:) withObject:error];
        }
        
        NSLog(@"sg_venderLoginWithInfo ==== failure");
        NSLog(@"sg_failure ====%@",error);
    }];
    
}

+(void)sg_ShareWeiXinShareToPeopleText:(NSString *)textStr WebImgUrl:(NSString *)imgUrlStr ForLinkStr:(NSString *)linkStr title:(NSString *)title picislocal:(BOOL)picislocal onlyPic:(BOOL)isOnlyPic{
    [[SGShareManager defaultCloudManger]weiXinShareToPeopleText:textStr WebImgUrl:imgUrlStr ForLinkStr:linkStr title:title picislocal:picislocal onlyPic:isOnlyPic];
}


+(void)sg_ShareWeiXinShareToGroupText:(NSString *)textStr WebImgUrl:(NSString *)imgUrlStr ForLinkStr:(NSString *)linkStr title:(NSString *)title picislocal:(BOOL)picislocal onlyPic:(BOOL)isOnlyPic{
     [[SGShareManager defaultCloudManger] weiXinShareToGroupText:textStr WebImgUrl:imgUrlStr ForLinkStr:linkStr title:title picislocal:picislocal onlyPic:isOnlyPic];
}

+(void)sg_VisitorWithDelegate:(id<SGApiDelegate>)delegate{
    [[self class] instance].delegate = delegate;
    NSString *code = [[NSUserDefaults standardUserDefaults] objectForKey:@"gameCode"];
    if (!code) {
        code = @"2";
    }
    
    [[SGHTTPManager sharedManager] sg_AsyncPostRequestWithEncrypt:[NSString stringWithFormat:@"%@userLoginVisitor.do",KHostName] content:[NSMutableDictionary dictionaryWithObjectsAndKeys:@(code.intValue),@"gameCode", nil] successBlock:^(NSData *data) {
        
        NSLog(@"请求地址%@",[NSString stringWithFormat:@"%@userLoginVisitor.do",KHostName]);
        
        NSLog(@"访客登录接口成功！！！%@",[[self class] instance].delegate);
        
        NSDictionary *responseObject = [SGAppUtils JsonDataToObject:data];
        
//        if ([responseObject[@"state"] intValue] == 1) {
//        }
        
            NSLog(@"访客登录接口:%@",responseObject);
            if ([[[self class] instance].delegate respondsToSelector:@selector(sg_LoginHandle:)]) {
                [[[self class] instance].delegate performSelector:@selector(sg_LoginHandle:) withObject:responseObject];
            }
            
    } failedBlock:^(NSError *error) {
        
        NSLog(@"访客登录接口失败！！！");

        if ([[[self class] instance].delegate respondsToSelector:@selector(sg_LoginHandle:)]) {
            [[[self class] instance].delegate performSelector:@selector(sg_LoginHandle:) withObject:error];
        }
        
    }];

}

+(void)sg_aduitVersionCheckVersionCode:(NSString *)versionCode withSuccusBlock:(void (^)(BOOL))succusBlock withFaildBlock:(void (^)(NSError *))faildBlock{
    NSString *code = [[NSUserDefaults standardUserDefaults] objectForKey:@"gameCode"];
    if (!code) {
        code = @"2";
    }
    NSString *channel = [[NSUserDefaults standardUserDefaults] objectForKey:@"channel"];
    if (!channel) {
        channel = @"";
    }
    
    [[SGHTTPManager sharedManager] sg_AsyncPostRequestWithEncrypt:[NSString stringWithFormat:@"%@aduitVersionCheck.do",KHostName] content:[NSMutableDictionary dictionaryWithObjectsAndKeys:versionCode,@"versionCode",@(code.intValue),@"gameCode",channel,@"channel",nil] successBlock:^(NSData *data) {

        NSDictionary *responseObject = [SGAppUtils JsonDataToObject:data];
        
        NSLog(@"版本审核判断成功:%@",responseObject);
        if (responseObject[@"state"]) {
            succusBlock(((NSString*)(responseObject[@"aduitFlag"])).boolValue);
        }else{
            faildBlock(nil);
        }
        
    } failedBlock:^(NSError *error) {
        
        NSLog(@"版本审核判断失败:%@",error.domain);
        faildBlock(error);
        
    }];
}

@end
