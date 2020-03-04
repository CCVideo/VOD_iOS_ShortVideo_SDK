//
//  DWShortShootingViewController.m
//  ShortVideoDemo
//
//  Created by zwl on 2019/9/11.
//  Copyright © 2019 Myself. All rights reserved.
//

#import "DWShortShootingViewController.h"
#import "DWShootingBottomView.h"
#import "DWBeautyView.h"
#import "DWFilterView.h"
#import "DWDelayView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "DWShortVideoEditViewController.h"
#import "DWGPUImageBrightnessFilter.h"
#import "DWShortVideoCropViewController.h"
#import "DWShortImagePickerViewController.h"

@interface DWShortShootingViewController ()<DWShootingBottomViewDelegate,DWBeautyViewDelegate,DWFilterViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property(nonatomic,strong)UIButton * resumeButton;

@property(nonatomic,strong)GPUImageVideoCamera * videoCamera;
@property(nonatomic,strong)GPUImageMovieWriter * movieWriter;
@property(nonatomic,strong)GPUImageView * filterView;
@property(nonatomic,assign)CGFloat zoomFactor;//变焦值

@property(nonatomic,strong)NSURL * videoURL;

@property(nonatomic,strong)NSString * videoLocalPath;//相对路径后缀

@property(nonatomic,assign)BOOL isRecording;//拍摄延迟
@property(nonatomic,assign)CGFloat notchTop;
@property(nonatomic,strong)DWShootingBottomView * bottomView;
@property(nonatomic,assign)BOOL isDelay;//拍摄延迟
@property(nonatomic,assign)NSInteger scale;//比例，默认0 9:16 1 3:4 2 1:1
@property(nonatomic,strong)DWBeautyView * beautyBgView;//美颜
@property(nonatomic,assign)BOOL isBeautyFilter;//是否添加美颜滤镜
@property(nonatomic,assign)BOOL isBilateralExist;//磨皮滤镜是否存在
@property(nonatomic,strong)DWFilterView * filterBgView;//滤镜
@property(nonatomic,strong)GPUImageBrightnessFilter * brightnessFilter;
@property(nonatomic,strong)DWGPUImageBrightnessFilter * bilateralFilter;
@property(nonatomic,strong)GPUImageFilter * filter;//滤镜

@property(nonatomic,strong)NSMutableArray * pathArray;

@property(nonatomic,strong)MBProgressHUD * hud;


//进度条
@property(nonatomic,assign)CGFloat viewX;
@property(nonatomic,assign)CGFloat viewY;
@property(nonatomic,assign)CGFloat totalTime;//总时长
@property(nonatomic,assign)CGFloat seconds;
@property(nonatomic,strong)NSMutableArray * viewArray;//进度条view
@property(nonatomic,strong)dispatch_source_t GCDtimer;//gcd定时器
@property(nonatomic,strong)NSMutableArray * secondsArray;

@property(nonatomic,strong)UIView * focusView;

@end

/**
 *注意 在info.plist文件设置麦克风 相机 相册 图片等权限
 *基于GPUImage 建议用cocoapods导入 也可手动导入 确保工程中只导入一次GPUImage
 GPUImage引入后 修改以下部分：
 1.GPUImageMovieWriter.h文件中添加isNeedBreakAudioWhiter属性
 
 @property (nonatomic, assign) BOOL isNeedBreakAudioWhiter;
 
 2.GPUImageMovieWriter.m文件中第377行代码修改如下：
 if (CMTIME_IS_INVALID(startTime))
 {
 if (_isNeedBreakAudioWhiter) {
 
 
 }else{
 
 runSynchronouslyOnContextQueue(_movieWriterContext, ^{
 if ((audioInputReadyCallback == NULL) && (assetWriter.status != AVAssetWriterStatusWriting))
 {
 [assetWriter startWriting];
 }
 [assetWriter startSessionAtSourceTime:currentSampleTime];
 startTime = currentSampleTime;
 
 });
 
 }
 
 }
 
 3.GPUImageMovieWriter初始化时设置 isNeedBreakAudioWhiter =YES;具体详情参见demo
 
 *上传用到了CC视频的点播SDK中的DWuploader 确保工程中只导入一次点播SDK 上传部分只是示例 详情可以参考点播Demo和文档
 */


@implementation DWShortShootingViewController

static const double FLOATTIME = 0.02;

static const NSInteger TIMESECONDS = 60;//默认60s

static const CGFloat VIEWHEIGHT = 5;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
            
    self.isDelay = NO;
    self.scale = 0;
    self.isRecording = NO;
    self.isBeautyFilter = NO;
    self.isBilateralExist = YES;
    self.zoomFactor = 1;
    
    [self initUI];

    //创建目录文件
    [self createShortVideoIfNotExist];
    //录制视频相关
    [self initCamera];
    
    //监听退到后台的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActive) name:UIApplicationWillResignActiveNotification object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    for (NSString * filePath in [self.pathArray copy]) {
        [self removeVideoWithPath:filePath];
    }
    
    [self hiddenAllView:NO];
    [self.bottomView setRecordTime:0];
    [self.bottomView setStyle:1];
    [self.bottomView resetRecordButtonStatus];
    
    [self.videoCamera startCameraCapture];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.videoCamera stopCameraCapture];
}

- (void)willResignActive
{
    if (self.isRecording) {
        [self stop];
    }
    
    [self.bottomView resetRecordButtonStatus];
    
    //关闭闪光灯
    UIButton * lightButton = (UIButton *)[self.view viewWithTag:100];
    lightButton.selected = NO;
    [self.videoCamera.inputCamera lockForConfiguration:nil];
    if ([self.videoCamera.inputCamera isTorchModeSupported:AVCaptureTorchModeOff]) {
        [self.videoCamera.inputCamera setTorchMode:AVCaptureTorchModeOff];
    }
    if ([self.videoCamera.inputCamera isFlashModeSupported:AVCaptureFlashModeOff]) {
        [self.videoCamera.inputCamera setFlashMode:AVCaptureFlashModeOff];
    }
    [self.videoCamera.inputCamera unlockForConfiguration];
}

-(UIView *)getFocusView
{
    UIView * focusView = [DWControl initViewWithFrame:CGRectMake(0, 0, 150, 150) BackgroundColor:[UIColor clearColor] Tag:0 AndAlpha:1];
    focusView.hidden = YES;
    focusView.layer.borderColor = [UIColor whiteColor].CGColor;
    focusView.layer.borderWidth = 3;
    focusView.layer.cornerRadius = focusView.frame.size.width / 2.0;
    [self.filterView addSubview:focusView];
    return focusView;
}

#pragma mark - public
- (void)createShortVideoIfNotExist
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *folderPath = [path stringByAppendingPathComponent:SHORTVIDEO];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];

    BOOL isDirExist = [fileManager fileExistsAtPath:folderPath];
    
    if(!isDirExist)
    {
        BOOL bCreateDir = [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
        if(!bCreateDir){
            NSLog(@"创建保存视频文件夹失败");
        }
    }else{
        for (NSString * fileName in [fileManager contentsOfDirectoryAtPath:folderPath error:NULL]) {
            [fileManager removeItemAtPath:[NSString stringWithFormat:@"%@/%@",folderPath,fileName] error:nil];
        }
    }

}

//录制保存的时候要保存
- (NSString *)getVideoSaveFilePathString:(NSString *)string addPathArray:(BOOL )isAdd
{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    path = [path stringByAppendingPathComponent:SHORTVIDEO];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    
    NSString *videoPath = [[path stringByAppendingPathComponent:nowTimeStr] stringByAppendingString:string];
    
    self.videoLocalPath =[NSString stringWithFormat:@"%@/%@",SHORTVIDEO,[nowTimeStr stringByAppendingString:string]];
    
    //本地路径后缀放入数组 用来做视频合成功能
    if (isAdd) {
        [self.pathArray addObject:videoPath];
    }
    return videoPath;
}

-(void)start
{
    //UI修改
    [self hiddenAllView:YES];
    [self.bottomView setStyle:2];
    
    if (self.isDelay) {
        //            __weak typeof(self) weakSelf = self;
        //开始延迟计时
        DWDelayView * delayView = [[DWDelayView alloc]init];
        [delayView beginAnimation];
        
        delayView.finish = ^{
            //进度条
               [self initProgressView];
               self.seconds = 0;
               
               [self gcdTimer];

               //开始录制
               [self initMovieWriter];
               
               [self.movieWriter startRecording];
        };
        return;
    }
        
    //进度条
    [self initProgressView];
    self.seconds = 0;
    
    //启动计时器
    [self gcdTimer];

    //开始录制
    [self initMovieWriter];
    [self.movieWriter startRecording];
}

-(void)stop
{
    //UI修改
//    [self hiddenAllView:NO];

    [self.bottomView setStyle:3];
    
    //移除定时器
    [self removeTimer];
    //暂停写入
    [self.movieWriter finishRecording];
    self.videoCamera.audioEncodingTarget = nil;
    
    [self.secondsArray addObject:[NSString stringWithFormat:@"%f",self.seconds]];

    //保存视频到本地
//    [self savePhotosAlbum:self.videoURL];

}

- (void)gcdTimer
{
    //使用GCD定时器
    NSTimeInterval period = FLOATTIME;
    dispatch_queue_t queue =dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    _GCDtimer =dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    dispatch_source_set_timer(_GCDtimer, DISPATCH_TIME_NOW, period * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    
    dispatch_source_set_event_handler(_GCDtimer, ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
//            NSLog(@"test %ld",self.viewArray.count);
            //回到主线程
            self.seconds += FLOATTIME;
            self.totalTime += FLOATTIME;
            UIView * view = [self.viewArray lastObject];
            view.frame = CGRectMake(self.viewX,self.viewY,self.seconds * (ScreenWidth / TIMESECONDS),VIEWHEIGHT);
        
            [self.bottomView setRecordTime:self.totalTime];
            
            NSNumber *number =[NSNumber numberWithFloat:self.totalTime];
        
            //   NSInteger integer =(NSInteger)totalTime;
            if ([number integerValue] >= TIMESECONDS) {
                
//                NSLog(@"结束时间%f%ld",self.totalTime,TIMESECONDS);
                [self stop];
            }
        });
    });
    dispatch_resume(_GCDtimer);
}

- (void)removeTimer{
    
    if (_GCDtimer) {
        dispatch_source_cancel(_GCDtimer);
        _GCDtimer =nil;
    }
}

-(void)cameraAddTargetWithType:(NSInteger)type
{
    //再添加新的滤镜效果前，首先移除响应链上的滤镜
    [self removeAllTarget];
    
    if (type == 0) {
        self.filter = nil;
    }
    
    //根据滤镜效果，添加合适的滤镜。
    //这里的滤镜效果仅供参考，更多效果请详见GPUImage功能介绍。
    if (type == 1) {
        GPUImageSaturationFilter * saturationFilter = [[GPUImageSaturationFilter alloc]init];
        saturationFilter.saturation = 2;
        self.filter = saturationFilter;
    }
    
    if (type == 2) {
        GPUImageSaturationFilter * saturationFilter = [[GPUImageSaturationFilter alloc]init];
        saturationFilter.saturation = 0.7;
        self.filter = saturationFilter;
    }
    
    if (type == 3) {
        GPUImageWhiteBalanceFilter * whiteBalanceFilter = [[GPUImageWhiteBalanceFilter alloc]init];
        whiteBalanceFilter.temperature = 4500;
        self.filter = whiteBalanceFilter;
    }
    
    if (type == 4) {
        GPUImageSepiaFilter * sepiaFilter = [[GPUImageSepiaFilter alloc]init];
        self.filter = sepiaFilter;
    }
    
    if (type == 5) {
        GPUImageExposureFilter * exposureFilter = [[GPUImageExposureFilter alloc]init];
        exposureFilter.exposure = 0.3;
        self.filter = exposureFilter;
    }
    
    //添加新的滤镜响应链
    if (self.filter) {
        if (self.isBeautyFilter) {
            if (self.isBilateralExist) {
                [self.videoCamera addTarget:self.filter];
                [self.filter addTarget:self.brightnessFilter];
                [self.brightnessFilter addTarget:self.bilateralFilter];
                [self.bilateralFilter addTarget:self.filterView];
            }else{
                [self.videoCamera addTarget:self.filter];
                [self.filter addTarget:self.brightnessFilter];
                [self.brightnessFilter addTarget:self.filterView];
            }
        }else{
            [self.videoCamera addTarget:self.filter];
            [self.filter addTarget:self.filterView];
        }
    }else{
        if (self.isBeautyFilter) {
            if (self.isBilateralExist) {
                [self.videoCamera addTarget:self.brightnessFilter];
                [self.brightnessFilter addTarget:self.bilateralFilter];
                [self.bilateralFilter addTarget:self.filterView];
            }else{
                [self.videoCamera addTarget:self.brightnessFilter];
                [self.brightnessFilter addTarget:self.filterView];
            }
        }else{
            [self.videoCamera addTarget:self.filterView];
        }
    }
}

//移除当前所有响应链
-(void)removeAllTarget
{
    for (id subTarget in self.videoCamera.targets) {
        if (subTarget != self.filterView && subTarget != self.movieWriter) {
            GPUImageFilter * filter = (GPUImageFilter *)subTarget;
            [self removeCurrentTarget:filter];
        }
    }
    
    [self.videoCamera removeAllTargets];
}

-(void)removeCurrentTarget:(GPUImageFilter *)filter
{
    for (id subTarget in filter.targets) {
        if (subTarget != self.filterView && subTarget != self.movieWriter) {
            GPUImageFilter * subFilter = (GPUImageFilter *)subTarget;
            [subFilter removeAllTargets];
        }
    }
    [filter removeAllTargets];
}

-(void)hiddenAllView:(BOOL)isHidden
{
    for (int i = 0; i < 4; i++) {
        UIButton * button = (UIButton *)[self.view viewWithTag:100 + i];
        button.hidden = isHidden;
    }
    
    if (self.isRecording) {
        self.resumeButton.hidden = YES;
        return;
    }
    self.resumeButton.hidden = !isHidden;
}

//保存到手机相册
- (void)savePhotosAlbum:(NSURL *)videoPathURL
{
    //必须调用延时的方法 否则可能出现保存失败的情况
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        
        if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:videoPathURL])
        {
            [library writeVideoAtPathToSavedPhotosAlbum:videoPathURL completionBlock:^(NSURL *assetURL, NSError *error)
             {

             }];
        }

    });

}

-(BOOL)removeVideoWithPath:(NSString *)filePath
{
    BOOL isSuccess = [DWShortTool dw_deleteFileWithFilePath:filePath];
    
    if (self.pathArray.count == 0) {
        return YES;
    }
    
    if (isSuccess) {

        [self.pathArray removeLastObject];
        
        UIView * view = [self.viewArray lastObject];
        [view removeFromSuperview];
        [self.viewArray removeLastObject];
                
        //要减去相应的录制时间
        double recordTime =[[self.secondsArray lastObject] doubleValue];
        self.totalTime -= recordTime;
        [self.secondsArray removeLastObject];
        [self.bottomView setRecordTime:self.totalTime];
        
//        NSLog(@"余下录制时间%f__%f",self.totalTime,recordTime);
    }
    
    
    return isSuccess;
}

//-(BOOL)isVerifyVideoWithUrl:(NSURL *)videoURL
//{
//    //验证视频是否合法、
//    //小于3分钟，大小小于100MB的视频
//    NSFileManager * fileManager = [NSFileManager defaultManager];
//    NSDictionary * fileAttr = [fileManager attributesOfItemAtPath:videoURL.absoluteString error:nil];
//    NSInteger fileSize = (NSInteger)[[fileAttr objectForKey:NSFileSize] longLongValue];
//    if (fileSize > 100 * 1024 * 1024) {
//        return NO;
//    }
//
//    AVAsset * asset = [AVAsset assetWithURL:videoURL];
//    CGFloat duration = asset.duration.value / asset.duration.timescale;
//    if (duration > 180) {
//        return NO;
//    }
//
//    return YES;
//}

#pragma mark - DWShootingBottomViewDelegate
//录制
-(void)DWShootingBottomViewRecordButtonAction:(BOOL)isSelect
{

    self.isRecording = isSelect;
    if (isSelect) {
        //开始录制
        [self start];

    }else{
        //结束录制
        [self stop];
    }
    
    [self hiddenAllView:YES];
}

//美颜
-(void)DWShootingBottomViewBeautyButtonAction
{
    if (!self.isBeautyFilter) {
        self.isBeautyFilter = YES;

        [self removeAllTarget];
        
        if (self.filter) {
            [self.videoCamera addTarget:self.filter];
            [self.filter addTarget:self.brightnessFilter];
            [self.brightnessFilter addTarget:self.bilateralFilter];
            [self.bilateralFilter addTarget:self.filterView];
        }else{
            [self.videoCamera addTarget:self.brightnessFilter];
            [self.brightnessFilter addTarget:self.bilateralFilter];
            [self.bilateralFilter addTarget:self.filterView];
        }
    }
    
    self.bottomView.hidden = YES;
    [self.beautyBgView show];
}

//滤镜
-(void)DWShootingBottomViewFilterButtonAction
{
    self.bottomView.hidden = YES;
    [self.filterBgView show];
}

//上传
-(void)DWShootingBottomViewUploadButtonAction
{
    DWShortImagePickerViewController * imagePickerViewController = [[DWShortImagePickerViewController alloc]init];
    [self presentViewController:imagePickerViewController animated:YES completion:nil];
}

//完成
-(void)DWShootingBottomViewFinishButtonAction
{
    if (self.isRecording) {
        [self stop];
    }
    
    //视频合成
    if (self.pathArray.count == 0) {
        [@"请录制视频" showAlert];
        return;
    }
    
    if (self.pathArray.count == 1) {
                
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.hud.removeFromSuperViewOnHide = YES;
//        self.hud.label.text = @"视频生成中";
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [self.hud hideAnimated:YES];

            DWShortVideoEditViewController * shortVideoEditVC = [[DWShortVideoEditViewController alloc]init];
            shortVideoEditVC.videoURL = [NSURL fileURLWithPath:self.pathArray.firstObject];
            [self presentViewController:shortVideoEditVC animated:YES completion:nil];
        });
        
      return;
    }
    
    //延迟执行，等待视频写入完成。
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        //合成视频输出路径
        NSString * path = [self getVideoSaveFilePathString:@".MOV" addPathArray:NO];

        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.hud.removeFromSuperViewOnHide = YES;
//        self.hud.label.text = @"视频生成中";

        [DWShortTool dw_compositeAndExportVideos:self.pathArray withVideoSize:CGSizeZero outPath:path outputFileType:AVFileTypeQuickTimeMovie presetName:AVAssetExportPresetHighestQuality didComplete:^(NSError *error, NSURL *compressionFileURL) {
            
            [self.hud hideAnimated:YES];
            
            if (!error) {
                                
                DWShortVideoEditViewController * shortVideoEditVC = [[DWShortVideoEditViewController alloc]init];
                shortVideoEditVC.videoURL = [NSURL fileURLWithPath:path];
                [self presentViewController:shortVideoEditVC animated:YES completion:nil];
            }else{
                [@"合成失败，请重试" showAlert];
            }
        }];
    });
}

//删除
-(void)DWShootingBottomViewDeleteButtonAction
{
    //删除
    NSString * filePath = [self.pathArray lastObject];
    if ([self removeVideoWithPath:filePath]) {
//        [@"删除成功" showAlert];
        
    }else{
//        [@"删除失败" showAlert];
    }
    
    if (self.pathArray.count <= 0) {
        [self hiddenAllView:NO];
        [self.bottomView setRecordTime:0];
        [self.bottomView setStyle:1];
        return;
    }

}

/*
#pragma mark - UINavigationControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info
{
    NSLog(@"%@",info);
    
    NSURL * videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
    
    if (![self isVerifyVideoWithUrl:videoURL]) {
        [@"视频不符合规范，请重新选择" showAlert];
        [picker dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    path = [path stringByAppendingPathComponent:SHORTVIDEO];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    
    NSString * outPath = [[path stringByAppendingPathComponent:nowTimeStr] stringByAppendingString:@".MOV"];
    
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.removeFromSuperViewOnHide = YES;
    hud.label.text = @"处理中，请稍后";
  
    [DWShortTool dw_compressionAndExportVideo:videoURL.absoluteString
                                  withOutPath:outPath
                               outputFileType:AVFileTypeQuickTimeMovie
                                   presetName:AVAssetExportPresetHighestQuality
                                  didComplete:^(NSError *error, NSURL *compressionFileURL) {
        
        [hud hideAnimated:YES];

        [picker dismissViewControllerAnimated:YES completion:nil];
        
        if (error) {
            [@"处理失败，请重选选择视频" showAlert];
            return;
        }
        
        DWShortVideoCropViewController * shortCropVC = [[DWShortVideoCropViewController alloc]init];
        shortCropVC.videoURL = compressionFileURL;
        [self presentViewController:shortCropVC animated:YES completion:nil];
    
    }];
    
}
 */

#pragma mark - DWBeautyViewDelegate
//美白滤镜调整
-(void)DWBeautyViewWhiteValueChange:(NSInteger)value
{
    self.brightnessFilter.brightness = value / 600.0;
}

//磨皮滤镜调整
-(void)DWBeautyViewMicroderValueChange:(NSInteger)value
{
    if (value == 0 && self.isBilateralExist) {
        //删除磨皮滤镜
        self.isBilateralExist = NO;
        
        [self removeAllTarget];

        if (self.filter) {
            [self.videoCamera addTarget:self.filter];
            [self.filter addTarget:self.brightnessFilter];
            [self.brightnessFilter addTarget:self.filterView];
        }else{
            [self.videoCamera addTarget:self.brightnessFilter];
            [self.brightnessFilter addTarget:self.filterView];
        }

    }else if (value != 0 && !self.isBilateralExist){
        //添加磨皮滤镜
        self.isBilateralExist = YES;

        [self removeAllTarget];

        if (self.filter) {
            [self.videoCamera addTarget:self.filter];
            [self.filter addTarget:self.brightnessFilter];
            [self.brightnessFilter addTarget:self.bilateralFilter];
            [self.bilateralFilter addTarget:self.filterView];
        }else{
            [self.videoCamera addTarget:self.brightnessFilter];
            [self.brightnessFilter addTarget:self.bilateralFilter];
            [self.bilateralFilter addTarget:self.filterView];
        }
        
    }
    
    if (!self.isBilateralExist) {
        return;
    }
    
    self.bilateralFilter.beautyLevel = value / 100.0;
}

-(void)DWBeautyViewDismiss
{
    self.bottomView.hidden = NO;
}

#pragma mark - DWFilterViewDelegate
-(void)DWFilterViewFinishWithIndex:(NSInteger)index
{
    //0无 额外滤镜 1清新 2淡雅 3白皙 4复古 5微光
    [self cameraAddTargetWithType:index];
}

-(void)DWFilterViewDismiss
{
    self.bottomView.hidden = NO;
}

#pragma mark - action
-(void)topFuncButtonAction:(UIButton *)button
{
    if (button.tag == 100) {
        //闪光灯
        //前置摄像头不打开闪光灯
        if (self.videoCamera.inputCamera.position == AVCaptureDevicePositionFront) {
            return;
        }
  
        button.selected = !button.selected;
        if (self.videoCamera.inputCamera.position == AVCaptureDevicePositionBack) {
            if (self.videoCamera.inputCamera.torchMode ==AVCaptureTorchModeOn) {
                [self.videoCamera.inputCamera lockForConfiguration:nil];
                [self.videoCamera.inputCamera setTorchMode:AVCaptureTorchModeOff];
                [self.videoCamera.inputCamera setFlashMode:AVCaptureFlashModeOff];
                [self.videoCamera.inputCamera unlockForConfiguration];
            }else{
                [self.videoCamera.inputCamera lockForConfiguration:nil];
                [self.videoCamera.inputCamera setTorchMode:AVCaptureTorchModeOn];
                [self.videoCamera.inputCamera setFlashMode:AVCaptureFlashModeOn];
                [self.videoCamera.inputCamera unlockForConfiguration];
            }
        }
    }
    if (button.tag == 101) {
        //计时器
        button.selected = !button.selected;
        
        self.isDelay = button.selected;
    }
    if (button.tag == 102) {
        //前后摄像头
        [self.videoCamera rotateCamera];
          
        UIButton * preButton = (UIButton *)[self.view viewWithTag:100];
        preButton.selected = NO;
    }
    /*
    if (button.tag == 102) {
        //比例
        if (self.scale == 0) {
            [button setBackgroundImage:[UIImage imageNamed:@"icon_scale_3_4.png"] forState:UIControlStateNormal];
            self.scale = 1;
        }else if (self.scale == 1) {
            [button setBackgroundImage:[UIImage imageNamed:@"icon_scale_1_1.png"] forState:UIControlStateNormal];
            self.scale = 2;
        }else if (self.scale == 2) {
            [button setBackgroundImage:[UIImage imageNamed:@"icon_scale_16_9.png"] forState:UIControlStateNormal];
            self.scale = 0;
        }
    }
    if (button.tag == 103) {
        //前后摄像头
        [self.videoCamera rotateCamera];
        
        UIButton * preButton = (UIButton *)[self.view viewWithTag:100];
        preButton.selected = NO;
    }
     */
}

-(void)resumeButtonAction
{
    if (self.isRecording) {
        [self stop];
    }
    
    for (NSString * filePath in [self.pathArray copy]) {
        [self removeVideoWithPath:filePath];
        
    }
    
    [self hiddenAllView:NO];
    [self.bottomView setRecordTime:0];
    [self.bottomView setStyle:1];
}

-(void)focusOntap:(UITapGestureRecognizer *)tap
{
    //对焦
    CGPoint point = [tap locationInView:self.view];
    
//    NSLog(@"对焦 %@",NSStringFromCGPoint(point));sc
    // 坐标转换
    CGPoint currentPoint = CGPointMake(point.y / ScreenHeight, 1 - point.x / ScreenWidth);
    if (self.videoCamera.cameraPosition == AVCaptureDevicePositionFront) {
        currentPoint = CGPointMake(currentPoint.x, 1 - currentPoint.y);
    }
    
    //添加聚焦提示
    if (self.focusView) {
        self.focusView.hidden = YES;
    }
    self.focusView = [self getFocusView];
    
    self.focusView.hidden = NO;
    self.focusView.center = point;
    [UIView animateWithDuration:0.5 animations:^{
        
        self.focusView.transform = CGAffineTransformMakeScale(0.4, 0.4);
        
    } completion:^(BOOL finished) {
        [self.focusView removeFromSuperview];
        self.focusView = nil;
    }];
    
    AVCaptureDevice * device = self.videoCamera.inputCamera;
    
    [device lockForConfiguration:nil];
//    [device setSubjectAreaChangeMonitoringEnabled:YES];
    
    if ([device isFocusPointOfInterestSupported] &&
        [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        [device setFocusPointOfInterest:currentPoint];
        [device setFocusMode:AVCaptureFocusModeAutoFocus];
    }
    if ([device isExposurePointOfInterestSupported] &&
        [device isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
        [device setExposurePointOfInterest:currentPoint];
        [device setExposureMode:AVCaptureExposureModeAutoExpose];
    }
    
    [device unlockForConfiguration];
}

#pragma mark - init
-(void)initUI
{
//    NSArray * normalImages = @[@"icon_light_close.png",@"icon_timing_close.png",@"icon_scale_16_9.png",@"icon_camera.png"];
    NSArray * normalImages = @[@"icon_light_close.png",@"icon_timing_close.png",@"icon_camera.png"];
    NSArray * selectImage = @[@"icon_light_open.png",@"icon_timing_open.png",@"",@""];
    
    CGFloat topSpace = (ScreenWidth - 39 * normalImages.count - 18 * 2) / (normalImages.count - 1);
    for (int i = 0; i < normalImages.count; i++) {
        UIButton * button = [DWControl initButtonWithFrame:CGRectZero ButtonType:UIButtonTypeCustom Title:nil Image:nil Target:self Action:@selector(topFuncButtonAction:) AndTag:100 + i];
        [button setBackgroundImage:[UIImage imageNamed:[normalImages objectAtIndex:i]] forState:UIControlStateNormal];
        if (i < 2) {
            [button setBackgroundImage:[UIImage imageNamed:[selectImage objectAtIndex:i]] forState:UIControlStateSelected];
        }
        [self.view addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(18 + (topSpace + 39) * i));
            make.top.equalTo(@(15 + self.notchTop));
            make.width.and.height.equalTo(@39);
        }];
    }
    
    self.resumeButton = [DWControl initButtonWithFrame:CGRectZero ButtonType:UIButtonTypeCustom Title:nil Image:@"icon_edit_close.png" Target:self Action:@selector(resumeButtonAction) AndTag:0];
    self.resumeButton.hidden = YES;
    [self.view addSubview:self.resumeButton];
    [self.resumeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@12);
        make.top.equalTo(@(15 + self.notchTop));
        make.width.and.height.equalTo(@30);
    }];
    
    self.bottomView = [[DWShootingBottomView alloc]init];
    self.bottomView.delegate = self;
    [self.bottomView setStyle:1];
    [self.view addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(@0);
        make.bottom.equalTo(@0);
        make.height.equalTo(@(44 + 75 + 44));
    }];
}

- (void)initCamera
{
    //录制相关
    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720
                                                      cameraPosition:AVCaptureDevicePositionBack];
    
    
    if ([self.videoCamera.inputCamera lockForConfiguration:nil]) {
        //自动对焦
        if ([self.videoCamera.inputCamera isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            [self.videoCamera.inputCamera setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        }
        //自动曝光
        if ([self.videoCamera.inputCamera isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
            [self.videoCamera.inputCamera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        }
        //自动白平衡
        if ([self.videoCamera.inputCamera isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {
            [self.videoCamera.inputCamera setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
        }
        
        [self.videoCamera.inputCamera unlockForConfiguration];
    }
    
    
    //输出方向为竖屏
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    //防止允许声音通过的情况下，避免录制第一帧黑屏闪屏
    [self.videoCamera addAudioInputsAndOutputs];
    self.videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    self.videoCamera.horizontallyMirrorRearFacingCamera = NO;
    
    //组合
//    [self cameraAddTargetWithType:0];
    
    [self.videoCamera addTarget:self.filterView];

    //相机开始运行
    [self.videoCamera startCameraCapture];
}

- (void)initMovieWriter
{
    //苹果默认是MOV格式
    NSString *path =[self getVideoSaveFilePathString:@".MOV" addPathArray:YES];
    unlink([path UTF8String]);
    self.videoURL = [NSURL fileURLWithPath:path];
    
    //写入
    CGSize size = CGSizeZero;
    if (self.scale == 0) {
        //9:16
        size = CGSizeMake(720.0, 1280.0);
    }else if (self.scale == 1){
        //3:4
        size = CGSizeMake(720.0, 960.0);
    }else{
        //1:1
        size = CGSizeMake(720.0, 720.0);
    }
    
    self.movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:self.videoURL size:size];
    
    //设置为liveVideo
    self.movieWriter.isNeedBreakAudioWhiter =YES;
    self.movieWriter.encodingLiveVideo = YES;
    self.movieWriter.shouldPassthroughAudio =YES;
 
    if (self.filter) {
        if (self.isBeautyFilter) {
            if (self.isBilateralExist) {
                [self.bilateralFilter addTarget:self.movieWriter];
            }else{
                [self.brightnessFilter addTarget:self.movieWriter];
            }
        }else{
            [self.filter addTarget:self.movieWriter];
        }
    }else{
        if (self.isBeautyFilter) {
            if (self.isBilateralExist) {
                [self.bilateralFilter addTarget:self.movieWriter];
            }else{
                [self.brightnessFilter addTarget:self.movieWriter];
            }
        }else{
            [self.videoCamera addTarget:self.movieWriter];
        }
    }
    
    //设置声音
    self.videoCamera.audioEncodingTarget = self.movieWriter;
}

- (void)initProgressView
{
    UIView *view = [[UIView alloc]init];
    view.backgroundColor = [UIColor colorWithRed:255/255.0 green:149/255.0 blue:32/255.0 alpha:1.0];
    [self.view addSubview:view];
    
    self.viewX = self.viewArray.count > 0 ? CGRectGetMaxX([[self.viewArray lastObject] frame]) + 2 : 0;
    self.viewY = self.notchTop > 0 ? self.notchTop + 10 : self.notchTop;
    [self.viewArray addObject:view];
}

-(CGFloat)notchTop
{
    if (@available(iOS 11.0, *)) {
        return [[UIApplication sharedApplication] delegate].window.safeAreaInsets.top > 0 ? 22 : 0;
    }
    return 0;
}

-(GPUImageView *)filterView
{
    if (!_filterView) {
        //显示view
        _filterView =[[GPUImageView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        [self.view insertSubview:_filterView atIndex:0];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(focusOntap:)];
        [_filterView addGestureRecognizer:tap];
        
//        UIPinchGestureRecognizer * pinch = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinchTap:)];
//        [_filterView addGestureRecognizer:pinch];
    }
    return _filterView;
}

-(DWBeautyView *)beautyBgView
{
    if (!_beautyBgView) {
        _beautyBgView = [[DWBeautyView alloc]init];
        _beautyBgView.delegate = self;
    }
    return _beautyBgView;
}

-(DWFilterView *)filterBgView
{
    if (!_filterBgView) {
        _filterBgView = [[DWFilterView alloc]init];
        _filterBgView.delegate = self;
    }
    return _filterBgView;
}

-(GPUImageBrightnessFilter *)brightnessFilter
{
    if (!_brightnessFilter) {
        _brightnessFilter = [[GPUImageBrightnessFilter alloc]init];
        _brightnessFilter.brightness = 50 / 600.0;
    }
    return _brightnessFilter;
}

- (DWGPUImageBrightnessFilter *)bilateralFilter
{
    if (!_bilateralFilter) {
        _bilateralFilter = [[DWGPUImageBrightnessFilter alloc]init];
    }
    return _bilateralFilter;
}

-(NSMutableArray *)pathArray
{
    if (!_pathArray) {
        _pathArray = [[NSMutableArray alloc]init];
    }
    return _pathArray;
}

-(NSMutableArray *)viewArray
{
    if (!_viewArray) {
        _viewArray = [[NSMutableArray alloc]init];
    }
    return _viewArray;
}

- (NSMutableArray *)secondsArray
{
    if (!_secondsArray) {
        _secondsArray =[NSMutableArray array];
    }
    return _secondsArray;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
