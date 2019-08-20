//
//  ShortVideoViewController.m
//  ShortVideoDemo
//
//  Created by luyang on 2017/7/28.
//  Copyright © 2017年 Myself. All rights reserved.
//

#import "ShortVideoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "GPUImage.h"

#import "DWUploadViewController.h"

#import "Util.h"
#import <Photos/Photos.h>
#import "DWuploadModel.h"

#import "ShortEditViewController.h"
#import "VideoTimeViewController.h"
#import "VideoSizeViewController.h"



NSString  *const shortVideo =@"ShortVideo";

static const NSInteger timeSeconds =10;//默认10s

static const double floatTime =0.02;

static const CGFloat viewHight =4.5;

@interface ShortVideoViewController ()<UIVideoEditorControllerDelegate,UINavigationControllerDelegate>{

    GPUImageVideoCamera *videoCamera;
    GPUImageOutput <GPUImageInput> *filter;
    GPUImageMovieWriter *movieWriter;
    GPUImageView *filterView;
    GPUImageMovie *movieFile;
    
    NSURL *videoURL;
    
    NSString *videoLocalPath;//相对路径后缀
    
    
    
    UIButton *closeBtn;//关闭
    UIButton *lightBtn;//闪光灯
    UIButton *cameraBtn;//摄像头
    UIButton *deleteBtn;//删除
    UIButton *recordBtn;//录制
    UIButton *uploadBtn;//上传
    UIButton *beautyBtn;//美颜
    
    UIButton *videoTimeBtn;//视长剪辑
    UIButton *videoCropBtn;//视频剪辑
    
    UIView *bottomView;
    UIView *backgroundView;
    
   
    
    CGFloat viewX;
    CGFloat viewY;
    double totalTime;//总时长
    
    BOOL isRecording;//是否在录制视频
    
    
    double seconds;
    
    MBProgressHUD *hud;
    
    

}

@property (nonatomic,strong)NSMutableArray *videoArray;

@property (nonatomic,strong)NSMutableArray *viewArray;

@property (nonatomic,strong)NSMutableArray *pathArray;

@property (nonatomic,strong)NSMutableArray *secondsArray;

@property (nonatomic,strong)dispatch_source_t GCDtimer;//gcd定时器




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

@implementation ShortVideoViewController


- (void)dealloc{

    [self removeTimer];
    
    NSLog(@"%@销毁了",[self description]);
    
}


- (BOOL)prefersStatusBarHidden{

    return YES;
}

- (void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden =YES;
   
}

- (void)viewWillDisappear:(BOOL)animated{

    [super viewWillDisappear:animated];
 
    self.navigationController.navigationBar.hidden =NO;
    

}

- (NSMutableArray *)videoArray{

    if (!_videoArray) {
        
        _videoArray =[NSMutableArray array];
    }

    return _videoArray;

}

- (NSMutableArray *)pathArray{

    if (!_pathArray) {
        
        
        _pathArray =[NSMutableArray array];
    }

    return _pathArray;
}

- (NSMutableArray *)viewArray{

    if (!_viewArray) {
        
        _viewArray =[NSMutableArray array];
    }


    return _viewArray;
}

- (NSMutableArray *)secondsArray{

    if (!_secondsArray) {
        
        _secondsArray =[NSMutableArray array];
    }
    
   return _secondsArray;

}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //创建目录文件
    [self createShortVideoIfNotExist];
    //录制视频相关
    [self initCamera];
    //UI界面
    [self initUI];
    //监听退到后台的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    
   
    

    
}




- (void)willResignActive{

  if (isRecording) {
        
        [self stopWrite];
    
    }
    
    
    
}

- (void)createShortVideoIfNotExist{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *folderPath = [path stringByAppendingPathComponent:shortVideo];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isDirExist = [fileManager fileExistsAtPath:folderPath isDirectory:&isDir];
    
    if(!(isDirExist && isDir))
    {
        BOOL bCreateDir = [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
        if(!bCreateDir){
            
            NSLog(@"创建保存视频文件夹失败");
        }
    }
}

- (void)initCamera{

    //录制相关
    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720
                                                      cameraPosition:AVCaptureDevicePositionBack];
    
    
    if ([videoCamera.inputCamera lockForConfiguration:nil]) {
        //自动对焦
        if ([videoCamera.inputCamera isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            [videoCamera.inputCamera setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        }
        //自动曝光
        if ([videoCamera.inputCamera isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
            [videoCamera.inputCamera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        }
        //自动白平衡
        if ([videoCamera.inputCamera isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {
            [videoCamera.inputCamera setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
        }
        
        [videoCamera.inputCamera unlockForConfiguration];
    }
    
    
    //输出方向为竖屏
    videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    //防止允许声音通过的情况下，避免录制第一帧黑屏闪屏
    [videoCamera addAudioInputsAndOutputs];
    videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    videoCamera.horizontallyMirrorRearFacingCamera = NO;

    
    //显示view
    filterView =[[GPUImageView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [self.view addSubview:filterView];
    //组合
//    filter = [[GPUImageBilateralFilter alloc] init];
//    [videoCamera addTarget:filter];
//    [filter addTarget:filterView];
    
    
    [videoCamera addTarget:filterView];
    //相机开始运行
    [videoCamera startCameraCapture];
    
}

- (void)initMovieWriter{
    
    //苹果默认是MOV格式
    NSString *path =[self getVideoSaveFilePathString:@".MOV" addPathArray:YES];
    unlink([path UTF8String]);
    videoURL =[NSURL fileURLWithPath:path];
    
    //写入
    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:videoURL size:CGSizeMake(720.0, 1280.0)];
    
    //设置为liveVideo
    movieWriter.isNeedBreakAudioWhiter =YES;
    movieWriter.encodingLiveVideo = YES;
    movieWriter.shouldPassthroughAudio =YES;
    
    
//  [filter addTarget:movieWriter];
    [videoCamera addTarget:movieWriter];

    //设置声音
    videoCamera.audioEncodingTarget = movieWriter;
    

}


- (void)initUI{
    
    
    bottomView =[[UIView alloc]initWithFrame:CGRectMake(0, ScreenHeight*3/4, ScreenWidth, ScreenHeight/4)];
    
    bottomView.backgroundColor =[UIColor whiteColor];
    [self.view addSubview:bottomView];
    
    
    closeBtn =[self creatBtnWithImage:@"close" selectImage:nil selector:@selector(closeClick)];
    [self.view addSubview:closeBtn];
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.top.mas_equalTo(self.view);
        make.width.height.mas_equalTo(45);
        
    }];
    
    cameraBtn =[self creatBtnWithImage:@"overturn_ic" selectImage:@"overturn_ic" selector:@selector(cameraClick)];
    [self.view addSubview:cameraBtn];
    [cameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.right.mas_equalTo(self.view.mas_right).offset(-15);
        make.bottom.mas_equalTo(filterView.mas_bottom).offset(-10-ScreenHeight/4);
        make.height.width.mas_equalTo(39);
        
        
    }];
    
    
    lightBtn =[self creatBtnWithImage:@"light_ic_on" selectImage:@"light_ic_off" selector:@selector(lightClick)];
    [self.view addSubview:lightBtn];
    [lightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.mas_equalTo(cameraBtn.mas_left).offset(-15);
        make.centerY.height.width.mas_equalTo(cameraBtn);
        
    }];
    
    beautyBtn =[self creatBtnWithImage:@"beauty_off" selectImage:@"beauty_on" selector:@selector(beautyClick)];
    [self.view addSubview:beautyBtn];
    [beautyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.centerY.height.width.mas_equalTo(cameraBtn);
        make.right.mas_equalTo(lightBtn.mas_left).offset(-15);
        
    }];
    
    
    backgroundView =[[UIView alloc]init];
    backgroundView.backgroundColor =[DWShortTool dw_colorWithHexString:@"#eeeeee"];
    [bottomView addSubview:backgroundView];
    [backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.width.centerX.mas_equalTo(bottomView);
        make.top.mas_equalTo(bottomView.mas_top);
        make.height.mas_equalTo(viewHight);
        
        
    }];
    
    
    
    
    recordBtn =[self creatBtnWithImage:@"recordBefore" selectImage:@"recording" selector:@selector(recordClick)];
    [bottomView addSubview:recordBtn];
    recordBtn.layer.cornerRadius =65/2;
    recordBtn.layer.masksToBounds =YES;
    [recordBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.centerX.mas_equalTo(bottomView);
        make.top.mas_equalTo(backgroundView.mas_bottom).offset(50);
        make.height.width.mas_equalTo(65);
        
        
        
    }];
    
    uploadBtn =[self creatBtnWithImage:@"finish" selectImage:@"finish" selector:@selector(uploadClick:)];
    [bottomView addSubview:uploadBtn];
    uploadBtn.tag =100;
    uploadBtn.layer.cornerRadius =89/2/2;
    uploadBtn.layer.masksToBounds =YES;
    [uploadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(recordBtn.mas_right).offset(53);
        make.centerY.mas_equalTo(recordBtn);
        make.height.width.mas_equalTo(89/2);
        
    }];
    
    
    deleteBtn =[self creatBtnWithImage:@"delete_ic" selectImage:@"delete_ic" selector:@selector(deleteClick)];
    deleteBtn.hidden =YES;
    [bottomView addSubview:deleteBtn];
    deleteBtn.layer.cornerRadius =89/2/2;
    deleteBtn.layer.masksToBounds =YES;
    [deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.mas_equalTo(recordBtn.mas_left).offset(-53);
        make.centerY.height.width.mas_equalTo(uploadBtn);
        
    }];
    
    
    videoTimeBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    videoTimeBtn.titleLabel.textAlignment =NSTextAlignmentCenter;
    [videoTimeBtn setTitle:@"视长剪辑" forState:UIControlStateNormal];
    [videoTimeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [videoTimeBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateSelected];
    videoTimeBtn.titleLabel.font =[UIFont systemFontOfSize:14];
    videoTimeBtn.tag =101;
    [videoTimeBtn addTarget:self action:@selector(uploadClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:videoTimeBtn];
    [videoTimeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
       make.top.mas_equalTo(backgroundView.mas_bottom).offset(10);
       make.left.mas_equalTo(self.view).offset(15);
        make.height.mas_equalTo(32);
        make.width.mas_equalTo(90);
    }];
    
    
    videoCropBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    videoCropBtn.titleLabel.textAlignment =NSTextAlignmentCenter;
    [videoCropBtn setTitle:@"视频剪辑" forState:UIControlStateNormal];
    [videoCropBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [videoCropBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateSelected];
    videoCropBtn.titleLabel.font =[UIFont systemFontOfSize:14];
    videoCropBtn.tag =102;
    [videoCropBtn addTarget:self action:@selector(uploadClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:videoCropBtn];
    [videoCropBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.height.width.mas_equalTo(videoTimeBtn);
        make.right.mas_equalTo(self.view).offset(-15);
        
        
    }];
    
}

- (void)initProgressView{

    
    
    UIView *view =[[UIView alloc]init];
    view.backgroundColor =[DWShortTool dw_colorWithHexString:@"#f9a54e"];
    [bottomView addSubview:view];
    
    viewX =self.viewArray.count >0?CGRectGetMaxX([[self.viewArray lastObject] frame])+2:0;
    viewY =CGRectGetMinY(backgroundView.frame);
    [self.viewArray addObject:view];
    
    
}


- (void)closeClick{

    if (isRecording) {
        
        [self stopWrite];
       
    }
   
    [videoCamera stopCameraCapture];
    [self.navigationController popViewControllerAnimated:YES];


}

- (void)cameraClick{
    
    cameraBtn.selected =!cameraBtn.selected;
    [videoCamera rotateCamera];
   
    if (videoCamera.inputCamera.position == AVCaptureDevicePositionFront){
    
        lightBtn.selected  =NO;
    
    }
    
    
}

- (void)lightClick{
    
    [self turnTorch];
}

-(void)turnTorch

{
    //前置摄像头不打开闪光灯
    if (videoCamera.inputCamera.position == AVCaptureDevicePositionFront) {
        
        return;
    }
    
    
   
   if (videoCamera.inputCamera.position == AVCaptureDevicePositionBack) {
       
      if (videoCamera.inputCamera.torchMode ==AVCaptureTorchModeOn) {
    
           [videoCamera.inputCamera lockForConfiguration:nil];
           [videoCamera.inputCamera setTorchMode:AVCaptureTorchModeOff];
           [videoCamera.inputCamera setFlashMode:AVCaptureFlashModeOff];
           [videoCamera.inputCamera unlockForConfiguration];
           
           lightBtn.selected =NO;
           
       }else{  
       
           [videoCamera.inputCamera lockForConfiguration:nil];
           [videoCamera.inputCamera setTorchMode:AVCaptureTorchModeOn];
           [videoCamera.inputCamera setFlashMode:AVCaptureFlashModeOn];
           [videoCamera.inputCamera unlockForConfiguration];
           
           
           lightBtn.selected =YES;
       
       }
        
       
        
    }
}

- (void)beautyClick{

    beautyBtn.selected =!beautyBtn.selected;
    if (beautyBtn.selected) {
        
        // 移除之前所有的处理链
        [videoCamera removeAllTargets];
        
        // 创建美颜滤镜
        filter = [[GPUImageBilateralFilter alloc] init];
        
        // 设置GPUImage处理链，从数据->滤镜->界面展示
        [videoCamera addTarget:filter];
        [filter addTarget:filterView];
        
        
        
        
    }else{
        
        // 移除之前所有的处理链
        [videoCamera removeAllTargets];
        [videoCamera addTarget:filterView];
    
    
    
    }
    
   
}

- (void)recordClick{

    recordBtn.selected =!recordBtn.selected;
    
    if (recordBtn.selected) {
        
        //开始录制
        [self starWrite];
       
        
       }else{
    
        [self stopWrite];
      
       
    }
    
}

//上传到服务器
- (void)uploadClick:(UIButton *)btn{
    
   
    
    btn.selected =!btn.selected;
    
    if (isRecording) {

        [self stopWrite];
       // [videoCamera stopCameraCapture];

    }
    //调用延时的方法 否则会出现诡异的bug
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    
        //合成视频输出路径
        NSString *path =[self getVideoSaveFilePathString:@".MOV" addPathArray:NO];
        
        NSLog(@"合成视频数组:%@",self.pathArray);
        hud =[MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.label.text =@"视频生成中";
        
        WeakSelf(self);
        [DWShortTool dw_mergeAndExportVideos:self.pathArray withOutPath:path outputFileType:AVFileTypeQuickTimeMovie presetName:AVAssetExportPreset1280x720      didComplete:^(NSError *error,NSURL *mergeFileURL) {
            
            StrongSelf(self);
            
            [hud hideAnimated:YES];
            
            if (!error) {
                
                NSLog(@"输出路径%@____%@",mergeFileURL.path,path);
                [self saveModelToVideoArray];
                //   [self savePhotosAlbum:mergeFileURL];
                [self turnNextViewControllerWithVideoURL:mergeFileURL tag:btn.tag];
                
                
            }else{
                
                
                NSLog(@"%@",[error localizedDescription]);
            }
            
        }];
        
    });
    
  
    
}


- (void)turnNextViewControllerWithVideoURL:(NSURL *)pathURL tag:(NSInteger)btnTag{

    dispatch_async(dispatch_get_main_queue(), ^{
        
       
        //清空
        [self.pathArray removeAllObjects];
        deleteBtn.hidden =YES;
        //视图清空
        for (UIView *view in self.viewArray) {
            
            [view removeFromSuperview];
        }
        [self.viewArray removeAllObjects];
        [self.secondsArray removeAllObjects];
        
        videoTimeBtn.selected =NO;
        videoCropBtn.selected =NO;
        
        //归零
        seconds =0.00;
        totalTime =0.00;
        
        if (btnTag ==100) {
            
            DWUploadViewController *viewCtrl =[[DWUploadViewController alloc]init];
            [self.navigationController pushViewController:viewCtrl animated:YES];
            
        }else if (btnTag ==101){
            
            
            //视频时长剪辑
            VideoTimeViewController *viewCtrl =[[VideoTimeViewController alloc]init];
            viewCtrl.filePath =pathURL.path;
            
            [self.navigationController pushViewController:viewCtrl animated:NO];
           
 //系统自带VideoEditor
//            UIVideoEditorController *viewCtrl =[[UIVideoEditorController alloc]init];
//            viewCtrl.videoPath =pathURL.path;
//            viewCtrl.delegate =self;
//            [self presentViewController:viewCtrl animated:YES completion:nil];

            
        }else{
            
            //视频区域剪辑
            VideoSizeViewController *viewCtrl =[[VideoSizeViewController alloc]init];
            viewCtrl.filePath =pathURL.path;
            [self.navigationController pushViewController:viewCtrl animated:NO];
            
        }
        
      
        
        
//        ShortEditViewController *viewCtrl =[[ShortEditViewController alloc]init];
//        viewCtrl.videoURL =pathURL;
//        [self.navigationController pushViewController:viewCtrl animated:YES];

    });
    
    



}

- (void)saveModelToVideoArray{
    
    
    NSLog(@"合成的数组为%ld",self.pathArray.count);
    self.videoArray =[[[NSUserDefaults standardUserDefaults] objectForKey:@"videoArray"] mutableCopy];
    
    //去重 用相对路径的后缀来判断
    for (NSDictionary *dic in self.videoArray) {
        
        DWuploadModel *model =[DWuploadModel mj_objectWithKeyValues:dic];
        
        if ([model.videoLocalPath isEqualToString:videoLocalPath]) {
            return;
        }
        
    }
    
    DWuploadModel *model =[[DWuploadModel alloc]init];
    //保存路径的后缀 再拼接成相对路径
    model.videoLocalPath =videoLocalPath;
    [self.videoArray addObject:[model mj_keyValues]];
    [[NSUserDefaults standardUserDefaults] setObject:self.videoArray forKey:@"videoArray"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
}

//删除文件 从最后一个开始删起
- (void)deleteClick{
    
    
    if (isRecording) {
        
        [self stopWrite];
    }
    
    
   
    //读取文件 做个比对
    [self readShortVideoFiles];
    
    NSString *filePath =[self.pathArray lastObject];
    BOOL isSuccess = [DWShortTool dw_deleteFileWithFilePath:filePath];
    if (isSuccess) {
        
        
        self.videoArray =[[[NSUserDefaults standardUserDefaults] objectForKey:@"videoArray"] mutableCopy];
        [self.videoArray removeLastObject];
        [[NSUserDefaults standardUserDefaults] setObject:self.videoArray forKey:@"videoArray"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self.pathArray removeLastObject];
        deleteBtn.hidden =self.pathArray.count>0?NO:YES;
        
        UIView *view =[self.viewArray lastObject];
        [view removeFromSuperview];
        [self.viewArray removeLastObject];
        
        NSLog(@"数组__%@__%@",self.pathArray,self.viewArray);
        
        //要减去相应的录制时间
        double recordTime =[[self.secondsArray lastObject] doubleValue];
        totalTime -=recordTime;
        [self.secondsArray removeLastObject];
        NSLog(@"余下录制时间%f__%f",totalTime,recordTime);
        
        
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"删除成功"
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        
        }else{
    
    
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"删除失败"
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    
    
    }
    
   
    [self readShortVideoFiles]; 
    
  
}

- (void)readShortVideoFiles{
    
    //读取Docunment下所有文件
    NSArray *fileList = [NSArray array]; 
    NSFileManager *fileManager =[NSFileManager defaultManager];
    NSError *error;
    //fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:shortVideo];
    fileList =[fileManager contentsOfDirectoryAtPath:documentsDirectory error:&error];
    NSLog(@"路径==%@,fileList%@___", documentsDirectory,fileList);
    
    
}


- (void)starWrite{
    
    deleteBtn.hidden =NO;
    beautyBtn.hidden =YES;
    [self initProgressView];
    
    isRecording =YES;
    seconds =0.00;
    
    [self initMovieWriter];
   
   dispatch_async(dispatch_get_main_queue(), ^{
       
       [movieWriter startRecording];
       [self gcdTimer];
       
   });
    
}


- (void)gcdTimer{


    //使用GCD定时器
    NSTimeInterval period =floatTime;
    dispatch_queue_t queue =dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    _GCDtimer =dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    dispatch_source_set_timer(_GCDtimer, DISPATCH_TIME_NOW, period * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    
    dispatch_source_set_event_handler(_GCDtimer, ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //回到主线程
            seconds +=floatTime;
            totalTime +=floatTime;
            UIView *view =[self.viewArray lastObject];
            view.frame =CGRectMake(viewX,viewY,seconds*(ScreenWidth/timeSeconds),viewHight);
            
            NSNumber *number =[NSNumber numberWithFloat:totalTime];
            
            //   NSInteger integer =(NSInteger)totalTime;
            
            if ([number integerValue] >=timeSeconds) {
                
                NSLog(@"结束时间%f%ld",totalTime,timeSeconds);
                
                [self stopWrite];
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

- (void)stopWrite{
    
    //因为GCDtimer较为精准 务必先调用移除定时器的方法 再调用停止录制的方法
    [self removeTimer];
    dispatch_async(dispatch_get_main_queue(), ^{
        //注意顺序
        [movieWriter finishRecording];
        [filter removeTarget:movieWriter];
        videoCamera.audioEncodingTarget = nil;
        
    });
    
    beautyBtn.hidden =NO;
    [self.secondsArray addObject:[NSString stringWithFormat:@"%f",seconds]];
    [self saveModelToVideoArray];
    
    recordBtn.selected =NO;
    
    isRecording =NO;
    
    [self savePhotosAlbum:videoURL];
    NSLog(@"录制时间为%f 当前时间为%f",seconds,totalTime);
        
}

//保存到手机相册
- (void)savePhotosAlbum:(NSURL *)videoPathURL{
    
  
    //必须调用延时的方法 否则可能出现保存失败的情况
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
      
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:videoPathURL])
        {
            [library writeVideoAtPathToSavedPhotosAlbum:videoPathURL completionBlock:^(NSURL *assetURL, NSError *error)
             {
                 /*
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     if (error) {
                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"保存失败"
                                                                        delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                         [alert show];
                         
                         
                     } else {
                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"保存成功"
                                                                        delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                         [alert show];
                         
                         
                         
                         
                     }
                 });
                  
                  */
             }];
        }
      
        
        
   });
    
  
    
}

- (UIButton *)creatBtnWithImage:(NSString *)image selectImage:(NSString *)selectImage selector:(SEL)selctor{

    UIButton *btn =[UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:selectImage] forState:UIControlStateSelected];
    [btn addTarget:self action:selctor forControlEvents:UIControlEventTouchUpInside];
    return btn;

}

//录制保存的时候要保存
- (NSString *)getVideoSaveFilePathString:(NSString *)string addPathArray:(BOOL )isAdd
{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    path = [path stringByAppendingPathComponent:shortVideo];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    
    NSString *videoPath = [[path stringByAppendingPathComponent:nowTimeStr] stringByAppendingString:string];
    
    videoLocalPath =[NSString stringWithFormat:@"%@/%@",shortVideo,[nowTimeStr stringByAppendingString:string]];
    
    
    
    //本地路径后缀放入数组 用来做视频合成功能
    if (isAdd) {
        
       [self.pathArray addObject:videoPath];
    }
    
    return videoPath;
    
}


#pragma mark----UIVideoEditorControllerDelegate------
//编辑成功后的Video被保存在沙盒的临时目录中
- (void)videoEditorController:(UIVideoEditorController *)editor didSaveEditedVideoToPath:(NSString *)editedVideoPath {
    
    NSLog(@"+++++++++++++++%@",editedVideoPath);
    [self savePhotosAlbum:[NSURL fileURLWithPath:editedVideoPath]];
    
    
}
// 编辑失败后调用的方法
- (void)videoEditorController:(UIVideoEditorController *)editor didFailWithError:(NSError *)error {
    
    NSLog(@"%@",error.description);
    
    
}
//编辑取消后调用的方法
- (void)videoEditorControllerDidCancel:(UIVideoEditorController *)editor {
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
