//
//  XKPlayer.h
//  XKPharmacy
//
//  Created by RyanMans on 16/12/8.
//  Copyright © 2016年 P.S. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "XKVideo.h"

@interface XKPlayer : UIView
@property (nonatomic,strong,readonly)AVPlayer * player;
@property (nonatomic,strong,readonly)XKVideo * video;

//监听播放状态
@property (nonatomic,copy)void (^onPlayerStatusBlock)(NSString * keyPath ,AVPlayerItem * playerItem);

//播发结束消息通知
@property (nonatomic,copy)void (^onPlayerDidEndBlock)(NSNotification * notification);

//数据刷新
- (void)ps_ReloadData:(XKVideo*)video;

//播放器音量设置
- (void)ps_PlayerVolumeSeting:(CGFloat)value;
@end
