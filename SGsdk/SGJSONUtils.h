//
//  SGJSONUtils.h
//  SuanGuo
//
//  Created by lianai on 16/3/1.
//  Copyright © 2016年 lianai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SGJSONUtils : NSObject

//+ (void)printJsonData:(NSData *)jsonData;

+ (NSString *)JsonDataToNSString:(NSData *)jsonData;

+ (id)JsonStringToObject:(NSString *)jsonString;

+ (id)JsonDataToObject:(NSData *)jsonData;

+ (NSData *)ObjectToJsonData:(id)_object;

+ (NSString *)ObjectToJsonString:(id)_object;

@end
