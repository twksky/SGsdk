//
//  UploadFileManager.h
//  LianAi
//
//  Created by calvin on 14-8-5.
//  Copyright (c) 2014年 Yung. All rights reserved.
//

//SC-Disabled:#import <Foundation/Foundation.h>
//SC-Disabled:#import "QiniuSDK.h"
//SC-Disabled:#import "../Utils/HttpRequest.h"
//SC-Disabled:#import <MobileCoreServices/MobileCoreServices.h>

#import <Foundation/Foundation.h>

typedef void    (^UploadFileCompletionBlock)(NSDictionary *);
typedef void    (^UploadFileFailedBlock)(NSError *);
typedef void    (^UploadFileProgressBlock)(float);

@interface UploadFileManager : NSObject

@property (copy) UploadFileCompletionBlock  completionBlock;
@property (copy) UploadFileFailedBlock      failedBlock;
@property (copy) UploadFileProgressBlock    progressBlock;

- (void)UploadGameToken:(NSString *)gameToken andUid:(NSString *)uid andFilePath:(NSString *)filePath progress:(void (^)(float)) progressBlock completion:(void (^)(NSDictionary *ret)) completionBlock failed:(void (^)(NSError *))failedBlock;

@end
