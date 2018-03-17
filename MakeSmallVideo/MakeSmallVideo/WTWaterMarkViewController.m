//
//  WTWaterMarkViewController.m
//  MakeSmallVideo
//
//  Created by mac_w on 2016/12/14.
//  Copyright © 2016年 mac_wsdasd. All rights reserved.
//

#import "WTWaterMarkViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface WTWaterMarkViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextFieldDelegate>

@property(nonatomic,strong)UIImageView *videoImg;


@property(nonatomic,strong)UITextField *textMark;
@property(nonatomic,strong)UIImageView *imgMark;

//选择视频按钮
@property(nonatomic,strong)UIButton *selecVideoButton;
//选择图片按钮
@property(nonatomic,strong)UIButton *selecPicButton;
//保存按钮
@property(nonatomic,strong)UIButton *saveAndoutButton;

@property(nonatomic,strong)NSURL *sourceVideoURL;


@property(nonatomic,strong)AVSEAddWatermarkCommand *watermarkCommand;

@property(nonatomic,strong)UIButton *selectedButton;
@property AVMutableComposition *composition;
@property AVMutableVideoComposition *videoComposition;
@property AVMutableAudioMix *audioMix;
@property AVAsset *inputAsset;
@property CALayer *watermarkLayer;

@property(nonatomic,strong)NSMutableArray *btnArr;
//对号标志
@property(nonatomic,strong)UIImageView *selectedLogo;

//返回按钮
@property(nonatomic,strong)UIButton *backButton;

@property(nonatomic,assign) NSInteger selectedCount;


@end

@implementation WTWaterMarkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.videoImg];
    [self.view addSubview:self.textMark];
    [self.view addSubview:self.imgMark];
    
    [self.view addSubview:self.selecVideoButton];
    [self.view addSubview:self.selecPicButton];
    [self.view addSubview:self.saveAndoutButton];
    
    
    self.view.backgroundColor=[UIColor whiteColor];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(editCommandCompletionNotificationReceiver:)
                                                 name:AVSEEditCommandCompletionNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backToPrefer) name:@"savesuccess" object:nil];
    
     _btnArr=[NSMutableArray array];

}


-(void)backToPrefer{
    
    [SVProgressHUD showSuccessWithStatus:@"Saving success , You Can See In Your Phone Library"];
  
}


- (void)editCommandCompletionNotificationReceiver:(NSNotification*) notification
{
    if ([[notification name] isEqualToString:AVSEEditCommandCompletionNotification]) {
        // Update the document's composition, video composition etc
        self.composition = [[notification object] mutableComposition];
        self.videoComposition = [[notification object] mutableVideoComposition];
        self.audioMix = [[notification object] mutableAudioMix];
        if([[notification object] watermarkLayer])
            self.watermarkLayer = [[notification object] watermarkLayer];
        dispatch_async( dispatch_get_main_queue(), ^{
            
            [self exportWillBegin];
            exportCommand = [[AVSEExportCommand alloc] initWithComposition:self.composition videoComposition:self.videoComposition audioMix:self.audioMix];
            [exportCommand performWithAsset:nil];
            //            [self reloadPlayerView];
            
            NSLog(@"导出成功");
            [SVProgressHUD showSuccessWithStatus:@"export success"];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [SVProgressHUD showWithStatus:@"saving"];
            });
            
        });
    }
}
- (void)exportWillBegin
{
    // Hide play until the export is complete
    // If Add watermark has been applied to the composition, create a video composition animation tool for export
    if(self.watermarkLayer) {
        CALayer *exportWatermarkLayer = [self copyWatermarkLayer:self.watermarkLayer];
        CALayer *parentLayer = [CALayer layer];
        CALayer *videoLayer = [CALayer layer];
        parentLayer.frame = CGRectMake(0, 0, self.videoComposition.renderSize.width, self.videoComposition.renderSize.height);
        videoLayer.frame = CGRectMake(0, 0, self.videoComposition.renderSize.width, self.videoComposition.renderSize.height);
        [parentLayer addSublayer:videoLayer];
 
        exportWatermarkLayer.position = CGPointMake(50, self.videoComposition.renderSize.height-150);
        [parentLayer addSublayer:exportWatermarkLayer];
        self.videoComposition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    }
}
- (CALayer*)copyWatermarkLayer:(CALayer*)inputLayer
{
    CALayer *exportWatermarkLayer = [CALayer layer];
    CATextLayer *titleLayer = [CATextLayer layer];
    CATextLayer *inputTextLayer = (CATextLayer *)[inputLayer sublayers][0];
    
    
    NSAttributedString *string =[[NSAttributedString alloc]initWithString:inputTextLayer.string attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:20]}];
    titleLayer.string = string;
    titleLayer.foregroundColor = inputTextLayer.foregroundColor;
//    titleLayer.font = inputTextLayer.font;
    titleLayer.shadowOpacity = inputTextLayer.shadowOpacity;
    titleLayer.alignmentMode = inputTextLayer.alignmentMode;
    titleLayer.bounds = inputTextLayer.bounds;
    
    [exportWatermarkLayer addSublayer:titleLayer];
    
    
    CALayer *imglayer=[CALayer layer];
    imglayer.bounds=CGRectMake(0, 0, 100, 100);
    imglayer.position=CGPointMake(0, 65);
    imglayer.contents=(id)_imgMark.image.CGImage;
    [exportWatermarkLayer addSublayer:imglayer];
    
    
    return exportWatermarkLayer;
}


-(void)selecPicForWaterMark{
    
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    
    if (author == ALAuthorizationStatusRestricted || author ==ALAuthorizationStatusDenied)
        
    {
        [SVProgressHUD showErrorWithStatus:@"Please allow to vist your photo library"];
        return ;
        //无权限
        
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    
    picker.delegate=self;

    
    picker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
    
    
    [self presentViewController:picker animated:YES completion:nil];
 
    
}

-(void)selectVideobuttonDidClicked{
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    
    if (author == ALAuthorizationStatusRestricted || author ==ALAuthorizationStatusDenied)
        
    {
        [SVProgressHUD showErrorWithStatus:@"Please allow to vist your photo library"];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            
            if([[UIApplication sharedApplication] canOpenURL:url]) {
                
                NSURL*url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];           [[UIApplication sharedApplication] openURL:url];
                
            }
        });
        return ;
        //无权限
        
    }
    
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    
    picker.delegate=self;
    
    
    picker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
    
    
    [self presentViewController:picker animated:YES completion:nil];
//    [self selecPicForWaterMark];
}

-(void)goOutAndSaveButtonDidCliced{
    
    if (_sourceVideoURL==nil) {
        [SVProgressHUD showErrorWithStatus:@"please select video first"];
        return;
    }
    
    self.watermarkCommand=[[AVSEAddWatermarkCommand alloc]init];
    self.watermarkCommand.markTExt=_textMark.text;
    AVAsset *asset=[AVAsset assetWithURL:_sourceVideoURL];
    [self.watermarkCommand performWithAsset:asset];

    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSString *typeString=info[@"UIImagePickerControllerMediaType"];

    NSString *type=[typeString componentsSeparatedByString:@"."].lastObject;
    if ([type isEqualToString:@"image"]) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        self.imgMark.image=image;
        
    }else{
        _sourceVideoURL=info[@"UIImagePickerControllerMediaURL"];
        
        _videoImg.image=[self thumbnailImageForVideo:_sourceVideoURL atTime:0];
        
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [SVProgressHUD dismiss];
}


//获取视频中图片
- (UIImage*) thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil] ;
   
    AVAssetImageGenerator *assetImageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset] ;
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, asset.duration.timescale) actualTime:NULL error:&thumbnailImageGenerationError];
    
    if (!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@", thumbnailImageGenerationError);
    
    UIImage *thumbnailImage = thumbnailImageRef ? [[UIImage alloc] initWithCGImage:thumbnailImageRef]  : nil;
    
    return thumbnailImage;
}

-(UIImageView *)videoImg{
    
    if (_videoImg==nil) {
        _videoImg=[[UIImageView alloc]initWithFrame:CGRectMake(0, 20, ScreenW, 0.75*ScreenW)];
        _videoImg.image=[UIImage imageNamed:@"videobg"];
        _videoImg.backgroundColor=[UIColor blackColor];
        return _videoImg;
    }
    
    return _videoImg;
}


-(UITextField *)textMark{
    
    if (_textMark==nil) {
        _textMark=[[UITextField alloc]initWithFrame:CGRectMake(22, 320*(ScreenH/667.0), 300, 20)];
        _textMark.placeholder=@"please enter watermark text";
        _textMark.font=[UIFont systemFontOfSize:20];
        _textMark.delegate=self;
    }
 
    return _textMark;
}

-(UIImageView *)imgMark{
    
    if (_imgMark==nil) {
        _imgMark=[[UIImageView alloc]initWithFrame:CGRectMake(ScreenW-70, 320*(ScreenH/667.0)+40, 50, 50)];
        _imgMark.image=[UIImage imageNamed:@"markHolder"];
    }
    return _imgMark;
}

-(UIButton *)selecVideoButton{
    
    if (_selecVideoButton==nil) {
        _selecVideoButton=[[UIButton alloc]initWithFrame:CGRectMake((ScreenW-60)*0.5-100, ScreenH-100, 60, 40)];
        [_selecVideoButton setImage:[UIImage imageNamed:@"selectedVideo"] forState:UIControlStateNormal];
        [_selecVideoButton setTitleColor:[UIColor colorWithRed:0/255.0 green:111/255.0 blue:252/255.0 alpha:1] forState:UIControlStateNormal];
        [_selecVideoButton addTarget:self action:@selector(selectVideobuttonDidClicked) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    return _selecVideoButton;
    
}

-(UIButton *)selecPicButton{
    if (_selecPicButton==nil) {
        _selecPicButton=[[UIButton alloc]initWithFrame:CGRectMake((ScreenW-60)*0.5, ScreenH-100, 60, 40)];
        [_selecPicButton setImage:[UIImage imageNamed:@"addImage"] forState:UIControlStateNormal];
        [_selecPicButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
        [_selecPicButton setTitleColor:[UIColor colorWithRed:0/255.0 green:111/255.0 blue:252/255.0 alpha:1] forState:UIControlStateNormal];
        [_selecPicButton addTarget:self action:@selector(selecPicForWaterMark) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    return _selecPicButton;
}

-(UIButton *)saveAndoutButton{
    
    if (_saveAndoutButton==nil) {
        _saveAndoutButton=[[UIButton alloc]initWithFrame:CGRectMake((ScreenW-60)*0.5+100, ScreenH-100, 60, 40)];
        [_saveAndoutButton setImage:[UIImage imageNamed:@"save"] forState:UIControlStateNormal];
         [_saveAndoutButton setTitleColor:[UIColor colorWithRed:0/255.0 green:111/255.0 blue:252/255.0 alpha:1] forState:UIControlStateNormal];
        [_saveAndoutButton addTarget:self action:@selector(goOutAndSaveButtonDidCliced) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    return _saveAndoutButton;
    
}



@end
