//
//  DWBeautyView.h
//  ShortVideoDemo
//
//  Created by zwl on 2019/9/11.
//  Copyright © 2019 Myself. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DWBeautyViewDelegate <NSObject>

-(void)DWBeautyViewWhiteValueChange:(NSInteger)value;

-(void)DWBeautyViewMicroderValueChange:(NSInteger)value;

-(void)DWBeautyViewDismiss;

@end

@interface DWBeautyView : UIView

@property(nonatomic,weak) id <DWBeautyViewDelegate> delegate;

-(void)show;

-(void)dismiss;

@end

NS_ASSUME_NONNULL_END
