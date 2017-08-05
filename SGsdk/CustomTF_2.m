//
//  CustomTF_2.m
//  GameSDKTest
//
//  Created by 周宇晗 on 22/07/2017.
//  Copyright © 2017 twksky. All rights reserved.
//

#import "CustomTF_2.h"

@implementation CustomTF_2

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    [self setTextFieldLeftPadding:self forWidth:55];
}

- (void)setTextFieldLeftPadding:(UITextField *)textField forWidth:(CGFloat)leftWidth {
    CGRect frame = textField.frame;
    
    frame.size.width = leftWidth;
    UIView *leftView = [[UIView alloc] initWithFrame:frame];
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.leftView = leftView;
}

@end
