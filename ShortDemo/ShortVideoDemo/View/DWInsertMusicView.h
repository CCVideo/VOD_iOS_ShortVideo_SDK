//
//  DWInsertMusicView.h
//  ShortVideoDemo
//
//  Created by zwl on 2019/9/20.
//  Copyright © 2019 Myself. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DWInsertMusicViewDelegate <NSObject>

-(void)DWInsertMusicOriginalVolumeValueChange:(CGFloat)originalVolume;

-(void)DWInsertMusicDismiss;

-(void)DWInsertMusicViewDidFinishWithAudioPath:(NSString *)audioPath OriginalVolume:(CGFloat)originalVolume InsertVolume:(CGFloat)insertVolume StartTime:(CMTime)start DurationTime:(CMTime)duration;

@end

@interface DWInsertMusicView : UIView

@property(nonatomic,weak)id <DWInsertMusicViewDelegate> delegate;

@property(nonatomic,copy)NSString * audioPath;

-(void)audioPlay;

-(void)audioPause;

-(void)repeatPlay;

-(void)dismiss;

@end

typedef void(^MusicSpectrumPostionValueChange)(CGFloat postion);

@interface DWMusicSpectrum : UIView

@property(nonatomic,copy)MusicSpectrumPostionValueChange valueChange;

-(void)setCurrentTime:(NSString *)time;

-(void)setTotalTime:(NSString *)time;

-(void)setPostion:(CGFloat)postion;

@end


