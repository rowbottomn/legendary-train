public class Bumper extends Platform {

  public float dir;
 

  public Bumper(PVector p, PVector s, float d) {
    super(p);
    siz.set(s);
    dir = d/180.*PI;
    duration = 500;
  }

  public void block() {
    if (duration > 50){
      float dispX = pos.x - player.pos.x;
      float dispY = pos.y - player.pos.y;
      float xCorr = (player.siz.x*player.hitBoxScaling+siz.x)/2.;
      float yCorr = (player.siz.y*player.hitBoxScaling+siz.y)/2.;   
  
      if (dir == -PI){
        player.vel.x *= 0.97;
        player.vel.y *= 0.5;
       // player.pos.y += -0.2*cos(dir)*(dispY - yCorr);
        player.vel.y -= G.y;
      }
      else if ((abs(dispX) <= xCorr) ) {
        //player.vel.y = 0;
        player.vel.x *= 0.97;
        // player.pos.x -= (dispX - xCorr)/20.;
        player.vel.y += -0.5*cos(dir)*(dispY - yCorr);
        player.vel.x -= 30*sin(dir);
      }
      if (dir != -PI|| pos.y>height*siz.y){
        duration -=10;
      }
    }
  
  }

  void draw() {
    if (dir == -PI/2) {
      col = color(10, 145, 10);
    } else if (dir == PI/2) {
      col = color(145, 10, 10);
    } else if (dir == 0) {
      col = color(10, 145, 145);
    } else if (dir == PI) {
      col = color(190, 100, 0);
    } else if (dir == -PI) {
      col = color(145, 145, 255);
    }

    fill(col, duration);
    pushMatrix();
    translate(pos.x, pos.y);
    noStroke();
    rect(0, 0, siz.x, siz.y);
    if (dir != -PI) {
      float timeScale = 60.;
      float tempX = siz.x*0.5;
      float tempY = siz.y*0.5;
      PVector left = new PVector();
      PVector right = new PVector();
      float slide1 = (frameCount%timeScale);
      rotate(dir);
      left.x = (-slide1*tempX/timeScale);
      left.y = ( - tempY+slide1*siz.y/timeScale) ;
      right.x = ( slide1*tempX/timeScale);
      //main square;

      fill(247, 246, 242, 100);//+ 50*(cos(20*dir*frameCount/timeScale/PI)));
      quad(- tempX, left.y, left.x, tempY, 
        right.x, + tempY, tempX, left.y );
     // if (left.y > 0) {
        triangle(left.x, -tempY, right.x, -tempY, 0,left.y);//leftpoint, right point, midpoint
     // }
    }
      popMatrix();
  }
}
