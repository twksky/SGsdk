//
//  APIServer.h
//  SuanGuo
//
//  Created by lianlian on 8/1/16.
//  Copyright © 2016 lianai. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "sma11case.h"

typedef void    (^APIResponeBlock)(id respone, NSError *error);
typedef void    (^APIDictionaryResponeBlock)(NSData *respone, NSError *error);

NSMutableDictionary *getRequestHeader();

NSUInteger updateNetworkActivityIndicatorState();

void enterNetworkActivityIndicatorState();

void leaveNetworkActivityIndicatorState();

void syncBlockWithMain(dispatch_block_t block);


@interface APIServer : NSObject
// 此接口仅用于兼容旧接口
+ (NSURLSessionDataTask *)postBinaryWithURL:(NSString *)url headers:(NSDictionary *)headers data:(NSData *)data successBlock:(APIDictionaryResponeBlock)block1 faildBlock:(APIDictionaryResponeBlock)block2;

// =============================== 使用下面的新接口进行网络请求 ===============================

// 同步请求接口, 建议使用异步
// data 参数为nil时表示GET请求, 否则为POST请求, headers为加密后的请求头(该接口不会进行加密,如果实在不会用, 可以用旧的, 会自动跳转到这里)
+ (NSData *)postBinarySyncEx:(NSString *)url headers:(NSDictionary *)headers data:(NSData *)data successBlock:(APIResponeBlock)block1 faildBlock:(APIResponeBlock)block2;

// 异步请求接口
// 注意: Block运行在异步线程中，若需要更新界面，需要返回主线程
// data 参数为nil时表示GET请求, 否则为POST请求, headers为加密后的请求头(该接口不会进行加密,如果实在不会用, 可以用旧的, 会自动跳转到这里)
+ (NSURLSessionDataTask *)postBinaryEx:(NSString *)url headers:(NSDictionary *)headers data:(NSData *)data successBlock:(APIResponeBlock)block1 faildBlock:(APIResponeBlock)block2;
@end

