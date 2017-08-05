//
//  ViewController.m
//  GameSDKTest
//
//  Created by twksky on 2017/7/20.
//  Copyright © 2017年 twksky. All rights reserved.
//

#import "SDKViewController.h"
#import "YingQiSDK.h"


#define Weakself __weak typeof(self) weakself = self;

@interface SDKViewController ()



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
//    NSString *resPath = [[NSBundle mainBundle] pathForResource:@"bundleWithXib" ofType:@"bundle"];
//    
//    NSBundle *bundle = [NSBundle bundleWithPath:resPath];
//    
//    self.YingQiView11 = [[bundle loadNibNamed:@"SDKYingQiView11" owner:nil options:nil] lastObject];
    
//    self.YingQiView11 = [[[NSBundle mainBundle] loadNibNamed:@"SDKYingQiView11" owner:nil options:nil] lastObject];
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
- (IBAction)youkeLogin:(id)sender {
    
    Weakself
    
    [YingQiSDK YingQiSDKRequst_tempWithsB:^(NSDictionary *dic) {
        NSLog(@"%@",dic);
//        if ([self.delegate respondsToSelector:@selector(YingQiLogin_Successed:)]) {
//            [self.delegate YingQiLogin_Successed:dic];
//        }
        weakself.successDict = dic;
        
        weakself.gameAccountLabel.text = [NSString stringWithFormat:@"游戏账号: %zd",[dic[@"data"][@"tempUser"][@"uid"] integerValue]];
        weakself.gamePassword.text = [NSString stringWithFormat:@"游戏密码: %zd",[dic[@"data"][@"tempUser"][@"pwd"] integerValue]];
        
        weakself.YingQiView2.hidden = NO;
        weakself.YingQiView1.hidden = YES;
        
    } fB:^(NSDictionary *dic) {
        [self failedLogined:dic];
    }];
    
}
/**
 手机注册
 */
- (IBAction)phoneRegister:(id)sender {
    
    self.YingQiView3.hidden = NO;
    self.YingQiView1.hidden = YES;
    self.YingQiView3.tag = 1;
}
/**
 账号登陆
 */
- (IBAction)accountLogin:(id)sender {
    
    self.YingQiView6.hidden = NO;
    self.YingQiView1.hidden = YES;
}


#pragma mark  ================== lazy load ==================
#pragma mark 视图懒加载
-(UIView *)YingQiView1{
    if (!_YingQiView1) {
//        _YingQiView1 = [[[NSBundle mainBundle] loadNibNamed:@"SDKYingQiView1" owner:nil options:nil] lastObject];
        
        NSString *resPath = [[NSBundle mainBundle] pathForResource:@"bundleWithXib" ofType:@"bundle"];
        
        NSBundle *bundle = [NSBundle bundleWithPath:resPath];
        
        _YingQiView1 = [[bundle loadNibNamed:@"SDKYingQiView1" owner:nil options:nil] lastObject];
    }
    return _YingQiView1;
}

- (UIView *)YingQiView2 {
    if (_YingQiView2 == nil) {
//        _YingQiView2 = [[[NSBundle mainBundle] loadNibNamed:@"SDKYingQiView2" owner:nil options:nil] lastObject];
        
        NSString *resPath = [[NSBundle mainBundle] pathForResource:@"bundleWithXib" ofType:@"bundle"];
        
        NSBundle *bundle = [NSBundle bundleWithPath:resPath];
        
        _YingQiView2 = [[bundle loadNibNamed:@"SDKYingQiView2" owner:nil options:nil] lastObject];
        
        [self.YingQiBaseView addSubview:_YingQiView2];
    }
    return _YingQiView2;
}
- (UIView *)YingQiView3 {
    if (_YingQiView3 == nil) {
//        _YingQiView3 = [[[NSBundle mainBundle] loadNibNamed:@"YingQiView3" owner:nil options:nil] lastObject];
        
        NSString *resPath = [[NSBundle mainBundle] pathForResource:@"bundleWithXib" ofType:@"bundle"];
        
        NSBundle *bundle = [NSBundle bundleWithPath:resPath];
        
        _YingQiView3 = [[bundle loadNibNamed:@"SDKYingQiView3" owner:nil options:nil] lastObject];
        
        [self.YingQiBaseView addSubview:_YingQiView3];
    }
    return _YingQiView3;
}
- (UIView *)YingQiView4 {
    if (_YingQiView4 == nil) {
//        _YingQiView4 = [[[NSBundle mainBundle] loadNibNamed:@"YingQiView4" owner:nil options:nil] lastObject];
        
        NSString *resPath = [[NSBundle mainBundle] pathForResource:@"bundleWithXib" ofType:@"bundle"];
        
        NSBundle *bundle = [NSBundle bundleWithPath:resPath];
        
        _YingQiView4 = [[bundle loadNibNamed:@"SDKYingQiView4" owner:nil options:nil] lastObject];
        
        [self.YingQiBaseView addSubview:_YingQiView4];
    }
    return _YingQiView4;
}
- (UIView *)YingQiView5 {
    if (_YingQiView5 == nil) {
//        _YingQiView5 = [[[NSBundle mainBundle] loadNibNamed:@"YingQiView5" owner:nil options:nil] lastObject];
        
        NSString *resPath = [[NSBundle mainBundle] pathForResource:@"bundleWithXib" ofType:@"bundle"];
        
        NSBundle *bundle = [NSBundle bundleWithPath:resPath];
        
        _YingQiView5 = [[bundle loadNibNamed:@"SDKYingQiView5" owner:nil options:nil] lastObject];
        
        [self.YingQiBaseView addSubview:_YingQiView5];
    }
    return _YingQiView5;
}
- (UIView *)YingQiView6 {
    if (_YingQiView6 == nil) {
//        _YingQiView6 = [[[NSBundle mainBundle] loadNibNamed:@"YingQiView6" owner:nil options:nil] lastObject];
        
        NSString *resPath = [[NSBundle mainBundle] pathForResource:@"bundleWithXib" ofType:@"bundle"];
        
        NSBundle *bundle = [NSBundle bundleWithPath:resPath];
        
        _YingQiView6 = [[bundle loadNibNamed:@"SDKYingQiView6" owner:nil options:nil] lastObject];
        
        [self.YingQiBaseView addSubview:_YingQiView6];
        
//        [self addDropMenu];
    }
    return _YingQiView6;
}
- (UIView *)YingQiView7 {
    if (_YingQiView7 == nil) {
//        _YingQiView7 = [[[NSBundle mainBundle] loadNibNamed:@"YingQiView7" owner:nil options:nil] lastObject];
        NSString *resPath = [[NSBundle mainBundle] pathForResource:@"bundleWithXib" ofType:@"bundle"];
        
        NSBundle *bundle = [NSBundle bundleWithPath:resPath];
        
        _YingQiView7 = [[bundle loadNibNamed:@"SDKYingQiView7" owner:nil options:nil] lastObject];
        
        [self.YingQiBaseView addSubview:_YingQiView7];
    }
    return _YingQiView7;
}

- (UIView *)YingQiView8 {
	if (_YingQiView8 == nil) {
//        _YingQiView8 = [[[NSBundle mainBundle] loadNibNamed:@"YingQiView8" owner:nil options:nil] lastObject];
        
        NSString *resPath = [[NSBundle mainBundle] pathForResource:@"bundleWithXib" ofType:@"bundle"];
        
        NSBundle *bundle = [NSBundle bundleWithPath:resPath];
        
        _YingQiView8 = [[bundle loadNibNamed:@"SDKYingQiView8" owner:nil options:nil] lastObject];
        
        [self.YingQiBaseView addSubview:_YingQiView8];
	}
	return _YingQiView8;
}
- (UIView *)YingQiView9 {
	if (_YingQiView9 == nil) {
//        _YingQiView9 = [[[NSBundle mainBundle] loadNibNamed:@"YingQiView9" owner:nil options:nil] lastObject];
        
        NSString *resPath = [[NSBundle mainBundle] pathForResource:@"bundleWithXib" ofType:@"bundle"];
        
        NSBundle *bundle = [NSBundle bundleWithPath:resPath];
        
        _YingQiView9 = [[bundle loadNibNamed:@"SDKYingQiView9" owner:nil options:nil] lastObject];
        
        [self.YingQiBaseView addSubview:_YingQiView9];
	}
	return _YingQiView9;
}

- (UIView *)YingQiView10 {
    
    if (_YingQiView10 == nil) {
//        _YingQiView10 = [[[NSBundle mainBundle] loadNibNamed:@"YingQiView10" owner:nil options:nil] lastObject];
        
        NSString *resPath = [[NSBundle mainBundle] pathForResource:@"bundleWithXib" ofType:@"bundle"];
        
        NSBundle *bundle = [NSBundle bundleWithPath:resPath];
        
        _YingQiView10 = [[bundle loadNibNamed:@"SDKYingQiView10" owner:nil options:nil] lastObject];
        
        [self.YingQiBaseView addSubview:_YingQiView10];
    }
    return _YingQiView10;
}

- (UIView *)YingQiView12 {
    
    if (_YingQiView12 == nil) {
//        _YingQiView12 = [[[NSBundle mainBundle] loadNibNamed:@"YingQiView12" owner:nil options:nil] lastObject];
        
        NSString *resPath = [[NSBundle mainBundle] pathForResource:@"bundleWithXib" ofType:@"bundle"];
        
        NSBundle *bundle = [NSBundle bundleWithPath:resPath];
        
        _YingQiView12 = [[bundle loadNibNamed:@"SDKYingQiView12" owner:nil options:nil] lastObject];
        
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
- (IBAction)continueGameMode:(id)sender {
    
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
- (IBAction)bindingPhone:(id)sender {
    
    self.YingQiView2.hidden = YES;
    self.YingQiView10.hidden = NO;
//    self.YingQiView3.tag = 2;
}

/**
 *  返回按钮
 *  @param sender <#sender description#>
 */
- (IBAction)backBtnClick_2:(id)sender {
    
    self.YingQiView2.hidden = YES;
    self.YingQiView1.hidden = NO;
}

#pragma mark  ================== 3 ==================
/**
 *  验证
 *  @param sender <#sender description#>
 */
- (IBAction)verifyBtnClick:(id)sender {
    
    if (!self.tf_3_1.text.length) {
        return;
    }
    
    [YingQiSDK YingQiSDKRequst_checkPhoneRegWithNumber:self.tf_3_1.text withCheckCode:0 sB:^(NSDictionary *dic) {
       
        self.YingQiView3.hidden = YES;
        self.YingQiView4.hidden = NO;
        
    } fB:^(NSDictionary *dic) {
        
    }];
}

/**
 *  注册帐号
 *  @param sender <#sender description#>
 */
- (IBAction)accountRegister:(id)sender {
    
    self.YingQiView3.hidden = YES;
    self.YingQiView5.hidden = NO;
}

- (IBAction)backBtnClick_3:(id)sender {
    
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
- (IBAction)registerBtnClick:(id)sender {
    
    if (self.tf_4_1.text.length && self.tf_4_2.text.length) {
        
        [YingQiSDK YingQiSDKRequst_registerWithNumber:self.tf_3_1.text withCheckCode:[self.tf_4_1.text integerValue] withPwd:self.tf_4_2.text sB:^(NSDictionary *dic) {
            
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
- (IBAction)sendSMSCode:(id)sender {
    
    self.smsBtn.enabled = NO;
    
    [YingQiSDK YingQiSDKRequst_sendCheckCodeWithNumber:self.tf_3_1.text sB:^(NSDictionary *dic) {
        
        self.timeCount = 60;
        // 创建
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(changeTimeTitle)
                                                    userInfo:nil
                                                     repeats:YES];
        
    } fB:^(NSDictionary *dic) {
        
        self.smsBtn.enabled = YES;
        
    }];
}

/**
 *  倒计时验证码
 */
- (void)changeTimeTitle {
    
    // 倒计时结束
    if (self.timeCount <= 0) {
        
        self.smsBtn.enabled = YES;
        [self.smsBtn setTitle:@"发送验证码" forState:UIControlStateNormal];
        return;
    }
    
    // 正在倒计时
    
    [self.smsBtn setTitle:[NSString stringWithFormat:@"%zds",self.timeCount] forState:UIControlStateNormal];
    self.timeCount--;
}

- (void)changeTimeTitle2 {
    
    // 倒计时结束
    if (self.timeCount2 <= 0) {
        
        self.smsBtn_8.enabled = YES;
        [self.smsBtn_8 setTitle:@"发送验证码" forState:UIControlStateNormal];
        return;
    }
    
    // 正在倒计时
    
    [self.smsBtn_8 setTitle:[NSString stringWithFormat:@"%zds",self.timeCount2] forState:UIControlStateNormal];
    self.timeCount2--;
}




- (IBAction)backBtnClick_4:(id)sender {
    
    self.YingQiView4.hidden = YES;
    self.YingQiView3.hidden = NO;
}


#pragma mark  ================== 5 ==================
- (IBAction)registerBtnClick_5:(id)sender {
    
    if (self.tf_5_1.text.length && self.tf_5_2.text.length) {
        
        [YingQiSDK YingQiSDKRequst_registerAccountWithName:self.tf_5_1.text withPwd:self.tf_5_2.text sB:^(NSDictionary *dic) {
            
            self.YingQiBaseView.hidden = YES;
            
            [self successfullyLogined:dic];
        } fB:^(NSDictionary *dic) {
            
        }];
    }
}

- (IBAction)backBtnClick_5:(id)sender {
    
    self.YingQiView5.hidden = YES;
    self.YingQiView3.hidden = NO;
}


#pragma mark  ================== 6 ==================
/**
 *  登录
 *  @param sender <#sender description#>
 */
- (IBAction)loginBtnClick:(id)sender {
    
    if (self.tf_6_1.text.length && self.tf_6_2.text.length) {
        
        [YingQiSDK YingQiSDKRequst_loginWithNumberStr:self.tf_6_1.text withPwd:self.tf_6_2.text withLoginKey:nil sB:^(NSDictionary *dic) {
            
            self.YingQiBaseView.hidden = YES;
        } fB:^(NSDictionary *dic) {
            
        }];
    }
}

/**
 *  找回密码
 *  @param sender <#sender description#>
 */
- (IBAction)getbackPassWordBtnClick:(id)sender {
    
    self.YingQiView6.hidden = YES;
    self.YingQiView7.hidden = NO;
}

/**
 *  快速注册
 *  @param sender <#sender description#>
 */
- (IBAction)fastRegisterBtnClick:(id)sender {
    
    self.YingQiView6.hidden = YES;
    self.YingQiView3.hidden = NO;
    self.YingQiView3.tag = 6;
}


- (IBAction)backBtnClick_6:(id)sender {
    
    self.YingQiView6.hidden = YES;
    self.YingQiView1.hidden = NO;
}


#pragma mark  ================== 7 ==================
/**
 *  确定
 *  @param sender <#sender description#>
 */
- (IBAction)confirmBtnClick:(id)sender {
    
    if (self.tf_7_1.text.length) {
        
        self.YingQiView7.hidden = YES;
        self.YingQiView8.hidden = NO;
    }
}

/**
 *  其他方式
 *  @param sender <#sender description#>
 */
- (IBAction)otherWayBtnClick:(id)sender {
    
    self.YingQiView7.hidden = YES;
    self.YingQiView9.hidden = NO;
}

- (IBAction)backBtnClick_7:(id)sender {
    
    self.YingQiView7.hidden = YES;
    self.YingQiView6.hidden = NO;
}

#pragma mark  ================== 8 ==================

/**
 *  返回
 *  @param sender <#sender description#>
 */
- (IBAction)backBtnClick_8:(id)sender {
    
    self.YingQiView8.hidden = YES;
    self.YingQiView7.hidden = NO;
}

/**
 *  确定
 *  @param sender <#sender description#>
 */
- (IBAction)confirmBtnClick_8:(id)sender {
    
    [YingQiSDK YingQiSDKRequst_passwordWithNumber:self.tf_7_1.text withCheckCode:[self.tf_8_1.text integerValue] withPwd:self.tf_8_2.text sB:^(NSDictionary *dic) {
        
        self.YingQiBaseView.hidden = YES;
        
        [self successfullyLogined:dic];
        
    } fB:^(NSDictionary *dic) {
        
    }];
}


/**
 *  点击发送验证码
 */
- (IBAction)sendSMSCode_8:(id)sender {
    
    self.smsBtn_8.enabled = NO;
    
    [YingQiSDK YingQiSDKRequst_sendCheckCodeWithNumber:self.tf_7_1.text sB:^(NSDictionary *dic) {
        
        self.timeCount2 = 60;
        // 创建
        self.timer2 = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(changeTimeTitle2)
                                                    userInfo:nil
                                                     repeats:YES];
        
    } fB:^(NSDictionary *dic) {
        
        self.smsBtn_8.enabled = NO;
    }];
}


#pragma mark  ================== 9 ==================

- (IBAction)backBtnClick_9:(id)sender {
    
    self.YingQiView9.hidden = YES;
    self.YingQiView7.hidden = NO;
}

#pragma mark  ================== 10 ==================
/**
 *  点击验证
 *  @param sender <#sender description#>
 */
- (IBAction)clickVerifyBtn_10:(id)sender {
    
    Weakself
    
    if (self.tf_10_1.text.length) {
        
        NSInteger uid = [self.successDict[@"data"][@"tempUser"][@"uid"] integerValue];
        
        [YingQiSDK YingQiSDKRequst_checkBindPhoneWithNumber:self.tf_10_1.text withUid:uid sB:^(NSDictionary *dic) {
    
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
    
    [YingQiSDK YingQiSDKRequst_bindSendCheckcode:dic[@"data"][@"tempUser"] andNumber:self.tf_10_1.text uid:uid sB:^(NSDictionary *dic) {
        
        self.YingQiView10.hidden = YES;
        self.YingQiView12.hidden = NO;
    } fB:^(NSDictionary *dic) {
        
    }];
}

- (IBAction)backBtnClick_10:(id)sender {
    
    self.YingQiView10.hidden = YES;
    self.YingQiView2.hidden = NO;
}

#pragma mark  ================== 12 ==================

/**
 *  点击确定
 *  @param sender <#sender description#>
 */
- (IBAction)clickConfirmBtn_12:(id)sender {
    
    if (self.tf_12_1.text.length) {
        
        NSInteger uid = [self.successDict[@"data"][@"tempUser"][@"uid"] integerValue];
        
        [YingQiSDK YingQiSDKRequst_BindPhoneWithNumber:self.tf_10_1.text withCheckCode:[self.tf_12_1.text integerValue] withTempUser:self.successDict[@"data"] andUid:uid sB:^(NSDictionary *dic) {
            
            [self successfullyLogined:dic];
            
            self.YingQiBaseView.hidden = YES;
        } fB:^(NSDictionary *dic) {
            
        }];
    }
}


- (IBAction)clickBackBtn_12:(id)sender {
    
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
    
    self.tf_6_1.text = self.downDropArr[number];
}

#pragma mark  ================== 最终登录成功的方法 ==================
- (void)successfullyLogined:(NSDictionary *)dic {
    
    
}


#pragma mark  ================== 登录失败的方法 ==================
- (void)failedLogined:(NSDictionary *)dic {
    
    
}

@end
