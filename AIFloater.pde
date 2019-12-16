public class AIFloater extends Player{
  float aggression;
  float fear;
  

  FlapTimer attentionTimer;
  Player target;
  int diff = -1;
  float flapSpeed = 4+0.8*diff;
  float speed = 0.8+0.1*diff;
  int attention = 1000 - 250 * diff;
  PVector dir;
  
  public AIFloater(ArrayList<Player> p, PImage[] i, SoundFile[] f) {
    super( p,  i, f); 
    attentionTimer = new FlapTimer(attention);
    dir  = new PVector();
    //diff = (int)(-1+ID/1.5);
  }
  
  void findTarget(){
    
    float closest = 100000;
    for (Player p : players){
       if (p == this){continue;}
       float dist = pos.dist(p.pos);
       if (dist < closest){
          target = p;
          closest = dist;
       }
    }

  }
  
  
  public void checkKeys(){
    attentionTimer.tick();
    aggression = 1;    
    if (target == null || !players.contains(target)||attentionTimer.canFlap){
       findTarget();
    }
    dir = PVector.sub(target.pos, pos);
    dir.normalize();
    stroke(target.col, 100);
    strokeWeight(8);
    
    if (flap.canFlap && frameCount % (5-diff) == 0) {
        if (disTimer.canFlap) {
          if (dir.y < 0.7 && pos.y > height*0.2 ){
            vel.y -= flapSpeed;
            vel.x +=  speed * 1.8 * dir.x;
            flap.flap();
            int temp = (int)random(0, 3);
            flaps[(int)random(0, 3)].play();
          }
          
        } else {
          disTimer.startTime -= 50;
          
        }
      }
     else if ((dir.y < -0.15&&!target.disTimer.canFlap)||spawnTimer< spawnDuration){
        aggression = -1; 
     }
     

      vel.x +=  speed * dir.x*aggression;
    
    
    line(target.pos.x, target.pos.y, pos.x, pos.y);

   noStroke();
  }
  
  public void update(){
   super.update();
  }
}
