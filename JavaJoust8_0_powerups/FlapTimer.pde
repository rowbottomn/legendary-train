import java.lang.System;

public class FlapTimer{

  int duration; //timer between flaps
  long startTime;//when the flap happened
  long timer;//current time in millis
  boolean canFlap;//boolean to determine whether another flap even can be triggered.
 
  public FlapTimer(){// no parameter constructor 
    timer = -99;
    startTime = -99;
    duration = 1000;
    canFlap = true;
  }

  public FlapTimer(int d){ //constructor that lets you set the duration between flaps
    timer = d;
    startTime = 0;
    duration = d;
    canFlap = true;
  }
  
  public void flap(){
    startTime = System.currentTimeMillis();
    timer = 0;
    canFlap = false;
  }
  
  public void tick(){
    //if the timer - the startTimer > duration turn canFlap on
    if (!canFlap){
      timer = System.currentTimeMillis() - startTime;
      if (timer >= duration){
         canFlap = true; 
      }
    }
    else {
     timer = duration; 
    }
  }
  
}
