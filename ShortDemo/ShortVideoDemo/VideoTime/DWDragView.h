//
//  DWDragView.h
//  ShortVideoDemo
//
//  Created by luyang on 2018/6/25.
//  Copyright © 2018年 Myself. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DWDragView : UIView

@property (nonatomic,strong)UIImageView *imageView;


@property (nonatomic,assign)UIEdgeInsets hitTestEdgeInsets;

- (instancetype )initWithFrame:(CGRect)frame isLeft:(BOOL )isLeft;

- (BOOL )pointInsideImageView:(CGPoint )point;

@end
