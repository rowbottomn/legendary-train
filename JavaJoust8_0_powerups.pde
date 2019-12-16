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
public PVector bumperSize;

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
public int numPlayers = 8;
public int numGamePads = 6; 
int numBumpers = 30;
int numBumperSpotsX; 
int numBumperSpotsY; 
int numNonAdjustableBumpers = 0;
boolean decisionMade;
int[] scores;
int maxScore = 30;
boolean gameOver = false;
int winner;
int sideBuffer = 150;
float leftSide;//used for showdown
/*
public color[] colors = new color[]{    
  color(10, 145, 10, 200), 
  color(145, 10, 10, 200), 
  color(10, 145, 145, 200), 
  color(190, 100, 0, 200), 
  color(145, 145, 255,200)
};*/ 
public color[] colors = new color[]{    
  color(0, 255, 0, 200), 
  color(215, 215, 0, 200), 
  color(255, 50, 50, 200), 
  color(120, 150, 255, 200), 
  color(180, 180, 180, 200),
  color(0, 255, 0, 200),
  color(160, 30, 180, 200),
  color(10, 30, 80, 200),
  color(190, 100, 0, 200),
  color(225,225,225,200)
}; 
void setup() {
  size (displayWidth, displayHeight);
  smooth();
  frameRate(60);
  rectMode(CENTER);
  textAlign(CENTER, CENTER);
  imageMode(CENTER);
  // textMode(CENTER);
  textSize(30);
  //  createGUI();
  initialize();
}

void initialize() {
  // Initialise the ControlIO
  control = ControlIO.getInstance(this);
  
//  println("numDevices"+control.getNumberOfDevices());
  scores = new int[numPlayers];
  imgs = new PImage[4][4];
  icons = new PImage[4];
  flaps = new SoundFile[7];
  players = new ArrayList <Player>();
  gpads = new ArrayList<ControlDevice>();
  // floater = new AIFloater(players, imgs[(players.size())%4]);
  platforms = new ArrayList <Platform>();
  bumpers = new ArrayList <Bumper>();
  drawable = new ArrayList <Object>();
  bumperSize = new PVector(50,50);//36,20
  numBumperSpotsY= (int)(height/bumperSize.y/3-1);
  numBumperSpotsX = (int)((width-sideBuffer/2)/bumperSize.x/2);
  decisionMade = false;
  // setPlatforms();
  //get the number of local gamepads connected
  //numGamePads = 4;//control.getDevices().size();
  // create players with devices that match the configuration file

  //  setPlatforms();
  setBumpers();
  setImages();
  setSounds();
  for (int i = 0; i < numPlayers; i ++) { 
    ControlDevice temp = control.getMatchedDeviceSilent("p"+(i+1)+"_gamepad_config");
    if (temp != null){gpads.add(temp);}
  }
  numGamePads = gpads.size();
  reset();
}

void reset() {
  players = new ArrayList <Player>();
  for (int i = 0; i < numGamePads; i ++) { 
    if (gpads.get(i) != null){
      players.add( new Player(players, gpads.get(i), imgs[(players.size())%4], flaps));
    }
    // gpad = control.getDevices().get(control.getDevices().size()-1);
  }
  //If not enough gamepads then fill with AI TODO
  for (int i = numGamePads; i < numPlayers; i++) {
    players.add( new AIFloater(players, imgs[(players.size())%4], flaps)); 
  }
  for (Bumper p : bumpers){
     p.duration = 500; 
  }
  //remove all the temp bumpers from showdown
  for (int i = 0; i < bumpers.size(); i++){
    Bumper b = bumpers.get(i);
    if (b.temp){
      bumpers.remove(b);
      drawable.remove(b);
      i--;
    }
  }
    
  leftSide = 0;//get walls out of the way until the final show down
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
  for (int i = -1; i <numBumperSpotsX*2+1; i += 1) {
    bumpers.add(new Bumper(new PVector((i+0.5)*bumperSize.x, bumperSize.y*0.25), 
      new PVector(bumperSize.x, bumperSize.y), 0 ));
    bumpers.add(new Bumper(new PVector((i+0.5)*bumperSize.x, height-bumperSize.y/2), 
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
  if (key == '`') {
    makeWinner();
  }
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
        if (temp.duration > 50 ){
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
      /*textSize(50);
      text("7", 240, 200);
      text("8", 440, 200);
      text("5", 640, 200);
      text("6", 840, 200);
*/
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
      
      if (tempPad == null||tempPad.getButton(7).pressed()){
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
      println(bumpers.size());
        //textAlign(CENTER, CENTER);
        int showdownScale = 240;
        float blockScale = 5;
        PVector blockSize = new PVector(bumperSize.x*blockScale, bumperSize.y*blockScale); 
        leftSide ++;
        int countDown = 6 - round((int)leftSide/showdownScale);
        if (leftSide % showdownScale == 0 && countDown >= 3){
          for (int i = (int)(blockSize.y/2+bumperSize.y*0.75); i <= height; i+= blockSize.y){
             bumpers.add(new Bumper(new PVector((leftSide/showdownScale-0.5)*blockSize.x, i), blockSize, -90, true));
             bumpers.add(new Bumper(new PVector((width )- (leftSide/showdownScale-0.1)*blockSize.x, i), blockSize, 90, true));
          }
        }
        color coolCol = lerpColor(colors[players.get(0).ID], colors[players.get(1).ID], 0.5*sin(frameCount*0.2)+0.5);
        fill(coolCol, 200);
        if (countDown>0){
          textSize(220);
          text("SHOWDOWN!", (width-sideBuffer/2)/2, height*0.33);
          textSize(320);
          text(""+countDown, (width-sideBuffer/2)/2, height*0.66);
        }
        if (countDown == 0){       
          players.get(0).vel = new PVector();
          players.get(1).vel = new PVector();
          textSize(320);
          text("TIME UP!", (width-sideBuffer/2)/2, height/2);
        }
        else if (countDown<0){
          drawable.remove(players.get(1));
          drawable.remove(players.get(0));
          players.remove(players.get(1));
          players.remove(players.get(0));
          countDown = 0;
          leftSide = 0;
         // println ("reseting" + players.size());
          reset();
        }
    }

    //drawTheScores
    fill(0);
    rect(width - sideBuffer/5, height/2, sideBuffer, height);
    for (int i = 0; i < scores.length; i++) {
      fill(255, 200);
      textSize(30);
      text("P"+(i+1)+" "+scores[i], width - sideBuffer*0.4-1.5, (i+1)*100-1);
      fill(colors[i+1]);
      text("P"+(i+1)+" "+scores[i], width - sideBuffer*0.4, (i+1)*100);
      if (scores[i] >= maxScore) {
        gameOver = true;
        winner = i;
      }
    }
  } else if (gameOver) {
        textSize(70);
        
        fill(colors[winner+1]);
        tint(colors[winner+1]);
        image(imgs[winner%4][0], (width)/2, height/2, 300, 300);
        text("Player "+ (winner +1) + "is the WINNER!", (width)/2 ,200);
        text("Press start to continue", (width)/2 ,550);
        for (ControlDevice pad : gpads){
          if (pad.getButton(10).pressed()){
            gameReset();
          }
        }
        //textAlign(LEFT, TOP);

  }
}
