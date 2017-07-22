//

#import <UIKit/UIKit.h>
//#import "NSString+Code.h"
#import "NSData+Code.h"
#import "Reachability.h"
//#import "Category.h"

#define HttpPost            @ "POST"
// #define HttpGet             @ "GET"

#define HttpCacheFilePath   [NSString stringWithFormat: @ "%@/webDataCache/", [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]]

@interface SGHttpRequest : NSObject {
    int activeRequestsCount;
    int concurrentRequestsLimit;
    // NSValue * with NSURLConnection * -> AsyncNetRequest *
    NSMutableDictionary *requests;
    NSMutableArray      *queue; // NSURLConnection *
    NSMutableArray      *requestArrs;
}

@property (nonatomic, assign) int               concurrentRequestsLimit;
@property (nonatomic, strong) NSMutableArray    *requestArrs;

+ (SGHttpRequest *)instance;

- (id)init;
- (void)startRequest:(NSURLConnection *)con;
- (void)stopRequest:(NSURLConnection *)con;
- (void)queueRequest:(NSURLConnection *)con;
- (NSURLConnection *)dequeueRequest;
- (void)connectionEnded;

#pragma mark Public
- (void)clearRequestDelegate:(id)_delegate;
//- (NSData *)getHttpCacheData:(NSString *)cacheName;
- (NSData *)sendRequestSyncWithEncrypt:(NSString *)url andMethod:(NSString *)method andContent:(NSMutableDictionary *)content andTimeout:(int)seconds andError:(NSError **)error;

- (void)addRequestWithEncrypt   :(NSString *)url andMethod:(NSString *)method andContent:(NSMutableDictionary *)content andTimeout:(int)seconds
        delegate                :(id)_delegate successAction:(SEL)successAction failureAction:(SEL)failureAction
        userInfo                :(NSDictionary *)userInfo isSaveCacheWithName:(NSString *)cacheName;

/**
 *  block的网络请求
 *
 */
- (void)asyncPostRequestWithEncrypt:(NSString *)url content:(NSMutableDictionary *)content successBlock:(void (^)(NSData *data)) successBlock failedBlock:(void (^)(NSError *error))failedBlock;

- (void)cancelRequest:(NSURLConnection *)con;
- (void)cancelAllRequests;
@end
