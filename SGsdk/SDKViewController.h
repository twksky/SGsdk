//
//  ViewController.h
//  GameSDKTest
//
//  Created by twksky on 2017/7/20.
//  Copyright © 2017年 twksky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LMJDropdownMenu.h"
#import "CustomTF.h"
#import "CustomTF_2.h"

@protocol YingQiLoginDelegate <NSObject>

@required
/**
 登录成功象

 @param successDic  登录成功服务器返回的对象
 */
-(void)YingQiLogin_Successed:(NSDictionary *)successDic;

@optional
/**
 登录成功
 
 @param failDic  登录失败服务器返回的对象（可以不用实现）
 */
-(void)YingQiLogin_Failed:(NSDictionary *)failDic;

@end

@interface SDKViewController : UIViewController<LMJDropdownMenuDelegate>

@property (nonatomic, weak) id<YingQiLoginDelegate> delegate;

/**
 *  显示在自定义视图中
 *  @param vc <#vc description#>
 */
- (void)showInCustomVC:(UIViewController *)vc;







@property (weak, nonatomic) IBOutlet UIView *YingQiBaseView;

@property (nonatomic, strong) UIView *YingQiView1;

@property (nonatomic, strong) UIView *YingQiView2;

@property (nonatomic, strong) UIView *YingQiView3;

@property (nonatomic, strong) UIView *YingQiView4;

@property (nonatomic, strong) UIView *YingQiView5;

@property (nonatomic, strong) UIView *YingQiView6;

@property (nonatomic, strong) UIView *YingQiView7;

@property (nonatomic, strong) UIView *YingQiView8;

@property (nonatomic, strong) UIView *YingQiView9;

@property (nonatomic, strong) UIView *YingQiView10;

@property (nonatomic, strong) UIView *YingQiView11;

@property (nonatomic, strong) UIView *YingQiView12;

@property (strong, nonatomic) IBOutlet CustomTF *tf_3_1;

@property (strong, nonatomic) IBOutlet CustomTF_2 *tf_4_1;

@property (strong, nonatomic) IBOutlet CustomTF *tf_4_2;

@property (strong, nonatomic) IBOutlet CustomTF *tf_5_1;

@property (strong, nonatomic) IBOutlet CustomTF *tf_5_2;

@property (strong, nonatomic) IBOutlet CustomTF *tf_6_1;

@property (strong, nonatomic) IBOutlet CustomTF *tf_6_2;

@property (strong, nonatomic) IBOutlet CustomTF *tf_7_1;

@property (strong, nonatomic) IBOutlet CustomTF_2 *tf_8_1;

@property (strong, nonatomic) IBOutlet CustomTF_2 *tf_8_2;


@property (strong, nonatomic) IBOutlet CustomTF *tf_10_1;

@property (strong, nonatomic) IBOutlet CustomTF_2 *tf_12_1;


@property (strong, nonatomic) IBOutlet UILabel *gameAccountLabel;

@property (strong, nonatomic) IBOutlet UILabel *gamePassword;


@property (strong, nonatomic) IBOutlet UIButton *smsBtn;
@property (strong, nonatomic) IBOutlet UIButton *smsBtn_8;


/**
 *  下拉数组
 */
@property (nonatomic, strong) NSArray *downDropArr;

/**
 *  全局唯一成功回调数据
 */
@property (nonatomic, strong) NSDictionary *successDict;

// 倒计时
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger timeCount;

@property (nonatomic, strong) NSTimer *timer2;
@property (nonatomic, assign) NSInteger timeCount2;

@end
