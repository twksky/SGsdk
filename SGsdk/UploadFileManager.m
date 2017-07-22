//#import "xSysHeaders.h"
//#import "UrlContant.h"
//#import "sma11case.h"
//#import "AppMacro.h"
#import "UploadFileManager.h"
//#import "QiNiuTokenModel.h"
//#import "YDBManager.h"
//#import "LianAiJSON.h"
//#import "HttpRequest.h"
//#import "LoginInfoModel.h"
//#import "SCHook.h" // 必须最后导入!!!
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//SC-Disabled:#import "sma11case.h"
#import "SGHTTPManager.h"
#import "QiNiuTokenModel.h"
#import "QNUploadManager.h"
#import "QNUploadOption.h"
#import "SGAppUtils.h"
#import "SGsdk.h"
//
//  UploadFileManager.m
//  LianAi
//
//  Created by calvin on 14-8-5.
//  Copyright (c) 2014年 Yung. All rights reserved.
//

extern NSString* KHostName;

#pragma mark - 七牛上传
#define RequestContantCmdStype_QiniuGetToken      [NSString stringWithFormat:@"%@getQiniuToken.do",KHostName]
#import "UploadFileManager.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@interface UploadFileManager()


@end

@implementation UploadFileManager

- (void)uploadErrorAlert:(NSString *)alertMsg
{
    NSString *msg = @"提交失败,请稍后再重新提交";

    if (alertMsg) {
        msg = alertMsg;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
        message             :msg
        delegate            :self
        cancelButtonTitle   :nil
        otherButtonTitles   :@"确定", nil];
        [alert show];
    });
}

- (void)UploadGameToken:(NSString *)gameToken andUid:(NSString *)uid andFilePath:(NSString *)filePath progress:(void (^)(float))progressBlock completion:(void (^)(NSDictionary *ret))completionBlock failed:(void (^)(NSError *))failedBlock
{

    self.progressBlock = progressBlock;
    self.completionBlock = completionBlock;
    self.failedBlock = failedBlock;
    NSString *code = [[NSUserDefaults standardUserDefaults] objectForKey:@"gameCode"];
    if (!code) {
        code = @"2";
    }
    
    NSMutableDictionary *jsonDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    gameToken,@"gameToken",
                                    uid, @"uid",
                                    code, @"gameCode",
                                    @(1),@"type",
                                    nil];
    
    [[SGHTTPManager sharedManager] sg_AsyncPostRequestWithEncrypt:RequestContantCmdStype_QiniuGetToken content:jsonDic successBlock:^(NSData *data) {
        NSDictionary *root = [SGAppUtils JsonDataToObject:data];
//        NSDictionary *root = responseObject;
        BOOL state = [[root objectForKey:@"state"] boolValue];
        if (state) {
            NSLog(@"我要准备上传图片到七牛啦啦啦啦啦啦%@",root);
            //上传图片到七牛
            QiNiuTokenModel *qiNiuTokenM = [[QiNiuTokenModel alloc] initWithDictionary:root error:nil];
            
            NSMutableDictionary *qiNiuDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             uid, @"x:uid",
                                             gameToken, @"x:loginKey",
                                             qiNiuTokenM.fileName, @"x:fileName",
                                             [NSString stringWithFormat:@"%d", 1], @"x:type",
                                             qiNiuTokenM.uptoken, @"x:token", nil];
            
            QNUploadManager *upManager = [[QNUploadManager alloc] init];
            
            NSString *key = [NSString stringWithFormat:@"%@%@", qiNiuTokenM.key, qiNiuTokenM.fileName];
            
            QNUploadOption *opt = [[QNUploadOption alloc] initWithMime:nil progressHandler:^(NSString *key, float percent) {
                if (self.progressBlock) {
                    self.progressBlock(percent);
                }
            } params:qiNiuDic checkCrc:YES cancellationSignal:nil];
            
            NSError *error = nil;
            
            [upManager putFile:filePath
                      key     :key
                      token   :qiNiuTokenM.uptoken
                      complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                          BOOL state = [[resp objectForKey:@"state"] boolValue];
                          
                          if (state) {
                              if (self.completionBlock) {
                                  self.completionBlock(resp);
                                  self.completionBlock = nil;
                                  self.failedBlock = nil;
                                  self.progressBlock = nil;
                              }
                          } else {
                              if (self.failedBlock) {
                                  self.failedBlock(error);
                                  self.completionBlock = nil;
                                  self.failedBlock = nil;
                                  self.progressBlock = nil;
                              }
                              
                              NSString *msg = [resp objectForKey:@"msg"];
                              [self uploadErrorAlert:msg];
                          }
                      } option:opt];
            
        }else{
            [self uploadErrorAlert:[root objectForKey:@"msg"]];
        }
        
    } failedBlock:^(NSError *error) {
        [self uploadErrorAlert:nil];
    }];
    
//    [[SGHTTPManager sharedManager] sg_AsyncPostRequestWithEncrypt:RequestContantCmdStype_QiniuGetToken parameters:jsonDic success:^(NSURLSessionDataTask *task, id responseObject) {
//        
//        
//    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//        [self uploadErrorAlert:nil];
//    }];
}

//- (void)UploadGameToken:(NSString *)gameToken andUid:(NSString *)uid FilePath:(NSString *)filePath andUserInfo:(NSDictionary *)infoDic progress:(void (^)(float)) progressBlock completion:(void (^)(NSDictionary *ret)) completionBlock failed:(void (^)(NSError *))failedBlock
//{
//
//    self.progressBlock = progressBlock;
//    self.completionBlock = completionBlock;
//    self.failedBlock = failedBlock;
//
//    dispatch_queue_t queue = dispatch_queue_create(DISPATCH_QUEUE_PRIORITY_DEFAULT, NULL);
//
//    dispatch_async(queue, ^{
//        LoginInfoModel *loginInfoM = [LoginInfoModel shareInstance];
//
//        NSMutableDictionary *jsonDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//        loginInfoM.userId, Request_Uid,
//        [NSNumber numberWithInt:type], Request_Type, nil];
//
//        NSString *requestUrl = nil;
//
//        if ((type == UploadImage_Type_MsgVoice) || (type == UploadImage_Type_MsgPhoto) || (type == UploadImage_Type_Broadcast)) {
//            requestUrl = RequestContantCmdStype_QiniuMsgServerGetToken;
//        } else {
//            requestUrl = RequestContantCmdStype_QiniuGetToken;
//        }
//
//        NSError *error = nil;
//
//        NSData *responeData = [[HttpRequest instance] sendRequestSyncWithEncrypt:requestUrl andMethod:HttpPost andContent:jsonDic andTimeout:20 andError:&error];
//
//        if (error) {
//            [self uploadErrorAlert:nil];
//        } else {
//            NSDictionary *root = [LianAiJSON JsonDataToObject:responeData];
//            BOOL state = [[root objectForKey:Request_State] boolValue];
//
//            if (state) {
//                //上传图片到七牛
//                QiNiuTokenModel *qiNiuTokenM = [[QiNiuTokenModel alloc] initWithDictionary:root error:nil];
//
//                NSMutableDictionary *qiNiuDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                loginInfoM.userId, @"x:uid",
//                loginInfoM.loginKey, @"x:loginKey",
//                qiNiuTokenM.fileName, @"x:fileName",
//                [NSString stringWithFormat:@"%d", type], @"x:type",
//                qiNiuTokenM.uptoken, @"x:token", nil];
//
//                if ((type == UploadImage_Type_MsgVoice) || (type == UploadImage_Type_MsgPhoto)) {
//                    [qiNiuDic setObject:[infoDic objectForKey:SocketMsgModel_msgMobileId] forKey:@"x:mid"];
//                    [qiNiuDic setObject:[infoDic objectForKey:SocketMsgModel_msgTo] forKey:@"x:toUid"];
//
//                    if (type == UploadImage_Type_MsgVoice) {
//                        [qiNiuDic setObject:[NSString stringWithFormat:@"%@", [infoDic objectForKey:SocketMsgModel_msgVoiceTime]] forKey:@"x:second"];
//                    }
//                }
//
//                // 4.9.2新增聊天室语音时间长度
//                if (type == UploadImage_Type_ChatRoomVoice) {
//                    [qiNiuDic setObject:[NSString stringWithFormat:@"%zd", [[[[infoDic objectForKey:@"msgBody"] componentsSeparatedByString:@"@#"] lastObject] integerValue]] forKey:@"x:second"];
//                }
//
//                // 4.9.5新增群聊语音时间长度
//                if (type == UploadImage_Type_GroupChatVoice) {
//                    [qiNiuDic setObject:[NSString stringWithFormat:@"%zd", [[infoDic objectForKey:@"chatroomId"] integerValue]] forKey:@"x:groupId"];
//                    [qiNiuDic setObject:[NSString stringWithFormat:@"%zd", [[[[infoDic objectForKey:@"msgBody"] componentsSeparatedByString:@"@#"] lastObject] integerValue]] forKey:@"x:second"];
//                }
//
//                // 4.9.5新增群聊图片与群主图片上传
//                if ((type == UploadImage_Type_GroupChatImage) || (type == UploadImage_Type_GroupHostImage)) {
//                    [qiNiuDic setObject:[NSString stringWithFormat:@"%zd", [[infoDic objectForKey:@"chatroomId"] integerValue]] forKey:@"x:groupId"];
//                }
//
//                if (type == UploadImage_Type_IntroduceVoice) {
//                    [qiNiuDic setObject:[NSString stringWithFormat:@"%@", [infoDic objectForKey:@"duration"]] forKey:@"x:second"];
//                }
//
//                QNUploadOption *opt = [[QNUploadOption alloc] initWithMime:nil progressHandler:^(NSString *key, float percent) {
//                    if (self.progressBlock) {
//                        self.progressBlock(percent);
//                    }
//                } params:qiNiuDic checkCrc:YES cancellationSignal:nil];
//
//                QNUploadManager *upManager = [[[QNUploadManager alloc] init]  nothing];
//
//                NSString *key = [NSString stringWithFormat:@"%@%@", qiNiuTokenM.key, qiNiuTokenM.fileName];
//
//                [upManager putFile:filePath
//                key     :key
//                token   :qiNiuTokenM.uptoken
//                complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
//                    BOOL state = [[resp objectForKey:Request_State] boolValue];
//
//                    if (state) {
//                        if (self.completionBlock) {
//                            self.completionBlock(resp);
//                            self.completionBlock = nil;
//                            self.failedBlock = nil;
//                            self.progressBlock = nil;
//                        }
//                    } else {
//                        if (self.failedBlock) {
//                            self.failedBlock(error);
//                            self.completionBlock = nil;
//                            self.failedBlock = nil;
//                            self.progressBlock = nil;
//                        }
//
//                        NSString *msg = [resp objectForKey:Request_Msg];
//                        [self uploadErrorAlert:msg];
//                    }
//                } option:opt];
//                
//                
//            } else {
//                // 出错信息
//                NSString *msg = [root objectForKey:Request_Msg];
//                [self uploadErrorAlert:msg];
//            }
//        }
//    });
//    //dispatch_release(queue);
//}

#pragma mark - QiniuUploadDelegate
// Upload progress
- (void)uploadProgressUpdated:(NSString *)theFilePath percent:(float)percent
{

    NSLog(@"七牛回调：进度Progress Updated: %@ - %f",theFilePath, percent);

    if (self.progressBlock) {
        self.progressBlock(percent);
    }
}

// Upload completed successfully
- (void)uploadSucceeded:(NSString *)theFilePath ret:(NSDictionary *)ret
{

    NSLog(@"七牛回调：成功Upload Succeeded: %@ - Ret: %@", theFilePath, ret);
    BOOL state = [[ret objectForKey:@"state"] boolValue];

    if (state) {
        if (self.completionBlock) {
            self.completionBlock(ret);
            self.completionBlock = nil;
            self.failedBlock = nil;
            self.progressBlock = nil;
        }
    } else {
        NSString *msg = [ret objectForKey:@"msg"];
        [self uploadErrorAlert:msg];
    }
}

// Upload failed
- (void)uploadFailed:(NSString *)theFilePath error:(NSError *)error
{
    NSLog(@"七牛回调：失败Upload Failed: %@ - Reason: %@", theFilePath, error);
    
    if (self.failedBlock) {
        self.failedBlock(error);
        self.completionBlock = nil;
        self.failedBlock = nil;
        self.progressBlock = nil;
    }
}



#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"请求服务器出错");
    if (self.failedBlock) {
        NSError *error = [NSError errorWithDomain:[NSString stringWithFormat:@"请求服务器出错, url=%@", RequestContantCmdStype_QiniuGetToken] code:0 userInfo:nil];
        self.failedBlock(error);
        self.failedBlock = nil;
    }
}

@end

#pragma clang diagnostic pop
