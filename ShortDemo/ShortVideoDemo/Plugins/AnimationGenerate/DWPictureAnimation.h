//
//  DWPictureAnimation.h
//  testPictureVideo
//
//  Created by zwl on 2019/12/19.
//  Copyright © 2019 zwl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DWPictureAnimationStyle) {
    DWPictureAnimationStyleNone, //无
    DWPictureAnimationStyleIncrease,  //放大
    DWPictureAnimationStyleDecrease,  //缩小
    DWPictureAnimationStyleLeft,      //左滑
    DWPictureAnimationStyleRight,     //右滑
};

///图片特效生成
@interface DWPictureAnimation : NSObject

/// 返回图片特效动画数据
/// @param style 特效样式
/// @param pictureDuration 图片特效持续时间
/// @param frontTransitionDuration 转场动画持续时间
/// @param videoSize 合成视频的大小，左滑，右滑特效需要。
/// @param isLast 是否是最后一张图片
+(NSArray *)pictureAnimationCreateWithStyle:(DWPictureAnimationStyle)style
                            PictureDuration:(CGFloat)pictureDuration
                    FrontTransitionDuration:(CGFloat)frontTransitionDuration
                                  VideoSize:(CGSize)videoSize
                                     isLast:(BOOL)isLast;


@end
