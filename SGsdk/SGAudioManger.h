//
//  SGAudioManger.h
//  SGsdk
//
//  Created by twksky on 2016/10/24.
//  Copyright © 2016年 twksky. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "VoiceConverter.h"

#define maxRecordTime 60

typedef void(^VolumeLevelHandle)(CGFloat level);//音量大小的回调

@protocol VoiceManagerDelegate <NSObject>

@optional
- (void)voiceStartPlay;
- (void)voicePlayEnd;
- (void)voicePlayProgress:(double)progress;

@end

@interface SGAudioManger : NSObject

@property (nonatomic, strong) AVAudioRecorder   *g_recorder;
@property (nonatomic, strong) AVAudioPlayer     *player;
@property (nonatomic, strong) CADisplayLink     *displayLink;

@property (nonatomic, weak) id <VoiceManagerDelegate>   delegate;
@property (nonatomic, assign) BOOL                      isShowProgress;

@property (nonatomic, strong) NSString *currentFileName;


- (void)startRecordWithFileName:(NSString *)fileName;
- (void)stopRecord;

- (void)playRecvVoiceMsgWithUrl:(NSString *)urlStr;
- (void)stopPlaying;
- (void)pause;
- (void)startProgress;

/**
 *  添加麦克风音量大小监听
 *
 *  @param volumeLevelHandle 音量监听回调函数
 */
- (void)addVolumeLevelObserveWithHandle:(VolumeLevelHandle) volumeLevelHandle;

@end
