//
//  PSAVPlayerController.h
//  PSVideoPlayer
//
//  Created by Ryan_Man on 16/9/2.
//  Copyright © 2016年 Ryan_Man. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSVideo.h"

//视频播放器
@interface PSPlayerController : UIView

//视频对象
@property (nonatomic,strong)PSVideo * video;

//TOP栏隐藏模式
@property(nonatomic,assign)BOOL isNaiBarHidenMode;

//放回
@property (nonatomic,copy) void (^onPlayerControlWillGoBackBlock)();

// 将要切换到竖屏模式
@property (nonatomic, copy) void(^onPlayerControlWillChangeToOriginalScreenModeBlock)();

// 将要切换到全屏模式
@property (nonatomic, copy) void(^onPlayerControlWillChangeToFullScreenModeBlock)();
@end
