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

@interface PSMPMoviePlayerViewController ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>
{
    UIAlertView * _alertView;
    
}
@property (nonatomic,assign)BOOL isNaiBarHidenMode;
@property (nonatomic,strong)UITableView * displayTableView;
@property (nonatomic,strong)PSMoviePlayerController * mpPlayerControl;

@end

@implementation PSMPMoviePlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = self.video.title;
    
    _alertView = [[UIAlertView alloc] initWithTitle:@"Select Demo Mode" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"模式1",@"模式2", nil];
    [_alertView show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [alertView removeFromSuperview];
    
    if (buttonIndex == 0) {
        [self ps_AlonePlayer];
    }else if (buttonIndex == 1)
    {
        [self ps_PlayerCombineTableView];
    }
}

//列举了两种模式结合

//模式1 : 单独播放器控件，且导航栏隐藏。
//模式2 : 和tableview 列表结合 ，且导航栏不隐藏(如果 和 tableview 结合，且在正常模式下要隐藏导航栏 ，需考虑statusbar的影响，可处理tableview 的contentInset,但全屏模式下需注意)；

//MARK:模式1
- (void)ps_AlonePlayer
{
    if ([NSThread isMainThread] == NO) {
        
        runBlockWithMain(^{
            
            [self ps_AlonePlayer];
        });
        
        return;
    }
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    self.isNaiBarHidenMode = YES;
    [self.view addSubview:self.mpPlayerControl];
    self.mpPlayerControl.video = self.video;
    
    self.mpPlayerControl.isNaiBarHidenMode = self.isNaiBarHidenMode;
    
}

//MARK:模式2
- (void)ps_PlayerCombineTableView
{
    if ([NSThread isMainThread] == NO) {
        
        runBlockWithMain(^{
            
            [self ps_PlayerCombineTableView];
        });
        
        return;
    }
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    self.isNaiBarHidenMode = NO;
    
    [self.view addSubview:self.displayTableView];
    
    self.displayTableView.tableHeaderView = self.mpPlayerControl;
    
    self.mpPlayerControl.video = self.video;
    
    self.mpPlayerControl.isNaiBarHidenMode = self.isNaiBarHidenMode;
    
    
}

- (UITableView*)displayTableView
{
    if (!_displayTableView) {
        _displayTableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        _displayTableView.delegate = self;
        _displayTableView.dataSource = self;
        _displayTableView.showsVerticalScrollIndicator = NO;
    }
    
    return _displayTableView;
}

- (PSMoviePlayerController*)mpPlayerControl
{
    if (! _mpPlayerControl) {
        
        WeakSelf(ws);
        _mpPlayerControl = [[PSMoviePlayerController alloc] initWithFrame:CGRectMake(0, 0, KScreen_Width, HalfF(400))];
        _mpPlayerControl.onPlayerControlWillGoBackBlock = ^()
        {
            PSLog(@"点击 返回");
            [ws ps_PlayerButtonClick];
        };
        _mpPlayerControl.onPlayerControlWillChangeToFullScreenModeBlock = ^()
        {
            PSLog(@"点击全屏");
            
            [ws ps_PlayerFullScreenClick];
            
        };
        _mpPlayerControl.onPlayerControlWillChangeToOriginalScreenModeBlock = ^()
        {
            PSLog(@"点击原屏");
            
            [ws ps_PlayerOriginalScreenClick];
            
        };
        
    }
    
    return _mpPlayerControl;
}

//返回( 原屏、全屏两种模式下返回 )
- (void)ps_PlayerButtonClick
{
    //主线程下
    if ([NSThread isMainThread] == NO)
    {
        runBlockWithMain(^{
            
            [self ps_PlayerButtonClick];
        });
        return;
    }
    if (self.isNaiBarHidenMode)
    {
        //模式1
        [self.navigationController setNavigationBarHidden:NO animated:NO];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        
        [self.navigationController popViewControllerAnimated:YES];
        
        return;
    }
    
    //模式2(只有全屏下 ，显示返回按钮，已内部处理方法，无需再处理)
    
}

//全屏
- (void)ps_PlayerFullScreenClick
{
    if ([NSThread isMainThread] == NO)
    {
        runBlockWithMain(^{
            
            [self ps_PlayerFullScreenClick];
        });
        return;
    }
    
    if (self.isNaiBarHidenMode)
    {
        //模式1
        [self.navigationController setNavigationBarHidden:YES animated:NO];
        
        return;
    }
    
    //模式2(同时调整player 父视图 frame。无需去改变指针地址。此时修改父视图 frame.指针 也是指向同一个对象)
    
    //1.
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    //2.全屏下父视图 调整 frame
    self.displayTableView.frame = self.view.bounds;
    self.displayTableView.scrollEnabled = NO;
    
}

//原屏
- (void)ps_PlayerOriginalScreenClick
{
    if ([NSThread isMainThread] == NO)
    {
        runBlockWithMain(^{
            
            [self ps_PlayerOriginalScreenClick];
        });
        return;
    }
    
    if (self.isNaiBarHidenMode)
    {
        //模式1
        [self.navigationController setNavigationBarHidden:YES animated:NO];
        
        return;
    }
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    //2.全屏下父视图 调整 frame
    self.displayTableView.frame = self.view.bounds;
    self.displayTableView.scrollEnabled = YES;
    
}

#pragma mark - tableView -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentity = @"defaultCellId";
    
    UITableViewCell * defaultCell = [tableView dequeueReusableCellWithIdentifier:cellIdentity];
    
    if (!defaultCell) {
        defaultCell  = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:cellIdentity];
    }
    
    defaultCell.textLabel.text = [NSString stringWithFormat:@"cell -- %ld",indexPath.row];
    return defaultCell;
}



@end
