//
//  DWGPUImageFlashFilter.h
//  ShortVideoDemo
//
//  Created by zwl on 2020/3/6.
//  Copyright © 2020 Myself. All rights reserved.
//

#if __has_include(<GPUImage/GPUImageFramework.h>)
#import <GPUImage/GPUImageFramework.h>
#else
#import "GPUImage.h"
#endif

///闪屏
@interface DWGPUImageFlashFilter : GPUImageFilter{
    GLint timeUniform;
}

@property (nonatomic, assign) CGFloat time;

@end
