//
//  VoiceConverter.m
//  Jeans
//
//  Created by Jeans Huang on 12-7-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "VoiceConverter.h"
#import "amrwapper/wav.h"
#import "opencore-amrnb/interf_dec.h"
#import "opencore-amrwb/dec_if.h"
#import "opencore-amrnb/interf_enc.h"
#import "amrwapper/amrFileCodec.h"

#undef DebugLog
#define DebugLog(...)

#undef LogFunctionName
#define LogFunctionName() // NSLog(@"<%@> %s", [[NSString stringWithCString:__FILE__ encoding:NSUTF8StringEncoding] lastPathComponent], __FUNCTION__)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@implementation VoiceConverter

+ (int)amrToWav:(NSString *)_amrPath wavSavePath:(NSString *)_savePath
{
    LogFunctionName();

    NSLog(@"save : 1  %@,%@",_amrPath,_savePath);
    
    if (!DecodeAMRFileToWAVEFile([_amrPath cStringUsingEncoding:NSASCIIStringEncoding], [_savePath cStringUsingEncoding:NSASCIIStringEncoding])) {
        //删除amr文件
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSLog(@"save : 2  %@,%@",_amrPath,_savePath);
        
//        if ([fileManager fileExistsAtPath:_amrPath]) {
//            [fileManager removeItemAtPath:_amrPath error:nil];
//            
//            NSLog(@"save : 3  %@,%@",_amrPath,_savePath);
//        }

        return 0;
    }
    NSLog(@"save : 4  %@,%@",_amrPath,_savePath);
    return 1;
}

+ (int)wavToAmr:(NSString *)_wavPath amrSavePath:(NSString *)_savePath
{
    LogFunctionName();

    if (EncodeWAVEFileToAMRFile([_wavPath cStringUsingEncoding:NSASCIIStringEncoding], [_savePath cStringUsingEncoding:NSASCIIStringEncoding], 1, 16)) {
        return 0;
    }

    return 1;
}

+ (int)wavToAmrWithFileName:(NSString *)fileName
{
    LogFunctionName();

    NSString    *wavFilePath = [NSString stringWithFormat:@"%@%@.wav", VoiceCacheFilePath, fileName];
    NSString    *amrFilePath = [NSString stringWithFormat:@"%@%@.amr", VoiceCacheFilePath, fileName];

    return [VoiceConverter wavToAmr:wavFilePath amrSavePath:amrFilePath];
}

//+ (int)amrToWavWithFileName:(NSString *)fileName sourcefilepath:(NSString *)finepath
//{
//    LogFunctionName();
//    
//    finepath = [finepath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
//    NSString    *wavFilePath = [NSString stringWithFormat:@"%@%@.wav", VoiceCacheFilePath, fileName];
//    NSString    *amrFilePath = [NSString stringWithFormat:@"%@%@.amr", VoiceCacheFilePath, fileName];
//    
//    NSLog(@"save : %@ finepath == %@",wavFilePath, finepath);
//    NSLog(@"save : %@",amrFilePath);
//    
//    return [VoiceConverter amrToWav:finepath wavSavePath:amrFilePath];
//}201610271745225635

+ (int)amrToWavWithFileName:(NSString *)fileName
{
    LogFunctionName();

    NSString    *wavFilePath = [NSString stringWithFormat:@"%@%@.wav", VoiceCacheFilePath, fileName];
    NSString    *amrFilePath = [NSString stringWithFormat:@"%@%@.amr", VoiceCacheFilePath, fileName];
    
    NSLog(@"save : %@",wavFilePath);
    NSLog(@"save amr : %@",amrFilePath);

    return [VoiceConverter amrToWav:amrFilePath wavSavePath:wavFilePath];
}

+ (int)amrToWavWithFileName:(NSString *)armfilepath wav:(NSString *)wavfilepath
{
    LogFunctionName();
    
    
    
    NSLog(@"save : %@",wavfilepath);
    NSLog(@"save amr : %@",armfilepath);
    
    return [VoiceConverter amrToWav:armfilepath wavSavePath:wavfilepath];
}

+ (NSString *)getWavPathByFileName:(NSString *)fileName
{
    LogFunctionName();

    return [NSString stringWithFormat:@"%@%@.wav", VoiceCacheFilePath, fileName];
}

+ (NSString *)getAmrPathByFileName:(NSString *)fileName
{
    LogFunctionName();

    return [NSString stringWithFormat:@"%@%@.amr", VoiceCacheFilePath, fileName];
}

+ (void)deleteAmrAfterSend:(NSString *)fileName
{
    LogFunctionName();

    if ((fileName == nil) || ([fileName length] == 0)) {
        DebugLog(@"deleteAmrAfterSend fileName is NULL");
        return;
    }

    NSError     *error = nil;
    NSString    *path = [VoiceConverter getAmrPathByFileName:fileName];
    [[NSFileManager defaultManager] removeItemAtPath:path error:&error];

    if (error) {
        DebugLog(@"deleteAmrAfterSend error:%@", [error domain]);
    }
}

+ (void)deleteWav:(NSString *)fileName
{
    LogFunctionName();

    if ((fileName == nil) || ([fileName length] == 0)) {
        DebugLog(@"deleteWav fileName is NULL");
        return;
    }

    NSError     *error = nil;
    NSString    *path = [VoiceConverter getAmrPathByFileName:fileName];

    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:&error];

        if (error) {
            DebugLog(@"deleteWavAfterSend error:%@", [error domain]);
        }
    }
}

/**
 *  只在录制语音介绍用到,发语音消息不需要
 *
 *  @param fileName    旧文件名
 *  @param newFileName 新文件名
 */
+ (void)changWavNameAfterSend:(NSString *)fileName andNewFileName:(NSString *)newFileName
{
    LogFunctionName();

    if ((fileName == nil) || ([fileName length] == 0)) {
        DebugLog(@"changWavNameAfterSend fileName is NULL");
        return;
    }

    if ((newFileName == nil) || ([newFileName length] == 0)) {
        DebugLog(@"changWavNameAfterSend newFileName is NULL");
        return;
    }

    NSString    *filePath = [VoiceConverter getWavPathByFileName:fileName];
    NSString    *newFilePath = [VoiceConverter getWavPathByFileName:newFileName];

    NSError *error = nil;
    [[NSFileManager defaultManager] moveItemAtPath:filePath toPath:newFilePath error:&error];

    if (error) {
        DebugLog(@"changWavNameAfterSend error:%@", [error domain]);
    }
}

@end

#pragma clang diagnostic pop
