/*
Feature                Design                Coding                  Testing          Completed               Commments

UML State diagram     June 3                                                          June 3 
                      
UML class diagram     June 2                                                                                 Defined clases but not up to date
               
Abstract Player       June 7                 June 7                  June 7
                      June 1                 June 1                  June 1          June 1                  Revised to add checkCollision method, disabled boolean

Basic Player          June 10                                                                                Tinting to disable with flaptimer, use flattening of sprite to do death animation
                      June 8                June 8                   June 9                                  Checkcollison works, need diabling, death animation and lives
                      June 2                June 3                   June 3           June 3                 Need to implement checkCollision with other players
                      June 1                June 1                   June 2           <==                    Problems with limiting flapping and speedlimits                 

Abstract Obstacle     June 8                 June 8                   June 8          
                      June 4                 June 4                    June 4          June 4                Moved touching method to Helper Method class
          
Platform class        June 4                  June 4                  June 5          June 5                Problems with blocking method

Bumper class                                 
                      June 8                 June 8                    June 8                              Art is awesome but needs tweaking on bottom behavour
                                              June 7                   June 7                                Problems with art, multiple detection
                      June 6                 June 6                   June 6                                Problems with art, player position changes

Hazard class          June 10               ~~~~~~~~~~                                                     Moved to optional requirements

Gamepad controls                              June 10                  June 10                             Got 1P to have controls!  Need to implement multiplayers
                                              June 8                                                       Still having problems getting control 
                                              June 7                                                        Little progress, looked at library
                      June 6                  June 6                 June 6                                Significant problems with library
                            
Bird Art                                      June 9                 June 9          June 9                     Implemented flapping animation, need to adjust hit box to match pic
                      June 9                  June 8                 June 8                                Setup images from spritesheet, loaded into 2D array            
                      June 6                  June 6                                                       Initial Setup

AI Players            JUne 10                 
                      June 9                  June 9                                                       No abstract class, extend floater off player
                      June 8                  June 8                                                       UNsure how to best implement

Network Multi                                  June 4                                                      Abandoning UDP for network or websocket libraries   
                                               JUne 2                                                      Multiple things tried 
                      May 30                   June 1                June 1                                Trouble using udp library

Couch Multi          June 10                                                                               Each player with arraylist of arraylists for lives, on death remove(0), spawn(get(0))

AI multi             June 10                                                                                Any player slot not picked up gets picked up by AI

UI                   June 10                                                                                G4P?  Look at other libraries?

Music and sounds     June 10                                                                                Need flap sound and music

Background image     June 10                                                                                Background image from flappy bird or random selection from arcade games (Ehonda screen)



*/