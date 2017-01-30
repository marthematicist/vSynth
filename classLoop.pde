//////////////////////////////////////////////
// Clss: Loop ////////////////////////////////
//////////////////////////////////////////////

class Loop {
  // Fields: ///////////////////////////////////
  int numChannels;              // number of channels
  ChannelLoop[] cl;             // Array of ChennelLoops (length numChannels)
                                // ChannelLoops contain data about events scheduled
                                // on a channel
  Metronome M;                  // Metronome attached to instance

  color cursorColor;            // color of draw cursor
  
  Loop( int n , Metronome Min , 
        color cursorColorIn ) {
    this.numChannels = n;
    this.cl = new ChannelLoop[ this.numChannels ];
    this.M = Min;
    this.cursorColor = cursorColorIn;
  }

  
  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: drawMin                                                       
  //     draws the loop to the screen
  ///////////////////////////////////////////////////////////////////////////////
  void drawMin( int t , float xl , float yl , float wl , float hl , float gapRatio ) {
    // get the measureTime from the Metronome
    float mt = M.measureTime( t );
    // check whether horizontal or vertical and set gap and channel height/width
    boolean vert;
    float g;
    float wc;
    float hc;
    if( wl > hl ) {
      vert = false;
      g = hl / numChannels * gapRatio;
      wc = wl;
      hc = (hl - g*(numChannels - 1)) / numChannels ;
    }
    else {
      vert = true;
      g = wl / numChannels * gapRatio;
      wc = (wl - g*(numChannels - 1)) / numChannels ;
      hc = hl;
    }
    // draw the channels
    for( int i = 0 ; i < numChannels ; i++ ) {
      if( !vert ) { cl[i].drawMin( xl , yl + i*(hc + g) , wc , hc ); }
      else        { cl[i].drawMin( xl + i*(wc + g) , yl , wc , hc ); }
    }
    // draw the cursor
    stroke( this.cursorColor );
    strokeWeight( 1 );
    if( !vert ) { line( xl + wl*mt , yl , xl + wl*mt , yl + hl ); }
    else        { line( xl , yl + hl*mt , xl + wl , yl + hl*mt ); }
  }
 
  
  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: triggerReset                                                       
  //     Sets resetTriggered
  ///////////////////////////////////////////////////////////////////////////////
  void triggerReset( int c ) {
    cl[c].resetTriggered = true;
  } // end of METHOD: resetTriggered ////////////////////////////////////////////
  
  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: toggleOn                                                       
  //     Toggles On flag
  ///////////////////////////////////////////////////////////////////////////////
  void toggleOn( int c ) {
    cl[c].onToggled = true;
  } // end of METHOD: resetTriggered ////////////////////////////////////////////

  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: triggerInput                                                       
  //     Sets inputTriggered and InputTriggerTime
  //     arguments:
  //       t: system time of evolution (int)
  ///////////////////////////////////////////////////////////////////////////////
  void triggerInput( int c , int t ) {
    cl[c].inputTriggered = true;
    cl[c].inputTriggerTime = t;
  } // end of METHOD: triggerInput /////////////////////////////////////////////  
  
  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: clearInput                                                       
  //     Sets inputCleared and InputClearTime
  //     arguments:
  //       t: system time of evolution (int)
  ///////////////////////////////////////////////////////////////////////////////
  void clearInput( int c , int t ) {
    cl[c].inputCleared = true;
    cl[c].inputClearTime = t;
  } // end of METHOD: clearInput /////////////////////////////////////////////
  
  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: clearInputAll                                                     
  //     Sets inputCleared and InputClearTime for all channels affected
  //     arguments:
  //       t: system time of evolution (int)
  ///////////////////////////////////////////////////////////////////////////////
  void clearInputAll( int t ) {
    for( int i = 0 ; i < numChannels ; i++ ) {
      if( cl[i].on ) {
        cl[i].inputCleared = true;
        cl[i].inputClearTime = t;
      }
    }
  } // end of METHOD: clearInputAll /////////////////////////////////////////////
  
  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: evolve                                                       
  //     Evolves the event list
  //     arguments:
  //       t: system time of evolution (int)
  ///////////////////////////////////////////////////////////////////////////////
  void evolve( int tIn ) {
    for( int i = 0 ; i < numChannels ; i++ ) {
      cl[i].evolve( tIn );
    }
  } // end of METHOD: evolve /////////////////////////////////////////////////////
}