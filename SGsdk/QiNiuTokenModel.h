//
//  QiNiuTokenModel.h
//  LianAi
//
//  Created by calvin on 14-8-1.
//  Copyright (c) 2014年 Yung. All rights reserved.
//

//SC-Disabled:#import <Foundation/Foundation.h>
#import "JSONModel.h"

@interface QiNiuTokenModel : JSONModel

@property (nonatomic, strong) NSString  *uptoken;
@property (nonatomic, strong) NSString  *fileName;
@property (nonatomic, strong) NSString  *key;
@property (nonatomic, strong) NSString  *bucketName;

@end
