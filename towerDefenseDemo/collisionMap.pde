ArrayList<WallRect> walls = new ArrayList<WallRect>();
ArrayList<Tower> towers = new ArrayList<Tower>();
ArrayList<Enemy> enemies = new ArrayList<Enemy>();

void genObstacles() {
  walls.add(new WallRect(width/2 - 50, height/2 - 100, 100, 200));
  walls.add(new WallRect(width/4, height/3, 80, 80));
  walls.add(new WallRect(3*width/4, 2*height/3, 80, 80));
}

void updateCollisionMap() {
  pgCollisionMap.beginDraw();
  pgCollisionMap.background(1);
  pgCollisionMap.fill(255, 0, 0);
  pgCollisionMap.noStroke();
  for (WallRect w : walls) w.draw(pgCollisionMap);
  for (Tower t : towers) t.drawToMap(pgCollisionMap);
  pgCollisionMap.endDraw();
}

class WallRect {
  float x, y, w, h;
  WallRect(float x, float y, float w, float h) {
    this.x = x; this.y = y; this.w = w; this.h = h;
  }
  void draw(PGraphics pg) {
    pg.rect(x, y, w, h);
  }
  boolean contains(float px, float py) {
    return px >= x && px <= x+w && py >= y && py <= y+h;
  }
}

boolean canPlaceTower(float x, float y) {
  if (dist(x, y, baseLocation.x, baseLocation.y) < 30) return false;
  for (WallRect w : walls) if (w.contains(x, y)) return false;
  for (Tower t : towers) if (t.loc.dist(new PVector(x, y)) < 20) return false;
  return true;
}
