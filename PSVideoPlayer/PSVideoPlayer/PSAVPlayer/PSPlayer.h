//
//  PSPlayer.h
//  PSVideoPlayer
//
//  Created by Ryan_Man on 16/9/2.
//  Copyright © 2016年 Ryan_Man. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "PSVideo.h"

@interface PSPlayer : UIView
@property (nonatomic,strong,readonly)AVPlayer * player;
@property (nonatomic,strong,readonly)PSVideo * video;


//监听播放状态
@property (nonatomic,copy)void (^onPlayerStatusBlock)(NSString * keyPath ,AVPlayerItem * playerItem);

//播发结束消息通知
@property (nonatomic,copy)void (^onPlayerDidEndBlock)(NSNotification * notification);

//数据刷新
- (void)ps_ReloadData:(PSVideo*)video;

//播放器音量设置
- (void)ps_PlayerVolumeSeting:(CGFloat)value;


@end
