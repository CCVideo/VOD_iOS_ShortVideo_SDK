//
//  DWVideoEffectsView.h
//  ShortVideoDemo
//
//  Created by zwl on 2020/2/26.
//  Copyright © 2020 Myself. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DWVideoEffectsViewDelegate <NSObject>

//取消回调
-(void)videoEffectsViewDismiss;

//确定回调
-(void)videoEffectsViewSure;

//撤销回调
-(void)videoEffectsViewUndo;

//开始添加特效
-(void)videoEffectsViewStartAddEffect:(NSInteger)style;

//结束添加特效
-(void)videoEffectsViewStopAddEffect;

@end

@interface DWVideoEffectsView : UIView

//是否重新开始动画
@property(nonatomic,assign,readonly)BOOL isRepeat;

@property(nonatomic,weak) id <DWVideoEffectsViewDelegate> delegate;

-(instancetype)initWithVideoURL:(NSURL *)videoURL;

//设置当前播放位置
-(void)setPosition:(CGFloat)position WithRepeat:(BOOL)isRepeat;

//修改进度条
//-(void)changeProgress:(CGFloat)progress;

@end


@interface DWVideoEffectsButton : UIButton

@end
