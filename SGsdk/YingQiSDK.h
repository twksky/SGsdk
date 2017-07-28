//
//  YingQiSDK.h
//  SGsdk
//
//  Created by twksky on 2017/7/20.
//  Copyright © 2017年 twksky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YingQiSDK : NSObject

#pragma mark 设置方法

+(void)Channel:(NSString *)channel;//不设置默认为空

+(void)GameCode:(NSString *)gameCode;//不设置默认为空

+(void)HostName:(NSString *)HostName;//不设置默认为 http://dev.imyingqi.com/ChessWebServer/  (线下)，或者自己设置HostName

+(void)TestSetting:(BOOL)test;//不设置默认为YES 测试环境。test传NO为正式环境

#pragma mark 接口调用
//手机登录注册-发送验证码 1
+(void)YingQiSDKRequst_sendCheckCodeWithNumber:(NSString *)number sB:(void (^)(NSDictionary * dic)) sB fB:(void (^)(NSDictionary * dic))fB;

//手机登录注册-校验验证码 2
+(void)YingQiSDKRequst_receiveCheckCode:(NSString *)number withCheckCode:(NSInteger)checkCode sB:(void (^)(NSDictionary * dic)) sB fB:(void (^)(NSDictionary * dic))fB;

//手机注册-用户信息 3
+(void)YingQiSDKRequst_registerWithNumber:(NSString *)number withCheckCode:(NSInteger)checkCode withPwd:(NSString *)pwd sB:(void (^)(NSDictionary * dic)) sB fB:(void (^)(NSDictionary * dic))fB;

//手机注册-校验手机注册状态（发验证码）4
+(void)YingQiSDKRequst_checkPhoneRegWithNumber:(NSString *)number withCheckCode:(NSInteger)checkCode sB:(void (^)(NSDictionary * dic)) sB fB:(void (^)(NSDictionary * dic))fB;

//手动输入账号、密码进行注册 5
+(void)YingQiSDKRequst_registerAccountWithName:(NSString *)name withPwd:(NSString *)pwd sB:(void (^)(NSDictionary * dic)) sB fB:(void (^)(NSDictionary * dic))fB;

//手动输入账号、用户登录-账号或手机号登录 6
+(void)YingQiSDKRequst_loginWithNumberStr:(NSString *)numberStr withPwd:(NSString *)pwd withLoginKey:(NSString *)loginKey sB:(void (^)(NSDictionary * dic)) sB fB:(void (^)(NSDictionary * dic))fB;

//用户登录-第三方登录 7
//+(void)YingQiSDKRequst_registerAccountWithName:(NSString *)name withPwd:(NSString *)pwd;

//用户登录-自动登录 8
+(void)YingQiSDKRequst_checkWithUid:(NSInteger)uid sB:(void (^)(NSDictionary * dic)) sB fB:(void (^)(NSDictionary * dic))fB;

//用户登录-无账号登录(游客登录) 9
+(void)YingQiSDKRequst_tempWithsB:(void (^)(NSDictionary * dic)) sB fB:(void (^)(NSDictionary * dic))fB;

//用户登出-退出登录 10
+(void)YingQiSDKRequst_loginOutWithUid:(NSInteger)uid sB:(void (^)(NSDictionary * dic)) sB fB:(void (^)(NSDictionary * dic))fB;

//用户手机号码找回密码 11
+(void)YingQiSDKRequst_passwordWithNumber:(NSString *)number withCheckCode:(NSInteger)checkCode withPwd:(NSString *)pwd sB:(void (^)(NSDictionary * dic)) sB fB:(void (^)(NSDictionary * dic))fB;

// 验证手机号(是否可以进入发送验证码流程)
+(void)YingQiSDKRequst_checkBindPhoneWithNumber:(NSString *)number withUid:(NSInteger)uid sB:(void (^)(NSDictionary * dic)) sB fB:(void (^)(NSDictionary * dic))fB;

// 绑定手机(带验证码)
+(void)YingQiSDKRequst_BindPhoneWithNumber:(NSString *)number withCheckCode:(NSInteger)checkCode withTempUser:(NSDictionary *)tempUser sB:(void (^)(NSDictionary * dic)) sB fB:(void (^)(NSDictionary * dic))fB;

@end
