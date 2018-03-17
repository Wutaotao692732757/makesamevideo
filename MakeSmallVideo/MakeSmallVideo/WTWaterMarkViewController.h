//
//  WTWaterMarkViewController.h
//  MakeSmallVideo
//
//  Created by mac_w on 2016/12/14.
//  Copyright © 2016年 mac_wsdasd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "AVSEAddWatermarkCommand.h"
#import "AVSEExportCommand.h"

@interface WTWaterMarkViewController : UIViewController{
    AVSEExportCommand *exportCommand;
}


@end
