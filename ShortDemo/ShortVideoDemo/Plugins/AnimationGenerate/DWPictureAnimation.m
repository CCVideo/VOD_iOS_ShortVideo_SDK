//
//  DWPictureAnimation.m
//  testPictureVideo
//
//  Created by zwl on 2019/12/19.
//  Copyright © 2019 zwl. All rights reserved.
//

#import "DWPictureAnimation.h"

@implementation DWPictureAnimation

+(NSArray *)pictureAnimationCreateWithStyle:(DWPictureAnimationStyle)style
                            PictureDuration:(CGFloat)pictureDuration
                    FrontTransitionDuration:(CGFloat)frontTransitionDuration
                                  VideoSize:(CGSize)videoSize
                                     isLast:(BOOL)isLast
{
    NSMutableArray * animationArray = [NSMutableArray array];
    
    CGFloat defaultDuration = 0.01;

    CABasicAnimation * showAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    showAnimation.fromValue = @0;
    showAnimation.toValue = @1;
    showAnimation.beginTime = 0;
    showAnimation.duration = defaultDuration;
    showAnimation.removedOnCompletion = NO;
    showAnimation.fillMode = kCAFillModeForwards;
    [animationArray addObject:showAnimation];
    
    if (style == DWPictureAnimationStyleNone) {
        
    }else if (style == DWPictureAnimationStyleIncrease) {
        //放大
        CABasicAnimation * increaseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        increaseAnimation.fromValue = @1;
        increaseAnimation.toValue = @1.5;
        increaseAnimation.beginTime = frontTransitionDuration;
        increaseAnimation.duration = pictureDuration - frontTransitionDuration - defaultDuration;
        increaseAnimation.removedOnCompletion = NO;
        increaseAnimation.fillMode = kCAFillModeForwards;
        [animationArray addObject:increaseAnimation];
    }else if (style == DWPictureAnimationStyleDecrease){
        //缩小
        CABasicAnimation * decreaseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        decreaseAnimation.fromValue = @1.5;
        decreaseAnimation.toValue = @1;
        decreaseAnimation.beginTime = frontTransitionDuration;
        decreaseAnimation.duration = pictureDuration - frontTransitionDuration - defaultDuration;
        decreaseAnimation.removedOnCompletion = NO;
        decreaseAnimation.fillMode = kCAFillModeForwards;
        [animationArray addObject:decreaseAnimation];
    }else if (style == DWPictureAnimationStyleLeft){
        //左滑
        CGFloat scale = 1.4;
        CGFloat width = videoSize.width;
        
        CABasicAnimation * scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scaleAnimation.fromValue = @1;
        scaleAnimation.toValue = @(scale);
        scaleAnimation.beginTime = frontTransitionDuration;
        scaleAnimation.duration = defaultDuration;
        scaleAnimation.removedOnCompletion = NO;
        scaleAnimation.fillMode = kCAFillModeForwards;
        [animationArray addObject:scaleAnimation];
        
        CABasicAnimation * positionAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
        positionAnimation.toValue = @(width * (scale - 1) / 2.0);
        positionAnimation.beginTime = scaleAnimation.beginTime;
        positionAnimation.duration = defaultDuration;
        positionAnimation.removedOnCompletion = NO;
        positionAnimation.fillMode = kCAFillModeForwards;
        [animationArray addObject:positionAnimation];
        
        //然后再给个左滑的动画
        CABasicAnimation * leftAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
        leftAnimation.toValue = @(-(width * (scale - 1) / 2.0));
        leftAnimation.beginTime = scaleAnimation.duration;
        leftAnimation.duration = pictureDuration - frontTransitionDuration - defaultDuration;
        leftAnimation.removedOnCompletion = NO;
        leftAnimation.fillMode = kCAFillModeForwards;
        [animationArray addObject:leftAnimation];
    }else{
        //右滑
        CGFloat scale = 1.4;
        CGFloat width = videoSize.width;
        
        CABasicAnimation * scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scaleAnimation.fromValue = @1;
        scaleAnimation.toValue = @(scale);
        scaleAnimation.beginTime = frontTransitionDuration;
        scaleAnimation.duration = defaultDuration;
        scaleAnimation.removedOnCompletion = NO;
        scaleAnimation.fillMode = kCAFillModeForwards;
        [animationArray addObject:scaleAnimation];
        
        CABasicAnimation * positionAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
        positionAnimation.toValue = @(-(width * (scale - 1) / 2.0));
        positionAnimation.beginTime = scaleAnimation.beginTime;
        positionAnimation.duration = defaultDuration;
        positionAnimation.removedOnCompletion = NO;
        positionAnimation.fillMode = kCAFillModeForwards;
        [animationArray addObject:positionAnimation];
        
        //然后再给个右滑的动画
        CABasicAnimation * rightAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
        rightAnimation.toValue = @(width * (scale - 1) / 2.0);
        rightAnimation.beginTime = scaleAnimation.duration;
        rightAnimation.duration = pictureDuration - frontTransitionDuration - defaultDuration;
        rightAnimation.removedOnCompletion = NO;
        rightAnimation.fillMode = kCAFillModeForwards;
        [animationArray addObject:rightAnimation];
    }
    
    if (!isLast) {
        CABasicAnimation * dismissAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
//        dismissAnimation.fromValue = @1;
        dismissAnimation.toValue = @0;
//        dismissAnimation.beginTime = pictureDuration + frontTransitionDuration - defaultDuration;
        dismissAnimation.beginTime = pictureDuration - defaultDuration;
        dismissAnimation.duration = defaultDuration;
        dismissAnimation.removedOnCompletion = NO;
        dismissAnimation.fillMode = kCAFillModeForwards;
        [animationArray addObject:dismissAnimation];
    }
    
    return animationArray;
}

@end
