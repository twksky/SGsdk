//
//  GameSDK.h
//  SGsdk
//
//  Created by twksky on 2017/3/23.
//  Copyright © 2017年 twksky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GameSDK : NSObject

/**
 获取微信支付订单接口

 @param bundleName  安卓为游戏包名，ios为bound_id
 @param userId      游戏用户id
 @param gameBillId  游戏内部订单号
 @param gameCode    游戏代码，目前6(请写死传入6)
 @param amt         交易金额
 @param succusBlock 支付h5地址
 @param faildBlock  失败内容显示
 */
+(void)gameSDK_WXPayWithBundleName:(NSString *)bundleName withUserId:(NSString *)userId withGameBillId:(NSString *)gameBillId withGameCode:(NSInteger)gameCode withAmt:(NSInteger)amt withSuccusBlock:(void(^)(NSString *url,NSString *prepayId))succusBlock withFaildBlock:(void(^)(NSString *errorMsg))faildBlock;

/**
 获取支付宝支付订单接口
 
 @param bundleName  安卓为游戏包名，ios为bound_id
 @param userId      游戏用户id
 @param gameBillId  游戏内部订单号
 @param gameCode    游戏代码，目前6(请写死传入6)
 @param amt         交易金额
 @param succusBlock 支付h5地址
 @param faildBlock  失败内容显示
 */
+(void)gameSDK_AliPayWithBundleName:(NSString *)bundleName withUserId:(NSString *)userId withGameBillId:(NSString *)gameBillId withGameCode:(NSInteger)gameCode withAmt:(NSInteger)amt withSuccusBlock:(void(^)(NSString *url))succusBlock withFaildBlock:(void(^)(NSString *errorMsg))faildBlock;

@end
