//
//  PSPlayerControlView.m
//  PSVideoPlayer
//
//  Created by Ryan_Man on 16/9/2.
//  Copyright © 2016年 Ryan_Man. All rights reserved.
//

#import "PSPlayerControlView.h"

static const CGFloat kPlayerControl_BarHeight = 50;


#pragma mark - PSPlayerControlTopBar -
@interface PSPlayerControlTopBar : UIView
// 返回按钮
@property (nonatomic,strong)UIButton * backButton;

// 标题
@property (nonatomic,strong)UILabel * titleLabel;

// 收藏按钮
@property (nonatomic,strong)UIButton * collectButton;

@property (nonatomic,copy)void (^onClickTopBarBlock)(PSPlayerControlClickState state);
@end

@implementation PSPlayerControlTopBar

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.backgroundColor = RGBA(0, 0, 0, 0.3);
        self.userInteractionEnabled = YES;
        
        [self addSubview:self.backButton];
        
        [self addSubview:self.titleLabel];
        
        [self addSubview:self.collectButton];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.backButton.frame = CGRectMake(CGRectGetMinX(self.bounds) + HalfF(20), (CGRectGetHeight(self.bounds) - HalfF(50)) / 2, HalfF(50), HalfF(50));
    
    self.collectButton.frame = CGRectMake(CGRectGetMaxX(self.bounds)- HalfF(100), (CGRectGetHeight(self.bounds)  - HalfF(80)) / 2, HalfF(80), HalfF(80));
    
    self.titleLabel.frame = CGRectMake(CGRectGetMaxX(self.backButton.frame), (CGRectGetHeight(self.bounds)  - HalfF(40)) / 2, CGRectGetMinX(self.collectButton.frame) - CGRectGetMaxX(self.backButton.frame) - HalfF(20) , HalfF(40));
}

//MARK: Setter And Getter
- (UIButton*)backButton
{
    if (!_backButton)
    {
        _backButton = NewButton();
        _backButton.tag = PSPlayerControlClickState_Back;
        _backButton.userInteractionEnabled = YES;
        [_backButton setImage:[UIImage imageNamed:@"zx-video-banner-back"] forState:(UIControlStateNormal)];
        
        [_backButton addTarget:self action:@selector(ps_clickTopBarEvent:) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _backButton;
}

- (UILabel*)titleLabel
{
    if (!_titleLabel)
    {
        _titleLabel = NewClass(UILabel);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = FontOfSize(16);
        _titleLabel.textColor = [UIColor whiteColor];
    }
    return _titleLabel;
}

- (UIButton*)collectButton
{
    if (!_collectButton)
    {
        _collectButton = NewButton();
        _collectButton.tag = PSPlayerControlClickState_UnCollect;
        _collectButton.userInteractionEnabled = YES;
        
        [_collectButton setImage:[UIImage imageNamed:@"ic_ypmd_collection_nor"] forState:(UIControlStateNormal)];
        [_collectButton setImage:[UIImage imageNamed:@"ic_ypmd_collection_sel"] forState:(UIControlStateSelected)];

        [_collectButton addTarget:self action:@selector(ps_clickTopBarEvent:) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _collectButton;
}

//点击事件
- (void)ps_clickTopBarEvent:(UIButton*)sender
{
    PSLog(@"%s  state : %ld",__func__,(PSPlayerControlClickState)sender.tag);
    
    PSPlayerControlClickState state = (PSPlayerControlClickState)sender.tag;
    
    if (sender == _collectButton) {
        _collectButton.selected = !_collectButton.selected;
        
        if (_collectButton.selected) {
            state = PSPlayerControlClickState_Collect;
        }
        else
        {
            state = PSPlayerControlClickState_UnCollect;

        }
    }
    
    if (self.onClickTopBarBlock)
    {
        self.onClickTopBarBlock(state);
    }
}

- (void)dealloc
{
    _titleLabel = nil;
    
    _collectButton = nil;
    
    _backButton = nil;
}

@end

#pragma mark - PSPlayerControlDetailView -
@interface PSPlayerControlDetailView : UIView
@end

@implementation PSPlayerControlDetailView
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.accessibilityIdentifier = @"PSPlayerControlDetatilView";
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}
@end

#pragma mark - PSPlayerControlBottomBar -

@interface PSPlayerControlBottomBar : UIView

//播放
@property (nonatomic,strong)UIButton * playButton;

//暂停
@property (nonatomic,strong)UIButton * pauseButton;

//时间条
@property (nonatomic,strong)UISlider * progressSlider;

//缓冲进度条
@property (nonatomic,strong)UIProgressView * bufferProgressView;

//时间显示
@property (nonatomic,strong)UILabel * timeLabel;

//全屏
@property (nonatomic,strong)UIButton * fullScreenButton;

//缩小全屏
@property (nonatomic,strong)UIButton * shrinkScreenButton;

@property (nonatomic,copy)void (^onClickBottomBarBlock)(PSPlayerControlClickState state);
@end

@implementation PSPlayerControlBottomBar

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.backgroundColor = RGBA(0, 0, 0, 0.3);
        self.userInteractionEnabled = YES;
        
        [self addSubview:self.playButton];
        
        [self addSubview:self.pauseButton];
        
        [self addSubview:self.progressSlider];
        
        [self addSubview:self.fullScreenButton];
        
        [self addSubview:self.shrinkScreenButton];
        
        [self addSubview:self.timeLabel];
        
        // 缓冲进度条
        [self insertSubview:self.bufferProgressView belowSubview:self.progressSlider];
        
        self.pauseButton.hidden = YES;
        self.shrinkScreenButton.hidden = YES;
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
    self.playButton.frame = CGRectMake(CGRectGetMinX(self.bounds), CGRectGetHeight(self.bounds)/2 - CGRectGetHeight(self.playButton.bounds)/2, CGRectGetWidth(self.playButton.bounds), CGRectGetHeight(self.playButton.bounds));
    
    self.pauseButton.frame = self.playButton.frame;
    
    
    self.fullScreenButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - CGRectGetWidth(self.fullScreenButton.bounds), CGRectGetHeight(self.bounds)/2 - CGRectGetHeight(self.fullScreenButton.bounds)/2, CGRectGetWidth(self.fullScreenButton.bounds), CGRectGetHeight(self.fullScreenButton.bounds));
    
    self.shrinkScreenButton.frame = self.fullScreenButton.frame;
    
    self.progressSlider.frame = CGRectMake(CGRectGetMaxX(self.playButton.frame), 0, CGRectGetMinX(self.fullScreenButton.frame) - CGRectGetMaxX(self.playButton.frame), kPlayerControl_BarHeight);
    
    self.timeLabel.frame = CGRectMake(CGRectGetMidX(self.progressSlider.frame), CGRectGetHeight(self.bounds) - CGRectGetHeight(self.timeLabel.bounds) - 2.0, CGRectGetWidth(self.progressSlider.bounds)/2, CGRectGetHeight(self.timeLabel.bounds));
    
    self.bufferProgressView.bounds = CGRectMake(0, 0, self.progressSlider.bounds.size.width - 7, self.progressSlider.bounds.size.height);
    self.bufferProgressView.center = CGPointMake(self.progressSlider.center.x + 2, self.progressSlider.center.y);
    
}

//MARK: Setter And Getter
- (UIButton*)playButton
{
    if (!_playButton)
    {
        _playButton = NewButton();
        _playButton.tag = PSPlayerControlClickState_Play;
        [_playButton setImage:[UIImage imageNamed:@"kr-video-player-play"] forState:UIControlStateNormal];
        [_playButton addTarget:self action:@selector(ps_clickBottomBarEvent:) forControlEvents:(UIControlEventTouchUpInside)];
        
        _playButton.bounds = CGRectMake(0, 0,kPlayerControl_BarHeight , kPlayerControl_BarHeight);
        
    }
    return _playButton;
}

- (UIButton*)pauseButton
{
    if (!_pauseButton)
    {
        _pauseButton = NewButton();
        _pauseButton.tag = PSPlayerControlClickState_Pause;
        
        [_pauseButton setImage:[UIImage imageNamed:@"kr-video-player-pause"] forState:UIControlStateNormal];
        [_pauseButton addTarget:self action:@selector(ps_clickBottomBarEvent:) forControlEvents:(UIControlEventTouchUpInside)];
        
        _pauseButton.bounds = CGRectMake(0, 0,kPlayerControl_BarHeight , kPlayerControl_BarHeight);
        
    }
    return _pauseButton;
}

- (UIButton*)fullScreenButton
{
    if (!_fullScreenButton)
    {
        _fullScreenButton = NewButton();
        _fullScreenButton.tag = PSPlayerControlClickState_FullScreen;
        
        [_fullScreenButton setImage:[UIImage imageNamed:@"kr-video-player-fullscreen"] forState:(UIControlStateNormal)];
        [_fullScreenButton addTarget:self action:@selector(ps_clickBottomBarEvent:) forControlEvents:(UIControlEventTouchUpInside)];
        
        _fullScreenButton.bounds = CGRectMake(0, 0,kPlayerControl_BarHeight , kPlayerControl_BarHeight);
        
    }
    return _fullScreenButton;
}

- (UIButton*)shrinkScreenButton
{
    if (!_shrinkScreenButton)
    {
        _shrinkScreenButton = NewButton();
        
        _shrinkScreenButton.tag = PSPlayerControlClickState_ShrinkScreen;
        
        [_shrinkScreenButton setImage:[UIImage imageNamed:@"kr-video-player-shrinkscreen"] forState:(UIControlStateNormal)];
        [_shrinkScreenButton addTarget:self action:@selector(ps_clickBottomBarEvent:) forControlEvents:(UIControlEventTouchUpInside)];
        
        _shrinkScreenButton.bounds = CGRectMake(0, 0,kPlayerControl_BarHeight , kPlayerControl_BarHeight);
        
    }
    return _shrinkScreenButton;
}

- (UISlider*)progressSlider
{
    if (!_progressSlider)
    {
        _progressSlider = NewClass(UISlider);
        _progressSlider.enabled = NO;
        _progressSlider.value = 0.f;
        _progressSlider.continuous = YES;
        [_progressSlider setThumbImage:[UIImage imageNamed:@"kr-video-player-point"] forState:UIControlStateNormal];
        [_progressSlider setMinimumTrackTintColor:[UIColor whiteColor]];
        [_progressSlider setMaximumTrackTintColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.4]];
        
        
        [_progressSlider addTarget:self action:@selector(ps_ProgressSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
        
        [_progressSlider addTarget:self action:@selector(ps_ProgressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        [_progressSlider addTarget:self action:@selector(ps_ProgressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside];
        
        [_progressSlider addTarget:self action:@selector(ps_ProgressSliderTouchEnded:) forControlEvents:UIControlEventTouchCancel];
        
    }
    
    return _progressSlider;
}

- (UIProgressView*)bufferProgressView
{
    if (!_bufferProgressView)
    {
        _bufferProgressView = [[UIProgressView alloc] initWithProgressViewStyle:(UIProgressViewStyleDefault)];
        _bufferProgressView.progressTintColor = [UIColor colorWithWhite:1 alpha:0.3];
        _bufferProgressView.trackTintColor = [UIColor clearColor];
    }
    return _bufferProgressView;
}

- (UILabel*)timeLabel
{
    if (!_timeLabel)
    {
        _timeLabel = NewClass(UILabel);
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _timeLabel.font = FontOfSize(10);
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.backgroundColor = [UIColor clearColor];
        
        _timeLabel.bounds = CGRectMake(0, 0, 10, 10);
    }
    return _timeLabel;
}

//MARK :  click
- (void)ps_clickBottomBarEvent:(UIButton*)sender
{
    PSLog(@"%s  state : %ld",__func__,(PSPlayerControlClickState)sender.tag);
    
    if (sender == _fullScreenButton) {
        _fullScreenButton.hidden = YES;
        _shrinkScreenButton.hidden = NO;
    }
    else if (sender == _shrinkScreenButton)
    {
        _fullScreenButton.hidden = NO;
        _shrinkScreenButton.hidden = YES;
        
    }
    
    if (self.onClickBottomBarBlock) {
        self.onClickBottomBarBlock ((PSPlayerControlClickState)sender.tag);
    }
}

//开始按下slider
- (void)ps_ProgressSliderTouchBegan:(UISlider*)slider
{
    if (self.onClickBottomBarBlock) {
        self.onClickBottomBarBlock (PSPlayerControlClickState_SliderTouchBegan);
    }
}

//开始改变
- (void)ps_ProgressSliderValueChanged:(UISlider*)slider
{
    
    if (self.onClickBottomBarBlock) {
        self.onClickBottomBarBlock (PSPlayerControlClickState_SliderTouchChangeValue);
    }
    
}

//结束
- (void)ps_ProgressSliderTouchEnded:(UISlider*)slider
{
    if (self.onClickBottomBarBlock) {
        self.onClickBottomBarBlock (PSPlayerControlClickState_SliderTouchEnd);
    }
}
@end

#pragma mark - PSPlayerControlTimeIndicatorView -
static const CGFloat kVideoTimeIndicatorViewSize = 96;

//快进、快退指示器
@interface PSPlayerControlTimeIndicatorView : UIView
{
    UIImageView * _arrowImageView;
    
    UILabel * _timeLabel;
}
@property (nonatomic,copy)NSString * timeText;
@property (nonatomic,assign)PSTimeIndicatorPlayState timePlayState;
@end

@implementation PSPlayerControlTimeIndicatorView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.hidden = YES;
        
        self.clipsToBounds = YES;
        self.backgroundColor = RGBA(0, 0, 0, 0.3);
        
        [self  setLayerWithCr:10];
        
        
        CGFloat margin = (kVideoTimeIndicatorViewSize - 24 - 12 - HalfF(30)) / 2;
        
        //方向指示图
        _arrowImageView = NewClass(UIImageView);
        _arrowImageView.frame = CGRectMake((kVideoTimeIndicatorViewSize - HalfF(88)) / 2,margin, HalfF(88), HalfF(48));
        [self addSubview:_arrowImageView];
        
        
        //时间显示
        _timeLabel = NewClass(UILabel);
        _timeLabel.frame = CGRectMake(0, margin + HalfF(48) + HalfF(30), kVideoTimeIndicatorViewSize, HalfF(24));
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.font = FontOfSize(12);
        [self addSubview:_timeLabel];
        
    }
    return self;
}

- (void)setTimeText:(NSString *)timeText
{
    _timeText = timeText;
    
    // 防止重叠显示(隐藏所有模态 视图 只显示当前视图)
    
    PSPlayerControlView * playerView = (PSPlayerControlView*)self.superview;
    [playerView ps_PlayerControlHideModeView];
    
    self.hidden = NO;
    
    _timeLabel.text = _timeText;
    
    //取消延迟执行的函数
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(ps_AnimateTimeIndicatorHide) object:nil];
    [self performSelector:@selector(ps_AnimateTimeIndicatorHide) withObject:nil afterDelay:1.0f];
}

- (void)setTimePlayState:(PSTimeIndicatorPlayState)timePlayState
{
    _timePlayState = timePlayState;
    
    if (_timePlayState == PSTimeIndicatorPlayStateRewind) {
        [_arrowImageView setImage:[UIImage imageNamed:@"zx-video-player-rewind"]];
    } else {
        [_arrowImageView setImage:[UIImage imageNamed:@"zx-video-player-fastForward"]];
    }
}

- (void)ps_AnimateTimeIndicatorHide
{
    [UIView animateWithDuration:0.3f animations:^{
        
        self.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        self.hidden = YES;
        
        self.alpha = 1;
        
        self.superview.accessibilityIdentifier = nil;
        
    }];
}
@end

static const CGFloat kVideoBrightnessIndicatorViewSize = 118.0;

@interface PSPlayerControlBrightnessView : UIView
{
    NSMutableArray * _blocksArray;
}
@end

@implementation PSPlayerControlBrightnessView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.hidden = YES;
        
        self.clipsToBounds = YES;
        self.backgroundColor = RGBA(0, 0, 0, 0.3);
        
        [self  setLayerWithCr:10];
        
        [self  setupIndicator];
        
        //监听系统亮度
        [[UIScreen mainScreen] addObserver:self forKeyPath:@"brightness" options:(NSKeyValueObservingOptionNew) context:NULL];
    }
    return self;
}

- (void)dealloc
{
    [[UIScreen mainScreen] removeObserver:self forKeyPath:@"brightness"];
    
}

- (void)setupIndicator
{
    // 亮度图标
    
    UIImageView * brightnessImageView = NewClass(UIImageView);
    brightnessImageView.frame = CGRectMake((kVideoBrightnessIndicatorViewSize - HalfF(100)) / 2, HalfF(30), HalfF(100), HalfF(100));
    brightnessImageView.image = [UIImage imageNamed:@"zx-video-player-brightness"];
    [self addSubview:brightnessImageView];
    
    // 亮度条
    _blocksArray = NewMutableArray();
    
    UIView * backgroundView = NewClass(UIView);
    backgroundView.frame = CGRectMake((kVideoBrightnessIndicatorViewSize - 105) / 2, 50 + HalfF(30) * 2, 105, 2.75 + 2);
    backgroundView.backgroundColor = RGBA(0.25f, 0.22f, 0.21f, 0.65);
    [self addSubview:backgroundView];
    
    CGFloat margin = 1;
    CGFloat blockW = 5.5;
    CGFloat blockH = 2.75;
    
    for (int i = 0; i < 16; i++)
    {
        CGFloat locX = i * (blockW + margin) + margin;
        
        UIView * temp = NewClass(UIView);
        temp.backgroundColor = [UIColor whiteColor];
        temp.frame =  CGRectMake(locX, margin, blockW, blockH);
        
        [backgroundView addSubview:temp];
        [_blocksArray addObject:temp];
    }
    
}

//kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    CGFloat brightness = [change[@"new"] floatValue];
    
    [self  ps_UpdateBrightnessIndicator:brightness];
}

//更新亮度
- (void)ps_UpdateBrightnessIndicator:(CGFloat)value
{
   
    //亮度 在0 － 1区间取值
    if (value > 1.0)value = 1.0f;
    else if (value <0.0)value = 0.0f;
    
    
    PSPlayerControlView * playerView = (PSPlayerControlView*)self.superview;
    [playerView ps_PlayerControlHideModeView];
    
    self.hidden = NO;
    
    CGFloat stage = 1 / 16.0;
    NSInteger level = value / stage;
    
    for (NSInteger i=0; i< _blocksArray.count; i++) {
        UIImageView *img = _blocksArray[i];
        
        if (i <= level) {
            img.hidden = NO;
        } else {
            img.hidden = YES;
        }
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(ps_AnimateBrightnessIndicatorHide) object:nil];
    [self performSelector:@selector(ps_AnimateBrightnessIndicatorHide) withObject:nil afterDelay:1.0];
}

//亮度视图消失
- (void)ps_AnimateBrightnessIndicatorHide
{
    [UIView animateWithDuration:.3 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        self.hidden = YES;
        self.alpha = 1;
        self.superview.accessibilityIdentifier = nil;
    }];
}
@end


#pragma mark - 音量调节器 -
static const CGFloat kVideoVolumeIndicatorViewSize = 118.0;

@interface PSPlayerControlVolumeView : UIView
{
    NSMutableArray * _blocksArray;
    
    UIImageView * _volumeImageView;
    
}
@end

@implementation PSPlayerControlVolumeView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.hidden = YES;
        self.clipsToBounds = YES;
        self.backgroundColor = RGBA(0, 0, 0, 0.3);
        [self  setLayerWithCr:10];
        
        [self  setupVolumeIndicator];
        
        //监听音量变化
        ps_AddPost(self, @selector(ps_PlayerVolumeSeting:), @"AVSetting_PlayerControlVolume");
        
        
    }
    return self;
}
- (void)dealloc
{
    ps_RemovePost(self, @"AVSetting_PlayerControlVolume");
}

- (void)setupVolumeIndicator
{
    
    //音量图标
    _volumeImageView = NewClass(UIImageView);
    _volumeImageView.frame = CGRectMake((kVideoVolumeIndicatorViewSize - 50) / 2, HalfF(30), 50, 50);
    _volumeImageView.image = [UIImage imageNamed:@"zx-video-player-volume"];
    _volumeImageView.accessibilityIdentifier = @"volume";
    [self addSubview:_volumeImageView];
    
    //音量条
    _blocksArray = NewMutableArray();
    
    UIView * backgroundView = NewClass(UIView);
    backgroundView.frame = CGRectMake((kVideoVolumeIndicatorViewSize - 105) / 2, 50 + HalfF(30) * 2, 105, 2.75 + 2);
    backgroundView.backgroundColor = RGBA(0.25f, 0.22f, 0.21f, 0.65);
    [self addSubview:backgroundView];
    
    CGFloat margin = 1;
    CGFloat blockW = 5.5;
    CGFloat blockH = 2.75;
    
    for (int i = 0; i < 16; i++)
    {
        CGFloat locX = i * (blockW + margin) + margin;
        
        UIView * temp = NewClass(UIView);
        temp.backgroundColor = [UIColor whiteColor];
        temp.frame =  CGRectMake(locX, margin, blockW, blockH);
        
        [backgroundView addSubview:temp];
        [_blocksArray addObject:temp];
    }
}

//接收声音变化
- (void)ps_PlayerVolumeSeting:(NSNotification*)noti
{
    CGFloat outputVolume = [[noti object] floatValue];
    
    [self  ps_UpdateVolumeIndicator:outputVolume];
}

//调整声音
- (void)ps_UpdateVolumeIndicator:(CGFloat)value
{
    //防止重叠显示
    PSPlayerControlView * playerView = (PSPlayerControlView*)self.superview;
    [playerView ps_PlayerControlHideModeView];
    
    self.hidden = NO;
    
    
    //音量在0 － 1区间取值
    if (value > 1.0)value = 1.0f;
    else if (value <0.0)value = 0.0f;
    
    
    CGFloat stage = 1 / 16.0f;
    
    NSInteger level = value / stage;
    
    for (int i = 0 ; i < _blocksArray.count; i++) {
        
        UIView * temp = (UIView*)_blocksArray[i];
        
        if (i < level) {
            temp.hidden = NO;
        }else{
            temp.hidden = YES;
        }
    }
    
    if (value == 0.0) { //静音
        
        _volumeImageView.accessibilityIdentifier = @"volumeMute";
        _volumeImageView.image = [UIImage imageNamed:@"zx-video-player-volumeMute"];
        
    }
    else
    {
        _volumeImageView.accessibilityIdentifier = @"volume";
        _volumeImageView.image = [UIImage imageNamed:@"zx-video-player-volume"];
        
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(ps_AnimateVolumeIndicatorHide) object:nil];
    [self performSelector:@selector(ps_AnimateVolumeIndicatorHide) withObject:nil afterDelay:1.0];
}

- (void)ps_AnimateVolumeIndicatorHide
{
    [UIView animateWithDuration:.3 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        self.hidden = YES;
        self.alpha = 1;
        self.superview.accessibilityIdentifier = nil;
    }];
}
@end


#pragma mark - PSProgressHUD  -

@interface PSProgressHUD : UIView
@property (nonatomic,strong)UIActivityIndicatorView * indicatorView;
@property (nonatomic,strong)UILabel * detailTextLabel;

- (void)ps_ShowHUD;
- (void)ps_HideHUD;

@end

@implementation PSProgressHUD

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [self setLayerWithCr:10];
        
        self.backgroundColor = RGBA(0, 0, 0, 0.3);
        
        [self addSubview:self.indicatorView];
        
        [self addSubview:self.detailTextLabel];
        
        [self ps_HideHUD];
    }
    return self;
}

- (UIActivityIndicatorView*)indicatorView
{
    if (!_indicatorView) {
        
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleWhite)];
        
        [_indicatorView stopAnimating];
    }
    
    return _indicatorView;
}

- (UILabel*)detailTextLabel
{
    if (!_detailTextLabel)
    {
        _detailTextLabel = NewClass(UILabel);
        _detailTextLabel.textAlignment = NSTextAlignmentCenter;
        _detailTextLabel.font = FontOfSize(12);
        _detailTextLabel.textColor = [UIColor whiteColor];
        _detailTextLabel.text = @"正在加载";
    }
    return _detailTextLabel;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.indicatorView.frame = CGRectMake((CGRectGetWidth(self.bounds) - HalfF(60)) / 2, HalfF(20), HalfF(60), HalfF(60));
    
    self.detailTextLabel.frame = CGRectMake(CGRectGetMinX(self.bounds), CGRectGetMaxY(self.indicatorView.frame), CGRectGetWidth(self.bounds), HalfF(24));
}


- (void)ps_ShowHUD
{
    
    [_indicatorView startAnimating];
    
    [UIView animateWithDuration:0.25f animations:^{
        
        self.alpha = 0;
        self.alpha = 1.0f;
    }];
}

- (void)ps_HideHUD
{
    [_indicatorView stopAnimating];
    [UIView animateWithDuration:0.25f animations:^{
        
        self.alpha = 1.0;
        self.alpha = 0.0f;
    }];
}
@end


#pragma mark - PSPlayerControlView  -

@interface PSPlayerControlView ()
{
    NSString * _totalTime;
}
@property (nonatomic,strong)PSPlayerControlTopBar * topBar;
@property (nonatomic,strong)PSPlayerControlDetailView * detailView;
@property (nonatomic,strong)PSPlayerControlBottomBar * bottomBar;
@property (nonatomic,strong)PSPlayerControlTimeIndicatorView * timeIndicatorView;
@property (nonatomic,strong)PSPlayerControlBrightnessView * brightnessView;
@property (nonatomic,strong)PSPlayerControlVolumeView * volumeView;
@property (nonatomic,weak)PSProgressHUD * hud;
@property (nonatomic,strong)UIButton * lockButton;


@property (nonatomic, assign) BOOL isLocked;
@property (nonatomic,assign)BOOL isBarShowing;

@end

@implementation PSPlayerControlView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        
        //top
        [self addSubview:self.topBar];

        
        //bottom
        [self addSubview:self.bottomBar];
        
        
        //detailView
        [self addSubview:self.detailView];
        
        //loading视图
        PSProgressHUD * hud = NewClass(PSProgressHUD);
        self.hud = hud;
        [self addSubview:hud];
        
        //锁屏
        [self addSubview:self.lockButton];
        
        // 快进、快退指示器
        [self addSubview:self.timeIndicatorView];
        
        //亮度指示器
        [self addSubview:self.brightnessView];
        
        //音量指示器
        [self addSubview:self.volumeView];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ps_TapPlayerControl:)];
        
        [self addGestureRecognizer:tap];
        
        self.isBarShowing = YES;
        
        [self ps_PlayerStopLoadAnimating];
        
    }
    return self;

}

/*
 -layoutSubviews方法：这个方法，默认没有做任何事情，需要子类进行重写
 -setNeedsLayout方法： 标记为需要重新布局，异步调用layoutIfNeeded刷新布局，不立即刷新，但layoutSubviews一定会被调用
 -layoutIfNeeded方法：如果，有需要刷新的标记，立即调用layoutSubviews进行布局（如果没有标记，不会调用layoutSubviews）
 
 如果要立即刷新，要先调用[view setNeedsLayout]，把标记设为需要布局，然后马上调用[view layoutIfNeeded]，实现布局
 
 在视图第一次显示之前，标记总是“需要刷新”的，可以直接调用[view layoutIfNeeded]
 */

- (void)layoutSubviews
{
    
    [super layoutSubviews];
    
    self.topBar.frame = CGRectMake(CGRectGetMinX(self.bounds), CGRectGetMinY(self.bounds), CGRectGetWidth(self.bounds),kPlayerControl_BarHeight );
    
    self.bottomBar.frame = CGRectMake(CGRectGetMinX(self.bounds), CGRectGetHeight(self.bounds) - kPlayerControl_BarHeight,  CGRectGetWidth(self.bounds), kPlayerControl_BarHeight);
    
    
    self.detailView.frame = CGRectMake(CGRectGetMinX(self.bounds),CGRectGetMaxY(self.topBar.frame) ,CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - kPlayerControl_BarHeight * 2);
    
    
    self.lockButton.frame =  CGRectMake(CGRectGetMinX(self.bounds) + HalfF(20), (CGRectGetHeight(self.bounds) - HalfF(80)) / 2, HalfF(80),  HalfF(80));
    
    [self.lockButton setLayerWithCr:self.lockButton.width / 2];
    
    self.hud.frame = CGRectMake((CGRectGetWidth(self.bounds) - HalfF(120)) / 2 , (CGRectGetHeight(self.bounds) - HalfF(120)) / 2, HalfF(120), HalfF(120));
    
    // 快进、快退指示器
    self.timeIndicatorView.center =  CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));;
    
    //亮度调节器
    self.brightnessView.center = self.timeIndicatorView.center;
    
    //音量调节器
    
    self.volumeView.center = self.brightnessView.center;
    
    
    [self.topBar  setNeedsLayout];
    [self.bottomBar  setNeedsLayout];
    [self.hud  setNeedsLayout];
}

//MARK: setter and getter
- (PSPlayerControlTopBar*)topBar
{
    if (!_topBar) {
        
        WeakSelf(ws);
        _topBar = NewClass(PSPlayerControlTopBar);
        _topBar.onClickTopBarBlock = ^(PSPlayerControlClickState state)
        {
            [ws ps_ClickPlayerControlState:state];
        };
    }
    return _topBar;
}

- (PSPlayerControlBottomBar*)bottomBar
{
    if (!_bottomBar) {
        
        WeakSelf(ws);
        _bottomBar = NewClass(PSPlayerControlBottomBar);
        _bottomBar.onClickBottomBarBlock = ^(PSPlayerControlClickState state)
        {
            [ws ps_ClickPlayerControlState:state];
        };
    }
    return _bottomBar;
}

- (PSPlayerControlDetailView*)detailView
{
    if (!_detailView)
    {
        _detailView = NewClass(PSPlayerControlDetailView);
    }
    return _detailView;
}

- (PSPlayerControlTimeIndicatorView*)timeIndicatorView
{
    if (!_timeIndicatorView) {
        
        _timeIndicatorView = [[PSPlayerControlTimeIndicatorView alloc] initWithFrame:CGRectMake(0, 0, kVideoTimeIndicatorViewSize, kVideoTimeIndicatorViewSize)];
    }
    return _timeIndicatorView;
}

- (PSPlayerControlBrightnessView*)brightnessView
{
    if (!_brightnessView) {
        _brightnessView = [[PSPlayerControlBrightnessView alloc] initWithFrame:CGRectMake(0, 0, kVideoBrightnessIndicatorViewSize, kVideoBrightnessIndicatorViewSize)];
    }
    return _brightnessView;
}

- (PSPlayerControlVolumeView*)volumeView
{
    if (!_volumeView) {
        _volumeView = [[PSPlayerControlVolumeView alloc] initWithFrame:CGRectMake(0, 0, kVideoVolumeIndicatorViewSize, kVideoVolumeIndicatorViewSize)];
    }
    return _volumeView;
}

- (UIButton*)lockButton
{
    if (!_lockButton)
    {
        _lockButton = NewButton();
        _lockButton.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.3];
        _lockButton.userInteractionEnabled = YES;
        
        _lockButton.imageView.contentMode = UIViewContentModeCenter;
        
        [_lockButton setImage:[UIImage imageNamed:@"zx-video-player-unlock"] forState:UIControlStateNormal];
        [_lockButton setImage:[UIImage imageNamed:@"zx-video-player-lock"] forState:UIControlStateHighlighted];
        [_lockButton setImage:[UIImage imageNamed:@"zx-video-player-lock"] forState:UIControlStateSelected];
        [_lockButton addTarget:self action:@selector(ps_LockButtonClick:) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _lockButton;
}

- (CGFloat)changeValue
{
    return self.bottomBar.progressSlider.value;
}

- (void)setVideo:(PSVideo *)video
{
    _video = video;
    self.topBar.titleLabel.text = _video.title;
}

- (void)setTimePlayState:(PSTimeIndicatorPlayState)timePlayState
{
    _timePlayState = timePlayState;
    self.timeIndicatorView.timePlayState = _timePlayState;
}

- (void)setTotalSecond:(CGFloat)totalSecond
{
    _totalSecond = totalSecond;
    
    _totalTime = [self ps_TransformTotalTime:_totalSecond];
    
    self.bottomBar.progressSlider.maximumValue = totalSecond;
    
    [self ps_ReloadTime:@"00:00"];
}

- (void)setCurrentSecond:(CGFloat)currentSecond
{
    _currentSecond = currentSecond;
    
    NSString * currentTime = [self ps_TransformTotalTime:_currentSecond];
    
    //更新进度条
    [self.bottomBar.progressSlider setValue:currentSecond animated:YES];
    
    [self ps_ReloadTime:currentTime];
}

- (void)setBufferSecond:(CGFloat)bufferSecond
{
    _bufferSecond = bufferSecond;
    
    [self.bottomBar.bufferProgressView setProgress:_bufferSecond animated:YES];
}

- (void)ps_ReloadTime:(NSString*)currentTime
{
    self.bottomBar.timeLabel.text = [NSString stringWithFormat:@"%@/%@",currentTime,_totalTime];
}

//总时长转化成字符串
- (NSString*)ps_TransformTotalTime:(CGFloat)totalSecond
{
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:totalSecond];
    
    NSDateFormatter * formatter = NewClass(NSDateFormatter);
    
    if (totalSecond / 3600 >= 1)
    {
        [formatter setDateFormat:@"HH:mm:ss"];
    }else
    {
        [formatter setDateFormat:@"mm:ss"];
    }
    return [formatter stringFromDate:date];
}


//MARK : Method
- (void)ps_ClickPlayerControlState:(PSPlayerControlClickState)state
{
    if (self.delegate && IsHasSelector(self.delegate, @selector(ps_PlayerControlView:withClickState:)))
    {
        [self.delegate ps_PlayerControlView:self withClickState:state];
    }
}

//轻拍
- (void)ps_TapPlayerControl:(UITapGestureRecognizer*)aTap
{
    LogFunctionName();
    
    if (self.isLocked == YES) return;
    
    if (aTap.state == UIGestureRecognizerStateRecognized)
    {
        if (self.isBarShowing) {
            [self ps_AnimateMenuBarHide];
        }
        else{
            
            [self ps_AnimateMenuBarShow];
        }
    }
}

- (void)ps_LockButtonClick:(UIButton*)sender
{
    sender.selected = !sender.selected;
    
    if (sender.selected)
    {
        self.isLocked = YES;
        [self ps_AnimateMenuBarHide];
    }else
    {
        self.isLocked = NO;
        [self ps_AnimateMenuBarShow];
    }
}

//播放状态
- (void)ps_PlaybackStatePlaying:(BOOL)isPlaying
{
    self.bottomBar.pauseButton.hidden = !isPlaying;
    self.bottomBar.playButton.hidden = isPlaying;
}

#pragma mark - public -
- (void)ps_PlayerControlHideModeView
{
    self.timeIndicatorView.hidden = YES;
    self.hud.hidden = YES;
    self.brightnessView.hidden = YES;
    self.volumeView.hidden = YES;
}

- (void)ps_ReloadTimeIndicatorPlay:(CGFloat)currentSecond
{
    self.currentSecond = currentSecond;
    self.timeIndicatorView.timeText = self.bottomBar.timeLabel.text;
}

- (void)ps_PlayerControlDidPlayVideo
{
    self.bottomBar.playButton.enabled = YES;
    self.bottomBar.progressSlider.enabled = YES;
    
    [self ps_PlaybackStatePlaying:YES];
    
    [self ps_PlayerStopLoadAnimating];
}

- (void)ps_PlayerControlDidPauseVideo
{
    self.bottomBar.progressSlider.enabled = NO;
    [self ps_PlaybackStatePlaying:NO];
}

- (void)ps_PlayerControlDidEndPlayVideo
{
    [self ps_PlaybackStatePlaying:NO];
    
    [self.bottomBar.progressSlider setValue:0.0 animated:YES];
    
    [self ps_ReloadTime:@"00:00"];
}

#pragma mark - animation -

- (void)ps_PlayerStartLoadAnimating
{
    [self ps_PlayerControlHideModeView];
    
    [self.hud ps_ShowHUD];
}

- (void)ps_PlayerStopLoadAnimating
{
    [self.hud ps_ShowHUD];
}


- (void)ps_AnimateMenuBarShow
{
    if (self.isBarShowing) return;
    
    [UIView animateWithDuration:0.25f animations:^{
        
        self.topBar.alpha = 1.0f;
        self.bottomBar.alpha = 1.0f;
        self.lockButton.alpha = 1.0f;
        
    } completion:^(BOOL finished) {
        
        self.isBarShowing = YES;
        
        //延迟3秒 ，动画消失，隐藏bar
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(ps_AnimateMenuBarHide) object:nil];
        [self performSelector:@selector(ps_AnimateMenuBarHide) withObject:nil afterDelay:3.0f];
    }];
}

- (void)ps_AnimateMenuBarHide
{
    if (!self.isBarShowing) return;
    
    [UIView animateWithDuration:0.25f animations:^{
        
        if (!self.isLocked) {
            self.lockButton.alpha = 0.0f;
        }
        self.topBar.alpha = 0.0f;
        self.bottomBar.alpha = 0.0f;
        
    } completion:^(BOOL finished) {
        
        self.isBarShowing = NO;
    }];
}

@end


