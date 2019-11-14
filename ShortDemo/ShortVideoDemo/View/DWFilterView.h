//
//  DWFilterView.h
//  ShortVideoDemo
//
//  Created by zwl on 2019/9/11.
//  Copyright © 2019 Myself. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DWFilterViewDelegate <NSObject>

-(void)DWFilterViewFinishWithIndex:(NSInteger)index;

-(void)DWFilterViewDismiss;

@end

@interface DWFilterView : UIView

@property(nonatomic,weak) id <DWFilterViewDelegate> delegate;

-(void)show;

-(void)dismiss;

@end

@interface DWFilterViewButton : UIButton

@end

NS_ASSUME_NONNULL_END
