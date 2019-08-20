//
//  VideoSizeViewController.m
//  ShortVideoDemo
//
//  Created by luyang on 2018/6/29.
//  Copyright © 2018年 Myself. All rights reserved.
//

#import "VideoSizeViewController.h"
#import "DWImageView.h"
#import "ShortVideoViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "DWuploadModel.h"
#import "DWUploadViewController.h"
#import <AVFoundation/AVFoundation.h>




@interface VideoSizeViewController (){
    
    UIButton *customBtn;
    UIButton *firstBtn;
    UIButton *secondBtn;
    UIButton *thirdBtn;
    UIButton *fourBtn;
    CGFloat currentProportion;
    NSString *videoLocalPath;
    
    MBProgressHUD *hud;
    
    
    
}

@property (nonatomic,strong)DWImageView *DWImageView;

@property (nonatomic,strong)NSMutableArray *btnArray;

@property (nonatomic,strong)NSMutableArray *videoArray;

@property (nonatomic,copy)NSArray *proportionArray;

@end

@implementation VideoSizeViewController

- (NSMutableArray *)videoArray{
    
    if (!_videoArray) {
        
        _videoArray =[NSMutableArray array];
    }
    
    return _videoArray;
}

- (NSMutableArray *)btnArray{
    
    if (!_btnArray) {
        
        _btnArray =[NSMutableArray array];
    }
    
    return _btnArray;
    
}

- (void)viewWillAppear:(BOOL)animated{

  [super viewWillAppear:animated];

 if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
    
    self.navigationController.interactivePopGestureRecognizer.enabled =NO;
  }

   self.navigationController.navigationBar.hidden =YES;

}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBar.hidden =NO;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    
    
}

- (void)initUI{
    
    
    UIImage *image =[DWShortTool dw_getThumbnailImage:_filePath time:0];
    
    _DWImageView =[[DWImageView alloc]initWithFrame:CGRectMake(0,64, ScreenWidth, ScreenHeight-160)];
    _DWImageView.toCropImage =image;
    _DWImageView.showMidLines = YES;
    _DWImageView.needScaleCrop = YES;
    _DWImageView.showCrossLines = YES;
    _DWImageView.cornerBorderInImage = NO;
    _DWImageView.cropAreaCornerWidth = 44;
    _DWImageView.cropAreaCornerHeight = 44;
    _DWImageView.minSpace = 30;
    _DWImageView.cropAreaCornerLineColor = [UIColor whiteColor];
    _DWImageView.cropAreaBorderLineColor = [UIColor whiteColor];
    _DWImageView.cropAreaCornerLineWidth = 2;
    _DWImageView.cropAreaBorderLineWidth = 2;
    _DWImageView.cropAreaMidLineWidth = 20;
    _DWImageView.cropAreaMidLineHeight = 6;
    _DWImageView.cropAreaMidLineColor = [UIColor whiteColor];
    _DWImageView.cropAreaCrossLineColor = [UIColor whiteColor];
    _DWImageView.cropAreaCrossLineWidth = 1;
    _DWImageView.initialScaleFactor = .8f;
    [self.view addSubview:_DWImageView];
    
    
    customBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnArray addObject:customBtn];
    [customBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    customBtn.titleLabel.textAlignment =NSTextAlignmentCenter;
    [customBtn setTitle:@"自由" forState:UIControlStateNormal];
    [customBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [customBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateSelected];
    [self.view addSubview:customBtn];
    [customBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        
        make.top.mas_equalTo(_DWImageView.mas_bottom).offset(15);
        make.left.mas_equalTo(self.view);
        make.height.mas_equalTo(28);
        make.width.mas_equalTo(ScreenWidth/5);
        
    }];
    
    
    firstBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnArray addObject:firstBtn];
    [firstBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    firstBtn.titleLabel.textAlignment =NSTextAlignmentCenter;
    [firstBtn setTitle:@"4:3" forState:UIControlStateNormal];
    [firstBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [firstBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateSelected];
    [self.view addSubview:firstBtn];
    [firstBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(_DWImageView.mas_bottom).offset(15);
        make.left.mas_equalTo(customBtn.mas_right);
        make.height.mas_equalTo(28);
        make.width.mas_equalTo(ScreenWidth/5);
    }];
    
    secondBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnArray addObject:secondBtn];
    [secondBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    secondBtn.titleLabel.textAlignment =NSTextAlignmentCenter;
    [secondBtn setTitle:@"16:9" forState:UIControlStateNormal];
    [secondBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [secondBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateSelected];
    [self.view addSubview:secondBtn];
    [secondBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.height.width.mas_equalTo(firstBtn);
        make.left.mas_equalTo(firstBtn.mas_right);
        
    }];
    
    
    thirdBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnArray addObject:thirdBtn];
    [thirdBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    thirdBtn.titleLabel.textAlignment =NSTextAlignmentCenter;
    [thirdBtn setTitle:@"3:4" forState:UIControlStateNormal];
    [thirdBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [thirdBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateSelected];
    [self.view addSubview:thirdBtn];
    [thirdBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.height.width.mas_equalTo(firstBtn);
        make.left.mas_equalTo(secondBtn.mas_right);
        
    }];
    
    fourBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnArray addObject:fourBtn];
    [fourBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    fourBtn.titleLabel.textAlignment =NSTextAlignmentCenter;
    [fourBtn setTitle:@"1:1" forState:UIControlStateNormal];
    [fourBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [fourBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateSelected];
    [self.view addSubview:fourBtn];
    [fourBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.height.width.mas_equalTo(firstBtn);
        make.left.mas_equalTo(thirdBtn.mas_right);
        
    }];
    
    UIButton *uploadBtn =[self creatBtnWithImage:@"finish" selectImage:@"finish" selector:@selector(uploadClick)];
    [self.view addSubview:uploadBtn];
    uploadBtn.layer.cornerRadius =89/2/2;
    uploadBtn.layer.masksToBounds =YES;
    [uploadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.mas_equalTo(self.view.mas_right).offset(-30);
        make.top.mas_equalTo(firstBtn.mas_bottom).offset(15);
        make.height.width.mas_equalTo(89/2);
        
    }];
    
    
    UIButton *cancelBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    cancelBtn.titleLabel.textAlignment =NSTextAlignmentCenter;
    [cancelBtn addTarget:self action:@selector(cancelClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelBtn];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(self.view.mas_left).offset(30);
        make.top.mas_equalTo(uploadBtn);
        make.height.width.mas_equalTo(89/2);
    }];
    
    currentProportion =0;
    self.proportionArray =@[@0,@(4.0/3.0),@(16.0/9.0),@(3.0/4.0),@1];
    [self btnClick:secondBtn];
    
}

- (void)btnClick:(UIButton *)btn{
    
    for (UIButton *button in self.btnArray) {
        
        button.selected =NO;
    }
    
    btn.selected =YES;
    NSInteger index =[self.btnArray indexOfObject:btn];
    currentProportion =[self.proportionArray[index] floatValue];
    _DWImageView.cropAspectRatio =currentProportion;
    
}

- (void)cancelClick{
    
    [self.navigationController popViewControllerAnimated:NO];
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
    
    //获取裁剪区域
    CGRect rect  =[_DWImageView currentCroppedRect];
    
    WeakSelf(self);
    
    [DWShortTool dw_videoSizeCropAndExportVideo:_filePath withOutPath:videoPath outputFileType:AVFileTypeQuickTimeMovie  presetName:AVAssetExportPreset1280x720 size:rect.size point:rect.origin shouldScale:NO didComplete:^(NSError *error, NSURL *compressionFileURL) {
            
            StrongSelf(self);
            [hud hideAnimated:YES];
            
            if (!error) {
                
                [self saveModelToVideoArray];
                [self savePhotosAlbum:compressionFileURL];
                [self turnNextViewController];
                
            }else{
                
                NSLog(@"区域剪辑出错:%@",[error localizedDescription]);
            }
            
        }];
    
    
  
  /*
    //视频区域兼时长裁剪示例    注意取只范围不要超过视频时间范围
    CMTime start =CMTimeMakeWithSeconds(1,600);
    CMTime duration =CMTimeMakeWithSeconds(5,600);
    
    CMTimeRange timeRange =CMTimeRangeMake(start, duration);
    
    [DWShortTool dw_videoSizeAndTimeCropAndExportVideo:_filePath withOutPath:videoPath outputFileType:AVFileTypeQuickTimeMovie presetName:AVAssetExportPreset1280x720 size:rect.size point:rect.origin shouldScale:NO range:timeRange didComplete:^(NSError *error, NSURL *compressionFileURL) {
        
        StrongSelf(self);
        [hud hideAnimated:YES];
        
        
        if (!error) {
            
            [self saveModelToVideoArray];
            [self savePhotosAlbum:compressionFileURL];
            [self turnNextViewController];
            
        }else{
            
            NSLog(@"区域剪辑出错:%@",[error localizedDescription]);
        }
        
        
        
        
    }];
    
   */
    
        
}



- (void)turnNextViewController{
    
    DWUploadViewController *viewCtrl =[[DWUploadViewController alloc]init];
    [self.navigationController pushViewController:viewCtrl animated:YES];
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


- (UIButton *)creatBtnWithImage:(NSString *)image selectImage:(NSString *)selectImage selector:(SEL)selctor{
    
    UIButton *btn =[UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:selectImage] forState:UIControlStateSelected];
    [btn addTarget:self action:selctor forControlEvents:UIControlEventTouchUpInside];
    return btn;
    
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
