//
//  DWShootingBottomView.h
//  ShortVideoDemo
//
//  Created by zwl on 2019/9/11.
//  Copyright © 2019 Myself. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DWShootingBottomViewDelegate <NSObject>

-(void)DWShootingBottomViewRecordButtonAction:(BOOL)isSelect;

//style = 1
-(void)DWShootingBottomViewBeautyButtonAction;

-(void)DWShootingBottomViewFilterButtonAction;

-(void)DWShootingBottomViewUploadButtonAction;

//style = 2
-(void)DWShootingBottomViewFinishButtonAction;

//style = 3
-(void)DWShootingBottomViewDeleteButtonAction;

@end

@interface DWShootingBottomView : UIView

-(void)setStyle:(NSInteger)style;

-(void)setRecordTime:(CGFloat)time;

-(void)resetRecordButtonStatus;

@property(nonatomic,weak) id <DWShootingBottomViewDelegate> delegate;

@end



@interface DWShootingBottomButton : UIButton

@end

NS_ASSUME_NONNULL_END
