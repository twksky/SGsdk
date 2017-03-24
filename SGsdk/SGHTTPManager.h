//
//  SGHTTPManager.h
//  SGsdk
//
//  Created by twksky on 2016/10/21.
//  Copyright © 2016年 twksky. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface SGHTTPManager : AFHTTPSessionManager

+ (instancetype)sharedManager;

- (void)sg_AsyncPostRequestWithEncrypt:(NSString *)url content:(NSMutableDictionary *)content successBlock:(void (^)(NSData *data)) successBlock failedBlock:(void (^)(NSError *error))failedBlock;

@end
