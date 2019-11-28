public class Platform extends AbstObstacle {

   public float duration;
   
  public Platform(PVector p) {
    pos = p;
    siz = new PVector(300, 50);
    drawable.add(this);
  }

  public void block() {
    float dispX = pos.x - player.pos.x;
    float dispY = pos.y - player.pos.y;
    float xCorr = (player.siz.x+siz.x)/2.;
    float yCorr = (player.siz.y+siz.y)/2.;   
//if above and falling &&(player.pos.y <= yCorr)
    if ((abs(dispX) <= xCorr)&& (player.vel.y > 0) ) {
      player.vel.y = 0;
      player.vel.x *= 0.97;
     // player.pos.x -= (dispX - xCorr)/20.;
      player.pos.y += (dispY - yCorr);
      
      fill(0,0,255);
    }
//if below and rising
  // else if ((abs(dispX) >= xCorr)&& (player.vel.y < 0)&&(player.pos.y >= yCorr)) {
 //     player.vel.y = 0;
 //     player.pos.y += (dispY - yCorr);
//      fill(0,255,0);
//    }
//if left and moving right 
/*     if ((abs(dispY) <= yCorr)&& player.vel.x > 0) {
      player.vel.x = 0;
      player.pos.y += abs(xCorr - dispX);
    }   
    else if ((abs(dispY) >= yCorr)&& player.vel.x < 0) {
      player.vel.x = 0;
      player.pos.x += abs(xCorr - dispX);
    }
*/
  }
}
