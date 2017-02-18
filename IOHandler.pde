////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////
// Class: InputHandler ///////////////////////
//////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////

class InputHandler {
  // FIELDS:
  Metronome M;
  Loop L;
  OutputHandler OH;
  int numChannels = 8;
  int[] lastKeyTime;
  boolean[] lastKeyState;
  int[] channelInputKeyCode = { 88 , 67 , 86 , 66 , 78 , 77 , 44 , 46 };
  int[] channelToggleKeyCode = { 83 , 68 , 70 , 71 , 72 , 74 , 75 , 76 };
  int loopRecordKeyCode = 16;
  int loopRecordToggleKeyCode = 90;
  int metaKeyCode = 65;
  int metronomeInputKeyCode = 81; 
  int metronomeResetKeyCode = 87;
  boolean[] channelInputStatus;
  boolean[] channelToggleStatus;
  boolean loopRecordStatus;
  boolean loopRecordToggleStatus;
  boolean metaStatus;
  boolean metronomeInputStatus;
  boolean metronomeResetStatus;

  
  InputHandler( Metronome Min , Loop Lin , OutputHandler OHin ) {
    this.M = Min;
    this.L = Lin;
    this.OH = OHin;
    this.lastKeyTime = new int[256];
    this.lastKeyState = new boolean[256];
    for( int i = 0 ; i < 256 ; i++ ) {
      lastKeyTime[i] = 0;
      lastKeyState[i] = false;
    }
    this.channelInputStatus = new boolean[numChannels];
    this.channelToggleStatus = new boolean[numChannels];
    for( int i = 0 ; i < numChannels ; i++ ) {
      this.channelInputStatus[i] = false;
      this.channelToggleStatus[i] = false;
    }
    this.loopRecordStatus = false;
    this.loopRecordToggleStatus = false;
    this.metaStatus = false;
    this.metronomeInputStatus = false;
    this.metronomeResetStatus = false;
  }
  
  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: receiveInput                                                       
  //     recieves an input and decides what to do with it
  ///////////////////////////////////////////////////////////////////////////////
  void recieveInput( int k , boolean on ) {
    int t = millis();
    // record-keeping
    lastKeyTime[k] = t;
    lastKeyState[k] = on;
    
    // CHANNEL INPUT RECEIVED
    for( int i = 0 ; i < numChannels ; i++ ) {
      if( k == channelInputKeyCode[i] ) {
        channelInputStatus[i] = on;
        // if loop controls are in record state, trigger the loop channel input or clear
        if( loopRecordStatus || loopRecordToggleStatus ) {
          if( on ) { L.triggerInput(i); }
          else     { L.clearInput(i); }
          // send an Event to the outputHandler
          OH.addEvent( new Event( L.cl[i].type , on , M.measureTime( t ) , i ) );
        } else {
          // loop is not recording, but if the channel is on, send an Event to the outputHandler
          if( L.cl[i].on ) {
            // send an Event to the outputHandler
            OH.addEvent( new Event( L.cl[i].type , on , M.measureTime( t ) , i ) );
          }
        }
      }
    }
    // CHANNEL TOGGLE RECEIVED
    for( int i = 0 ; i < numChannels ; i++ ) {
      if( k == channelToggleKeyCode[i] ) {
        channelToggleStatus[i] = on;
        if( on ) { 
          if( metaStatus ) {
            // if meta is on, clear the channel, and send an off event to outputHandler
            L.triggerReset(i);
            // send an off event to the output 
            OH.addEvent( new Event( L.cl[i].type , false , M.measureTime( t ) , i ) );
          } else {
            // if meta is not on, trigger the channel toggle
            L.triggerToggle(i);
            // if the channel just turned off, send an off event to the outputHandler
            if( !L.cl[i].on ) {
              // send an off event to the output 
              OH.addEvent( new Event( L.cl[i].type , false , M.measureTime( t ) , i ) );
            }
          }
        }
      }
    }
    // LOOP RECORD RECEIVED
    if( k == loopRecordKeyCode ) { 
      loopRecordStatus = on;
    }
    // LOOP RECORD TOGGLE RECIEVED
    if( k == loopRecordToggleKeyCode ) {
      if( on ) {
        loopRecordToggleStatus = !loopRecordToggleStatus;
      }
    }
    // META RECIEVED
    if( k == metaKeyCode ) {
      metaStatus = on;
    }
    // METRONOME INPUT RECEIVED
    if( k == metronomeInputKeyCode ) {
      metronomeInputStatus = on;
      if( on ) {
        // send an input trigger to the metronome
        M.triggerInput();
      }
    }
    // METRONOME RESET RECEIVED
    if( k == metronomeResetKeyCode ) {
      metronomeResetStatus = on;
      if( on ) {
        // send a reset trigger to the metronome
        M.triggerReset();
      }
    }
    
  }
  
}


////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
// Class: InputHandler ///////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
class OutputHandler {
  // FIELDS:
  Metronome M;
  Loop L;
  ArrayList<Event> events;
  boolean metronomeSyncTriggered;
  int lastLoopQueryTime;
  
  OutputHandler( Metronome Min , Loop Lin ) {
    this.M = Min;
    this.L = Lin;
    events = new ArrayList<Event>();
    this.metronomeSyncTriggered = false;
    this.lastLoopQueryTime = 0;
  }
  
  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: reset                                                       
  //     clears all events and triggers
  ///////////////////////////////////////////////////////////////////////////////  
  void reset() {
    events = new ArrayList<Event>();
    this.metronomeSyncTriggered = false;
  }
  
  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: sendAllEvents                                                       
  //     sends all events out of a server
  /////////////////////////////////////////////////////////////////////////////// 
  void sendAllEvents( Server sIn ) {
    // get all Events from Loop L
    getLoopEvents();
    // build a byte buffer
    byte[] bytebuffer = new byte[ events.size() ];
    for( int i = 0 ; i < events.size() ; i++ ) {
      bytebuffer[i] = events.get(i).toByte();
    }
    //bytebuffer[ events.size() ] = byte(0);
    // send out the byte buffer to the server
    sIn.write( bytebuffer );
    // reset the events list
    reset();
  }
  
  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: addEvent                                                       
  //     adds an Event to events, in the correct position
  ///////////////////////////////////////////////////////////////////////////////  
  void addEvent( Event e ) {
    // if events is empty, put e at beginning
    if( events.size() == 0 ) {
      events.add( 0 , e );
    } else {
      // there is at least one event
      //if e comes after the last event, append it to events
      if( e.t > events.get( events.size() - 1 ).t ) {
        events.add( e );
      } else {
        // e should be placed before one of the events
        int index = 0;
        // index will be the index of the latest event where e.t <= events.get( index ).t
        for( int i = 0 ; i < events.size() ; i++ ) {
          if( e.t <= events.get(i).t ) {
            index = i;
          }
        }
        // put e into events at index
        events.add( index , e );
      }
    }
  }
  
  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: getLoopEvents                                                       
  //     adds all Events from a Loop into events, in the correct position.
  //     Only Events between the current time and lastLoopQueryTime are added.
  //     lastLoopQueryTime is updated
  /////////////////////////////////////////////////////////////////////////////// 
  void getLoopEvents() {
    int t = millis();
    // get measureTimes for last loop query time and current time
    float mt1 = M.measureTime( lastLoopQueryTime );
    float mt2 = M.measureTime( t );
    // get all Events
    ArrayList<Event> loopEvents = L.getEvents( mt1 , mt2 );
    // add Events into events list
    for( int i = 0 ; i < loopEvents.size() ; i++ ) {
      addEvent( loopEvents.get(i) );
    }
    // set lasLoopQueryTime
    lastLoopQueryTime = t;
  }
}