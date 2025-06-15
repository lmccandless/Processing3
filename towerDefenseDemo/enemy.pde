class Enemy {
  PVector loc;
  PVector vel = new PVector();
  float speed = 2.0;
  int hp = 3;
  final int radius = 4;
  final int s = radius + 2;
  final int w = width, h = height, totPxls = w*h - w, ws = w*s;

  Enemy(PVector start) {
    loc = start.copy();
  }

  void update() {
    move();
    fill(0, 0, 255);
    noStroke();
    ellipse(loc.x, loc.y, radius * 2, radius * 2);
  }

  boolean reachedGoal() {
    return loc.dist(baseLocation) < 10;
  }

  void damage(int amt) {
    hp -= amt;
  }

  boolean dead() {
    return hp <= 0;
  }

  void move() {
    vel.lerp(getDirection(loc), 0.1);
    loc.add(vel.copy().mult(speed));
    loc.x = constrain(loc.x, 1, width - 2);
    loc.y = constrain(loc.y, 1, height - 2);
  }

  PVector getDirection(PVector ploc) {
    if (ploc.y < 0) return new PVector(0, 1);
    PVector tv = ploc.copy();
    int tx = constrain(ceil(tv.x), 0, w - 2);
    int ty = constrain(round(tv.y) - 1, 0, h - 1);
    return getDirection(tx + ty * w);
  }

  PVector getDirection(int ijq) {
    PVector dir = new PVector();
    int ind = min(ijq + s, totPxls);
    dir.x += brightnessDecode(pgPathMap.pixels[ind]);
    ind = max(ijq - s, 0);
    dir.x -= brightnessDecode(pgPathMap.pixels[ind]);
    ind = min(ijq + ws, totPxls);
    dir.y += brightnessDecode(pgPathMap.pixels[ind]);
    ind = max(ijq - ws, 0);
    dir.y -= brightnessDecode(pgPathMap.pixels[ind]);
    dir.normalize();
    return dir;
  }
}

int brightnessDecode(color c) {
  return int(red(c) + blue(c) + green(c));
}
