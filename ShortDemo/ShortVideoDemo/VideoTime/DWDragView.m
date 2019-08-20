//
//  DWDragView.m
//  ShortVideoDemo
//
//  Created by luyang on 2018/6/25.
//  Copyright © 2018年 Myself. All rights reserved.
//

#import "DWDragView.h"




@interface DWDragView()

@property (nonatomic,assign)BOOL isLeft;



@end

@implementation DWDragView

- (instancetype )initWithFrame:(CGRect)frame isLeft:(BOOL )isLeft{
    
    self =[super initWithFrame:frame];
    if (self) {
        
        self.isLeft =isLeft;
        [self loadSubviews];
       
        
    }
    
    return self;
}

- (void)loadSubviews{
    
    CGFloat width =self.frame.size.width;
    CGFloat height =self.frame.size.height;
    
    self.backgroundColor =[UIColor clearColor];
    self.imageView =[[UIImageView alloc]init];
    CGRect frame;
    if (_isLeft) {
        
        frame =CGRectMake((width-10),0,10,height);
        
    }else{
        
        frame =CGRectMake(0,0,10,height);
        
    }
    self.imageView.frame =frame;
    self.imageView.backgroundColor =[UIColor blackColor];
    [self addSubview:_imageView];
    
}

- (BOOL)pointInside:(CGPoint)point withEvent:(nullable UIEvent *)event{
    
    
    return [self pointInsideSelf:point];
}

- (BOOL )pointInsideSelf:(CGPoint )point{
    
    CGRect frame =self.bounds;
    CGRect hitFrame =UIEdgeInsetsInsetRect(frame,_hitTestEdgeInsets);
    
    return CGRectContainsPoint(hitFrame, point);
}

- (BOOL )pointInsideImageView:(CGPoint )point{
    
    CGRect frame =_imageView.frame;
    CGRect hitFrame =UIEdgeInsetsInsetRect(frame, _hitTestEdgeInsets);
    
    return CGRectContainsPoint(hitFrame,point);
}



@end
