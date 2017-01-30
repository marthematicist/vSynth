// FUNCTION loopSetup
Loop loopSetup( Metronome Min) {
  // initialize Loop
  int numChannels = 8;              // number of channels
  color cursorColor = color( 255 , 255 , 0 );
  Loop Lout = new Loop( numChannels , Min , cursorColor );
  
  // set type
  String[] types = { "OnOff" , "OneTime" , "OneTime" , "OnOff" , "OneTime" , "OneTime" , "OnOff" , "OneTime" };
  
  // set parameters
  for( int i = 0 ; i < numChannels ; i++ ) {
    String type = types[i];
    color lineColorOn = color( 255 , 255 , 255 );
    color lineColorOff = color( 128 , 128 , 128 );
    color fillColorOn = hsvColor( 320*i/numChannels , 1 , 1 );
    color fillColorOff = hsvColor( 320*i/numChannels , 0.5 , 0.5 );
    color bgColorOn = color( 128 , 128 , 128 );
    color bgColorOff = color( 64 , 64 , 64 );
    
    Lout.cl[i] = createChannelLoop(  Min ,      // Metronome
                                  type,       // type
                                  lineColorOn,  // colors
                                  lineColorOff,
                                  bgColorOn,
                                  bgColorOff,
                                  fillColorOn,
                                  fillColorOff
                                  );
  }
  return Lout;
}