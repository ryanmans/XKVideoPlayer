//
//  PSAVPlayerViewController.m
//  PSVideoPlayer
//
//  Created by Ryan_Man on 16/9/2.
//  Copyright © 2016年 Ryan_Man. All rights reserved.
//

#import "PSAVPlayerViewController.h"

#import "PSAVPlayerController.h"

#import "PSVideo.h"
@interface PSAVPlayerViewController ()

@property (nonatomic,strong)PSAVPlayerController * avPlayerControl;
@end

@implementation PSAVPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = self.video.title;
    
    //添加视频播放器
    [self.view addSubview:self.avPlayerControl];
    
    self.avPlayerControl.video = self.video;
    
}

- (PSAVPlayerController*)avPlayerControl
{
    if (!_avPlayerControl) {
        
        WeakSelf(ws);
        _avPlayerControl = [[PSAVPlayerController alloc] initWithFrame:CGRectMake(0, 0, KScreen_Width, HalfF(400))];
        
        _avPlayerControl.onPlayerControlWillGoBackBlock = ^()
        {
            PSLog(@"back");
            
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
            
            [ws.navigationController popViewControllerAnimated:YES];
            [ws.navigationController setNavigationBarHidden:NO animated:YES];
//            
            ws.avPlayerControl = nil;
            [ws.navigationController popViewControllerAnimated:YES];

        };
        
        _avPlayerControl.onPlayerControlWillChangeToFullScreenModeBlock = ^()
        {
            PSLog(@"fullScreen");
        };
        
        _avPlayerControl.onPlayerControlWillChangeToOriginalScreenModeBlock = ^()
        {
            
            PSLog(@"originalScreen");
        };
        
    }
    
    return _avPlayerControl;
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    
    
}
@end
