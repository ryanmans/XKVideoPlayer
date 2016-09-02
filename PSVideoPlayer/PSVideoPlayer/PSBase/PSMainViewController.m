//
//  PSMainViewController.m
//  PSVideoPlayer
//
//  Created by Ryan_Man on 16/8/26.
//  Copyright © 2016年 Ryan_Man. All rights reserved.
//

#import "PSMainViewController.h"
#import "PSVideo.h"

#import "PSMPMoviePlayerViewController.h"
#import "PSAVPlayerViewController.h"
@interface PSMainViewController ()

@end

@implementation PSMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSArray * menus = @[@"Play Local Video",@"Play Net Video"];
    
    for (int index = 0 ; index < menus.count; index ++)
    {
        
        UIButton * button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.backgroundColor = [UIColor whiteColor];
        button.tag = index;
        button.width = HalfF(300);
        button.height = HalfF(100);
        button.x = (KScreen_Width - button.width)/ 2;
        button.y = HalfF(300) + (button.height + HalfF(40)) * index;
        [button setTitle:menus[index] forState:(UIControlStateNormal)];
        [button setTitleColor:RGB(37, 177, 232) forState:(UIControlStateNormal)];
        [button addTarget:self action:@selector(clickEvent:) forControlEvents:(UIControlEventTouchUpInside)];
        [self.view addSubview:button];
        
    }
}

- (void)clickEvent:(UIButton*)sender
{
    LogFunctionName();

    if (sender.tag == 0) [self playLocalVideo];
    else if (sender.tag == 1)[self playNetVideo];
    
}

- (void)playLocalVideo
{
    
    NSURL *videoURL = [[NSBundle mainBundle] URLForResource:@"150511_JiveBike" withExtension:@"mov"];
    PSVideo *video = NewClass(PSVideo);
    video.playUrl = videoURL.absoluteString;
    video.title = @"local";
    
    PSMPMoviePlayerViewController * movieVC = NewClass(PSMPMoviePlayerViewController);
    movieVC.video = video;
    movieVC.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:movieVC animated:YES];
    
}

- (void)playNetVideo
{
//    NSURL *videoURL = [[NSBundle mainBundle] URLForResource:@"150511_JiveBike" withExtension:@"mov"];
//    PSVideo *video = NewClass(PSVideo);
//    video.playUrl = videoURL.absoluteString;
//    video.title = @"local";
    
    PSVideo *video = [[PSVideo alloc] init];
    video.playUrl = @"http://baobab.wdjcdn.com/1451897812703c.mp4";
    video.title = @"Rollin'Wild 圆滚滚的";

    PSAVPlayerViewController * movieVC = NewClass(PSAVPlayerViewController);
    movieVC.video = video;
    movieVC.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:movieVC animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
