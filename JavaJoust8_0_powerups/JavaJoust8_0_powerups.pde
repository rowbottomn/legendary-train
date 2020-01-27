//TO DO
//




import processing.sound.*;

import net.java.games.input.*;
import org.gamecontrolplus.*;
import org.gamecontrolplus.gui.*;
import java.util.ArrayList;

ControlIO control;
Configuration config;
ArrayList <ControlDevice> gpads;  

final static float g = 0.2;
final static PVector G = new PVector(0, g);
final static PVector bumperSize = new PVector(50, 50);

ArrayList <Player> players;
ArrayList <Platform> platforms;
ArrayList <Bumper> bumpers;
ArrayList <Object> drawable;
PowerUp powerUp;

PImage spriteSheet;
PImage[][] imgs;
PImage [] icons;

SoundFile[] flaps; 
public Player player;
public AIFloater floater;
public int numPlayers = 4;
public int numGamePads; 
int numBumpers = 40;
int numBumperSpotsX; 
int numBumperSpotsY; 
int numNonAdjustableBumpers = 0;
boolean decisionMade;
int[] scores;
int maxScore = 30;
boolean gameOver = false;
int winner;
int sideBuffer = 150;
float leftSide;
float rightSide;

public color[] colors = new color[]{    
  color(0, 255, 0, 150), 
  color(215, 215, 0, 200), 
  color(255, 50, 50, 150), 
  color(120, 150, 255, 120), 
  color(180, 180, 180, 150)
}; 

void setup() {
  size (1600, 950);
  smooth();
  frameRate(60);
  rectMode(CENTER);
  imageMode(CENTER);
  // textMode(CENTER);
  textSize(30);
  //  createGUI();
  initialize();
}

void initialize() {
  // Initialise the ControlIO
  control = ControlIO.getInstance(this);
  // println(gpad.matches(config));
  scores = new int[]{0, 0, 0, 0};
  imgs = new PImage[4][4];
  icons = new PImage[4];
  flaps = new SoundFile[7];
  players = new ArrayList <Player>();
  gpads = new ArrayList<ControlDevice>();
  // floater = new AIFloater(players, imgs[(players.size())%4]);
  platforms = new ArrayList <Platform>();
  bumpers = new ArrayList <Bumper>();
  drawable = new ArrayList <Object>();
  numBumperSpotsY= (int)(height/bumperSize.y/3-1);
  numBumperSpotsX = (int)((width-sideBuffer)/bumperSize.x/2);
  decisionMade = false;
  // setPlatforms();
  //get the number of local gamepads connected
  numGamePads = 4;//control.getDevices().size();
  // create players with devices that match the configuration file

  //  setPlatforms();
  setBumpers();
  setImages();
  setSounds();

  for (int i = 0; i < numGamePads; i ++) { 
    gpads.add(control.getMatchedDevice("p"+(i+1)+"_gamepad_config"));
    players.add( new Player(players, gpads.get(i), imgs[(players.size())%4], flaps));
    // gpad = control.getDevices().get(control.getDevices().size()-1);
  }

  for (int i = numGamePads; i < numPlayers; i++) {
    players.add( new Player(players, imgs[(players.size())%4], flaps));
    
  }
}

void reset() {
  players = new ArrayList <Player>();
  for (int i = 0; i < 4; i++) {//numGamePads; i ++) { 
    players.add( new Player(players, gpads.get(i), imgs[(players.size())%4], flaps));
  }
  for (int i = 0; i < bumpers.size(); i++){
     Bumper p = bumpers.get(i);
     if (p.temp){
       bumpers.remove(p);
       drawable.remove(p);
       i --;
     }
     else{
       p.duration = 500;
     }
  }
  rightSide = width - sideBuffer+10;
  leftSide = -10;//get walls out of the way until the final show down
}

void gameReset() {
  scores = new int[numPlayers];
  drawable = new ArrayList <Object>();
  bumpers = new ArrayList <Bumper>();
  decisionMade = true;
  gameOver = false;
  reset();
  setBumpers();
}

void setSounds() {
  for (int i = 0; i < flaps.length; i++) {
    flaps[i] = new SoundFile(this, "flap"+(i+1)+".wav");
  }
}
void setImages() {
  icons[0] = loadImage("plus.png");
  icons[1] = loadImage("minus.png");
  icons[2] = loadImage("rot_left.png");
  icons[3] = loadImage("rot_right.png");
  spriteSheet = loadImage("flappybirds.png");
  for (int p = 0; p < imgs.length; p++) {//player
    for (int f = 0; f < imgs.length; f++) {//frame
      imgs[p][f] = spriteSheet.get(f*spriteSheet.width/4, p*spriteSheet.height/4, spriteSheet.width/4, spriteSheet.height/4);
    }
  }
}

void setPlatforms() {
  platforms.add(new Platform(new PVector(200, 200)));
  platforms.add(new Platform(new PVector(600, 200)));
  platforms.add(new Platform(new PVector(400, 600)));
  platforms.add(new Platform(new PVector(100, 750)));
  platforms.add(new Platform(new PVector(300, 750)));
  platforms.add(new Platform(new PVector(500, 750)));
  platforms.add(new Platform(new PVector(700, 750)));
}

void removeBumpers() {
  for (int i = 0; i < 5; i++) {
    if (bumpers.size()>numNonAdjustableBumpers) {
      drawable.remove(bumpers.get(bumpers.size()-1));
      bumpers.remove(bumpers.size()-1);
    }
  }
}

void rotateBumpers(int rotationDir) {
  for (int i = numNonAdjustableBumpers; i < bumpers.size(); i ++) {
    int tempDir = (int)(bumpers.get(i).dir/PI*180);
    tempDir += rotationDir * 90;
    if (tempDir > 180) {
      tempDir = -90;
    } else if (tempDir < -90) {
      tempDir = 180;
    }
    bumpers.get(i).dir = tempDir * PI/180;
  }
}

void makeWinner() {
  //for testing, make a winner
  while (players.size()>1) {
    drawable.remove(players.get(1));
    players.remove(1);
  }
  decisionMade = false;
}

void addBumpers() {
  for (int i = 0; i < 5; i++) {
    boolean alreadyBlockPresent = true;
    PVector temp = new PVector();
    while (alreadyBlockPresent) {
      alreadyBlockPresent = false;
      //get a random PVector
      temp = new PVector((int)random(-1*numBumperSpotsX, numBumperSpotsX)*bumperSize.x+(width-sideBuffer)/2, 
        (int)random(-1*numBumperSpotsY+1, numBumperSpotsY+2)*bumperSize.y+height/3);
      //check this vector agains the rest of the list
      for (int j = numNonAdjustableBumpers; j < bumpers.size()-1; j++) {
        if (bumpers.get(j).pos.x == temp.x && bumpers.get(j).pos.y == temp.y) {
          alreadyBlockPresent = true;
        }
      }
    }
    bumpers.add(new Bumper(temp, bumperSize, floor(random(-1, 3))*90));
  }
}

void addBumpers(Player p) {
  for (int i = -1; i < 2; i++) {
    bumpers.add(new Bumper(
      new PVector((int)(p.pos.x +player.siz.x), (int)(p.pos.x + i*bumperSize.y)), 
      bumperSize, floor(random(-1, 3))*90));
  }
}


void setBumpers() {
  //along the leftside and rightside
  /*  for (int i = 0; i < 15; i += 1){
   bumpers.add(new Bumper(new PVector(0, i*bumperSize.y+0.5*bumperSize.y),
   new PVector(bumperSize.x, bumperSize.y), -90 ));
   bumpers.add(new Bumper(new PVector(width, i*bumperSize.y+0.5*bumperSize.y),
   new PVector(bumperSize.x, bumperSize.y), 90 ));   
   }*/
  //the bumpers along the top and bottom
  numNonAdjustableBumpers = 0;//22
  for (int i = -1; i < (width-sideBuffer+1) /bumperSize.x; i += 1) {
    bumpers.add(new Bumper(new PVector(i*50+0.5*bumperSize.x, 0), 
      new PVector(bumperSize.x, bumperSize.y), 0 ));
    bumpers.add(new Bumper(new PVector(i*bumperSize.x+0.5*bumperSize.x, height), 
      new PVector(bumperSize.x, bumperSize.y), -180 ));//floor
    numNonAdjustableBumpers+=2;
  }

  for (int i = 0; i < numBumpers; i ++) {
    boolean alreadyBlockPresent = true;
    PVector temp = new PVector();
    while (alreadyBlockPresent) {
      alreadyBlockPresent = false;
      //get a random PVector
      temp = new PVector((int)random(-1*numBumperSpotsX, numBumperSpotsX)*bumperSize.x+(width-sideBuffer)/2, 
        (int)random(-1*numBumperSpotsY+1, numBumperSpotsY+1)*bumperSize.y+height/3);
      //check this vector agains the rest of the list
      for (int j = numNonAdjustableBumpers; j < bumpers.size()-1; j++) {
        if (bumpers.get(j).pos.x == temp.x && bumpers.get(j).pos.y == temp.y) {
          alreadyBlockPresent = true;
        }
      }
    }
    bumpers.add(new Bumper(temp, bumperSize, floor(random(-1, 3))*90));
  }
  //
  /*  for (int i = 0; i < 1; i ++) {
   bumpers.add(new Bumper(new PVector((int)random(-2,3)*600+i*bumperSize.x+0.5*bumperSize.x, 200), bumperSize, 180));
   bumpers.add(new Bumper(new PVector((int)random(-2,3)*400+i*bumperSize.x+0.5*bumperSize.x, 200-bumperSize.y), bumperSize, -90));
   bumpers.add(new Bumper(new PVector((int)random(-2,3)*600+i*bumperSize.x+0.5*bumperSize.x, 400), bumperSize, 180));
   bumpers.add(new Bumper(new PVector((int)random(-2,3)*600+i*bumperSize.x+0.5*bumperSize.x, 400-bumperSize.y), bumperSize, -90));
   bumpers.add(new Bumper(new PVector((int)random(-2,3)*200+i*bumperSize.x+0.5*bumperSize.x, 400-bumperSize.y), bumperSize, -90));
   
   }
   
   for (int i = 0; i < 1; i ++) {
   bumpers.add(new Bumper(new PVector((int)random(-2,3)*700+i*bumperSize.x+0.5*bumperSize.x, 500), bumperSize, -90));
   bumpers.add(new Bumper(new PVector((int)random(-2,3)*200+i*bumperSize.x+0.5*bumperSize.x, 500+bumperSize.y), bumperSize, 180));
   }
   
   for (int i = 0; i < 1; i ++) {
   bumpers.add(new Bumper(new PVector((int)random(-2,3)*600+i*bumperSize.x+0.5*bumperSize.x, 500), bumperSize, 90));
   bumpers.add(new Bumper(new PVector((int)random(-2,3)*600+i*bumperSize.x+0.5*bumperSize.x, 500+bumperSize.y), bumperSize, 0));
   }
   
   
   // bumpers.add(new Bumper(new PVector(600, 200), bumperSize, 90));
   // bumpers.add(new Bumper(new PVector(400, 600), bumperSize, -90));
   //  bumpers.add(new Bumper(new PVector(100, 750), bumperSize, 180));
   //  bumpers.add(new Bumper(new PVector(300, 750), bumperSize, 0.1));
  /*
   bumpers.add(new Bumper(new PVector(500, 750)));
   bumpers.add(new Bumper(new PVector(700, 750)));*/
}

void mousePressed() {
  //players.add(new Player(players, imgs[(players.size())%4]));
}


void keyPressed() {
}

void keyReleased() {
  /*if (key == '`') {
    makeWinner();
  }*/
}

void draw() {
  background(255);
  if (!gameOver) {
    for (Player p : players) {
      p.update(); 
      for (Platform pf : platforms) {
          pf.update(p);
        
      }
      for (Bumper b : bumpers) {
        b.update(p);
      }
    }

    for (int i = 0; i < drawable.size(); i++) {
      Object o = drawable.get(i);
      if (o instanceof Player) {
        Player temp = (Player)o;
        if (temp.dead) {
          // print("removing"+temp.ID);
          players.remove(temp);
          drawable.remove(temp);
          continue;
        }
        temp.draw();
      } else if (o instanceof Platform) {
        Platform temp = (Platform)o;
        if (temp.duration > 50){
          temp.draw();
        }
      } else if (o instanceof Bumper) {
        Bumper temp = (Bumper)o;
        temp.draw();
        

      }
    }

    if (players.size() == 1 ) {
      //wait until we get a decision   
      decisionMade = false;
      Player tp = players.get(0);
      textSize(50);
      text("7", 240, 200);
      text("8", 440, 200);
      text("5", 640, 200);
      text("6", 840, 200);

      for (int op = 0; op < icons.length; op++) {

        tint(tp.col);
        fill(255);
        float imgPos = (op+0.8)*width/5;
        rect(imgPos, 300, 102, 102, 10);

        fill(tp.col);
        rect(imgPos, 300, 100, 100, 10);

        image(icons[op], imgPos, 300, 100, 100);
        tint(255);
      }
      
      ControlDevice tempPad = tp.getGPad();
      
      if (tempPad.getButton(7).pressed()){
      //if (keyPressed) {
       // if (key == 'u') {
          addBumpers();
          decisionMade = true;
        } else if (tempPad.getButton(8).pressed()){
        //else if (key == 'i') {
          removeBumpers();
          decisionMade = true;
        } else if (tempPad.getButton(5).pressed()){
        //else if (key == 'o') {
          rotateBumpers(-1);
          decisionMade = true;
        } else if (tempPad.getButton(6).pressed()){
        //else if (key == 'p') {
          rotateBumpers(1);
          decisionMade = true;
        }
      
      if (decisionMade) {
        drawable.remove(tp);
        players.remove(tp);
        reset();
      }
    }
    else if (players.size() == 2){
        int frameVal = 90;
        if (leftSide % frameVal == 0){
           for (int i = 0; i < height; i+= bumperSize.y){     
                   bumpers.add(new Bumper(new PVector(leftSide/frameVal*bumperSize.x, i), bumperSize, -90, true));
                   bumpers.add(new Bumper(new PVector(width - sideBuffer - leftSide/frameVal*bumperSize.x, i), bumperSize, 90, true));
           }
        
        }
          textSize(100);
          fill(255,0,0);
          text(""+round(10 - leftSide/frameVal), (width-sideBuffer)/2, height/2);   
          // print (leftSide);
        leftSide ++;
        if (10 - leftSide/frameVal < 1){
           drawable.remove(players.get(1));
           players.remove(1);
           drawable.remove(players.get(0));
           players.remove(0);
           reset();
        }
       /* rightSide --;
        for ( int i = 0; i
        
        for (Player p : players){
          //if hitting the right side
          if (p.pos.x > rightSide ){
            p.pos.x = rightSide;
            p.vel.x *= -1.01;
          }
          else if (p.pos.x < leftSide){
            p.pos.x = leftSide;
            p.vel.x *= -1.01;
            p.pos.x += p.vel.x;//needed to clear the wall
          }
          
          //draw the walls
          fill(255,0,0,150);
          rectMode(CORNER);
          rect(0,0, leftSide, height);
          rect(width - rightSide - sideBuffer,0, width-sideBuffer, height);
          rectMode(CENTER);
          print(rightSide);
        }*/
    }

    //drawTheScores
    fill(0);
    rect(width - sideBuffer/5, height/2, sideBuffer, height);
    for (int i = 0; i < scores.length; i++) {
      fill(0, 140);
      textSize(30);
      text("P"+(i+1)+" "+scores[i], width - sideBuffer*0.6-1, (i+1)*100+1);
      fill(colors[i+1]);
      text("P"+(i+1)+" "+scores[i], width - sideBuffer*0.6, (i+1)*100);
      if (scores[i] >= maxScore) {
        gameOver = true;
        winner = i;
      }
    }
  } else if (gameOver) {
        textSize(70);
        textAlign(CENTER, CENTER);
        fill(colors[winner+1]);
        image(imgs[winner][0], (width)/2, height/2, 300, 300);
        text("Player "+ winner + "is the WINNER!", (width)/2 ,200);
        text("Press start to continue", (width)/2 ,550);
        for (ControlDevice pad : gpads){
          if (pad.getButton(10).pressed()){
            gameReset();
          }
        }
        textAlign(LEFT, TOP);

  }
}
