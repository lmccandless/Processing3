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

  float [] wallSend = new float[200]; 
  float [] thickSend = new float[50];
  float [] eSend = new float[4000];

  int i = 0, j = 0;
  for (WallLine wall : walls) {
    wallSend[i]=wall.loc.x;
    wallSend[i+1]=wall.loc.y;
    wallSend[i+2]=(wall.loc.x - wall.loc2.x);
    wallSend[i+3]=(wall.loc.y - wall.loc2.y);
    thickSend[j] = wall.weight/2;
    i+=4; 
    j++;
  }

  int w = 0;
  for (int q = 0; q < 4000; q+=2) {
    eSend[q] = pathers[w].loc.x;
    eSend[q+1] = height - pathers[w].loc.y;
    w++;
  }

  drawShapes.set("lines", wallSend, 4);
  drawShapes.set("thick", thickSend);
  drawShapes.set("enemies", eSend, 2);
  pgCollisionMap.filter(drawShapes);

  pgCollisionMap.endDraw();

  drawPathers(); 
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
  float [] getSend() {
    return new float [] { loc.x, loc.y, loc.x - loc2.x, loc.y - loc2.y };
  }
}