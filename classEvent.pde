//////////////////////////////////////////////
// Class: Event ///////////////////////////////
//////////////////////////////////////////////

class Event {
  // FIELDS //////////////////////////////////
  String type;            // type: "OnOff" or "OneTime"
  boolean on;            // is Event on-type?
  float t;               // time of event
  int ch;                // channel 
  
  
  // CONSTRUCTOR /////////////////////////////
  Event( String typeIn , boolean onIn , float tIn , int chIn ) {
    this.type = typeIn;
    this.on = onIn;
    this.t = tIn;
    this.ch = chIn;
  }
  // recieve constructor
  Event( String in ) {
    int data[];
    data = int(split(in, ' '));
    if( data[0] == 0 ) { this.type = "OnOff"; }
    if( data[0] == 1 ) { this.type = "OneTime"; }
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
    return new Event( type , on , t , ch );
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
    if( type == "OnOff" )   { typeOut = 0; }
    if( type == "OneTime" ) { typeOut = 1; }
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