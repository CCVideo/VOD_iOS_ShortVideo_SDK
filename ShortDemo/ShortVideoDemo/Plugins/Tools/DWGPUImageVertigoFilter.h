//
//  DWGPImageVertigoFilter.h
//  ShortVideoDemo
//
//  Created by zwl on 2020/4/1.
//  Copyright © 2020 Myself. All rights reserved.
//

#if __has_include(<GPUImage/GPUImageFramework.h>)
#import <GPUImage/GPUImageFramework.h>
#else
#import "GPUImage.h"
#endif

//毛刺
@interface DWGPUImageVertigoFilter : GPUImageFilter{
    GLint timeUniform;
}

@property (nonatomic, assign) CGFloat time;

@end
