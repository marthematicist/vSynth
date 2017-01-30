
class Metronome {
  boolean isOn;                // bool: outputting beats?
  boolean beatEstablished;     // has beat been established?
  boolean newBeatReady;
  boolean beatInitialized;
  float measureLength;             // measure length in ms
  RollingAverageInt RA;        // rolling average object
  float beatStartTime;         // time of beat start
  float beatEndTime;           // time measure will end
  float measureStartTime;      // time that current measure started
  float measureEndTime;        // time that current measure will end
  int lastInputTime;           // time of last input
  float minNextInput;          // earliest time next input will be accepted (if beatEstablished)
  float maxNextInput;          // latest time next input will be accepted (if beatEstablished)
  float inputThreshold;        // portion of measureLength before and after next predicted beat where input is accepted
  int measureCount;            // number of measures since beatEstablished
  int beat;
  float measureRatio;
  // constructor
  Metronome ( ) {
    this.isOn = true;
    this.beatEstablished = false;
    this.newBeatReady = false;
    this.beatInitialized = false;
    this.measureLength = 0;
    this.RA = new RollingAverageInt( RAnum );
    this.beatStartTime = 0;
    this.beatEndTime = 9999999.0;
    this.measureStartTime = 0;
    this.measureEndTime = 0;
    this.lastInputTime = 0;
    this.minNextInput = 0;
    this.maxNextInput = 999999999.0;
    this.inputThreshold = 0.4;
    this.beat = 0;
    this.measureCount = 0;
    this.measureRatio = 0;
    println( "mentronome initialized..." );
  }
  
  // METHOD: measureTime ///////////////////////////
  //     Returns float [0,1] of measure time
  //     arguments: t
  float measureTime( int tIn ) {
    float t = float( tIn );
    if( !beatEstablished ) {
      return 0;
    }
    if( t < measureStartTime ) {
      return 0;
    }
    return ( ( (t - measureStartTime) % measureLength ) ) / measureLength ;
  }
  
  void evolve ( int t ) {
    if( this.beatEstablished && float(t) > this.measureEndTime) {
      this.measureStartTime = this.measureEndTime;
      this.measureEndTime = this.measureStartTime + this.measureLength;
    }
    
    if( this.beatEstablished ) {
      this.measureRatio = ( float(t) - this.measureStartTime ) / this.measureLength;
      this.beat = floor( 4*this.measureRatio );
    } else {
      this.measureRatio = 0;
      this.beat = 0;
    } 
  }
  
  void triggerInput ( int t ) {
    // t is current time
    // if the beat is not yet established
    if( !this.beatEstablished || !this.newBeatReady ) {
      // if the input string is empty
      if( !beatInitialized ) {
        beatInitialized = true;
        println( "beat sync starting..." );
      } else {
        // else input string has 1 measure
        // include measure length in rolling average
        this.RA.addEntry( t - this.lastInputTime );
        // compute measure length
        this.measureLength = this.RA.ravg();
        // beat has been established
        this.beatEstablished = true;
        this.newBeatReady = true;
        // sync the beat
        this.sync( t );
        // set threshold for next input
        this.minNextInput = t + this.measureLength*( 1 - this.inputThreshold );
        this.maxNextInput = t + this.measureLength*( 1 + this.inputThreshold );
        println( "Beat established. BMP = " + 60000/(this.measureLength*0.25) );
      }
    } else {
      // otherwise, beat has been established
      // if the current input time is within threshold...
      if( t > this.minNextInput && t < this.maxNextInput ) {
        // include measure length in rolling average
        this.RA.addEntry( t - this.lastInputTime );
        // compute measure length
        this.measureLength = this.RA.ravg();
        println( "Beat modified.  BMP = " + 60000/(this.measureLength*0.25) + " ; num data points: " + this.RA.N );
      } 
      // set threshold for next input
      this.minNextInput = t + this.measureLength*( 1 - this.inputThreshold );
      this.maxNextInput = t + this.measureLength*( 1 + this.inputThreshold );
    }
    // set lastInputTime
    this.lastInputTime = t;
  }
  
  // method to sync beat to current time
  void sync ( int t ) {
    // t is current time
    // set current input time as beatStartTime
      this.measureStartTime = float( t );
      // calculate predicted end time
      this.measureEndTime = t + this.measureLength;
      this.beat = 0;
  }
  
  // method to reset the metronome
  void reset ( ) {
    this.isOn = true;
    this.newBeatReady = false;
    this.beatInitialized = false;
    this.RA = new RollingAverageInt( RAnum );
    this.lastInputTime = 0;
    this.minNextInput = 0;
    this.maxNextInput = 999999999;
    println( "resetting beat..." );
  }
  
  // metronome to return the current beat as a float [0 , 4)
  float beatFloat ( int t ) {
    if( this.beatEstablished ) {
      return float(this.beat) + (float(t)-this.beatStartTime)/(0.25*this.measureLength);
    } else {
      return 0;
    }
  }
  
  // method to draw the metronome
  void draw ( ) {
    if( this.beatEstablished ) {
      noStroke();
      if( this.beat == 0 ) {
        fill( blockColor0 );
        rect( xRes*0.00 , yRes*0.95 ,  xRes*0.05 , yRes*0.05 );
      }
      if( this.beat == 1 ) {
        fill( blockColor1 );
        rect( xRes*0.05 , yRes*0.95 ,  xRes*0.05 , yRes*0.05 );
      }
      if( this.beat == 2 ) {
        fill( blockColor2 );
        rect( xRes*0.10 , yRes*0.95 ,  xRes*0.05 , yRes*0.05 );
      }
      if( this.beat == 3 ) {
        fill( blockColor3 );
        rect( xRes*0.15 , yRes*0.95 ,  xRes*0.05 , yRes*0.05 );
      }
    }
  }
}



// maintains a rolling average of integer numbers
class RollingAverageInt {
  int N;         // number of entries
  int maxN;      // max number of entries
  IntList x;     // list of entries
  int s;         // sum of all entries
  
  RollingAverageInt ( int maxNin ) {
    this.maxN = maxNin;
    this.N = 0;
    this.x = new IntList();
    this.s = 0;
  }
  // method to include a new entry
  void addEntry( int xin ) {
    // append to x
    this.x.append( xin );
    this.N++;
    this.s += xin;
    // if there are too many entries, remove the oldest
    if( this.N > this.maxN ) {
      this.s -= x.remove( 0 );
      this.N--;
    }
  }
  // method to compute the rolling average
  float ravg () {
    return float( this.s ) / float( this.N );
    
  }
  
}