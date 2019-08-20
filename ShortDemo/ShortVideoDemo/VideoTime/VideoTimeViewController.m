//
//  VideoTimeViewController.m
//  ShortVideoDemo
//
//  Created by luyang on 2018/6/25.
//  Copyright © 2018年 Myself. All rights reserved.
//

#import "VideoTimeViewController.h"
#import "LYAVPlayerView.h"
#import "DWDragView.h"
#import "DWUploadViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "ShortVideoViewController.h"
#import "DWuploadModel.h"

static const CGFloat EDGE_EXTENSION_FOR_THUMB =20.0;
@interface VideoTimeViewController ()<UIScrollViewDelegate,LYVideoPlayerDelegate>{
    
   
    LYAVPlayerView *playerView;
    UIScrollView *scrollView;
    
    UIView *bottomView;
    UIButton *closeBtn;
    UIButton *playBtn;
    UIButton *uploadBtn;//上传
    
    CGFloat boderX;
    CGFloat boderWidth;
    
    UIView *topBorder;
    UIView *bottomBorder;
    
    DWDragView *leftDrgView;
    DWDragView *rightDrgView;
    
    UIView *lineView;
    CGFloat startPointX;
    CGFloat endPointX;
    CGFloat imgWidth;
    
    BOOL isDraggingLeftOverlayView;// 拖拽左侧编辑框
    BOOL isDraggingRightOverlayView;// 拖拽右侧编辑框
    
    CGFloat touchPointX;
    CGPoint rightStartPoint;
    CGPoint leftStartPoint;
    
    NSInteger startTime;// 编辑框内视频开始时间秒
    NSInteger endTime;// 编辑框内视频结束时间秒
   
    CGFloat videoTotalTime;
    
    NSInteger count;
    
    MBProgressHUD *hud;
    
    NSString *videoLocalPath;
}

@property (nonatomic,strong)NSMutableArray *framesArray;

@property (nonatomic,strong)NSMutableArray *videoArray;

@end

@implementation VideoTimeViewController

- (NSMutableArray *)videoArray{
    
    if (!_videoArray) {
        
        _videoArray =[NSMutableArray array];
    }
    
    return _videoArray;
}

- (NSMutableArray *)framesArray{
    
    if (!_framesArray) {
        
        _framesArray =[NSMutableArray array];
    }
    
    return _framesArray;
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBar.hidden =NO;
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        
        self.navigationController.interactivePopGestureRecognizer.enabled =NO;
    }
    
    self.navigationController.navigationBar.hidden =YES;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置AVAudioSession
    [self settingAudioSession];
    //创建视图
    [self initUI];
    //视频帧相关
    [self analysisVideoFrames];
    
    
    
}

- (void)settingAudioSession{

 NSError *categoryError = nil;
 BOOL success = [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&categoryError];
  if (!success)
  {
    NSLog(@"Error setting audio session category: %@", categoryError);
  }

  NSError *activeError = nil;
  success = [[AVAudioSession sharedInstance] setActive:YES error:&activeError];
  if (!success)
  {
    NSLog(@"Error setting audio session active: %@", activeError);
  }

 
}

- (void)initUI{
    
    self.view.backgroundColor =[UIColor whiteColor];
    
    playerView =[[LYAVPlayerView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-160)];
    playerView.delegate =self;
  //  playerView.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view addSubview:playerView];
    [playerView setURL:[NSURL fileURLWithPath:_filePath]];
    [playerView play];
    
    
    bottomView =[[UIView alloc]init];
    bottomView.backgroundColor =[UIColor whiteColor];
    UIPanGestureRecognizer *pan =[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(moveOverlayView:)];
    [bottomView addGestureRecognizer:pan];
    [self.view addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.mas_equalTo(playerView.mas_bottom).offset(15);
        make.left.width.mas_equalTo(self.view);
        make.height.mas_equalTo(70);
        
    }];
    
    closeBtn =[self creatBtnWithImage:@"close" selectImage:nil selector:@selector(closeClick)];
    [self.view addSubview:closeBtn];
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.top.mas_equalTo(self.view);
        make.width.height.mas_equalTo(45);
    }];
    
    
    playBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    [playBtn setTitle:@"播放" forState:UIControlStateNormal];
    [playBtn setTitle:@"暂停" forState:UIControlStateSelected];
    [playBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [playBtn addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playBtn];
    [playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(bottomView.mas_bottom).offset(10);
        make.height.width.mas_equalTo(65);
        
    }];
    
    uploadBtn =[self creatBtnWithImage:@"finish" selectImage:@"finish" selector:@selector(uploadClick)];
    [self.view addSubview:uploadBtn];
    uploadBtn.layer.cornerRadius =89/2/2;
    uploadBtn.layer.masksToBounds =YES;
    [uploadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(playBtn.mas_right).offset(53);
        make.centerY.mas_equalTo(playBtn);
        make.height.width.mas_equalTo(89/2);
        
    }];
    
    
   // 添加编辑框上下边线
    boderX = 25.0;
    boderWidth =ScreenWidth-50;
    topBorder =[[UIView alloc]initWithFrame:CGRectMake(25,0, boderWidth,2)];
    topBorder.backgroundColor =[UIColor orangeColor];
    [bottomView addSubview:topBorder];

    bottomBorder =[[UIView alloc]initWithFrame:CGRectMake(25,68, boderWidth,2)];
    bottomBorder.backgroundColor =[UIColor orangeColor];
    [bottomView addSubview:bottomBorder];
    
    
    scrollView =[[UIScrollView alloc]initWithFrame:CGRectMake(25,2,ScreenWidth-50,66)];
    scrollView.showsHorizontalScrollIndicator =NO;
    scrollView.bounces =NO;
    scrollView.delegate =self;
    [bottomView addSubview:scrollView];
    UIPanGestureRecognizer *scrollPan =[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(scrollPanAction:)];
    [scrollView addGestureRecognizer:scrollPan];
    
    // 添加左右编辑框拖动条
    leftDrgView =[[DWDragView alloc]initWithFrame:CGRectMake(-(ScreenWidth-25),0,ScreenWidth,70) isLeft:YES];
   
    leftDrgView.hitTestEdgeInsets =UIEdgeInsetsMake(0,-EDGE_EXTENSION_FOR_THUMB,0, -EDGE_EXTENSION_FOR_THUMB);
    [bottomView addSubview:leftDrgView];
    
    rightDrgView =[[DWDragView alloc]initWithFrame:CGRectMake(ScreenWidth-25,0,ScreenWidth,70) isLeft:NO];
    rightDrgView.hitTestEdgeInsets =UIEdgeInsetsMake(0, -EDGE_EXTENSION_FOR_THUMB, 0, -EDGE_EXTENSION_FOR_THUMB);
    [bottomView addSubview:rightDrgView];
    

    
    lineView =[[UIView alloc]initWithFrame:CGRectMake(27,2, 3,66)];
    lineView.backgroundColor =[UIColor whiteColor];
    [bottomView addSubview:lineView];
    
     startPointX =25;
     endPointX =ScreenWidth-25;
    
}


- (void)analysisVideoFrames{
    
    AVURLAsset *asset =[[AVURLAsset alloc]initWithURL:[NSURL fileURLWithPath:_filePath] options:nil];
    
    videoTotalTime =asset.duration.value/asset.duration.timescale;
    NSLog(@"视频总时长：_____%f",videoTotalTime);
    
    //获取帧率
    CGFloat fps =[[[asset tracksWithMediaType:AVMediaTypeVideo] firstObject] nominalFrameRate];
    
    NSLog(@"视频帧率_____%f",fps);
    AVAssetImageGenerator *generator =[[AVAssetImageGenerator alloc]initWithAsset:asset];
    generator.appliesPreferredTrackTransform =YES;
//    generator.requestedTimeToleranceBefore =kCMTimeZero;
 //   generator.requestedTimeToleranceAfter =kCMTimeZero;
    for (int i =1; i<= videoTotalTime; i++) {
       
        CMTime time =CMTimeMakeWithSeconds(i, fps);
        
        NSLog(@"时间结构体");
        CMTimeShow(time);
        NSValue *value =[NSValue valueWithCMTime:time];
        [self.framesArray addObject:value];
        
    }
    
    //自定义imageView的宽
     if (self.framesArray.count <=5) {
        
        imgWidth =scrollView.frame.size.width/self.framesArray.count;
        
    }else{
    
        imgWidth =50;
    }
    
   
    NSLog(@"imgWidth:%f___%@",imgWidth,self.framesArray);
    
    [generator generateCGImagesAsynchronouslyForTimes:self.framesArray completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        
        if (result ==AVAssetImageGeneratorSucceeded) {
            
            UIImageView *imageView =[[UIImageView alloc]initWithFrame:CGRectMake(imgWidth*count,0,imgWidth,66)];
            imageView.image =[UIImage imageWithCGImage:image];
            //主线程刷新UI
            dispatch_async(dispatch_get_main_queue(), ^{
                
               
                [scrollView addSubview:imageView];
                scrollView.contentSize =CGSizeMake(imgWidth*count, 0.0);
                
                
            });
            
            count++;
            
        }else if (result ==AVAssetImageGeneratorFailed){
            
            NSLog(@"出错了：%@",error.localizedDescription);
            
        }else if (result ==AVAssetImageGeneratorCancelled){
            
             NSLog(@"出错了：%@",error.localizedDescription);
        }
        
        
    }];
    
}

- (void)scrollPanAction:(UIPanGestureRecognizer *)panGesture{
   
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
            
            break;
            
        case UIGestureRecognizerStateChanged:{
            
            CGPoint point =[panGesture locationInView:scrollView];
            lineView.frame =CGRectMake(point.x-1.5,2,3,66);
            CGFloat seconds =(point.x -25)/scrollView.frame.size.width*videoTotalTime;
            [playerView seekToTime:seconds];
            
            
            
        }
        break;
            
        case UIGestureRecognizerStateEnded:
            
            break;
            
            
        default:
            break;
    }
    
    
    
}

//触摸手势
- (void)moveOverlayView:(UIPanGestureRecognizer *)gesture{
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:{
            
        
            
           BOOL isLeft =[leftDrgView pointInsideImageView:[gesture locationInView:leftDrgView]];
           BOOL isRight =[rightDrgView pointInsideImageView:[gesture locationInView:rightDrgView]];
          
           touchPointX =[gesture locationInView:bottomView].x;
            
            if (isLeft) {
                
                leftStartPoint =[gesture locationInView:bottomView];
                isDraggingLeftOverlayView =YES;
                isDraggingRightOverlayView =NO;
                
            }else if (isRight){
                
                rightStartPoint =[gesture locationInView:bottomView];
                isDraggingRightOverlayView =YES;
                isDraggingLeftOverlayView =NO;
            }
            
            
        }
            
            break;
            
        case UIGestureRecognizerStateChanged:{
            
            CGPoint point =[gesture locationInView:bottomView];
            //left
            if (isDraggingLeftOverlayView) {
                
                CGFloat deltaX =point.x -leftStartPoint.x;
                CGPoint center =leftDrgView.center;
                center.x +=deltaX;
                CGFloat durationTime =(ScreenWidth-50)*2/10;//最小范围2秒
                BOOL flag =(endPointX -point.x) >durationTime?YES:NO;
                
                if (center.x >=(25-ScreenWidth/2) && flag) {
                    
                    leftDrgView.center =center;
                    leftStartPoint =point;
                    
                    
                    //
                    boderX +=deltaX;
                    boderWidth -=deltaX;
                    
                    topBorder.frame =CGRectMake(boderX,0, boderWidth, 2);
                    bottomBorder.frame =CGRectMake(boderX,68, boderWidth,2);
                    
                    startPointX =point.x;
                    
                }
                
                lineView.frame =CGRectMake(boderX-6.5,2,3,66);
                
                
                startTime =round((point.x-25)/scrollView.frame.size.width*(videoTotalTime));
                [playerView seekToTime:startTime];
                NSLog(@"left_____seek:%ld____%f",(long)startTime,videoTotalTime);
                
            }else if (isDraggingRightOverlayView){
                
                //right
                CGFloat deltax =point.x -rightStartPoint.x;
                CGPoint center =rightDrgView.center;
                center.x +=deltax;
                
                //限定取值范围
                CGFloat durationTime =(ScreenWidth-50)*2/10;//最小范围2秒
                BOOL flag =(point.x -startPointX) >durationTime?YES:NO;
                
                if (center.x <=(ScreenWidth-25+ScreenWidth/2) && flag) {
                    
                    
                    rightDrgView.center =center;
                    rightStartPoint =point;
                   
                    boderWidth +=deltax;
                    topBorder.frame =CGRectMake(boderX,0, boderWidth,2);
                    bottomBorder.frame =CGRectMake(boderX,68, boderWidth,2);
                    
                    endPointX =point.x;
                }
                
                
                lineView.frame =CGRectMake(boderX+boderWidth+3.5,2,3,66);
                
                endTime =round((point.x -25)/scrollView.frame.size.width*(videoTotalTime));
                [playerView seekToTime:endTime];
                NSLog(@"right_____seek:%ld____%f",(long)endTime,videoTotalTime);
                
            }
                
            
            
            
        }
            
            break;
            
       case UIGestureRecognizerStateEnded:
            
            break;
            
        default:
            break;
    }
    
}

- (void)playAction:(UIButton *)btn{
    
    btn.selected =!btn.selected;
    if (btn.selected) {
        
         [playerView play];
        
    }else{
        
         [playerView pause];
    }
    
}

- (void)uploadClick{
    
    hud =[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text =@"视频裁剪中";
    
    //输出路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    path = [path stringByAppendingPathComponent:shortVideo];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    
    NSString *videoPath = [[path stringByAppendingPathComponent:nowTimeStr] stringByAppendingString:@".MOV"];
    
    videoLocalPath =[NSString stringWithFormat:@"%@/%@",shortVideo,[nowTimeStr stringByAppendingString:@".MOV"]];
    
    
    CMTime start =CMTimeMakeWithSeconds(startTime, playerView.player.currentTime.timescale);
    CMTime duration =CMTimeMakeWithSeconds((endTime -startTime),playerView.player.currentTime.timescale);
    
    CMTimeRange timeRange =CMTimeRangeMake(start, duration);
    NSLog(@"时间结构体");
    CMTimeShow(duration);
    //时长裁剪
    WeakSelf(self);
    [DWShortTool dw_videoTimeCropAndExportVideo:_filePath withOutPath:videoPath outputFileType:AVFileTypeQuickTimeMovie presetName:AVAssetExportPreset1280x720  range:timeRange didComplete:^(NSError *error, NSURL *compressionFileURL) {
        
        StrongSelf(self);
        [hud hideAnimated:YES];
        if (!error) {
            
            [self saveModelToVideoArray];
            [self savePhotosAlbum:compressionFileURL];
            [self turnNextViewController];
            
        }else{
            
            
            NSLog(@"区域剪辑出错:%@",error.localizedDescription);
        }
        
        
        
    }];
    
   
}

- (void)turnNextViewController{
    
    [playerView pause];
    
    DWUploadViewController *viewCtrl =[[DWUploadViewController alloc]init];
    [self.navigationController pushViewController:viewCtrl animated:YES];
}

- (void)closeClick{
    
    [self.navigationController popViewControllerAnimated:NO];
    
}

- (void)saveModelToVideoArray{
    
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


- (UIButton *)creatBtnWithImage:(NSString *)image selectImage:(NSString *)selectImage selector:(SEL)selctor{
    
    UIButton *btn =[UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:selectImage] forState:UIControlStateSelected];
    [btn addTarget:self action:selctor forControlEvents:UIControlEventTouchUpInside];
    return btn;
    
}

#pragma mark--------LYVideoPlayerDelegate------
//播放完毕
- (void)videoPlayerDidReachEnd:(LYAVPlayerView *)playerView{
    
    [playerView seekToTime:0];
    [playerView play];
}

#pragma mark--------UIScrollViewDelegate---------
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
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
                 
                 
             }];
        }
        
        
        
    });
    
    
    
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
