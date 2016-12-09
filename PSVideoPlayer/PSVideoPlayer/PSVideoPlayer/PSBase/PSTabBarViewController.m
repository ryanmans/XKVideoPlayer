//
//  PSTabBarViewController.m
//  PSVideoPlayer
//
//  Created by Ryan_Man on 16/8/26.
//  Copyright © 2016年 Ryan_Man. All rights reserved.
//

#import "PSTabBarViewController.h"
#import "PSMainViewController.h"
@interface PSTabBarViewController ()

@end

@implementation PSTabBarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    PSMainViewController * mainVC = NewClass(PSMainViewController);
    mainVC.tabBarItem.title = @"首页";
    mainVC.navigationItem.title = @"PSVideoPlayer";
    mainVC.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:(UITabBarSystemItemBookmarks) tag:0];
    
    UINavigationController * navigationVC = [[UINavigationController alloc] initWithRootViewController:mainVC];
    
    [self addChildViewController:navigationVC];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
