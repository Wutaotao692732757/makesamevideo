//
//  mergerVC.m
//  avplayerCuter
//
//  Created by mac_w on 2016/11/29.
//  Copyright © 2016年 aee. All rights reserved.
//

#import "mergerVC.h"
#import <AVFoundation/AVFoundation.h>

@interface mergerVC ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property(nonatomic,strong)NSURL *outptVideoUrl;

@property(nonatomic,strong)UIImageView *playerView;

@property(nonatomic,strong)AVPlayer *player;
@property(nonatomic,strong)AVPlayerLayer  *playerLayer;

//保存并退出
@property(nonatomic,strong)UIButton *saveAndout;

@end

@implementation mergerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
  
    [self.view addSubview:self.mergerButton];
    
    [self.view addSubview:self.chooseViewButton];
    [self.view addSubview:self.playerView];
    [self.view addSubview:self.saveAndout];
    
}

-(void)chooseVideoS{
    
  
    
    
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    
    picker.delegate=self;
    picker.mediaTypes=[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    
    [self presentViewController:picker animated:YES completion:nil];
    
    
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSURL *videoURL=info[@"UIImagePickerControllerMediaURL"];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self.sourcePathARR addObject:videoURL];
        if (self.sourcePathARR.count==1) {
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                [SVProgressHUD showInfoWithStatus:@"请再选择一个视频"];
            });
            
        }
    }];
    
    
}



-(void)mergerButtonDidClicked{
    
    [SVProgressHUD show];
    
    if (self.sourcePathARR.count<2) {
        UIAlertController *alerVC=[UIAlertController alertControllerWithTitle:@"没有足够的视频" message:@"请添加两个以上视频" preferredStyle:UIAlertControllerStyleAlert];
        
        [self presentViewController:alerVC animated:YES completion:nil];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [alerVC dismissViewControllerAnimated:YES completion:nil];
        });
        
    }else{
        
        NSMutableArray *assetArr=[NSMutableArray array];
        for (NSURL *sourcePath in self.sourcePathARR) {
            AVAsset *asset = [AVAsset assetWithURL:sourcePath];
            [assetArr addObject:asset];
        }

        
        AVMutableComposition *mainComposition = [[AVMutableComposition alloc] init];
        AVMutableCompositionTrack *compositionVideoTrack = [mainComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        
        
        AVMutableCompositionTrack *soundtrackTrack = [mainComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        CMTime insertTime = kCMTimeZero;
        for(AVAsset *videoAsset in assetArr){
            [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:insertTime error:nil];
            
            [soundtrackTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:insertTime error:nil];
            
            // Updating the insertTime for the next insert
            insertTime = CMTimeAdd(insertTime, videoAsset.duration);
        }
      
        NSURL *outptVideoUrl = [NSURL fileURLWithPath:[self savePath]];
        
        AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mainComposition presetName:AVAssetExportPreset640x480];
        
        // Setting attributes of the exporter
        exporter.outputURL=outptVideoUrl;
        exporter.outputFileType = AVFileTypeMPEG4; //AVFileTypeQuickTimeMovie;
        exporter.shouldOptimizeForNetworkUse = YES;
        [exporter exportAsynchronouslyWithCompletionHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                //completion(exporter);
                AVAsset *asset=[AVAsset assetWithURL:outptVideoUrl];
                AVPlayerItem *item=[[AVPlayerItem alloc]initWithAsset:asset];
                
                _player = [[AVPlayer alloc] initWithPlayerItem:item];
                
                _playerLayer=[AVPlayerLayer playerLayerWithPlayer:_player];
                _playerLayer.frame=_playerView.bounds;
                [_playerView.layer addSublayer: _playerLayer];
                [_player play];
                NSLog(@"合成成功！---%@",outptVideoUrl);
                
                [SVProgressHUD showSuccessWithStatus:@"合成成功"];
                
            
                // [self exportDidFinish:exporter:assets];
            });
        }];
        
        
    }
    
}

-(void)saveAndoutButtonClicked{
    
    [SVProgressHUD show];
     UISaveVideoAtPathToSavedPhotosAlbum([self savePath] , self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self.navigationController popViewControllerAnimated:YES];
    });
 

    
   
 
}

-(void)video:(NSData *)image didFinishSavingWithError:(NSError*)error contextInfo:(void *)contextInfo{
    NSLog(@"保存成功");
    if(error!=nil){
        
    }else{
        [SVProgressHUD showSuccessWithStatus:@"保存成功,请在相册查看"];
    }
    
}


-(UIButton *)chooseViewButton{
    if (_chooseViewButton==nil) {
        _chooseViewButton=[[UIButton alloc]initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width-100), 400*(ScreenH/667.0), 100, 40)];
        [_chooseViewButton setTitle:@"选择视频" forState:UIControlStateNormal];
         [_chooseViewButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_chooseViewButton addTarget:self action:@selector(chooseVideoS) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _chooseViewButton;
}



-(UIButton *)mergerButton{
    
    if (_mergerButton==nil) {
        _mergerButton=[[UIButton alloc]initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width-100), 460*(ScreenH/667.0), 100, 40)];
        [_mergerButton setTitle:@"合成" forState:UIControlStateNormal];
        [_mergerButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_mergerButton addTarget:self action:@selector(mergerButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _mergerButton;
}

-(UIButton *)saveAndout{
    if (_saveAndout==nil) {
        _saveAndout=[[UIButton alloc]initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width-100), 510*(ScreenH/667.0), 100, 40)];
        
        [_saveAndout setTitle:@"保存并退出" forState:UIControlStateNormal];
        [_saveAndout setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_saveAndout addTarget:self action:@selector(saveAndoutButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        
        
    }
    
    return _saveAndout;
    
    
}




-(NSMutableArray *)sourcePathARR{
    
    if (_sourcePathARR==nil) {
        _sourcePathARR=[NSMutableArray array];
    }
    return _sourcePathARR;
}

-(UIImageView *)playerView{
    if (_playerView==nil) {
        _playerView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 400*(ScreenH/667.0))];
        _playerView.backgroundColor=[UIColor greenColor];
    }
    return _playerView;
}

-(NSString *)savePath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // Creating a full path and URL to the exported video
    NSString *outputVideoPath =  [documentsDirectory stringByAppendingPathComponent:
                                  [NSString stringWithFormat:@"mergeVideo-%@.mov",@"aaa"]];
    

    return outputVideoPath;
}

@end
