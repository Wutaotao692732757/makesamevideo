//
//  BeautifulFaceVC.m
//  MakeSmallVideo
//
//  Created by wutaotao on 2017/5/17.
//  Copyright © 2017年 mac_wsdasd. All rights reserved.
//

#import "BeautifulFaceVC.h"
#import "GPUImage.h"
#import "GPUImageBeautifyFilter.h"
#import "AppDelegate.h"

@interface BeautifulFaceVC ()

@property (nonatomic,strong) GPUImageStillCamera *videoCamera;
@property (nonatomic,strong) GPUImageView *filterView;
@property (weak, nonatomic) IBOutlet UIButton *beautifulButton;

@property (nonatomic,strong) GPUImageUIElement *uiElementInput;
@property (nonatomic,strong) CIDetector  *faceDetector;
@end

@implementation BeautifulFaceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.videoCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionFront];
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    self.filterView = [[GPUImageView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
//    self.filterView.center = self.view.center;
    [self.view insertSubview:self.filterView atIndex:0];
 
    [self.videoCamera addTarget:self.filterView];
    [self.videoCamera startCameraCapture];
    
    NSDictionary *detectorOptions = [[NSDictionary alloc]initWithObjectsAndKeys:CIDetectorAccuracyLow, CIDetectorAccuracy, nil];
    _faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:detectorOptions];
 
}

GPUImageBeautifyFilter * beautifyFilter ;
- (IBAction)beautifulFaceButtonDidClicked:(id)sender {
    
    if (self.beautifulButton.selected) {
        self.beautifulButton.selected = NO;
        [self.videoCamera removeAllTargets];
        [self.videoCamera addTarget:self.filterView];
    }
    else{
        self.beautifulButton.selected = YES;
        [self.videoCamera removeAllTargets];
 
         beautifyFilter = [[GPUImageBeautifyFilter alloc]init];
        [self.videoCamera addTarget:beautifyFilter];
        [beautifyFilter addTarget:self.filterView];
        
    }
}

- (IBAction)takephoto:(id)sender {
    
   
    
  
//  UIImage *img = [self.videoCamera captureSessionPreset];
    
    
//    UIImageWriteToSavedPhotosAlbum(img, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    [self.videoCamera capturePhotoAsImageProcessedUpToFilter:beautifyFilter withCompletionHandler:^(UIImage *processedImage, NSError *error) {
        if(error){
            return;
        }
        //存入本地相册
        UIImageWriteToSavedPhotosAlbum(processedImage, nil, nil, nil);
    }];
    
}
// 指定回调方法

- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo

{
    NSLog(@"出错了:%@",error);
    
    }

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UITabBarController *tabvc = (UITabBarController *)app.window.rootViewController;
    tabvc.tabBar.hidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UITabBarController *tabvc = (UITabBarController *)app.window.rootViewController;
    tabvc.tabBar.hidden = NO;
}


- (IBAction)backBtnDidclicked:(id)sender {
    
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UITabBarController *tabvc = (UITabBarController *)app.window.rootViewController;
    tabvc.tabBar.hidden = NO;
    [tabvc setSelectedIndex:0];
//    tabvc.selectedIndex = 0;
    
}

@end









