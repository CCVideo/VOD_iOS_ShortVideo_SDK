//
//  DWTransitionAnimation.h
//  testPictureVideo
//
//  Created by zwl on 2019/12/19.
//  Copyright © 2019 zwl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DWTransitionAnimationStyle) {
    DWTransitionAnimationStyleCover, //重叠
    DWTransitionAnimationStyleBlack,  //闪黑
    DWTransitionAnimationStyleWhite,  //闪白
    DWTransitionAnimationStyleCircle, //圆形
};

//转场特效生成
@interface DWTransitionAnimation : NSObject

/// 返回转场动画特效
/// @param style 转场动画样式
/// @param beginTime 特效持续时间
/// @param duration 转场动画持续时间
/// @param videoSize 合成视频的大小
/// @param isFront 转场特效是否在图片之前
+(NSArray *)transitionAnimationCreateWithStyle:(DWTransitionAnimationStyle)style
                                     BeginTime:(CGFloat)beginTime
                                      Duration:(CGFloat)duration
                                     VideoSize:(CGSize)videoSize
                                       isFront:(BOOL)isFront;

//生成圆形动画
+(NSArray *)circleMaskAnimationCreateWithDuration:(CGFloat)duration
                                        VideoSize:(CGSize)videoSize;

@end
