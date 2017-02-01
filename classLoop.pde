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
  // METHOD: getEvents                                                       
  //     Returns an ArrayList<Event> of Events in an interval (t1, t2] (in measure time)
  //     arguments:
  //       t1: measure time at start of interval
  //       t2: measure time at end of interval
  ///////////////////////////////////////////////////////////////////////////////
  ArrayList<Event> getEvents( float t1 , float t2 ) {
    // create an arrayList of ArrayList<Events> to store events for all channels
    ArrayList<ArrayList<Event>> allEvents = new ArrayList<ArrayList<Event>>(numChannels);
    // fill the meta-ArrayList, and calculate the total number of events N
    int N = 0;
    for( int i = 0 ; i < numChannels ; i++ ) {
      allEvents.add( i , cl[i].getEvents( t1 , t2 ) );
      N += allEvents.get(i).size();
    }
    // create an empty ArrayList to hold all Events
    ArrayList<Event> output = new ArrayList<Event>();
    // loop through all events and store them, in order
    // This loop should remove one element per iteration
    for( int n = 0 ; n < N ; n++ ) {
      float lowestTime = 100;
      int lowestTimeChannel = 0;
      // loop through all channels, and compare the first event's time to lowestTime
      for( int i = 0 ; i < numChannels ; i++ ) {
        if( allEvents.get(i).size() > 0 ) {
          if( allEvents.get(i).get(0).t <= lowestTime ) {
            lowestTime =  allEvents.get(i).get(0).t;
            lowestTimeChannel = i;
          }
        }
      }
      // lowestTimeChannel now contains the channel of the earliest remaining Event
      // append the Event to the output List
      output.add( allEvents.get(lowestTimeChannel).get(0).clone() );
      // remove the Event from its channel
      allEvents.get(lowestTimeChannel).remove(0);
    }
    return output;
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