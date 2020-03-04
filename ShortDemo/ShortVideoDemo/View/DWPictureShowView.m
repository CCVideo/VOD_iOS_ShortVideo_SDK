//
//  DWPictureShowView.m
//  ShortVideoDemo
//
//  Created by zwl on 2019/12/30.
//  Copyright © 2019 Myself. All rights reserved.
//

#import "DWPictureShowView.h"

@interface DWPictureShowView () 

@property(nonatomic,strong)NSMutableArray * layersArray;

@property(nonatomic,assign)CFTimeInterval pauseTime;

@end

@implementation DWPictureShowView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.layersArray = [[NSMutableArray alloc]init];

        self.layer.masksToBounds = YES;
        
    }
    return self;
}

-(void)resetUIWithNodeArrays:(NSArray <DWPictureNodeModel *> *)pictureNodesArray
{
    //清空已存在的layer及动画效果
    [self.layer removeAllAnimations];
    
    for (CALayer * subLayer in self.layersArray) {
        [subLayer removeFromSuperlayer];
    }
    [self.layersArray removeAllObjects];
    
    self.layer.speed = 1;
    self.layer.timeOffset = 0.0;
    self.layer.beginTime = 0.0;
    
    for (int i = 0; i < pictureNodesArray.count; i++) {
        
        DWPictureNodeModel * pictureNodeModel = [pictureNodesArray objectAtIndex:i];
        UIImage * image = pictureNodeModel.image;
        CGFloat beginTime = pictureNodeModel.beginTime;
        CGFloat duration = pictureNodeModel.duration;
        
        NSArray <CAAnimation *> * animations = pictureNodeModel.animations;
        
        CALayer * imageLayer = [CALayer layer];
        imageLayer.frame = self.bounds;
        imageLayer.masksToBounds = YES;
        imageLayer.contentsGravity = kCAGravityResizeAspect;

        imageLayer.contents = (__bridge UIImage*)image.CGImage;
        if (i == 0) {
            imageLayer.opacity = 1;
        }else{
            imageLayer.opacity = 0;
        }
        
        if (i == 0) {
            [self.layer addSublayer:imageLayer];
        }else{
            if (pictureNodeModel.isCover) {
                [self.layer addSublayer:imageLayer];
            }else{
                [self.layer insertSublayer:imageLayer atIndex:0];
            }
        }

        //处理CAAnimationGroup
        CAAnimationGroup * group = [CAAnimationGroup animation];
        group.animations = animations;
        group.beginTime = CACurrentMediaTime() + beginTime;
        group.duration = duration;
        group.fillMode = kCAFillModeForwards;
        group.removedOnCompletion = NO;
        [imageLayer addAnimation:group forKey:nil];

        CALayer * maskLayer = pictureNodeModel.maskLayer;
        if (maskLayer) {
            maskLayer.frame = imageLayer.bounds;
            imageLayer.mask = maskLayer;
            
            CAAnimationGroup * maskGroup = [CAAnimationGroup animation];
            maskGroup.animations = pictureNodeModel.maskAnimations;
            maskGroup.beginTime = CACurrentMediaTime() + pictureNodeModel.maskAnimationBeginTime;
            maskGroup.duration = pictureNodeModel.maskAnimationDuration;
            maskGroup.fillMode = kCAFillModeForwards;
            maskGroup.removedOnCompletion = NO;
            [maskLayer addAnimation:maskGroup forKey:nil];
        }
        
        [self.layersArray addObject:imageLayer];
        
//        NSLog(@"idx:%d beginTime:%lf duration:%lf",i,beginTime,duration);
    }
}

-(void)play
{
    if (self.layer.speed == 1) {
        return;
    }
    
    CFTimeInterval pauseTime = [self.layer timeOffset];
    self.layer.speed = 1.0;
    self.layer.timeOffset = 0.0;
    self.layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [self.layer convertTime:CACurrentMediaTime() fromLayer:nil] - pauseTime;
    self.layer.beginTime = timeSincePause;
}

-(void)pause
{
    if (self.layer.speed == 0) {
        return;
    }
    
    CFTimeInterval pauseTime = [self.layer convertTime:CACurrentMediaTime() fromLayer:nil];
    
    self.layer.speed = 0;
    
    self.layer.timeOffset = pauseTime;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
