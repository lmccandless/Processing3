/*
 * Copyright (C) 2016 Logan McCandless
 * MIT License: https://opensource.org/licenses/MIT
 */

#define PROCESSING_TEXTURE_SHADER

uniform sampler2D texture;
uniform vec2 texOffset;
uniform int numLights;
uniform float lights2[24]; // 8 lights, 3 floats per light, x/y/brightnesss
uniform float reso;
varying vec4 vertTexCoord;

void main () {
  if ((texture2D (texture, vertTexCoord.xy).r < 1.0)) { 
    float col = 0.0;
    int li = numLights-1;
    float stepReduce = texOffset.x ;
    while (li-- >= 0.){
      vec2 loc = vec2(lights2[li*3],  lights2[li*3 +1]);
      vec2 distVec = (loc - vertTexCoord.xy);
      vec2 dir = normalize(distVec) * -texOffset;
      float totDist  =length(distVec);
      float step = (totDist);
      while (step > 0.0) {
        step -= stepReduce;
        if (texture2D(texture, loc+=dir).r > 0.9) step = -5.0;
      };
      if (step > -5.0) {
         float val = clamp(1.0 - pow(totDist,lights2[li*3+2]),0.0,0.9);
         col = max(col,val)+ min(col,val)/8.0;
        //float val = *max(min(1.0 - pow(totDist*2.,2.5-lights2[li*3+2]),1.0),0.0)
      }
    };
    gl_FragColor.xyz = vec3(min (1.0, pow(col,3.0)));
    gl_FragColor.w = 1.0;
  }
}

