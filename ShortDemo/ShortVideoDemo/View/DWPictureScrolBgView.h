//
//  DWPictureScrolBgView.h
//  ShortVideoDemo
//
//  Created by zwl on 2019/12/30.
//  Copyright © 2019 Myself. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DWPictureScrolBgViewDelegate <NSObject>

//图片选中
-(void)pictureScrolBgViewDidSelectImage:(NSInteger)imageIndex;

//转场选中
-(void)pictureScrolBgViewDidSelectTransition:(NSInteger)transitionIndex;

//开始滑动
-(void)pictureScrolBgViewBeginDragging;

@end

//图片及特效view
@interface DWPictureScrolBgView : UIView

@property(nonatomic,weak)id <DWPictureScrolBgViewDelegate> delegate;

@property(nonatomic,assign,readonly)NSInteger selectImageIndex;//当前正在编辑的图片下标

@property(nonatomic,assign,readonly)NSInteger selectTransitionIndex;//当前正在编辑的转场下标

- (instancetype)initWithImageArray:(NSArray *)imagesArray;

//设置图片特效
//style 0 无 1 放大 2 缩小 3 左滑 4 右滑
-(void)setImageIndex:(NSInteger)index WithStyle:(NSInteger)style;
//设置图片时长
-(void)setImageIndex:(NSInteger)index WithDuration:(CGFloat)duration;

//设置转场特效
//style 0 无 1 重叠 2 闪黑 3 闪白 4 圆形
-(void)setTransitionIndex:(NSInteger)index WithStyle:(NSInteger)style;
//设置转场时长
-(void)setTransitionIndex:(NSInteger)index WithDuration:(CGFloat)duration;

//修改进度条
-(void)setScrollViewOffsetWithPercentage:(CGFloat)percentage;

@end

@interface DWPictureScrolImageButton : UIButton

@end

NS_ASSUME_NONNULL_END
