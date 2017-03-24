//
//  SGShareManager.m
//  XieHou
//
//  Created by Zhang YaoYuan on 25/7/13.
//  Copyright (c) 2013 Yung. All rights reserved.
//

#import "SGShareManager.h"
#import "SGAppUtils.h"
//#import "SCHook.h"

#define BUFFER_SIZE                                 1024 * 100

#define ShareSingleHandle_Pre                       @"123"

#define ShareSingleHandle_Tencent_accessToken       [NSString stringWithFormat:@"%@_Tencent_AccessToken", ShareSingleHandle_Pre]
#define ShareSingleHandle_Tencent_expirationDate    [NSString stringWithFormat:@"%@_Tencent_expirationDate", ShareSingleHandle_Pre]
#define ShareSingleHandle_Tencent_localAppId        [NSString stringWithFormat:@"%@_Tencent_localAppId", ShareSingleHandle_Pre]
#define ShareSingleHandle_Tencent_openId            [NSString stringWithFormat:@"%@_Tencent_openId", ShareSingleHandle_Pre]
#define ShareSingleHandle_Tencent_redirectURI       [NSString stringWithFormat:@"%@_Tencent_redirectURI", ShareSingleHandle_Pre]
#define ShareSingleHandle_Tencent_appId             [NSString stringWithFormat:@"%@_Tencent_appId", ShareSingleHandle_Pre]

#define ShareSingleHandle_XinLan_userID             [NSString stringWithFormat:@"%@_XinLan_userID", ShareSingleHandle_Pre]
#define ShareSingleHandle_XinLan_accessToken        [NSString stringWithFormat:@"%@_XinLan_accessToken", ShareSingleHandle_Pre]
#define ShareSingleHandle_XinLan_expirationDate     [NSString stringWithFormat:@"%@_XinLan_expirationDate", ShareSingleHandle_Pre]

@interface SGShareManager ()
- (void)initShareHandle;
@property(nonatomic, copy) void (^authorizeBlock)(BOOL);
@end

static SGShareManager *_defaultHandle = nil;

@implementation SGShareManager

#pragma mark - system
+ (instancetype)defaultCloudManger
{
    if (_defaultHandle == nil) {
        _defaultHandle = [[SGShareManager alloc] init];
        [_defaultHandle initShareHandle];
    }

    return _defaultHandle;
}

- (void)initShareHandle
{

}

- (id)init
{
    self = [super init];

    if (self != nil) {}

    return self;
}

#pragma mark - 朋友圈

- (void)weiXinShareToGroupText:(NSString *)textStr WebImgUrl:(NSString *)imgUrlStr ForLinkStr:(NSString *)linkStr title:(NSString *)title picislocal:(BOOL)islocal onlyPic:(BOOL)isOnlyPic
{
    NSLog(@"朋友圈");
    if (isOnlyPic) {
        //只分享图片
        
        if ((imgUrlStr.length > 0)&&(!islocal)) {
            WXMediaMessage *message = [WXMediaMessage message];
            WXImageObject *imgO = [WXImageObject object];
            NSLog(@"网络图片分享只分享图片URl是:%@",imgUrlStr);
            NSError         *error = nil;
            NSURLRequest    *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:imgUrlStr]];
            NSData          *imgData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
            
            UIImage *jpgImg = [UIImage imageWithData:imgData scale:.5];
            UIImage *scaleImg = [SGAppUtils scale:jpgImg toSize:CGSizeMake(150, 75)];
            imgData = UIImageJPEGRepresentation(scaleImg, 1);
            CGFloat scale = .1;
            NSLog(@"缩略图之前：%zd",imgData.length);
            if (imgData.length > 16 * 1024) {
                jpgImg = [UIImage imageWithData:imgData];
                imgData = UIImageJPEGRepresentation(jpgImg, scale);
                scale *= 0.5;
                NSLog(@"压缩一下");
            }
            [message setThumbData:imgData];//缩略
            
            imgO.imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgUrlStr]];//大图
            
            NSLog(@"缩略图：%zd 大图：%zd",message.thumbData.length,imgO.imageData.length);
            
            message.mediaObject = imgO;
            
            SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
            req.bText = NO;
            req.message = message;
            req.scene = WXSceneTimeline;
            
            [WXApi sendReq:req];
            
            return;
        }
        
        if ((imgUrlStr.length > 0)&&(islocal)) {
            
            WXMediaMessage *message = [WXMediaMessage message];
            WXImageObject *imgO = [WXImageObject object];
            NSLog(@"本地图片分享只分享图片地址是:%@",imgUrlStr);
            //            NSError         *error = nil;
            //        NSURLRequest    *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:imgUrlStr]];
            //        NSData          *imgData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
            
            UIImage *jpgImg = [UIImage imageWithContentsOfFile:imgUrlStr];
            UIImage *scaleImg = [SGAppUtils scale:jpgImg toSize:CGSizeMake(150, 70)];
            NSData *imgData = UIImageJPEGRepresentation(scaleImg, 1);
            CGFloat scale = .1;
            NSLog(@"缩略图之前：%zd",imgData.length);
            if (imgData.length > 16 * 1024) {
                jpgImg = [UIImage imageWithData:imgData];
                imgData = UIImageJPEGRepresentation(jpgImg, scale);
                scale *= 0.5;
                NSLog(@"压缩一下");
            }
            
            [message setThumbData:imgData];//缩略
            
            imgO.imageData = [NSData dataWithContentsOfFile:imgUrlStr];//大图
            
            NSLog(@"缩略图：%zd 大图：%zd",message.thumbData.length,imgO.imageData.length);
            
            message.mediaObject = imgO;
            
            SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
            req.bText = NO;
            req.message = message;
            req.scene = WXSceneTimeline;
            
            [WXApi sendReq:req];
            
            return;
        }
        
    }

    WXMediaMessage *message = [WXMediaMessage message];
    
    NSLog(@"微信好友分享==文案：%@，图片地址：%@，链接地址：%@，标题：%@，是不是本地：%zd",textStr,imgUrlStr,linkStr,title,islocal);

    message.title = title;
    message.description = textStr;
    
    NSLog(@"微信朋友圈分享:%@",imgUrlStr);

    if ((imgUrlStr.length > 0)&&(!islocal)) {
        NSLog(@"网络图片分享，图片的URl是:%@",imgUrlStr);
        NSError         *error = nil;
        NSURLRequest    *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:imgUrlStr]];
        NSData          *imgData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];

        UIImage *jpgImg = [UIImage imageWithData:imgData scale:.5];
        UIImage *scaleImg = [SGAppUtils scale:jpgImg toSize:CGSizeMake(100, 100)];
        imgData = UIImageJPEGRepresentation(scaleImg, 1);
        CGFloat scale = .1;

        if (imgData.length > 16 * 1024) {
            jpgImg = [UIImage imageWithData:imgData];
            imgData = UIImageJPEGRepresentation(jpgImg, scale);
            scale *= 0.5;
        }

        [message setThumbData:imgData];

        if (error) {

        }
    }else if ((imgUrlStr.length >0)&&(islocal)){
        NSLog(@"本地图片分享，图片的地址是:%@",imgUrlStr);
        NSError         *error = nil;
//        NSURLRequest    *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:imgUrlStr]];
//        NSData          *imgData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
        
        UIImage *jpgImg = [UIImage imageWithContentsOfFile:imgUrlStr];
        NSLog(@"jpgImg本地图片:%@",jpgImg);
        UIImage *scaleImg = [SGAppUtils scale:jpgImg toSize:CGSizeMake(100, 100)];
        NSData *imgData = UIImageJPEGRepresentation(scaleImg, 1);
        CGFloat scale = .1;
        if (imgData.length > 16 * 1024) {
            jpgImg = [UIImage imageWithData:imgData];
            imgData = UIImageJPEGRepresentation(jpgImg, scale);
            scale *= 0.5;
        }
        
        [message setThumbData:imgData];
        
        if (error) {
            
        }

    
    }

    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = linkStr;
    message.mediaObject = ext;

    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = WXSceneTimeline;

    [WXApi sendReq:req];
}

#pragma mark - 微信分享

- (void)weiXinShareToPeopleText:(NSString *)textStr WebImgUrl:(NSString *)imgUrlStr ForLinkStr:(NSString *)linkStr title:(NSString *)title picislocal:(BOOL)islocal onlyPic:(BOOL)isOnlyPic
{
    NSLog(@"朋友");
    if (isOnlyPic) {
        //只分享图片
    
        if ((imgUrlStr.length > 0)&&(!islocal)) {
            WXMediaMessage *message = [WXMediaMessage message];
            WXImageObject *imgO = [WXImageObject object];
            NSLog(@"网络图片分享只分享图片URl是:%@",imgUrlStr);
            NSError         *error = nil;
            NSURLRequest    *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:imgUrlStr]];
            NSData          *imgData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
            
            UIImage *jpgImg = [UIImage imageWithData:imgData scale:.5];
            UIImage *scaleImg = [SGAppUtils scale:jpgImg toSize:CGSizeMake(150, 75)];
            imgData = UIImageJPEGRepresentation(scaleImg, 1);
            CGFloat scale = .1;
            NSLog(@"缩略图之前：%zd",imgData.length);
            if (imgData.length > 16 * 1024) {
                jpgImg = [UIImage imageWithData:imgData];
                imgData = UIImageJPEGRepresentation(jpgImg, scale);
                scale *= 0.5;
                NSLog(@"压缩一下");
            }
        
            [message setThumbData:imgData];//缩略
            
            imgO.imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgUrlStr]];//大图
            NSLog(@"缩略图：%zd 大图：%zd",message.thumbData.length,imgO.imageData.length);
            
            SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
            req.bText = NO;
            req.message = message;
            req.scene = WXSceneSession;
            
            [WXApi sendReq:req];
            
            return;
        }
        
        if ((imgUrlStr.length > 0)&&(islocal)) {
            
            WXMediaMessage *message = [WXMediaMessage message];
            WXImageObject *imgO = [WXImageObject object];
            NSLog(@"本地图片分享只分享图片地址是:%@",imgUrlStr);
//            NSError         *error = nil;
            //        NSURLRequest    *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:imgUrlStr]];
            //        NSData          *imgData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
            
            UIImage *jpgImg = [UIImage imageWithContentsOfFile:imgUrlStr];
            UIImage *scaleImg = [SGAppUtils scale:jpgImg toSize:CGSizeMake(150, 75)];
            NSData *imgData = UIImageJPEGRepresentation(scaleImg, 1);
            CGFloat scale = .1;
            
            NSLog(@"缩略图之前：%zd",imgData.length);
            
            if (imgData.length > 16 * 1024) {
                jpgImg = [UIImage imageWithData:imgData];
                imgData = UIImageJPEGRepresentation(jpgImg, scale);
                scale *= 0.5;
                NSLog(@"压缩一下");
            }
            
            [message setThumbData:imgData];//缩略
            
            imgO.imageData = [NSData dataWithContentsOfFile:imgUrlStr];//大图
            
            NSLog(@"缩略图：%zd 大图：%zd",message.thumbData.length,imgO.imageData.length);
            
            message.mediaObject = imgO;
            
            SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
            req.bText = NO;
            req.message = message;
            req.scene = WXSceneSession;
            
            [WXApi sendReq:req];
            
            return;
        }
        
    }
    
    
    WXMediaMessage *message = [WXMediaMessage message];
    
    NSLog(@"微信好友分享==文案：%@，图片地址：%@，链接地址：%@，标题：%@，是不是本地：%zd",textStr,imgUrlStr,linkStr,title,islocal);
    
    message.title = title;
    message.description = textStr;
    
    NSLog(@"微信好友分享:%@",imgUrlStr);
    
    if ((imgUrlStr.length > 0)&&(!islocal)) {
        NSLog(@"网络图片分享，图片的URl是:%@",imgUrlStr);
        NSError         *error = nil;
        NSURLRequest    *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:imgUrlStr]];
        NSData          *imgData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
        
        UIImage *jpgImg = [UIImage imageWithData:imgData scale:.5];
        UIImage *scaleImg = [SGAppUtils scale:jpgImg toSize:CGSizeMake(100, 100)];
        imgData = UIImageJPEGRepresentation(scaleImg, 1);
        CGFloat scale = .1;
        
        if (imgData.length > 16 * 1024) {
            jpgImg = [UIImage imageWithData:imgData];
            imgData = UIImageJPEGRepresentation(jpgImg, scale);
            scale *= 0.5;
        }
        
        [message setThumbData:imgData];
        
        if (error) {
            
        }
    }else if ((imgUrlStr.length >0)&&(islocal)){
        NSLog(@"本地图片分享，图片的地址是:%@",imgUrlStr);
        NSError         *error = nil;
        //        NSURLRequest    *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:imgUrlStr]];
        //        NSData          *imgData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
        
        UIImage *jpgImg = [UIImage imageWithContentsOfFile:imgUrlStr];
        NSLog(@"jpgImg本地图片:%@",jpgImg);
        UIImage *scaleImg = [SGAppUtils scale:jpgImg toSize:CGSizeMake(100, 100)];
        NSData *imgData = UIImageJPEGRepresentation(scaleImg, 1);
        CGFloat scale = .1;
        
        if (imgData.length > 16 * 1024) {
            jpgImg = [UIImage imageWithData:imgData];
            imgData = UIImageJPEGRepresentation(jpgImg, scale);
            scale *= 0.5;
        }
        
        [message setThumbData:imgData];
        
        if (error) {
            
        }
    }
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = linkStr;
    message.mediaObject = ext;
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = WXSceneSession;
    
    [WXApi sendReq:req];
}


@end
