class Tracer{
  ArrayList <PVector> pos;
  PVector siz;
  Player player;
  color col;
  int num = 15;
  
  public Tracer(Player p){
     player = p;
     pos = new ArrayList<PVector>();
     siz = p.siz;
  }
  
  public void update(){
    pos.add(new PVector(player.pos.x,player.pos.y));
    if(pos.size()>num){
      pos.remove(0);
    }
    for (int i = 0; i < pos.size()-1; i++){
      if (player.siz.y == player.siz.x || !player.dead){
        fill(player.col, 30*(1-i/pos.size()));
        ellipse(pos.get(i).x,pos.get(i).y,siz.y*pow(0.95, float(pos.size()-i))-20,siz.y*pow(0.95, float(pos.size()-i))-20);
      }
    }
  }
}
