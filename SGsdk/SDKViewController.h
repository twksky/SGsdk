//
//  ViewController.h
//  GameSDKTest
//
//  Created by twksky on 2017/7/20.
//  Copyright © 2017年 twksky. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol YingQiLoginDelegate <NSObject>

@required
/**
 登录成功

 @param successDic  登录成功服务器返回的对象
 */
-(void)YingQiLogin_Successed:(NSDictionary *)successDic;

@optional
/**
 登录失败
 
 @param failDic  登录失败服务器返回的对象（可以不用实现）
 */
-(void)YingQiLogin_Failed:(NSDictionary *)failDic;

@end

@interface SDKViewController : UIViewController

@property (nonatomic, weak) id<YingQiLoginDelegate> delegate;

/**
 *  显示在自定义视图中
 *  @param vc <#vc description#>
 */
- (void)showInCustomVC:(UIViewController *)vc;



@end
