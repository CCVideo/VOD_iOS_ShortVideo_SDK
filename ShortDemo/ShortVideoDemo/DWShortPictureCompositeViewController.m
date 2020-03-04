//
//  DWShortPictureCompositeViewController.m
//  ShortVideoDemo
//
//  Created by zwl on 2019/12/27.
//  Copyright © 2019 Myself. All rights reserved.
//

#import "DWShortPictureCompositeViewController.h"
#import "DWPictureShowView.h"
#import "DWPictureScrolBgView.h"
#import "DWPictureSetBgView.h"
#import "DWPictureAnimation.h"
#import "DWTransitionAnimation.h"
#import "DWPictureCompositeInstrument.h"
#import "DWShortVideoEditViewController.h"

#define VIDEOSIZE  CGSizeMake(720, 1280)

@interface DWShortPictureCompositeViewController () <DWPictureScrolBgViewDelegate,DWPictureSetBgViewDelegate>

@property(nonatomic,strong)NSArray * resetImageArray;//处理后图片数组
@property(nonatomic,assign)CGFloat notchTop;
@property(nonatomic,assign)CGFloat notchBottom;

@property(nonatomic,assign)BOOL isAnimation;//动画是否正在进行
@property(nonatomic,assign)CGFloat currentDuration;//动画进行时间

@property(nonatomic,assign)CGSize pictureShowViewSize;
@property(nonatomic,strong)DWPictureShowView * pictureShowView;//图片展示
@property(nonatomic,strong)UILabel * currentLabel;
@property(nonatomic,strong)UILabel * totalLabel;

@property(nonatomic,strong)DWPictureScrolBgView * pictureScrolBgView;//图片滚动条
@property(nonatomic,strong)DWPictureSetBgView * pictureSetBgView;//图片设置

@property(nonatomic,strong)NSTimer * timer;
@property(nonatomic,assign)CGFloat second;

/*
 @{@"image":图片,
   @"duration":时长,
   @"style":样式,
   @"animation":动画效果 }
 
 */
@property(nonatomic,strong)NSArray * imagesDataArray;//图片数据数据


/*
@{@"duration":时长,
 @"style":样式,
 @"animation":动画效果,
 @"maskAnimation":遮罩层动画效果 }
 */
@property(nonatomic,strong)NSArray * transitionsDataArray;//转场数据数据

@property(nonatomic,strong)NSArray <DWPictureNodeModel *> * pictureNodesArray;//图片node数组

@property(nonatomic,assign)CGFloat pictureIndex;//记录当前选中图片下标

@property(nonatomic,assign)CGFloat transitionIndex;//记录当前选中转场下标

@end

static CGFloat timeSpace = 0.1;

@implementation DWShortPictureCompositeViewController

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
    
    self.currentDuration = 0.0;
    self.pictureIndex = -1;
    self.transitionIndex = -1;
    self.second = 0;
    
    [self initUI];
    
    //初始化默认动画
    self.pictureIndex = 0;
    self.transitionIndex = -1;
    [self resetViewAnimation];
}

-(void)setImagesArray:(NSArray *)imagesArray
{
    _imagesArray = imagesArray;
    
    //对图片进行处理，填充黑边
    NSMutableArray * newImageArray = [NSMutableArray array];
    for (int i = 0; i < imagesArray.count; i++) {
        UIImage * newImage = [self reSizeImage:[imagesArray objectAtIndex:i]];
        [newImageArray addObject:newImage];
    }
    
    self.resetImageArray = newImageArray;
    
    //初始化图片数据
    NSMutableArray * imagesDataArray = [NSMutableArray array];
    [newImageArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableDictionary * imageDict = [NSMutableDictionary dictionary];
        [imageDict setValue:obj forKey:@"image"];
        [imageDict setValue:@3 forKey:@"duration"];
        [imageDict setValue:@0 forKey:@"style"];
        [imagesDataArray addObject:imageDict];
    }];
    self.imagesDataArray = imagesDataArray;
    
    //初始化转场数据
    NSMutableArray * transitionDataArray = [NSMutableArray array];
    for (int i = 0; i < self.imagesDataArray.count - 1; i++) {
        NSMutableDictionary * transitionDict = [NSMutableDictionary dictionary];
        [transitionDict setValue:@0 forKey:@"duration"];
        [transitionDict setValue:@0 forKey:@"style"];
        [transitionDataArray addObject:transitionDict];
    }
    self.transitionsDataArray = transitionDataArray;
    
    /*
    return;
    _imagesArray = imagesArray;
    
    //初始化图片数据
    NSMutableArray * imagesDataArray = [NSMutableArray array];
    [imagesArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableDictionary * imageDict = [NSMutableDictionary dictionary];
        [imageDict setValue:obj forKey:@"image"];
        [imageDict setValue:@1 forKey:@"duration"];
        [imageDict setValue:@0 forKey:@"style"];
        [imagesDataArray addObject:imageDict];
    }];
    self.imagesDataArray = imagesDataArray;
    
    //初始化转场数据
    NSMutableArray * transitionDataArray = [NSMutableArray array];
    for (int i = 0; i < self.imagesDataArray.count - 1; i++) {
        NSMutableDictionary * transitionDict = [NSMutableDictionary dictionary];
        [transitionDict setValue:@0 forKey:@"duration"];
        [transitionDict setValue:@0 forKey:@"style"];
        [transitionDataArray addObject:transitionDict];
    }
    self.transitionsDataArray = transitionDataArray;
     */
}

//对图片进行处理，填充黑边
-(UIImage *)reSizeImage:(UIImage *)image
{
    CGRect imageFrame = AVMakeRectWithAspectRatioInsideRect(image.size, CGRectMake(0, 0, self.pictureShowViewSize.width, self.pictureShowViewSize.height));
    UIImage * backGroundImage = [[UIColor blackColor] createImageWithSize:self.pictureShowViewSize];
    UIGraphicsBeginImageContext(self.pictureShowViewSize);
    [backGroundImage drawInRect:CGRectMake(0, 0, self.pictureShowViewSize.width, self.pictureShowViewSize.height)];
    [image drawInRect:imageFrame];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return reSizeImage;
}

-(void)play
{
    if (self.isAnimation) {
        return;
    }
    
    //启动定时器
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    self.timer = [NSTimer timerWithTimeInterval:timeSpace target:self selector:@selector(timeValeChange) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    
    [self.pictureShowView play];
    
    self.isAnimation = YES;

}

-(void)pause
{
    if (!self.isAnimation) {
        return;
    }
    
    //定时器暂停
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    //view动画效果暂停
    [self.pictureShowView pause];
    
    self.isAnimation = NO;
}

//生成图片特效
-(void)resetViewAnimation
{
//    [self resetPictureNodeAniationsWithSize:self.pictureShowView.bounds.size];
    self.pictureNodesArray = [self resetPictureNodeAniationsWithSize:self.pictureShowView.bounds.size AndCreateVideo:NO];

    [self.pictureShowView resetUIWithNodeArrays:self.pictureNodesArray];
    
    self.isAnimation = YES;
    
    //初始化label时间
    self.second = 0;
    self.currentLabel.text = @"00:00";
    self.totalLabel.text = [self formatSecondsToString:[self calculateVideoDuration]];
    
    //重启定时器
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    self.timer = [NSTimer timerWithTimeInterval:timeSpace target:self selector:@selector(timeValeChange) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];

}

//重新设置model动效
//-(void)resetPictureNodeAniationsWithSize:(CGSize)aniationsSize
/// 返回动效数组
/// @param aniationsSize 尺寸
/// @param isCreateVideo 是否SDK使用
-(NSArray *)resetPictureNodeAniationsWithSize:(CGSize)aniationsSize AndCreateVideo:(BOOL)isCreateVideo
{
    
    NSInteger beginIndex = [self getAnimationBeginIndex];
    
    /*
     三种情况。
     1.第一张图片，只处理图片本身特效与图片后方的转场动画。
     2.最后一张图片，只处理图片本身特效与图片前方的转场动画。
     3.中间图片，处理图片本身特效与图片前后方的转场动画。
     
     对于视频总时长的解释：
     假设有2张图片，各自显示3秒，转场动画时长2秒，视频总时长为3+2+3=8秒。
     */
    
    NSMutableArray * pictureNodesArray = [NSMutableArray array];
        
    [self.imagesDataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx >= beginIndex) {
            NSDictionary * imageDict = (NSDictionary *)obj;
            DWPictureNodeModel * pictureNodeModel = [[DWPictureNodeModel alloc]init];
            //SDK使用图片原图，页面展示使用处理过的图片
            pictureNodeModel.image = isCreateVideo ? [self.imagesArray objectAtIndex:idx] : [imageDict objectForKey:@"image"];
            pictureNodeModel.beginTime = [self calculateAnimationTimeWithIndex:idx IsPicture:YES];
            pictureNodeModel.duration = [[imageDict objectForKey:@"duration"] floatValue];
            
            //图片显示时间
            CGFloat pictureDuration = pictureNodeModel.duration;
            
            //转场动画时间
            CGFloat transitionDuration = 0;
            //前置转场动画时间
            CGFloat advanceTransitionDuration = 0;
  
            NSArray * pictureAnimations = [NSArray array];
            NSMutableArray * transitionAnimations = [NSMutableArray array];
            
            if (idx == 0) {
                //第一张图片
                //只处理自身动画与其后转场动画
                NSDictionary * transitionDict = [self.transitionsDataArray objectAtIndex:0];
                //转场动画样式
                if ([[transitionDict objectForKey:@"style"] integerValue] != 0) {
                    
                    transitionDuration = [self calculateAnimationTimeWithIndex:0 IsPicture:NO];
                    
                    if (transitionDuration > 0) {
                        pictureDuration += transitionDuration;
                        
                        DWTransitionAnimationStyle transitionStyle = [[transitionDict objectForKey:@"style"] integerValue] - 1;
                        //添加转场特效
                        [transitionAnimations addObjectsFromArray:[DWTransitionAnimation transitionAnimationCreateWithStyle:transitionStyle BeginTime:pictureDuration - transitionDuration Duration:transitionDuration VideoSize:aniationsSize isFront:YES]];
                    }

                }
                
            }else if (idx == self.imagesDataArray.count - 1) {
                //最后一张图片
                //只处理自身动画与其前转场动画
                NSDictionary * transitionDict = [self.transitionsDataArray objectAtIndex:idx - 1];
                
                if ([[transitionDict objectForKey:@"style"] integerValue] != 0) {
                    transitionDuration = [self calculateAnimationTimeWithIndex:idx - 1 IsPicture:NO];
                    
                    if (transitionDuration > 0) {
                        advanceTransitionDuration = transitionDuration;
                        //转场动画样式
                        DWTransitionAnimationStyle transitionStyle = [[transitionDict objectForKey:@"style"] integerValue] - 1;
                        
                        if (transitionStyle == DWTransitionAnimationStyleCover) {
                            
                        }else if (transitionStyle == DWTransitionAnimationStyleBlack || transitionStyle == DWTransitionAnimationStyleWhite) {
                            //添加转场特效
                            [transitionAnimations addObjectsFromArray:[DWTransitionAnimation transitionAnimationCreateWithStyle:transitionStyle BeginTime:0 Duration:transitionDuration VideoSize:aniationsSize isFront:NO]];
                        }else if (transitionStyle == DWTransitionAnimationStyleCircle) {
                            //添加转场特效
                            [transitionAnimations addObjectsFromArray:[DWTransitionAnimation transitionAnimationCreateWithStyle:transitionStyle BeginTime:0 Duration:transitionDuration VideoSize:aniationsSize isFront:NO]];
                            
                            //增加辅助图层
                            //修改显示图层层级关系
                            pictureNodeModel.isCover = YES;
                            CALayer * maskLayer = [CALayer layer];
                            maskLayer.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1].CGColor;
                            pictureNodeModel.maskLayer = maskLayer;
                            pictureNodeModel.maskAnimations = [DWTransitionAnimation circleMaskAnimationCreateWithDuration:transitionDuration VideoSize:aniationsSize];
                            pictureNodeModel.maskAnimationBeginTime = pictureNodeModel.beginTime - advanceTransitionDuration;
                            pictureNodeModel.maskAnimationDuration = transitionDuration;
                        }
                        
                        pictureDuration += transitionDuration;
                    }
                }
                
            }else {
                //中间图片
                //添加图片前转场动画
                NSDictionary * frontTransitionDict = [self.transitionsDataArray objectAtIndex:idx - 1];
                if ([[frontTransitionDict objectForKey:@"style"] integerValue] != 0) {
                    transitionDuration = [self calculateAnimationTimeWithIndex:idx - 1 IsPicture:NO];
                    
                    advanceTransitionDuration = transitionDuration;
                    
                    if (transitionDuration > 0) {
                        //前转场动画样式
                        DWTransitionAnimationStyle frontTransitionStyle = [[frontTransitionDict objectForKey:@"style"] integerValue] - 1;
                        
                        if (frontTransitionStyle == DWTransitionAnimationStyleCover) {
                            
                        }else if (frontTransitionStyle == DWTransitionAnimationStyleBlack || frontTransitionStyle == DWTransitionAnimationStyleWhite) {
                            //添加转场特效
                            [transitionAnimations addObjectsFromArray:[DWTransitionAnimation transitionAnimationCreateWithStyle:frontTransitionStyle BeginTime:0 Duration:transitionDuration VideoSize:aniationsSize isFront:NO]];
                        }else if (frontTransitionStyle == DWTransitionAnimationStyleCircle) {
                            //添加转场特效
                            [transitionAnimations addObjectsFromArray:[DWTransitionAnimation transitionAnimationCreateWithStyle:frontTransitionStyle BeginTime:0 Duration:transitionDuration VideoSize:aniationsSize isFront:NO]];
                            
                            //增加辅助图层
                            //修改显示图层层级关系
                            pictureNodeModel.isCover = YES;
                            CALayer * maskLayer = [CALayer layer];
                            maskLayer.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1].CGColor;
                            pictureNodeModel.maskLayer = maskLayer;
                            pictureNodeModel.maskAnimations = [DWTransitionAnimation circleMaskAnimationCreateWithDuration:transitionDuration VideoSize:aniationsSize];
                            pictureNodeModel.maskAnimationBeginTime = pictureNodeModel.beginTime - advanceTransitionDuration;
                            pictureNodeModel.maskAnimationDuration = transitionDuration;
                        }
                        
                        pictureDuration += transitionDuration;
                    }
                    
                }
                
                //添加图片后转场动画
                NSDictionary * nextTransitionDict = [self.transitionsDataArray objectAtIndex:idx];
                
                if ([[nextTransitionDict objectForKey:@"style"] integerValue] != 0) {
                    CGFloat nextTransitionDuration = [self calculateAnimationTimeWithIndex:idx IsPicture:NO];
                    
                    pictureDuration += nextTransitionDuration;
                    
                    if (nextTransitionDuration > 0) {
                        //后转场动画样式
                        DWTransitionAnimationStyle nextTransitionStyle = [[nextTransitionDict objectForKey:@"style"] integerValue] - 1;
                        
                        [transitionAnimations addObjectsFromArray:[DWTransitionAnimation transitionAnimationCreateWithStyle:nextTransitionStyle BeginTime:pictureDuration - nextTransitionDuration Duration:nextTransitionDuration VideoSize:aniationsSize isFront:YES]];
                    }
                }
                
            }
                        
            pictureNodeModel.beginTime = pictureNodeModel.beginTime - advanceTransitionDuration;
            pictureNodeModel.duration = pictureDuration;
            
            //设置图片特效
//            DWPictureAnimationStyle pictureAnimationStyle = [[imageDict objectForKey:@"style"] integerValue] - 1;
            DWPictureAnimationStyle pictureAnimationStyle = [[imageDict objectForKey:@"style"] integerValue];

            
            pictureAnimations = [DWPictureAnimation pictureAnimationCreateWithStyle:pictureAnimationStyle
                                                                    PictureDuration:pictureDuration
                                                            FrontTransitionDuration:advanceTransitionDuration
                                                                          VideoSize:aniationsSize
                                                                             isLast:idx == self.imagesDataArray.count - 1];
            
            NSMutableArray * animations = [NSMutableArray array];
            [animations addObjectsFromArray:pictureAnimations];
            [animations addObjectsFromArray:transitionAnimations];
            pictureNodeModel.animations = animations;
            
            [pictureNodesArray addObject:pictureNodeModel];
            
        }
    }];
    
    return pictureNodesArray;
}

//计算时间动画开始时间
-(CGFloat)calculateAnimationTimeWithIndex:(NSInteger)index IsPicture:(BOOL)isPicture
{
    CGFloat beginTime = 0;
    int beginIndex = [self getAnimationBeginIndex];
    
    if (isPicture) {
        //计算图片动画开始时间
        if (index != 0) {
            for (int i = beginIndex; i < index; i++) {
                NSDictionary * imageDict = [self.imagesDataArray objectAtIndex:i];
                beginTime += [[imageDict objectForKey:@"duration"] floatValue];
            }
            
            //转场动画占用时间
            for (int i = beginIndex; i < index; i++) {
                NSDictionary * transitionDict = [self.transitionsDataArray objectAtIndex:i];
                if ([[transitionDict objectForKey:@"style"] integerValue] != 0) {
                    beginTime += [[transitionDict objectForKey:@"duration"] floatValue];
                }
            }
        }
    }else{
        //计算转场算持续时间
        NSDictionary * transitionDict = [self.transitionsDataArray objectAtIndex:index];
        if ([[transitionDict objectForKey:@"style"] integerValue] != 0) {
            beginTime += [[transitionDict objectForKey:@"duration"] floatValue];
        }
    }
    
    return beginTime;
}

//计算视频时长
-(CGFloat)calculateVideoDuration
{
    int beginIndex = [self getAnimationBeginIndex];
    
    CGFloat duration = 0;
    for (int i = beginIndex; i < self.imagesDataArray.count; i++) {
        NSDictionary * imageDict = [self.imagesDataArray objectAtIndex:i];
        duration += [[imageDict objectForKey:@"duration"] floatValue];
    }
    
    for (int i = beginIndex; i < self.transitionsDataArray.count; i++) {
        NSDictionary * transitionDict = [self.transitionsDataArray objectAtIndex:i];
        if ([[transitionDict objectForKey:@"style"] integerValue] != 0) {
            duration += [[transitionDict objectForKey:@"duration"] floatValue];
        }
    }
    return duration;
}

-(NSInteger)getAnimationBeginIndex
{
    return self.pictureIndex == -1 ? self.transitionIndex : self.pictureIndex;
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

#pragma mark - action
-(void)leftButtonAction
{
    [self pause];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)nextButtonAction
{
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.removeFromSuperViewOnHide = YES;
    hud.label.text = @"处理中，请稍后";
    
    [self pause];
    
    //根据视频尺寸重新设置动画
    self.pictureIndex = 0;
    self.transitionIndex = -1;
    
//    [self resetPictureNodeAniationsWithSize:VIDEOSIZE];
    NSArray * pictureNodeModels = [self resetPictureNodeAniationsWithSize:VIDEOSIZE AndCreateVideo:YES];
    
    DWPictureCompositeInstrument * instrument = [[DWPictureCompositeInstrument alloc]init];
    instrument.videoSize = VIDEOSIZE;
    instrument.videoBackgroundColor = [UIColor blackColor];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    path = [path stringByAppendingPathComponent:SHORTVIDEO];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    NSString *videoPath = [[path stringByAppendingPathComponent:nowTimeStr] stringByAppendingString:@".MP4"];

    instrument.outPath = videoPath;
    instrument.pictureNodeModels = pictureNodeModels;
    
    //视频总时间
    instrument.videoDuration = [self calculateVideoDuration];
    
    //开始生成视频
    [instrument startComposite];
    
    instrument.complete = ^(NSError *error, NSURL *completeFileURL) {
        
        [hud hideAnimated:YES];

        if (error) {
            [error.localizedDescription showAlert];
            return;
        }
        NSLog(@"视频生成完成 %@",completeFileURL);
        
        DWShortVideoEditViewController * shortVideoEditVC = [[DWShortVideoEditViewController alloc]init];
        shortVideoEditVC.videoURL = completeFileURL;
        [self presentViewController:shortVideoEditVC animated:YES completion:nil];
        
    };
}

-(void)showViewTapAction
{
    if (self.isAnimation) {
        [self pause];
    }else{
        [self play];
    }
}

-(void)timeValeChange
{
    self.second += timeSpace;
    
    CGFloat duration = [self calculateVideoDuration];
    
    if (self.second >= duration) {
        //动画结束 重新开始
        self.second = 0;
        self.currentLabel.text = @"00:00";
        [self.pictureShowView resetUIWithNodeArrays:self.pictureNodesArray];
    }
    
    self.currentLabel.text = [self formatSecondsToString:self.second];

    //修改滚动条
    CGFloat schedulePrcentage = self.second / duration;
    [self.pictureScrolBgView setScrollViewOffsetWithPercentage:schedulePrcentage];
}

#pragma mark - delegate
///DWPictureScrolBgViewDelegate
-(void)pictureScrolBgViewDidSelectImage:(NSInteger)imageIndex
{
    //点击图片
    NSDictionary * imageDict = [self.imagesDataArray objectAtIndex:imageIndex];
    CGFloat percentage = ([[imageDict objectForKey:@"duration"] floatValue] - self.pictureSetBgView.imageMinTime) / (self.pictureSetBgView.imageMaxTime  - self.pictureSetBgView.imageMinTime);
    NSInteger styleIndex = [[imageDict objectForKey:@"style"] integerValue];
    
    [self.pictureSetBgView resetStyle:DWPictureSetStylePicture DurationPercentage:percentage AndSelectIndex:styleIndex];

    self.pictureIndex = imageIndex;
    self.transitionIndex = -1;
    [self resetViewAnimation];
}

-(void)pictureScrolBgViewDidSelectTransition:(NSInteger)transitionIndex
{
    //点击转场
    NSDictionary * transitionDict = [self.transitionsDataArray objectAtIndex:transitionIndex];
    CGFloat percentage = ([[transitionDict objectForKey:@"duration"] floatValue] - self.pictureSetBgView.transitionMinTime) / (self.pictureSetBgView.transitionMaxTime - self.pictureSetBgView.transitionMinTime);

    NSInteger styleIndex = [[transitionDict objectForKey:@"style"] integerValue];

    [self.pictureSetBgView resetStyle:DWPictureSetStyleTransition DurationPercentage:percentage AndSelectIndex:styleIndex];
    
    self.pictureIndex = -1;
    self.transitionIndex = transitionIndex;
    [self resetViewAnimation];
}

//进度条开始滑动
-(void)pictureScrolBgViewBeginDragging
{
    if (self.isAnimation) {
        [self pause];
    }
}

///DWPictureSetBgViewDelegate
//设置动画效果
-(void)pictureSetBgViewStyle:(DWPictureSetStyle)style Index:(NSInteger)index
{
    if (style == DWPictureSetStylePicture) {
        NSInteger selectImageIndex = self.pictureScrolBgView.selectImageIndex;
        
        //修改图片数据
        NSMutableDictionary * imageDict = [self.imagesDataArray objectAtIndex:selectImageIndex];
        [imageDict setValue:[NSNumber numberWithInteger:index] forKey:@"style"];

        [self.pictureScrolBgView setImageIndex:selectImageIndex WithStyle:index];
        
    }else{
        NSInteger selectTransitionIndex = self.pictureScrolBgView.selectTransitionIndex;
        //修改转场数据
        NSDictionary * transitionDict = [self.transitionsDataArray objectAtIndex:selectTransitionIndex];
        [transitionDict setValue:[NSNumber numberWithInteger:index] forKey:@"style"];

        [self.pictureScrolBgView setTransitionIndex:selectTransitionIndex WithStyle:index];
                
    }
    
    [self resetViewAnimation];
    
}

//设置时长
-(void)pictureSetBgViewStyle:(DWPictureSetStyle)style DurationChange:(CGFloat)duration
{
    if (style == DWPictureSetStylePicture) {
        NSInteger selectImageIndex = self.pictureScrolBgView.selectImageIndex;
        //修改图片数据
        NSDictionary * imageDict = [self.imagesDataArray objectAtIndex:selectImageIndex];
        [imageDict setValue:[NSNumber numberWithFloat:duration] forKey:@"duration"];
        
        [self.pictureScrolBgView setImageIndex:selectImageIndex WithDuration:duration];
                
    }else{
        NSInteger selectTransitionIndex = self.pictureScrolBgView.selectTransitionIndex;
        //修改转场数据
        NSDictionary * transitionDict = [self.transitionsDataArray objectAtIndex:selectTransitionIndex];
        [transitionDict setValue:[NSNumber numberWithFloat:duration] forKey:@"duration"];
        
        [self.pictureScrolBgView setTransitionIndex:selectTransitionIndex WithDuration:duration];
        
    }
    
    [self resetViewAnimation];
}

//设置全部
-(void)pictureSetBgViewTotalSetStyle:(DWPictureSetStyle)style Index:(NSInteger)index
{
    if (style == DWPictureSetStylePicture) {
        NSInteger selectImageIndex = self.pictureScrolBgView.selectImageIndex;
        NSDictionary * currentImageDict = [self.imagesDataArray objectAtIndex:selectImageIndex];

        for (int i = 0; i < self.imagesDataArray.count; i++) {
            NSDictionary * imageDict = [self.imagesDataArray objectAtIndex:i];
            if (selectImageIndex != i) {
                [imageDict setValue:[currentImageDict objectForKey:@"duration"] forKey:@"duration"];
                [imageDict setValue:[currentImageDict objectForKey:@"style"] forKey:@"style"];
                [self.pictureScrolBgView setImageIndex:i WithStyle:[[currentImageDict objectForKey:@"style"] integerValue]];
                [self.pictureScrolBgView setImageIndex:i WithDuration:[[currentImageDict objectForKey:@"duration"] floatValue]];
            }
        }
            
    }else{
        NSInteger selectTransitionIndex = self.pictureScrolBgView.selectTransitionIndex;
        NSDictionary * currentTransitionDict = [self.transitionsDataArray objectAtIndex:selectTransitionIndex];
        
        for (int i = 0; i < self.transitionsDataArray.count; i++) {
            NSDictionary * transitionDict = [self.transitionsDataArray objectAtIndex:i];
            if (selectTransitionIndex != i) {
                [transitionDict setValue:[currentTransitionDict objectForKey:@"duration"] forKey:@"duration"];
                [transitionDict setValue:[currentTransitionDict objectForKey:@"style"] forKey:@"style"];
                [self.pictureScrolBgView setTransitionIndex:i WithStyle:[[currentTransitionDict objectForKey:@"style"] integerValue]];
                [self.pictureScrolBgView setTransitionIndex:i WithDuration:[[currentTransitionDict objectForKey:@"duration"] floatValue]];

            }
        }

    }
    
    [self resetViewAnimation];

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
    
    self.pictureShowView = [[DWPictureShowView alloc]initWithFrame:CGRectMake(0, self.notchTop + 64, self.pictureShowViewSize.width, self.pictureShowViewSize.height)];
    [self.view addSubview:self.pictureShowView];
    UITapGestureRecognizer * showViewTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showViewTapAction)];
    [self.pictureShowView addGestureRecognizer:showViewTap];
    
    [self.view addSubview:self.currentLabel];
    [self.currentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@12);
        make.top.equalTo(@(CGRectGetMaxY(self.pictureShowView.frame) + 5));
        make.width.equalTo(@(self.currentLabel.frame.size.width));
        make.height.equalTo(@(self.currentLabel.frame.size.height));
    }];
    
    UILabel * tsLabel = [DWControl initLabelWithFrame:CGRectZero Title:@" / " TextColor:self.currentLabel.textColor TextAlignment:NSTextAlignmentCenter AndFont:self.currentLabel.font];
    [tsLabel sizeToFit];
    [self.view addSubview:tsLabel];
    [tsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.currentLabel.mas_right);
        make.centerY.equalTo(self.currentLabel);
        make.width.equalTo(@(tsLabel.frame.size.width));
        make.height.equalTo(@(tsLabel.frame.size.height));
    }];
    
    [self.view addSubview:self.totalLabel];
    [self.totalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.currentLabel.mas_right);
        make.left.equalTo(tsLabel.mas_right);
        make.centerY.equalTo(self.currentLabel);
        make.width.equalTo(self.currentLabel);
        make.height.equalTo(self.currentLabel);
    }];
    
//    self.pictureScrolBgView = [[DWPictureScrolBgView alloc]initWithImageArray:self.imagesArray];
    self.pictureScrolBgView = [[DWPictureScrolBgView alloc]initWithImageArray:self.resetImageArray];
    self.pictureScrolBgView.delegate = self;
    [self.view addSubview:self.pictureScrolBgView];
    [self.pictureScrolBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@0);
        make.top.equalTo(self.currentLabel.mas_bottom).offset(5);
        make.width.equalTo(@(ScreenWidth));
        make.height.equalTo(@(69));
    }];
    
    UIView * lineView = [DWControl initViewWithFrame:CGRectZero BackgroundColor:[UIColor colorWithRed:30/255.0 green:30/255.0 blue:32/255.0 alpha:1] Tag:0 AndAlpha:1];
    [self.view addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.pictureScrolBgView.mas_bottom);
        make.left.equalTo(@0);
        make.width.equalTo(@(ScreenWidth));
        make.height.equalTo(@10);
    }];
    
    self.pictureSetBgView = [[DWPictureSetBgView alloc]init];
    self.pictureSetBgView.delegate = self;
    [self.view addSubview:self.pictureSetBgView];
    [self.pictureSetBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lineView.mas_bottom);
        make.left.equalTo(@0);
        make.width.equalTo(@(ScreenWidth));
        make.bottom.equalTo(@0);
    }];
  
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


-(UILabel *)currentLabel
{
    if (!_currentLabel) {
        _currentLabel = [DWControl initLabelWithFrame:CGRectZero Title:@" 00:00" TextColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.5] TextAlignment:NSTextAlignmentCenter AndFont:[UIFont systemFontOfSize:13]];
        [_currentLabel sizeToFit];
    }
    return _currentLabel;
}

-(UILabel *)totalLabel
{
    if (!_totalLabel) {
        _totalLabel = [DWControl initLabelWithFrame:CGRectZero Title:@" 00:00" TextColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.5] TextAlignment:NSTextAlignmentCenter AndFont:[UIFont systemFontOfSize:13]];
        [_totalLabel sizeToFit];
    }
    return _totalLabel;
}

-(NSArray <DWPictureNodeModel *> *)pictureNodesArray
{
    if (!_pictureNodesArray) {
        _pictureNodesArray = [[NSArray alloc]init];
    }
    return _pictureNodesArray;
}

-(CGSize)pictureShowViewSize
{
    return CGSizeMake(ScreenWidth, ScreenHeight - (self.notchTop + 64 + 23 + 69 + 10 + (121 + self.notchBottom)));
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
