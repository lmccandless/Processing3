/*
 * Copyright (C) 2017 Logan McCandless
 * MIT License: https://opensource.org/licenses/MIT
 */

/*
  CPU based flow field path followers 
     A simple implementation of a path follower using a 
     flow field path map. Works with flow fields rendered 
     on either the GPU or CPU. 
*/

PathFollower [] pathers;
int totalPathers = 2000;

void genPathers() {
  pathers = new PathFollower[totalPathers];
  for (int i = 0; i < totalPathers; i++) {
    pathers[i] = new PathFollower();
  }
}

void drawPathers() {
  pgPathMap.loadPixels();
  pgCollisionMap.noStroke();
  pgCollisionMap.fill(255, 0, 0);
  for (int i = 0; i < totalPathers; i++) {
    pathers[i].update();
  }
}

class PathFollower {
  float speed = 2.4, pathAuthority = 0.25;
  int radius = 4;
  int s = radius+2;
  
  PVector loc = new PVector(0, 0);
  PVector moving = new PVector(0, 0);
  PVector vel = new PVector(0, 0);
  int w = width, h = height;
  int totPxls = w*h - w;
  int ws = w*s;

  PathFollower() {
    loc = new PVector(random(w), random(h));
  }

  void update() {
    move();
    pgCollisionMap.ellipse(loc.x, loc.y, radius, radius);
  }

  void move() {
    vel.lerp(getDirection(loc), pathAuthority);
    loc.add(vel.copy().mult(speed));
    if (loc.copy().sub(new PVector(mouseX, mouseY)).magSq() < 100) {
      loc = new PVector(random(w), random(h));
      loc = loc.copy();
    }
    if (loc.x<=0) loc.x += w;
    if (loc.x>=w-1) loc.x -=w;
  }

  PVector getDirection(PVector ploc) { // converts PVec location to pixel location
    if (ploc.y<0) return new PVector(0, 1);
    PVector tv = ploc.copy();
    int tx = constrain(ceil(tv.x), 0, w-2), ty = constrain(round(tv.y)-1, 0, h-1);
    return getDirection(tx+ty*w);
  }

  PVector getDirection(int ijq) { // calculates path direction at pixel location
    // simple version, looks at 1 pixel from the cardinal directions and moves which way is brightest. 
    PVector dir = new PVector(0, 0);
    int ind = min(ijq+s, totPxls); 
    dir.x +=  blue(pgPathMap.pixels[ind]); 
    ind = max(ijq-s, 0);    
    dir.x -= blue(pgPathMap.pixels[ind]); 
    ind = min(ijq+ws, totPxls); 
    dir.y += blue(pgPathMap.pixels[ind]);  
    ind = max(ijq-ws, 0);    
    dir.y -= blue(pgPathMap.pixels[ind]);
    dir.normalize();
    return dir;
  }
}