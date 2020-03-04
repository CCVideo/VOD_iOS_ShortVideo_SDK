//
//  DWShortVideoEditViewController.m
//  ShortVideoDemo
//
//  Created by zwl on 2019/9/16.
//  Copyright © 2019 Myself. All rights reserved.
//

#import "DWShortVideoEditViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "DWEditBeautyView.h"
#import "DWEditFilterView.h"
#import "DWStickerView.h"
#import "DWBubbleView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "DWAudioChooseView.h"
#import "DWInsertMusicView.h"
#import "DWGPUImageBrightnessFilter.h"
#import "LINConversionView.h"
#import "DWVideoTrimmerView.h"
#import "DWShortEditAndUploadViewController.h"

static CGFloat STICKEWIDTH = 180;
static CGFloat BUBBLEWIDTH = 180;

@interface DWShortVideoEditViewController ()<DWEditBeautyViewDelegate,DWEditFilterViewDelegate,DWInsertMusicViewDelegate,DWStickerViewDelegate,DWBubbleViewDelegate,LINConversionViewDelegate,DWVideoTrimmerViewDelegate>

@property(nonatomic,assign)CGFloat notchTop;
@property(nonatomic,assign)CGFloat notchBottom;

@property(nonatomic,strong)GPUImageView * filterView;
@property(nonatomic,strong)GPUImageMovie * movieFile;
@property(nonatomic,strong)NSTimer * timer;
@property(nonatomic,strong)AVPlayer * player;
@property(nonatomic,assign)BOOL isPlaying;

@property(nonatomic,assign)BOOL isBeautyFilter;//是否添加美颜滤镜
@property(nonatomic,assign)BOOL isBilateralExist;//磨皮滤镜是否存在
@property(nonatomic,strong)GPUImageBrightnessFilter * brightnessFilter;
@property(nonatomic,strong)DWGPUImageBrightnessFilter * bilateralFilter;
@property(nonatomic,strong)GPUImageFilter * filter;//滤镜

@property(nonatomic,assign)CMTime videoDuration;//视频总时长
@property(nonatomic,assign)CGSize videoSize;//视频分辨率
@property(nonatomic,assign)CGRect videoBackground;//视频实际显示size
@property(nonatomic,strong)UIView * editBgView;
@property(nonatomic,strong)UILabel * currentLabel;
@property(nonatomic,strong)UILabel * totalLabel;
@property(nonatomic,strong)UISlider * slider;

@property(nonatomic,strong)DWEditBeautyView * editBeautyView;//美颜
@property(nonatomic,strong)DWEditFilterView * editFilterView;//滤镜
//GPUImage视频输出
@property(nonatomic,strong)GPUImageMovie * writeMovieFile;
@property(nonatomic,strong)GPUImageMovieWriter * writeMovieWriter;

@property(nonatomic,strong)DWInsertMusicView * insertMusicView;//音乐
@property(nonatomic,strong)NSArray * musicListArray;//音频列表
@property(nonatomic,strong)NSDictionary * musicDict;//音乐数据

@property(nonatomic,strong)DWStickerView * stickerView;//贴纸
@property(nonatomic,strong)NSMutableArray * stickerArray;//贴纸数据

@property(nonatomic,strong)DWBubbleView * bubbleView;//气泡文字
@property(nonatomic,strong)NSMutableArray * bubbleArray;//气泡文字数据

@property(nonatomic,strong)DWShortEditAndUploadViewController * editAndUploadVC;

@property(nonatomic,assign)BOOL canEdit;//判断视频是否能被编辑
@property(nonatomic,assign)BOOL aleardyPresent;

@end

@implementation DWShortVideoEditViewController

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
    
    self.isBeautyFilter = NO;
    self.isBilateralExist = YES;
    self.isPlaying = NO;
    self.canEdit = YES;
    self.aleardyPresent = NO;
    
    [self initUI];
    
    [self initPlayer];
    
    //回到前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForegroundNotification) name:UIApplicationWillEnterForegroundNotification object:nil];
    //app退到后台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackgroundNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self play];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self pause];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

-(NSString *)formatSecondsToString:(NSInteger)seconds
{
    if (seconds < 0) {
        return @"00:00";
    }
    
    int m = (int)round(seconds / 60);
    int s = (int)round(seconds % 60);
    
    return [NSString stringWithFormat:@"%02d:%02d",m,s];
}

-(NSString *)createFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    path = [path stringByAppendingPathComponent:SHORTVIDEO];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    
//    NSString *videoPath = [[path stringByAppendingPathComponent:nowTimeStr] stringByAppendingString:@".MOV"];
    NSString *videoPath = [[path stringByAppendingPathComponent:nowTimeStr] stringByAppendingString:@".MP4"];

    return videoPath;
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
                [self.movieFile addTarget:self.filter];
                [self.filter addTarget:self.brightnessFilter];
                [self.brightnessFilter addTarget:self.bilateralFilter];
                [self.bilateralFilter addTarget:self.filterView];
            }else{
                [self.movieFile addTarget:self.filter];
                [self.filter addTarget:self.brightnessFilter];
                [self.brightnessFilter addTarget:self.filterView];
            }
        }else{
            [self.movieFile addTarget:self.filter];
            [self.filter addTarget:self.filterView];
        }
    }else{
        if (self.isBeautyFilter) {
            if (self.isBilateralExist) {
                [self.movieFile addTarget:self.brightnessFilter];
                [self.brightnessFilter addTarget:self.bilateralFilter];
                [self.bilateralFilter addTarget:self.filterView];
            }else{
                [self.movieFile addTarget:self.brightnessFilter];
                [self.brightnessFilter addTarget:self.filterView];
            }
        }else{
            [self.movieFile addTarget:self.filterView];
        }
    }
}

//移除当前所有响应链
-(void)removeAllTarget
{
    for (id subTarget in self.movieFile.targets) {
        if (subTarget != self.filterView) {
            GPUImageFilter * filter = (GPUImageFilter *)subTarget;
            [self removeCurrentTarget:filter];
        }
    }
    
    [self.movieFile removeAllTargets];
}

-(void)removeCurrentTarget:(GPUImageFilter *)filter
{
    for (id subTarget in filter.targets) {
        if (subTarget != self.filterView) {
            GPUImageFilter * subFilter = (GPUImageFilter *)subTarget;
//            [subFilter removeAllTargets];
            [self removeCurrentTarget:subFilter];
        }
    }
    [filter removeAllTargets];
}

-(DWVideoTrimmerView *)getTrimmerView:(DWVideoTrimmerViewStyle)style
{
    DWVideoTrimmerView * trimmerView = [[DWVideoTrimmerView alloc]init];
    trimmerView.videoURL = self.videoURL;
    trimmerView.delegate = self;
    trimmerView.style = style;
    [self.view addSubview:trimmerView];
    [trimmerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    return trimmerView;
}

//控制贴纸的编辑状态
-(void)controlStickerEdit:(LINConversionView *)conversionView
{
    for (NSDictionary * dict in self.stickerArray) {
        LINConversionView * view = (LINConversionView *)[dict objectForKey:@"object"];
        if (view == conversionView) {
            continue;
        }
        if (view.isEdit) {
            view.isEdit = NO;
        }
    }
}

//控制气泡文字编辑状态
-(void)controlBubbleEdit:(LINConversionView *)conversionView
{
    for (NSDictionary * dict in self.bubbleArray) {
        LINConversionView * view = (LINConversionView *)[dict objectForKey:@"object"];
        if (view == conversionView) {
            continue;
        }
        if (view.isEdit) {
            view.isEdit = NO;
        }
    }
}

-(void)play
{
    if (self.aleardyPresent) {
        return;
    }
    
    if (self.isPlaying) {
        return;
    }
    
    [self.movieFile startProcessing];
    
    [self startTimer];
    
    [self.player play];
    
    self.isPlaying = YES;
    
    if (self.insertMusicView) {
        [self.insertMusicView audioPlay];
    }
}

-(void)pause
{
    if (!self.isPlaying) {
         return;
     }
     
     [self.movieFile endProcessing];
     
     [self stopTimer];
     
     [self.player pause];
     
     self.isPlaying = NO;
     
     if (self.insertMusicView) {
         [self.insertMusicView audioPause];
     }
}

///获取视频的旋转角度
-(CGFloat)getAngleFromAffineTransform:(CGAffineTransform)transform
{
    CGAffineTransform _trans = transform;
    CGFloat rotate = atanf(_trans.b/_trans.a); //acosf(_trans.a);
//    NSLog(@"getAngleFromAffineTransform %f",rotate);
    if (_trans.a < 0 && _trans.b > 0) {
        rotate += M_PI;
    }else if(_trans.a <0 && _trans.b < 0){
        rotate -= M_PI;
    }
    return rotate;
}

//计算贴纸实际大小
-(CGFloat)getStickerSideLengthWithView:(UIView *)view
{
    CGRect frame = view.frame;
    CGAffineTransform transform = view.transform;
    
    CGFloat rotate = [self getAngleFromAffineTransform:transform];
    if (rotate >= 0 && rotate <= M_PI_2) {
    }else if (rotate > M_PI_2 && rotate <= M_PI){
        rotate = M_PI - rotate;
    }else if (rotate > M_PI && rotate <= -M_PI_2 * 3){
        rotate = -M_PI - rotate;
    }else{
        rotate = -rotate;
    }
    
    CGFloat L = frame.size.width;
    
    double size = L / (sin(rotate) + cos(rotate));
    
    return size;
}

#pragma mark - 视频处理
//添加美颜，滤镜
-(void)addFilterWithVideoUrl:(NSURL *)videoUrl
{
    if (!self.canEdit) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    self.editAndUploadVC = [[DWShortEditAndUploadViewController alloc]init];
    self.editAndUploadVC.didDismiss = ^{
        weakSelf.aleardyPresent = NO;
    };
    [self presentViewController:self.editAndUploadVC animated:YES completion:^{
        self.aleardyPresent = YES;
    }];
    
    //处理滤镜链
    GPUImageBrightnessFilter * writeBrightnessFilter = nil;
    DWGPUImageBrightnessFilter * writeBilateralFilter = nil;
    GPUImageFilter * writeFilter = nil;
        
    if (self.editBeautyView) {
        //美颜
        writeBrightnessFilter = [[GPUImageBrightnessFilter alloc]init];
        writeBrightnessFilter.brightness = self.brightnessFilter.brightness;
        
        if (self.isBilateralExist) {
            writeBilateralFilter = [[DWGPUImageBrightnessFilter alloc]init];
            writeBilateralFilter.beautyLevel = self.bilateralFilter.beautyLevel;
        }
    }
    
    if (self.editFilterView && self.filter) {
        //滤镜
        Class cls = [self.filter class];
        NSString * className = NSStringFromClass(cls);
        if ([className isEqualToString:@"GPUImageSaturationFilter"]) {
            GPUImageSaturationFilter * saturationFilter = (GPUImageSaturationFilter *)self.filter;
            GPUImageSaturationFilter * writeSaturationFilter = [[GPUImageSaturationFilter alloc]init];
            writeSaturationFilter.saturation = saturationFilter.saturation;
            writeFilter = writeSaturationFilter;
        }
        if ([className isEqualToString:@"GPUImageWhiteBalanceFilter"]) {
            GPUImageWhiteBalanceFilter * whiteBalanceFilter = (GPUImageWhiteBalanceFilter *)self.filter;
            GPUImageWhiteBalanceFilter * writeWhiteBalanceFilter = [[GPUImageWhiteBalanceFilter alloc]init];
            writeWhiteBalanceFilter.temperature = whiteBalanceFilter.temperature;
            writeFilter = writeWhiteBalanceFilter;
        }
        if ([className isEqualToString:@"GPUImageSepiaFilter"]) {
//            GPUImageSepiaFilter * sepiaFilter = (GPUImageSepiaFilter *)self.filter;
            GPUImageSepiaFilter * writeSepiaFilter = [[GPUImageSepiaFilter alloc]init];
            writeFilter = writeSepiaFilter;
        }
        if ([className isEqualToString:@"GPUImageExposureFilter"]) {
            GPUImageExposureFilter * exposureFilter = (GPUImageExposureFilter *)self.filter;
            GPUImageExposureFilter * writeExposureFilter = [[GPUImageExposureFilter alloc]init];
            writeExposureFilter.exposure = exposureFilter.exposure;
            writeFilter = writeExposureFilter;
        }
    }
    

    NSString * outPath = [self createFilePath];
    NSURL * outPathUrl = [NSURL fileURLWithPath:outPath];
    
    self.writeMovieFile = [[GPUImageMovie alloc]initWithURL:videoUrl];
    
    self.writeMovieWriter = [[GPUImageMovieWriter alloc]initWithMovieURL:outPathUrl size:self.movieFile.asset.naturalSize];
    self.writeMovieWriter.shouldPassthroughAudio = YES;
    
    //添加滤镜链
    GPUImageOutput * lastFilter = nil;
    if (writeBrightnessFilter) {
        [self.writeMovieFile addTarget:writeBrightnessFilter];
        if (writeBilateralFilter) {
            [writeBrightnessFilter addTarget:writeBilateralFilter];
            if (writeFilter) {
                [writeBilateralFilter addTarget:writeFilter];
                lastFilter = writeFilter;
            }else{
                lastFilter = writeBilateralFilter;
            }
        }else{
            lastFilter = writeBrightnessFilter;
        }
    }else{
        if (writeBilateralFilter) {
            [self.writeMovieFile addTarget:writeBilateralFilter];
            if (writeFilter) {
                [writeBilateralFilter addTarget:writeFilter];
                lastFilter = writeFilter;
            }else{
                lastFilter = writeBilateralFilter;
            }
        }else{
            if (writeFilter) {
                [self.writeMovieFile addTarget:writeFilter];
                lastFilter = writeFilter;
            }else{
                //原始数据
                lastFilter = nil;
            }
        }
    }
    
    if (!lastFilter) {
        //没有添加滤镜特效
        [self addMusicWithVideoUrl:videoUrl];
        return;
    }
    
    [lastFilter addTarget:self.writeMovieWriter];
    
    AVAsset * videoAsset = [AVAsset assetWithURL:videoUrl];
    if ([[videoAsset tracksWithMediaType:AVMediaTypeAudio] count] > 0) {
        self.writeMovieFile.audioEncodingTarget = self.writeMovieWriter;
    }else{
        self.writeMovieFile.audioEncodingTarget = nil;
    }

    [self.writeMovieFile enableSynchronizedEncodingUsingMovieWriter:self.writeMovieWriter];
    
    [self.writeMovieWriter startRecording];
    [self.writeMovieFile startProcessing];

    [self.writeMovieWriter setCompletionBlock:^{
        //延迟执行，等待数据文件写入完成。
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf addMusicWithVideoUrl:outPathUrl];
            weakSelf.writeMovieWriter = nil;
            weakSelf.writeMovieFile = nil;
        });
      }];
}

//添加音频
-(void)addMusicWithVideoUrl:(NSURL *)videoUrl
{
    if (!self.canEdit) {
        return;
    }
    
    //判断是否选择了音频
    BOOL select = NO;
    for (NSDictionary * dict in self.musicListArray) {
        if ([[dict objectForKey:@"isSelect"] boolValue]) {
            select = YES;
            break;
        }
    }
    
    if (!select) {
        self.musicDict = nil;
        [self addStickerWithVideoUrl:videoUrl];
        return;
    }
    
    //插入音频
    NSString * outPath = [self createFilePath];
    //        NSURL * outPathUrl = [NSURL fileURLWithPath:outPath];
    
    [DWShortTool dw_insertAudioAndExportVideo:videoUrl.absoluteString
                                withAudioPath:[self.musicDict objectForKey:@"audioPath"]
                               originalVolume:[[self.musicDict objectForKey:@"originalVolume"] floatValue]
                                 insertVolume:[[self.musicDict objectForKey:@"insertVolume"] floatValue]
                                    timeRange:CMTimeRangeMake([[self.musicDict objectForKey:@"start"] CMTimeValue], [[self.musicDict objectForKey:@"duration"] CMTimeValue])
                                      outPath:outPath
                               outputFileType:OUTPUTFILETYPE
                                   presetName:PRESETNAME
                                  didComplete:^(NSError *error, NSURL *compressionFileURL) {
        
        
        if (error) {
            
            [self.editAndUploadVC endEditWithSuccess:NO];
            
//            [error.localizedDescription showAlert];
            return;
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self addStickerWithVideoUrl:compressionFileURL];
        });
        
    }];
}

//添加视频水印
-(void)addStickerWithVideoUrl:(NSURL *)videoUrl
{
    if (!self.canEdit) {
        return;
    }
    
    //判断是否添加贴纸
    if (self.stickerArray.count == 0) {
        [self addBubbleVideoUrl:videoUrl];
        return;
    }
    
    NSString * outPath = [self createFilePath];
    
    NSArray * images = @[@"icon_sticker_1.png",@"icon_sticker_2.png",@"icon_sticker_3.png",@"icon_sticker_4.png",@"icon_sticker_5.png"];
    NSMutableArray * stickerImages = [NSMutableArray array];
    NSMutableArray * stickerImagePoints = [NSMutableArray array];
    NSMutableArray * stickerImageSizes = [NSMutableArray array];
    NSMutableArray * rotateAngles = [NSMutableArray array];
    NSMutableArray * timeRanges = [NSMutableArray array];
    
    for (NSDictionary * dict in self.stickerArray) {
        UIImage * stickerImage = [UIImage imageNamed:[images objectAtIndex:[[dict objectForKey:@"index"] integerValue]]];
        LINConversionView * conversionView = [dict objectForKey:@"object"];
        CGRect frame = conversionView.frame;
        CGAffineTransform transform = conversionView.transform;

        CGFloat rotate = [self getAngleFromAffineTransform:transform];
        CGFloat sizeLength = [self getStickerSideLengthWithView:conversionView];
        //计算偏移量
        CGFloat offset = (conversionView.frame.size.width - sizeLength) / 2.0;
        CGPoint offsetPoint = CGPointMake(frame.origin.x + offset, frame.origin.y + offset);
        //百分比
        CGPoint stickerImagePoint = CGPointMake((offsetPoint.x - self.videoBackground.origin.x) / self.videoBackground.size.width, (offsetPoint.y - self.videoBackground.origin.y) / self.videoBackground.size.height);
        CGSize stickerImageSize = CGSizeMake(sizeLength / self.videoBackground.size.width, sizeLength / self.videoBackground.size.height);

        CMTime start = [[dict objectForKey:@"start"] CMTimeValue];
        CMTime duration = [[dict objectForKey:@"duration"] CMTimeValue];
        //如果需要整个视频都添加贴纸，传kCMTimeZero即可。
        if (CMTimeCompare(duration, self.videoDuration) == 0) {
            duration = kCMTimeZero;
        }
        CMTimeRange timeRange = CMTimeRangeMake(start, duration);
        
        [stickerImages addObject:stickerImage];
        [stickerImagePoints addObject:[NSValue valueWithCGPoint:stickerImagePoint]];
        [stickerImageSizes addObject:[NSValue valueWithCGSize:stickerImageSize]];
        [rotateAngles addObject:[NSNumber numberWithFloat:rotate]];
        [timeRanges addObject:[NSValue valueWithCMTimeRange:timeRange]];
       
    }

    [DWShortTool dw_addStickerAndExportVideo:videoUrl.absoluteString
                           withStickerImages:stickerImages
                          stickerImagePoints:stickerImagePoints
                           stickerImageSizes:stickerImageSizes
                                rotateAngles:rotateAngles
                                  timeRanges:timeRanges
                                     outPath:outPath
                              outputFileType:OUTPUTFILETYPE
                                  presetName:PRESETNAME
                                 didComplete:^(NSError *error, NSURL *compressionFileURL) {
        
        if (error) {
            [self.editAndUploadVC endEditWithSuccess:NO];
            
            return;
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self addBubbleVideoUrl:compressionFileURL];
        });
        
    }];

}

//添加气泡文字
-(void)addBubbleVideoUrl:(NSURL *)videoUrl
{
    if (!self.canEdit) {
        return;
    }
    
    if (self.bubbleArray.count == 0) {
        [self.editAndUploadVC endEditWithSuccess:YES];
        
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library writeVideoAtPathToSavedPhotosAlbum:videoUrl completionBlock:^(NSURL *assetURL, NSError *error)
         {
            
        }];
        return;
    }
    
    NSString * outPath = [self createFilePath];

    NSMutableArray * bubbleImages = [NSMutableArray array];
    NSMutableArray * bubbleImagePoints = [NSMutableArray array];
    NSMutableArray * bubbleImageSizes = [NSMutableArray array];
    NSMutableArray * rotateAngles = [NSMutableArray array];
    NSMutableArray * timeRanges = [NSMutableArray array];
    for (NSDictionary * dict in self.bubbleArray) {
        LINConversionView * conversionView = [dict objectForKey:@"object"];
        CGRect frame = conversionView.frame;
        CGAffineTransform transform = conversionView.transform;
        
        CGFloat rotate = [self getAngleFromAffineTransform:transform];
        CGFloat sizeLength = [self getStickerSideLengthWithView:conversionView];

        //计算偏移量
        CGFloat offset = (conversionView.frame.size.width - sizeLength) / 2.0;
        CGPoint offsetPoint = CGPointMake(frame.origin.x + offset, frame.origin.y + offset);
        
        //获取贴纸所占视频区域的百分比
        CGPoint bubbleImagePoint = CGPointMake((offsetPoint.x - self.videoBackground.origin.x) / self.videoBackground.size.width, (offsetPoint.y - self.videoBackground.origin.y) / self.videoBackground.size.height);

        CGSize bubbleImageSize = CGSizeMake(sizeLength / self.videoBackground.size.width, sizeLength / self.videoBackground.size.height);
        
        CMTime start = [[dict objectForKey:@"start"] CMTimeValue];
        CMTime duration = [[dict objectForKey:@"duration"] CMTimeValue];
        //如果需要整个视频都添加贴纸，传kCMTimeZero即可。
        if (CMTimeCompare(duration, self.videoDuration) == 0) {
            duration = kCMTimeZero;
        }
        CMTimeRange timeRange = CMTimeRangeMake(start, duration);
        
        //生成贴纸图片
        [bubbleImages addObject:[self bubbleImageWithBubbleDict:dict]];
        [bubbleImagePoints addObject:[NSValue valueWithCGPoint:bubbleImagePoint]];
        [bubbleImageSizes addObject:[NSValue valueWithCGSize:bubbleImageSize]];
        [rotateAngles addObject:[NSNumber numberWithFloat:rotate]];
        [timeRanges addObject:[NSValue valueWithCMTimeRange:timeRange]];
    }

    [DWShortTool dw_addStickerAndExportVideo:videoUrl.absoluteString
                           withStickerImages:bubbleImages
                          stickerImagePoints:bubbleImagePoints
                           stickerImageSizes:bubbleImageSizes
                                rotateAngles:rotateAngles
     
                                  timeRanges:timeRanges
                                     outPath:outPath
                              outputFileType:OUTPUTFILETYPE
                                  presetName:PRESETNAME
                                 didComplete:^(NSError *error, NSURL *compressionFileURL) {
        if (error) {
            [self.editAndUploadVC endEditWithSuccess:NO];
            return;
        }
        [self.editAndUploadVC endEditWithSuccess:YES];
        
        //保存视频到本地相册
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library writeVideoAtPathToSavedPhotosAlbum:compressionFileURL completionBlock:^(NSURL *assetURL, NSError *error)
         {
            
        }];
    }];
}

//生成气泡文字图片
-(UIImage *)bubbleImageWithBubbleDict:(NSDictionary *)dict
{
    NSArray * images = @[@"icon_bubble_1.png",@"icon_bubble_2.png",@"icon_bubble_3.png",@"icon_bubble_4.png",@"icon_bubble_5.png"];
    //总体生成图片
    UIImage * bubbleImage = [UIImage imageNamed:[images objectAtIndex:[[dict objectForKey:@"index"] integerValue]]];
    LINConversionView * conversionView = [dict objectForKey:@"object"];
    DWBubbleInputView * inputView = (DWBubbleInputView *)conversionView.contentView;
    
    UIImageView * bubbleImageView = [[UIImageView alloc]init];
    
    CGFloat sizeLength = [self getStickerSideLengthWithView:conversionView];
    bubbleImageView.frame = CGRectMake(0, 0, sizeLength, sizeLength);
    bubbleImageView.image = bubbleImage;

    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(bubbleImageView.frame.size.width * 32 / BUBBLEWIDTH, bubbleImageView.frame.size.height * 102 / BUBBLEWIDTH, bubbleImageView.frame.size.width - (bubbleImageView.frame.size.width * 32 / BUBBLEWIDTH) * 2, bubbleImageView.frame.size.height * 49 / BUBBLEWIDTH)];
    label.text = inputView.placeholderLabel.text;
    label.font = inputView.placeholderLabel.font;
    label.textColor = inputView.placeholderLabel.textColor;
    label.textAlignment = inputView.placeholderLabel.textAlignment;
    label.numberOfLines = 2;
    label.adjustsFontSizeToFitWidth = YES;
    [bubbleImageView addSubview:label];
    
    UIGraphicsBeginImageContextWithOptions(bubbleImageView.bounds.size, NO, 0);
    
    if ([bubbleImageView respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        
        [bubbleImageView drawViewHierarchyInRect:bubbleImageView.bounds afterScreenUpdates:YES];
    }else{
        [bubbleImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - DWEditBeautyViewDelegate
-(void)DWEditBeautyViewWhiteValueChange:(NSInteger)value
{
    self.brightnessFilter.brightness = value / 600.0;
}

-(void)DWEditBeautyViewMicroderValueChange:(NSInteger)value
{
    if (value == 0 && self.isBilateralExist) {
        //删除磨皮滤镜
        self.isBilateralExist = NO;
        
        [self removeAllTarget];

        if (self.filter) {
            [self.movieFile addTarget:self.filter];
            [self.filter addTarget:self.brightnessFilter];
            [self.brightnessFilter addTarget:self.filterView];
        }else{
            [self.movieFile addTarget:self.brightnessFilter];
            [self.brightnessFilter addTarget:self.filterView];
        }

    }else if (value != 0 && !self.isBilateralExist){
        //添加磨皮滤镜
        self.isBilateralExist = YES;

        [self removeAllTarget];

        if (self.filter) {
            [self.movieFile addTarget:self.filter];
            [self.filter addTarget:self.brightnessFilter];
            [self.brightnessFilter addTarget:self.bilateralFilter];
            [self.bilateralFilter addTarget:self.filterView];
        }else{
            [self.movieFile addTarget:self.brightnessFilter];
            [self.brightnessFilter addTarget:self.bilateralFilter];
            [self.bilateralFilter addTarget:self.filterView];
        }
        
    }
    
    if (!self.isBilateralExist) {
        return;
    }
    self.bilateralFilter.beautyLevel = value / 100.0;
}

-(void)DWEditBeautyDismiss
{
    self.editBgView.hidden = NO;
}

#pragma mark - DWEditFilterViewDelegate
-(void)DWEditFilterSelectWithIndex:(NSInteger)index
{
    [self cameraAddTargetWithType:index];
}

-(void)DWEditFilterDismiss
{
    self.editBgView.hidden = NO;
}

#pragma mark - DWInsertMusicViewDelegate
-(void)DWInsertMusicOriginalVolumeValueChange:(CGFloat)originalVolume
{
    [self.player setVolume:originalVolume / 100.0];
}

-(void)DWInsertMusicViewDidFinishWithAudioPath:(NSString *)audioPath OriginalVolume:(CGFloat)originalVolume InsertVolume:(CGFloat)insertVolume StartTime:(CMTime)start DurationTime:(CMTime)duration
{
    //记录音频数据
    self.musicDict = @{@"audioPath":audioPath,
                       @"originalVolume":[NSNumber numberWithFloat:originalVolume],
                       @"insertVolume":[NSNumber numberWithFloat:insertVolume],
                       @"start":[NSValue valueWithCMTime:start],
                       @"duration":[NSValue valueWithCMTime:duration]};
    
    self.editBgView.hidden = NO;
}

-(void)DWInsertMusicDismiss
{
    self.editBgView.hidden = NO;
}

#pragma mark - DWStickerViewDelegate
-(void)DWStickerViewDidSelect:(NSInteger)index
{
    //清空气泡文字编辑状态
    [self controlBubbleEdit:nil];

//    新增贴纸
    NSArray * images = @[@"icon_sticker_1.png",@"icon_sticker_2.png",@"icon_sticker_3.png",@"icon_sticker_4.png",@"icon_sticker_5.png"];
    UIImageView * imageView = [[UIImageView alloc]init];
    imageView.image = [UIImage imageNamed:[images objectAtIndex:index]];
    imageView.frame = CGRectMake((ScreenWidth - STICKEWIDTH) / 2.0, (ScreenHeight - STICKEWIDTH) / 2.0, STICKEWIDTH, STICKEWIDTH);
    
    LINConversionView * conversionView = [[LINConversionView alloc]initWithContentView:imageView];
//    conversionView.scaleMode = LINConversionViewMode_Transform;
    conversionView.scaleMode = LINConversionViewMode_Bounds;

    conversionView.delegate = self;
    conversionView.needPan = YES;
    conversionView.needRotate = NO;
    conversionView.needPinch  = NO;
    conversionView.style = LINConversionViewStyle_Sticker;
    [conversionView setTransformCtrlImage:[UIImage imageNamed:@"icon_edit_scale.png"] resizeCtrlImage:[UIImage imageNamed:@"icon_edit_time.png"] rotateCtrlImage:[UIImage imageNamed:@"icon_edit_delete.png"]];
    [self.filterView addSubview:conversionView];
    
    [self.stickerArray addObject:[@{@"object":conversionView,@"start":[NSValue valueWithCMTime:kCMTimeZero],@"duration":[NSValue valueWithCMTime:kCMTimeZero],@"index":[NSNumber numberWithInteger:index],@"trimmer":[self getTrimmerView:DWVideoTrimmerViewStyle_Sticker]} mutableCopy]];
    [self controlStickerEdit:conversionView];
}

-(void)DWStickerViewDismiss
{
    self.editBgView.hidden = NO;

    self.stickerView = nil;
}

#pragma mark - DWBubbleViewDelegate
-(void)DWBubbleViewDidSelect:(NSInteger)index
{
    //清空水印状态
    [self controlStickerEdit:nil];
    
    NSArray * images = @[@"icon_bubble_1.png",@"icon_bubble_2.png",@"icon_bubble_3.png",@"icon_bubble_4.png",@"icon_bubble_5.png"];

    //创建贴纸View
    DWBubbleInputView * inputView = [[DWBubbleInputView alloc]initWithFrame: CGRectMake((ScreenWidth - BUBBLEWIDTH) / 2.0, (ScreenHeight - BUBBLEWIDTH) / 2.0, BUBBLEWIDTH, BUBBLEWIDTH)];
    inputView.image = [UIImage imageNamed:[images objectAtIndex:index]];

    LINConversionView * conversionView = [[LINConversionView alloc]initWithContentView:inputView];
    conversionView.scaleMode = LINConversionViewMode_Bounds;

    conversionView.delegate = self;
    conversionView.needPan = YES;
    conversionView.needRotate = NO;
    conversionView.needPinch  = NO;
    conversionView.style = LINConversionViewStyle_Bubble;
    [conversionView setTransformCtrlImage:[UIImage imageNamed:@"icon_edit_scale.png"] resizeCtrlImage:[UIImage imageNamed:@"icon_edit_time.png"] rotateCtrlImage:[UIImage imageNamed:@"icon_edit_delete.png"] TextCtrlImage:[UIImage imageNamed:@"icon_edit_text.png"]];
    [self.filterView addSubview:conversionView];

    [self.bubbleArray  addObject:[@{@"object":conversionView,@"start":[NSValue valueWithCMTime:kCMTimeZero],@"duration":[NSValue valueWithCMTime:kCMTimeZero],@"index":[NSNumber numberWithInteger:index],@"trimmer":[self getTrimmerView:DWVideoTrimmerViewStyle_Bubble]} mutableCopy]];
    
    [self controlBubbleEdit:conversionView];
    
    [inputView beginEdit];
}

-(void)DWBubbleViewDismiss
{
    self.editBgView.hidden = NO;

    self.bubbleView = nil;
}

#pragma mark - LINConversionViewDelegate
-(void)conversionViewDidDeleteAction:(LINConversionView *)conversionView
{
    if (conversionView.style == LINConversionViewStyle_Sticker) {
        NSDictionary * dict;
        for (NSDictionary * subDict in self.stickerArray) {
            if ([subDict objectForKey:@"object"] == conversionView) {
                dict = subDict;
            }
        }
        [conversionView removeFromSuperview];
        [self.stickerArray removeObject:dict];
    }
    
    if (conversionView.style == LINConversionViewStyle_Bubble) {
        NSDictionary * dict;
        for (NSDictionary * subDict in self.bubbleArray) {
            if ([subDict objectForKey:@"object"] == conversionView) {
                dict = subDict;
            }
        }
        [conversionView removeFromSuperview];
        [self.bubbleArray removeObject:dict];
    }
}

-(void)conversionViewDidTimeAction:(LINConversionView *)conversionView
{
    CGFloat scale = (ScreenHeight - (170 + self.notchBottom)) / ScreenHeight;
    self.filterView.transform = CGAffineTransformMake(scale, 0, 0, scale, 0, -100);
    
    //时间选择
    if (conversionView.style == LINConversionViewStyle_Sticker) {
        //贴纸
        //取消贴纸编辑
        conversionView.isEdit = NO;
        for (NSDictionary * dict in self.stickerArray) {
            DWVideoTrimmerView * view = (DWVideoTrimmerView *)[dict objectForKey:@"trimmer"];
            if ([dict objectForKey:@"object"] == conversionView) {
                view.hidden = NO;
            }else{
                view.hidden = YES;
            }
        }
    }
    
    if (conversionView.style == LINConversionViewStyle_Bubble) {
        //气泡文字
        //取消气泡文字编辑
        conversionView.isEdit = NO;
        for (NSDictionary * dict in self.bubbleArray) {
            DWVideoTrimmerView * view = (DWVideoTrimmerView *)[dict objectForKey:@"trimmer"];
            if ([dict objectForKey:@"object"] == conversionView) {
                view.hidden = NO;
            }else{
                view.hidden = YES;
            }
        }
    }
    
    self.editBgView.hidden = YES;
}

-(void)conversionViewDidTextAction:(LINConversionView *)conversionView
{
    if (conversionView.style == LINConversionViewStyle_Bubble) {
        DWBubbleInputView * inputView = (DWBubbleInputView *)conversionView.contentView;
        if (inputView.isEdit) {
            [inputView endEdit];
        }else{
            [inputView beginEdit];
        }
    }
}

-(void)conversionViewEditValueChange:(LINConversionView *)conversionView
{
    [self hideKeyboardTapAction];
    
    if (conversionView.style == LINConversionViewStyle_Sticker) {
        [self controlStickerEdit:conversionView];
        
        [self controlBubbleEdit:nil];
    }
    
    if (conversionView.style == LINConversionViewStyle_Bubble) {
        [self controlBubbleEdit:conversionView];
        
        [self controlStickerEdit:nil];
    }
}

-(void)conversionViewEndPanGesture:(LINConversionView *)conversionView
{
    //修改拖拽范围，最多不超出自身播放视图大小的50%
    if (conversionView.center.x < self.videoBackground.origin.x) {
        conversionView.center = CGPointMake(self.videoBackground.origin.x, conversionView.center.y);
    }else if (conversionView.center.y < self.videoBackground.origin.y){
        conversionView.center = CGPointMake(conversionView.center.x, self.videoBackground.origin.y);
    }else if (conversionView.center.x > self.videoBackground.size.width){
        conversionView.center = CGPointMake(self.videoBackground.size.width, conversionView.center.y);
    }else if (conversionView.center.y > self.videoBackground.size.height){
        conversionView.center = CGPointMake(conversionView.center.x ,self.videoBackground.size.height);
    }
}

#pragma mark - DWVideoTrimmerViewDelegate
-(void)DWVideoTrimmerView:(DWVideoTrimmerView *)videoTrimmerView SureActionWithStart:(CMTime)start Duration:(CMTime)duration
{
    if (videoTrimmerView.style == DWVideoTrimmerViewStyle_Sticker) {
        //贴纸时间回调
        for (NSDictionary * dict in self.stickerArray) {
            DWVideoTrimmerView * view = (DWVideoTrimmerView *)[dict objectForKey:@"trimmer"];
            if (view == videoTrimmerView) {
                [dict setValue:[NSValue valueWithCMTime:start] forKey:@"start"];
                [dict setValue:[NSValue valueWithCMTime:duration] forKey:@"duration"];
                //恢复贴纸编辑状态
                LINConversionView * conversionView = [dict objectForKey:@"object"];
                conversionView.isEdit = YES;
                break;
            }
        }
    }
    
    if (videoTrimmerView.style == DWVideoTrimmerViewStyle_Bubble) {
        //气泡文字回调
        for (NSDictionary * dict in self.bubbleArray) {
            DWVideoTrimmerView * view = (DWVideoTrimmerView *)[dict objectForKey:@"trimmer"];
            if (view == videoTrimmerView) {
                [dict setValue:[NSValue valueWithCMTime:start] forKey:@"start"];
                [dict setValue:[NSValue valueWithCMTime:duration] forKey:@"duration"];
                //恢复贴纸编辑状态
                LINConversionView * conversionView = [dict objectForKey:@"object"];
                conversionView.isEdit = YES;
                break;
            }
        }
    }
 
    self.filterView.transform = CGAffineTransformIdentity;
    
    self.editBgView.hidden = NO;
}

-(void)DWVideoTrimmerViewDismiss:(DWVideoTrimmerView *)videoTrimmerView
{
    if (videoTrimmerView.style == DWVideoTrimmerViewStyle_Sticker) {
        for (NSDictionary * dict in self.stickerArray) {
            if ([dict objectForKey:@"trimmer"] == videoTrimmerView) {
                //恢复贴纸编辑状态
                  LINConversionView * conversionView = [dict objectForKey:@"object"];
                  conversionView.isEdit = YES;
                  break;
            }
        }
    }
    if (videoTrimmerView.style == DWVideoTrimmerViewStyle_Bubble) {
        //气泡文字回调
        for (NSDictionary * dict in self.bubbleArray) {
            if ([dict objectForKey:@"trimmer"] == videoTrimmerView) {
                //恢复气泡文字状态
                LINConversionView * conversionView = [dict objectForKey:@"object"];
                conversionView.isEdit = YES;
                break;
            }
        }
//        self.bubbleConversionView.isEdit = YES;
    }
    
    self.filterView.transform = CGAffineTransformIdentity;

    self.editBgView.hidden = NO;
}

#pragma mark - action
-(void)leftButtonAction
{
    [self stopTimer];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)nextButtonAction
{
    [self addFilterWithVideoUrl:self.videoURL];
}

-(void)editFuncButtonAction:(UIButton *)button
{
    self.editBgView.hidden = YES;
    // 100 + i
    if (button.tag == 100) {
        //美颜
//        [self pause];
        if (!self.editBeautyView) {
            self.editBeautyView = [[DWEditBeautyView alloc]initWithVideoURL:self.videoURL];
            self.editBeautyView.delegate = self;
            [self.view addSubview:self.editBeautyView];
        }
        
        if (!self.isBeautyFilter) {
            self.isBeautyFilter = YES;

            [self removeAllTarget];
            
            if (self.filter) {
                [self.movieFile addTarget:self.filter];
                [self.filter addTarget:self.brightnessFilter];
                [self.brightnessFilter addTarget:self.bilateralFilter];
                [self.bilateralFilter addTarget:self.filterView];
            }else{
                [self.movieFile addTarget:self.brightnessFilter];
                [self.brightnessFilter addTarget:self.bilateralFilter];
                [self.bilateralFilter addTarget:self.filterView];
            }
        }
        
        self.editBeautyView.hidden = NO;
        
    }
    
    if (button.tag == 101) {
        //滤镜
//        [self pause];
        
        if (!self.editFilterView) {
            self.editFilterView = [[DWEditFilterView alloc]initWithVideoURL:self.videoURL];
            self.editFilterView.delegate = self;
            [self.view addSubview:self.editFilterView];
        }
       
        self.editFilterView.hidden = NO;
    }
    
    if (button.tag == 102) {
        //音乐
//        [self pause];

        DWAudioChooseView * audioChooseView = [[DWAudioChooseView alloc]init];
        audioChooseView.array = self.musicListArray;
                
        __weak typeof(self) weakSelf = self;
        audioChooseView.chooseAudio = ^(NSString *audioPath) {
            if (audioPath) {
                //设置插入音频，保存默认参数
                weakSelf.musicDict = @{@"audioPath":audioPath,
                                       @"originalVolume":@0.5,
                                       @"insertVolume":@0.5,
                                       @"start":[NSValue valueWithCMTime:kCMTimeZero],
                                       @"duration":[NSValue valueWithCMTime:kCMTimeZero]};
            }else{
                weakSelf.musicDict = nil;
            }
            weakSelf.insertMusicView.audioPath = audioPath;
        };
        
        audioChooseView.cancel = ^(BOOL isSelect) {
            if (!isSelect) {
                [weakSelf.insertMusicView dismiss];
            }
        };
        
        if (!self.insertMusicView) {
            self.insertMusicView = [[DWInsertMusicView alloc]init];
            self.insertMusicView.hidden = YES;
            self.insertMusicView.delegate = self;
            [self.view addSubview:self.insertMusicView];
            [self.insertMusicView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.view);
            }];
        }
             
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.insertMusicView.hidden = NO;
        });
    }
    
    if (button.tag == 103) {
        //贴纸
        self.stickerView = [[DWStickerView alloc]init];
//        self.stickerView.videoURL = self.videoURL;
        self.stickerView.delegate = self;
        [self.view addSubview:self.stickerView];
        
        [self.stickerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];

    }
    
    if (button.tag == 104) {
        //文字
        self.bubbleView = [[DWBubbleView alloc]init];
//        self.bubbleView.videoURL = self.videoURL;
        self.bubbleView.delegate = self;
        [self.view addSubview:self.bubbleView];
        
        [self.bubbleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        
    }
}

-(void)timerAction
{
    if (self.slider.value > self.movieFile.progress) {
        //开始新的播放循环
        if (self.insertMusicView) {
            [self.insertMusicView repeatPlay];
        }
        
        CMTime seekTime = CMTimeMake(self.videoDuration.value * self.movieFile.progress, self.videoDuration.timescale);
        [self.player seekToTime:seekTime];
        [self.player play];
    }
    
    self.currentLabel.text = [self formatSecondsToString:(self.videoDuration.value / self.videoDuration.timescale) * self.movieFile.progress];
    self.slider.value = self.movieFile.progress;
    
    //处理音视频不同步  控制误差在1秒以内
    CGFloat mistake = 1 / (CGFloat)(self.videoDuration.value / self.videoDuration.timescale);
    
    CGFloat playerProgress = (self.player.currentTime.value / self.player.currentTime.timescale) / (CGFloat)(self.videoDuration.value / self.videoDuration.timescale);

    if (playerProgress - self.movieFile.progress > mistake) {
        self.player.rate = 0.9;
    }else if (playerProgress - self.movieFile.progress < mistake){
        self.player.rate = 1.1;
    }else{
        self.player.rate = 1;
    }
    
}

-(void)hideKeyboardTapAction
{
    //查找编辑状态气泡文字，取消编辑状态
    for (NSDictionary * dict in self.bubbleArray) {
        LINConversionView * conversionView = (LINConversionView *)[dict objectForKey:@"object"];
        DWBubbleInputView * inputView = (DWBubbleInputView *)conversionView.contentView;
        if (inputView.isEdit) {
            [inputView endEdit];
        }
    }
    
}

#pragma mark - notification
-(void)enterForegroundNotification
{
    [self play];
    
    self.canEdit = YES;
}

-(void)didEnterBackgroundNotification
{
    [self pause];
    
    self.canEdit = NO;

    //如果程序进入后台，取消视频处理。
    if (self.writeMovieWriter) {
        [self.writeMovieWriter cancelRecording];
        [self.writeMovieFile endProcessing];
        self.writeMovieWriter = nil;
        self.writeMovieFile = nil;
    }
    
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
    
    NSArray * titles = @[@"美颜",@"滤镜",@"音乐",@"贴纸",@"文字"];
    NSArray * images = @[@"icon_beauty_close.png",@"icon_filter.png",@"icon_music.png",@"icon_sticker.png",@"icon_text.png"];
    
    [self.view addSubview:self.editBgView];
    [self.editBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(@0);
        make.bottom.equalTo(@0);
        make.height.equalTo(@(170 + self.notchBottom));
    }];
    
    [self.editBgView addSubview:self.currentLabel];
    [self.currentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@10);
        make.top.equalTo(@46);
        make.width.equalTo(@(self.currentLabel.frame.size.width));
        make.height.equalTo(@(self.currentLabel.frame.size.height));
    }];
    
    [self.editBgView addSubview:self.totalLabel];
    [self.totalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@(-10));
        make.centerY.equalTo(self.currentLabel);
        make.width.equalTo(self.currentLabel);
        make.height.equalTo(self.currentLabel);
    }];
    
    [self.editBgView addSubview:self.slider];
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.currentLabel.mas_right).offset(5);
        make.right.equalTo(self.totalLabel.mas_left).offset(-5);
        make.centerY.equalTo(self.currentLabel);
        make.height.equalTo(@20);
    }];
    
    UIScrollView * bgScrollView = [[UIScrollView alloc]init];
    bgScrollView.showsVerticalScrollIndicator = NO;
    bgScrollView.showsHorizontalScrollIndicator = NO;
    bgScrollView.contentSize = CGSizeMake(15 * 2 + 18 * (titles.count - 1) + 39 * titles.count, 103);
    [self.editBgView addSubview:bgScrollView];
    [bgScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@0);
        make.bottom.equalTo(@(0 - self.notchBottom));
        make.width.equalTo(@(ScreenWidth));
        make.height.equalTo(@103);
    }];
    
    for (int i = 0 ; i < titles.count; i++) {
        DWShortVideoEditButton * button = [DWShortVideoEditButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:[images objectAtIndex:i]] forState:UIControlStateNormal];
        if (i == 0) {
            [button setImage:[UIImage imageNamed:@"icon_beauty_open.png"] forState:UIControlStateSelected];
        }
        [button setTitle:[titles objectAtIndex:i] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:13];
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.tag = 100 + i;
        [button addTarget:self action:@selector(editFuncButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [bgScrollView addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(15 + (18 + 39) * i));
            make.top.equalTo(@25);
            make.width.equalTo(@39);
            make.height.equalTo(@53);
        }];
    }
}

-(void)initPlayer
{
    self.movieFile = [[GPUImageMovie alloc]initWithURL:self.videoURL];
    [self.movieFile addTarget:self.filterView];
    
    self.movieFile.shouldRepeat = YES;
    self.movieFile.playAtActualSpeed = YES;
    
    AVURLAsset * asset = [AVURLAsset assetWithURL:self.videoURL];
    self.videoDuration = asset.duration;
    self.videoSize = asset.naturalSize;
    
    self.totalLabel.text = [self formatSecondsToString:self.videoDuration.value / self.videoDuration.timescale];
    
    //创建AVplayer来播放声音，GPUImage播放无声音
    self.player = [[AVPlayer alloc]initWithURL:self.videoURL];
    [self.player setVolume:0.5];
    
    [self play];
}

-(void)startTimer
{
    if (self.timer) {
        [self stopTimer];
    }
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
}

-(void)stopTimer
{
    if (!self.timer) {
        return;
    }
    
    [self.timer invalidate];
    self.timer = nil;
}

-(GPUImageView *)filterView
{
    if (!_filterView) {
        _filterView = [[GPUImageView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        [self.view insertSubview:_filterView atIndex:0];
        
        //添加键盘消除手势
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboardTapAction)];
        [_filterView addGestureRecognizer:tap];
    }
    return _filterView;
}

-(GPUImageBrightnessFilter *)brightnessFilter
{
    if (!_brightnessFilter) {
        _brightnessFilter = [[GPUImageBrightnessFilter alloc]init];
        _brightnessFilter.brightness = 50 / 600.0;
    }
    return _brightnessFilter;
}

-(DWGPUImageBrightnessFilter *)bilateralFilter
{
    if (!_bilateralFilter) {
        _bilateralFilter = [[DWGPUImageBrightnessFilter alloc]init];
    }
    return _bilateralFilter;
}

-(UIView *)editBgView
{
    if (!_editBgView) {
        _editBgView = [DWControl initViewWithFrame:CGRectZero BackgroundColor:[UIColor clearColor] Tag:0 AndAlpha:1];
        CAGradientLayer * gl = [CAGradientLayer layer];
        gl.frame = CGRectMake(0,0,ScreenWidth,170);
        gl.startPoint = CGPointMake(0.5, 0);
        gl.endPoint = CGPointMake(0.5, 1);
        gl.colors = @[(__bridge id)[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.0].CGColor, (__bridge id)[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.4].CGColor];
        gl.locations = @[@(0), @(1.0f)];
        [_editBgView.layer addSublayer:gl];
    }
    return _editBgView;
}

-(UISlider *)slider
{
    if (!_slider) {
        _slider = [[UISlider alloc]init];
        [_slider setThumbImage:[UIImage imageNamed:@"icon_beauty_point.png"] forState:UIControlStateNormal];
        [_slider setMinimumTrackTintColor:[UIColor colorWithWhite:1 alpha:1]];
        [_slider setMaximumTrackTintColor:[UIColor colorWithWhite:1 alpha:0.3]];
    }
    return _slider;
}

-(UILabel *)currentLabel
{
    if (!_currentLabel) {
        _currentLabel = [DWControl initLabelWithFrame:CGRectZero Title:@" 00:00 " TextColor:[UIColor whiteColor] TextAlignment:NSTextAlignmentCenter AndFont:[UIFont systemFontOfSize:13]];
        [_currentLabel sizeToFit];
    }
    return _currentLabel;
}

-(UILabel *)totalLabel
{
    if (!_totalLabel) {
        _totalLabel = [DWControl initLabelWithFrame:CGRectZero Title:@" 00:00 " TextColor:[UIColor whiteColor] TextAlignment:NSTextAlignmentCenter AndFont:[UIFont systemFontOfSize:13]];
        [_totalLabel sizeToFit];
    }
    return _totalLabel;
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

-(NSMutableArray *)stickerArray
{
    if (!_stickerArray) {
        /*
         object
         start
         duration
         index
         trimmer
         */
        _stickerArray = [[NSMutableArray alloc]init];
    }
    return _stickerArray;
}

-(NSMutableArray *)bubbleArray
{
    if (!_bubbleArray) {
        /*
         object
         start
         duration
         index
         trimmer
         */
        _bubbleArray = [[NSMutableArray alloc]init];
    }
    return _bubbleArray;
}

-(CGRect)videoBackground
{
    CGRect videoBackground = AVMakeRectWithAspectRatioInsideRect(self.videoSize, self.filterView.bounds);
    return videoBackground;
}

-(NSArray *)musicListArray
{
    if (!_musicListArray) {
        _musicListArray = @[[@{@"name":@"KyleXian",@"author":@"中川奈美",@"time":@"02:46",@"path":[[NSBundle mainBundle] pathForResource:@"KyleXian" ofType:@"mp3"],@"isSelect":@NO} mutableCopy],
        [@{@"name":@"翼をください ",@"author":@"林原惠美",@"time":@"04:50",@"path":[[NSBundle mainBundle] pathForResource:@"翼をください " ofType:@"mp3"],@"isSelect":@NO} mutableCopy],
                            [@{@"name":@"aLIEz ",@"author":@"澤野弘之",@"time":@"04:28",@"path":[[NSBundle mainBundle] pathForResource:@"aLIEz" ofType:@"mp3"],@"isSelect":@NO} mutableCopy]];
    }
    return _musicListArray;
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

@implementation DWShortVideoEditButton

-(CGRect)imageRectForContentRect:(CGRect)contentRect
{
    return CGRectMake(0, 0, 39, 39);
}

-(CGRect)titleRectForContentRect:(CGRect)contentRect
{
    return CGRectMake(0, 40, 39, 13);
}

@end
