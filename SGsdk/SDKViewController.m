//
//  ViewController.m
//  GameSDKTest
//
//  Created by twksky on 2017/7/20.
//  Copyright © 2017年 twksky. All rights reserved.
//

#import "SDKViewController.h"
#import "YingQiSDK.h"

#import "LMJDropdownMenu.h"
#import "CustomTF.h"
#import "CustomTF_2.h"
#import "SDKYingQiView1.h"
#import "SDKYingQiView2.h"
#import "SDKYingQiView3.h"
#import "SDKYingQiView4.h"
#import "SDKYingQiView5.h"
#import "SDKYingQiView6.h"
#import "SDKYingQiView7.h"
#import "SDKYingQiView8.h"
#import "SDKYingQiView9.h"
#import "SDKYingQiView10.h"
#import "SDKYingQiView11.h"
#import "SDKYingQiView12.h"



#define Weakself __weak typeof(self) weakself = self;

@interface SDKViewController ()<LMJDropdownMenuDelegate>

@property (weak, nonatomic) IBOutlet UIView *YingQiBaseView;

@property (nonatomic, strong) SDKYingQiView1 *YingQiView1;

@property (nonatomic, strong) SDKYingQiView2 *YingQiView2;

@property (nonatomic, strong) SDKYingQiView3 *YingQiView3;

@property (nonatomic, strong) SDKYingQiView4 *YingQiView4;

@property (nonatomic, strong) SDKYingQiView5 *YingQiView5;

@property (nonatomic, strong) SDKYingQiView6 *YingQiView6;

@property (nonatomic, strong) SDKYingQiView7 *YingQiView7;

@property (nonatomic, strong) SDKYingQiView8 *YingQiView8;

@property (nonatomic, strong) SDKYingQiView9 *YingQiView9;

@property (nonatomic, strong) SDKYingQiView10 *YingQiView10;

@property (nonatomic, strong) SDKYingQiView11 *YingQiView11;

@property (nonatomic, strong) SDKYingQiView12 *YingQiView12;

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

@implementation SDKViewController

#pragma mark  ================== lazy load ==================

- (NSDictionary *)successDict {
	if (_successDict == nil) {
        _successDict = [[NSDictionary alloc] init];
	}
	return _successDict;
}

- (NSArray *)downDropArr {
    
    if (_downDropArr == nil) {
        _downDropArr = [[NSArray alloc] init];
        _downDropArr = @[@"选项一",@"选项二",@"选项三",@"选项四"];
        
        // 本地化储存取值 todo
        
    }
    return _downDropArr;
}

#pragma mark  ================== life cycle ==================

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self onePic];//第一个图的UI
//    [self twoPic];//第二个图的UI
    

// 添加11视图
    self.YingQiView11 = [[SDKYingQiView11 alloc] init];
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
    
    [self.timer invalidate];
    [self.timer2 invalidate];
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}

#pragma mark 第一个图的UI
-(void)onePic{
    
    [self.YingQiBaseView addSubview:self.YingQiView1];
}

/**
 *  添加下拉菜单
 */
- (void)addDropMenu {
    
    LMJDropdownMenu * dropdownMenu = [[LMJDropdownMenu alloc] init];
    [dropdownMenu setFrame:CGRectMake(360, 33, 30, 30)];
    
    [dropdownMenu setMenuTitles:self.downDropArr rowHeight:30];
    dropdownMenu.delegate = self;
    [self.YingQiView6 addSubview:dropdownMenu];
}

#pragma mark 第一个图的Action
/**
 游客模式登录
 */
- (void)youkeLogin:(id)sender {
    
    Weakself
    
    [YingQiSDK YingQiSDKRequst_tempWithsB:^(NSDictionary *dic) {
        NSLog(@"%@",dic);

        
        weakself.successDict = dic;
        
        weakself.YingQiView11.uidLabel.text = [NSString stringWithFormat:@"游戏账号: %zd",[dic[@"data"][@"tempUser"][@"uid"] integerValue]];
        weakself.YingQiView11.pswLabel.text = [NSString stringWithFormat:@"游戏密码: %zd",[dic[@"data"][@"tempUser"][@"pwd"] integerValue]];
        
        weakself.YingQiView2.hidden = NO;
        weakself.YingQiView1.hidden = YES;
        
    } fB:^(NSDictionary *dic) {
        [self failedLogined:dic];
    }];
    
}
/**
 手机注册
 */
- (void)phoneRegister:(id)sender {
    
    self.YingQiView3.hidden = NO;
    self.YingQiView1.hidden = YES;
    self.YingQiView3.tag = 1;
}
/**
 账号登陆
 */
- (void)accountLogin:(id)sender {
    
    self.YingQiView6.hidden = NO;
    self.YingQiView1.hidden = YES;
}


#pragma mark  ================== lazy load ==================
#pragma mark 视图懒加载
-(UIView *)YingQiView1{
    if (!_YingQiView1) {
        
        _YingQiView1 = [[SDKYingQiView1 alloc] init];
        
        [_YingQiView1.youkeBtn addTarget:self action:@selector(youkeLogin:) forControlEvents:UIControlEventTouchUpInside];
        [_YingQiView1.phoneBtn addTarget:self action:@selector(phoneRegister:) forControlEvents:UIControlEventTouchUpInside];
        [_YingQiView1.accountBtn addTarget:self action:@selector(accountLogin:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _YingQiView1;
}

- (UIView *)YingQiView2 {
    if (_YingQiView2 == nil) {
        
        _YingQiView2 = [[SDKYingQiView2 alloc] init];
        
        [_YingQiView2.backBtn addTarget:self action:@selector(backBtnClick_2:) forControlEvents:UIControlEventTouchUpInside];
        [_YingQiView2.continueGameModeBtn addTarget:self action:@selector(continueGameMode:) forControlEvents:UIControlEventTouchUpInside];
        [_YingQiView2.bindPhoneBtn addTarget:self action:@selector(bindingPhone:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.YingQiBaseView addSubview:_YingQiView2];
    }
    return _YingQiView2;
}
- (UIView *)YingQiView3 {
    if (_YingQiView3 == nil) {
        
        _YingQiView3 = [[SDKYingQiView3 alloc] init];
        
        [_YingQiView3.verifyBtn addTarget:self action:@selector(verifyBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_YingQiView3.registerBtn addTarget:self action:@selector(accountRegister:) forControlEvents:UIControlEventTouchUpInside];
        [_YingQiView3.backBtn addTarget:self action:@selector(backBtnClick_3:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.YingQiBaseView addSubview:_YingQiView3];
    }
    return _YingQiView3;
}
- (UIView *)YingQiView4 {
    if (_YingQiView4 == nil) {
        
        _YingQiView4 = [[SDKYingQiView4 alloc] init];
        
        [_YingQiView4.registerBtn addTarget:self action:@selector(registerBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_YingQiView4.sendSMSBtn addTarget:self action:@selector(sendSMSCode:) forControlEvents:UIControlEventTouchUpInside];
        [_YingQiView4.backBtn addTarget:self action:@selector(backBtnClick_4:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.YingQiBaseView addSubview:_YingQiView4];
    }
    return _YingQiView4;
}
- (UIView *)YingQiView5 {
    if (_YingQiView5 == nil) {
        
        _YingQiView5 = [[SDKYingQiView5 alloc] init];
        
        [_YingQiView5.registerBtn addTarget:self action:@selector(registerBtnClick_5:) forControlEvents:UIControlEventTouchUpInside];
        [_YingQiView5.backBtn addTarget:self action:@selector(backBtnClick_5:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.YingQiBaseView addSubview:_YingQiView5];
    }
    return _YingQiView5;
}
- (UIView *)YingQiView6 {
    if (_YingQiView6 == nil) {
        
        _YingQiView6 = [[SDKYingQiView6 alloc] init];
        
        [_YingQiView6.loginBtn addTarget:self action:@selector(loginBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_YingQiView6.findbackPswBtn addTarget:self action:@selector(getbackPassWordBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_YingQiView6.fastRegisterBtn addTarget:self action:@selector(fastRegisterBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_YingQiView6.backBtn addTarget:self action:@selector(backBtnClick_6:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.YingQiBaseView addSubview:_YingQiView6];
        
//        [self addDropMenu];
    }
    return _YingQiView6;
}
- (UIView *)YingQiView7 {
    if (_YingQiView7 == nil) {
        
        _YingQiView7 = [[SDKYingQiView7 alloc] init];
        
        [_YingQiView7.confirmBtn addTarget:self action:@selector(confirmBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_YingQiView7.otherwayBtn addTarget:self action:@selector(otherWayBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_YingQiView7.backBtn addTarget:self action:@selector(backBtnClick_7:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.YingQiBaseView addSubview:_YingQiView7];
    }
    return _YingQiView7;
}

- (UIView *)YingQiView8 {
	if (_YingQiView8 == nil) {

        _YingQiView8 = [[SDKYingQiView8 alloc] init];
        [_YingQiView8.backBtn addTarget:self action:@selector(backBtnClick_8:) forControlEvents:UIControlEventTouchUpInside];
        [_YingQiView8.confirmBtn addTarget:self action:@selector(confirmBtnClick_8:) forControlEvents:UIControlEventTouchUpInside];
        [_YingQiView8.sendSMSBtn addTarget:self action:@selector(sendSMSCode_8:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.YingQiBaseView addSubview:_YingQiView8];
	}
	return _YingQiView8;
}
- (UIView *)YingQiView9 {
	if (_YingQiView9 == nil) {
        
        _YingQiView9 = [[SDKYingQiView9 alloc] init];
        [_YingQiView9.backBtn addTarget:self action:@selector(backBtnClick_9:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.YingQiBaseView addSubview:_YingQiView9];
	}
	return _YingQiView9;
}

- (UIView *)YingQiView10 {
    
    if (_YingQiView10 == nil) {
        
        _YingQiView10 = [[SDKYingQiView10 alloc] init];
        
        [_YingQiView10.verifyBtn addTarget:self action:@selector(clickVerifyBtn_10:) forControlEvents:UIControlEventTouchUpInside];
        [_YingQiView10.backBtn addTarget:self action:@selector(backBtnClick_10:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.YingQiBaseView addSubview:_YingQiView10];
    }
    return _YingQiView10;
}

- (UIView *)YingQiView12 {
    
    if (_YingQiView12 == nil) {
        
        _YingQiView12 = [[SDKYingQiView12 alloc] init];
        [_YingQiView12.confirmBtn addTarget:self action:@selector(clickConfirmBtn_12:) forControlEvents:UIControlEventTouchUpInside];
        [_YingQiView10.backBtn addTarget:self action:@selector(clickBackBtn_12:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.YingQiBaseView addSubview:_YingQiView12];
    }
    return _YingQiView12;
}


#pragma mark  ================== action ==================

#pragma mark  ================== 2 ==================
/**
 *  继续游戏模式
 *  @param sender <#sender description#>
 */
- (void)continueGameMode:(id)sender {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"帐号保存" message:@"为了防止帐号丢失,您的帐号信息将会以图片的形式保存到相册中" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"不保存" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        return;
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    
        [self saveImage];
        self.YingQiBaseView.hidden = YES;
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];

    
    [self successfullyLogined:self.successDict];
}

- (void)saveImage {
    
    // 保存图片
    UIGraphicsBeginImageContextWithOptions(self.YingQiView11.bounds.size, YES, [UIScreen mainScreen].scale);
    [self.YingQiView11.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
}

/**
 *  绑定手机
 *  @param sender <#sender description#>
 */
- (void)bindingPhone:(id)sender {
    
    self.YingQiView2.hidden = YES;
    self.YingQiView10.hidden = NO;
//    self.YingQiView3.tag = 2;
}

/**
 *  返回按钮
 *  @param sender <#sender description#>
 */
- (void)backBtnClick_2:(id)sender {
    
    self.YingQiView2.hidden = YES;
    self.YingQiView1.hidden = NO;
}

#pragma mark  ================== 3 ==================
/**
 *  验证
 *  @param sender <#sender description#>
 */
- (void)verifyBtnClick:(id)sender {
    
    if (!self.YingQiView3.tf_1.text.length) {
        return;
    }
    
    [YingQiSDK YingQiSDKRequst_checkPhoneRegWithNumber:self.YingQiView3.tf_1.text withCheckCode:0 sB:^(NSDictionary *dic) {
       
        self.YingQiView3.hidden = YES;
        self.YingQiView4.hidden = NO;
        
    } fB:^(NSDictionary *dic) {
        
    }];
}

/**
 *  注册帐号
 *  @param sender <#sender description#>
 */
- (void)accountRegister:(id)sender {
    
    self.YingQiView3.hidden = YES;
    self.YingQiView5.hidden = NO;
}

- (void)backBtnClick_3:(id)sender {
    
    if (self.YingQiView3.tag == 1) {
        
        self.YingQiView3.hidden = YES;
        self.YingQiView1.hidden = NO;
    } else if (self.YingQiView3.tag == 2) {
        
        self.YingQiView3.hidden = YES;
        self.YingQiView1.hidden = NO;
    } else if (self.YingQiView3.tag == 6) {
        
        self.YingQiView3.hidden = YES;
        self.YingQiView6.hidden = NO;
    }
}


#pragma mark  ================== 4 ==================
/**
 *  注册
 *  @param sender <#sender description#>
 */
- (void)registerBtnClick:(id)sender {
    
    if (self.YingQiView4.tf_1.text.length && self.YingQiView4.tf_2.text.length) {
        
        [YingQiSDK YingQiSDKRequst_registerWithNumber:self.YingQiView3.tf_1.text withCheckCode:[self.YingQiView4.tf_1.text integerValue] withPwd:self.YingQiView4.tf_2.text sB:^(NSDictionary *dic) {
            
            self.YingQiBaseView.hidden = YES;
            
            [self successfullyLogined:dic];
            
        } fB:^(NSDictionary *dic) {
            
        }];
    }
}

/**
 *  发送验证码
 *  @param sender <#sender description#>
 */
- (void)sendSMSCode:(id)sender {
    
    self.YingQiView4.sendSMSBtn.enabled = NO;
    
    [YingQiSDK YingQiSDKRequst_sendCheckCodeWithNumber:self.YingQiView3.tf_1.text sB:^(NSDictionary *dic) {
        
        self.timeCount = 60;
        // 创建
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(changeTimeTitle)
                                                    userInfo:nil
                                                     repeats:YES];
        
    } fB:^(NSDictionary *dic) {
        
        self.YingQiView4.sendSMSBtn.enabled = YES;
        
    }];
}

/**
 *  倒计时验证码
 */
- (void)changeTimeTitle {
    
    // 倒计时结束
    if (self.timeCount <= 0) {
        
        self.YingQiView4.sendSMSBtn.enabled = YES;
        [self.YingQiView4.sendSMSBtn setTitle:@"发送验证码" forState:UIControlStateNormal];
        return;
    }
    
    // 正在倒计时
    
    [self.YingQiView4.sendSMSBtn setTitle:[NSString stringWithFormat:@"%zds",self.timeCount] forState:UIControlStateNormal];
    self.timeCount--;
}

- (void)changeTimeTitle2 {
    
    // 倒计时结束
    if (self.timeCount2 <= 0) {
        
        self.YingQiView8.sendSMSBtn.enabled = YES;
        [self.YingQiView8.sendSMSBtn setTitle:@"发送验证码" forState:UIControlStateNormal];
        return;
    }
    
    // 正在倒计时
    
    [self.YingQiView8.sendSMSBtn setTitle:[NSString stringWithFormat:@"%zds",self.timeCount2] forState:UIControlStateNormal];
    self.timeCount2--;
}




- (void)backBtnClick_4:(id)sender {
    
    self.YingQiView4.hidden = YES;
    self.YingQiView3.hidden = NO;
}


#pragma mark  ================== 5 ==================
- (void)registerBtnClick_5:(id)sender {
    
    if (self.YingQiView5.tf_1.text.length && self.YingQiView5.tf_2.text.length) {
        
        [YingQiSDK YingQiSDKRequst_registerAccountWithName:self.YingQiView5.tf_1.text withPwd:self.YingQiView5.tf_2.text sB:^(NSDictionary *dic) {
            
            self.YingQiBaseView.hidden = YES;
            
            [self successfullyLogined:dic];
        } fB:^(NSDictionary *dic) {
            
        }];
    }
}

- (void)backBtnClick_5:(id)sender {
    
    self.YingQiView5.hidden = YES;
    self.YingQiView3.hidden = NO;
}


#pragma mark  ================== 6 ==================
/**
 *  登录
 *  @param sender <#sender description#>
 */
- (void)loginBtnClick:(id)sender {
    
    if (self.YingQiView6.tf_1.text.length && self.YingQiView6.tf_2.text.length) {
        
        [YingQiSDK YingQiSDKRequst_loginWithNumberStr:self.YingQiView6.tf_1.text withPwd:self.YingQiView6.tf_2.text withLoginKey:nil sB:^(NSDictionary *dic) {
            
            self.YingQiBaseView.hidden = YES;
        } fB:^(NSDictionary *dic) {
            
        }];
    }
}

/**
 *  找回密码
 *  @param sender <#sender description#>
 */
- (void)getbackPassWordBtnClick:(id)sender {
    
    self.YingQiView6.hidden = YES;
    self.YingQiView7.hidden = NO;
}

/**
 *  快速注册
 *  @param sender <#sender description#>
 */
- (void)fastRegisterBtnClick:(id)sender {
    
    self.YingQiView6.hidden = YES;
    self.YingQiView3.hidden = NO;
    self.YingQiView3.tag = 6;
}


- (void)backBtnClick_6:(id)sender {
    
    self.YingQiView6.hidden = YES;
    self.YingQiView1.hidden = NO;
}


#pragma mark  ================== 7 ==================
/**
 *  确定
 *  @param sender <#sender description#>
 */
- (void)confirmBtnClick:(id)sender {
    
    if (self.YingQiView7.tf_1.text.length) {
        
        self.YingQiView7.hidden = YES;
        self.YingQiView8.hidden = NO;
    }
}

/**
 *  其他方式
 *  @param sender <#sender description#>
 */
- (void)otherWayBtnClick:(id)sender {
    
    self.YingQiView7.hidden = YES;
    self.YingQiView9.hidden = NO;
}

- (void)backBtnClick_7:(id)sender {
    
    self.YingQiView7.hidden = YES;
    self.YingQiView6.hidden = NO;
}

#pragma mark  ================== 8 ==================

/**
 *  返回
 *  @param sender <#sender description#>
 */
- (void)backBtnClick_8:(id)sender {
    
    self.YingQiView8.hidden = YES;
    self.YingQiView7.hidden = NO;
}

/**
 *  确定
 *  @param sender <#sender description#>
 */
- (void)confirmBtnClick_8:(id)sender {
    
    [YingQiSDK YingQiSDKRequst_passwordWithNumber:self.YingQiView7.tf_1.text withCheckCode:[self.YingQiView8.tf_1.text integerValue] withPwd:self.YingQiView8.tf_2.text sB:^(NSDictionary *dic) {
        
        self.YingQiBaseView.hidden = YES;
        
        [self successfullyLogined:dic];
        
    } fB:^(NSDictionary *dic) {
        
    }];
}


/**
 *  点击发送验证码
 */
- (void)sendSMSCode_8:(id)sender {
    
    self.YingQiView8.sendSMSBtn.enabled = NO;
    
    [YingQiSDK YingQiSDKRequst_sendCheckCodeWithNumber:self.YingQiView7.tf_1.text sB:^(NSDictionary *dic) {
        
        self.timeCount2 = 60;
        // 创建
        self.timer2 = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(changeTimeTitle2)
                                                    userInfo:nil
                                                     repeats:YES];
        
    } fB:^(NSDictionary *dic) {
        
        self.YingQiView8.sendSMSBtn.enabled = NO;
    }];
}


#pragma mark  ================== 9 ==================

- (void)backBtnClick_9:(id)sender {
    
    self.YingQiView9.hidden = YES;
    self.YingQiView7.hidden = NO;
}

#pragma mark  ================== 10 ==================
/**
 *  点击验证
 *  @param sender <#sender description#>
 */
- (void)clickVerifyBtn_10:(id)sender {
    
    Weakself
    
    if (self.YingQiView10.tf_1.text.length) {
        
        NSInteger uid = [self.successDict[@"data"][@"tempUser"][@"uid"] integerValue];
        
        [YingQiSDK YingQiSDKRequst_checkBindPhoneWithNumber:self.YingQiView10.tf_1.text withUid:uid sB:^(NSDictionary *dic) {
    
            // 发送验证码
            [weakself sendCheckCode:dic andUid:uid];
        } fB:^(NSDictionary *dic) {
            
        }];
    
    }
}

// 发送验证码
- (void)sendCheckCode:(NSDictionary *)dic andUid:(NSInteger)uid{

    if (!dic[@"data"][@"tempUser"]) {
        
        return;
    }
    
    [YingQiSDK YingQiSDKRequst_bindSendCheckcode:dic[@"data"][@"tempUser"] andNumber:self.YingQiView10.tf_1.text uid:uid sB:^(NSDictionary *dic) {
        
        self.YingQiView10.hidden = YES;
        self.YingQiView12.hidden = NO;
    } fB:^(NSDictionary *dic) {
        
    }];
}

- (void)backBtnClick_10:(id)sender {
    
    self.YingQiView10.hidden = YES;
    self.YingQiView2.hidden = NO;
}

#pragma mark  ================== 12 ==================

/**
 *  点击确定
 *  @param sender <#sender description#>
 */
- (void)clickConfirmBtn_12:(id)sender {
    
    if (self.YingQiView12.tf_1.text.length) {
        
        NSInteger uid = [self.successDict[@"data"][@"tempUser"][@"uid"] integerValue];
        
        [YingQiSDK YingQiSDKRequst_BindPhoneWithNumber:self.YingQiView10.tf_1.text withCheckCode:[self.YingQiView12.tf_1.text integerValue] withTempUser:self.successDict[@"data"] andUid:uid sB:^(NSDictionary *dic) {
            
            [self successfullyLogined:dic];
            
            self.YingQiBaseView.hidden = YES;
        } fB:^(NSDictionary *dic) {
            
        }];
    }
}


- (void)clickBackBtn_12:(id)sender {
    
    self.YingQiView12.hidden = YES;
    self.YingQiView10.hidden = NO;
}

#pragma mark  ================== show in customView ==================
- (void)showInCustomVC:(UIViewController *)vc {
    
    [vc addChildViewController:self];
    self.view.frame = [UIScreen mainScreen].bounds;
    [vc.view addSubview:self.view];
}


#pragma mark  ================== delegate ==================

- (void)dropdownMenu:(LMJDropdownMenu *)menu selectedCellNumber:(NSInteger)number {
    
    self.YingQiView6.tf_1.text = self.downDropArr[number];
}

#pragma mark  ================== 最终登录成功的方法 ==================
- (void)successfullyLogined:(NSDictionary *)dic {
    
    
}


#pragma mark  ================== 登录失败的方法 ==================
- (void)failedLogined:(NSDictionary *)dic {
    
    
}

@end
