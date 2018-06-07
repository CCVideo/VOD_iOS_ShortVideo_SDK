//
//  ShortEditViewController.m
//  ShortVideoDemo
//
//  Created by luyang on 2017/8/18.
//  Copyright © 2017年 Myself. All rights reserved.
//

#import "ShortEditViewController.h"
#import "GPUImage.h"
#import <AssetsLibrary/AssetsLibrary.h>

static NSString  *const shortVideo =@"ShortVideo";

@interface ShortEditViewController ()

@property (nonatomic,strong)GPUImageOutput <GPUImageInput> *filter;
@property (nonatomic,strong)GPUImageMovieWriter *movieWriter;
@property (nonatomic,strong)GPUImageMovie *movieFile;
@property (nonatomic,strong)MBProgressHUD *hud;
@end

@implementation ShortEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _hud =[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _hud.label.text =@"添加水印中";
    
    [self saveVedioPath:_videoURL WithWaterImg:[UIImage imageNamed:@"avatar"] WithCoverImage:[UIImage imageNamed:@"demo"] WithText:@"CC视频"];
}

/**
 使用GPUImage加载水印
 
 @param videoPathURL 视频路径
 @param img 水印图片
 @param coverImg 水印图片二
 @param text 字符串水印

 */
-(void)saveVedioPath:(NSURL*)videoPathURL WithWaterImg:(UIImage*)img WithCoverImage:(UIImage*)coverImg WithText:(NSString*)text
{
    
    _filter = [[GPUImageNormalBlendFilter alloc] init];
    
    AVAsset *asset = [AVAsset assetWithURL:videoPathURL];
    CGSize size = asset.naturalSize;
    
    _movieFile = [[GPUImageMovie alloc] initWithAsset:asset];
    _movieFile.playAtActualSpeed = NO;
    
    // 文字水印
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = [UIFont systemFontOfSize:30];
    label.textColor = [UIColor whiteColor];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label sizeToFit];
    label.layer.masksToBounds = YES;
    label.layer.cornerRadius = 18.0f;
    [label setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
    [label setFrame:CGRectMake(50, 100, label.frame.size.width+20, label.frame.size.height)];
    
    //图片水印
    UIImage *coverImage1 = [img copy];
    UIImageView *coverImageView1 = [[UIImageView alloc] initWithImage:coverImage1];
    [coverImageView1 setFrame:CGRectMake(0, 100, 210, 50)];
    
    //第二个图片水印
    UIImage *coverImage2 = [coverImg copy];
    UIImageView *coverImageView2 = [[UIImageView alloc] initWithImage:coverImage2];
    [coverImageView2 setFrame:CGRectMake(270, 100, 210, 50)];
    
    UIView *subView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    subView.backgroundColor = [UIColor clearColor];
    
    [subView addSubview:coverImageView1];
    [subView addSubview:coverImageView2];
    [subView addSubview:label];
    
    GPUImageUIElement *element = [[GPUImageUIElement alloc] initWithView:subView];
    
    NSString *pathToMovie =[self getVideoSaveFilePathString:@".MOV" addPathArray:NO];
    unlink([pathToMovie UTF8String]);
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    
    self.movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(720.0, 1280.0)];
    
    GPUImageFilter* progressFilter = [[GPUImageFilter alloc] init];
    [progressFilter addTarget:_filter];
    [_movieFile addTarget:progressFilter];
    [element addTarget:_filter];
    self.movieWriter.shouldPassthroughAudio = YES;
    if ([[asset tracksWithMediaType:AVMediaTypeAudio] count] > 0){
        
        _movieFile.audioEncodingTarget = self.movieWriter;
        
    } else {
        //no audio
        _movieFile.audioEncodingTarget = nil;
    }
    
    
    //    movieFile.playAtActualSpeed = true;
    [_movieFile enableSynchronizedEncodingUsingMovieWriter:self.movieWriter];
    // 显示到界面
    [_filter addTarget:self.movieWriter];
    
    [self.movieWriter startRecording];
    [_movieFile startProcessing];
    
    
    
    WeakSelf(self);
    //渲染
    [progressFilter setFrameProcessingCompletionBlock:^(GPUImageOutput *output, CMTime time) {
        //水印可以移动
        CGRect frame = coverImageView1.frame;
        frame.origin.x += 1;
        frame.origin.y += 1;
        coverImageView1.frame = frame;
        //第5秒之后隐藏coverImageView2
        if (time.value/time.timescale>=5.0) {
            [coverImageView2 removeFromSuperview];
        }
        [element update];
        
    }];
    
    
    [self.movieWriter setCompletionBlock:^{
        StrongSelf(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.hud hideAnimated:YES];
            [self.filter removeTarget:self.movieWriter];
            [self.movieWriter finishRecording];
            
            //保存相册
            [self savePhotosAlbum:movieURL];
            
        });
        
        
        
        
      
        
       
        }];
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
    
    return videoPath;
    
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
