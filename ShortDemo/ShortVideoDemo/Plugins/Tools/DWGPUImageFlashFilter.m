//
//  DWGPUImageFlashFilter.m
//  ShortVideoDemo
//
//  Created by zwl on 2020/3/6.
//  Copyright © 2020 Myself. All rights reserved.
//

#import "DWGPUImageFlashFilter.h"

NSString *const kGPUImageFlashShaderString = SHADER_STRING
(
 precision highp float;

 varying vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;

 uniform float time;

 void main (void) {
     
    if (time == 0.0) {
        
        vec4 mask = texture2D(inputImageTexture, textureCoordinate);
        gl_FragColor = mask;
        
    }else {
        
        float loopDuration = 1.5;
        
        float interval = 0.5;
        
        float t = mod(time, loopDuration);
        
        vec4 maskColor;
        
        if (t <= interval) {
            maskColor = vec4(1.0, 0.0 ,0.0 ,0.0);
        }else if (t > interval && t <= interval * 2.0) {
            maskColor = vec4(0.0, 1.0 ,0.0 ,0.5);
        }else {
            maskColor = vec4(0.0, 0.0 ,1.0 ,1.0);
        }
        
        vec4 mask = texture2D(inputImageTexture, textureCoordinate);
        
        gl_FragColor = maskColor * 0.4 + mask;
        
    }
 }

 );

@implementation DWGPUImageFlashFilter

- (id)initWithFragmentShaderFromString:(NSString *)fragmentShaderString
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageFlashShaderString])) {
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
