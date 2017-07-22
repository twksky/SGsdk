//
//  SGHTTPManager.m
//  SGsdk
//
//  Created by twksky on 2016/10/21.
//  Copyright © 2016年 twksky. All rights reserved.
//

#import "SGHTTPManager.h"
#import "AFNetworkReachabilityManager.h"
#import "SGAppUtils.h"
#import "APIServer.h"
#import "SGHttpRequest.h"

@implementation SGHTTPManager

#pragma mark 单例

+(instancetype)sharedManager
{
    static dispatch_once_t predicate;
    static SGHTTPManager *_instance;
    
    dispatch_once(&predicate, ^{
//        NSURL *url = [NSURL URLWithString:@"http://t.xiehou360.com/WechatWebServer/"];
        NSURL *url = [NSURL URLWithString:@""];
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        [config setHTTPAdditionalHeaders:[[self new] getRequestHeaderWithEncrypt]];
  
//  @{@"APP-VERSION": kAppVerison, @"PLATFORM": kPlatform}];
        
        _instance = [[SGHTTPManager alloc] initWithBaseURL:url sessionConfiguration:config];
        _instance.responseSerializer = [AFHTTPResponseSerializer serializer];
        _instance.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
        [_instance setRequestSerializer:[AFJSONRequestSerializer serializer]];
    });
    
    //    Account *account = [AccountManager sharedInstance].account;
    //    NSLog(@"%@",account.token);
    //    [_instance.requestSerializer setValue:account.token forHTTPHeaderField:@"X-AUTH-TOKEN"];
    
    return _instance;
}

#pragma mark 设置头部
- (NSMutableDictionary *)getRequestHeaderWithEncrypt
{
    /* http头部信息 */
    /*
     *   String uid      (用户id)
     *   String loginKey (loginKey)
     *   String gender   (性别)
     *   String osType   (系统类型)
     *   String version  (版本)
     *   String channel  (渠道)
     *   String imei     (串号)
     */
    
//    NSString *version = [SuanGuoVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
    
    NSString *imei = [SGAppUtils getIDFAOrMac];
    
    NSString *isBroken = nil;
    
    if ([SGAppUtils isJailBrokeDevice]) {
        isBroken = @"2";
    } else {
        isBroken = @"1";
    }
    
    /*    NSInteger netWorkStatus = 0;    //未知网络 */
    
    /*
     *    Reachability *r = [Reachability reachabilityWithHostName:@"www.baidu.com"];
     *    switch ([r currentReachabilityStatus])
     *    {
     *        case NotReachable:// 没有网络连接
     *            netWorkStatus = 6;
     *            break;
     *        case ReachableViaWWAN:// 使用3G网络
     *            netWorkStatus = 5;
     *            break;
     *        case ReachableViaWiFi:// 使用WiFi网络
     *            netWorkStatus = 1;
     *            break;
     *        default:
     *            break;
     *    }
     */
    
    /*    NSString *uid = [[LoginInfoModel shareInstance] userId]; */
    
    NSMutableDictionary *httpHeader = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       /*[SGUserInfoManager instance].uid ?[SGUserInfoManager instance].uid : @"", @"uid",*/
                                       /*[SGUserInfoManager instance].loginKey ?[SGUserInfoManager instance].loginKey : @"", @"loginKey",*/
                                       imei ? imei : @"", @"imei",
                                       /*@([SGUserInfoManager instance].userInfo.gender), @"gender",*/
                                       @([isBroken integerValue]), @"osType",
                                       @"ios", @"ios",
                                       /*@([version integerValue]), @"version",*/
                                       [[UIDevice currentDevice] systemVersion], @"mobileVersion",
                                       /*[SGChannelManager channelName], @"channel",*/
                                       [SGAppUtils deviceString], @"deviceModel",
                                       nil];
    
//    NSLog(@"http头部: === %@",httpHeader);
    
    return httpHeader;
}


#pragma mark  

- (NSInteger)parseStatusCode:(NSDictionary *)jsonData
{
    
    NSInteger statusCode = -1;
    
    if ([jsonData objectForKey:@"status_code"] && jsonData[@"status_code"] != [NSNull null]) {
        
        statusCode = [[jsonData objectForKey:@"status_code"] integerValue];
    }
    return statusCode;
}

//- (void)dealWith403WithStatusCode:(NSInteger)statusCode
//{
//    
//}

- (NSString *)parseStatusMessage:(NSDictionary *)jsonData {
    
    NSString *statusMsg = @"未知错误";
    if ([jsonData objectForKey:@"status_message"] && [jsonData objectForKey:@"status_message"] != [NSNull null]) {
        
        statusMsg = [jsonData objectForKey:@"status_message"];
    }
    
    return statusMsg;
}

- (NSError *)localErrorWithMsg:(NSString *)msg withCode:(NSInteger)code {
    
    NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
    [errorDetails setValue:msg forKey:NSLocalizedDescriptionKey];
    return [NSError errorWithDomain:@"未知" code:code userInfo:errorDetails];
}

//- (NSURLSessionDataTask *)SG_POST:(NSString *)URLString parameters:(NSMutableDictionary *)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
//    
////    NSLog(@"twk*******parameters === %@",parameters);
//
//    
//    NSURLSessionDataTask *task = [super POST:URLString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
//        
////        NSInteger statusCode = [self parseStatusCode:responseObject];
//        
////        NSLog(@"twk*******statusCode = %@",responseObject);
//
//        success(task,responseObject);
//        
//    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//        
//        
//        NSLog(@"failure************===  %@,%ld,%ld",[error domain],(long)[AFNetworkReachabilityManager sharedManager].networkReachabilityStatus,(long)((NSHTTPURLResponse *)task.response).statusCode);
//        
//        NSString *msg = @"";
//        if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable || !task.response) {
//            
//            msg = @"网络异常，请稍后重试";
//        } else {
//            
//            msg = @"服务器异常，请稍后重试";
//        }
//        
//        failure(task, [self localErrorWithMsg:msg withCode:-100]);
//        
//    }];
//    
//    return task;
//}

- (void)sg_AsyncPostRequestWithEncrypt:(NSString *)url content:(NSMutableDictionary *)content successBlock:(void (^)(NSData *data)) successBlock failedBlock:(void (^)(NSError *error))failedBlock{

    NSLog(@"头部：%@",[self getRequestHeaderWithEncrypt]);
    
    NSString *channel = [[NSUserDefaults standardUserDefaults] objectForKey:@"channel"];
    NSString *gameCode = [[NSUserDefaults standardUserDefaults] objectForKey:@"gameCode"];

    if (channel) {
        [content setObject:channel forKey:@"channel"];
    }
    
    if (gameCode) {
        [content setObject:gameCode forKey:@"gameCode"];
    }
    
    [[SGHttpRequest instance] asyncPostRequestWithEncrypt:url content:content successBlock:^(NSData *data) {
        successBlock(data);
    } failedBlock:^(NSError *error) {
        failedBlock(error);
    }];
}

@end
