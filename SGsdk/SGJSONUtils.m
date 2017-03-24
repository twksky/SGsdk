//
//  SGJSONUtils.m
//  SuanGuo
//
//  Created by lianai on 16/3/1.
//  Copyright © 2016年 lianai. All rights reserved.
//

#import "SGJSONUtils.h"

#undef LogFunctionName
#define LogFunctionName()

@implementation SGJSONUtils

//+ (void)printJsonData:(NSData *)jsonData
//{
//    LogFunctionName();
//
//    DebugLog(@"json Str: %@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
//}

/**
 *	@brief	将JsonData 转换为 NSString
 *
 *	@param  jsonData
 *
 *	@return	返回NSString
 */
+ (NSString *)JsonDataToNSString:(NSData *)jsonData
{
    LogFunctionName();

    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    if (jsonString != nil) {
#if !__has_feature(objc_arc)
            return [jsonString autorelease];

#else
            return jsonString;
#endif
    } else {
        return nil;
    }

    return nil;
}

/**
 *	@brief	将jsonString 转换为 Object
 *
 *	@param  jsonString
 *
 *	@return	返回id
 */
+ (id)JsonStringToObject:(NSString *)jsonString
{
    LogFunctionName();

    if (jsonString == nil) {
        return nil;
    }

    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];

    id jsonObject = [SGJSONUtils JsonDataToObject:jsonData];

    if (jsonObject != nil) {
        return jsonObject;
    }

    return nil;
}

/**
 *	@brief	将JsonData 转换为 Object
 *
 *	@param  jsonData
 *
 *	@return	返回id
 */
+ (id)JsonDataToObject:(NSData *)jsonData
{
    LogFunctionName();

//    if (jsonData.length) {
//        return [jsonData toJSONObject];
//    }
//
//#if 0
        if ((jsonData == nil) || ([jsonData length] == 0)) {
//            DebugLog(@"JsonDataToObject error jsonData lenght is 0");
            return nil;
        }

        NSError *error = nil;
        id      jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];

        if ((jsonObject != nil) && (error == nil)) {
            return jsonObject;
        } else {
//            DebugLog(@"NSJSONSerialization error:%@ \n error Str %@", error, [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);

            return nil;
        }
//#endif
//    return nil;
}

+ (NSData *)ObjectToJsonData:(id)_object
{
    LogFunctionName();

    NSError *error = nil;

    if ([NSJSONSerialization isValidJSONObject:_object]) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:_object options:NSJSONWritingPrettyPrinted error:&error];

        if ((jsonData != nil) && (error == nil)) {
            return jsonData;
        } else {
            NSLog(@"json error:%@", error);
        }
    }

    return nil;
}

+ (NSString *)ObjectToJsonString:(id)_object
{
    LogFunctionName();

    NSData      *dataJson = [SGJSONUtils ObjectToJsonData:_object];
    NSString    *jsonStr = [SGJSONUtils JsonDataToNSString:dataJson];

    return jsonStr;
}

@end
