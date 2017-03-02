// FUNCTION loopSetup
Loop loopSetup( Metronome Min , PatchBay PBin) {
  // initialize Loop
  int numChannels = 8;              // number of channels
  color cursorColor = color( 0.1667 , 1 , 1 );
  Loop Lout = new Loop( numChannels , Min , PBin , cursorColor );
  
  // set type
  int[] types = { 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 };
  
  // set parameters
  for( int i = 0 ; i < numChannels ; i++ ) {
    int type = types[i];
    color lineColorOn = color( 0 , 0 , 1 );
    color lineColorOff = color( 0 , 0 , 0.5 );
    color fillColorOn = color( float(i)/float(numChannels) , 1 , 1 );
    color fillColorOff = color( float(i)/float(numChannels) , 0.5 , 0.5 );
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
////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////
// Class: Loop ////////////////////////////////
//////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
class Loop {
  // Fields: ///////////////////////////////////
  int numChannels;              // number of channels
  ChannelLoop[] cl;             // Array of ChennelLoops (length numChannels)
                                // ChannelLoops contain data about events scheduled
                                // on a channel
  Metronome M;                  // Metronome attached to instance
  PatchBay PB;
  color cursorColor;            // color of draw cursor
  
  Loop( int n , Metronome Min , PatchBay PBin, 
        color cursorColorIn ) {
    this.numChannels = n;
    this.cl = new ChannelLoop[ this.numChannels ];
    this.M = Min;
    this.PB = PBin;
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
    float gs = 4;
    float xs = xl + gs;
    float ys = yl + gs;
    float ws = wl - 2*gs;
    float hs = hl - 2*gs;
    float g = 4;
    float wc = (ws - g*(numChannels+1)) / numChannels;
    float hc = hs;
    strokeWeight(2);
    stroke( 0 , 0 , 0.5 );
    noFill();
    rect( xs , ys , ws , hs , 5 , 5 , 5 , 5 );
    // draw the channels
    for( int i = 0 ; i < numChannels ; i++ ) {
      cl[i].drawMin2( xs + i*(wc + g) + g , ys , wc , hc );
    }
    // draw the cursor
    stroke( this.cursorColor );
    strokeWeight( 2 );
    line( xs , ys + hs*mt , xs + ws , ys + hs*mt );
    
  }
 
  
  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: triggerReset                                                       
  //     Sets resetTriggered
  ///////////////////////////////////////////////////////////////////////////////
  void triggerReset( int c ) {
    cl[c].triggerReset();
  } // end of METHOD: resetTriggered ////////////////////////////////////////////
  
  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: triggerToggle                                                       
  //     Toggles On flag
  ///////////////////////////////////////////////////////////////////////////////
  void triggerToggle( int c ) {
    cl[c].triggerToggle();
  } // end of METHOD: resetTriggered ////////////////////////////////////////////

  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: triggerInput                                                       
  //     Sets inputTriggered and InputTriggerTime
  //     arguments:
  //       t: system time of evolution (int)
  ///////////////////////////////////////////////////////////////////////////////
  void triggerInput( int c ) {
    cl[c].triggerInput();
  } // end of METHOD: triggerInput /////////////////////////////////////////////  
  
  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: clearInput                                                       
  //     Sets inputCleared and InputClearTime
  //     arguments:
  //       t: system time of evolution (int)
  ///////////////////////////////////////////////////////////////////////////////
  void clearInput( int c ) {
    cl[c].clearInput();
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
    updateChannels();
  } // end of METHOD: evolve /////////////////////////////////////////////////////
  
  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: updateChannels                                                       
  //     Sets channel colors based on PB
  ///////////////////////////////////////////////////////////////////////////////
  void updateChannels() {
    for( int i = 0 ; i < numChannels ; i++ ) {
      cl[i].fillColorOn = color( PB.channels[i].h , PB.channels[i].s , PB.channels[i].v );
      cl[i].fillColorOff = color( PB.channels[i].h , 0.5*PB.channels[i].s , 0.5*PB.channels[i].v );
      cl[i].lineColorOn = color( PB.channels[i].h , 1 , 1 );
      cl[i].lineColorOff = color( PB.channels[i].h , 0.5 , 0.5 );
      cl[i].type = PB.channels[i].type;
      cl[i].l = PB.channels[i].l;
      cl[i].on = PB.channelOn[i];
    }
  }
}


////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
// Class: ChannelLoop                                                //
///////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
class ChannelLoop {
  // FIELDS ///////////////////////////////////////////////////////////////////////
  int type;                           // 0 = onOff , 1 = timed 
  int l;                              // [0,4]: 0=whole, 1=half, 2=quarter, 3=eight, 4=sixteenth
  Metronome M;                        // Metronome class instance associated with this ChannelLoop
  int ch;                             // channel
  ArrayList<Event> events;            // List of Events
  boolean inputOn;                    // Is input on?
                                      //   set and cleared in evolve
  boolean inputTriggered;             // Flag that input has just been triggered
                                      //   set in triggerInput, cleared in evolve
  int inputTriggerTime;               // Time of input trigger (system time in millis)
                                      //   set in triggerInput
  boolean inputCleared;               // Flag that input has just been cleared
                                      //   set in triggerInput, cleared in evolve
  int inputClearTime;                 // Time of input clear (system time in millis)
                                      //   set in clearInput
  boolean resetTriggered;             // Flag that reset has been triggered (set in triggerReset,
                                      //   cleared in reset()
  float lastEvolveTime;               // Time of last evolve (mesaure time)
                                      //   set in evolve. Used to clear events between 
                                      //   evolvutions if inputOn during both
  boolean full;                       // is the loop completely full?
                                      //   If true, inputOn is set, and no other methods will
                                      //   affect the object except reset() and draw() (spectial case)
  boolean onToggleTriggered;                  // Flag that on state has been toggled
  boolean on;                         // is the loop active? Affects output
  color lineColorOn;                  // color of lines in draw box (when on)
  color lineColorOff;                 // color of lines in draw box (when off)
  color bgColorOn;                    // background color in draw box (when on)
  color bgColorOff;                   // background color in draw box (when off)
  color fillColorOn;                  // color of fill in draw box (when on)
  color fillColorOff;                 // color of fill in draw box (when off)
  
  // CONSTRUCTOR ////////////////////////////////////////////////////////////////
  ChannelLoop( Metronome Min , int typeIn , int chIn) {
    this.type = typeIn;
    this.M = Min;
    this.ch = chIn;
    this.events = new ArrayList<Event>();
    this.inputOn = false;
    this.inputTriggered = false;
    this.inputTriggerTime = 0;
    this.inputCleared = false;
    this.inputClearTime = 0;
    this.resetTriggered = false;
    this.lastEvolveTime = 0;
    this.full = false;
    this.onToggleTriggered = false;
    this.on = true;
    this.lineColorOn = color( 0 , 0 , 1 );
    this.lineColorOff = color( 0 , 0 , 0.75 );
    this.bgColorOn = color( 0 , 0 , 0.5 );
    this.bgColorOff = color( 0 , 0 , 0.25 );
    this.fillColorOn = color( 0 , 0 , 0.75 );
    this.fillColorOff = color( 0 , 0 , 0.5 );
  }  // end of CONSTRUCTOR
  
  
  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: getEvents                                                       
  //     Returns an ArrayList<Event> of Events in an interval (t1, t2] (in measure time)
  //     arguments:
  //       t1: measure time at start of interval
  //       t2: measure time at end of interval
  ///////////////////////////////////////////////////////////////////////////////
  ArrayList<Event> getEvents( float t1 , float t2 ) {
    // does the interval wrap from front to back of loop?
    boolean wraps = false;
    // create an empty ArrayList
    ArrayList<Event> output = new ArrayList<Event>();
    if( t1 > t2 ) { wraps = true; }
    // parse through all Events, and add them to the List if they are in the interval
    for( int i = 0 ; i < events.size() ; i++ ) {
      // get time of event
      float te = events.get(i).t;
      if( on && ( ( !wraps && ( (t1 < te) && (te <= t2) ) ) || ( wraps && ( (te <= t2) || (t1 < te) ) ) ) ) {
        output.add( events.get(i).clone() );
      }
    }
    return output;
  }
   
  
  
  
  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: drawMin                                                       
  //     draws the loop to the screen
  ///////////////////////////////////////////////////////////////////////////////
  void drawMin( float xc , float yc , float wc , float hc ) {
    //float mt = M.measureTime( t );
    noFill();
    strokeCap( SQUARE );
    // check whether horizontal or vertical and set line width
    boolean vert;
    if( wc < hc ) {
      vert = true;
      strokeWeight( 4 );
    } else {
      vert = false;
      strokeWeight( 4 );
    }
    // set the background color
    if( this.on ) { stroke( this.bgColorOn ); } 
    else          { stroke( this.bgColorOff ); }
    // draw the background
    if( !vert ) { line( xc , yc + 0.5*hc , xc + wc , yc + 0.5*hc ); }
    else        { line( xc + 0.5*wc , yc , xc + 0.5*wc , yc + hc ); }
    if( wc < hc ) {
      vert = true;
      strokeWeight( wc );
    } else {
      vert = false;
      strokeWeight( hc );
    }
    // set the event color
    if( this.on ) { stroke( this.fillColorOn ); } 
    else          { stroke( this.fillColorOff ); }
    // draw the events - TYPE: "OnOff"
    if( type == 0 && events.size() > 0 ) {
      // if the first event is an Off, draw event from start to it
      if( !events.get( 0 ).on ) {
        if( !vert ) { line( xc , yc + 0.5*hc , xc + wc*events.get(0).t , yc + 0.5*hc ); }
        else        { line( xc + 0.5*wc , yc , xc + 0.5*wc , yc + hc*events.get(0).t ); }
      }
      // if the last event is an ON, draw event from it to end
      int last = events.size() - 1;
      if( events.get(last).on ) {
        if( !vert ) { line( xc + wc*events.get(last).t , yc + 0.5*hc , xc + wc , yc + 0.5*hc ); }
        else        { line( xc + 0.5*wc , yc + hc*events.get(last).t , xc + 0.5*wc , yc + hc ); }
      }
      // if there are at least two events, draw lines between them
      if( events.size() > 1 ) {
        // for each pair of events
        for( int i = 0 ; i < events.size() - 1 ; i++ ) {
          // only draw if first event is On and second is Off
          if( events.get(i).on && !events.get(i+1).on ) {
            // get t1 and t2, measureTimes for the events
            float t1 = events.get(i).t;
            float t2 = events.get(i+1).t;
            // draw the On event
            if( !vert ) { line( xc + wc*t1 , yc + 0.5*hc , xc + wc*t2 , yc + 0.5*hc ); }
            else        { line( xc + 0.5*wc , yc + hc*t1 , xc + 0.5*wc , yc + hc*t2 ); } 
          }
        }
      }
    }
    // draw the events - TYPE: "Timed"
    if( type == 1 && events.size() > 0 ) {
      // for each event...
      for( int i = 0 ; i < events.size() ; i++ ) {
        // get t1, measureTime for the event
        float t1 = events.get(i).t;
        float t2 = events.get(i).t+0.02;
        if( t2 > 1 ) { t2 = 1; }
        // set the event color
        if( this.on ) { stroke( this.fillColorOn ); } 
        else          { stroke( this.fillColorOff ); }
        if( !vert ) { strokeWeight( hc ); }
        else        { strokeWeight( wc ); }
        // draw the On event
        if( !vert ) { line( xc + wc*t1 , yc + 0.5*hc , xc + wc*t2 , yc + 0.5*hc ); }
        else        { line( xc + 0.5*wc , yc + hc*t1 , xc + 0.5*wc , yc + hc*t2 ); } 
        // set the line color
        
        if( this.on ) { stroke( this.lineColorOn ); }
        else          { stroke( this.lineColorOff ); }
        strokeWeight( 5 );
        // draw the On beginning
        if( !vert ) { line( xc + wc*t1 , yc , xc + wc*t1 , yc + hc ); }
        else        { line( xc , yc + hc*t1 , xc + wc , yc + hc*t1 ); } 
      }
    }
  }

  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: drawMin2                                                       
  //     draws the loop to the screen
  ///////////////////////////////////////////////////////////////////////////////
  void drawMin2( float xc , float yc , float wc , float hc ) {
    noFill();
    strokeCap( SQUARE );
    // draw the background line
    if( this.on ) { stroke( this.bgColorOn ); } 
    else          { stroke( this.bgColorOff ); }
    strokeWeight( 4 );
    line( xc + 0.5*wc , yc , xc + 0.5*wc , yc + hc );
    
    // set colors for event drawing
    if( this.on ) {
      stroke( lineColorOn );
      fill( fillColorOn );
    } else {
      stroke( lineColorOff );
      fill( fillColorOff );
    }
    strokeWeight(1);
    
    // draw the events - TYPE: "OnOff"
    if( type == 0 && events.size() > 0 ) {
      // if the first event is an Off, draw event from start to it
      if( !events.get( 0 ).on ) {
        rect( xc , yc , wc , hc*events.get(0).t );
      }
      // if the last event is an ON, draw event from it to end
      int last = events.size() - 1;
      if( events.get(last).on ) {
        rect( xc , yc + hc*events.get(last).t , wc , hc - hc*events.get(last).t );
      }
      // if there are at least two events, draw lines between them
      if( events.size() > 1 ) {
        // for each pair of events
        for( int i = 0 ; i < events.size() - 1 ; i++ ) {
          // only draw if first event is On and second is Off
          if( events.get(i).on && !events.get(i+1).on ) {
            // get t1 and t2, measureTimes for the events
            float t1 = events.get(i).t;
            float t2 = events.get(i+1).t;
            // draw the On event
            rect( xc , yc + hc*t1 , wc , hc*( t2 - t1 ) );
          }
        }
      }
    }
    
    // draw the events - TYPE: "Timed"
    if( type == 1 && events.size() > 0 ) {
      // for each event...
      for( int i = 0 ; i < events.size() ; i++ ) {
        // set colors for event drawing
        if( this.on ) {
          stroke( lineColorOn );
          fill( fillColorOn );
        } else {
          stroke( lineColorOff );
          fill( fillColorOff );
        }
        // get t1 (start) and t2 (end)
        float t1 = events.get(i).t;
        float t2 = t1;
        if( l == 0 ) { t2 += 1; }
        if( l == 1 ) { t2 += 0.5; }
        if( l == 2 ) { t2 += 0.25; }
        if( l == 3 ) { t2 += 0.125; }
        if( l == 4 ) { t2 += 0.0625; }
        println( l );
        // check whether t2 wraps to next measure
        if( t2 > 1 ) {
          // t2 is in next measure
          // draw from t1 to end
          rect( xc , yc + hc*t1 , wc , hc - hc*t1 );
          // draw from beginning to t2
          rect( xc , yc , wc , hc*(t2-1) );
        } else {
          // t2 is in this measure. draw event
          rect( xc , yc + hc*t1 , wc , hc*( t2 - t1 ) );
        }
        // draw a white line at start of event
        stroke( 0 , 0 , 1 );
        line( xc , yc + hc*t1 , xc + wc , yc + hc*t1 );
      }
    }
    
  }
  
  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: print                                                       
  //     returns a string output of events
  ///////////////////////////////////////////////////////////////////////////////
  String print() {
    String s = "Events: \n";
    for( int i = 0 ; i < events.size() ; i++ ) {
      s = s + " i:" + i + "  state:" + events.get(i).on + "  t:" + events.get(i).t + "\n" ;
    }
    return s;
  }
  

  
  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: triggerReset                                                       
  //     Sets resetTriggered
  ///////////////////////////////////////////////////////////////////////////////
  void triggerReset() {
    resetTriggered = true;
  } // end of METHOD: resetTriggered ////////////////////////////////////////////
  
  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: triggerToggle                                                       
  //     Toggles On flag
  ///////////////////////////////////////////////////////////////////////////////
  void triggerToggle() {
    onToggleTriggered = true;
  } // end of METHOD: resetTriggered ////////////////////////////////////////////

  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: triggerInput                                                       
  //     Sets inputTriggered and InputTriggerTime
  //     arguments:
  //       t: system time of evolution (int)
  ///////////////////////////////////////////////////////////////////////////////
  void triggerInput() {
    int t = millis();
    inputTriggered = true;
    inputTriggerTime = t;
  } // end of METHOD: triggerInput /////////////////////////////////////////////  
  
  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: clearInput                                                       
  //     Sets inputCleared and InputClearTime
  //     arguments:
  //       t: system time of evolution (int)
  ///////////////////////////////////////////////////////////////////////////////
  void clearInput() {
    int t = millis();
    inputCleared = true;
    inputClearTime = t;
  } // end of METHOD: clearInput /////////////////////////////////////////////
  
  
  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: reset                                                       
  //     resets the loop
  ///////////////////////////////////////////////////////////////////////////////
  void reset() {
    events.clear();
    this.inputTriggered = false;
    this.inputTriggerTime = 0;
    this.inputCleared = false;
    this.inputClearTime = 0;
    this.resetTriggered = false;
    this.lastEvolveTime = 0;
    this.full = false;
    this.inputOn = false;
  }
  
  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: evolve                                                       
  //     Evolves the event list
  //     arguments:
  //       t: system time of evolution (int)
  ///////////////////////////////////////////////////////////////////////////////
  void evolve( int tIn ) {
    // TYPE: all
    if( onToggleTriggered ) {
      // toggle value of on
      this.on = !this.on;
    }
    
    // TYPE: OnOff
    if( type == 0 ) {
      // only evolve if Metronome's beat has been established, and loop is not full
      if( M.beatEstablished && !full ) {
        // check status of resetTriggered
        if( true ) {
          // get measure time
          float t = M.measureTime( tIn );
          // check status of inputTriggered
          if( inputTriggered ) {
            // input has been triggered
            // set inputOn
            inputOn = true;
            // insert new On event at inputTriggerTime
            addEvent( true , t );
            // insert new Off event immediately after inputTriggerTime
            addEvent( false , (t + 0.00001)%1 );
          }
          
          // check status of inputCleared
          if( inputCleared ) {
            // input has been cleared
            // clear inputOn
            inputOn = false;
            // insert new Off event at inputClearTime
            addEvent( false , (t + 0.00001)%1 );
            // clean up event list
            cleanup();
          }
          
          // check status of inputOn
          if( inputOn ) {
            // input is on
            // check whether next event is On
            if( nextEvent( t ).on ) {
              // next event is On
              // insert a new Off event at this measure time
              addEvent( false , (t + 0.00001)%1 );
            }
            // check status of inputTriggered
            if( !inputTriggered ) {
              // this is not the first evolve with inputOn
              // remove any events between current time and lastEvolveTime
              removeEventsInRange( lastEvolveTime , t );
              if( float( tIn ) > float( inputTriggerTime ) + M.measureLength ) {
                full = true;
                println( "full set because float( tIn ) > float( inputTriggerTime ) + M.measureLength" );
              }
            }
            // clean up event list
            cleanup();
            // check if loop is full
            if( events.size() < 2 ) {
              full = true;
              println( "full set because events.size() < 2" );
            }
          }
          
          // set lastEvolveTime to this time
          lastEvolveTime = t; 
          // check status of full flag
          if( full ) {
            println( "Loop is full" );
            // the loop is full
            // clear the events list
            events.clear();
            // add an On event to beginning and off event to end
            addEvent( true , 0 );
            addEvent( false , 0.99999 );
          }     
        }
      }
    }
    
    // TYPE: "Timed"
    // only evolve if Metronome's beat is established
    if( type == 1 ) {
      if( this.M.beatEstablished ) {
        // check status of resetTriggered
        if( true ) {
          // get measure time
          float t = M.measureTime( tIn );
          // check status of inputTriggered
          if( inputTriggered ) {
            // input has been triggered
            // insert new On event at inputTriggerTime
            addEvent( true , t );
          }
        }
      }
    }
    
    if( resetTriggered ) {
      reset();
    }
    
    // clear all flags
    resetTriggered = false;
    onToggleTriggered = false;
    inputTriggered = false;
    inputCleared = false;
  } // end of METHOD: evolve ////////////////////////////////////////////////////
  
  //////////////////////////////////////////////////////////////////////////////
  // METHOD: cleanup
  //     Only used for type: "OnOff"
  //     Cleans up the event list. Gaurantees that:
  //       * there are no consecutive events of same type (On/Off)
  //       * if consecutive On: later is removed
  //       * if consecutive Off: first is removed
  ///////////////////////////////////////////////////////////////////////////////
  void cleanup() {
    boolean cleanupComplete = false;
    int i = 0;
    while( !cleanupComplete ) {
      // if there are less than two events, done cleaning up
      if( events.size() < 2 ) { cleanupComplete = true; }
      else {
        // there are at least two elements
        if( i == events.size() - 1 ) {
          // i is the index of the last event:
          if( !( events.get(i).on ^ events.get(0).on ) ) {
            // last and first events are the same, remove one
            if( events.get(i).on ) { events.remove( 0 ); }
            else { events.remove( i ); }
            // reset counter to 0 and try again
            i = 0;
          } else {
            // first and last elements are different.
            // cleanup is complete
            cleanupComplete = true;
          }
        } else {
          // there are at least two events, and i is not the last one
          if( !( events.get(i).on ^ events.get(i+1).on ) ) {
            // the (i)th and (i+1)th events are the same
            if( events.get(i).on ) { events.remove( i+1 ); }
            else { events.remove( i ); }
            // reset counter to 0 and try again
            i = 0;
          } else {
            // the (i)th and (i+1)th events are different
            // increment the counter and try the next pair
            i++;
          }
        }
      }
    }
  } // end of METHOD: cleanup ///////////////////////////////////////////////////
  
  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: nextEvent                                                       
  //      Returns the next event after the input measure time
  //      arguments:
  //         t: measure time (float)
  ///////////////////////////////////////////////////////////////////////////////  
  Event nextEvent( float t ) {
    if( t >= events.get( events.size() - 1 ).t ) {
      // if t is after the last event, return the first event
      return events.get( 0 );
    }
    // otherwise, t is less than at least one event
    int ind = 0;
    for( int i = events.size() - 1 ; i >=0  ; i-- ) {
      if( t < events.get(i).t ) { 
        ind = i; 
      }
    }
    return events.get( ind );
  } // end of METHOD: nextEvent
  
  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: removeEventsInRange                                                       
  //      Removes all events with time t such that  t1 <= t < t2
  //      arguments:
  //         t1: begin time (float)
  //         t2: end time (float
  ///////////////////////////////////////////////////////////////////////////////
  void removeEventsInRange( float t1In , float t2In ) {
    // get measure time for t1 and t2
    //float t1 = M.measureTime( t1In );
    //float t2 = M.measureTime( t2In );
    float t1 = t1In;
    float t2 = t2In;
    // create an empty IntList of indices of Events to be removed
    IntList ind = new IntList();
    // if range does not wrap to beginning of the loop
    if( t1 <= t2 ) {
      // parse through event list, and find events after t1 and before t2
      for( int i = 0 ; i < events.size() ; i++ ) {
        float t = events.get(i).t;
        if( t > t1 && t < t2 ) {
          ind.append( i );
        }
      }
    } else { 
      // range wraps to beginning of loop
      // parse through event list, find events after t1 or before t2
      for( int i = 0 ; i < events.size() ; i++ ) {
        
        float t = events.get(i).t;
        if( t > t1 || t < t2 ) {
          ind.append( i );
        }
      }
    }
    // working backwards through ind list, remove found events from events list
    for( int i = ind.size() - 1 ; i >=0 ; i-- ) {
      events.remove( ind.get(i) );
    }
  } // end of METHOD: removeEventsInRange ///////////////////////////////////////
  
  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: addEvent
  //      Adds an event to the list in the correct position  
  //      arguments:
  //         onIn: type of event (boolean)
  //         tIn: event time (float)
  ///////////////////////////////////////////////////////////////////////////////
  void addEvent( boolean onIn , float tIn ) {
    float t = tIn % 1;
    // if the event list is empty, add to list position 0
    if( events.size() == 0 ) {
      events.add( 0 , new Event( type , l , onIn , t , ch ) );
    } else {
      // if the arrayList is not empty...
      // if the arraylist has only one Event, add this Event before or after, as appropriate
      if( events.size() == 1 ) {
        if( t < events.get(0).t ) {
          events.add( 0 , new Event( type , l , onIn , t , ch ) );
        } else if( t > events.get(0).t ) {
          events.add( 1 , new Event( type , l , onIn , t , ch ) );
        }
      } else {
        // the event list must have more than one entry
        // check if new Event belongs at the beginning
        if( tIn < events.get(0).t ) {
          events.add( 0 , new Event( type , l ,  onIn , t , ch ) );
        }
        // check if new Event belongs at the end
        else if( tIn > events.get( events.size() - 1 ).t ) {
          events.add( events.size() , new Event( type , l , onIn , t , ch ) );
        }
        else {
          // the event belongs somewhere in the middle of the list
          for( int i = 0 ; i < events.size() - 1 ; i++ ) {
            // parse through consecutive pairs, and find where the event belongs
            if( tIn > events.get(i).t && tIn < events.get(i+1).t ) {
              events.add( i+1 ,  new Event( type , l , onIn , t , ch ) );
            }
          }
        }
      }
    }
    // Note that if the new event happens at the exact time as an existing event, the
    // new event is not added (event list is unchanged)
  } // end of METHOD: addEvent //////////////////////////////////////////////////
  
  
} // end of Class: ChannelLoop

// HELPER FUNCTIONS: ChannelLoop //////////////////////////////////////

// createChannelLoop
ChannelLoop createChannelLoop(  Metronome Min ,      // Metronome
                                int typeIn,       // type
                                int chIn,            // channel
                                color lineColorOnIn,  // colors
                                color lineColorOffIn,
                                color bgColorOnIn,
                                color bgColorOffIn,
                                color fillColorOnIn,
                                color fillColorOffIn
                                ) {
  ChannelLoop clOut =  new ChannelLoop( Min , typeIn , chIn );
  clOut.lineColorOn = lineColorOnIn;
  clOut.lineColorOff = lineColorOffIn;
  clOut.bgColorOn = bgColorOnIn;
  clOut.bgColorOff = bgColorOffIn;
  clOut.fillColorOn = fillColorOnIn;
  clOut.fillColorOff = fillColorOffIn;
  return clOut;
}

// createOnOffChannelLoop
ChannelLoop createOnOffChannelLoop( Metronome Min ,      // Metronome
                                    int chIn,
                                    color lineColorOnIn,
                                    color lineColorOffIn,
                                    color bgColorOnIn,
                                    color bgColorOffIn,
                                    color fillColorOnIn,
                                    color fillColorOffIn
                                    ) {
  ChannelLoop clOut =  new ChannelLoop( Min , 1 , chIn );
  clOut.lineColorOn = lineColorOnIn;
  clOut.lineColorOff = lineColorOffIn;
  clOut.bgColorOn = bgColorOnIn;
  clOut.bgColorOff = bgColorOffIn;
  clOut.fillColorOn = fillColorOnIn;
  clOut.fillColorOff = fillColorOffIn;
  return clOut;
}
// createTimedChannelLoop
ChannelLoop createTimedChannelLoop( Metronome Min ,      // Metronome
                                    int chIn,
                                    color lineColorOnIn,
                                    color lineColorOffIn,
                                    color bgColorOnIn,
                                    color bgColorOffIn,
                                    color fillColorOnIn,
                                    color fillColorOffIn
                                    ) {
  ChannelLoop clOut =  new ChannelLoop( Min , 1 , chIn );
  clOut.lineColorOn = lineColorOnIn;
  clOut.lineColorOff = lineColorOffIn;
  clOut.bgColorOn = bgColorOnIn;
  clOut.bgColorOff = bgColorOffIn;
  clOut.fillColorOn = fillColorOnIn;
  clOut.fillColorOff = fillColorOffIn;
  return clOut;
}


////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////
// Class: Event ///////////////////////////////
//////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////

class Event {
  // FIELDS //////////////////////////////////
  int type;              // type: 0 = onOff , 1 = timed 
  int l;                 // [0,4]: 0=whole, 1=half, 2=quarter, 3=eight, 4=sixteenth
                         // defaults to 0 if type is onOff(0)
  boolean on;            // is Event on-type?
  float t;               // time of event
  int ch;                // channel 
  
  
  // CONSTRUCTOR /////////////////////////////
  Event( int typeIn , int lIn , boolean onIn , float tIn , int chIn ) {
    this.type = typeIn;
    this.on = onIn;
    this.t = tIn;
    this.ch = chIn;
  }
  // recieve constructor
  Event( String in ) {
    int data[];
    data = int(split(in, ' '));
    if( data[0] == 0 ) { this.type = 0; }
    if( data[0] == 1 ) { this.type = 1; }
    if( data[1] == 0 ) { this.on = false; }
    if( data[1] == 1 ) { this.on = true; }
    this.t = 0.00000001*float( data[2] );
    this.ch = data[3];
  }
  
  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: clone                                                       
  //     returns a clone of the Event
  ///////////////////////////////////////////////////////////////////////////////
  Event clone() {
    return new Event( type , l , on , t , ch );
  }
  
  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: print                                                       
  //     returns a String of the Event
  ///////////////////////////////////////////////////////////////////////////////
  String print() {
    return "Event - type: " + type + "   on?: " + on + "   time: " + t + "   channel: " + ch ;
  }
  
  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: sendData                                                       
  //     returns a String of the Event, formatted for sending
  ///////////////////////////////////////////////////////////////////////////////
  String sendData() {
    // type
    int typeOut = 0;
    if( type == 0 )   { typeOut = 0; }
    if( type == 1 ) { typeOut = 1; }
    // on
    int onOut = 0;
    if( !on ) { onOut = 0; }
    else      { onOut = 1; }
    // time
    int tOut = floor( t *100000000 );
    // channel
    int chOut = ch;
    return typeOut + " " + onOut + " " + tOut + " " + chOut + "\n";
  }
  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: toByte                                                       
  //     returns a byte version of the event (currently type and time are not included)
  ///////////////////////////////////////////////////////////////////////////////
  byte toByte() {
    int cmd = 1;
    if( on ) { cmd = 2; }
    //println( 16*cmd + ch );
    return byte(16*cmd + ch );
  }
  
}