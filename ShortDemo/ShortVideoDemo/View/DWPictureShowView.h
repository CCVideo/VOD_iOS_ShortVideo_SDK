//
//  DWPictureShowView.h
//  ShortVideoDemo
//
//  Created by zwl on 2019/12/30.
//  Copyright © 2019 Myself. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DWPictureCompositeInstrument.h"

NS_ASSUME_NONNULL_BEGIN

///特效预览view
@interface DWPictureShowView : UIView

- (instancetype)initWithFrame:(CGRect)frame;

-(void)resetUIWithNodeArrays:(NSArray <DWPictureNodeModel *> *)pictureNodesArray;

-(void)play;

-(void)pause;

@end

NS_ASSUME_NONNULL_END
