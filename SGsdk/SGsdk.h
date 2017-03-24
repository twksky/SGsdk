//
//  SGsdk.h
//  SGsdk
//
//  Created by twksky on 2016/10/17.
//  Copyright © 2016年 twksky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SGAudioManger.h"
#import "UploadFileManager.h"
#import "Macro.h"

@protocol SGApiDelegate <NSObject>
@optional
/*
 成功的是时候obj是一个字典，类似于下面这个对象
 
 {
 gameToken = 20F531F903153B241E97878D61A40FEB;
 result = ok;
 state = 1;
 uid = 20;
 userInfo =     {
 gender = 2;
 head = "http://lianai-image-head.imlianai.com/weixin/ol6fNwQta8qaRE-GwjjAqkzkXIOg20161024123856500!s148";
 name = "#";
 uid = 20;
 };
 }

*/
-(void)sg_LoginHandle:(id)obj;


/**
 分享完回调

 @param code 0是成功，其他是失败
 */
-(void)sg_shareHandle:(NSString *)code;

@end

@interface SGsdk : NSObject

-(void)sg_show;

+(void)sg_showBuild;

+(void)Channel:(NSString *)channel;

+(void)GameCode:(NSString *)gameCode;


/**
 是否安装微信

 @return 微信已安装返回YES，未安装返回NO。
 */
+(BOOL)isIntallWX;

/*
 Describe : 注册
 */
+ (void)sg_RegisterApp:(NSString *)appKey;

/*
 Describe : 重写handle方法
 */
+ (BOOL)sg_HandleOpenURL:(NSURL *)url delegate:(id<SGApiDelegate>)delegate;

/*
 Describe : 微信登录接口
 scope字段传 : @"snsapi_userinfo";
 */
+ (BOOL)auth:(NSString *)scope withAppID:(NSString *)appID withAppSecret:(NSString *)appSecret;


/**
 帐号过期检验

 @param gameToken   gameToken
 @param succusBlock 成功回调
 @param faildBlock  失败  Domain：请重新登录 code为 1  过期请重新调用auth接口
                          Domain：失败 code为 0  可能网络不好造成的
 */
+ (void)checkAccount:(NSString *)gameToken withSuccusBlock:(void(^)())succusBlock withFaildBlock:(void(^)(NSError *error))faildBlock;


/**
 分享到微信好友

 @param textStr   文字
 @param imgUrlStr 图片头像连接
 @param linkStr   点击连接
 */
+(void)sg_ShareWeiXinShareToPeopleText:(NSString *)textStr WebImgUrl:(NSString *)imgUrlStr ForLinkStr:(NSString *)linkStr title:(NSString *)title picislocal:(BOOL)picislocal onlyPic:(BOOL)isOnlyPic;


/**
  分享到朋友圈

 @param textStr   文字
 @param imgUrlStr 图片头像连接
 @param linkStr   点击连接
 
 */
+(void)sg_ShareWeiXinShareToGroupText:(NSString *)textStr WebImgUrl:(NSString *)imgUrlStr ForLinkStr:(NSString *)linkStr title:(NSString *)title picislocal:(BOOL)picislocal onlyPic:(BOOL)isOnlyPic;


/**
 访客登录接口
 */
+(void)sg_VisitorWithDelegate:(id<SGApiDelegate>)delegate;


/**
 版本审核判断

 @param versionCode   版本号
 @param succusBlock 网络成功
 @param faildBlock  网络失败
 */
+ (void)sg_aduitVersionCheckVersionCode:(NSString *)versionCode withSuccusBlock:(void(^)(BOOL aduitFlag))succusBlock withFaildBlock:(void(^)(NSError *error))faildBlock;

@end
