//
//  GameSDK.m
//  SGsdk
//
//  Created by twksky on 2017/3/23.
//  Copyright © 2017年 twksky. All rights reserved.
//

#import "GameSDK.h"
#import "SGHTTPManager.h"
#import "Macro.h"
#import "SGAppUtils.h"
#import "WXApi.h"

@implementation GameSDK

+(void)gameSDK_WXPayWithBundleName:(NSString *)bundleName withUserId:(NSString *)userId withGameBillId:(NSString *)gameBillId withGameCode:(NSInteger)gameCode withAmt:(NSInteger)amt withSuccusBlock:(void (^)(NSString *,NSString *))succusBlock withFaildBlock:(void (^)(NSString *))faildBlock{
    
    NSMutableDictionary *jsonDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    bundleName, @"bundleName",
                                    userId, @"userId",
                                    gameBillId, @"gameBillId",
                                    @(gameCode), @"gameCode",
                                    @(amt), @"amt",
                                    nil];
    NSLog(@"getZiweiH5Order.do请求的body：%@",jsonDic);

    [[SGHTTPManager sharedManager] sg_AsyncPostRequestWithEncrypt:[NSString stringWithFormat:@"%@getZiweiH5Order.do",KHostName] content:jsonDic successBlock:^(NSData *data) {
        NSDictionary *responseObject = [SGAppUtils JsonDataToObject:data];
        NSLog(@"getZiweiH5Order.do请求回来的数据data：%@***responseObject：%@",data,responseObject);
        if ([responseObject[@"state"] boolValue]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                succusBlock(responseObject[@"url"],responseObject[@"prepayId"]);
            });
        }else{
            faildBlock(responseObject[@"errorMsg"]);
        }
        
    } failedBlock:^(NSError *error) {
        
        faildBlock([NSString stringWithFormat:@"%@",error.domain]);
        
    }];

}

+(void)gameSDK_AliPayWithBundleName:(NSString *)bundleName withUserId:(NSString *)userId withGameBillId:(NSString *)gameBillId withGameCode:(NSInteger)gameCode withAmt:(NSInteger)amt withSuccusBlock:(void (^)(NSString *))succusBlock withFaildBlock:(void (^)(NSString *))faildBlock{
    
    NSMutableDictionary *jsonDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    bundleName, @"bundleName",
                                    userId, @"userId",
                                    gameBillId, @"gameBillId",
                                    @(gameCode), @"gameCode",
                                    @(amt), @"amt",
                                    nil];
    NSLog(@"getZiweiH5Order.do请求的body：%@",jsonDic);
    
    [[SGHTTPManager sharedManager] sg_AsyncPostRequestWithEncrypt:[NSString stringWithFormat:@"%@getAlipayH5Order.do",KHostName] content:jsonDic successBlock:^(NSData *data) {
        NSDictionary *responseObject = [SGAppUtils JsonDataToObject:data];
        NSLog(@"getAlipayH5Order.do请求回来的数据data：%@***responseObject：%@",data,responseObject);
        if ([responseObject[@"state"] boolValue]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                succusBlock(responseObject[@"url"]);
            });
        }else{
            faildBlock(responseObject[@"errorMsg"]);
        }
        
    } failedBlock:^(NSError *error) {
        
        faildBlock([NSString stringWithFormat:@"%@",error.domain]);
        
    }];
    
}


@end
