//
//  DWGPUImageShakeFilter.h
//  ShortVideoDemo
//
//  Created by zwl on 2020/3/4.
//  Copyright © 2020 Myself. All rights reserved.
//

#if __has_include(<GPUImage/GPUImageFramework.h>)
#import <GPUImage/GPUImageFramework.h>
#else
#import "GPUImage.h"
#endif

///抖动
@interface DWGPUImageShakeFilter : GPUImageFilter{
    GLint timeUniform;
}

@property (nonatomic, assign) CGFloat time;

@end

