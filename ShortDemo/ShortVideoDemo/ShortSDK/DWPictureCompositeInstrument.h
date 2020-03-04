//
//  DWPictureCompositeInstrument.h
//  ShortVideoDemo
//
//  Created by zwl on 2019/12/17.
//  Copyright © 2019 Myself. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@class DWPictureNodeModel;

typedef void(^DWPictureCompositeInstrumentComplete)(NSError *error ,NSURL *completeFileURL);

///图片合成视频功能
@interface DWPictureCompositeInstrument : NSObject

/// 视频分辨率，非空
@property(nonatomic,assign)CGSize videoSize;

/// 视频总时长，非空
@property(nonatomic,assign)CGFloat videoDuration;

/// 视频导出路径，非空
@property(nonatomic,copy)NSString * outPath;

/// 图片节点数组，非空。
@property(nonatomic,strong)NSArray <DWPictureNodeModel *> * pictureNodeModels;

/// 合成视频底色，默认纯黑
@property(nonatomic,copy)UIColor * videoBackgroundColor;

/// 视频压缩质量，默认AVAssetExportPresetMediumQuality
@property(nonatomic,copy)NSString * presetName;

/// 视频导出格式，默认AVFileTypeQuickTimeMovie
@property(nonatomic,copy)NSString * outputFileType;

/// 视频导出回调
@property(nonatomic,copy)DWPictureCompositeInstrumentComplete complete;

/// 开始合成视频
-(void)startComposite;

@end

@interface DWPictureNodeModel : NSObject

/// 图片，非空
@property(nonatomic,strong)UIImage * image;

/// 图片特效起始时间，默认0
@property(nonatomic,assign)CGFloat beginTime;

/// 图片特效持续时间，默认0
@property(nonatomic,assign)CGFloat duration;

/// 图片特效动画
@property(nonatomic,strong)NSArray <CAAnimation *> * animations;

/// 图层layer的mask图层，用于辅助完成动画效果
@property(nonatomic,strong)CALayer * maskLayer;

/// mask图层特效开始时间
@property(nonatomic,assign)CGFloat maskAnimationBeginTime;

/// mask图层特效持续时间
@property(nonatomic,assign)CGFloat maskAnimationDuration;

/// mask图层的特效
@property(nonatomic,strong)NSArray <CAAnimation *> * maskAnimations;

/// 图层layer的添加顺序，是否覆盖上一张，YES 覆盖，NO 不覆盖。默认：NO
@property(nonatomic,assign)BOOL isCover;

@end
