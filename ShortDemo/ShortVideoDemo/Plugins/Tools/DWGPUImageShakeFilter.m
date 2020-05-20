//
//  DWGPUImageShakeFilter.m
//  ShortVideoDemo
//
//  Created by zwl on 2020/3/4.
//  Copyright © 2020 Myself. All rights reserved.
//

#import "DWGPUImageShakeFilter.h"

NSString *const kGPUImageShakeShaderString = SHADER_STRING
(
 precision highp float;

 varying vec2 textureCoordinate;

 uniform sampler2D inputImageTexture;

 uniform float time;

 void main (void) {
    
    float duration = 0.7;
    float maxScale = 1.1;
    float offset = 0.02;
    
    float progress = mod(time, duration) / duration; // 0~1
    vec2 offsetCoords = vec2(offset, offset) * progress;
    float scale = 1.0 + (maxScale - 1.0) * progress;
    
    vec2 ScaleTextureCoords = vec2(0.5, 0.5) + (textureCoordinate - vec2(0.5, 0.5)) / scale;
    
    vec4 maskR = texture2D(inputImageTexture, ScaleTextureCoords + offsetCoords);
    vec4 maskB = texture2D(inputImageTexture, ScaleTextureCoords - offsetCoords);
    vec4 mask = texture2D(inputImageTexture, ScaleTextureCoords);
    
    gl_FragColor = vec4(maskR.r, mask.g, maskB.b, mask.a);
}
);

@implementation DWGPUImageShakeFilter

- (id)initWithFragmentShaderFromString:(NSString *)fragmentShaderString
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageShakeShaderString])) {
        return nil;
    }
    
    timeUniform = [filterProgram uniformIndex:@"time"];
    self.time = 0.0;
    
    return self;
}

-(void)setTime:(CGFloat)time
{
    _time = time;
    
    [self setFloat:_time forUniform:timeUniform program:filterProgram];
}

@end
