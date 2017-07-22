//
//  YingQiSDK.m
//  SGsdk
//
//  Created by twksky on 2017/7/20.
//  Copyright © 2017年 twksky. All rights reserved.
//

#import "YingQiSDK.h"
#import "SGHTTPManager.h"
#import "SGAppUtils.h"

static NSString *K_YingQi_HostName = @"http://dev.imyingqi.com/ChessWebServer/";
//static NSString *K_YingQi_HostName = @"192.168.1.80/";//汪洋本地部署

@interface YingQiSDK ()

@end

@implementation YingQiSDK

#pragma mark 设置方法

+(void)Channel:(NSString *)channel{
    [[NSUserDefaults standardUserDefaults] setObject:channel forKey:@"channel"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(void)GameCode:(NSString *)gameCode{
    [[NSUserDefaults standardUserDefaults] setObject:gameCode forKey:@"gameCode"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(void)HostName:(NSString *)HostName{
    K_YingQi_HostName = HostName;
}

+(void)TestSetting:(BOOL)test{
    if (test == 0) {
        K_YingQi_HostName = @"http://dev.imyingqi.com/ChessWebServer/";
    }else{
        K_YingQi_HostName = @"http://wanba.imyingqi.com/ChessWebServer/";
    }
}

#pragma mark 接口调用
//手机登录注册-发送验证码 1
+(void)YingQiSDKRequst_sendCheckCodeWithNumber:(NSString *)number sB:(void (^)(NSDictionary * dic)) sB fB:(void (^)(NSDictionary * dic))fB{
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:number forKey:@"number"];
    
    [[SGHTTPManager sharedManager] sg_AsyncPostRequestWithEncrypt:[NSString stringWithFormat:@"%@userPhone/sendCheckCode",K_YingQi_HostName] content:dictionary successBlock:^(NSData *data) {
        
        NSDictionary *responseObject = [SGAppUtils JsonDataToObject:data];
        
        if ([responseObject[@"state"] boolValue]) {
            sB(responseObject);
        }else{
            fB(responseObject);
        }
    } failedBlock:^(NSError *error) {
        [[[UIAlertView alloc]initWithTitle:@"提示" message:@"网络请求失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
    }];

}

//手机登录注册-校验验证码 2
+(void)YingQiSDKRequst_receiveCheckCode:(NSString *)number withCheckCode:(NSInteger)checkCode sB:(void (^)(NSDictionary * dic)) sB fB:(void (^)(NSDictionary * dic))fB{
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:number forKey:@"number"];
    [dictionary setObject:@(checkCode) forKey:@"checkCode"];
    
    [[SGHTTPManager sharedManager] sg_AsyncPostRequestWithEncrypt:[NSString stringWithFormat:@"%@userPhone/receiveCheckCode",K_YingQi_HostName] content:dictionary successBlock:^(NSData *data) {
        
        NSDictionary *responseObject = [SGAppUtils JsonDataToObject:data];
        
        if ([responseObject[@"state"] boolValue]) {
            sB(responseObject);
        }else{
            fB(responseObject);
        }
    } failedBlock:^(NSError *error) {
        [[[UIAlertView alloc]initWithTitle:@"提示" message:@"网络请求失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
    }];
    
}

//手机注册-用户信息 3
+(void)YingQiSDKRequst_registerWithNumber:(NSString *)number withCheckCode:(NSInteger)checkCode withPwd:(NSString *)pwd sB:(void (^)(NSDictionary * dic)) sB fB:(void (^)(NSDictionary * dic))fB{
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:number forKey:@"number"];
    [dictionary setObject:@(checkCode) forKey:@"checkCode"];
    [dictionary setObject:pwd forKey:@"pwd"];
    
    [[SGHTTPManager sharedManager] sg_AsyncPostRequestWithEncrypt:[NSString stringWithFormat:@"%@userRegister/register",K_YingQi_HostName] content:dictionary successBlock:^(NSData *data) {
        
        NSDictionary *responseObject = [SGAppUtils JsonDataToObject:data];
        
        if ([responseObject[@"state"] boolValue]) {
            sB(responseObject);
        }else{
            fB(responseObject);
        }
    } failedBlock:^(NSError *error) {
        [[[UIAlertView alloc]initWithTitle:@"提示" message:@"网络请求失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
    }];
    
}

//手机注册-校验手机注册状态（发验证码）4
+(void)YingQiSDKRequst_checkPhoneRegWithNumber:(NSString *)number withCheckCode:(NSInteger)checkCode sB:(void (^)(NSDictionary * dic)) sB fB:(void (^)(NSDictionary * dic))fB{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:number forKey:@"number"];
    
    [[SGHTTPManager sharedManager] sg_AsyncPostRequestWithEncrypt:[NSString stringWithFormat:@"%@userRegister/checkPhoneReg",K_YingQi_HostName] content:dictionary successBlock:^(NSData *data) {
        
        NSDictionary *responseObject = [SGAppUtils JsonDataToObject:data];
        
        if ([responseObject[@"state"] boolValue]) {
            sB(responseObject);
        }else{
            fB(responseObject);
        }
    } failedBlock:^(NSError *error) {
        [[[UIAlertView alloc]initWithTitle:@"提示" message:@"网络请求失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
    }];
}

//手动输入账号、密码进行注册 5
+(void)YingQiSDKRequst_registerAccountWithName:(NSString *)name withPwd:(NSString *)pwd sB:(void (^)(NSDictionary * dic)) sB fB:(void (^)(NSDictionary * dic))fB{
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:name forKey:@"name"];
    [dictionary setObject:pwd forKey:@"pwd"];
    
    [[SGHTTPManager sharedManager] sg_AsyncPostRequestWithEncrypt:[NSString stringWithFormat:@"%@userRegister/registerAccount",K_YingQi_HostName] content:dictionary successBlock:^(NSData *data) {
        
        NSDictionary *responseObject = [SGAppUtils JsonDataToObject:data];
        
        if ([responseObject[@"state"] boolValue]) {
            sB(responseObject);
        }else{
            fB(responseObject);
        }
    } failedBlock:^(NSError *error) {
        [[[UIAlertView alloc]initWithTitle:@"提示" message:@"网络请求失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
    }];
}

//手动输入账号、用户登录-账号或手机号登录 6
+(void)YingQiSDKRequst_loginWithNumberStr:(NSString *)numberStr withPwd:(NSString *)pwd sB:(void (^)(NSDictionary * dic)) sB fB:(void (^)(NSDictionary * dic))fB{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:numberStr forKey:@"numberStr"];
    [dictionary setObject:pwd forKey:@"pwd"];
    
    [[SGHTTPManager sharedManager] sg_AsyncPostRequestWithEncrypt:[NSString stringWithFormat:@"%@userLogin/login",K_YingQi_HostName] content:dictionary successBlock:^(NSData *data) {
        
        NSDictionary *responseObject = [SGAppUtils JsonDataToObject:data];
        
        if ([responseObject[@"state"] boolValue]) {
            sB(responseObject);
        }else{
            fB(responseObject);
        }
    } failedBlock:^(NSError *error) {
        [[[UIAlertView alloc]initWithTitle:@"提示" message:@"网络请求失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
    }];
}

//用户登录-第三方登录 7
//+(void)YingQiSDKRequst_registerAccountWithName:(NSString *)name withPwd:(NSString *)pwd;

//用户登录-自动登录 8
+(void)YingQiSDKRequst_checkWithUid:(NSInteger)uid sB:(void (^)(NSDictionary * dic)) sB fB:(void (^)(NSDictionary * dic))fB{
    
}

//用户登录-无账号登录(游客登录) 9
+(void)YingQiSDKRequst_tempWithsB:(void (^)(NSDictionary * dic)) sB fB:(void (^)(NSDictionary * dic))fB{
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    [[SGHTTPManager sharedManager] sg_AsyncPostRequestWithEncrypt:[NSString stringWithFormat:@"%@userLogin/temp",K_YingQi_HostName] content:dictionary successBlock:^(NSData *data) {
        
        NSDictionary *responseObject = [SGAppUtils JsonDataToObject:data];
        
        if ([responseObject[@"state"] intValue] == 1) {
            sB(responseObject);
        }else{
            fB(responseObject);
        }
    } failedBlock:^(NSError *error) {
        [[[UIAlertView alloc]initWithTitle:@"提示" message:@"网络请求失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
    }];

}

//用户登出-退出登录 10
+(void)YingQiSDKRequst_loginOutWithUid:(NSInteger)uid sB:(void (^)(NSDictionary * dic)) sB fB:(void (^)(NSDictionary * dic))fB{
    
}

//用户手机号码找回密码 11
+(void)YingQiSDKRequst_passwordWithNumber:(NSString *)number withCheckCode:(NSInteger)checkCode withPwd:(NSString *)pwd sB:(void (^)(NSDictionary * dic)) sB fB:(void (^)(NSDictionary * dic))fB{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:@(1) forKey:@"type"];
    [dictionary setObject:pwd forKey:@"pwd"];
    [dictionary setObject:number forKey:@"number"];
    [dictionary setObject:@(checkCode) forKey:@"checkCode"];
    
    [[SGHTTPManager sharedManager] sg_AsyncPostRequestWithEncrypt:[NSString stringWithFormat:@"%@user.password",K_YingQi_HostName] content:dictionary successBlock:^(NSData *data) {
        
        NSDictionary *responseObject = [SGAppUtils JsonDataToObject:data];
        
        if ([responseObject[@"state"] boolValue]) {
            sB(responseObject);
        }else{
            fB(responseObject);
        }
    } failedBlock:^(NSError *error) {
        [[[UIAlertView alloc]initWithTitle:@"提示" message:@"网络请求失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
    }];
}

@end
