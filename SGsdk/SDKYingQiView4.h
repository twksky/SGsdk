//
//  SDKYingQiView4.h
//  SGsdk
//
//  Created by 周宇晗 on 05/08/2017.
//  Copyright © 2017 twksky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTF.h"
#import "CustomTF_2.h"

@interface SDKYingQiView4 : UIView

@property (strong, nonatomic) IBOutlet UIButton *backBtn;

@property (strong, nonatomic) IBOutlet CustomTF_2 *tf_1;
@property (strong, nonatomic) IBOutlet CustomTF *tf_2;

@property (strong, nonatomic) IBOutlet UIButton *registerBtn;
@property (strong, nonatomic) IBOutlet UIButton *sendSMSBtn;


@end
