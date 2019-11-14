//
//  DWShortVideoCropViewController.m
//  ShortVideoDemo
//
//  Created by zwl on 2019/10/22.
//  Copyright © 2019 Myself. All rights reserved.
//

#import "DWShortVideoCropViewController.h"
#import "DWEditCropView.h"
#import "DWShortVideoEditViewController.h"

@interface DWShortVideoCropViewController ()<DWEditCropViewDelegate>

@property(nonatomic,assign)CGFloat notchTop;
@property(nonatomic,assign)CGFloat notchBottom;

@property(nonatomic,strong)AVPlayer * player;
@property(nonatomic,strong)AVPlayerLayer * playerLayer;
@property(nonatomic,strong)id timeObserverToken;
@property(nonatomic,assign)CGSize videoSize;//视频分辨率
@property(nonatomic,assign)CGRect videoBackground;//视频实际显示size

@property(nonatomic,strong)DWEditCropView * cropView;//裁剪

@property(nonatomic,strong)MBProgressHUD * hud;

@end

@implementation DWShortVideoCropViewController

-(instancetype)init
{
    if (self == [super init]) {
        self.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initUI];
    [self initPlayer];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.player play];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.player pause];
}

-(void)dealloc
{
    [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    [self.player removeTimeObserver:self.timeObserverToken];
}

-(NSString *)createFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    path = [path stringByAppendingPathComponent:SHORTVIDEO];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    
    NSString *videoPath = [[path stringByAppendingPathComponent:nowTimeStr] stringByAppendingString:@".MP4"];
    return videoPath;
}

//裁剪视频
-(void)cropWithVideoUrl:(NSURL *)videoUrl
{
    NSString *videoPath = [self createFilePath];
    
    CGPoint point = CGPointMake(self.cropView.scaleFrame.origin.x - self.videoBackground.origin.x, self.cropView.scaleFrame.origin.y - self.videoBackground.origin.y);
    
    [DWShortTool dw_videoSizeAndTimeCropAndExportVideo:videoUrl.absoluteString
                                                  size:self.cropView.scaleFrame.size
                                                 point:point
                                                 range:CMTimeRangeMake(self.cropView.start, self.cropView.duration)
                                             videoRate:self.cropView.speed
                                           withOutPath:videoPath
                                        outputFileType:AVFileTypeQuickTimeMovie
                                            presetName:AVAssetExportPresetHighestQuality
                                           didComplete:^(NSError *error, NSURL *compressionFileURL) {
        
        
        if (error) {
            [self.hud hideAnimated:YES];
            
            [error.localizedDescription showAlert];
            return;
        }
    
        //延迟0.5秒执行，否则可能会引起编辑失败的问题
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self fixSizeWithVideoUrl:compressionFileURL];
        });
        //剪辑完成，跳转编辑页面
//        [self.hud hideAnimated:YES];
//        DWShortVideoEditViewController * shortVideoEditVC = [[DWShortVideoEditViewController alloc]init];
//        shortVideoEditVC.videoURL = compressionFileURL;
//        [self presentViewController:shortVideoEditVC animated:YES completion:nil];
    }];
}

//修改视频分辨率
-(void)fixSizeWithVideoUrl:(NSURL *)videoUrl
{
    NSString *videoPath = [self createFilePath];
    
    CGSize videoSize = CGSizeMake(720, 1280);
    
    [DWShortTool dw_videoSizeChangeRenderAndExportVideo:videoUrl.absoluteString
                                              videoSize:videoSize
                                            withOutPath:videoPath
                                         outputFileType:AVFileTypeMPEG4
                                             presetName:AVAssetExportPresetHighestQuality
                                            didComplete:^(NSError *error, NSURL *compressionFileURL) {
        
        [self.hud hideAnimated:YES];
        
        if (error) {
            [error.localizedDescription showAlert];
            return;
        }
        
        //剪辑完成，跳转编辑页面
        DWShortVideoEditViewController * shortVideoEditVC = [[DWShortVideoEditViewController alloc]init];
        shortVideoEditVC.videoURL = compressionFileURL;
        [self presentViewController:shortVideoEditVC animated:YES completion:nil];
    }];
}

#pragma mark - action
-(void)leftButtonAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)nextButtonAction
{
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.removeFromSuperViewOnHide = YES;
    
    [self cropWithVideoUrl:self.videoURL];
}

#pragma mark - Observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus newStatus = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (newStatus)
        {
            case AVPlayerItemStatusUnknown:
            {
                break;
            }
            case AVPlayerItemStatusReadyToPlay:
            {
                [self.player play];
                break;
            }
            case AVPlayerItemStatusFailed:
            {
                [@"播放失败，请重试" showAlert];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self leftButtonAction];
                });
                break;
            }
        }
    }
}

#pragma mark - DWEditCropViewDelegate
-(void)DWEditCropViewDidChangeSpeed:(CGFloat)speed
{
    [self.player setRate:speed];
}

-(void)DWEditCropViewLeftButtonAction
{
    [self leftButtonAction];
}

-(void)DWEditCropViewNextButtonAction
{
    [self nextButtonAction];
}

#pragma mark - init
-(void)initUI
{
    self.view.backgroundColor = [UIColor blackColor];

    UIButton * leftButton = [DWControl initButtonWithFrame:CGRectZero ButtonType:UIButtonTypeCustom Title:nil Image:@"icon_back.png" Target:self Action:@selector(leftButtonAction) AndTag:0];
    [self.view addSubview:leftButton];
    [leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@12);
        make.top.equalTo(@(self.notchTop + 15));
        make.width.and.height.equalTo(@30);
    }];
    
    UIButton * nextButton = [DWControl initButtonWithFrame:CGRectZero ButtonType:UIButtonTypeCustom Title:@"下一步" Image:nil Target:self Action:@selector(nextButtonAction) AndTag:0];
    [nextButton setBackgroundImage:[[UIColor colorWithRed:255/255.0 green:149/255.0 blue:32/255.0 alpha:1.0] createImage] forState:UIControlStateNormal];
    [nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    nextButton.titleLabel.font = [UIFont systemFontOfSize:13];
    nextButton.layer.masksToBounds = YES;
    nextButton.layer.cornerRadius = 30 / 2.0;
    [self.view addSubview:nextButton];
    [nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@(-12));
        make.centerY.equalTo(leftButton);
        make.height.equalTo(@30);
        make.width.equalTo(@59);
    }];
    
    //剪辑
    self.cropView = [[DWEditCropView alloc]init];
    self.cropView.videoURL = self.videoURL;
    self.cropView.delegate = self;
    [self.view addSubview:self.cropView];
    
    [self.cropView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

}

-(void)initPlayer
{
    AVPlayerItem * item = [AVPlayerItem playerItemWithURL:self.videoURL];
    self.player = [[AVPlayer alloc]initWithPlayerItem:item];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.view.layer insertSublayer:self.playerLayer atIndex:0];
    
    __weak typeof(self) weakSelf = self;
    self.timeObserverToken = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        
        if (weakSelf.cropView) {
            [weakSelf.cropView seekToTime:CMTimeGetSeconds(time)];
        }
        
        if (CMTimeGetSeconds(time) == CMTimeGetSeconds(weakSelf.player.currentItem.duration)) {
            [weakSelf.player seekToTime:kCMTimeZero];
            [weakSelf.player play];
        }
    }];
    [self.player.currentItem addObserver:self
                              forKeyPath:@"status"
                                 options:NSKeyValueObservingOptionNew
                                 context:nil];
    
    
    CGFloat scale = (ScreenHeight - 200) / ScreenHeight;
    self.playerLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransformMake(scale, 0, 0, scale, 0, -100));
    
    self.cropView.videoScale = scale;
    
    AVURLAsset * asset = [AVURLAsset assetWithURL:self.videoURL];
    self.videoSize = asset.naturalSize;
}

-(CGFloat)notchTop
{
    if (@available(iOS 11.0, *)) {
        return [[UIApplication sharedApplication] delegate].window.safeAreaInsets.top > 0 ? 22 : 0;
    }
    return 0;
}

-(CGFloat)notchBottom
{
    if (@available(iOS 11.0, *)) {
        return [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0 ? 34 : 0;
    }
    return 0;
}

-(CGRect)videoBackground
{
    CGRect videoBackground = AVMakeRectWithAspectRatioInsideRect(self.videoSize, self.view.bounds);
    return videoBackground;
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
