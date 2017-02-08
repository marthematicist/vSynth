import processing.net.*;
Server s;
String input;
int data[];


//Client c;
//String input;
//int data[];

float xRes;
float yRes;
float xC;
float yC;
float d;

float mtLast = 0;


void setup() {
  size( 800, 480 );

  xRes = float(width);
  yRes = float(height);
  xC = 0.5*xRes;
  yC = 0.5*yRes;
  d = yRes;

  M = new Metronome();
  L = loopSetup( M );
  OH = new OutputHandler( M , L );
  IH = new InputHandler( M , L  , OH);
  s = new Server(this, 12345);
}


void draw() {

  // get the current time
  int t = millis();
  float mt = M.measureTime(t);
  // evolve the metronome
  M.evolve( t );
  // evolve the ChannelLoop
  L.evolve( t );
  
  // get events from Loop
  // send all events to client
  OH.sendAllEvents( s );
  /*
  for( int i = 0 ; i < events.size() ; i ++ ) {
    println( millis() + "      " + events.get(i).sendData() );
    s.write( events.get(i).sendData() );
  }
  */
  
    

  // draw
  background(0, 0, 0 );
  //M.draw();
  L.drawMin( t , 0 , 0 , xRes*0.1 , yRes*0.8 , 0.1 );
  drawRecordButton( 0.0*xRes , 0.8*yRes , 0.1*xRes , 0.2*yRes );
  drawChannelButtons( 0.1*xRes , 0.8*yRes , 0.9*xRes , 0.2*yRes );
  drawChannelButtons( 0.1*xRes , 0.5*yRes , 0.9*xRes , 0.2*yRes );
  drawChannelButtons( 0.1*xRes , 0.3*yRes , 0.9*xRes , 0.2*yRes );
  colorFun( 0.1*xRes , 0.0*yRes , 0.9*xRes , 0.2*yRes );
  //drawMenuButtons( 0.9*xRes , 0 , 0.1*xRes , yRes );
  //println( C.print() );
  mtLast = mt;
  println( frameRate );
}


void keyPressed() {
  IH.recieveInput( keyCode ,  true );
}
void keyReleased() {
  IH.recieveInput( keyCode ,  false );
}