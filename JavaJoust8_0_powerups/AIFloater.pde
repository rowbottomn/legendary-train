public class AIFloater extends Player{
  float aggression;
  float fear;
  float speed;
  float flapSpeed;
  float xLimit;
  float yLimit;
  PVector atPlayer;
  PVector atClosestAI;
  
  public AIFloater(ArrayList<Player> p, PImage[] i) {
    super( p,  i); 
  }
  
  
  public void checkKeys(){
   //placeHolder 
   if ((pos.y > (int )(0.25*width)) &&(pos.y < (int )(0.75*width))){
        vel.y -= flapSpeed;
        flap.flap();
   }
  }
  
  public void update(){
   super.update();
  }
}
