//
//  DWTransitionAnimation.m
//  testPictureVideo
//
//  Created by zwl on 2019/12/19.
//  Copyright © 2019 zwl. All rights reserved.
//

#import "DWTransitionAnimation.h"
#import "ObjectExtension.h"

@implementation DWTransitionAnimation

+(NSArray *)transitionAnimationCreateWithStyle:(DWTransitionAnimationStyle)style
                                     BeginTime:(CGFloat)beginTime
                                      Duration:(CGFloat)duration
                                     VideoSize:(CGSize)videoSize
                                       isFront:(BOOL)isFront
{
    NSMutableArray * animationArray = [NSMutableArray array];

    CGFloat defaultDuration = 0.01;

    if (style == DWTransitionAnimationStyleCover) {
        //重叠
        if (isFront) {
            CABasicAnimation * coverAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
            coverAnimation.fromValue = @1;
            coverAnimation.toValue = @0;
            coverAnimation.beginTime = beginTime;
            coverAnimation.duration = duration;
            coverAnimation.removedOnCompletion = NO;
            coverAnimation.fillMode = kCAFillModeForwards;
            [animationArray addObject:coverAnimation];
        }else{

        }
        
    }else if (style == DWTransitionAnimationStyleBlack) {
        //闪黑
        if (isFront) {
            CABasicAnimation * opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
            opacityAnimation.toValue = @0;
            opacityAnimation.beginTime = beginTime;
            opacityAnimation.duration = duration;
            opacityAnimation.removedOnCompletion = NO;
            opacityAnimation.fillMode = kCAFillModeForwards;
            [animationArray addObject:opacityAnimation];
        }else{
            CAKeyframeAnimation * contentsAnimation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
            contentsAnimation.values = @[(__bridge UIImage*)[[UIColor blackColor] createImage].CGImage];
            contentsAnimation.beginTime = beginTime;
            contentsAnimation.duration = duration - defaultDuration;
            [animationArray addObject:contentsAnimation];
        }
        
    }else if (style == DWTransitionAnimationStyleWhite) {
        //闪白
        if (isFront) {
            CABasicAnimation * opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
            opacityAnimation.toValue = @0;
            opacityAnimation.beginTime = beginTime;
            opacityAnimation.duration = duration;
            opacityAnimation.removedOnCompletion = NO;
            opacityAnimation.fillMode = kCAFillModeForwards;
            [animationArray addObject:opacityAnimation];
        }else{
              CAKeyframeAnimation * contentsAnimation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
             contentsAnimation.values = @[(__bridge UIImage*)[[UIColor whiteColor] createImage].CGImage];
//            contentsAnimation.values = @[(__bridge UIImage*)[[UIColor whiteColor] createImageWithSize:videoSize].CGImage];
             contentsAnimation.beginTime = beginTime;
             contentsAnimation.duration = duration - defaultDuration;
             [animationArray addObject:contentsAnimation];
        }
    }else{
        
        if (isFront) {
            CABasicAnimation * opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
            opacityAnimation.fromValue = @1;
            opacityAnimation.toValue = @0;
            opacityAnimation.beginTime = beginTime + duration - defaultDuration;
            opacityAnimation.duration = defaultDuration;
            opacityAnimation.removedOnCompletion = NO;
            opacityAnimation.fillMode = kCAFillModeForwards;
            [animationArray addObject:opacityAnimation];
        }else{
            //圆形
            //这个是针对于背景imageLayer的
            CABasicAnimation * opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
            opacityAnimation.toValue = @1;
            opacityAnimation.beginTime = 0;
            opacityAnimation.duration = defaultDuration;
            opacityAnimation.removedOnCompletion = NO;
            opacityAnimation.fillMode = kCAFillModeForwards;
            [animationArray addObject:opacityAnimation];
        }
    }

    return animationArray;
}

//生成圆形动画
+(NSArray *)circleMaskAnimationCreateWithDuration:(CGFloat)duration
                                        VideoSize:(CGSize)videoSize
{
    //生成圆形maskLayer的动画
    NSMutableArray * animationArray = [NSMutableArray array];

//    CGFloat defaultDuration = 0.01;
    
    CGFloat radius = [DWTransitionAnimation getMaxRadiusWithVideoSize:videoSize];
    
    CABasicAnimation * boundAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
    boundAnimation.fromValue = [NSValue valueWithCGRect:CGRectZero];
    boundAnimation.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, radius * 2, radius * 2)];
    boundAnimation.beginTime = 0;
    boundAnimation.duration = duration;
    boundAnimation.removedOnCompletion = NO;
    boundAnimation.fillMode = kCAFillModeForwards;
    [animationArray addObject:boundAnimation];
    
    CABasicAnimation * cornerRadiusAnimation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
    cornerRadiusAnimation.fromValue = @0;
    cornerRadiusAnimation.toValue = @(radius);
    cornerRadiusAnimation.beginTime = 0;
    cornerRadiusAnimation.duration = duration;
    cornerRadiusAnimation.removedOnCompletion = NO;
    cornerRadiusAnimation.fillMode = kCAFillModeForwards;
    [animationArray addObject:cornerRadiusAnimation];
    
    return animationArray;
}

//计算圆形动画最大半径
+(double)getMaxRadiusWithVideoSize:(CGSize)videoSize
{
    return sqrtf(pow(videoSize.width, 2) + pow(videoSize.height, 2)) / 2.0;
}

@end
