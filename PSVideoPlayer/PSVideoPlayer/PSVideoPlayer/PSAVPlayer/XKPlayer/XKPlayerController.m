//
//  XKPlayerController.m
//  XKPharmacy
//
//  Created by RyanMans on 16/12/8.
//  Copyright © 2016年 P.S. All rights reserved.
//

#import "XKPlayerController.h"
#import "XKPlayer.h"
#import "XKPlayerControlView.h"

typedef NS_ENUM(NSInteger,PSPanDirection)
{
    PSPanDirectionHorizontal, // 横向移动
    PSPanDirectionVertical,   // 纵向移动
};

@interface XKPlayerController ()<UIGestureRecognizerDelegate,PSPlayerControlDelegate>

//播放器layer
@property (nonatomic,strong)XKPlayer * avPlayer;

//播放器上的操作菜单
@property (nonatomic,strong)XKPlayerControlView * playerControlView;

//最开始的frame（用于记录，横屏时需要）
@property (nonatomic,assign)CGRect originalFrame;

//播放器Observer
@property (nonatomic,strong)id playbackTimeObserver;

// 是否已经全屏模式
@property (nonatomic, assign) BOOL isFullscreenMode;

// 是否锁定
@property (nonatomic, assign,readonly,getter= isLocked) BOOL isLocked;

//调节音量值
@property (nonatomic,assign)CGFloat volumeValue;

// 是否在调节音量
@property (nonatomic, assign) BOOL isVolumeAdjust;

// pan手势移动方向
@property (nonatomic, assign) PSPanDirection panDirection;

// 快进退的总时长
@property (nonatomic,assign)CGFloat sumTime;

// 设备方向
@property (nonatomic, assign, readonly, getter=ps_GetDeviceOrientation) UIDeviceOrientation deviceOrientation;
@end

@implementation XKPlayerController

- (void)dealloc
{
    _avPlayer = nil;
    _playerControlView = nil;
}

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
        self.avPlayer = [[XKPlayer alloc] init];
        self.avPlayer.frame = self.bounds;
        
        self.avPlayer.onPlayerStatusBlock = ^(NSString * keyPath,AVPlayerItem * playerItem)
        {
            [ws ps_ObserveValueForKeyPath:keyPath withPlayerItem:playerItem];
        };
        
        self.avPlayer.onPlayerDidEndBlock = ^ (NSNotification * notification)
        {
            [ws ps_VideoPlayDidEnd:notification];
        };
        
        [self addSubview:self.avPlayer];
        
        
        //初始化控件菜单视图
        self.playerControlView = NewClass(XKPlayerControlView);
        self.playerControlView.delegate = self;
        self.playerControlView.frame = self.bounds;
        [self addSubview:self.playerControlView];

        //添加滑动手势 (快进 后退，调节音量 ，亮度)
        UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(ps_PanDirection:)];
        pan.delegate = self;
        [self.playerControlView addGestureRecognizer:pan];
        
        
        // 监听耳机插入和拔掉通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ps_AudioRouteChangeListenerCallback:) name:AVAudioSessionRouteChangeNotification object:nil];
        
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    self.avPlayer.frame = self.bounds;
    self.playerControlView.frame = self.bounds;
    
    [self.playerControlView  setNeedsLayout]; //重新布局子视图
}

- (void)setIsFullscreenMode:(BOOL)isFullscreenMode
{
    _isFullscreenMode = isFullscreenMode;
    
    self.playerControlView.isFullscreenMode = _isFullscreenMode;
}

- (void)setIsNaiBarHidenMode:(BOOL)isNaiBarHidenMode
{
    _isNaiBarHidenMode = isNaiBarHidenMode;
    
    self.playerControlView.isNaviBarHideMode = _isNaiBarHidenMode;
}

//MARK:视频数据
- (void)setVideo:(XKVideo *)video
{
    _video = video;
    
    [self.avPlayer ps_ReloadData:_video];
    self.playerControlView.video = _video;
    
    //立即播放
    [self ps_PlayVideo];
}

- (BOOL)isLocked
{
    return self.playerControlView.isLocked;
}

#pragma mark - 播放器layer
//MARK:视频状态接收
- (void)ps_ObserveValueForKeyPath:(NSString *)keyPath withPlayerItem:(AVPlayerItem*)playerItem
{
    if (!playerItem) return;
    
    if (IsSameString(keyPath, @"status")) {
        
        if (playerItem.status == AVPlayerStatusReadyToPlay)  //准备播放
        {
            NSLog(@"status --- AVPlayerStatusReadyToPlay");

            //获取视频总时长
            CMTime duration = playerItem.duration;
            
            //转化成秒
            CGFloat totalSecond = duration.value / playerItem.duration.timescale;
            
            self.playerControlView.totalSecond = totalSecond; //CMTimeGetSeconds(duration);
            
            [self ps_MonitoringPlayBack:playerItem];
            
        }else if (playerItem.status == AVPlayerStatusUnknown || playerItem.status == AVPlayerStatusFailed)
        {
            NSLog(@"视频出错了！");
        }
    }else if (IsSameString(keyPath,  @"loadedTimeRanges"))
    {
        //计算缓冲进度
        NSTimeInterval timeInterval = [self ps_AvailableDuration];
        
        CMTime duration = playerItem.duration;
        
        CGFloat totalDuration = CMTimeGetSeconds(duration);
        
        self.playerControlView.bufferSecond = timeInterval / totalDuration;
    }
}

//MARK:视频播放结束
- (void)ps_VideoPlayDidEnd:(NSNotification*)notification
{
    WeakSelf(ws);
    [self.avPlayer.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        
        [ws.playerControlView ps_PlayerControlDidEndPlayVideo];
        
    }];
}

//MARK:/用于监听每秒的状态
- (void)ps_MonitoringPlayBack:(AVPlayerItem*)playerItem
{
    
    WeakSelf(ws);
    self.playbackTimeObserver =  [self.avPlayer.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
        
        CGFloat currentSecond = playerItem.currentTime.value/playerItem.currentTime.timescale;// 计算当前在第几秒
        
        ws.playerControlView.currentSecond = currentSecond;
    }];
}

//MARK:计算缓冲进度
- (NSTimeInterval)ps_AvailableDuration
{
    NSArray * loadTimeRanges = [[self.avPlayer.player currentItem] loadedTimeRanges];
    
    CMTimeRange timeRange = [loadTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    
    NSTimeInterval result = startSeconds + durationSeconds;// 计算缓冲总进度
    
    return result;
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
    
    [self.avPlayer.player play];
}

//点击暂停视频
- (void)ps_PauseVideo
{
    [self.avPlayer.player pause];
    
    [self.playerControlView ps_PlayerControlDidPauseVideo];
}

// 全屏按钮点击
- (void)ps_FullScreenButtonClick
{
    if (self.isFullscreenMode) return;
    
//    [self ps_ChangeToOrientation:UIDeviceOrientationLandscapeLeft];
    [self ps_ChangeToFullScreenForOrientation:UIDeviceOrientationLandscapeLeft];
    
}

/// 返回竖屏按钮点击
- (void)ps_ShrinkScreenButtonClick
{
    if (!self.isFullscreenMode) return;
    
//    [self ps_ChangeToOrientation:UIDeviceOrientationPortrait];
    [self ps_RestoreOriginalScreen];
    
}

// slider 按下事件
- (void)ps_ProgressSliderTouchBegan
{
    [self ps_PauseVideo];
}

// slider value changed
- (void)ps_ProgressSliderValueChanged
{
    CMTime changedTime = CMTimeMakeWithSeconds(self.playerControlView.changeValue, 1);
    
    CGFloat changeSecond = changedTime.value/changedTime.timescale;// 计算当前在第几秒
    
    self.playerControlView.currentSecond = changeSecond;
}

// slider 松开事件
- (void)ps_ProgressSliderTouchEnded
{
    CMTime changedTime = CMTimeMakeWithSeconds(self.playerControlView.changeValue, 1);
    
    WeakSelf(ws);
    [self.avPlayer.player seekToTime:changedTime completionHandler:^(BOOL finished) {
        
        [ws ps_PauseVideo];
    }];
}
#pragma mark - 快进 后退，调节音量 ，亮度
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
            NSLog(@"------fast rewind");
            self.playerControlView.timePlayState = PSTimeIndicatorPlayStateRewind;
        }
        else if (value > 0)
        {
            
            // right
            NSLog(@"------fast forward");
            self.playerControlView.timePlayState = PSTimeIndicatorPlayStateFastForward;
        }
    }
}

//pan 垂直移动
- (void)ps_PanVerticalMoved:(CGFloat)value
{
    
    if (self.isVolumeAdjust) {
        
        //调节系统音量
        self.volumeValue -= value / 10000;
        
        //音量在0 － 1区间取值
        if ( self.volumeValue > 1.0) self.volumeValue = 1.0f;
        else if ( self.volumeValue <0.0) self.volumeValue = 0.0f;
        
        //发送音量修改通知
        ps_Post(@"AVSetting_PlayerControlVolume",[NSNumber numberWithFloat: self.volumeValue]);
        
        [self.avPlayer ps_PlayerVolumeSeting:self.volumeValue];
        
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
    CMTime changedTime = CMTimeMakeWithSeconds(self.sumTime, 1);
    
    [self.avPlayer.player seekToTime:changedTime completionHandler:^(BOOL finished) {
        
        [self.playerControlView ps_ReloadTimeIndicatorPlay:self.sumTime];
        //开始播放
        [self ps_PlayVideo];
    }];
}


//原屏
- (void)ps_RestoreOriginalScreen
{
    
    if (!self.isFullscreenMode) return;
    
    if ([UIApplication sharedApplication].statusBarHidden) {
        
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    }
    if (self.onPlayerControlWillChangeToOriginalScreenModeBlock) {
        self.onPlayerControlWillChangeToOriginalScreenModeBlock();
    }
    
    
    [UIView animateWithDuration:0.3 animations:^{
        self.transform = CGAffineTransformIdentity;
        self.frame = self.originalFrame;

    }];
    
    self.isFullscreenMode = NO;
}

//全屏
- (void)ps_ChangeToFullScreenForOrientation:(UIDeviceOrientation)orientation
{
    if (self.isFullscreenMode) return;
    
    if ([UIApplication sharedApplication].statusBarHidden == NO) {
        
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    }
    
    //全屏
    if (self.onPlayerControlWillChangeToFullScreenModeBlock) {
        self.onPlayerControlWillChangeToFullScreenModeBlock();
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.transform = CGAffineTransformMakeRotation(M_PI / 2);
        self.frame = [UIScreen mainScreen].bounds;

    }];
    
    self.isFullscreenMode = YES;
    
}

//MARK:监听耳机插入和拔掉通知
- (void)ps_AudioRouteChangeListenerCallback:(NSNotification*)notification
{
    NSInteger routeChangeReason = [[notification.userInfo valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    switch (routeChangeReason)
    {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            
            NSLog(@"---耳机插入");
            
            //            [self ps_PauseVideo];//test
            
            break;
            
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
        {
            NSLog(@"---耳机拔出");
            
            // 拔掉耳机继续播放(当前播放进度继续)
            
            CMTime changedTime = CMTimeMakeWithSeconds(self.playerControlView.changeValue, 1);
            WeakSelf(ws);
            [self.avPlayer.player seekToTime:changedTime completionHandler:^(BOOL finished) {
                
                // 拔掉耳机继续播放
                [ws ps_PlayVideo];
            }];
            
        }
            break;
            
        case AVAudioSessionRouteChangeReasonCategoryChange:
        {
            
            NSLog(@"AVAudioSessionRouteChangeReasonCategoryChange");
        }
            break;
            
        default:
            break;
    }
}

@end
