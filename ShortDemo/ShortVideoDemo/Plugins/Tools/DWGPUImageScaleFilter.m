//
//  DWGPUImageScaleFilter.m
//  ShortVideoDemo
//
//  Created by zwl on 2020/4/1.
//  Copyright © 2020 Myself. All rights reserved.
//

#import "DWGPUImageScaleFilter.h"

NSString *const kGPUImageScaleVertexShaderString = SHADER_STRING
(
 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;
 
 varying vec2 textureCoordinate;
 
 uniform float time;
 
 const float PI = 3.1415926;
 
 void main (void) {
    float duration = 0.6;
    float maxAmplitude = 0.3;
    
    float currentTime = mod(time, duration);
    float amplitude = 1.0 + maxAmplitude * abs(sin(currentTime * (PI / duration)));
    
    gl_Position = vec4(position.x * amplitude, position.y * amplitude, position.zw);
    textureCoordinate = inputTextureCoordinate.xy;
}
 );

NSString *const kGPUImageScaleShaderString = SHADER_STRING
(
 precision highp float;
 
 varying vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
// uniform sampler2D Texture;
// varying vec2 TextureCoordsVarying;
 
 void main (void) {
    vec4 mask = texture2D(inputImageTexture, textureCoordinate);
    gl_FragColor = vec4(mask.rgb, 1.0);
}
 );

@implementation DWGPUImageScaleFilter

-(id)initWithVertexShaderFromString:(NSString *)vertexShaderString fragmentShaderFromString:(NSString *)fragmentShaderString
{
    if (!(self = [super initWithVertexShaderFromString:kGPUImageScaleVertexShaderString fragmentShaderFromString:kGPUImageScaleShaderString])) {
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
