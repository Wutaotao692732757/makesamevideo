//
//  CutterVideoVC.m
//  avplayerCuter
//
//  Created by mac_w on 2016/11/4.
//  Copyright © 2016年 aee.wutaotao All rights reserved.
//  ...

#import "CutterVideoVC.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
static CGFloat imageWidth;
static CGFloat imageheight;
#define  ScreenW [UIScreen mainScreen].bounds.size.width
#define  ScreeH  [UIScreen mainScreen].bounds.size.height
#define randomName @"nai8uww33"


@interface CutterVideoVC ()<UIScrollViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property(nonatomic,strong) AVAsset *asset;
@property(nonatomic,strong) UIButton *pauseButton;
@property(nonatomic,strong) UILabel *beginlabel;
@property(nonatomic,strong) UILabel *endLabel;

@property(nonatomic,strong) NSTimer *timer;
//底部的预览视图
@property(nonatomic,strong) UIScrollView *quickLookView;
@property (nonatomic,strong) NSMutableArray *quickLookArr;
//刻度尺
@property(nonatomic,strong) UIImageView *positionImageView;


@property(nonatomic,assign) NSInteger totalTime;
//记录是否是人为拖动
@property (nonatomic,assign) BOOL isPlaying;

//开始裁剪按钮
@property (nonatomic,strong) UIButton *beginCutBtn;
//记录开始裁剪的状态
@property (nonatomic,assign) BOOL isCutting;
@property (nonatomic,assign) CGFloat beginoffset;
//记录是否赋了剪切初值
@property (nonatomic,assign) BOOL hasBeginTime;
@property (nonatomic,assign) CGFloat endoffset;
//标记的红色视图
@property (nonatomic,strong) UIImageView *redView;

@property (nonatomic,strong) UIView *bgView;


@property (nonatomic,strong)UIButton *getOutbutton;


@property (nonatomic,strong) UIButton *selectedViewBtn;

@property (nonatomic,strong) UIImageView *holderImage;

@end

@implementation CutterVideoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.holderImage];
 
    [self.view addSubview:self.selectedViewBtn];
    
    [self.view addSubview:self.beginCutBtn];
    [self.view addSubview:self.getOutbutton];
    [self.beginCutBtn addTarget:self action:@selector(beginCutBtnDidClicked) forControlEvents:UIControlEventTouchUpInside];
    self.view.backgroundColor=[UIColor whiteColor];
}

-(void)selectViewBtnDidClicked{
    
    
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
    
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    
    
    NSURL *videoURL=info[@"UIImagePickerControllerMediaURL"];
    
    self.sourceURL=videoURL;
    
    [self dismissViewControllerAnimated:YES completion:nil];
 
}




-(void)setSourceURL:(NSURL *)sourceURL
{
      _beginoffset=0; _endoffset=0;
    [self.redView removeFromSuperview];
    _isCutting=NO;
    _isPlaying=NO;
    _beginlabel.text=[NSString stringWithFormat:@"%zd",0];
    _playerlayer=nil;
    _player=nil;
    
    for (UIImageView *img in _quickLookArr) {
        [img removeFromSuperview];
    }
    [_quickLookArr removeAllObjects];
    
     [_beginCutBtn setTitle:@"开始 begin" forState:UIControlStateNormal];
      _hasBeginTime=NO;
        _sourceURL=sourceURL;
        _asset = [AVAsset assetWithURL:sourceURL];
        CGFloat totalTime=_asset.duration.value*1.0f/_asset.duration.timescale;
    
    _totalTime = [[NSNumber numberWithFloat:totalTime] integerValue];
        int time=[[NSNumber  numberWithFloat:totalTime] intValue];
    
        NSTimeInterval begintime=[[NSNumber numberWithInt:0] doubleValue] ;
        UIImage *firstImage=[self thumbnailImageForVideo:sourceURL atTime:begintime];
    
        imageWidth=firstImage.size.width;
        imageheight=firstImage.size.height;
        CGFloat scale = imageWidth/imageheight;
    
    imageWidth = ScreenW;
    imageheight = ScreenW / scale;
            if (imageheight>ScreenH-350) {
                imageheight=ScreenH-350;
                imageWidth=imageheight*(scale);
            }
 
    self.firstImageView.frame=CGRectMake((ScreenW-imageWidth)*0.5, 84, imageWidth, imageheight);
        _firstImageView.image=firstImage;
    
        [self.view addSubview:_firstImageView];
    
        self.playButton.frame = CGRectMake((imageWidth-30)*0.5, (imageheight-30)*0.5, 30, 30);
        [_playButton setImage:[UIImage imageNamed:@"player_play"] forState:UIControlStateNormal];
        [_firstImageView addSubview:_playButton];
        _firstImageView.userInteractionEnabled=YES;
        [_playButton addTarget:self action:@selector(playVideo) forControlEvents:UIControlEventTouchUpInside];
    
       self.beginlabel.frame=CGRectMake(0, CGRectGetMaxY(_firstImageView.frame), 50, 20);
        self.endLabel.frame =CGRectMake([UIScreen mainScreen].bounds.size.width-50, CGRectGetMaxY(_firstImageView.frame), 50, 20);
        _beginlabel.text=@"0";
        _beginlabel.textColor=[UIColor whiteColor];
        _beginlabel.font=[UIFont systemFontOfSize:15];
        _beginlabel.textAlignment=NSTextAlignmentCenter;
        _endLabel.text=[NSNumber numberWithInt:time].description;
        _endLabel.textColor=[UIColor whiteColor];
        _endLabel.font=[UIFont systemFontOfSize:15];
        _endLabel.textAlignment=NSTextAlignmentCenter;
        
        [self.view addSubview:_beginlabel];
        [self.view addSubview:_endLabel];
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pauseTheVideo)];
    
     [_firstImageView addGestureRecognizer:tap];
     _timer=[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(coutLabelPlus) userInfo:nil repeats:YES];
     [_timer setFireDate:[NSDate distantFuture]];
    
     self.quickLookView.frame=CGRectMake(0, CGRectGetMaxY(_beginlabel.frame)+5, [UIScreen mainScreen].bounds.size.width, 50);
    _quickLookView.backgroundColor=[UIColor clearColor];
    [self.view addSubview:_quickLookView];
        [self creatQuickLookImage];
    self.positionImageView.frame=CGRectMake((ScreenW-20)*0.5, _quickLookView.frame.origin.y, 20, 50);
    _positionImageView.backgroundColor=[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.5];
 
    [self.view addSubview:_positionImageView];
    _quickLookView.delegate=self;
    
}


//播放点击事件
-(void)playVideo{
    
       [_playButton removeFromSuperview];
    
//    AVURLAsset *avasset = [[AVURLAsset alloc]initWithURL:_sourceURL options:nil];
    if (_player==nil||_player.currentTime.value==_asset.duration.value) {
        _player=nil;
        
        AVPlayerItem *item=[[AVPlayerItem alloc]initWithAsset:_asset];
        
        _player = [[AVPlayer alloc] initWithPlayerItem:item];
        
        _playerlayer=[AVPlayerLayer playerLayerWithPlayer:_player];
        _playerlayer.frame=_firstImageView.bounds;
        [_firstImageView.layer addSublayer: _playerlayer];
    }
    
        [_player play];
//         _isPlaying=YES;
        [_timer setFireDate:[NSDate distantPast]];
    
}
//暂停播放
-(void)pauseTheVideo{
    
    if (_player!=nil) {
        [_timer setFireDate:[NSDate distantFuture]];
        [_player pause];
//        _isPlaying=NO;
     
    }
    [_firstImageView addSubview:_playButton];
}

//计数方法
-(void)coutLabelPlus{
//      AVURLAsset *avasset = [[AVURLAsset alloc]initWithURL:_sourceURL options:nil];
    
    if (_player!=nil) {
        
        CMTime time = _player.currentTime;
        
        CGFloat floatTime=time.value*1.0f/time.timescale;
//        CGFloat scale = time.value/_asset.duration.value;
//        NSLog(@"%.2f",scale);
        NSInteger currentTime=[[NSNumber numberWithFloat:floatTime] integerValue];
        _beginlabel.text=[NSString stringWithFormat:@"%zd",currentTime];
        NSLog(@"%.2f",floatTime);
        if (floatTime<_totalTime) {
            
            [_quickLookView setContentOffset:CGPointMake(floatTime*(50*(imageWidth/imageheight)), 0) animated:YES];
        }
        
        
    }
    if (_player.currentTime.value==_asset.duration.value) {
         [_timer setFireDate:[NSDate distantFuture]];
//        _beginlabel.text=[NSString stringWithFormat:@"%zd",0];
       
    }
 }
//生成预览
-(void)creatQuickLookImage{
    
//    AVAsset *asset = [AVAsset assetWithURL:_sourceURL];
    for (int i=0; i<_totalTime; i++) {
        
        NSTimeInterval cuttime=[[NSNumber numberWithInt:i*_asset.duration.timescale] doubleValue] ;
        
        UIImage *cImage=[self thumbnailImageForVideo:_sourceURL atTime:cuttime];
        
        UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(ScreenW*0.5+50*(imageWidth/imageheight)*i, 0, 50*(imageWidth/imageheight), 50)];
        imageView.image=cImage;
        [self.quickLookArr addObject:imageView];
        [_quickLookView addSubview:imageView];
    }
 
    _quickLookView.contentSize=CGSizeMake(50*(imageWidth/imageheight)*_totalTime+ScreenW, 50);
    _quickLookView.scrollEnabled=YES;
    [_quickLookView setContentOffset:CGPointMake(0, 0)];
    _quickLookView.showsHorizontalScrollIndicator=NO;
    _quickLookView.showsVerticalScrollIndicator=NO;
    
}


//拖动预览可暂停视频
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
//    if (scrollView==_quickLookView) {
//        [self pauseTheVideo];
//    }
    _isPlaying=YES;
    
    if (_isCutting==YES&&_hasBeginTime==NO) {
        _hasBeginTime=YES;
        _beginoffset=(scrollView.contentOffset.x);
    }
    
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
   //当是拖动发起的时候就操作
    if (_isPlaying==YES) {
       
        CGFloat percent = (scrollView.contentOffset.x)/(scrollView.contentSize.width-ScreenW);
        double dpercent=[[NSNumber numberWithFloat:percent] doubleValue];
        double cuttime=_asset.duration.value*(dpercent);
//        NSLog(@"%.2f",(scrollView.contentOffset.x)/(scrollView.contentSize.width-ScreenW));
        CMTime begintime=CMTimeMake(cuttime, _asset.duration.timescale);
        [_player seekToTime:begintime];
    }
    
    
    if (_isCutting==YES&&_hasBeginTime==YES) {
        NSLog(@"%.2f",_beginoffset);
        _endoffset=(scrollView.contentOffset.x);
        self.redView.frame=CGRectMake(_beginoffset+ScreenW*0.5, 0,(scrollView.contentOffset.x-_beginoffset), 50);
        [self.quickLookView addSubview:self.redView];
    }
    
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView==_quickLookView) {
        
        _isPlaying=NO;
    }

}



// 开始裁剪按钮点击
-(void)beginCutBtnDidClicked{
    
//    _positionImageView.backgroundColor=[UIColor redColor];
    
    if (self.sourceURL==nil||self.asset==nil) {
        [SVProgressHUD showErrorWithStatus:@"please select video frome library"];
        return;
    }
    
    
    if([_beginCutBtn.currentTitle isEqualToString:@"开始 begin"] ){
        
        [self pauseTheVideo];
        CGRect saveframe = _getOutbutton.frame;
        
      UIImageView*imgView = [[UIImageView alloc]initWithFrame:CGRectMake((ScreenW-50)*0.5, saveframe.origin.y-70, 50, 50)];
        imgView.image=[UIImage imageNamed:@"leftAndRightScroll"];
        [self.view addSubview:imgView];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [imgView removeFromSuperview];
        });
        
        [_beginCutBtn setTitle:@"完成 success" forState:UIControlStateNormal];
        //    _beginCutBtn.enabled=NO;
        _isCutting=YES;
    }else{
        
 
//        _player=nil;
        [_playerlayer removeFromSuperlayer];
        _playerlayer=nil;
        [_bgView removeFromSuperview];
        _bgView=nil;
        
        [self beginToCutterVideo];
    }
    
    
    
}

//裁剪操作
-(void)beginToCutterVideo{
    
       NSFileManager *fileMag=[NSFileManager defaultManager];
    
       [fileMag removeItemAtURL:[self clipUrl] error:nil];
  
    _bgView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenW, ScreeH)];
//    _bgView.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    UIActivityIndicatorView *prosses=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake((ScreenW-30)*0.5, (ScreeH-30)*0.5, 30, 30)];
    [self.view addSubview:_bgView];
    [_bgView addSubview:prosses];
    [prosses startAnimating];
    
    NSURL *clipPath = _sourceURL;
    AVMutableComposition *mainComposition = [[AVMutableComposition alloc]init];
    AVMutableCompositionTrack *videoTrack=[mainComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *audioTrack =[mainComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    CMTime duration=kCMTimeZero;
    AVAsset *asset = [AVAsset assetWithURL:clipPath];
 
    CGFloat beginValue = _totalTime*(_beginoffset/(_quickLookView.contentSize.width-ScreenW));
    CGFloat endValue = _totalTime*(_endoffset/(_quickLookView.contentSize.width-ScreenW));
    
    NSLog(@"--%.2f---%.2f",beginValue,endValue);
    
    CMTimeRange rangeTime = CMTimeRangeMake(CMTimeMakeWithSeconds( beginValue, asset.duration.timescale), CMTimeMakeWithSeconds(endValue, asset.duration.timescale));
    [videoTrack insertTimeRange:rangeTime ofTrack:[asset tracksWithMediaType:AVMediaTypeVideo].firstObject atTime:duration error:nil];
    
    [audioTrack insertTimeRange:rangeTime ofTrack:[asset tracksWithMediaType:AVMediaTypeAudio].firstObject atTime:duration error:nil];
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mainComposition presetName:AVAssetExportPreset1280x720];
    
    exporter.outputURL = [self clipUrl];
    exporter.outputFileType = AVFileTypeMPEG4;
    exporter.shouldOptimizeForNetworkUse = YES;
    NSLog(@"%@",exporter.outputURL);
    
   
    __weak typeof (self) weakSelf = self;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
       
        NSLog(@"%zd",exporter.status);
     
        switch (exporter.status) {
   
            case AVAssetExportSessionStatusWaiting:
                break;
            case AVAssetExportSessionStatusExporting:
                break;
            case AVAssetExportSessionStatusCompleted:{
                NSLog(@"exporting completed");
                dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.bgView removeFromSuperview];
                    self.sourceURL=[self clipUrl];
                    
                });
             
            }
  
                break;
            default:
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                   [weakSelf.bgView removeFromSuperview];
                });
                NSLog(@"exporting failed %@",[exporter error]);
                break;
        }
        
    }];
    NSLog(@"kaishikaishikaishi");
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

-(void)getoutAndSave{
    if (self.sourceURL==nil||self.asset==nil) {
        [SVProgressHUD showErrorWithStatus:@"please select video frome system library"];
        return;
    }
    
    NSArray *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [docPath objectAtIndex:0];
    NSString *path= [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",randomName]];
    NSFileManager *filemg = [NSFileManager defaultManager];
    if (![filemg fileExistsAtPath:path]) {
        [SVProgressHUD showErrorWithStatus:@"have no video been cut"];
    }
    
    _sourceURL=nil;
    [self.playerlayer removeFromSuperlayer];
    _playerlayer=nil;
    _player=nil;
    [_quickLookView removeFromSuperview];
    _quickLookView=nil;
    [_beginlabel removeFromSuperview];
    _beginlabel=nil;
    [_endLabel removeFromSuperview];
    _endLabel=nil;
    [_positionImageView removeFromSuperview];
    _positionImageView=nil;
    [_firstImageView removeFromSuperview];
    _firstImageView=nil;
     NSLog(@"---%@--",path);
     UISaveVideoAtPathToSavedPhotosAlbum(path , self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
  
}

-(void)video:(NSData *)image didFinishSavingWithError:(NSError*)error contextInfo:(void *)contextInfo{
    NSLog(@"保存成功");
    if(error!=nil){
        [SVProgressHUD showErrorWithStatus:@"fail to save"];
    }else{
        [SVProgressHUD showSuccessWithStatus:@"save success,please check in your photo library"];
    }
    
}

 
//获取视频中图片
- (UIImage*) thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil] ;
    NSParameterAssert(asset);
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



-(UIButton *)beginCutBtn
{
    if (_beginCutBtn==nil) {
        _beginCutBtn=[[UIButton alloc]initWithFrame:CGRectMake(0, ScreeH-104, ScreenW, 40)];
        [_beginCutBtn setTitle:@"开始剪切 begin" forState:UIControlStateNormal];
        [_beginCutBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [_beginCutBtn setBackgroundColor:[UIColor colorWithRed:0/255.0 green:111/255.0 blue:252/255.0 alpha:1]];
    }
    
    return _beginCutBtn;
}
//完成按钮
-(UIButton *)getOutbutton{
    
    if (_getOutbutton==nil) {
        _getOutbutton=[[UIButton alloc] initWithFrame:CGRectMake(0, ScreeH-164, ScreenW, 40)];
        [_getOutbutton setTitle:@"保存 save" forState:UIControlStateNormal];
        [_getOutbutton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_getOutbutton addTarget:self action:@selector(getoutAndSave) forControlEvents:UIControlEventTouchUpInside];
        [_getOutbutton setBackgroundColor:[UIColor colorWithRed:0/255.0 green:111/255.0 blue:252/255.0 alpha:1]];
    }
    return _getOutbutton;
    
}

-(UIImageView *)redView
{
    if (_redView==nil) {
        _redView=[[UIImageView alloc]init];
        _redView.backgroundColor=[UIColor colorWithRed:220/225.0 green:1/225.0 blue:1/225.0 alpha:0.4];
        
    }
    return _redView;
}
- (NSURL*)clipUrl {
    NSArray *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [docPath objectAtIndex:0];
    return [NSURL fileURLWithPath:[documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",randomName]]];
}
-(UIImageView *)firstImageView
{
    if (_firstImageView==nil) {
        _firstImageView=[[UIImageView alloc]init];
    }
    
    return _firstImageView;
}
-(UIButton *)playButton{
    if (_playButton==nil) {
        _playButton=[[UIButton alloc]init];
    }
    
    return _playButton;
}
-(UILabel *)beginlabel
{
    if (_beginlabel==nil) {
        _beginlabel=[[UILabel alloc]init];
    }
    return _beginlabel;
}
-(UILabel *)endLabel
{
    if (_endLabel==nil) {
        _endLabel=[[UILabel alloc]init];
    }
    return _endLabel;
}

-(UIScrollView *)quickLookView
{
    if (_quickLookView==nil) {
        _quickLookView=[[UIScrollView alloc]init];
    }
    
    return _quickLookView;
}
-(UIImageView *)positionImageView
{
    if (_positionImageView==nil) {
        _positionImageView=[[UIImageView alloc]init];
        UIImageView *blueLine=[[UIImageView alloc]initWithFrame:CGRectMake(9.5, 0, 1, 50)];
        blueLine.backgroundColor=[UIColor blueColor];
        [_positionImageView addSubview:blueLine];
    }
    
    return _positionImageView;
}

-(NSMutableArray *)quickLookArr
{
    if (_quickLookArr==nil) {
        _quickLookArr=[NSMutableArray array];
    }
    return _quickLookArr;
}

-(UIButton*)selectedViewBtn{
  
    if (_selectedViewBtn==nil) {
        _selectedViewBtn=[[UIButton alloc]initWithFrame:CGRectMake(ScreenW-60 , 0.6*ScreenW+20, 40, 40)];
        [_selectedViewBtn setImage:[UIImage imageNamed:@"selectLibrary"] forState:UIControlStateNormal];
        [_selectedViewBtn addTarget:self action:@selector(selectViewBtnDidClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _selectedViewBtn;
}

-(UIImageView*)holderImage
{
    if (_holderImage==nil) {
        _holderImage=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, ScreenW, ScreenW*0.6)];
        _holderImage.image=[UIImage imageNamed:@"img_制作快闪视频"];
        
        UIImageView *maskView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, ScreenW, ScreenW*0.6)];
        maskView.alpha=0.5;
        maskView.image=[UIImage imageNamed:@"img_video_preview_mask"];
        [_holderImage addSubview:maskView];
        
    }
    return _holderImage;
}


@end
