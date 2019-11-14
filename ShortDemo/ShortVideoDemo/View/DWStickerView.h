//
//  DWStickerView.h
//  ShortVideoDemo
//
//  Created by zwl on 2019/9/16.
//  Copyright © 2019 Myself. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DWStickerViewDelegate <NSObject>

//选中贴纸
-(void)DWStickerViewDidSelect:(NSInteger)index;

//隐藏
-(void)DWStickerViewDismiss;

@end

@interface DWStickerView : UIView

@property(nonatomic,weak) id <DWStickerViewDelegate> delegate;

@end
