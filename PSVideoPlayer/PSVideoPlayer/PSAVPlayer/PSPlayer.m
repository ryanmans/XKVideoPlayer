//
//  PSPlayer.m
//  PSVideoPlayer
//
//  Created by Ryan_Man on 16/9/2.
//  Copyright © 2016年 Ryan_Man. All rights reserved.
//

#import "PSPlayer.h"

@interface PSPlayer ()
@property (nonatomic,strong)AVPlayer * player;
@property (nonatomic,strong)AVPlayerItem * playerItem;
@end

@implementation PSPlayer

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}

+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

- (AVPlayer*)player
{
    return [(AVPlayerLayer*)[self layer] player];
}

- (void)setPlayer:(AVPlayer *)player
{
    [(AVPlayerLayer*)[self layer] setPlayer:player];
}

- (void)dealloc
{
    [self ps_ReleaseSubObject];
}

//释放或移除子对象
- (void)ps_ReleaseSubObject
{
    
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    
    [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    
    self.playerItem = nil;
    
    self.player = nil;
    
    ps_RemovePost(self, nil);
}

#pragma mark - public -

- (void)ps_ReloadData:(PSVideo *)video
{
    _video = video;
    
    if (_video == nil || _video.playUrl.length == 0)
    {
        [self ps_ReleaseSubObject];
        
        return;
    }
    
    //播放器
    self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:_video.playUrl]];

    //当status等于AVPlayerStatusReadyToPlay时代表视频已经可以播放了，我们就可以调用play方法播放了
    
    //loadedTimeRange属性代表已经缓冲的进度，监听此属性可以在UI中更新缓冲进度，也是很有用的一个属性。
    
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];

    
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    
    ps_AddPost(self, @selector(videoPlayDidEnd:), AVPlayerItemDidPlayToEndTimeNotification);

}

- (void)ps_PlayerVolumeSeting:(CGFloat)value
{

    //音量在0 － 1区间取值
    if (value > 1.0)value = 1.0f;
    else if (value <0.0)value = 0.0f;
    
    
    NSArray * temp = [self.playerItem.asset tracksWithMediaType:AVMediaTypeAudio];
    
    NSMutableArray * audioParams = NewMutableArray();
    
    for (AVAssetTrack * track in temp)
    {
        
        AVMutableAudioMixInputParameters * audioInputParams = [AVMutableAudioMixInputParameters audioMixInputParameters];
        
        [audioInputParams setVolume:value atTime:kCMTimeZero];
        
        [audioInputParams setTrackID:[track trackID]];
        
        [audioParams addObject:audioInputParams];
    }
    
    AVMutableAudioMix * audioMix = [AVMutableAudioMix audioMix];
    
    [audioMix setInputParameters:audioParams];
    
    [self.playerItem setAudioMix:audioMix];
}



#pragma mark - -

//kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    PSLog(@"keyPath --- %@",keyPath);
    
    if (self.onPlayerStatusBlock) {
        self.onPlayerStatusBlock(keyPath,self.playerItem);
    }
}

//视频播放结束
- (void)videoPlayDidEnd:(NSNotification*)noti
{
    if (self.onPlayerDidEndBlock) {
        self.onPlayerDidEndBlock (noti);
    }
}

@end
