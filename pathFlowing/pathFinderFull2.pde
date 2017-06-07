/*
 * Copyright (C) 2017 Logan McCandless
 * MIT License: https://opensource.org/licenses/MIT
 */
 
import java.text.NumberFormat;
import java.math.RoundingMode;

NumberFormat renderTimeFormat = NumberFormat.getInstance();

PShader pathFlow;
PGraphics pgPathMap;
PGraphics pgCollisionMap; 


color background = color(1, 1, 1, 255);
color wallColor = color(255, 0, 0, 255);

boolean traceType = false;
boolean rateLock = false;

float gpuPasses = 8;
float fpsAverage = 0;
long renderTime = 0;

void setup() {
  size(800, 600, P2D);
  frameRate(1000);
  println("Toggle between CPU/GPU engine with (q) key.");
  println("-/+ gpu shader passes with (1/2) keys."); 
  println("Toggle frame rate lock with (a) key.");

  renderTimeFormat.setMaximumFractionDigits(3);
  renderTimeFormat.setMinimumFractionDigits(0);
  renderTimeFormat.setRoundingMode(RoundingMode.HALF_UP); 

  pgPathMap = createGraphics(800, 600, P3D);
  pgPathMap.noSmooth();
  pgCollisionMap  = createGraphics(800, 600, P2D);
  pgCollisionMap.noSmooth();
  genCollisionMap();
  genPathers();
  pathFlow = loadShader("pathFlow.glsl");
  pathFlow.set("resolution", float(pgPathMap.width), float(pgPathMap.height));
  pathFlow.set("tex_obstacles", pgCollisionMap);
  
}

void draw() {
  frameLockHack();
  updateCollisionMap();
  
  renderTime = System.nanoTime();
  
  if (traceType) cpuPathTrace();
  else gpuPathTrace(); 
  
  setTitle();
  liveKeyCheck();
 }

void liveKeyCheck() { // check key every frame, change slower if high fps
  if (keyPressed) {
    if ((key == '1') && (gpuPasses >2))  gpuPasses-=10/frameRate; 
    if (key == '2')  gpuPasses+=10/frameRate; 
    if (key == 'r') saveFrame();
    println("gpu, passes: "+ int(gpuPasses));
  }
}

void keyPressed() { // checks only new key presses
  if (key == 'q') traceType = !traceType;
  if (key == 'a') rateLock = !rateLock;
  if(key=='`') {
    println("debugin");
  }
  frameRate(rateLock? 60:1000);
  println  (traceType?"cpu":"gpu, passes: "+ gpuPasses);
}

void setTitle() {
  fpsAverage = (fpsAverage *15 + frameRate)/16;
  renderTime = System.nanoTime() -renderTime;
  Float formatedFloat = new Float(renderTimeFormat.format(renderTime/1000000.0));
  String Sfps = Integer.toString(int(fpsAverage));
  Sfps = padRight(Sfps, 8-Sfps.length());
  surface.setTitle( "FPS: " + Sfps  + "  |  " + (traceType?"CPU":" GPU,  passes: "+ int(gpuPasses)  + ", ") + " Render time: " + formatedFloat + " ms");
}

boolean started = false;
void frameLockHack() {
  // If frameRate(60) is used during setup, it cannot be increased during runtime, it must be set high then reduced. 
  if (started==false) {
    if (millis() > 2000) {
      started = true;
      frameRate(60);
    }
  }
}

public static String padRight(String s, int n) {
  return String.format("%1$-" + n + "s", s);
}