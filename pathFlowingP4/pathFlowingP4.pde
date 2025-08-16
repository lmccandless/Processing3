/*
 * Condensed pathFlowing example for Processing 4
 * Derived from Logan McCandless (MIT License)
 */

PShader flow;
PShader blur;
PGraphics pathMap, collisionMap;
ArrayList<Wall> walls = new ArrayList<Wall>();
PathFollower[] agents;

final color BG = color(1,1,1,255);
final color WALL = color(255,0,0,255);

boolean useCPU = false;
boolean lockRate = false;
float passes = 8;
float blurPasses = 1;
float fpsAvg = 0;
long renderTime = 0;

void setup() {
  size(800, 600, P2D);
  frameRate(1000);
  pathMap = createGraphics(width, height, P2D);
  //pathMap.noSmooth();
  collisionMap = createGraphics(width, height, P2D);
  //collisionMap.noSmooth();

  flow = loadShader("pathFlow.glsl");
  flow.set("resolution", float(width), float(height));
  flow.set("tex_obstacles", collisionMap);
  blur = loadShader("blur.glsl");

  for (int i = 0; i < 50; i++) walls.add(new Wall());
  agents = new PathFollower[2000];
  for (int i = 0; i < agents.length; i++) agents[i] = new PathFollower();
}

void draw() {
  frameLock();
  updateCollision();
  renderTime = System.nanoTime();
  if (useCPU) cpuTrace();
  else gpuTrace();
  drawTitle();
  noStroke();
  fill(0, 255, 0);
  ellipse(mouseX, mouseY, 10, 10);
  liveKeys();
}

void gpuTrace() {
  flow.set("mouse", map(mouseX, 0, width, 0, 1), map(mouseY, 0, height, 1, 0));
  for (int i = 0; i < int(passes); i++) {
    pathMap.beginDraw();
    pathMap.filter(flow);
    pathMap.filter(blur);
    pathMap.endDraw();
  }
  for (int i = 0; i < int(blurPasses); i++) {
    pathMap.beginDraw();
    pathMap.filter(blur);
    pathMap.endDraw();
  }
  image(pathMap, 0, 0, width, height);
  image(collisionMap, 0, 0);
}

void cpuTrace() {
  final int[] card = {1, -1, width, -width};
  final int total = width * height - 1;
  final int start = constrain(mouseX + mouseY * width, 0, total);
  IntList cur = new IntList();
  IntList next = new IntList();
  int step = 255 * 3;
  cur.append(start);
  pathMap.beginDraw();
  pathMap.image(collisionMap, 0, 0);
  pathMap.loadPixels();
  while (cur.size() > 0) {
    step--;
    for (int idx : cur) {
      idx = constrain(idx, width, total - width);
      if (pathMap.pixels[idx] == BG) {
        pathMap.pixels[idx] = encode(step);
        for (int j = 0; j < 4; j++) {
          int k = idx + card[j];
          if (pathMap.pixels[k] == BG) next.append(k);
        }
      }
    }
    cur = next;
    next = new IntList();
  }
  pathMap.endDraw();
  pathMap.updatePixels();
  for (int i = 0; i < int(blurPasses); i++) {
    pathMap.beginDraw();
    pathMap.filter(blur);
    pathMap.endDraw();
  }
  background(0);
  image(pathMap, 0, 0, width, height);
  image(collisionMap, 0, 0);
}

color encode(int v) {
  int b = v / 3;
  return color(b, b + ((v % 3 > 1) ? 1 : 0), b + ((v % 3 > 0) ? 1 : 0), 255);
}

int decode(color c) {
  return int(red(c) + green(c) + blue(c));
}

void updateCollision() {
  for (Wall w : walls) w.update();
  collisionMap.beginDraw();
  collisionMap.stroke(WALL);
  collisionMap.fill(WALL);
  collisionMap.strokeWeight(4);
  collisionMap.background(BG);
  for (Wall w : walls) {
    collisionMap.strokeWeight(w.weight);
    collisionMap.line(w.loc.x, w.loc.y, w.loc.x - w.dir.x, w.loc.y - w.dir.y);
  }
  collisionMap.line(100, 100, 250, 100);
  collisionMap.line(100, 100, 100, 250);
  drawAgents();
  collisionMap.endDraw();
}

void drawAgents() {
  pathMap.loadPixels();
  collisionMap.noStroke();
  collisionMap.fill(255, 0, 0);
  for (PathFollower p : agents) p.update();
}

class PathFollower {
  final float speed = 2.7, authority = 0.10;
  final int r = 4;
  final int step = r + 1;
  final int ws = width * step;
  final int total = width * height - width;
  PVector loc = new PVector(random(width), random(height));
  PVector vel = new PVector();

  void update() {
    move();
    collisionMap.ellipse(loc.x, loc.y, r, r);
  }

  void move() {
    vel.lerp(getDir(loc), authority);
    loc.add(vel.copy().mult(speed));
    if (distSq(loc.x, loc.y, mouseX, mouseY) < 100) loc.set(random(width), random(height));
    if (loc.x <= 0) loc.x += width;
    if (loc.x >= width - 1) loc.x -= width;
  }

  PVector getDir(PVector p) {
    if (p.y < 0) return new PVector(0, 1);
    int x = constrain(ceil(p.x), 0, width - 2);
    int y = constrain(round(p.y) - 1, 0, height - 1);
    return getDir(x + y * width);
  }

  PVector getDir(int idx) {
    PVector d = new PVector();
    int ind = min(idx + step, total);
    d.x += decode(pathMap.pixels[ind]);
    ind = max(idx - step, 0);
    d.x -= decode(pathMap.pixels[ind]);
    ind = min(idx + ws, total);
    d.y += decode(pathMap.pixels[ind]);
    ind = max(idx - ws, 0);
    d.y -= decode(pathMap.pixels[ind]);
    d.normalize();
    return d;
  }
}

class Wall {
  PVector loc = new PVector(random(width), random(height));
  PVector dir = PVector.random2D().setMag(200);
  float weight = random(2, 22);

  void update() {
    loc.add(dir.copy().mult(0.13 / frameRate));
    PVector tail = loc.copy().sub(dir);
    if ((loc.x < 0 || loc.x > width) && (tail.x < 0 || tail.x > width)) {
      loc = tail;
      dir.x *= -1;
    }
    if ((loc.y < 0 || loc.y > height) && (tail.y < 0 || tail.y > height)) {
      loc = tail;
      dir.y *= -1;
    }
  }
}

float distSq(float x1, float y1, float x2, float y2) {
  x1 -= x2;
  y1 -= y2;
  return x1 * x1 + y1 * y1;
}

void liveKeys() {
  if (keyPressed) {
    if (key == '1' && passes > 2) passes -= 10 / frameRate;
    if (key == '2') passes += 10 / frameRate;
    println("gpu, passes: " + int(passes));
  }
}

void keyPressed() {
  if (key == 'q') useCPU = !useCPU;
  if (key == 'a') lockRate = !lockRate;
  frameRate(lockRate ? 60 : 1000);
  println(useCPU ? "cpu" : "gpu, passes: " + passes);
}

void drawTitle() {
  fpsAvg = (fpsAvg * 15 + frameRate) / 16;
  renderTime = System.nanoTime() - renderTime;
  surface.setTitle("FPS: " + int(fpsAvg) + " | " + (useCPU ? "CPU" : "GPU, passes: " + int(passes)) +
    " Render time: " + nf(renderTime / 1000000.0, 0, 2) + " ms");
}

boolean started = false;
void frameLock() {
  if (!started && millis() > 2000) {
    started = true;
    frameRate(60);
  }
}

