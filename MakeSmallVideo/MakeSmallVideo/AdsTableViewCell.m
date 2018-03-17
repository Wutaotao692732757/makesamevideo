//
//  AdsTableViewCell.m
//  MakeSmallVideo
//
//  Created by wutaotao on 2017/2/7.
//  Copyright © 2017年 mac_wsdasd. All rights reserved.
//

#import "AdsTableViewCell.h"

@implementation AdsTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    
        _bgImageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, ScreenW, 186)];
        [self addSubview:_bgImageView];
        
        _maskImageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, ScreenW, 186)];
        _maskImageView.alpha=0.8;
        [self addSubview:_maskImageView];
        
        _tipsImageView=[[UIImageView alloc]initWithFrame:CGRectMake((ScreenW-137)*0.5, (186-37)*0.5, 137, 37)];
        [self addSubview:_tipsImageView];
    }
    
    return self;
}


@end
