//
//  PSAVPlayerViewController.m
//  PSVideoPlayer
//
//  Created by Ryan_Man on 16/9/2.
//  Copyright © 2016年 Ryan_Man. All rights reserved.
//

#import "PSAVPlayerViewController.h"
#import "PSPlayerController.h"

#import "PSVideo.h"
@interface PSAVPlayerViewController ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>
{
    UIAlertView * _alertView;
    
}
@property (nonatomic,assign)BOOL isNaiBarHidenMode;
@property (nonatomic,strong)UITableView * displayTableView;
@property (nonatomic,strong)UIButton * tableHeaderView;
@property (nonatomic,strong)PSPlayerController * avPlayerControl;
@end

@implementation PSAVPlayerViewController

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

- (UIButton*)tableHeaderView
{
    if (!_tableHeaderView) {
        
        _tableHeaderView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, KScreen_Width, HalfF(400))];
        
        _tableHeaderView.backgroundColor = Arc4randomColor;
        
        [_tableHeaderView setTitle:@"点我播放" forState:(UIControlStateNormal)];
        
        [_tableHeaderView setTitleColor:[UIColor redColor] forState:(UIControlStateNormal)];
        
        [_tableHeaderView addTarget:self action:@selector(createPlayer:) forControlEvents:(UIControlEventTouchUpInside)];
        
    }
    return _tableHeaderView;
}

- (PSPlayerController*)avPlayerControl
{
    if (! _avPlayerControl) {
        
        WeakSelf(ws);
        _avPlayerControl = [[PSPlayerController alloc] initWithFrame:CGRectMake(0, 0, KScreen_Width, HalfF(400))];
        _avPlayerControl.onPlayerControlWillGoBackBlock = ^()
        {
            PSLog(@"点击 返回");
            [ws ps_PlayerButtonClick];
        };
        _avPlayerControl.onPlayerControlWillChangeToFullScreenModeBlock = ^()
        {
            PSLog(@"点击全屏");
            
            [ws ps_PlayerFullScreenClick];
            
        };
        _avPlayerControl.onPlayerControlWillChangeToOriginalScreenModeBlock = ^()
        {
            PSLog(@"点击原屏");
            
            [ws ps_PlayerOriginalScreenClick];
            
        };
        
    }
    
    return _avPlayerControl;
}

//列举了两种模式结合

//模式1 : 单独播放器控件，且导航栏隐藏。
//模式2 : 和tableview 列表结合 ，且导航栏不隐藏(如果 和 tableview 结合，且在正常模式下要隐藏导航栏 ，需考虑statusbar的影响，可处理tableview 的contentInset,但全屏模式下需注意)；

     //注意点： 如果使用整个设备的旋转适配，等同的，其他的视图也要做旋转适配，不单单只有视频播放器，这样子工作量就大了，UI布局简单样式时，可采用。
//还可以选择一种方式，只是单单的做视频的旋转动画，只需要控制视频播放器的旋转，进行相关调整就可以了，这种情况，必须考虑监听设备旋转通知，不然会重复旋转。

//MARK:模式1
- (void)ps_AlonePlayer
{
    if ([NSThread isMainThread] == NO) {
        
        runBlockWithMain(^{
            
            [self ps_AlonePlayer];
        });
        
        return;
    }
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    self.isNaiBarHidenMode = YES;
    [self.view addSubview:self.avPlayerControl];
    self.avPlayerControl.video = self.video;
    
    self.avPlayerControl.isNaiBarHidenMode = self.isNaiBarHidenMode;
    
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
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    self.isNaiBarHidenMode = NO;
    
    [self.view addSubview:self.displayTableView];
    
    self.displayTableView.tableHeaderView = self.tableHeaderView;
    
}

//创建播放器
- (void)createPlayer:(UIButton*)sender
{
    
    self.avPlayerControl.video = self.video;
    
    self.avPlayerControl.isNaiBarHidenMode = self.isNaiBarHidenMode;

    [self.displayTableView addSubview:self.avPlayerControl];
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
    
    //2.
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
        [self.navigationController setNavigationBarHidden:NO animated:NO];
        
        return;
    }

    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    //2.
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    
    
}
@end
