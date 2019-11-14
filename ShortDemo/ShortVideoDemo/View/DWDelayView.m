//
//  DWDelayView.m
//  ShortVideoDemo
//
//  Created by zwl on 2019/9/12.
//  Copyright © 2019 Myself. All rights reserved.
//

#import "DWDelayView.h"

@interface DWDelayView () <CAAnimationDelegate>

@end

@implementation DWDelayView

-(instancetype)init
{
    if (self == [super init]) {
        
        self.backgroundColor = [UIColor clearColor];
        [[UIApplication sharedApplication].keyWindow addSubview:self];
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(@0);
            make.top.and.bottom.equalTo(@0);
        }];
    }
    return self;
}

-(void)beginAnimation
{
    CALayer * animationLayer = [CALayer layer];
    animationLayer.frame = CGRectMake((ScreenWidth - 150) / 2.0, (ScreenHeight - 150) / 2.0, 150, 150);
    [self.layer addSublayer:animationLayer];
    
    CAKeyframeAnimation * animation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
    NSMutableArray * images = [NSMutableArray array];
    for (int i = 3; i >= 1; i--) {
        [images addObject:(__bridge id)[UIImage imageNamed:[NSString stringWithFormat:@"icon_delay_%d.png",i]].CGImage];
    }
    
    animation.values = images;
    animation.duration = 3;
    animation.delegate = self;

    /*
     ①NSString *type;（表示其渐变的效果的类型。有4种分别为kCATransitionFade（消退）kCATransitionMoveIn（渐入）kCATransitionPush（推动）kCATransitionReveal（揭开）等不同的效果）
     
     ②NSString *subtype;（此类用于过渡运动方向的转变且分为上下左右四种：kCATransitionFromRight、kCATransitionFromLeft、kCATransitionFromTop、kCATransitionFromBottom）
     */
    [animationLayer addAnimation:animation forKey:@"keyAnimation"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (self.finish) {
        self.finish();
    }
    
    [self removeFromSuperview];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
