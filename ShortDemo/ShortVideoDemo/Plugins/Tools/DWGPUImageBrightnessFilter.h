#if __has_include(<GPUImage/GPUImageFramework.h>)
#import <GPUImage/GPUImageFramework.h>
#else
#import "GPUImage.h"
#endif

@interface DWGPUImageBrightnessFilter : GPUImageFilter {
}

@property (nonatomic, assign) CGFloat beautyLevel;
@property (nonatomic, assign) CGFloat toneLevel;
@end
