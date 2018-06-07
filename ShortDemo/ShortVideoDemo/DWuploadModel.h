//
//  DWuploadModel.h
//  ShortVideoDemo
//
//  Created by luyang on 2017/7/31.
//  Copyright © 2017年 Myself. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger, DWUploadStatus) {
    
    DWUploadStatusWait = 0,
    DWUploadStatusLoadLocalFileInvalid,
    DWUploadStatusStart,
    DWUploadStatusUploading,
    DWUploadStatusPause,
    DWUploadStatusResume,
    DWUploadStatusFail,
    DWUploadStatusFinish
};



@interface DWuploadModel : NSObject

@property (nonatomic,copy)NSString *videoPath;

@property (nonatomic,copy)NSString *videoLocalPath;//本地路径

@property (nonatomic,copy)NSString *videoTitle;

@property (nonatomic,copy)NSString *videoDescripton;

@property (copy, nonatomic)NSString *videoTag;

@property (assign, nonatomic)CGFloat videoFileSize;
@property (assign, nonatomic)NSInteger videoUploadedSize;

@property (assign, nonatomic)float videoUploadProgress;

@property (assign, nonatomic)DWUploadStatus videoUploadStatus;

@property (copy, nonatomic)NSDictionary *uploadContext;


//@property (strong, nonatomic)DWUploader *uploader;



@end
