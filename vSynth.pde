//import processing.net.*;

//Client c;
//String input;
//int data[];

float xRes;
float yRes;
float xC;
float yC;
float d;


void setup() {
  size( 800, 480 );

  xRes = float(width);
  yRes = float(height);
  xC = 0.5*xRes;
  yC = 0.5*yRes;
  d = yRes;

  M = new Metronome();
  L = loopSetup( M );
}


void draw() {

  // get the current time
  int t = millis();
  // evolve the metronome
  M.evolve( t );
  // evolve the ChannelLoop
  L.evolve( t );
  //println( "done evolving ChannelLoop" );

  // draw
  background(0, 0, 0 );
  //M.draw();
  L.drawMin( t , 0 , 0 , xRes , yRes , 0.1 );
  //println( C.print() );
  
}