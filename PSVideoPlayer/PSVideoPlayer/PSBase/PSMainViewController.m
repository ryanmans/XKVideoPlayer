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
@interface PSMainViewController ()<UIActionSheetDelegate>
@property(nonatomic,strong)PSVideo * video;
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
    self.video = NewClass(PSVideo);
     self.video.playUrl = videoURL.absoluteString;
     self.video.title = @"Local Movie";
    
    [self showActionSheet];

}

- (void)playNetVideo
{
    self.video = [[PSVideo alloc] init];
    self.video.playUrl = @"http://baobab.wdjcdn.com/1451897812703c.mp4";
    self.video.title = @"Rollin'Wild 圆滚滚的";

    [self showActionSheet];
}

- (void)showActionSheet
{
    UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"Use MPMoviePlayer",@"Use AVPlayer", nil];
    [sheet showInView:self.view];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [actionSheet removeFromSuperview];
    
    if (buttonIndex == 0 ) {
        
        PSMPMoviePlayerViewController * movieVC = NewClass(PSMPMoviePlayerViewController);
        movieVC.video = self.video;
        movieVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:movieVC animated:YES];

    }else if (buttonIndex == 1)
    {
        
        PSAVPlayerViewController * movieVC = NewClass(PSAVPlayerViewController);
        movieVC.video = self.video;
        movieVC.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:movieVC animated:YES];
    }
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
