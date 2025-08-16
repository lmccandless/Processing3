/*
 * Copyright (C) 2017 Logan McCandless
 * MIT License: https://opensource.org/licenses/MIT
 */

#version 150 

precision mediump float;
precision mediump int;

out vec4 fragColor;

#define PROCESSING_TEXTURE_SHADER

uniform sampler2D texture;
uniform sampler2D tex_obstacles;
uniform vec2 texOffset;
uniform mat4 texMatrix;

varying vec4 vertColor;
varying vec4 vertTexCoord;

uniform vec2 mouse;
uniform vec2 resolution;
uniform sampler2D ppixels;

vec4 white  = vec4(1.0, 1.0, 1.0, 1.0);

void main( void ) {
  vec2 position = ( gl_FragCoord.xy / resolution.xy );
  if (texture2D(tex_obstacles, position).r <1.0) {
    if (length(position-mouse) < 0.002) {
      fragColor = white;
    } 
    else {
      // cardinals 1px away
      vec2 tc5 = vertTexCoord.st + vec2( 0.0, texOffset.t);
      vec2 tc6 = vertTexCoord.st + vec2( 0.0, -texOffset.t);
      vec2 tc7 = vertTexCoord.st + vec2(+texOffset.s, 0.0);
      vec2 tc8 = vertTexCoord.st + vec2(-texOffset.s, 0.0);
      // Get step distances/blue , reduce diagnals by sqrt(2)
      float b5 = texture2D(tex_obstacles, tc5).r;
      float b6 = texture2D(tex_obstacles, tc6).r;
      float b7 = texture2D(tex_obstacles, tc7).r;
      float b8 = texture2D(tex_obstacles, tc8).r;
      if (b5 < 1.0) b5= texture2D(ppixels, tc5).r + texture2D(ppixels, tc5).g + texture2D(ppixels, tc5).b;  else b5 = -1.0; 
      if (b6 < 1.0) b6= texture2D(ppixels, tc6).r + texture2D(ppixels, tc6).g + texture2D(ppixels, tc6).b;  else b6 = -1.0; 
      if (b7 < 1.0) b7= texture2D(ppixels, tc7).r + texture2D(ppixels, tc7).g + texture2D(ppixels, tc7).b;  else b7 = -1.0; 
      if (b8 < 1.0) b8= texture2D(ppixels, tc8).r + texture2D(ppixels, tc8).g + texture2D(ppixels, tc8).b;  else b8 = -1.0; 
      // Find the highest neighbor value
      b5 = max(b5, b6);
      b7 = max(b7, b8);
      b5 = max(b5, b7); 
      float b1 = b5 - 0.006;
      // Brightness encode
      float bk =  (b1*85);
      bk = bk - floor(bk);
      float r1 = 0, r2 = 0;
      if (bk >0.33333) r1 = 0.00390625;
      if (bk >0.66666) r2 = 0.00390625;
      float b5r = float(b1)/3.0;
      fragColor = vec4(b5r, b5r+r2, b5r+r1, 1.);
    }
  }
}
