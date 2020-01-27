import java.util.ArrayList;

public class Player extends AbstPlayer {
  ControlDevice gpad;
  float maxSpeed = 5.5;
  float flapSpeed = 7;
  int flapTime = 250;
  int disabledTime = 5000;
  float hitBoxScaling = 0.6;
  Tracer tracer;
  int spawnTimer = 0;
  int spawnDuration = 120;
  SoundFile [] flaps;

  public Player(ArrayList<Player>p) {
    players = p;
    pos = new PVector(mouseX, mouseY);
    powerUps = new ArrayList <PowerUp>();
    //pos = new PVector(random(width), random(height/2));
    vel = PVector.random2D();
    disabled = false;
    dead = false;
    flap = new FlapTimer(flapTime);
    disTimer = new FlapTimer(disabledTime);
    col = color (random(255), random(255), random(255));
    //lives = 4;
    ID = players.size()+1;
    drawable.add(this);
    frame = 0;
    spawnTimer = 0;
  }

  public Player(ArrayList<Player> p, ControlDevice g) {
    players = p;
    gpad = g;

    //pos = new PVector(mouseX, mouseY);
    pos = new PVector((players.size()+1)*150+50, height - 75);
    vel = PVector.random2D();
    powerUps = new ArrayList <PowerUp>();
    flap = new FlapTimer(flapTime);
    disTimer = new FlapTimer(disabledTime);
    col = color (random(255), random(255), random(255));
    //lives = 4;
    ID = players.size()+1;
    drawable.add(this);
    disabled = false;
    dead = false;
    frame = 0;
    spawnTimer = 0;
  }

  public Player(ArrayList<Player> p, PImage[] i) {
    players = p;

    imgs = i;
    powerUps = new ArrayList <PowerUp>();
    //pos = new PVector(mouseX, mouseY);
    pos = new PVector((players.size()+1)*150+50, height - 75);    
    vel = PVector.random2D();

    flap = new FlapTimer(flapTime);
    disTimer = new FlapTimer(disabledTime);
    col = color (random(255), random(255), random(255));
    //lives = 4;
    ID = players.size()+1;
    drawable.add(this);
    disabled = false;
    dead = false;
    frame = 0;
    spawnTimer = 0;
  }

  public Player(Player p) {
  }

  public Player(ArrayList<Player> p, ControlDevice g, PImage[] i, SoundFile[] f) {
    players = p;
    flaps = f;
    gpad = g;
    imgs = i;
    //pos = new PVector(mouseX, mouseY);
    pos = new PVector((players.size()+1)*(width-200)/5, height - 75);
    vel = PVector.random2D();
    powerUps = new ArrayList <PowerUp>();
    flap = new FlapTimer(flapTime);
    disTimer = new FlapTimer(disabledTime);
    //lives = 4;
    ID = players.size()+1;
    col = colors[ID];
    drawable.add(this);
    disabled = false;
    frame = 0;
    dead = false;
    spawnTimer = 0;
  }

  public Player(ArrayList<Player> p, PImage[] i, SoundFile[] f) {
    players = p;
    flaps = f;

    imgs = i;
    //pos = new PVector(mouseX, mouseY);
    pos = new PVector(players.indexOf(this)*150+50, height - 75);
    vel = PVector.random2D();
    powerUps = new ArrayList <PowerUp>();
    flap = new FlapTimer(flapTime);
    disTimer = new FlapTimer(disabledTime);
    //lives = 4;
    ID = players.size()+1;
    drawable.add(this);
    disabled = false;
    dead = false;
    frame = 0;
    spawnTimer = 0;
  }
  
  public void checkKeys() {

    if (gpad == null) {
      if (keyPressed && (keyCode == LEFT|| key == 'a')) {
        vel.x --;
        //velX --;
      } else if (keyPressed && (keyCode == RIGHT|| key == 'd')) {
        vel.x ++;
        //velX ++
      } 
      if (keyPressed && (keyCode == UP || key == 'w')&& flap.canFlap&&disTimer.canFlap) {
        vel.y -= flapSpeed;
        //velY ;d
        if (disTimer.canFlap) {
          vel.x +=  2. * vel.x;
          flap.flap();
         // flaps[(int)random(0, 3)].play();
        }
      }
    } else {

      if ((gpad.getButton("Flap_1").pressed() || gpad.getButton("Flap_2").pressed()||
        gpad.getButton("Flap_3").pressed() || gpad.getButton("Flap_4").pressed())
        &&flap.canFlap) {
        if (disTimer.canFlap) {
          vel.y -= flapSpeed;
          vel.x +=  2. * gpad.getSlider("X_controls").getValue();
          flap.flap();
          int temp = (int)random(0, 3);
          flaps[(int)random(0, 3)].play();
         // print("flaprandom"+temp);
        } else {
          disTimer.startTime -= 50;
        }
      }

      vel.x +=  1.3 * gpad.getSlider("X_controls").getValue();
    }
    //vel.x *= 0.95;//handled in the platform class
  }

  public ControlDevice getGPad(){
     return gpad; 
  }

  public void checkLimits() {
    //speed limits
    if (vel.x < -maxSpeed) {
      vel.x = - maxSpeed;
    } else if (vel.x > maxSpeed) {
      vel.x  = maxSpeed;

    } 
    if (vel.y < -3*maxSpeed) {
      vel.y = -3* maxSpeed;
    } else if (vel.y > 3*maxSpeed) {
      vel.y  = 3*maxSpeed;
    }
    //position limits
    //top of screen
    if (pos.y< siz.y/2) {
      pos.y = siz.y/2;
    }
    if (pos.x > (width - sideBuffer)+siz.x) {
      pos.x = -siz.x/2;
    }
    if (pos.x < -siz.x) {
      pos.x = (width - sideBuffer)+siz.x/2;
    }

    //left right boundary conditions
  }

  public void update() {

    if (!dead) {
      if (tracer == null){
         tracer = new Tracer(this); 
       }
      else {
        tracer.update();
      }
      flap.tick();
      disTimer.tick();
      siz.y = 0.2*maxHeight*(1.+(4*(float)disTimer.timer/(float)disabledTime));
      checkKeys();
      checkFrames();
      vel.add(G);
      checkLimits();
      if (!disTimer.canFlap) {
        vel.mult(0.75);
      }    
      pos.add(vel);
      if (spawnTimer < spawnDuration){
         spawnTimer ++; 
      }
      else{
        checkCollision();
      }
    }
  }

  public void checkFrames()
  {    
    if (!flap.canFlap) {
      frame = (int)((int)flap.timer / 75);
    } else {
      frame = 0;
    }
  }

  public void bounceY(Player p) {
    //PVector pointAway = new PVector (pos.x - p.pos.x,pos.y - p.pos.y);
    vel.y+= 0.5;
    vel.add(p.vel);
    vel.y*=-1.05;

    vel.x*=1.05;
  }

  public void bounceX(Player p) {
    //PVector pointAway = new PVector (pos.x - p.pos.x,pos.y - p.pos.y);
    //vel.y*=-1.1;

    vel.x*=-1.05;
    vel.x +=p.vel.x;
    vel.mult(0.5);
  }

  public void checkCollision() {
    for (int i = 0; i < players.size(); i ++) {
      Player p = players.get(i); 
      if (p != this && !p.dead) {
        PVector tSiz = new PVector(siz.x*hitBoxScaling, siz.y*hitBoxScaling);
        PVector ptSiz = new PVector(p.siz.x*hitBoxScaling, p.siz.y*hitBoxScaling);
        if (HelperMethods.touching(pos, tSiz, p.pos, ptSiz)) {
          if (!disTimer.canFlap) {
            dead = true;
            scores[p.ID-1]++;
            flaps[6].play();
            //print("Flap6");
            p.bounceY(this);
          } else if (!p.disTimer.canFlap) {
            p.dead = true;
            scores[ID-1]++;
            flaps[4].play();
           // print("Flap4");
            bounceY(this);
          } else {
            float diff = pos.y - p.pos.y;
            if (diff < -siz.y/3. ) {
              //p.disabled = true;
              p.disTimer.flap();
              flaps[5].play();
              //print("Flap5");
              bounceY(p);
              p.bounceY(this);
            } else if (diff > siz.y/3. ) {
              int temp = (int)random(4, 6); 
              flaps[temp].play();
              //print("Flaprandom"+temp);
              //disabled = true;
              disTimer.flap();
              p.bounceY(this);
              bounceY(p);
            } else {
              bounceX(p);
            }
          }
        }
      }
    }
  }



  public void draw() {
    if (imgs == null) {
      fill (col);
      ellipse(pos.x, pos.y, siz.x, siz.y);
    } else {
      PImage img = imgs[frame];
      // textSize(30);
      // text ((int)(vel.heading()/PI*180),100,100);

      pushMatrix();
      translate(pos.x, pos.y);

      rotate(vel.heading());
      if (cos(vel.heading())< 0) {
        scale(1, -1);
      }
      image(img, 0., 0., siz.x, siz.y);
      // rect(0,0,siz.x*0.6,siz.y*0.6);
      // ellipse(0,0,siz.x*0.7,siz.y*0.7);
      popMatrix();
      fill (col, map(spawnTimer, 0, spawnDuration, 255, 0 ));
      ellipse(pos.x, pos.y, siz.x, siz.y);
    }
  }
}
