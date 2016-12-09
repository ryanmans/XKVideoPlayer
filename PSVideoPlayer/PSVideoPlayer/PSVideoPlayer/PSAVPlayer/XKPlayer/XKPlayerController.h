//
//  XKPlayerController.h
//  XKPharmacy
//
//  Created by RyanMans on 16/12/8.
//  Copyright © 2016年 P.S. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XKVideo.h"

//视频播放器
@interface XKPlayerController : UIView

//视频对象
@property (nonatomic,strong)XKVideo * video;

//TOP栏隐藏模式
@property(nonatomic,assign)BOOL isNaiBarHidenMode;

//返回
@property (nonatomic,copy) void (^onPlayerControlWillGoBackBlock)();

// 将要切换到竖屏模式
@property (nonatomic, copy) void(^onPlayerControlWillChangeToOriginalScreenModeBlock)();

// 将要切换到全屏模式
@property (nonatomic, copy) void(^onPlayerControlWillChangeToFullScreenModeBlock)();
@end
