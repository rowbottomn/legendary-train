public abstract class AbstObstacle {

  Player player;//enemies or players
  PVector pos;
  PVector siz;
  PImage img;
  color col;

  public void update(Player p) {
    player = p;
    PVector tSiz = new PVector(p.siz.x*p.hitBoxScaling,p.siz.x*p.hitBoxScaling);
    if (HelperMethods.touching(p.pos,tSiz, pos, siz)) {
      block();
    }
  }

  public void draw() {
    if (img == null) {
      fill(255, 0, 0);
      noStroke();
      rect(pos.x, pos.y, siz.x, siz.y, 0);
    } else {
      image(img, pos.x, pos.y, siz.x, siz.y);
    }
  }
  public abstract void block();
}