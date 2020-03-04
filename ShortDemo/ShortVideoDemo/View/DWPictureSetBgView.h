//
//  DWPictureSetBgView.h
//  ShortVideoDemo
//
//  Created by zwl on 2019/12/30.
//  Copyright © 2019 Myself. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, DWPictureSetStyle) {
    DWPictureSetStylePicture,  //图片
    DWPictureSetStyleTransition,  //转场
};

@protocol DWPictureSetBgViewDelegate <NSObject>

//设置动画效果
-(void)pictureSetBgViewStyle:(DWPictureSetStyle)style Index:(NSInteger)index;

//设置时长
-(void)pictureSetBgViewStyle:(DWPictureSetStyle)style DurationChange:(CGFloat)duration;

//设置全部
-(void)pictureSetBgViewTotalSetStyle:(DWPictureSetStyle)style Index:(NSInteger)index;

@end

//特效设置view
@interface DWPictureSetBgView : UIView

@property(nonatomic,weak)id <DWPictureSetBgViewDelegate> delegate;

//默认值
@property(nonatomic,assign)CGFloat imageMinTime;
@property(nonatomic,assign)CGFloat imageMaxTime;

@property(nonatomic,assign)CGFloat transitionMinTime;
@property(nonatomic,assign)CGFloat transitionMaxTime;

//修改样式及默认值
-(void)resetStyle:(DWPictureSetStyle)style DurationPercentage:(CGFloat)durationPercentage AndSelectIndex:(NSInteger)selectIndex;

@end

@interface DWPictureSetBgButton : UIButton

@end

@interface DWPictureSetFuncButton : UIButton

@end

NS_ASSUME_NONNULL_END
