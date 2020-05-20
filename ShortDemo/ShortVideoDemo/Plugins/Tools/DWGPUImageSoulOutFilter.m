//
//  DWGPUSoulOutFilter.m
//  ShortVideoDemo
//
//  Created by zwl on 2020/4/1.
//  Copyright © 2020 Myself. All rights reserved.
//

#import "DWGPUImageSoulOutFilter.h"

NSString *const kGPUImageSoulOutShaderString = SHADER_STRING
(
 precision highp float;

 varying vec2 textureCoordinate;

 uniform sampler2D inputImageTexture;

 uniform float time;

 void main (void) {
     float duration = 0.7;
     float maxAlpha = 0.4;
     float maxScale = 1.8;
     
     float progress = mod(time, duration) / duration; // 0~1
     float alpha = maxAlpha * (1.0 - progress);
     float scale = 1.0 + (maxScale - 1.0) * progress;
     
     float weakX = 0.5 + (textureCoordinate.x - 0.5) / scale;
     float weakY = 0.5 + (textureCoordinate.y - 0.5) / scale;
     vec2 weakTextureCoords = vec2(weakX, weakY);
     
     vec4 weakMask = texture2D(inputImageTexture, weakTextureCoords);
     
     vec4 mask = texture2D(inputImageTexture, textureCoordinate);
     
     gl_FragColor = mask * (1.0 - alpha) + weakMask * alpha;
 }

);

@implementation DWGPUImageSoulOutFilter

- (id)initWithFragmentShaderFromString:(NSString *)fragmentShaderString
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageSoulOutShaderString])) {
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
