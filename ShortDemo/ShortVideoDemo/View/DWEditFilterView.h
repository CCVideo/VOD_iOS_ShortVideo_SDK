//
//  DWEditFilterView.h
//  ShortVideoDemo
//
//  Created by zwl on 2019/9/19.
//  Copyright © 2019 Myself. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DWEditFilterViewDelegate <NSObject>

-(void)DWEditFilterSelectWithIndex:(NSInteger)index;

-(void)DWEditFilterDismiss;

@end

@interface DWEditFilterView : UIView

-(instancetype)initWithVideoURL:(NSURL *)videoURL;

@property(nonatomic,weak) id <DWEditFilterViewDelegate> delegate;

@end

