public class PowerUp{
  
 Player owner; 
 ArrayList powerUps; 
 PVector pos;
 PVector siz;
 PImage img;
 
 int type; //1 is add, 2 is remove, 3 is rotate left, 4 is rotate right
 
 public PowerUp(int t){
    type = t;
    pos = new PVector(width - 100, 100);
 }

 public PowerUp(Player p, int t){
    owner = p;
    type = t;
    pos = new PVector(width - 100, owner.ID*100);
 }


}