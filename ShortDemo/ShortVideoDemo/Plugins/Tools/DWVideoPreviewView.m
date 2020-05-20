//
//  DWVideoPreviewView.m
//  ShortVideoDemo
//
//  Created by zwl on 2020/2/27.
//  Copyright © 2020 Myself. All rights reserved.
//

#import "DWVideoPreviewView.h"

@interface DWVideoPreviewView () <CAAnimationDelegate>

@property(nonatomic,assign)NSURL * videoUrl;
@property(nonatomic,strong)AVURLAsset * asset;

//@property(nonatomic,assign)CGFloat startPosition;

@property(nonatomic,strong)UIView * lineView;

@property(nonatomic,strong)NSDictionary * colorBlockDict;
//保存数据格式如下
/*
 @{@"layer":,@"startPosition",@"stopPosition"}
 */
@property(nonatomic,strong)NSMutableArray * colorBlockArray;

@end

@implementation DWVideoPreviewView

-(instancetype)initWithFrame:(CGRect)frame VideoUrl:(NSURL *)videoUrl
{
    if (self == [super initWithFrame:frame]) {
                
        self.videoUrl = videoUrl;
        
        self.colorBlockArray = [[NSMutableArray alloc]init];
        
        self.startPosition = 0;
    
        [self initUI];
    }
    return self;
}

//取消色块
-(void)dismissAllColorBlock
{
    if (self.colorBlockArray.count == 0) {
        return;
    }
    
    [self.colorBlockArray enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([[obj objectForKey:@"new"] boolValue]) {
            CAShapeLayer * colorBlockLayer = [obj objectForKey:@"layer"];
            [colorBlockLayer removeFromSuperlayer];
            [self.colorBlockArray removeObjectAtIndex:idx];
        }
    }];
    
    [self.colorBlockArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([[obj objectForKey:@"alreadyUndo"] boolValue]) {
            CAShapeLayer * colorBlockLayer = [obj objectForKey:@"layer"];
            colorBlockLayer.hidden = NO;
            [obj setValue:@NO forKey:@"alreadyUndo"];
        }
    }];
}

//撤销最新的色块
-(void)undoLastColorBlock
{
    if (self.colorBlockArray.count == 0) {
        return;
    }
    
    [self.colorBlockArray enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![[obj objectForKey:@"alreadyUndo"] boolValue]) {
            [obj setValue:@YES forKey:@"alreadyUndo"];
            CAShapeLayer * colorBlockLayer = [obj objectForKey:@"layer"];
            colorBlockLayer.hidden = YES;
            *stop = YES;
        }
    }];
}

//确认所有色块的操作
-(void)sureColorBlock
{
    if (self.colorBlockArray.count == 0) {
        return;
    }
    
    [self.colorBlockArray enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([[obj objectForKey:@"alreadyUndo"] boolValue]) {
            CAShapeLayer * colorBlockLayer = [obj objectForKey:@"layer"];
            [colorBlockLayer removeFromSuperlayer];
            [self.colorBlockArray removeObjectAtIndex:idx];
        }
    }];
    
    [self.colorBlockArray enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([[obj objectForKey:@"new"] boolValue]) {
            [obj setValue:@NO forKey:@"new"];
        }
    }];
}

//生成随机色
-(UIColor *)createRandomColor
{
    UIColor * color = [UIColor colorWithRed:(arc4random()%255) / 255.0 green:(arc4random()%255) / 255.0 blue:(arc4random()%255) / 255.0 alpha:0.85];
    return color;
}

-(void)initUI
{
    //默认截图时间间隔
    CGFloat imageSpace = 3.0;
    //图片最小宽度
    CGFloat minWidth = 30;
    
    self.asset = [[AVURLAsset alloc] initWithURL:self.videoUrl options:nil];
    CGFloat duration = CMTimeGetSeconds(self.asset.duration);
    //计算当前应截取图片数量
    NSInteger imageCount = duration / imageSpace;
    //按当前图片数据计算图片宽度
    CGFloat currentWidth = CGRectGetWidth(self.frame) / imageCount;
    //宽度小于最小宽度，按最小宽度截图图片
    if (currentWidth < minWidth) {
        currentWidth = minWidth;
        imageCount = CGRectGetWidth(self.frame) / currentWidth;
    }
    
    for (int i = 0; i < imageCount; i++) {
        UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(currentWidth * i, 5, currentWidth, self.frame.size.height - 10)];
        imageView.layer.masksToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:imageView];
        
        //截图
        UIImage * image = [DWShortTool dw_getThumbnailImage:self.videoUrl.path time:i * imageSpace];
        imageView.image = image;
    }
    
    self.lineView = [DWControl initViewWithFrame:CGRectMake(0, 0, 2, self.frame.size.height) BackgroundColor:[UIColor whiteColor] Tag:0 AndAlpha:1];
    self.lineView.layer.masksToBounds = YES;
    self.lineView.layer.cornerRadius = 2;
    [self addSubview:self.lineView];
    
    
}

//-(void)changeProgress:(CGFloat)progress
-(void)setStartPosition:(CGFloat)position
{
    [self.lineView.layer removeAllAnimations];
    
    CGFloat duration = CMTimeGetSeconds(self.asset.duration);

    CABasicAnimation * offsetAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    offsetAnimation.toValue = @(self.frame.size.width - 2);
    offsetAnimation.fromValue = @((self.frame.size.width - 2) * position);
    offsetAnimation.duration = duration * (1 - position);
    offsetAnimation.removedOnCompletion = NO;
    offsetAnimation.fillMode = kCAFillModeForwards;
    offsetAnimation.delegate = self;
    [self.lineView.layer addAnimation:offsetAnimation forKey:@"offsetAnimation"];
}

//开始添加色块
-(void)startAddColorBlockWithPosition:(CGFloat)position
{
    CAShapeLayer * colorBlockLayer = [CAShapeLayer layer];
    colorBlockLayer.frame = CGRectMake((self.frame.size.width - 1) * position, 5, 0, self.frame.size.height - 10);
    colorBlockLayer.backgroundColor = [self createRandomColor].CGColor;
    colorBlockLayer.strokeColor = colorBlockLayer.backgroundColor;
    colorBlockLayer.lineWidth = colorBlockLayer.frame.size.height;
//    [self.layer addSublayer:colorBlockLayer];
    [self.layer insertSublayer:colorBlockLayer below:self.lineView.layer];
    
    CGFloat duration = CMTimeGetSeconds(self.asset.duration);

    CGFloat maxWidth = self.frame.size.width * (1 - position);
    
    UIBezierPath * bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointMake(0, colorBlockLayer.lineWidth / 2.0)];
    [bezierPath addLineToPoint:CGPointMake(maxWidth, colorBlockLayer.lineWidth / 2.0)];
    colorBlockLayer.path = bezierPath.CGPath;
    
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.fromValue = @0;
    animation.toValue = @1;
    animation.duration = duration * (1 - position);
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    [colorBlockLayer addAnimation:animation forKey:@"colorBlockAnimation"];
        
    NSMutableDictionary * colorBlockDict = [NSMutableDictionary dictionaryWithDictionary:@{@"layer":colorBlockLayer,
                                                                                           @"startPosition":[NSNumber numberWithFloat:position],
                                                                                           @"stopPosition":@0,
                                                                                           @"new":@YES,
                                                                                           @"alreadyUndo":@NO}];
    
    [self.colorBlockArray addObject:colorBlockDict];

    self.colorBlockDict = colorBlockDict;
}

//停止添加色块
-(void)stopAddColorBlockWithPosition:(CGFloat)position
{
    if (!self.colorBlockDict) {
        return;
    }
    
    [self.colorBlockDict setValue:[NSNumber numberWithFloat:position] forKey:@"stopPosition"];
    CAShapeLayer * colorBlockLayer = [self.colorBlockDict objectForKey:@"layer"];
    
    [colorBlockLayer removeAllAnimations];
    
    //重新设置path
    CGFloat width = (position - [[self.colorBlockDict objectForKey:@"startPosition"] floatValue]) * self.frame.size.width;

    UIBezierPath * bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointMake(0, colorBlockLayer.lineWidth / 2.0)];
    [bezierPath addLineToPoint:CGPointMake(width, colorBlockLayer.lineWidth / 2.0)];
    colorBlockLayer.path = bezierPath.CGPath;
    
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag) {
        
        self.lineView.frame = CGRectMake(0, 0, 2, self.frame.size.height);

    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
