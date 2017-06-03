/*
 * Copyright (C) 2016 Logan McCandless
 * MIT License: https://opensource.org/licenses/MIT
 */
 
void setupLights(){
  float x = map(mouseX, 0, width, 0, 1), y = map(mouseY, 0, height, 1, 0);
  // format is X,Y, intensity
  float[] lights = 
   { x,         y,   0.9, 
    .200,    .200,  0.15, 
    .2100,  .8100,   0.4, 
    .87100, .0100,   0.2, 
    .800,   .7100,  0.32 };

  raytrace.set("numLights", int(lights.length/3));
  raytrace.set("lights2", lights);
}

void gpuPathTrace() {
  setupLights();

  image(pgWallMap, 0, 0);
  
  pgPathMap.beginDraw();
  pgPathMap.image(pgWallMap, 0, 0, scaledSize, scaledSize);
  pgPathMap.filter(raytrace);
  pgPathMap.endDraw();
  
  for (int i = 0; i <int(blurPasses); i++) {
    pgPathMap.beginDraw();
    pgPathMap.filter(blur);
    pgPathMap.endDraw();
  }
  
  blendMode(NORMAL);
  image(pgPathMap, 0, 0, width, height);
  blendMode(ADD);
  image(pgWallMap, 0, 0);
  blendMode(NORMAL);
}