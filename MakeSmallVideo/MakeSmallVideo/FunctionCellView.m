//
//  FunctionCellView.m
//  MakeSmallVideo
//
//  Created by wutaotao on 2017/2/6.
//  Copyright © 2017年 mac_wsdasd. All rights reserved.
//

#import "FunctionCellView.h"

@implementation FunctionCellView

-(instancetype)initWithFrame:(CGRect)frame{
    
    if (self=[super initWithFrame:frame]) {
        
        _bgImageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 130*(ScreenH/667.0), 125*(ScreenH/667.0))];
        [self addSubview:_bgImageView];
        _maskImageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 130*(ScreenH/667.0), 125*(ScreenH/667.0))];
        _maskImageView.alpha=0.6;
        [self addSubview:_maskImageView];
        
        _line1=[[UIImageView alloc]initWithFrame:CGRectMake(31, 45*(ScreenH/667.0), 68*(ScreenH/667.0), 1)];
        _line2=[[UIImageView alloc]initWithFrame:CGRectMake(31, 80*(ScreenH/667.0), 68*(ScreenH/667.0), 1)];
        _line1.backgroundColor=[UIColor whiteColor];
        _line1.alpha=0.9;
        _line2.backgroundColor=[UIColor whiteColor];
        _line2.alpha=0.9;
        [self addSubview:_line1];
        [self addSubview:_line2];
        
        _nameLabel=[[UILabel alloc]initWithFrame:CGRectMake(31, 48*(ScreenH/667.0), 68*(ScreenH/667.0), 30)];
        _nameLabel.font=[UIFont systemFontOfSize:15];
        if (ScreenH<667) {
            _nameLabel.font=[UIFont systemFontOfSize:13];
        }
        _nameLabel.alpha=0.8;
        _nameLabel.textColor=[UIColor whiteColor];
        [self addSubview:_nameLabel];
        
        _tipsLabel=[[UILabel alloc]initWithFrame:CGRectMake(15, 137*(ScreenH/667.0), 100*(ScreenH/667.0), 15)];
        [self addSubview:_tipsLabel];
        
        _englishTipsLabel=[[UILabel alloc]initWithFrame:CGRectMake(15, 157*(ScreenH/667.0), 115*(ScreenH/667.0), 15)];
        _englishTipsLabel.font=[UIFont systemFontOfSize:10];
        
        _showVCButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 130*(ScreenH/667.0), 125*(ScreenH/667.0))];
        [self addSubview:_showVCButton];
        
        [self addSubview:_englishTipsLabel];
        
        
    }
    return self;
}

@end
