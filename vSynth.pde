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
  // ArrayList<Event> events = L.getEvents( mtLast , mt );
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
  L.drawMin( t , 0 , 0 , xRes , yRes , 0.1 );
  //println( C.print() );
  mtLast = mt;
}


void keyPressed() {
  IH.recieveInput( keyCode ,  true );
}
void keyReleased() {
  IH.recieveInput( keyCode ,  false );
}