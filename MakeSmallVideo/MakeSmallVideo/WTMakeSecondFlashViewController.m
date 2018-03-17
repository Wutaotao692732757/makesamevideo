//
//  WTMakeSecondFlashViewController.m
//  MakeSmallVideo
//
//  Created by mac_w on 2016/12/16.
//  Copyright © 2016年 mac_wsdasd. All rights reserved.
//

// 制作快闪视频
#import <AssetsLibrary/AssetsLibrary.h>
#import "WTMakeSecondFlashViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "UIImage+WaterMark.h"
#import "MediaManager.h"
#import <MobileCoreServices/MobileCoreServices.h>
#define MediaFileName @"MixVideo.mov"
#define AUDIO_URL [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Surkin - Tiger Rhythm" ofType:@"mp3"]]
#define VideoWidth 768
#define VideoHeight 432

@interface WTMakeSecondFlashViewController ()<UITextFieldDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>{
    
 NSURL *_audioUrl;
}

//滚动视图
@property(nonatomic,strong)UIScrollView *chooseScroller;

@property(nonatomic,strong)UIImageView *prewView;

@property(nonatomic,strong)NSMutableArray *imageArr;
//合并按钮
@property(nonatomic,strong)UIButton *startButton;
//按钮数组
@property(nonatomic,strong)NSMutableArray *buttonArr;
//texField数组
@property(nonatomic,strong)NSMutableArray *texfieldArr;
//选中的图片数组
@property(nonatomic,strong)NSMutableArray *showedImgViewArr;
//写入的文字数组
@property(nonatomic,strong)NSMutableArray *textArr;

@property(nonatomic,assign)NSInteger buttonCount;

//输入按钮
@property(nonatomic,strong)UIButton *addTextBtn;
//输入框和输入按钮
@property(nonatomic,strong)UIView *sendTextView;
@property(nonatomic,strong)UITextField *sendTextField;
@property(nonatomic,strong)UIButton *sendTextBtn;

//选择相册按钮
@property(nonatomic,strong)UIButton *selectedImageBtn;

@property(nonatomic,strong)UIImageView *showSelectedImageView;

//清空按钮
@property(nonatomic,strong)UIButton *cleanButton;

//背景
@property(nonatomic,strong)UIImageView *chatbgView;

@end
//Surkin - Tiger Rhythm

@implementation WTMakeSecondFlashViewController

NSInteger count;
UIImage *selectedImage;

 int j=3;
//CGSize size;
- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.view.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:self.chatbgView];
    [self.view addSubview:self.startButton];
    
    [self.view addSubview:self.addTextBtn];
    
   
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moveTheTextEndView:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
//    _showSelectedImageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 200, ScreenW, 300)];
//    [self.view addSubview:_showSelectedImageView];
    
    
}

CGRect ketframe;
-(void)moveTheTextEndView:(NSNotification *)notification{
    
    //1. 获取键盘的 Y 值
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    //或者  keyboardFrame = [[notification.userInfo objectForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    
    //注意从字典取出来的是对象，而 CGRect CGFloat 都是基本数据类型，一次需要转换
    
    CGFloat keyboardY = keyboardFrame.origin.y;
    ketframe=keyboardFrame;
    NSLog(@"---键盘位置--%.2f--",keyboardY);
    if (keyboardY<ScreenH) {
        self.sendTextView.transform = CGAffineTransformMakeTranslation(0, (keyboardY-ScreenH)+_sendTextView.frame.size.height);
    }else{
        self.sendTextView.transform=CGAffineTransformMakeTranslation(0, (keyboardY-ScreenH));
        
    }
   
    
}

-(void)cleanbtnDidClicked{
    

    [self.imageArr removeAllObjects];
    
    for (UIView *view in self.showedImgViewArr) {
        [view removeFromSuperview];
    }
    
    [self.cleanButton removeFromSuperview];
    
    
}

- (CVPixelBufferRef )pixelBufferFromCGImage:(CGImageRef)image size:(CGSize)size
{
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey, nil];
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, size.width, size.height, kCVPixelFormatType_32ARGB,(__bridge CFDictionaryRef) options, &pxbuffer);
    
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, size.width, size.height, 8, 4*size.width, rgbColorSpace, kCGImageAlphaPremultipliedFirst);
    NSParameterAssert(context);
    
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), image);
    
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

- (void)testCompressionSession
{
    
    if (self.imageArr.count==0) {
        [SVProgressHUD showErrorWithStatus:@"please select image frome library first"];
        return ;
    }
    
    
    
    [SVProgressHUD show];
//    [self mergerSelecedImageAndText];
    
    
    NSString *betaCompressionDirectory =[self savePath];
//    [[NSBundle mainBundle] pathForResource:@"Movie" ofType:@"mov"]; 320,400
    
    CGSize size = CGSizeMake(VideoWidth,VideoHeight);//定义视频的大小
    
    NSError *error = nil;
    unlink([betaCompressionDirectory UTF8String]);
//    unlink([betaCompressionDirectory UTF8String]);
   
    //—-initialize compression engine
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:betaCompressionDirectory]
                                                           fileType:AVFileTypeQuickTimeMovie
                                                              error:&error];
    NSParameterAssert(videoWriter);
    if(error){
        NSLog(@"出错了啊");
    }
//        NSLog(@" error = %@”, [error localizedDescription]);
    
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:size.width], AVVideoWidthKey,
                                   [NSNumber numberWithInt:size.height], AVVideoHeightKey, nil];
    AVAssetWriterInput *writerInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    
    NSDictionary *sourcePixelBufferAttributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_32ARGB], kCVPixelBufferPixelFormatTypeKey, nil];
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor
                                                     assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput sourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];
    NSParameterAssert(writerInput);
    NSParameterAssert([videoWriter canAddInput:writerInput]);
    
    if ([videoWriter canAddInput:writerInput])
        NSLog(@"");
    else
        NSLog(@"");
    
    [videoWriter addInput:writerInput];
    
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    //合成多张图片为一个视频文件
    dispatch_queue_t dispatchQueue = dispatch_queue_create("mediaInputQueue", NULL);
    dispatch_queue_t mergerQueue = dispatch_queue_create("mergerQueue.com.GCD", NULL);
    int __block frame = 0;
    int __block coun;
    [writerInput requestMediaDataWhenReadyOnQueue:dispatchQueue usingBlock:^{
        
    
        
             while ([writerInput isReadyForMoreMediaData])
             {
                 if(++frame >= [self.imageArr count]*30)
                 {
                     [writerInput markAsFinished];
                     [videoWriter finishWriting];
                     
                     break;
                 }
                 
                 CVPixelBufferRef buffer = NULL;
                 
                 int idx = frame/30;
                 
                 buffer = (CVPixelBufferRef)[self pixelBufferFromCGImage:[[_imageArr objectAtIndex:idx] CGImage] size:size];
                 
                 if (buffer)
                 {
                     if(![adaptor appendPixelBuffer:buffer withPresentationTime:CMTimeMake(frame, 30)])
                         NSLog(@"FAIL");
                     else
                         CFRelease(buffer);
                 }
                 
             }
             NSThread *thred = [NSThread currentThread];
             NSLog(@"-%@---执行几次---%zd",thred,++coun);
 

    }];
    
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC * _imageArr.count)), dispatchQueue, ^{
        //添加音乐
//        NSURL *docurl=[NSURL fileURLWithPath:[self savePath]];
//           UISaveVideoAtPathToSavedPhotosAlbum([self savePath] , self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        [self getMusicAndVideo];
    });
}

-(void)getMusicAndVideo{
    
    NSURL *docurl=[NSURL fileURLWithPath:[self savePath]];
    [MediaManager addBackgroundMiusicWithVideoUrlStr:docurl audioUrl:AUDIO_URL andCaptureVideoWithRange:NSMakeRange(0,_imageArr.count) completion:^{
        [SVProgressHUD dismiss];
        NSLog(@"make video success");
        NSString *outPutPath = [NSTemporaryDirectory() stringByAppendingPathComponent:MediaFileName];
        
        UISaveVideoAtPathToSavedPhotosAlbum(outPutPath , self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        
        [self.imageArr removeAllObjects];
        count=0;
    }];
    
}





-(void)video:(NSData *)image didFinishSavingWithError:(NSError*)error contextInfo:(void *)contextInfo{
  
    if(error!=nil){
        [SVProgressHUD showErrorWithStatus:@"save error"];
    }else{
        [SVProgressHUD showSuccessWithStatus:@"save success, you can check in your phone Photo library"];
  
         [self.view addSubview:self.cleanButton];
    }
    
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSString *typeString=info[@"UIImagePickerControllerMediaType"];
    
    NSString *type=[typeString componentsSeparatedByString:@"."].lastObject;
  
  
     if ([type isEqualToString:@"image"]) {
        selectedImage=[info objectForKey:UIImagePickerControllerOriginalImage];
        
     }
    
//    if ([type isEqualToString:@"image"]) {
//        UIImage *image = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            
//            UIImageView *lastView = self.selectedImgArr.lastObject;
//            lastView.image=image;
//        });
//
//     
//    }
    [self dismissViewControllerAnimated:YES completion:nil];

    [self showSelectedImage];
}

-(void)showSelectedImage{
    
        NSInteger cow = (ScreenW-10)/88;

        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10+88*(count%cow), 84+84*(count/cow), 78, 44)];
        UIImage *newscaleImage=[UIImage OriginImage:selectedImage scaleToSize:CGSizeMake(VideoWidth, VideoHeight)];
        imageView.image=newscaleImage;
        [self.imageArr addObject:newscaleImage];
    
        [self.view addSubview:imageView];
        [self.showedImgViewArr addObject:imageView];
        count++;
}



//将文字和图片混合成image   Party LET Plain
-(UIImage *)mergerSelecedImageAndTextWithString:(NSString *)string{
 
        NSString*string1=string;
        
        UIGraphicsBeginImageContextWithOptions (CGSizeMake(VideoWidth, VideoHeight), NO , 0.0 );
        CGContextRef context = UIGraphicsGetCurrentContext();
  
        CGContextDrawPath (context, kCGPathStroke );
//     NSDictionary *dic=@{
//                            NSFontAttributeName:[UIFont systemFontOfSize:18],
//                            //设置文字的字体
//                            NSKernAttributeName:@10,
//                            //文字之间的字距
//                            } ;
//     [string1 drawAtPoint : CGPointMake (30 ,110 ) withAttributes : @{ NSFontAttributeName :[ UIFont systemFontOfSize:100 ], NSForegroundColorAttributeName :[ UIColor redColor ] } ];
    
    CGSize size=[string sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:50],NSKernAttributeName:@10}];
        [string1 drawInRect:CGRectMake((VideoWidth-size.width)*0.5, (VideoHeight-size.height)*0.5, VideoWidth, VideoHeight) withAttributes:@{ NSFontAttributeName :[ UIFont systemFontOfSize:50 ],NSKernAttributeName:@10, NSForegroundColorAttributeName :[ UIColor whiteColor ] }];
        
        UIImage *newImage=UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext ();

        UIImage *newscaleImage=[UIImage OriginImage:newImage scaleToSize:CGSizeMake(768, 432)];
        
    
        return newscaleImage;
}




-(NSMutableArray *)imageArr
{
    if (_imageArr==nil) {
        _imageArr=[NSMutableArray array];
    
    }
    return _imageArr;
}

//选图片按钮点击
-(void)selectPicbuttonDidClicked:(UIButton *)button{
    
    _buttonCount=button.tag;
    

    
}

-(void)sendTextbtnDidClicked{
   [_sendTextField resignFirstResponder];
   
    UIImage *img=[self mergerSelecedImageAndTextWithString:_sendTextField.text];
    [self.imageArr addObject:img];
    NSInteger cow = (ScreenW-10)/88;
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10+88*(count%cow), 84+84*(count/cow), 78, 44)];

    imageView.image=img;
    imageView.backgroundColor=[UIColor blackColor];
    
    [self.view addSubview:imageView];
    [self.showedImgViewArr addObject:imageView];
     count++;
    
}
//选择相册按钮点击
-(void)selectImageButtonDidClicked{

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
    
    picker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
    

    [self presentViewController:picker animated:YES completion:nil];
    
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    NSInteger index=[self.texfieldArr indexOfObject:textField];
    
    UITextField *teField=self.textArr[index];
    teField.text=textField.text;
    
    
    
    return YES;
}

-(void)showOrDismissSendTextView{
    
    
    if (self.sendTextView.superview!=nil) {
        [self.sendTextView removeFromSuperview];
    }else{
        
        [self.view addSubview:self.sendTextView];
    }
    
}

-(NSString *)savePath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // Creating a full path and URL to the exported video
    NSString *outputVideoPath =  [documentsDirectory stringByAppendingPathComponent:
                                  [NSString stringWithFormat:@"flashVideo-%@.mov",@"flash"]];

    return outputVideoPath;
}
-(UIButton *)startButton
{
    if (_startButton==nil) {
        _startButton=[[UIButton alloc]initWithFrame:CGRectMake(ScreenW-50, 35, 40, 40)];
     
        [_startButton setImage:[UIImage imageNamed:@"save"] forState:UIControlStateNormal];
        [_startButton addTarget:self action:@selector(testCompressionSession) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startButton;
}
-(UIScrollView *)chooseScroller
{
    
    if (_chooseScroller==nil) {
       
        _chooseScroller=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 64+20, ScreenW, 225)];
        _chooseScroller.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"img_制作快闪视频"]];
        _chooseScroller.contentSize=CGSizeMake(100*j*2, 225);
        _chooseScroller.scrollEnabled=YES;
    }

    return _chooseScroller;
}


-(NSMutableArray *)texfieldArr
{
    if (_texfieldArr==nil) {
        _texfieldArr=[NSMutableArray array];
    }
    return _texfieldArr;
}
-(NSMutableArray *)buttonArr
{
    if (_buttonArr==nil) {
        _buttonArr=[NSMutableArray array];
    }
    return _buttonArr;
}

-(NSMutableArray *)textArr
{
    if (_textArr==nil) {
        _textArr=[NSMutableArray array];
    }
    return _textArr;
}

-(NSMutableArray *)showedImgViewArr
{
    if (_showedImgViewArr==nil) {
        _showedImgViewArr=[NSMutableArray array];
    }
    return _showedImgViewArr;
}


-(UIButton *)addTextBtn
{
    if (_addTextBtn==nil) {
        _addTextBtn=[[UIButton alloc]initWithFrame:CGRectMake(ScreenW-55, ScreenH-100, 45, 45)];
        [_addTextBtn setImage:[UIImage imageNamed:@"btn_add"] forState:UIControlStateNormal];
        [_addTextBtn addTarget:self action:@selector(showOrDismissSendTextView) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addTextBtn;
    
}
-(UIView *)sendTextView
{
    if (_sendTextView==nil) {
        _sendTextView=[[UIView alloc]initWithFrame:CGRectMake(0, ScreenH-100, ScreenW-60, 40)];
        _sendTextView.backgroundColor=[UIColor colorWithRed:0/255.0 green:111/255.0 blue:252/255.0 alpha:1.0];
;
        //选择相册按钮
        _selectedImageBtn=[[UIButton alloc]initWithFrame:CGRectMake(5, 5, 30, 30)];
        [_selectedImageBtn setImage:[UIImage imageNamed:@"LIBRARY_"] forState:UIControlStateNormal];
        [_sendTextView addSubview:_selectedImageBtn];
        [_selectedImageBtn addTarget:self action:@selector(selectImageButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
        
        _sendTextField=[[UITextField alloc]initWithFrame:CGRectMake(50, 0, ScreenW-170, 40)];
        _sendTextField.font=[UIFont systemFontOfSize:15];
        
        _sendTextField.placeholder=@"please enter text";
        [_sendTextView addSubview:_sendTextField];
        
        _sendTextBtn=[[UIButton alloc]initWithFrame:CGRectMake(ScreenW-120, 0, 60, 40)];
        [_sendTextBtn setTitle:@"Send" forState:UIControlStateNormal];
        [_sendTextBtn addTarget:self action:@selector(sendTextbtnDidClicked) forControlEvents:UIControlEventTouchUpInside];
//        [sendBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_sendTextView addSubview:_sendTextBtn];
    }
    
    return _sendTextView;
}

-(UIButton *)cleanButton{
    
    if (_cleanButton==nil) {
        _cleanButton=[[UIButton alloc]initWithFrame:CGRectMake(10, 35, 40, 40)];
        [_cleanButton setImage:[UIImage imageNamed:@"clean"] forState:UIControlStateNormal];
        [_cleanButton addTarget:self action:@selector(cleanbtnDidClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _cleanButton;
}
-(UIImageView *)chatbgView
{
    if (_chatbgView==nil) {
        _chatbgView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, ScreenW, 1.25*ScreenW)];
        _chatbgView.image=[UIImage imageNamed:@"markvideoBg"];
    }
    return _chatbgView;
}


@end
