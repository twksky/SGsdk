//
//  SDKYingQiView9.m
//  SGsdk
//
//  Created by 周宇晗 on 05/08/2017.
//  Copyright © 2017 twksky. All rights reserved.
//

#import "SDKYingQiView9.h"

@implementation SDKYingQiView9

- (instancetype)init {
    
    NSString *resPath = [[NSBundle mainBundle] pathForResource:@"bundleWithXib" ofType:@"bundle"];
    
    NSBundle *bundle = [NSBundle bundleWithPath:resPath];
    
    self = [[bundle loadNibNamed:@"SDKYingQiView9" owner:nil options:nil] lastObject];
    
    return self;
}

@end
