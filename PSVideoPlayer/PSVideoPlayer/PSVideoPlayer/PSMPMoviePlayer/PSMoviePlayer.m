//
//  PSMoviePlayer.m
//  PSVideoPlayer
//
//  Created by Ryan_Man on 16/9/2.
//  Copyright © 2016年 Ryan_Man. All rights reserved.
//

#import "PSMoviePlayer.h"

#import <AVFoundation/AVFoundation.h>

@interface PSMoviePlayer ()
@property (nonatomic, strong) UISlider * volumeViewSlider;

@end

@implementation PSMoviePlayer
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super init];
    
    if (self)
    {
        self.frame = frame;
        
        self.view.frame = frame;
        self.view.backgroundColor = [UIColor clearColor];
        self.controlStyle = MPMovieControlStyleNone;
        
        //音量控制控件
        MPVolumeView *volumeView = [[MPVolumeView alloc] init];
        volumeView.center = CGPointMake(-1000, 0);
        [self.view addSubview:volumeView];
        
        self.volumeViewSlider = nil;
        for (UIView *view in [volumeView subviews]){
            if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
                 self.volumeViewSlider = (UISlider *)view;
                break;
            }
        }
        
        // 使用这个category的应用不会随着手机静音键打开而静音，可在手机静音下播放声音(必须添加，才可调节声音)
        NSError *error = nil;
        BOOL success = [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: &error];
        
        if (!success) {/* error */}

        
        [self ps_addObserver];
        
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    _frame = frame;
    
    [self.view setFrame:_frame];
}

- (void)ps_ReloadData:(PSVideo *)video
{
    _video = video;
    
    self.contentURL = [NSURL URLWithString:_video.playUrl];
}

//监听播放器状态
- (void)ps_addObserver
{
    // 播放状态改变，可配合playbakcState属性获取具体状态
    ps_AddPost(self, @selector(ps_OnMoviePlayerPlaybackStateDidChange:), MPMoviePlayerPlaybackStateDidChangeNotification);

    // 媒体网络加载状态改变
    ps_AddPost(self, @selector(ps_OnMoviePlayerLoadStateDidChange:), MPMoviePlayerLoadStateDidChangeNotification);
    
    // 视频显示状态改变
    ps_AddPost(self, @selector(ps_OnMoviePlayerReadyForDisplayDidChange:), MPMoviePlayerReadyForDisplayDidChangeNotification);
    
    // 确定了媒体播放时长后
    ps_AddPost(self, @selector(ps_OnMovieDurationAvailable:), MPMovieDurationAvailableNotification);
    
}

- (void)ps_OnMoviePlayerPlaybackStateDidChange:(NSNotification*)notification
{
    if (self.onMoviePlayerStateBlock) {
        self.onMoviePlayerStateBlock(PSMoviePlayerState_PlaybackState);
    }
}

- (void)ps_OnMoviePlayerLoadStateDidChange:(NSNotification*)notification
{
    if (self.onMoviePlayerStateBlock) {
        self.onMoviePlayerStateBlock(PSMoviePlayerState_LoadState);
    }
    
}
- (void)ps_OnMoviePlayerReadyForDisplayDidChange:(NSNotification*)notification
{
    
    if (self.onMoviePlayerStateBlock) {
        self.onMoviePlayerStateBlock(PSMoviePlayerState_ReadyForDisplay);
    }
}

- (void)ps_OnMovieDurationAvailable:(NSNotification*)notification
{
    if (self.onMoviePlayerStateBlock) {
        self.onMoviePlayerStateBlock(PSMoviePlayerState_Available);
    }
}





@end
