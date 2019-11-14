//
//  DWVideoTrimmerView.h
//  ShortVideoDemo
//
//  Created by zwl on 2019/10/23.
//  Copyright © 2019 Myself. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DWVideoTrimmerView;

NS_ASSUME_NONNULL_BEGIN

@protocol DWVideoTrimmerViewDelegate <NSObject>

-(void)DWVideoTrimmerView:(DWVideoTrimmerView *)videoTrimmerView SureActionWithStart:(CMTime)start Duration:(CMTime)duration;

-(void)DWVideoTrimmerViewDismiss:(DWVideoTrimmerView *)videoTrimmerView;

@end

typedef NS_ENUM(NSInteger, DWVideoTrimmerViewStyle) {
    DWVideoTrimmerViewStyle_Sticker,
    DWVideoTrimmerViewStyle_Bubble
};


@interface DWVideoTrimmerView : UIView

@property(nonatomic,weak) id <DWVideoTrimmerViewDelegate> delegate;

@property(nonatomic,strong)NSURL * videoURL;

@property(nonatomic,assign)DWVideoTrimmerViewStyle style;

@end

NS_ASSUME_NONNULL_END
