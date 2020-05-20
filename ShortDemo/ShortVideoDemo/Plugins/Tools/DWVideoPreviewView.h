//
//  DWVideoPreviewView.h
//  ShortVideoDemo
//
//  Created by zwl on 2020/2/27.
//  Copyright © 2020 Myself. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DWVideoPreviewView : UIView

//@property(nonatomic,weak) id <DWVideoPreviewViewDelegate> delegate;

-(instancetype)initWithFrame:(CGRect)frame VideoUrl:(NSURL *)videoUrl;

//修改进度当前播放起始位置
-(void)setStartPosition:(CGFloat)position;

//开始添加色块
-(void)startAddColorBlockWithPosition:(CGFloat)position;

//停止添加色块
-(void)stopAddColorBlockWithPosition:(CGFloat)position;

//取消色块
-(void)dismissAllColorBlock;
//撤销最新的色块
-(void)undoLastColorBlock;
//确认色块的操作
-(void)sureColorBlock;

@end
