//
//  SGShareManager.h
//  XieHou
//
//  Created by Zhang YaoYuan on 25/7/13.
//  Copyright (c) 2013 Yung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXApi.h"

typedef enum {
    shareWeChat_Tag = 0,
    shareFirendGroup_Tag,
    shareSinaWeiBo_Tag,
    shareQQFriend_Tag,
    shareQQZone_Tag
} shareTag;

@protocol ShareManagerDelegate;

#define kAppShareInContactByPersonalWeb(type, str) [NSString stringWithFormat: @ "http://www.xiehou360.com/call.do?cmd=share.getUserInfo&type=%@&uid=%@", type, str]

@interface SGShareManager : NSObject {}

//@property (nonatomic, retain) TencentOAuth *tencentHandle;
// @property (nonatomic, retain) SinaWeibo *sinaHandle;
//@property (nonatomic, strong) WBAuthorizeResponse       *sinaResp;
//@property (nonatomic, assign) BOOL                      isSinaLogin;
@property (nonatomic, weak) id <ShareManagerDelegate>   delegate;
@property (nonatomic, strong) NSString                  *shareTitle;
//@property (nonatomic, assign) BOOL                      isQQZone;// 主要是区分qq和qq空间
//@property (nonatomic, strong) NSString                  *shareQQLinkUrl;
//@property (nonatomic, strong) ShareContent              *currentShareContent;

+ (instancetype)defaultCloudManger;               // 单例

//// QQ
//- (BOOL)isTencentLogin;
//- (void)tencentLogin;
//- (void)tencentShareText:(NSString *)textStr ForTitle:(NSString *)titleStr webImageUrl:(NSString *)imgUrlStr ForLinkUrl:(NSString *)linkStr;
//- (void)tencentShareText:(NSString *)textStr webImageUrl:(NSString *)imgUrlStr;
//- (void)tencentShareText:(NSString *)textStr webImageUrl:(NSString *)imgUrlStr webUrlStr:(NSString *)webUrlStr;
//- (void)tencentShareText:(NSString *)textStr webImageUrl:(NSString *)imgUrlStr linkUrl:(NSString *)linkUrl;
//
//- (void)tencentShareTitle:(NSString *)title shareText:(NSString *)textStr webImageUrl:(NSString *)imgUrlStr linkUrl:(NSString *)linkUrl;
//
//- (void)tencentAddCareAbout:(NSString *)tencentName;
//- (void)readCurrentUidTencentInfo;

//// xinlan
//- (BOOL)isXinLanLogin;
//- (void)xinLanLogin;
//- (void)sinaShareText:(NSString *)textStr imageName:(NSString *)imageName linkUrlStr:(NSString *)url linkTitle:(NSString *)title linkDescription:(NSString *)description;
//- (void)xinLanAddCareAbout:(NSString *)xinLanId;
//- (void)xinLanLogOut;
//- (void)readCurrentXinLanInfo;

#pragma mark - 直播前微信分享
@property(nonatomic, assign, readonly, getter = isAuthorizeValid) BOOL authorizeValid;
- (void)requestShareAuthorize:(void (^)(BOOL succeed))authorize;
//- (void)shareOther:(SGLiveRoomModel *)liveRoomModel type:(ShareType)type;
//- (void)shareSinaWeiboOnly:(BOOL)only liveRoomModel:(SGLiveRoomModel *)liveRoomModel;

- (void)weiXinShareToGroupText:(NSString *)textStr WebImgUrl:(NSString *)imgUrlStr ForLinkStr:(NSString *)linkStr title:(NSString *)title picislocal:(BOOL)islocal onlyPic:(BOOL)isOnlyPic;
- (void)weiXinShareToPeopleText:(NSString *)textStr WebImgUrl:(NSString *)imgUrlStr ForLinkStr:(NSString *)linkStr title:(NSString *)title picislocal:(BOOL)islocal onlyPic:(BOOL)isOnlyPic;

//- (void)weiXinShareToPeopleWithTitle:(NSString *)title text:(NSString *)textStr WebImgUrl:(NSString *)imgUrlStr ForLinkStr:(NSString *)linkStr; // 带title分享到好友

// + (void)shareActionByShareTag:(NSInteger)tag shareTitle:(NSString *)shareText sharedImageUrl:(NSString *)imageUrl urlStr:(NSString *)urlStr;

// + (void)shareActionByShareTag:(NSInteger)tag shareTitle:(NSString *)title shareText:(NSString *)shareText sharedImageUrl:(NSString *)imageUrl urlStr:(NSString *)urlStr;

@end

@protocol ShareManagerDelegate <NSObject>

@optional
- (void)ShareSingleHandleTencentLoginSucceed:(SGShareManager *)shareHandle;
- (void)ShareSingleHandleTencentShowTextSucceed:(SGShareManager *)shareHandle;
- (void)didCancelShareToQQ:(SGShareManager *)shareHandle;   // 取消分享
- (void)FailToAuthorToQQ:(SGShareManager *)shareHandle;     // 取消授权或者登陆失败

- (void)ShareSingleHandleXinLanLoginSuccedd:(SGShareManager *)shareHandle;
- (void)ShareSingleHandleXinLanShowTextSuccedd:(SGShareManager *)shareHandle;
- (void)didCancelShareToSina:(SGShareManager *)shareHandle;

- (void)ShareSingleHandleWeiXinShowTextSuccedd:(SGShareManager *)shareHandle;
- (void)ShareSingleHandleWeiXinShowTextFail:(SGShareManager *)shareHandle;

// 微信授权获取个人资料成功 先走登陆流程
- (void)weiXinAuthSuccessWithDic:(NSDictionary *)dic;

@end
