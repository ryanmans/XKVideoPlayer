//
//  PSMoviePlayer.h
//  PSVideoPlayer
//
//  Created by Ryan_Man on 16/9/2.
//  Copyright © 2016年 Ryan_Man. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

#import "PSVideo.h"
typedef NS_ENUM(NSUInteger, PSMoviePlayerState)
{
    PSMoviePlayerState_PlaybackState = 0,
    PSMoviePlayerState_LoadState,
    PSMoviePlayerState_ReadyForDisplay ,
    PSMoviePlayerState_Available ,
    
};

@interface PSMoviePlayer : MPMoviePlayerController
@property (nonatomic,assign)CGRect frame;

@property (nonatomic,copy)void (^onMoviePlayerStateBlock)(PSMoviePlayerState state);
@property (nonatomic,strong,readonly)PSVideo * video;

// 系统音量slider
@property (nonatomic, strong,readonly) UISlider *volumeViewSlider;

//初始化
- (instancetype)initWithFrame:(CGRect)frame;

//数据刷新
- (void)ps_ReloadData:(PSVideo*)video;

@end
