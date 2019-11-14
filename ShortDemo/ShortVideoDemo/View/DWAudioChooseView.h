//
//  DWAudioChooseView.h
//  ShortVideoDemo
//
//  Created by zwl on 2019/10/29.
//  Copyright © 2019 Myself. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DidChooseAudio)(NSString * audioPath);
typedef void(^DidCancel)(BOOL isSelect);

@interface DWAudioChooseView : UIView

@property(nonatomic,strong)NSArray * array;

@property(nonatomic,copy)DidChooseAudio chooseAudio;
@property(nonatomic,copy)DidCancel cancel;

@end

@interface DWAudioChooseTableViewCell : UITableViewCell

-(void)setAudioName:(NSString *)name Author:(NSString *)author Time:(NSString *)time WithSelect:(BOOL)isSelect;

@end
