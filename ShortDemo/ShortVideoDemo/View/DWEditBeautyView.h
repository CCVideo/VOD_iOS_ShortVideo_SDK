//
//  DWEditBeautyView.h
//  ShortVideoDemo
//
//  Created by zwl on 2019/9/17.
//  Copyright © 2019 Myself. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DWEditBeautyViewDelegate <NSObject>

-(void)DWEditBeautyDismiss;

-(void)DWEditBeautyViewWhiteValueChange:(NSInteger)value;

-(void)DWEditBeautyViewMicroderValueChange:(NSInteger)value;

@end

@interface DWEditBeautyView : UIView

-(instancetype)initWithVideoURL:(NSURL *)videoURL;

@property(nonatomic,weak)id <DWEditBeautyViewDelegate> delegate;

@end
