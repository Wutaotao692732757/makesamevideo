//
//  WTTabbarVC.m
//  MakeSmallVideo
//
//  Created by mac_w on 2016/12/6.
//  Copyright © 2016年 mac_wsdasd. All rights reserved.
//

#import "WTTabbarVC.h"
#import "CutterVideoVC.h"
#import "WTMakeSecondFlashViewController.h"
#import "WTNavigationVC.h"
#import "WTWaterMarkViewController.h"
#import "BeautifulFaceVC.h"


@interface WTTabbarVC ()

@end

@implementation WTTabbarVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CutterVideoVC *cutter=[[CutterVideoVC alloc]init];
  
    WTMakeSecondFlashViewController *adsVC=[[WTMakeSecondFlashViewController alloc]init];
    WTWaterMarkViewController *waterVC = [[WTWaterMarkViewController alloc]init];
    
    BeautifulFaceVC *beautifulVC = [[BeautifulFaceVC alloc] init];
   
    cutter.tabBarItem=[[UITabBarItem alloc]initWithTitle:@"剪切视频" image:[UIImage imageNamed:@"tab_icon_视频处理_h"] tag:0];

    adsVC.tabBarItem=[[UITabBarItem alloc]initWithTitle:@"制作视频" image:[UIImage imageNamed:@"tab_icon_制作广告_h"] tag:1];
    waterVC.tabBarItem=[[UITabBarItem alloc]initWithTitle:@"添加水印" image:[UIImage imageNamed:@"水印相机"] tag:2];
    beautifulVC.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"美颜" image:[UIImage imageNamed:@"beautifulFace"] tag:3];
    
    UINavigationBar *bar = [UINavigationBar appearance];
    
    //设置显示的颜色
    bar.barTintColor = [UIColor colorWithRed:0/255.0 green:111/255.0 blue:252/255.0 alpha:1.0];
    //设置字体颜色
    bar.tintColor = [UIColor whiteColor];
   
    [self addChildViewController:cutter];
    [self addChildViewController:adsVC];
    [self addChildViewController:waterVC];
    [self addChildViewController:beautifulVC];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}



@end
