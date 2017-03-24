//
//  APIServer.m
//  SuanGuo
//
//  Created by lianlian on 8/1/16.
//  Copyright © 2016 lianai. All rights reserved.
//

#import "APIServer.h"
#import "SGAppUtils.h"
#define GCDMainQueue        dispatch_get_main_queue()
//void runBlockWithMain(dispatch_block_t block);
//void runBlockWithAsync(dispatch_block_t block);
#undef SCDebugVersion
#define SCDebugVersion 0UL

#undef LogFunctionName
#define LogFunctionName()

static NSUInteger       gs_requestCount = 0;

NSUInteger updateNetworkActivityIndicatorState()
{
//    runBlockWithMain(^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = (0 != gs_requestCount);
//    });
    return gs_requestCount;
}

void enterNetworkActivityIndicatorState()
{
    gs_requestCount += 1;
    updateNetworkActivityIndicatorState();
}

void leaveNetworkActivityIndicatorState()
{
    gs_requestCount -= 1;
    updateNetworkActivityIndicatorState();
}

NSMutableDictionary *getRequestHeader()
{
    //* http头部信息 */
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
    NSString *code = [[NSUserDefaults standardUserDefaults] objectForKey:@"gameCode"];
    if (!code) {
        code = @"2";
    }
    NSString *channel = [[NSUserDefaults standardUserDefaults] objectForKey:@"channel"];
    if (!channel) {
        channel = @"";
    }
    
    NSMutableDictionary *httpHeader = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       /*[SGUserInfoManager instance].uid ?[SGUserInfoManager instance].uid : @"", @"uid",*/
                                       /*[SGUserInfoManager instance].loginKey ?[SGUserInfoManager instance].loginKey : @"", @"loginKey",*/
                                       imei ? imei : @"", @"imei",
                                       /*@([SGUserInfoManager instance].userInfo.gender), @"gender",*/
                                       @([isBroken integerValue]), @"osType",
                                       @"ios", @"ios",
                                       /*@([version integerValue]), @"version",*/
                                       [[UIDevice currentDevice] systemVersion], @"mobileVersion",
                                       channel, @"channel",
                                       [SGAppUtils deviceString], @"deviceModel",
                                       code, @"gameCode",
                                       nil];
    
    //    NSLog(@"http头部: === %@",httpHeader);
    return httpHeader;
}

void syncBlockWithMain(dispatch_block_t block)
{
    if ([NSThread isMainThread])
    {
        block();
        return;
    }
    
    dispatch_sync(GCDMainQueue, block);
}

@implementation APIServer

+ (NSURLSessionDataTask *)postBinaryWithURL:(NSString *)url headers:(NSDictionary *)headers data:(NSData *)data successBlock:(APIDictionaryResponeBlock)block1 faildBlock:(APIDictionaryResponeBlock)block2
{
    LogFunctionName();

    return [self postBinaryEx:url headers:headers data:data successBlock:^(id respone, NSError *error) {
               if (block1) {
//                   runBlockWithMain(^{
                block1(respone, nil);
//            });
               }
           } faildBlock:^(id respone, NSError *error) {
               if (block2) {
//                   runBlockWithMain(^{
                block2(nil, error);
//            });
               }
           }];
}

+ (NSURLSessionDataTask *)postBinaryEx:(NSString *)url headers:(NSDictionary *)headers data:(NSData *)data successBlock:(APIResponeBlock)block1 faildBlock:(APIResponeBlock)block2
{
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    
    if (data)
    {
        req.HTTPBody = data;
        req.HTTPMethod = @"POST";
    }
    else
    {
        req.HTTPMethod = @"GET";
    }
    
    for (NSString *key in headers.allKeys) {
        id value = headers[key];
        
        if ([value isKindOfClass:[NSString class]]) {
            [req setValue:value forHTTPHeaderField:key];
        } else {
            [req setValue:[value description] forHTTPHeaderField:key];
        }
    }
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:req completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
        if (data.length) {
            if (block1) {
//                runBlockWithAsync(^{
                    block1(data, nil);
//                });
            }
            
            return;
        }
        
        if (nil == response) {
            error = [NSError errorWithDomain:@"哎呦，貌似网络不给力" code:0 userInfo:nil];
        }
        
        else if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *rep = (id)response;
            
            if (200 != rep.statusCode) {
                error = [NSError errorWithDomain:@"哎呦，貌似网络不给力" code:0 userInfo:nil];
            }
        }
        
        if (block2) {
//            runBlockWithAsync(^{
                block2(nil, error);
//            });
        }
    }];
    
    [task resume];
    
    return task;
}

+ (NSData *)postBinarySyncEx:(NSString *)url headers:(NSDictionary *)headers data:(NSData *)data successBlock:(APIResponeBlock)block1 faildBlock:(APIResponeBlock)block2
{
    __block NSData  *result = nil;
    __block NSError *nerror = nil;
    
    dispatch_semaphore_t se = dispatch_semaphore_create(0);
    
    [self postBinaryEx:url headers:headers data:data successBlock:^(NSData *respone, NSError *error) {
        result = respone;
        dispatch_semaphore_signal(se);
    } faildBlock:^(NSData *respone, NSError *error) {
        nerror = error;
        dispatch_semaphore_signal(se);
    }];
    
    dispatch_semaphore_wait(se, DISPATCH_TIME_FOREVER);
    
    NSError *error = nerror;
    
    if (error && block2) {
        block2(nil, error);
        return nil;
    }
    
    if (result.length && block1) {
        block1(result, nil);
        return result;
    }
    
    return result;
}

@end
