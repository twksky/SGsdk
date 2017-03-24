//
//  SGAppUtils.h
//  XieHou
//
//  Created by LianAiMini on 14-5-20.
//  Copyright (c) 2014年 Yung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class  ShareContent;
@class  SGMessage;
@interface SGAppUtils : NSObject

#pragma mark - 获取软件版本
+ (NSInteger)appVersion;
+ (NSString *)appVersionString;

#pragma mark - 获取网络状态
+ (NSInteger)networkStatus;

#pragma mark - 设备信息

/**
 *  获取设备描述
 *
 *  @return  设备描述
 */
+ (NSString *)deviceString;

/**
 *  获取一个UUID
 *
 *  @return UUIDString
 */
+ (NSString *)getUUIDString;

/**
 *  获取mac地址
 *
 *  @return mac Address
 */
//+ (NSString *)getMacAddress;

/**
 *  获取设备唯一标识
 *
 *  @return  设备唯一标识
 */
+ (NSString *)getIDFAOrMac;

/**
 *  判断是否越狱
 *
 *  @return BOOL
 */
+ (BOOL)isJailBrokeDevice;

+ (id)JsonDataToObject:(NSData *)jsonData;

/**
 *  缩放图片到指定大小
 *
 *  @return UIIMAGE
 */
+ (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size;

+ (UIImage *)imageCompressSize:(UIImage *)image;

+ (UIImage *)scale:(UIImage *)image toSize:(CGSize)size;


@end
