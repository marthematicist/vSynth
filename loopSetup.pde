// FUNCTION loopSetup
Loop loopSetup( Metronome Min) {
  // initialize Loop
  int numChannels = 8;              // number of channels
  color cursorColor = color( 60 , 1 , 1 );
  Loop Lout = new Loop( numChannels , Min , cursorColor );
  
  // set type
  String[] types = { "OnOff" , "OnOff" , "OnOff" , "OnOff" , "OnOff" , "OnOff" , "OnOff" , "OnOff" };
  
  // set parameters
  for( int i = 0 ; i < numChannels ; i++ ) {
    String type = types[i];
    color lineColorOn = color( 0 , 0 , 1 );
    color lineColorOff = color( 0 , 0 , 0.5 );
    color fillColorOn = color( 320*i/numChannels , 1 , 1 );
    color fillColorOff = color( 320*i/numChannels , 0.5 , 0.5 );
    color bgColorOn = color( 0 , 0 , 0.5 );
    color bgColorOff = color( 0 , 0 , 0.25 );
    
    Lout.cl[i] = createChannelLoop(  Min ,      // Metronome
                                  type,       // type
                                  i,          // channel
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