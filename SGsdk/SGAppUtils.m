//
//  SGAppUtils.m
//  XieHou
//
//  Created by LianAiMini on 14-5-20.
//  Copyright (c) 2014年 Yung. All rights reserved.
//

#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

#import "SGAppUtils.h"
#import "sys/utsname.h"
#import <AdSupport/ASIdentifierManager.h>
#import <AudioToolbox/AudioSession.h>

// 存储UUID到KeyChain
#import <Security/Security.h>

#import "AFNetworking.h"

@interface SGAppUtils ()

@end

@implementation SGAppUtils

#pragma mark - 获取软件版本
+ (NSInteger)appVersion
{
    NSString *appVersion = [self appVersionString];

    appVersion = [appVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
    return appVersion.integerValue;
}

+ (NSString *)appVersionString
{
    NSString *appVersionString = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];

    return appVersionString;
}

#pragma mark -  获取当前网络状态
+ (NSInteger)networkStatus
{
    AFNetworkReachabilityManager *mgr = [AFNetworkReachabilityManager sharedManager];

    NSInteger   networStatus = 0;
    NSInteger   AFNnetWorkStatus = 0;

    AFNnetWorkStatus = mgr.networkReachabilityStatus;

    if ((AFNnetWorkStatus == -1) || (AFNnetWorkStatus == 0)) {
        networStatus = 0;   // 未知网络
    } else if (AFNnetWorkStatus == 1) {
        networStatus = 5;   // 数据网络
    } else {
        networStatus = 1;   // WiFi
    }

    return networStatus;
}

+ (BOOL)checkTextIsBlank:(NSString *)string
{
    string = [string stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];

    if ([string isEqualToString:@""]) {
        return YES;
    } else {
        return NO;
    }
}


#pragma mark - 设备信息
+ (NSString *)getUUIDString
{
    CFUUIDRef   uuidRef = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef strRef = CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
    NSString    *uuidString = [(__bridge NSString *)strRef stringByReplacingOccurrencesOfString:@"-" withString:@""];

    CFRelease(strRef);
    CFRelease(uuidRef);
    return uuidString;
}

+ (NSString *)getIDFAOrMac
{
    NSString *uuid = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];

    if (!uuid.length) {
//        [self saveUUIDToKeyChain];
//        uuid = [self readUUIDFromKeyChain];
    }

    return uuid;
}

+ (NSString *)deviceString
{
    struct utsname systemInfo;

    uname(&systemInfo);
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];

    if ([platform isEqualToString:@"iPhone1,1"]) {
        return @"iPhone 2G";
    }

    if ([platform isEqualToString:@"iPhone1,2"]) {
        return @"iPhone 3G";
    }

    if ([platform isEqualToString:@"iPhone2,1"]) {
        return @"iPhone 3GS";
    }

    if ([platform isEqualToString:@"iPhone3,1"]) {
        return @"iPhone 4";
    }

    if ([platform isEqualToString:@"iPhone3,2"]) {
        return @"iPhone 4";
    }

    if ([platform isEqualToString:@"iPhone3,3"]) {
        return @"iPhone 4 (CDMA)";
    }

    if ([platform isEqualToString:@"iPhone4,1"]) {
        return @"iPhone 4S";
    }

    if ([platform isEqualToString:@"iPhone5,1"]) {
        return @"iPhone 5";
    }

    if ([platform isEqualToString:@"iPhone5,2"]) {
        return @"iPhone 5 (GSM+CDMA)";
    }

    if ([platform isEqualToString:@"iPhone5,1"]) {
        return @"iPhone 5 (A1428)";
    }

    if ([platform isEqualToString:@"iPhone5,2"]) {
        return @"iPhone 5 (A1429/A1442)";
    }

    if ([platform isEqualToString:@"iPhone5,3"]) {
        return @"iPhone 5c (A1456/A1532)";
    }

    if ([platform isEqualToString:@"iPhone5,4"]) {
        return @"iPhone 5c (A1507/A1516/A1526/A1529)";
    }

    if ([platform isEqualToString:@"iPhone6,1"]) {
        return @"iPhone 5s (A1453/A1533)";
    }

    if ([platform isEqualToString:@"iPhone6,2"]) {
        return @"iPhone 5s (A1457/A1518/A1528/A1530)";
    }

    if ([platform isEqualToString:@"iPhone7,1"]) {
        return @"iPhone 6 Plus (A1522/A1524)";
    }

    if ([platform isEqualToString:@"iPhone7,2"]) {
        return @"iPhone 6 (A1549/A1586)";
    }

    if ([platform isEqualToString:@"iPod1,1"]) {
        return @"iPod Touch (1 Gen)";
    }

    if ([platform isEqualToString:@"iPod2,1"]) {
        return @"iPod Touch (2 Gen)";
    }

    if ([platform isEqualToString:@"iPod3,1"]) {
        return @"iPod Touch (3 Gen)";
    }

    if ([platform isEqualToString:@"iPod4,1"]) {
        return @"iPod Touch (4 Gen)";
    }

    if ([platform isEqualToString:@"iPod5,1"]) {
        return @"iPod Touch (5 Gen)";
    }

    if ([platform isEqualToString:@"iPad1,1"]) {
        return @"iPad";
    }

    if ([platform isEqualToString:@"iPad1,2"]) {
        return @"iPad 3G";
    }

    if ([platform isEqualToString:@"iPad2,1"]) {
        return @"iPad 2 (WiFi)";
    }

    if ([platform isEqualToString:@"iPad2,2"]) {
        return @"iPad 2";
    }

    if ([platform isEqualToString:@"iPad2,3"]) {
        return @"iPad 2 (CDMA)";
    }

    if ([platform isEqualToString:@"iPad2,4"]) {
        return @"iPad 2";
    }

    if ([platform isEqualToString:@"iPad3,1"]) {
        return @"iPad 3 (WiFi)";
    }

    if ([platform isEqualToString:@"iPad3,2"]) {
        return @"iPad 3 (GSM+CDMA)";
    }

    if ([platform isEqualToString:@"iPad3,3"]) {
        return @"iPad 3";
    }

    if ([platform isEqualToString:@"iPad3,4"]) {
        return @"iPad 4 (WiFi)";
    }

    if ([platform isEqualToString:@"iPad3,5"]) {
        return @"iPad 4";
    }

    if ([platform isEqualToString:@"iPad3,6"]) {
        return @"iPad 4 (GSM+CDMA)";
    }

    if ([platform isEqualToString:@"iPad2,5"]) {
        return @"iPad Mini (WiFi)";
    }

    if ([platform isEqualToString:@"iPad2,6"]) {
        return @"iPad Mini";
    }

    if ([platform isEqualToString:@"iPad2,7"]) {
        return @"iPad Mini (GSM+CDMA)";
    }

    if ([platform isEqualToString:@"i386"]) {
        return @"Simulator";
    }

    if ([platform isEqualToString:@"x86_64"]) {
        return @"Simulator";
    }

    return platform;
}

static const char *jailbreak_apps[] =
{
    "/Applications/Cydia.app",
    "/Applications/blackra1n.app",
    "/Applications/blacksn0w.app",
    "/Applications/greenpois0n.app",
    "/Applications/limera1n.app",
    "/Applications/redsn0w.app",
    NULL,
};

+ (BOOL)isJailBrokeDevice
{
    for (int i = 0; jailbreak_apps[i] != NULL; ++i) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithUTF8String:jailbreak_apps[i]]]) {
            return YES;
        }
    }

    return NO;
}

+ (id)JsonDataToObject:(NSData *)jsonData
{
    if ((jsonData == nil) || ([jsonData length] == 0)) {
        
        return nil;
    }
    
    NSError *error = nil;
    id      jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
    
    if ((jsonObject != nil) && (error == nil)) {
        return jsonObject;
    } else {
        NSLog(@"解析不了啊:%@ \n error Str %@", error, [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
        return nil;
    }

}


+ (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

// 只压缩尺寸,不压缩质量,需要再压质量的,自己调UIImageJPEGRepresentation(squareImage, 0.6);方法压缩
+ (UIImage *)imageCompressSize:(UIImage *)image
{
    // 压缩大图
    CGFloat imageWidth = 320 * 2;
    CGSize  bigNewSize;
    
    bigNewSize = CGSizeMake(imageWidth, imageWidth * image.size.height / image.size.width);
    
    UIGraphicsBeginImageContext(bigNewSize);
    [image drawInRect:CGRectMake(0, 0, bigNewSize.width, bigNewSize.height + 1)];
    UIImage *bigNewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return bigNewImage;
}

+ (UIImage *)scale:(UIImage *)image toSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

@end
