//
//  XKPlayerControlView.h
//  XKPharmacy
//
//  Created by RyanMans on 16/12/8.
//  Copyright © 2016年 P.S. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XKVideo.h"

//控件点击
typedef NS_ENUM(NSInteger , PSPlayerControlClickState)
{
    PSPlayerControlClickState_Back = 0, //返回
    
    PSPlayerControlClickState_Collect , //收藏
    
    PSPlayerControlClickState_UnCollect , //cancel收藏
    
    PSPlayerControlClickState_Lock,  //锁屏
    
    PSPlayerControlClickState_UnLock,  //解屏
    
    PSPlayerControlClickState_Play, //播放
    
    PSPlayerControlClickState_Pause, //暂停
    
    PSPlayerControlClickState_FullScreen, //全屏
    
    PSPlayerControlClickState_ShrinkScreen, //缩小屏幕
    
    PSPlayerControlClickState_SliderTouchBegan,
    
    PSPlayerControlClickState_SliderTouchChangeValue,
    
    PSPlayerControlClickState_SliderTouchEnd
    
};

//快进、快退指示器
typedef NS_ENUM(NSUInteger, PSTimeIndicatorPlayState)
{
    PSTimeIndicatorPlayStateRewind,      // rewind
    PSTimeIndicatorPlayStateFastForward, // fast forward
};

//代理
@class XKPlayerControlView;
@protocol PSPlayerControlDelegate <NSObject>

@optional

//操作菜单 ，状态回调
- (void)ps_PlayerControlView:(XKPlayerControlView*)playerControl withClickState:(PSPlayerControlClickState)state;

@end


//播放器上的操作菜单
@interface XKPlayerControlView : UIView
@property (nonatomic,weak)id<PSPlayerControlDelegate>delegate;

//导航栏模式
@property (nonatomic,assign)BOOL isNaviBarHideMode;

@property (nonatomic,strong)XKVideo * video;

// 是否已经全屏模式
@property (nonatomic, assign) BOOL isFullscreenMode;

//是否锁屏
@property (nonatomic, assign,readonly) BOOL isLocked;

//bar state
@property (nonatomic,assign,readonly)BOOL isBarShowing;

//状态
@property (nonatomic,assign)PSTimeIndicatorPlayState timePlayState;

//视频总时长
@property (nonatomic,assign)CGFloat totalSecond;

//正在播放的当前时长
@property (nonatomic,assign)CGFloat currentSecond;

// 缓存进度
@property (nonatomic,assign)CGFloat bufferSecond;

//拖动
@property (nonatomic,assign,readonly)CGFloat changeValue;


//快进 或者后退指示图刷新
- (void)ps_ReloadTimeIndicatorPlay:(CGFloat)currentSecond;

//播放器隐藏 所有模态视图
- (void)ps_PlayerControlHideModeView;

//bar show
- (void)ps_AnimateMenuBarShow;

//bar hide
- (void)ps_AnimateMenuBarHide;

//开始加载动画
- (void)ps_PlayerStartLoadAnimating;

//停止加载动画
- (void)ps_PlayerStopLoadAnimating;

#pragma mark - 视频播放 -
//正在播放
- (void)ps_PlayerControlDidPlayVideo;

//暂停播放
- (void)ps_PlayerControlDidPauseVideo;

//结束播放
- (void)ps_PlayerControlDidEndPlayVideo;
@end
