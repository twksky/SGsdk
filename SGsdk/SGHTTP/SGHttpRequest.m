/*  */

#import "SGHttpRequest.h"
//#import "sma11case.h"
//#import "sma11case.h"
//#import "Components.h"
#import "APIServer.h"
#import "SGAppUtils.h"
#import "SGJSONUtils.h"
#import "GTMBase64.h"
#import <CommonCrypto/CommonCryptor.h>

// 警告!!!必须作为最后一个引入,且必须在.m或.mm中引入，否则呵呵!!!
//#import "SCHook.h"

//#if SCDebugVersion
#undef UseNewNetwork
#define UseNewNetwork 1UL
//#endif

#undef LogFunctionName
#define LogFunctionName()

#undef SCDebug
#define SCDebug 0UL

@interface RequestInfo : NSObject {
    //    id		target;
    SEL             successAction;
    SEL             failureAction;
    NSDictionary    *userInfo;

    BOOL    active;
    BOOL    serverIsError; /* 404\500错误 */

    NSMutableData   *data;
    NSString        *cacheName;
}

@property (nonatomic, strong) id              target;
@property (nonatomic, assign) SEL           successAction;
@property (nonatomic, assign) SEL           failureAction;
@property (nonatomic, strong) NSDictionary  *userInfo;
@property (nonatomic, assign) BOOL          active;
@property (nonatomic, assign) BOOL          serverIsError;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSString      *cacheName;

- (id)init;

@end
@implementation RequestInfo

@synthesize target;
@synthesize successAction;
@synthesize failureAction;
@synthesize userInfo;
@synthesize active;
@synthesize data;
@synthesize serverIsError;
@synthesize cacheName;

- (id)init
{
    LogFunctionName();

    if (self = [super init]) {
        data = [[NSMutableData alloc] init];
    }

    return self;
}

//- (void)dealloc
//{
//    LogFunctionName();
//
//    [data release];
//    [userInfo release];
//    [cacheName release];
//    //    [super dealloc];
//}

@end

/*
 * @interface NSURLRequest (DummyInterface)
 * + (BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host;
 * + (void)setAllowsAnyHTTPSCertificate:(BOOL)allow forHost:(NSString*)host;
 * @end
 */
@interface SGHttpRequest ()
@end

@interface SGHttpRequest (Private)

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection;
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace;
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;

@end

@implementation SGHttpRequest (Private)

/* /////////////////////////////////////////////////////// */
#pragma mark NSURLConnection delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    LogFunctionName();

    RequestInfo *request = [requests objectForKey:[NSValue valueWithNonretainedObject:connection]];

    [request.data setLength:0];

    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

    /* 判断服务器是否返回404 */
    if ((([httpResponse statusCode] / 100) != 2)) {
//        NSLog(@"SGHttpRequest connection didReceiveResponse:%zd andUrl:%@", [httpResponse statusCode], [httpResponse URL]);

        request.serverIsError = YES;
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:
            NSLocalizedString(@"Connect error",
            @"Error message displayed when receving a connection error.")
            forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:@"HTTP" code:[httpResponse statusCode] userInfo:userInfo];

        if (([error code] == 404) || ([error code] == 500)) {
            /*            RequestInfo *request = [requests objectForKey:[NSValue valueWithNonretainedObject:connection]]; */
        }
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    LogFunctionName();

    RequestInfo *request = [requests objectForKey:[NSValue valueWithNonretainedObject:connection]];

    request.active = NO;
    --activeRequestsCount;

    if ((request.serverIsError == NO) && ([request.data length] != 0)) {
        if (request.target && [request.target respondsToSelector:request.successAction]) {
            [request.target performSelector:request.successAction withObject:request.data withObject:request.userInfo];
        }

        /* 缓存数据到本地 */
        if (request.cacheName) {
            NSString *resultStr = [[[NSString alloc] initWithData:request.data encoding:NSUTF8StringEncoding] autorelease];

            /* 如果服务器有返回result_Code 字段表示,服务器正在重启,不需要进行缓存 */
            NSRange range = [resultStr rangeOfString:@"result_Code"];

            if (range.location == NSNotFound) {
                NSString    *encryptCacheName = request.cacheName;
                NSString    *path = [NSString stringWithFormat:@"%@%@", HttpCacheFilePath, encryptCacheName];
                NSData      *encryptCacheData = [request.data tripleDES];
                [encryptCacheData writeToFile:path atomically:YES];
            }
        }
    } else {
        NSURLRequest *currentRequest = [connection currentRequest];

        NSError *error = nil;

        if (request.serverIsError == YES) {
            NSLog(@"请求服务器出错, url=%@", [[currentRequest URL] absoluteString]);
            error = [NSError errorWithDomain:[NSString stringWithFormat:@"连接服务器出错,请稍候再试."] code:0 userInfo:nil];
        }

        if ([request.data length] == 0) {
            NSLog(@"服务器返回空数据, url=%@", [[currentRequest URL] absoluteString]);
            error = [NSError errorWithDomain:[NSString stringWithFormat:@"数据格式错误,请稍候再试."] code:0 userInfo:nil];
        }

        if (request.target && [request.target respondsToSelector:request.failureAction]) {
            [request.target performSelector:request.failureAction withObject:error withObject:request.userInfo];
        }
    }

    [requests removeObjectForKey:[NSValue valueWithNonretainedObject:connection]];

    if ([requests allKeys].count == 0) {
        leaveNetworkActivityIndicatorState();
    }

    [self connectionEnded];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    LogFunctionName();

    NSLog(@"SGHttpRequest connection didFailWithError: %@, %p", error, connection);
    RequestInfo *request = [requests objectForKey:[NSValue valueWithNonretainedObject:connection]];
    request.active = NO;
    --activeRequestsCount;

    NSError *returnError = nil;

    if ([error code] == -1001) {
        returnError = [NSError errorWithDomain:[NSString stringWithFormat:@"连接服务器超时,请稍候再试."] code:0 userInfo:nil];
    } else {
        returnError = [NSError errorWithDomain:[NSString stringWithFormat:@"连接服务器出错,请稍候再试."] code:0 userInfo:nil];
    }

    if (request.target && [request.target respondsToSelector:request.failureAction]) {
        [request.target performSelector:request.failureAction withObject:returnError withObject:request.userInfo];
    }

    [requests removeObjectForKey:[NSValue valueWithNonretainedObject:connection]];

    if ([requests allKeys].count == 0) {
        leaveNetworkActivityIndicatorState();
    }

    [self connectionEnded];
}

/* 处理数据 */
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    LogFunctionName();

    RequestInfo *request = [requests objectForKey:[NSValue valueWithNonretainedObject:connection]];

    [request.data appendData:data];
    /*    NSLog(@"%@", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]); */
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection
{
    LogFunctionName();

    return NO;
}

/*下面两段是重点，要服务器端单项HTTPS验证，iOS客户端忽略证书验证。 */
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    LogFunctionName();

    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    LogFunctionName();

    NSLog(@"SGHttpRequest didReceiveAuthenticationChallenge %@ %zd", [[challenge protectionSpace] authenticationMethod], (ssize_t)[challenge previousFailureCount]);

    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        [[challenge sender] useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
        [[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
    }
}

@end

@implementation SGHttpRequest
@synthesize requestArrs;

@synthesize concurrentRequestsLimit;

+ (SGHttpRequest *)instance
{
    LogFunctionName();

    static SGHttpRequest *x = nil;

    if (x == nil) {
        x = [[SGHttpRequest alloc] init];

        if (![[NSFileManager defaultManager] fileExistsAtPath:HttpCacheFilePath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:HttpCacheFilePath
                                            withIntermediateDirectories :YES
                                            attributes                  :nil
                                            error                       :NULL];
        }
    }

    return x;
}

- (id)init
{
    LogFunctionName();

    if (self = [super init]) {
        concurrentRequestsLimit = 8;
        requests = [[NSMutableDictionary alloc] init];
        queue = [[NSMutableArray alloc] init];
        requestArrs = [[NSMutableArray alloc] init];
    }

    return self;
}

- (void)dealloc
{
    LogFunctionName();

    [self cancelAllRequests];
    [requestArrs release];
    [requests release];
    [queue release];
    //    [super dealloc];
}

- (void)startRequest:(NSURLConnection *)con
{
    LogFunctionName();

    RequestInfo *request = [requests objectForKey:[NSValue valueWithNonretainedObject:con]];

    request.active = YES;
    ++activeRequestsCount;
    [con start];
}

- (void)stopRequest:(NSURLConnection *)con
{
    LogFunctionName();

    RequestInfo *request = [requests objectForKey:[NSValue valueWithNonretainedObject:con]];

    request.active = NO;
    --activeRequestsCount;
    [con cancel];
}

- (void)queueRequest:(NSURLConnection *)con
{
    LogFunctionName();

    [queue addObject:con];
}

- (NSURLConnection *)dequeueRequest
{
    LogFunctionName();

    NSURLConnection *con = [[queue objectAtIndex:0] retain];

    [queue removeObjectAtIndex:0];
    return [con autorelease];
}

- (void)connectionEnded
{
    LogFunctionName();

    if ((activeRequestsCount < concurrentRequestsLimit) && ([queue count] > 0)) {
        [self startRequest:[self dequeueRequest]];
    }
}

#pragma mark Public
- (void)clearRequestDelegate:(id)_delegate
{
    LogFunctionName();

    /*    NSMutableArray *cancelCon = [NSMutableArray arrayWithCapacity:5]; */
    for (NSValue *key in requests) {
        RequestInfo *request = [requests objectForKey:key];

        if (request.target == _delegate) {
            request.target = nil;
            /*            [cancelCon addObject:cancelCon]; */
        }
    }

    /*
     *    for (NSValue *value in cancelCon)
     *    {
     *        NSURLConnection *con = nil;
     *        [value getValue:&con];
     *        if (con)
     *        {
     *            [self cancelRequest:con];
     *        }
     *    }
     */
}

//- (NSData *)getHttpCacheData:(NSString *)cacheName
//{
//    LogFunctionName();
//
//    NSString    *encryptCacheName = [cacheName tripleDES];
//    NSString    *path = [NSString stringWithFormat:@"%@%@", HttpCacheFilePath, encryptCacheName];
//    NSData      *encryptCacheData = [NSData dataWithContentsOfFile:path];
//
//    if (encryptCacheData && ([encryptCacheData length] != 0)) {
//        NSData *decodeData = [encryptCacheData decodeTripleDES];
//        return decodeData;
//    }
//
//    return nil;
//}

/*同步的http请求 */
- (NSData *)sendRequestSyncWithEncrypt:(NSString *)url andMethod:(NSString *)method andContent:(NSMutableDictionary *)content andTimeout:(int)seconds andError:(NSError **)error
{
    LogFunctionName();

    if (([Reachability reachabilityForInternetConnection] == nil) || ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == 0)) {
        *error = [NSError errorWithDomain:[NSString stringWithFormat:@"无网络连接,请检查网络"] code:0 userInfo:nil];
        return nil;
    }

#if UseNewNetwork
        {
            NSMutableDictionary *headers = [NSMutableDictionary dictionary];
//            NewMutableDictionary();
            headers[@"ios"] = @"ios";
            headers[@"Content-type"] = @"application/octet-stream";

            NSString *keyString = [SGJSONUtils ObjectToJsonString:getRequestHeader()];
//            [SGJSONUtils ObjectToJsonString:getRequestHeader()];
//            [getRequestHeader() toJsonString];
            NSLog(@"before$$****2");
            headers[@"headKey"] = [self encryptString:keyString];
            NSLog(@"before$$****3");
            NSData *pd = [SGJSONUtils ObjectToJsonData:[self encryptString:[SGJSONUtils ObjectToJsonString:content]]];

            NSData *res = [APIServer postBinarySyncEx:url headers:headers data:pd successBlock:nil faildBlock:nil];

            return res;
        }
#else

    enterNetworkActivityIndicatorState();
    /* /////////////////////////////////////////////////////////////////////////////// */
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:seconds];

    /*
     *    [NSMutableURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[[NSURL URLWithString:url] host]];
     * 设置请求方式
     */
    [request setHTTPMethod:method];

    /*
     * 添加用户会话id
     *    NSLog(@"url:%@", url);
     * /////////////////////////
     */

    NSMutableDictionary *headerFields = [self getRequestHeaderWithEncrypt];

    NSString *headJSONString = [SGJSONUtils ObjectToJsonString:headerFields];
    /*    NSLog(@"headJSON:%@", headJSONString); */

    if (headJSONString.length && headJSONString) {
        NSLog(@"before$$****4");
        [request setValue:[self encryptString:headJSONString] forHTTPHeaderField:@"headKey"];
        [request setValue:@"ios" forHTTPHeaderField:@"ios"];
    }

    [request setValue:@"" forHTTPHeaderField:@"Content-type"];

    /************************** 加密内容／发送文件流 *************************************************/

    NSString *str = [SGJSONUtils ObjectToJsonString:content];
    /*    NSLog(@"PostJson:%@", str); */
    
    NSLog(@"***twk****str = %@",str);
    NSLog(@"before$$****5");
    NSData *bodyData = [[self encryptString:str] dataUsingEncoding:NSUTF8StringEncoding];

    /*
     *    [request setValue:@"AppleWebKit/533.18.1 (KHTML, like Gecko) Version/5.0.2 Safari/533.18.5" forHTTPHeaderField:@"User-Agent"];
     * /////////////////////////
     */

    /* 设置Content-Length 目前不需要了. */
    if (bodyData && [bodyData length]) {
        /*        [request setValue:[NSString stringWithFormat:@"%zd", [bodyData length]] forHTTPHeaderField:@"Content-Length"]; */
        [request setHTTPBody:bodyData];
    }

    /* /////////////////////////////////////////////////////////////////////////////// */

    /* 发送同步请求, data就是返回的数据 */
    NSURLResponse *response = nil;

    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:error];

    leaveNetworkActivityIndicatorState();

    if (*error) {
        if ([*error code] == -1001) {
            *error = [NSError errorWithDomain:[NSString stringWithFormat:@"连接服务器超时,请稍候再试."] code:-1001 userInfo:nil];
        }

        /*同步请求出错,直接返回空 */
        return nil;
    }

    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

    /* 判断服务器是否返回404 */
    if ((([httpResponse statusCode] / 100) != 2)) {
        NSLog(@"SGHttpRequest sync connection didReceiveResponse:%zd andUrl:%@", [httpResponse statusCode], url);
        return nil;
    }

    if ((data == nil) || ([data length] == 0)) {
        *error = [NSError errorWithDomain:[NSString stringWithFormat:@"连接服务器出错,请稍候再试."] code:0 userInfo:nil];
        NSLog(@"data length is 0, or send request failed:url is:%@", url);
        return nil;
    }

    return data;
#endif /* if UseNewNetwork */
}

/* 异步http请求 */
- (void)addRequestWithEncrypt   :(NSString *)url andMethod:(NSString *)method andContent:(NSMutableDictionary *)content andTimeout:(int)seconds
        delegate                :(id)_delegate successAction:(SEL)successAction failureAction:(SEL)failureAction
        userInfo                :(NSDictionary *)userInfo isSaveCacheWithName:(NSString *)cacheName
{
    //    LogWhoCallMe();

    /*    NSLog(@"url:%@", url); */

    if (([Reachability reachabilityForInternetConnection] == nil) || ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == 0)) {
        if (_delegate && [_delegate respondsToSelector:failureAction]) {
            [_delegate performSelector:failureAction withObject:[NSError errorWithDomain:[NSString stringWithFormat:@"无网络连接,请检查网络"] code:0 userInfo:nil] withObject:userInfo];
        }

        return;
    }

#if UseNewNetwork
        {
            NSMutableDictionary *headers = [NSMutableDictionary dictionary];
            //            NewMutableDictionary();
            headers[@"ios"] = @"ios";
            headers[@"Content-type"] = @"application/octet-stream";
            
            NSString *keyString = [SGJSONUtils ObjectToJsonString:getRequestHeader()];
            //            [SGJSONUtils ObjectToJsonString:getRequestHeader()];
            //            [getRequestHeader() toJsonString];
            NSLog(@"before$$****6");
            headers[@"headKey"] = [self encryptString:keyString];
            
            NSData *pd = [[self encryptString:[SGJSONUtils ObjectToJsonString:content]] dataUsingEncoding:NSUTF8StringEncoding];
            
            NSLog(@"******%@",content);
            NSLog(@"======%@",[SGJSONUtils ObjectToJsonString:content]);
            NSLog(@"======%@",[self encryptString:[SGJSONUtils ObjectToJsonString:content]]);
            NSLog(@"======%@",pd);
            
            [APIServer postBinaryWithURL:url headers:headers data:pd successBlock:^(NSData *respone, NSError *error) {
                if (_delegate) {
                    [_delegate performSelector:successAction withObject:respone withObject:userInfo];
                }

//                BreakPointHere;
            } faildBlock:^(NSData *respone, NSError *error) {
                if (_delegate) {
                    [_delegate performSelector:failureAction withObject:error withObject:userInfo];
                }

//                BreakPointHere;
            }];

            return;
        }
#else

    enterNetworkActivityIndicatorState();

    /* /////////////////////////////////////////////////////////////////////////////// */
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:seconds];

    /* 设置请求方式 */
    [request setHTTPMethod:method];
    /* 添加用户会话id */

    NSMutableDictionary *headerFields = [self getRequestHeaderWithEncrypt];

    NSString *headJSONString = [SGJSONUtils ObjectToJsonString:headerFields];
    /*    NSLog(@"headJSON:%@", headJSONString); */

    if (headJSONString.length && headJSONString) {
        NSLog(@"before$$****7");
        [request setValue:[self encryptString:headJSONString] forHTTPHeaderField:@"headKey"];
        [request setValue:@"ios" forHTTPHeaderField:@"ios"];
    }

    [request setValue:@"" forHTTPHeaderField:@"Content-type"];

    /************************** 加密内容／发送文件流 *************************************************/
    NSString *str = [SGJSONUtils ObjectToJsonString:content];
    /*    NSLog(@"PostJason:%@", str); */
    
    NSLog(@"***twk****str = %@",str);
    
    NSData *bodyData = [[self encryptString:str] dataUsingEncoding:NSUTF8StringEncoding];

    /* 设置Content-Length */
    if (bodyData && [bodyData length]) {
        /*        [request setValue:[NSString stringWithFormat:@"%zd", [content length]] forHTTPHeaderField:@"Content-Length"]; */
        [request setHTTPBody:bodyData];
    }

    /* /////////////////////////////////////////////////////////////////////////////// */
    NSURLConnection *con = [[[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO] autorelease];
    [con scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];

    if (con == nil) {
        NSLog(@"NSURLConnection init error");
        return;
    }

    RequestInfo *reqInfo = [[RequestInfo alloc] init];

    if (_delegate) {
        reqInfo.target = _delegate;
        reqInfo.failureAction = failureAction;
        reqInfo.successAction = successAction;
    }

    reqInfo.userInfo = userInfo;
    reqInfo.serverIsError = NO;
    reqInfo.cacheName = cacheName;
    [requests setObject:reqInfo forKey:[NSValue valueWithNonretainedObject:con]];
    [reqInfo release];

    if (activeRequestsCount < concurrentRequestsLimit) {
        [self startRequest:con];
    } else {
        [self queueRequest:con];
    }
#endif /* if UseNewNetwork */
}

- (void)cancelRequest:(NSURLConnection *)con
{
    LogFunctionName();

    RequestInfo *request = [requests objectForKey:[NSValue valueWithNonretainedObject:con]];

    if (request == nil) {
        return;
    }

    if (request.active) {
        [self stopRequest:con];
    } else {
        [queue removeObject:con];
    }

    [requests removeObjectForKey:[NSValue valueWithNonretainedObject:con]];
}

- (void)cancelAllRequests
{
    LogFunctionName();

    for (NSValue *value in requests) {
        RequestInfo *request = [requests objectForKey:value];

        if (request.active) {
            NSURLConnection *con = nil;
            [value getValue:&con];

            if (con) {
                [self stopRequest:con];
            }
        }
    }

    [requests removeAllObjects];
    [queue removeAllObjects];
}

#pragma mark - BLOCK 异步请求
#define SuccessBlock    @"SuccessBlock"
#define FailedBlock     @"FailedBlock"
- (void)asyncPostRequestWithEncrypt:(NSString *)url content:(NSMutableDictionary *)content successBlock:(void (^)(NSData *))successBlock failedBlock:(void (^)(NSError *))failedBlock
{
    LogFunctionName();

    @try
    {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        
        NSLog(@"盈麒SDK Debug：\n%@\n%@",url,dict);
        
        if (successBlock) {
            [dict setObject:[successBlock copy] forKey:SuccessBlock];
        }
        
        if (failedBlock) {
            [dict setObject:[failedBlock copy] forKey:FailedBlock];
        }
        
        [self addRequestWithEncrypt:url andMethod:HttpPost andContent:content andTimeout:20 delegate:self successAction:@selector(blockSuccessAciton:userInfo:) failureAction:@selector(blockFailuserAction:userInfo:) userInfo:dict isSaveCacheWithName:nil];
    }
    
    @catch(NSException *exception) {}
    @finally {}
}

- (void)blockSuccessAciton:(NSData *)data userInfo:(NSDictionary *)userInfo
{
    LogFunctionName();

    void (^successedBlock)(NSData *) = userInfo[SuccessBlock];

    if (successedBlock) {
        successedBlock(data);
    }
}

- (void)blockFailuserAction:(NSError *)error userInfo:(NSDictionary *)userInfo
{
    LogFunctionName();

    void (^failBlock)(NSError *) = userInfo[FailedBlock];

    if (failBlock) {
        failBlock(error);
    }
}

#pragma mark -
#pragma mark get SGHttpRequest header

/**
 *	@brief	设置请求头部信息
 */
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

- (NSString *)encryptString:(NSString *)str
{
    
    Byte    iv[9] = {1, 2, 3, 4, 5, 6, 7, 8};
    size_t  numBytesEncrypted;
    NSData  *contantData = [str dataUsingEncoding:NSUTF8StringEncoding];
    Byte    *plaintext = (Byte *)[contantData bytes];
    Byte    *buffer[1024 * 32];
    
    memset(buffer, 0, sizeof(buffer));
    char key[] = "hqi/FjjcBxA=";
    CCCrypt(kCCEncrypt,
            kCCAlgorithmDES,
            kCCOptionPKCS7Padding,
            key,
            kCCKeySizeDES,
            iv,
            plaintext,
            contantData.length,
            &buffer,
            1024 * 32,
            &numBytesEncrypted);
    //    DebugLog(@"%zi", numBytesEncrypted);
    return [GTMBase64 stringByEncodingBytes:&buffer length:numBytesEncrypted];
}

@end
