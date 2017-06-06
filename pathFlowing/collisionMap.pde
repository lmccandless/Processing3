/*
 * Copyright (C) 2017 Logan McCandless
 * MIT License: https://opensource.org/licenses/MIT
 */

ArrayList<WallLine> walls = new ArrayList<WallLine>();
int numWalls = 50;

void genCollisionMap() {
  for (int i = 0; i < numWalls; i++) {
    walls.add(new WallLine());
  }
}

void updateCollisionMap() {
  for (WallLine wall : walls) wall.update();
  drawCollisionMap();
}

void drawCollisionMap() {
  pgCollisionMap.beginDraw();
  pgCollisionMap.stroke(wallColor);
  pgCollisionMap.fill(wallColor);
  pgCollisionMap.strokeWeight(4);
  pgCollisionMap.background(background);
  for (WallLine wall : walls) { // using beginShape(LINES) is broken, strokeWeight is glitched
    pgCollisionMap.strokeWeight(wall.weight);
    pgCollisionMap.line(wall.loc.x, wall.loc.y, wall.loc.x - wall.loc2.x, wall.loc.y-wall.loc2.y);
  }
  pgCollisionMap.line(100, 100, 250, 100);
  pgCollisionMap.line(100, 100, 100, 250);
  
  drawPathers(); // kinda messy, this both moves and draws pathfollwers 

  pgCollisionMap.endDraw();
}

class WallLine {
  PVector loc = new PVector(0, 0);
  PVector loc2 = new PVector(0, 0);
  int wallLength = 200;
  float weight = 2;
  WallLine() {
    loc = new PVector(random(width), random(height));
    loc2 = new PVector(random(2)-1, random(2)-1);
    loc2.setMag(wallLength);
    weight = random(20)+ 2;
  }
  void update() {
    loc.add(loc2.copy().mult(0.13/frameRate));
    PVector TailLoc = loc.copy().sub(loc2.copy());
    if (((loc.x <0)||(loc.x>width))
      && ((TailLoc.x < 0) || (TailLoc.x>width))) {
      loc = TailLoc.copy();
      loc2.x *=-1;
    }
    if (((loc.y <0)||(loc.y>height))
      && ((TailLoc.y < 0) || (TailLoc.y>height))) {
      loc = TailLoc.copy();
      loc2.y *=-1;
    }
  }
}