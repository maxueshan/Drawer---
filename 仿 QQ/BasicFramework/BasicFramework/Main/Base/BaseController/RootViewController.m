//
//  RootViewController.m
//  Dome
//
//  Created by Rainy on 16/8/18.
//  Copyright © 2016年 Rainy. All rights reserved.
//

#import "RootViewController.h"
#import "LYLMenuView.h"
#import "LYLLateralSpreadsMenu.h"

@interface RootViewController ()
{
    LYLLateralSpreadsMenu *_sideSlipView;
}
@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self layoutSubviews];
    [self layoutLateralSpreadsMenu];
    
}
-(void)layoutSubviews
{
    UIImageView *imgV = [[UIImageView alloc]initWithFrame:self.view.bounds];
    imgV.image = [UIImage imageNamed:@"backView.jpg"];
    [self.view addSubview:imgV];
    
    
    UIButton *bt = [UIButton buttonWithType:UIButtonTypeSystem];
    bt.frame = CGRectMake(0, 0, 20, 20);
    [bt setBackgroundImage:[UIImage imageNamed:@"shouye"] forState:UIControlStateNormal];
    [bt addTarget:self action:@selector(switchTouched:) forControlEvents:UIControlEventTouchUpInside];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:bt];
    
    
    
    UIButton *btnaaa = [UIButton buttonWithType:UIButtonTypeSystem];
    btnaaa.frame = CGRectMake(110, 110, 120, 120);
    btnaaa.backgroundColor = [UIColor redColor];
    [btnaaa addTarget:self action:@selector(switchTouched:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:btnaaa];
    
    
    
}
-(void)layoutLateralSpreadsMenu
{
    _sideSlipView = [[LYLLateralSpreadsMenu alloc]initWithController:self];
    
    LYLMenuView *menu = [LYLMenuView menuView];
    [menu didSelectRowAtIndexPath:^(id cell, NSIndexPath *indexPath) {
        NSLog(@"click %ld",indexPath.row);
        [_sideSlipView hide];
    }];
    menu.items = @[@{@"title":@"相册",@"imagename":@"shoujihao"},@{@"title":@"资料",@"imagename":@"shoujihao"},@{@"title":@"任务",@"imagename":@"shoujihao"},@{@"title":@"其它",@"imagename":@"shoujihao"}];
    
    [_sideSlipView setContentView:menu];//contentView
    //如果不是UINavigationController
//    [self.view addSubview:_sideSlipView];
    [kWindow addSubview:_sideSlipView];  //关键,添加到 keyWindow上,在最上层
}
- (void)switchTouched:(id)sender {
    
    [_sideSlipView switchMenu];
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
