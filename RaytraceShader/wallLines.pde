/*
 * Copyright (C) 2016 Logan McCandless
 * MIT License: https://opensource.org/licenses/MIT
 */
 
void genWallMap() {
  for (int i = 0; i < 50; i++) {
    walls.add(new WallLine());
  }
}

void updateWallMap() {
  for (WallLine wall : walls) wall.update();
  drawWallMap();
}

void drawWallMap() {
  pgWallMap.beginDraw();
  pgWallMap.stroke(wallColor);
  pgWallMap.fill(wallColor);
  pgWallMap.strokeWeight(4);
  pgWallMap.background(background);
  pgWallMap.beginShape(LINES);
  for (WallLine wall : walls) {
    pgWallMap.strokeWeight(wall.weight);
    pgWallMap.line(wall.loc.x, wall.loc.y, wall.loc.x - wall.loc2.x, wall.loc.y-wall.loc2.y);
  }
  pgWallMap.endShape();
  pgWallMap.line(100, 100, 250, 100);
  pgWallMap.line(100, 100, 100, 250);
  pgWallMap.endDraw();
}

class WallLine {
  PVector loc = new PVector(0, 0);
  PVector loc2 = new PVector(0, 0);
  int wallLength = 100;
  float weight = 2;
  WallLine() {
    loc = new PVector(random(width), random(height));
    loc2 = new PVector(random(2)-1, random(2)-1);
    loc2.setMag(wallLength);
    weight = random(20)+ 5;
  }

  void update() {
    loc.add(loc2.copy().mult(0.23/frameRate));
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