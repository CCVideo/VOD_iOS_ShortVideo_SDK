//
//  DWEditCropView.h
//  ShortVideoDemo
//
//  Created by zwl on 2019/9/20.
//  Copyright © 2019 Myself. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DWEditCropViewDelegate <NSObject>

-(void)DWEditCropViewDidChangeSpeed:(CGFloat)speed;

-(void)DWEditCropViewLeftButtonAction;

-(void)DWEditCropViewNextButtonAction;

@end

@interface DWEditCropView : UIView

-(void)seekToTime:(CGFloat)second;

@property(nonatomic,weak) id <DWEditCropViewDelegate> delegate;

@property(nonatomic,strong)NSURL * videoURL;

@property(nonatomic,assign)CGFloat videoScale;//父视图缩放比例

@property(nonatomic,assign)CMTime start;
@property(nonatomic,assign)CMTime duration;
@property(nonatomic,assign)CGRect scaleFrame;
@property(nonatomic,assign)CGFloat speed;

@end

