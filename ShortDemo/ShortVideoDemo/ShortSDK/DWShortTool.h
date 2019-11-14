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


/// 取得缩略图
/// @param videoPath 文件路径
/// @param time 第几秒的缩略图
+(UIImage *)dw_getThumbnailImage:(NSString *)videoPath time:(NSTimeInterval)time;

/// 十六进制色彩
/// @param string 色值
+(UIColor *)dw_colorWithHexString:(NSString *)string;


/// 删除文件
/// @param filePath 文件路径 并返回是否成功
+(BOOL)dw_deleteFileWithFilePath:(NSString *)filePath;


/// 获取文件大小
/// @param filePath 文件路径
+(CGFloat)dw_fileSizeAtPath:(NSString*)filePath;


/// 压缩视频
/// @param videoPath 视频路径
/// @param outPath 输出路径
/// @param outputFileType 视频格式
/// @param presetName 视频导出质量
/// @param completeBlock 完成后回调
+ (void)dw_compressionAndExportVideo:(NSString *)videoPath
                         withOutPath:(NSString *)outPath
                      outputFileType:(NSString *)outputFileType
                          presetName:(NSString *)presetName
                         didComplete:(void(^)(NSError *error,NSURL *compressionFileURL))completeBlock;


/// 视频时长剪辑 视频区域不变
/// @param videoPath 视频路径
/// @param outPath 视频输出路径
/// @param outputFileType 视频格式
/// @param presetName 视频导出质量
/// @param timeRange 截取视频的时间范围
/// @param completeBlock 完成后回调
+ (void)dw_videoTimeCropAndExportVideo:(NSString *)videoPath
                           withOutPath:(NSString *)outPath
                        outputFileType:(NSString *)outputFileType
                            presetName:(NSString *)presetName
                                 range:(CMTimeRange)timeRange
                           didComplete:(void(^)(NSError *error,NSURL *compressionFileURL))completeBlock;


/// 视频区域剪裁 视频时长不变
/// @param videoPath 视频路径
/// @param outPath 视频输出路径
/// @param outputFileType 视频格式
/// @param presetName 视频导出质量
/// @param videoSize 剪裁区域
/// @param videoPoint 剪裁起点
/// @param shouldScale 是否拉伸 YES拉伸 NO不拉伸 剪裁黑背景
/// @param completeBlock 剪裁完成后的回调
+ (void)dw_videoSizeCropAndExportVideo:(NSString *)videoPath
                           withOutPath:(NSString *)outPath
                        outputFileType:(NSString *)outputFileType
                            presetName:(NSString *)presetName
                                  size:(CGSize)videoSize
                                 point:(CGPoint)videoPoint
                           shouldScale:(BOOL)shouldScale
                           didComplete:(void(^)(NSError *error,NSURL *compressionFileURL))completeBlock;



/// 视频区域兼时长剪裁
/// @param videoPath 视频路径
/// @param outPath 视频输出路径
/// @param outputFileType 视频格式
/// @param presetName 视频导出质量
/// @param videoSize 剪裁区域
/// @param videoPoint 剪裁起点
/// @param shouldScale 是否拉伸 YES拉伸 NO不拉伸 剪裁黑背景
/// @param timeRange 截取视频的时间范围
/// @param completeBlock 剪裁完成后的回调
+ (void)dw_videoSizeAndTimeCropAndExportVideo:(NSString *)videoPath
                                  withOutPath:(NSString *)outPath
                               outputFileType:(NSString *)outputFileType
                                   presetName:(NSString *)presetName
                                         size:(CGSize)videoSize
                                        point:(CGPoint)videoPoint
                                  shouldScale:(BOOL)shouldScale
                                        range:(CMTimeRange)timeRange
                                  didComplete:(void(^)(NSError *error,NSURL *compressionFileURL))completeBlock;


/// 视频区域，时长，倍速剪裁
/// @param videoPath 视频路径
/// @param videoSize 剪裁区域，CGSizeZero不裁剪
/// @param videoPoint 剪裁起点
/// @param timeRange 截取视频的时间范围，kCMTimeRangeZero，不裁剪时长
/// @param videoRate 截取视频倍速
/// @param outPath 视频输出路径
/// @param outputFileType 视频格式
/// @param presetName 视频导出质量
/// @param completeBlock 完成后的回调
+ (void)dw_videoSizeAndTimeCropAndExportVideo:(NSString *)videoPath
                                         size:(CGSize)videoSize
                                        point:(CGPoint)videoPoint
                                        range:(CMTimeRange)timeRange
                                    videoRate:(CGFloat)videoRate
                                  withOutPath:(NSString *)outPath
                               outputFileType:(NSString *)outputFileType
                                   presetName:(NSString *)presetName
                                  didComplete:(void(^)(NSError *error,NSURL *compressionFileURL))completeBlock;

/// 添加单个视频水印
/// @param videoPath 视频路径
/// @param stickerImage 水印图片
/// @param stickerImagePoint 水印位置，point为水印所占视频位置的百分比。eg:CGPointMake(0.1, 0.1)
/// @param stickerImageSize 水印大小，为水印所占视频大小的百分比。eg:CGSizeMake(0.4, 0.4)
/// @param rotateAngle 水印旋转弧度。eg:M_PI_2
/// @param timeRange 添加水印的时间范围，kCMTimeRangeZero时，全部时长都添加水印
/// @param outPath 视频输出路径
/// @param outputFileType 视频格式
/// @param presetName 视频导出质量
/// @param completeBlock 完成后的回调
+ (void)dw_addStickerAndExportVideo:(NSString *)videoPath
                   withStickerImage:(UIImage *)stickerImage
                  stickerImagePoint:(CGPoint)stickerImagePoint
                   stickerImageSize:(CGSize)stickerImageSize
                        rotateAngle:(CGFloat)rotateAngle
                          timeRange:(CMTimeRange)timeRange
                            outPath:(NSString *)outPath
                     outputFileType:(NSString *)outputFileType
                         presetName:(NSString *)presetName
                        didComplete:(void(^)(NSError *error,NSURL *compressionFileURL))completeBlock;

/// 批量添加视频水印
/// @param videoPath 视频路径
/// @param stickerImages 水印图片数组
/// @param stickerImagePoints 水印位置数组，points为水印所占视频位置的百分比数组。eg:@[[NSValue valueWithCGPoint:CGPointMake(0.1, 0.1)]]
/// @param stickerImageSizes 水印大小数组，sizes为水印所占视频大小的百分比数组。eg:@[[NSValue valueWithCGPoint:CGSizeMake(0.4, 0.4)]]
/// @param rotateAngles 水印旋转弧度数据。eg:[NSNumber numberWithFloat:M_PI_2]
/// @param timeRanges 添加水印的时间范围数组，kCMTimeRangeZero时，全部时长都添加水印
/// @param outPath 视频输出路径
/// @param outputFileType 视频格式
/// @param presetName 视频导出质量
/// @param completeBlock 完成后的回调
+ (void)dw_addStickerAndExportVideo:(NSString *)videoPath
                  withStickerImages:(NSArray <UIImage *>*)stickerImages
                 stickerImagePoints:(NSArray <NSValue *> *)stickerImagePoints
                  stickerImageSizes:(NSArray <NSValue *> *)stickerImageSizes
                        rotateAngles:(NSArray <NSNumber *> *)rotateAngles
                         timeRanges:(NSArray <NSValue *> *)timeRanges
                            outPath:(NSString *)outPath
                     outputFileType:(NSString *)outputFileType
                         presetName:(NSString *)presetName
                        didComplete:(void(^)(NSError *error,NSURL *compressionFileURL))completeBlock;
 

/// 多视频合成
/// @param videosPath 视频路径数组
/// @param videoSize 合成视频尺寸，不设置（CGRectZero）默认取第一个视频大小为基准
/// @param outPath 输出路径
/// @param outputFileType 视频格式
/// @param presetName 视频导出质量
/// @param completeBlock 完成后的回调
+(void)dw_compositeAndExportVideos:(NSArray <NSString *>*)videosPath
                         withVideoSize:(CGSize)videoSize
                           outPath:(NSString *)outPath
                    outputFileType:(NSString *)outputFileType
                        presetName:(NSString *)presetName
                       didComplete:(void(^)(NSError *error,NSURL *compressionFileURL))completeBlock;

/// 插入音频
/// @param videoPath 视频路径
/// @param audioPath 待插入音频路径
/// @param originalVolume 原音频音量
/// @param insertVolume 插入音频音量
/// @param timeRange 插入音频范围，kCMTimeRangeZero时，从0开始添加
/// @param outPath 视频输出路径
/// @param outputFileType 视频格式
/// @param presetName 视频导出质量
/// @param completeBlock 完成后的回调
+(void)dw_insertAudioAndExportVideo:(NSString *)videoPath
                      withAudioPath:(NSString *)audioPath
                     originalVolume:(CGFloat)originalVolume
                       insertVolume:(CGFloat)insertVolume
                          timeRange:(CMTimeRange)timeRange
                            outPath:(NSString *)outPath
                     outputFileType:(NSString *)outputFileType
                         presetName:(NSString *)presetName
                        didComplete:(void(^)(NSError *error,NSURL *compressionFileURL))completeBlock;

/// 修改视频分辨率
/// @param videoPath 视频路径
/// @param videoSize 要输出的视频分辨率
/// @param outPath 视频输出路径
/// @param outputFileType 视频格式
/// @param presetName 视频导出质量
/// @param completeBlock 完成后的回调
+ (void)dw_videoSizeChangeRenderAndExportVideo:(NSString *)videoPath
                                     videoSize:(CGSize)videoSize
                                   withOutPath:(NSString *)outPath
                                outputFileType:(NSString *)outputFileType
                                    presetName:(NSString *)presetName
                                   didComplete:(void(^)(NSError *error,NSURL *compressionFileURL))completeBlock;

@end








