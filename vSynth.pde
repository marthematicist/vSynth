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
  size( 1280, 800, P2D );
  drawBuffer = createGraphics( 1280, 800, P2D );

  xRes = float(width);
  yRes = float(height);
  xC = 0.5*xRes;
  yC = 0.5*yRes;
  d = yRes;

  M = new Metronome();
  L = loopSetup( M );
  C = new ChannelLoop( M , "OnOff" );
  S00 = new Scene00( drawBuffer, M, xRes, yRes );
  // c = new Client( this, "192.168.0.104", 12345 );
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
  L.drawMin( t , 50 , 50 , mouseX , mouseY , 0.1 );
  //println( C.print() );
  
}