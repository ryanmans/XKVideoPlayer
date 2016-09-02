//
//  PSMPMoviePlayerViewController.m
//  PSVideoPlayer
//
//  Created by Ryan_Man on 16/9/2.
//  Copyright © 2016年 Ryan_Man. All rights reserved.
//

#import "PSMPMoviePlayerViewController.h"
#import "PSMoviePlayerController.h"
#import "PSVideo.h"

@interface PSMPMoviePlayerViewController ()
@property (nonatomic,strong)PSMoviePlayerController * mpPlayerControl;

@end

@implementation PSMPMoviePlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.title = self.video.title;
    
    //添加视频播放器
    [self.view addSubview:self.mpPlayerControl];
    
    self.mpPlayerControl.video = self.video;
    
}

- (PSMoviePlayerController*)mpPlayerControl
{
    if (!_mpPlayerControl) {
        
        WeakSelf(ws);
        _mpPlayerControl = [[PSMoviePlayerController alloc] initWithFrame:CGRectMake(0, 0, KScreen_Width, HalfF(400))];
        
        _mpPlayerControl.onPlayerControlWillGoBackBlock = ^()
        {
            PSLog(@"back");
            
            
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
            
            [ws.navigationController popViewControllerAnimated:YES];
            [ws.navigationController setNavigationBarHidden:NO animated:YES];
            //
            ws.mpPlayerControl = nil;
            [ws.navigationController popViewControllerAnimated:YES];

        };
        
        _mpPlayerControl.onPlayerControlWillChangeToFullScreenModeBlock = ^()
        {
            PSLog(@"fullScreen");
        };
        
        _mpPlayerControl.onPlayerControlWillChangeToOriginalScreenModeBlock = ^()
        {
            
            PSLog(@"originalScreen");
        };
        
    }
    
    return _mpPlayerControl;
}




@end
