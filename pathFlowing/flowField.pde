/*
 * Copyright (C) 2017 Logan McCandless
 * MIT License: https://opensource.org/licenses/MIT

     A GPU and CPU implemenation of my flow field algorithm. 
     
     This GPU implementation solves the problem iteravely, doing only a 
     little  bit of work with each shader pass. This CPU implementation 
     solves the entire flow field in one pass. 
     
     There are pros and cons to each implemenation, the GPU has a lag 
     in response time, but that can result in less predictable, more 
     organic pathing. CPU implemnation calculates 10-20 times slower than
     GPU, but it's full frame nature provides better avoidence of fast
     moving obstacles. 
     
     -the CPU implementation attempts to world-wrap across the X axis for 
      use in a game, is currently bugged at the corners
 */

void gpuPathTrace() {
  pathFlow.set("mouse", map(mouseX, 0, width, 0, 1), map(mouseY, 0, height, 1, 0)); 
  image(pgCollisionMap,0,0);
  for (int i = 0; i <int(gpuPasses); i++) {
    pgPathMap.beginDraw();
    pgPathMap.image(pgCollisionMap, 0, 0);
    pgPathMap.filter(pathFlow);
    pgPathMap.endDraw();
  }
  image(pgPathMap, 0, 0, width, height);
}

void cpuPathTrace() {
  final int[] cardinals  = { 1, -1, width, -width }; 
  final int totPxls = width*height - 1;
  final int mousePx = constrain(mouseX +mouseY*width, 0, totPxls);
  
  IntList curPxs = new IntList();
  IntList nextPxs = new IntList();
  int pathStep = 255*3;

  curPxs.append(mousePx);
  pgPathMap.beginDraw();
  pgPathMap.image(pgCollisionMap, 0, 0);
  pgPathMap.loadPixels();
 /*  preload targets into curPxs, which serve as starting points for the reverse path search
     while there are still neighbors to search,
        set currentPixel brightness to the current calculation step, the walking distance from target
        add it's available neighbors to be searched in the next step                         */
  while ((curPxs.size()>0)) {
    pathStep--;
    for (int ci : curPxs) {
      ci = constrain(ci, width, totPxls-width);
      if (pgPathMap.pixels[ci]==background) {
        int i3 = int( pathStep/3);
        //brightness encoding, 255*3 levels
        pgPathMap.pixels[ci] =  color(i3 ,   (i3 + ((pathStep%3>1)?1:0))  ,   (i3 + ((pathStep%3>0)?1:0)) ,255);
        // Add neighbors that have not been processed
        int j = 4;
        while (j-- > 0){
          int k = ci+cardinals[j];
          if (pgPathMap.pixels[k] == background) nextPxs.append(k); 
        }
      }
    }
    curPxs=nextPxs.copy();
    nextPxs.clear();
  }
  pgPathMap.endDraw();
  pgPathMap.updatePixels();
  background(0);
  image(pgPathMap, 0, 0, width, height);
}