//
//  WTAdsViewController.m
//  MakeSmallVideo
//
//  Created by mac_w on 2016/12/6.
//  Copyright © 2016年 mac_wsdasd. All rights reserved.
//

#import "WTAdsViewController.h"
#import "WTMakeSecondFlashViewController.h"
#import "NetSourceViewController.h"
#import "AdsTableViewCell.h"

@interface WTAdsViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)UITableView *tabView;
@property(nonatomic,strong)NSMutableArray *dataArr;

@end

@implementation WTAdsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.text=@"制作广告";
    titleLabel.textColor=[UIColor whiteColor];
    titleLabel.font=[UIFont systemFontOfSize:18];
    titleLabel.textAlignment=NSTextAlignmentCenter;
    self.navigationItem.titleView=titleLabel;
    self.view.backgroundColor=[UIColor redColor];
     [self.view addSubview:self.tabView];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 186;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    AdsTableViewCell * cell=[tableView dequeueReusableCellWithIdentifier:@"water"];
    if (cell==nil) {
        cell=[[AdsTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"water"];
        
        switch (indexPath.row) {
            case 2:
                cell.bgImageView.image=[UIImage imageNamed:@"img_1今日热门视频"];
                cell.maskImageView.image=[UIImage imageNamed:@"img_1今日热门视频透明图层"];
                cell.tipsImageView.image=[UIImage imageNamed:@"icon_今日热门视频"];
                break;
            case 1:
                cell.bgImageView.image=[UIImage imageNamed:@"img_2经典素材"];
                cell.maskImageView.image=[UIImage imageNamed:@"img_2经典素材透明图层"];
                cell.tipsImageView.image=[UIImage imageNamed:@"icon_经典素材"];
                break;
            case 0:
                cell.bgImageView.image=[UIImage imageNamed:@"img_3制作快闪视频"];
                cell.maskImageView.image=[UIImage imageNamed:@"img_3制作快闪视频透明图层"];
                cell.tipsImageView.image=[UIImage imageNamed:@"icon_制作快闪视频"];
                break;
                
            default:
                break;
        }
        
        
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0) {
        WTMakeSecondFlashViewController *secondflashVC=[[WTMakeSecondFlashViewController alloc]init];
        [self.navigationController pushViewController:secondflashVC animated:YES];
    }else{
        
        NetSourceViewController *netSourceVC=[[NetSourceViewController alloc]init];
        
         [self.navigationController pushViewController:netSourceVC animated:YES];
        
    }
}



-(UITableView *)tabView{
    
    if (_tabView==nil) {
        _tabView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        _tabView.delegate=self;
        _tabView.dataSource=self;
    }
    return _tabView;
}
-(NSMutableArray *)dataArr{
    
    if (_dataArr==nil) {
        _dataArr=[NSMutableArray arrayWithObjects:@"制作自己的快闪视频",@"今日网络视频库",@"经典视频素材",nil];
    }
    return _dataArr;
}



@end
