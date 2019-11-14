//
//  DWBubbleView.h
//  ShortVideoDemo
//
//  Created by zwl on 2019/9/18.
//  Copyright © 2019 Myself. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DWBubbleViewDelegate <NSObject>

//选中气泡文字
-(void)DWBubbleViewDidSelect:(NSInteger)index;

//隐藏
-(void)DWBubbleViewDismiss;

@end

@interface DWBubbleView : UIView

@property(nonatomic,weak) id <DWBubbleViewDelegate> delegate;

@end

@interface DWBubbleInputView : UIImageView

@property(nonatomic,assign)BOOL isEdit;

@property(nonatomic,strong)UILabel * placeholderLabel;

-(void)beginEdit;

-(void)endEdit;

@end
