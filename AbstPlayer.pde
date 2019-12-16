public abstract class AbstPlayer{
 ArrayList <Player> players; 
 ArrayList <PowerUp> powerUps;
 FlapTimer flap; 
 FlapTimer disTimer;
 PVector pos;
 PVector vel;
 PVector siz = new PVector(60., 60.); 
 float maxHeight = siz.y;
 color col;
 PImage[] imgs;
 int ID;
 int score;
 public boolean disabled;
 boolean dead;
 int frame;
  
  public abstract void update();
  public abstract void draw();
  protected abstract void checkKeys();  
  protected abstract void checkLimits();
  protected abstract void checkCollision();
}
