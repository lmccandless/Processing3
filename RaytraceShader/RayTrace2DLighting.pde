/*
 * Copyright (C) 2016 Logan McCandless
 * MIT License: https://opensource.org/licenses/MIT
 */

import java.text.NumberFormat;
import java.math.RoundingMode;

NumberFormat renderTimeFormat = NumberFormat.getInstance();

PShader raytrace;
PShader blur;

PGraphics pgPathMap;
PGraphics pgWallMap; 
ArrayList<WallLine> walls = new ArrayList<WallLine>();

color background = color(1, 1, 1, 255);
color wallColor = color(255, 0, 0, 255);

boolean rateLock = true;

float blurPasses = 1;
float fpsAverage = 0;
long renderTime = 0;

int size = 800;
float scale = 0.8;
int scaledSize = int(size*scale);

void settings() {
  size(size, size, P3D);
}

void setup() {
  frameRate(1000);

  println("-/+  blur shader passes with (1/2) keys."); 
  println("-/+ raytrace shader resolution with (3/4) keys.");
  println("Toggle 60fps frame rate lock with (a) key.");

  renderTimeFormat.setMaximumFractionDigits(3);
  renderTimeFormat.setMinimumFractionDigits(0);
  renderTimeFormat.setRoundingMode(RoundingMode.HALF_UP); 

  changeScale(scale);
  pgWallMap  = createGraphics(size, size, P2D);
  pgWallMap.noSmooth();
  genWallMap();

  raytrace = loadShader("raytrace.glsl");
  blur = loadShader("blur.glsl");
}

void draw() {
  frameLockHack();
  updateWallMap();
  fpsAverage = (fpsAverage *15 + frameRate)/16;
  renderTime = System.nanoTime();
  gpuPathTrace();
  keyCheck();
  setTitle();
}

void setTitle() {
  renderTime = System.nanoTime() -renderTime;
  Float formatedFloat = new Float(renderTimeFormat.format(renderTime/1000000.0));
  String Sfps = Integer.toString(int(fpsAverage));
  Sfps = String.format("%1$-" + int(8- Sfps.length()) + "s", Sfps);
  Float formatedScale =new Float(renderTimeFormat.format(scale));
  surface.setTitle("FPS: " + Sfps + " scale: " + formatedScale + "  |  blur  passes: "+ int(blurPasses)  + ", Render time: " + formatedFloat + " ms" );
}

void keyCheck() { // Checks every frame
  if (keyPressed) {
    if ((key == '1') && (blurPasses >1))  blurPasses-=10/frameRate; 
    if (key == '2')  blurPasses+=10/frameRate; 
    println("blur passes: "+ int(blurPasses));
  }
}

void keyPressed() { // Checks only new keypresses
  if (key == 'a') rateLock = !rateLock;
  if (key == '3') changeScale(scale-0.05);
  if (key == '4') changeScale(scale+0.05);
  frameRate(rateLock? 60:1000);
}

boolean started = false;
void frameLockHack() {
  if (started==false) {
    if (millis() > 2000) {
      started = true;
      frameRate(60);
    }
  }
}

void changeScale(float s) {
  scale = constrain(s, 0.1, 2);
  scaledSize = int(size*scale);
  pgPathMap = createGraphics(scaledSize, scaledSize, P2D);
  pgPathMap.noSmooth();
}