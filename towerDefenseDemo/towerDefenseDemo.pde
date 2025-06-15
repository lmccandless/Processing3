PShader pathFlow;
PGraphics pgPathMap;
PGraphics pgCollisionMap;
PVector baseLocation;

float gpuPasses = 8;
int selectedTurret = 0;
String[] turretNames = {"Basic", "Slow", "Rapid"};
int nextWave = 0;
int enemiesPerWave = 5;

void setup() {
  size(800, 600, P2D);
  frameRate(60);
  pgPathMap = createGraphics(width, height, P2D);
  pgPathMap.noSmooth();
  pgCollisionMap = createGraphics(width, height, P2D);
  pgCollisionMap.noSmooth();
  pathFlow = loadShader("pathFlow.glsl");
  pathFlow.set("resolution", float(pgPathMap.width), float(pgPathMap.height));
  pathFlow.set("tex_obstacles", pgCollisionMap);
  baseLocation = new PVector(width - 40, height/2);
  genObstacles();
  spawnWave();
}

void draw() {
  updateCollisionMap();
  gpuPathTrace();

  pgPathMap.loadPixels();
  for (Tower t : towers) t.update();
  for (int i = enemies.size()-1; i>=0; i--) {
    Enemy e = enemies.get(i);
    e.update();
    if (e.dead()) enemies.remove(i);
    else if (e.reachedGoal()) enemies.remove(i);
  }

  if (frameCount > nextWave) {
    spawnWave();
    nextWave = frameCount + 600;
  }

  fill(0,255,0);
  noStroke();
  ellipse(baseLocation.x, baseLocation.y, 20, 20);

  drawUI();
}

void gpuPathTrace() {
  pathFlow.set("mouse", map(baseLocation.x, 0, width, 0, 1), map(baseLocation.y, 0, height, 1, 0));
  int i = int(gpuPasses);
  while (i-- > 0) {
    pgPathMap.beginDraw();
    pgPathMap.image(pgCollisionMap, 0, 0);
    pgPathMap.filter(pathFlow);
    pgPathMap.endDraw();
  }
  image(pgPathMap, 0, 0, width, height);
}

void spawnWave() {
  for (int i = 0; i < enemiesPerWave; i++) {
    enemies.add(new Enemy(new PVector(40, 50 + i*20)));
  }
}

void drawUI() {
  fill(0);
  rect(0, height-30, width, 30);
  fill(255);
  text("Turret: " + turretNames[selectedTurret] + " (1-3 to select) | Click to place", 10, height-10);
}

void mousePressed() {
  if (mouseY < height-30 && canPlaceTower(mouseX, mouseY)) {
    towers.add(new Tower(mouseX, mouseY, selectedTurret));
  }
}

void keyPressed() {
  if (key == '1') selectedTurret = 0;
  if (key == '2') selectedTurret = 1;
  if (key == '3') selectedTurret = 2;
}
