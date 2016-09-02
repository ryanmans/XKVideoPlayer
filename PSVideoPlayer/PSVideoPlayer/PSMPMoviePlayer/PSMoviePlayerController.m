//
//  PSMoviePlayerController.m
//  PSVideoPlayer
//
//  Created by Ryan_Man on 16/9/2.
//  Copyright © 2016年 Ryan_Man. All rights reserved.
//

#import "PSMoviePlayerController.h"
#import "PSMoviePlayer.h"

#import "PSPlayerControlView.h"

#import <AVFoundation/AVFoundation.h>
typedef NS_ENUM(NSInteger,PSPanDirection)
{
    PSPanDirectionHorizontal, // 横向移动
    PSPanDirectionVertical,   // 纵向移动
};

@interface PSMoviePlayerController ()<UIGestureRecognizerDelegate,PSPlayerControlDelegate>

@property (nonatomic,strong)PSMoviePlayer * mpPlayer;

@property (nonatomic,strong)PSPlayerControlView * playerControlView;

@property (nonatomic,assign)CGRect originalFrame;

// player duration timer
@property (nonatomic, strong) NSTimer * durationTimer;

//播放器Observer
@property (nonatomic,strong)id playbackTimeObserver;

// 是否已经全屏模式
@property (nonatomic, assign) BOOL isFullscreenMode;

// 是否锁定
@property (nonatomic, assign,readonly,getter= isLocked) BOOL isLocked;

//调节音量值
//@property (nonatomic,assign)CGFloat volumeValue;

// 是否在调节音量
@property (nonatomic, assign) BOOL isVolumeAdjust;

// pan手势移动方向
@property (nonatomic, assign) PSPanDirection panDirection;

// 快进退的总时长
@property (nonatomic,assign)CGFloat sumTime;

// 设备方向
@property (nonatomic, assign, readonly, getter=ps_GetDeviceOrientation) UIDeviceOrientation deviceOrientation;

@end


@implementation PSMoviePlayerController

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.clipsToBounds = YES;
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        
        self.originalFrame = frame;
        
        WeakSelf(ws);
        
        //视频播放器
        self.mpPlayer = [[PSMoviePlayer alloc] initWithFrame:self.bounds];
        
        self.mpPlayer.onMoviePlayerStateBlock = ^(PSMoviePlayerState state)
        {
            [ws ps_ObserveValueForMoviePlayerState:state];
        };
  
        [self addSubview:self.mpPlayer.view];
        
        
        //初始化控件菜单视图
        self.playerControlView = NewClass(PSPlayerControlView);
        self.playerControlView.delegate = self;
        self.playerControlView.frame = self.bounds;
        
        [self addSubview:self.playerControlView];
        
        
        //添加滑动手势 (快进 后退，调节音量 ，亮度)
        UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(ps_PanDirection:)];
        pan.delegate = self;
        [self.playerControlView addGestureRecognizer:pan];
        
        //设置监听设备旋转的通知
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        ps_AddPost(self, @selector(ps_OnDeviceOrientationDidChange), UIDeviceOrientationDidChangeNotification);
        
        
        // 监听耳机插入和拔掉通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ps_AudioRouteChangeListenerCallback:) name:AVAudioSessionRouteChangeNotification object:nil];
        
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    self.mpPlayer.frame = self.bounds;
    self.playerControlView.frame = self.bounds;
    
    [self.playerControlView  setNeedsLayout]; //重新布局子视图
}

//视频数据
- (void)setVideo:(PSVideo *)video
{
    _video = video;
    
    [self.mpPlayer ps_ReloadData:_video];
    self.playerControlView.video = _video;
}

- (BOOL)isLocked
{
    return self.playerControlView.isLocked;
}

#pragma mark - PSMoviePlayer -
- (void)ps_ObserveValueForMoviePlayerState:(PSMoviePlayerState)state
{
    
    if (state == PSMoviePlayerState_PlaybackState)[self ps_OnMoviePlayerPlayBackStateDidChange];
    else if (state == PSMoviePlayerState_LoadState)[self ps_OnMoviePlayerPlayBackStateDidChange];
    else if (state == PSMoviePlayerState_ReadyForDisplay)[self ps_OnMoviePlayerPlayBackStateDidChange];
    else if (state == PSMoviePlayerState_Available)[self ps_OnMoviePlayerDurationAvailable];

}

// 播放状态改变，可配合playbakcState属性获取具体状态
- (void)ps_OnMoviePlayerPlayBackStateDidChange
{
    if (self.mpPlayer.playbackState == MPMoviePlaybackStatePlaying)
    {
        [self.playerControlView ps_PlayerControlDidPlayVideo];
        [self ps_StartDurationTimer];
        
        //start loading
       [self.playerControlView ps_PlayerStartLoadAnimating];

    }
    else
    {
        [self.playerControlView ps_PlayerControlDidPauseVideo];
        [self ps_StopDurationTimer];
        
        if (self.mpPlayer.playbackState == MPMoviePlaybackStateStopped)
        {
            [self.playerControlView ps_AnimateMenuBarShow];
        }
    }
    
    //?
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(quality) name:@"" object:nil];

}

- (void)ps_OnMoviePlayerLoadStateDidChange
{
    if (self.mpPlayer.loadState & MPMovieLoadStateStalled) {
        
        //start loading
        [self.playerControlView ps_PlayerStartLoadAnimating];
    }
    
}

- (void)ps_OnMoviePlayerReadyForDisplayDidChange
{
    PSLog(@"MPMoviePlayer  ReadyForDisplayDidChange  Notification");

}

- (void)ps_OnMoviePlayerDurationAvailable
{
    [self ps_StartDurationTimer];

    self.playerControlView.totalSecond = floor(self.mpPlayer.duration);
}

//开启定时器
- (void)ps_StartDurationTimer
{
    if (self.durationTimer)
    {
        [self.durationTimer setFireDate:[NSDate date]];
    }
    else{
        
        self.durationTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(ps_MonitorVideoPlayback) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.durationTimer forMode:NSRunLoopCommonModes];
    }
}

//暂停定时器
- (void)ps_StopDurationTimer
{
    if (self.durationTimer) {
        [self.durationTimer setFireDate:[NSDate distantFuture]];
    }
}

//监听播放进度
- (void)ps_MonitorVideoPlayback
{
    self.playerControlView.currentSecond = floor(self.mpPlayer.currentPlaybackTime);
    self.playerControlView.bufferSecond = self.mpPlayer.playableDuration / self.mpPlayer.duration;
    
}

#pragma mark - PSPlayerControlDelegate -
- (void)ps_PlayerControlView:(PSPlayerControlView *)playerControl withClickState:(PSPlayerControlClickState)state
{
    if (state == PSPlayerControlClickState_Back)[self ps_PlayerBack];
    else if (state == PSPlayerControlClickState_Collect)[self ps_PlayVideo];
    else if (state == PSPlayerControlClickState_Play)[self ps_PlayVideo];
    else if (state == PSPlayerControlClickState_Pause)[self ps_PauseVideo];
    else if (state == PSPlayerControlClickState_FullScreen)[self ps_FullScreenButtonClick];
    else if (state == PSPlayerControlClickState_ShrinkScreen)[self ps_ShrinkScreenButtonClick];
    else if (state == PSPlayerControlClickState_SliderTouchBegan)[self ps_ProgressSliderTouchBegan];
    else if (state == PSPlayerControlClickState_SliderTouchChangeValue)[self ps_ProgressSliderValueChanged];
    else if (state == PSPlayerControlClickState_SliderTouchEnd)[self ps_ProgressSliderTouchEnded];
    
}

//点击返回按钮
- (void)ps_PlayerBack
{
    if (self.isLocked == YES) return;
    
    if (!_isFullscreenMode) //竖屏
    {
        //取消计时器
        [self.durationTimer invalidate];
        
        //暂停视频播放
        [self ps_PauseVideo];
        
        //状态栏
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
        
        if (self.onPlayerControlWillGoBackBlock) {
            self.onPlayerControlWillGoBackBlock();
        }
    }
    else
    {
        //全屏状态，回归竖屏
        [self ps_ShrinkScreenButtonClick];
    }
}

//收藏视频
- (void)ps_CollectVideo
{
    
    
}

//点击播放视频
- (void)ps_PlayVideo
{
    if (self.video == nil || self.video.playUrl.length == 0) return;
    
    [self.playerControlView ps_PlayerControlDidPlayVideo];
    
    [self.mpPlayer play];
}

//点击暂停视频
- (void)ps_PauseVideo
{
    [self.mpPlayer pause];
    
    [self.playerControlView ps_PlayerControlDidPauseVideo];
}

// 全屏按钮点击
- (void)ps_FullScreenButtonClick
{
    if (self.isFullscreenMode) return;
    
    [self ps_ChangeToOrientation:UIDeviceOrientationLandscapeLeft];
    
}

/// 返回竖屏按钮点击
- (void)ps_ShrinkScreenButtonClick
{
    if (!self.isFullscreenMode) return;
    
    [self ps_ChangeToOrientation:UIDeviceOrientationPortrait];
    
}

// slider 按下事件
- (void)ps_ProgressSliderTouchBegan
{
    [self ps_PauseVideo];
    
    [self ps_StopDurationTimer];
}

// slider value changed
- (void)ps_ProgressSliderValueChanged
{
    self.playerControlView.currentSecond = floor(self.playerControlView.changeValue);
}

// slider 松开事件
- (void)ps_ProgressSliderTouchEnded
{
    //进度
    [self.mpPlayer setCurrentPlaybackTime:floor(self.playerControlView.changeValue)];
    [self ps_PlayVideo];
}


#pragma mark - UIGestureRecognizerDelegate -
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    //触控点 是否在detial区域，而且必须没有被锁屏
    if (IsSameString(touch.view.accessibilityIdentifier, @"PSPlayerControlDetatilView") && self.isLocked == NO)
    {
        return YES;
    }
    return NO;
}

//触发手势
- (void)ps_PanDirection:(UIPanGestureRecognizer*)aPan
{
    
    //translationInView： 该方法返回在横坐标上、纵坐标上拖动了多少像素
    // velocityInView：在指定坐标系统中pan gesture拖动的速度
    
    CGPoint locationPoint = [aPan locationInView:self.playerControlView];
    CGPoint veloctyPoint = [aPan velocityInView:self.playerControlView];
    
    switch (aPan.state)
    {
        case UIGestureRecognizerStateBegan: //手势开始时
        {
            //去绝对值
            CGFloat x = fabs(veloctyPoint.x);
            CGFloat y = fabs(veloctyPoint.y);
            
            if (x > y) //水平移动
            {
                self.panDirection = PSPanDirectionHorizontal;
                
                self.sumTime = self.playerControlView.currentSecond; //sumTime 初值
                
                //暂停播放
                [self  ps_PauseVideo];
                [self ps_StopDurationTimer];
                
            }
            else if (x < y) //垂直移动
            {
                self.panDirection = PSPanDirectionVertical;
                if (locationPoint.x > self.playerControlView.width / 2)
                {
                    //音量调节
                    self.isVolumeAdjust = YES;
                    
                }else
                {
                    //亮度调节
                    self.isVolumeAdjust = NO;
                }
            }
        }
            break;
            
        case UIGestureRecognizerStateChanged://正在移动
        {
            switch (self.panDirection) {
                case PSPanDirectionHorizontal:
                {
                    [self ps_PanHorizontalMoved:veloctyPoint.x];
                }
                    break;
                case PSPanDirectionVertical:
                {
                    [self ps_PanVerticalMoved:veloctyPoint.y];
                }
                    break;
                default:
                    break;
            }
        }
            break;
            
        case UIGestureRecognizerStateEnded://手势结束
        {
            switch (self.panDirection) {
                case PSPanDirectionHorizontal:
                {
                    [self ps_ReloadTimeTimeIndicator];
                }
                    break;
                case PSPanDirectionVertical:
                {
                }
                    break;
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
    
}

//pan 水平移动
- (void)ps_PanHorizontalMoved:(CGFloat)value
{
    self.sumTime += value / 200;
    
    //数据容错
    if (self.sumTime > self.playerControlView.totalSecond) {
        self.sumTime = self.playerControlView.totalSecond;
    }
    else if (self.sumTime < 0)
    {
        self.sumTime = 0;
    }
    
    // 播放进度更新
    [self.playerControlView ps_ReloadTimeIndicatorPlay:self.sumTime];
    
    // 快进or后退 状态调整
    PSTimeIndicatorPlayState playState = PSTimeIndicatorPlayStateRewind;
    
    if (value < 0) { // left
        playState = PSTimeIndicatorPlayStateRewind;
    } else if (value > 0) { // right
        playState = PSTimeIndicatorPlayStateFastForward;
    }
    
    if (self.playerControlView.timePlayState != playState)
    {
        if (value < 0) {
            
            // left
            PSLog(@"------fast rewind");
            self.playerControlView.timePlayState = PSTimeIndicatorPlayStateRewind;
        }
        else if (value > 0)
        {
            
            // right
            PSLog(@"------fast forward");
            self.playerControlView.timePlayState = PSTimeIndicatorPlayStateFastForward;
        }
    }
}

//pan 垂直移动
- (void)ps_PanVerticalMoved:(CGFloat)value
{
    
    if (self.isVolumeAdjust) {
        
        // 调节系统音量
        // [MPMusicPlayerController applicationMusicPlayer].volume 这种简单的方式调节音量也可以，只是CPU高一点点
        self.mpPlayer.volumeViewSlider.value -= value / 10000;
        
        CGFloat currentVolume = self.mpPlayer.volumeViewSlider.value;
        
        //音量在0 － 1区间取值
        if (currentVolume > 1.0) currentVolume = 1.0f;
        else if (currentVolume <0.0) currentVolume = 0.0f;
        
        //发送音量修改通知
        ps_Post(@"AVSetting_PlayerControlVolume",[NSNumber numberWithFloat:currentVolume]);
        
    }
    else
    {
        //亮度
        [UIScreen mainScreen].brightness -= value / 10000;
    }
    
}

//刷新快进或后退
- (void)ps_ReloadTimeTimeIndicator
{
    [self.mpPlayer setCurrentPlaybackTime:floor(self.sumTime)];

    //开始播放
    [self ps_PlayVideo];
    [self ps_StartDurationTimer];
}

#pragma mark - UIDeviceOrientationDidChangeNotification -

//获取设备方向
- (UIDeviceOrientation)ps_GetDeviceOrientation
{
    return [UIDevice currentDevice].orientation;
}

// 设备旋转方向改变
- (void)ps_OnDeviceOrientationDidChange
{
    UIDeviceOrientation  orientation = self.ps_GetDeviceOrientation;
    
    if (self.isLocked == YES) return;
    
    switch (orientation)
    {
        case UIDeviceOrientationPortrait: // Device oriented vertically, home button on the bottom
        {
            //home键在 下
            [self ps_RestoreOriginalScreen];
        }
            break;
        case UIDeviceOrientationPortraitUpsideDown: { // Device oriented vertically, home button on the top
            
            //home键在 上
        }
            break;
        case UIDeviceOrientationLandscapeLeft: {      // Device oriented horizontally, home button on the right
            
            //home键在 右
            [self ps_ChangeToFullScreenForOrientation:UIDeviceOrientationLandscapeLeft];
        }
            break;
        case UIDeviceOrientationLandscapeRight: {     // Device oriented horizontally, home button on the left
            
            //home键在 左
            [self ps_ChangeToFullScreenForOrientation:UIDeviceOrientationLandscapeRight];
        }
            break;
            
        default:
            break;
    }
}

//原屏
- (void)ps_RestoreOriginalScreen
{
    
    if (!self.isFullscreenMode) return;
    
    if ([UIApplication sharedApplication].statusBarHidden) {
        
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    }
    if (self.onPlayerControlWillChangeToOriginalScreenModeBlock) {
        self.onPlayerControlWillChangeToOriginalScreenModeBlock();
    }
    
    self.frame = self.originalFrame;
    
    self.isFullscreenMode = NO;
}

//全屏
- (void)ps_ChangeToFullScreenForOrientation:(UIDeviceOrientation)orientation
{
    if (self.isFullscreenMode) return;
    
    if (self.playerControlView.isBarShowing) {
        
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    } else {
        
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }
    
    //全屏
    if (self.onPlayerControlWillChangeToFullScreenModeBlock) {
        self.onPlayerControlWillChangeToFullScreenModeBlock();
    }
    
    self.frame = [UIScreen mainScreen].bounds;
    
    self.isFullscreenMode = YES;
    
}

//手动切换设备方向
- (void)ps_ChangeToOrientation:(UIDeviceOrientation)orientation
{
    if (IsHasSelector([UIDevice currentDevice], @selector(setOrientation:)))
    {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        
        [invocation setSelector:selector];
        
        [invocation setTarget:[UIDevice currentDevice]];
        
        int val = orientation;
        
        [invocation setArgument:&val atIndex:2];
        
        [invocation invoke];
    }
}

#pragma mark - UIDeviceOrientationDidChangeNotification -

- (void)ps_AudioRouteChangeListenerCallback:(NSNotification*)notification
{
    NSInteger routeChangeReason = [[notification.userInfo valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    switch (routeChangeReason)
    {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            
            PSLog(@"---耳机插入");
            
//            [self ps_PauseVideo];//test
            
            break;
            
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
        {
            
            PSLog(@"---耳机拔出");
            // 拔掉耳机继续播放(当前播放进度继续)
            [self.mpPlayer setCurrentPlaybackTime:floor(self.playerControlView.changeValue)];
            [self ps_PlayVideo];
        }
            break;
            
        case AVAudioSessionRouteChangeReasonCategoryChange:
        {
            
            PSLog(@"AVAudioSessionRouteChangeReasonCategoryChange");
        }
            break;
            
        default:
            break;
    }
}



@end
