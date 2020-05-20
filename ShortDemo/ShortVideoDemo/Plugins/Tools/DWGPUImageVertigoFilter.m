//
//  DWGPImageVertigoFilter.m
//  ShortVideoDemo
//
//  Created by zwl on 2020/4/1.
//  Copyright © 2020 Myself. All rights reserved.
//

#import "DWGPUImageVertigoFilter.h"

NSString *const kGPUImageVertigoString = SHADER_STRING
(
 precision highp float;

 varying vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;

 uniform float time;

 const float PI = 3.1415926;
 const float duration = 2.0;

 vec4 getMask(float pTime, vec2 textureCoords, float padding) {
     vec2 translation = vec2(sin(pTime * (PI * 2.0 / duration)),
                             cos(pTime * (PI * 2.0 / duration)));
     vec2 translationTextureCoords = textureCoords + padding * translation;
     vec4 mask = texture2D(inputImageTexture, translationTextureCoords);
     
     return mask;
 }

 float maskAlphaProgress(float currentTime, float hideTime, float startTime) {
     float rTime = mod(duration + currentTime - startTime, duration);
     return min(rTime, hideTime);
 }

 void main (void) {
    
    if (time == 0.0) {

        vec4 mask = texture2D(inputImageTexture, textureCoordinate);
        gl_FragColor = mask;
        
    }else {
    
     float currentTime = mod(time, duration);
     
     float scale = 1.2;
     float padding = 0.5 * (1.0 - 1.0 / scale);
     vec2 textureCoords = vec2(0.5, 0.5) + (textureCoordinate - vec2(0.5, 0.5)) / scale;
     
     float hideTime = 0.9;
     float timeGap = 0.2;
     
     float maxAlphaR = 0.5; // max R
     float maxAlphaG = 0.05; // max G
     float maxAlphaB = 0.05; // max B
     
     vec4 mask = getMask(time, textureCoords, padding);
     float alphaR = 1.0; // R
     float alphaG = 1.0; // G
     float alphaB = 1.0; // B
     
     vec4 resultMask = vec4(0, 0, 0, 0);
     
     for (float f = 0.0; f < duration; f += timeGap) {
         float tmpTime = f;
         vec4 tmpMask = getMask(tmpTime, textureCoords, padding);
         float tmpAlphaR = maxAlphaR - maxAlphaR * maskAlphaProgress(currentTime, hideTime, tmpTime) / hideTime;
         float tmpAlphaG = maxAlphaG - maxAlphaG * maskAlphaProgress(currentTime, hideTime, tmpTime) / hideTime;
         float tmpAlphaB = maxAlphaB - maxAlphaB * maskAlphaProgress(currentTime, hideTime, tmpTime) / hideTime;
      
         resultMask += vec4(tmpMask.r * tmpAlphaR,
                            tmpMask.g * tmpAlphaG,
                            tmpMask.b * tmpAlphaB,
                            1.0);
         alphaR -= tmpAlphaR;
         alphaG -= tmpAlphaG;
         alphaB -= tmpAlphaB;
     }
     resultMask += vec4(mask.r * alphaR, mask.g * alphaG, mask.b * alphaB, 1.0);

     gl_FragColor = resultMask;
    }
 }

);

@implementation DWGPUImageVertigoFilter

- (id)initWithFragmentShaderFromString:(NSString *)fragmentShaderString
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageVertigoString])) {
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
