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

color[] synthColors;
boolean[] synthActive;

SynthSliders SL;


void setup() {
  size( 800, 480 );

  xRes = float(width);
  yRes = float(height);
  xC = 0.5*xRes;
  yC = 0.5*yRes;
  d = yRes;
  
  colorMode( HSB , 360 , 1 , 1 , 255 );

  M = new Metronome();
  L = loopSetup( M );
  OH = new OutputHandler( M , L );
  IH = new InputHandler( M , L  , OH);
  s = new Server(this, 12345);
  SL = new SynthSliders( 160 , 0 , 640 , 160 );
  
  synthColors = new color[24];
  synthActive = new boolean[24];
  for( int i = 0 ; i < 24 ; i++ ) {
    synthColors[i] = color( random(0,360) , 1 , 1 );
    synthActive[i] = false;
  }
  synthActive[ floor( random(0,16) ) ] = true;
  synthActive[ floor( random(16,24) ) ] = true;
}


void draw() {

  // get the current time
  int t = millis();
  // get the current mouse position
  float mx = mouseX;
  float my = mouseY;
  float mt = M.measureTime(t);
  // evolve the metronome
  M.evolve( t );
  // evolve the ChannelLoop
  L.evolve( t );
  // evolve the slider
  SL.evolve( mx , my );
  
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
  L.drawMin( t , 0 , 160 , xRes*0.2 , 240 , 0.1 );
  drawRecordButton( 0.0*xRes , 0 , 0.2*xRes , 160 );
  //drawChannelButtons( 0.2*xRes , 400 , 0.8*xRes , 80 );
  //drawChannelButtons( 0.2*xRes , 320 , 0.8*xRes , 80 );
  //drawChannelButtons( 0.2*xRes , 240 , 0.8*xRes , 80 );
  for( int i = 0 ; i < 8 ; i++ ) {
    drawSynthButton( 160 + 80*i , 160 , i , synthColors[i] , synthActive[i] );
    drawSynthButton( 160 + 80*i , 240 , 8+i , synthColors[8+i] , synthActive[8+i] );
    drawChannelButton( 160 + 80*i , 380 , 16+i , synthColors[16+i] , synthActive[16+i] );
  }
  SL.draw();
  //println( C.print() );
  mtLast = mt;
  //println( frameRate );
}


void mousePressed() {
  SL.triggerInput( mouseX , mouseY );
}

void mouseReleased() {
  SL.deactivate();
}

void keyPressed() {
  IH.recieveInput( keyCode ,  true );
}
void keyReleased() {
  IH.recieveInput( keyCode ,  false );
}