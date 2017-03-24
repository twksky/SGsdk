//
//  SGAudioManger.m
//  SGsdk
//
//  Created by twksky on 2016/10/24.
//  Copyright © 2016年 twksky. All rights reserved.
//

#import "SGAudioManger.h"
#import "AFNetworking.h"
#import "AFURLRequestSerialization.h"
#import "AFNetworking.h"
#import "AFHTTPSessionManager.h"
#import "SGHTTPManager.h"

@interface SGAudioManger ()<AVAudioRecorderDelegate, AVAudioPlayerDelegate>

- (void)detectionVoice;//侦查声音大小

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@implementation SGAudioManger
@synthesize g_recorder;

#pragma mark - private

#pragma mark - system
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (_isShowProgress && _displayLink) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
    
    _player = nil;
    
    g_recorder = nil;
    
}

- (id)init
{
    
    self = [super init];
    
    if (self != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(sensorStateChange:)
                                                 name    :UIDeviceProximityStateDidChangeNotification
                                                 object  :nil];
    }
    
    return self;
}

- (void)updateProgressCircle
{
    //    DebugLog(@"currentTime:%f", self.player.currentTime);
    // update progress value
    if (_delegate && [_delegate respondsToSelector:@selector(voicePlayProgress:)]) {
        [_delegate voicePlayProgress:(self.player.currentTime / self.player.duration)];
    }
}

//#pragma mark - public
//
//- (void)playAudioWithResourcePath:(NSString *)filePath
//{
//    
//    NSError *error = nil;
//    NSURL   *url = [NSURL fileURLWithPath:filePath];
//    
//    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
//    
//    if (_player) {
//        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
//        [[AVAudioSession sharedInstance] setActive:YES error:nil];
//        _player.delegate = self;
//        [_player prepareToPlay];
//        [_player play];
//        [self startProximityMonitering];
//    } else {
//        [self stopProximityMonitering];
//        
//        if (_delegate && [_delegate respondsToSelector:@selector(voicePlayEnd)]) {
//            [_delegate voicePlayEnd];
//            NSLog(@"playAudioWithFileName error:%@", [error domain]);
//        }
//    }
//}

- (void)playAudioWithFileName:(NSString *)fileName
{
    self.currentFileName = fileName;
    
    NSLog(@"~~~~~~~1 :: %@",fileName);
    
    
    if (!fileName) {
        NSLog(@"要播放的文件名为空");
        return;
    }
    
//    NSString *filePath = fileName;
    
    NSLog(@"~~~~~~~2 :: %@",fileName);
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
        NSLog(@"要播放的文件不存在:%@", fileName);
        return;
    }
    
    NSLog(@"~~~~~~~3 :: %@",fileName);
    
    if (_player) {
        [_player stop];
        _player = nil;
    }
    
    NSError *error = nil;
    NSURL   *url = [NSURL fileURLWithPath:fileName];
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    
    if (_player) {
        if (_isShowProgress == YES) {
            [self startProgress];
            NSLog(@"~~~~~~~4 :: _isShowProgress");
        }
        
//        // 在主页语音介绍需要用到这个回调
//        if (_delegate && [_delegate respondsToSelector:@selector(voiceStartPlay)]) {
//            [_delegate voiceStartPlay];
//        }
        
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        _player.delegate = self;
        [_player prepareToPlay];
        [_player play];
        NSLog(@"~~~~~~~5 ::[_player play]");
        [self startProximityMonitering];
    } else {
        NSLog(@"~~~~~~~6 :: NO _player");
        
        [self stopProximityMonitering];
        
        if (_delegate && [_delegate respondsToSelector:@selector(voicePlayEnd)]) {
            [_delegate voicePlayEnd];
            NSLog(@"playAudioWithFileName error:%@", [error domain]);
        }
    }
}

- (void)stopPlaying
{
    
    if (_player) {
        [_player stop];
        _player = nil;
        
        if (_isShowProgress) {
            [self.displayLink invalidate];
            self.displayLink = nil;
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(voicePlayEnd)]) {
            [self stopProximityMonitering];
            [_delegate voicePlayEnd];
        }
    }
}

- (void)startProgress
{
    if (!self.displayLink) {
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateProgressCircle)];
        self.displayLink.frameInterval = 2;
        [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    } else {
        self.displayLink.paused = NO;
    }
}

- (void)pause
{

    self.displayLink.paused = YES;
    [self.player pause];
}

- (void)playRecvVoiceMsgWithUrl:(NSString *)urlStr
{
    NSLog(@"播放************");
    
    if (g_recorder) {
        [self stopRecord];
    }
    
    g_recorder = nil;
    
    if (!urlStr) {
        NSLog(@"Voice urlStr is nil");
        return;
    }
    
    NSString    *fileName = [urlStr lastPathComponent];
    NSString    *filePath = [VoiceConverter getWavPathByFileName:fileName];
    
    //不存在的时候,去下载
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSURL           *url = [NSURL URLWithString:urlStr];
        NSURLRequest    *request = [NSURLRequest requestWithURL:url];
        
        AFHTTPRequestOperation *AFHoperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        NSString *filePath = [VoiceConverter getAmrPathByFileName:fileName];
        AFHoperation.outputStream = [[NSOutputStream alloc] initToFileAtPath:filePath append:NO];
        
        NSLog(@"$$ outputStream : = : %@",[VoiceConverter getAmrPathByFileName:fileName]);
        
        [AFHoperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"***fileName = %@",fileName);
//            sleep(20);
            
            NSString *fileName1 = [NSString stringWithFormat:@"%@%@.wav", VoiceCacheFilePath, fileName];
            [VoiceConverter amrToWav:filePath wavSavePath:fileName1];
            
            // [VoiceConverter amrToWavWithFileName:filePath];
            [VoiceConverter deleteAmrAfterSend:fileName];
            
            [self playAudioWithFileName:fileName1];
        }
                                            failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             NSLog(@"its make an error");
         }
         ];
        [AFHoperation start];
    } else {
        NSLog(@"***fileName = %@",fileName);
        NSString *fileName1 = [NSString stringWithFormat:@"%@%@.wav", VoiceCacheFilePath, fileName];
        [VoiceConverter amrToWav:filePath wavSavePath:fileName1];

        [self playAudioWithFileName:fileName1];
    }
    
    return;
}

- (void)startProximityMonitering
{
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    NSLog(@"开启距离监听");
}

- (void)stopProximityMonitering
{
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    NSLog(@"关闭距离监听");
}

- (void)sensorStateChange:(NSNotification *)notification
{
    // 如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗
    if ([[UIDevice currentDevice] proximityState] == YES) {
        NSLog(@"Device is close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    } else {
        NSLog(@"Device is not close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
}

#pragma mark - 录音
- (void)startRecordWithFileName:(NSString *)fileName
{
    //    if (g_audioPlay) {
    //        [g_audioPlay pause];
    //    }
    //    g_audioPlay = nil;
    
    // 创建录音文件，准备录音
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    NSLog(@"1 ===  %@,%f",g_recorder,g_recorder.currentTime);
    if (g_recorder == nil) {
        NSMutableDictionary *recordSetting = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                              [NSNumber numberWithFloat:8000.0], AVSampleRateKey,                                     // 采样率
                                              [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
                                              [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,                                    // 采样位数 默认 16
                                              [NSNumber numberWithInt:1], AVNumberOfChannelsKey,                                      // 通道的数
                                              [NSNumber numberWithInt:AVAudioQualityHigh], AVEncoderAudioQualityKey,                  // 录音的质量
                                              nil];
        
        NSError *error = nil;
        
         NSString    *filePath = [VoiceConverter getWavPathByFileName:fileName];
        // NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"test.caf"];
        NSURL       *url = [NSURL fileURLWithPath:filePath];
        NSLog(@"%@",url.absoluteString);
        // 初始化
        g_recorder = [[AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:&error];
        // 开启音量检测
        g_recorder.meteringEnabled = YES;
        g_recorder.delegate = self;
        NSLog(@"2 ===  %@,%f  == %@",g_recorder,g_recorder.currentTime, error);
    }
    
    
   
    NSLog(@"3 ===  %@,%f",g_recorder,g_recorder.currentTime);
//    NSLog(@"%hhd",[g_recorder prepareToRecord]);
    if ([g_recorder prepareToRecord]) {
        NSLog(@"4 ===  %@,%f",g_recorder,g_recorder.currentTime);
        // 开始
        [g_recorder record];
        
        NSLog(@"5 ===  %@,%f",g_recorder,g_recorder.currentTime);
    }
}

- (void)stopRecord
{
    [g_recorder stop];
    g_recorder = nil;
}

- (void)detectionVoice
{
    NSLog(@"6 ===  %@,%f",g_recorder,g_recorder.currentTime);
    [g_recorder updateMeters];// 刷新音量数据
    double lowPassResults = pow(10, (0.05 * [g_recorder peakPowerForChannel:0]));
    NSLog(@"%lf", lowPassResults);
}

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (flag) {
        if (_isShowProgress) {
            [self.displayLink invalidate];
            self.displayLink = nil;
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(voicePlayEnd)]) {
            [self stopProximityMonitering];
            [_delegate voicePlayEnd];
        }
        
        _player = nil;
    }
}

//#pragma mark 音量监听
//- (void)addVolumeLevelObserveWithHandle:(VolumeLevelHandle) volumeLevelHandle {
//    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(volumeLevelTimerHandle:) userInfo:nil repeats:YES];
//    self.volumeLevelHandle = volumeLevelHandle;
//}

/**
 *  初始化recorder
 */
//- (void)setupRecorder {
//    //不加这句话，真机运行时获取不了
//    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
//    //录音文件路径
//    NSURL *audioURL = [NSURL fileURLWithPath:self.audioFilePath];
//    
//    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:@44100.0, AVSampleRateKey, [NSNumber  numberWithInt:kAudioFormatAppleLossless], AVFormatIDKey, @2, AVNumberOfChannelsKey, [NSNumber numberWithInt:AVAudioQualityMax], AVEncoderAudioQualityKey, nil];
//    
//    NSError *error;
//    self.recorder = [[AVAudioRecorder alloc] initWithURL:audioURL settings:settings error:&error];
//    if (error != nil) {
//        Log(@"ERROR: %@", error.localizedDescription);
//    }else {
//        [self.recorder prepareToRecord];
//        self.recorder.meteringEnabled = YES;
//        [self.recorder record];
//    }
//}


@end
