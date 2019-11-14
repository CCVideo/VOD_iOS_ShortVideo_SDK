//
//  DWDelayView.h
//  ShortVideoDemo
//
//  Created by zwl on 2019/9/12.
//  Copyright © 2019 Myself. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^AnimationFinish)(void);

@interface DWDelayView : UIView

-(void)beginAnimation;

@property(nonatomic,copy)AnimationFinish finish;

@end

NS_ASSUME_NONNULL_END
