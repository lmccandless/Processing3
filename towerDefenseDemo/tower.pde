class Tower {
  PVector loc;
  int type;
  float range;
  int maxCooldown;
  int cooldown = 0;

  Tower(float x, float y, int t) {
    loc = new PVector(x, y);
    type = t;
    if (t == 0) { // basic
      range = 70;
      maxCooldown = 30;
    } else if (t == 1) { // slow but strong
      range = 90;
      maxCooldown = 60;
    } else { // rapid fire
      range = 60;
      maxCooldown = 15;
    }
  }

  void update() {
    if (cooldown > 0) cooldown--;
    Enemy target = null;
    for (Enemy e : enemies) {
      if (!e.dead() && e.loc.dist(loc) < range) {
        target = e;
        break;
      }
    }
    if (target != null && cooldown == 0) {
      target.damage(1);
      cooldown = maxCooldown;
    }
  }

  void drawTower() {
    rectMode(CENTER);
    fill(100, 100, 0);
    if (type == 1) fill(0, 100, 100);
    if (type == 2) fill(100, 0, 100);
    rect(loc.x, loc.y, 16, 16);
  }

  void drawToMap(PGraphics pg) {
    pg.rectMode(CENTER);
    pg.rect(loc.x, loc.y, 16, 16);
  }
}
