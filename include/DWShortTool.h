//
//  DWShortUtil.h
//  ShortVideoDemo
//
//  Created by luyang on 2017/8/2.
//  Copyright © 2017年 Myself. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>

@interface DWShortTool : NSObject



//取得缩略图 videoPath:文件路径 time:第几秒的缩略图
+(UIImage *)dw_getThumbnailImage:(NSString *)videoPath time:(NSTimeInterval )time;

//十六进制色彩
+ (UIColor *)dw_colorWithHexString: (NSString *) string;

//删除文件 filePath：文件路径 并返回是否成功
+ (BOOL )dw_deleteFileWithFilePath:(NSString *)filePath;

//文件大小
+ (CGFloat )dw_fileSizeAtPath:(NSString*)filePath;


/* 合成视频|转换视频格式
 @param videosPathArray:合成视频的路径数组
 @param outpath:输出路径
 @param outputFileType:视频格式
 @param presetName:分辨率
 @param  completeBlock  mergeFileURL:合成后新的视频URL
 
 
 */

+ (void)dw_mergeAndExportVideos:(NSArray *)videosPathArray withOutPath:(NSString *)outpath outputFileType:(NSString *)outputFileType  presetName:(NSString *)presetName  didComplete:(void(^)(NSError *error,NSURL *mergeFileURL) )completeBlock;




/**
 压缩视频

 @param videoPath 视频路径
 @param outPath 输出路径
 @param outputFileType 视频格式
 @param presetName 分辨率
 @param completeBlock 回调的block  compressionFileURL:压缩后的视频URL
 */
+ (void)dw_compressionAndExportVideo:(NSString *)videoPath withOutPath:(NSString *)outPath outputFileType:(NSString *)outputFileType  presetName:(NSString *)presetName  didComplete:(void(^)(NSError *error,NSURL *compressionFileURL) )completeBlock;



/**
 视频时长剪辑 视频区域不变

 @param videoPath 视频路径
 @param outPath 视频输出路径
 @param outputFileType 视频格式
 @param presetName 分辨率
 @param timeRange 截取视频的时间范围
 @param completeBlock 回调的block  compressionFileURL:剪辑后的视频URL
 */
+ (void)dw_videoTimeCropAndExportVideo:(NSString *)videoPath withOutPath:(NSString *)outPath outputFileType:(NSString *)outputFileType  presetName:(NSString *)presetName range:(CMTimeRange )timeRange didComplete:(void(^)(NSError *error,NSURL *compressionFileURL) )completeBlock;



/**
 视频区域剪裁 视频时长不变

 @param videoPath 视频路径
 @param outPath 视频输出路径
 @param outputFileType 视频格式
 @param presetName 分辨率
 @param videoSize 剪裁区域
 @param videoPoint 剪裁起点
 @param shouldScale 是否拉伸 YES拉伸 NO不拉伸 剪裁黑背景
 @param completeBlock 剪裁完成后的回调
 */
+ (void)dw_videoSizeCropAndExportVideo:(NSString *)videoPath withOutPath:(NSString *)outPath outputFileType:(NSString *)outputFileType  presetName:(NSString *)presetName size:(CGSize )videoSize point:(CGPoint )videoPoint shouldScale:(BOOL )shouldScale didComplete:(void(^)(NSError *error,NSURL *compressionFileURL) )completeBlock;


/**
 视频区域兼时长剪裁
 
 @param videoPath 视频路径
 @param outPath 视频输出路径
 @param outputFileType 视频格式
 @param presetName 分辨率
 @param videoSize 剪裁区域
 @param videoPoint 剪裁起点
 @param shouldScale 是否拉伸 YES拉伸 NO不拉伸 剪裁黑背景
 @param timeRange 截取视频的时间范围
 @param completeBlock 剪裁完成后的回调
 */
+ (void)dw_videoSizeAndTimeCropAndExportVideo:(NSString *)videoPath withOutPath:(NSString *)outPath outputFileType:(NSString *)outputFileType  presetName:(NSString *)presetName size:(CGSize )videoSize point:(CGPoint )videoPoint shouldScale:(BOOL )shouldScale range:(CMTimeRange)timeRange didComplete:(void(^)(NSError *error,NSURL *compressionFileURL) )completeBlock;


@end








