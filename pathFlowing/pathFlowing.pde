/*
 * Copyright (C) 2017 Logan McCandless
 * MIT License: https://opensource.org/licenses/MIT
 */

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

  pgPathMap = createGraphics(800, 600, P2D);
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
  
  noStroke(); fill(0,255,0);
  ellipse(mouseX,mouseY,10,10);
  
  liveKeyCheck();
 }

void liveKeyCheck() { // check key every frame, change slower if high fps
  if (keyPressed) {
    if ((key == '1') && (gpuPasses >2))  gpuPasses-=10/frameRate; 
    if (key == '2')  gpuPasses+=10/frameRate; 
    //if (key == 'r') saveFrame();
    println("gpu, passes: "+ int(gpuPasses));
  }
}

void keyPressed() { // checks only new key presses
  if (key == 'q') traceType = !traceType;
  if (key == 'a') rateLock = !rateLock;
  frameRate(rateLock? 60:1000);
  println  (traceType?"cpu":"gpu, passes: "+ gpuPasses);
}

void setTitle() {
  fpsAverage = (fpsAverage *15 + frameRate)/16;
  renderTime = System.nanoTime() -renderTime;
  String sRenderTime = (Float.toString(renderTime/1000000.0)).substring(0,4);
  String sFPS = Integer.toString(int(fpsAverage));
  surface.setTitle( "FPS: " + sFPS  + "  |  "
    + (traceType ? "CPU" :
    " GPU,  passes: " + int(gpuPasses)  + ", ") 
    + " Render time: " + sRenderTime + " ms");
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