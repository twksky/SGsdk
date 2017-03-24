//
//  VoiceConverter.h
//  Jeans
//
//  Created by Jeans Huang on 12-7-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define VoiceCacheFilePath [NSString stringWithFormat: @ "%@/voiceCache/", [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]]

@interface VoiceConverter : NSObject

+ (int)amrToWav:(NSString *)_amrPath wavSavePath:(NSString *)_savePath;

+ (int)amrToWavWithFileName:(NSString *)fileName;

+ (int)amrToWavWithFileName:(NSString *)armfilepath wav:(NSString *)wavfilepath;

//+ (int)amrToWavWithFileName:(NSString *)fileName sourcefilepath:(NSString *)finepath;

+ (NSString *)getWavPathByFileName:(NSString *)fileName;

+ (void)deleteWav:(NSString *)fileName;
+ (void)deleteAmrAfterSend:(NSString *)fileName;


+ (NSString *)getAmrPathByFileName:(NSString *)fileName;

+ (void)changWavNameAfterSend:(NSString *)fileName andNewFileName:(NSString *)newFileName;
@end
