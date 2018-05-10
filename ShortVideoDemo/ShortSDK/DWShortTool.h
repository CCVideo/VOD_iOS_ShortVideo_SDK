//
//  DWShortUtil.h
//  ShortVideoDemo
//
//  Created by luyang on 2017/8/2.
//  Copyright © 2017年 Myself. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

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

@end








