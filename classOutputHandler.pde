//////////////////////////////////////////////
// Class: InputHandler ///////////////////////
//////////////////////////////////////////////

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