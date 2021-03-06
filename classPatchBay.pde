////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////
// Class: PatchBay ///////////////////////
//////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////

class PatchBay {
  int selected;              // channel:[0-7] , synth: [8-23]
  int prevSelected;          // previously selected
  Patch[] channels;          // array[8] of channel Patches
  Patch[] synths;            // array[16] of synth Patches
                             // synths[0:7] are type onOff
                             // synths[8:15] are type Timed
  int[] channelPatches;      // array[8] of int
                             // for each channel, the synth that is patched
  boolean[] channelOn;       // for each channel, is it on (loop)
  boolean[] drawTrigger;     // array of flags to trigger element redraw: channel[0-7] , synth[8-23]
  boolean newSelection;      // flag that gets set when a new selection is made (cleared by SynthAdjuster)
  boolean synthRedraw;       // trigger to redraw synths
  boolean channelRedraw;     // trigger to redraw channels
  
  
  // CONSTRUCTOR ///////////////////////////////////////////////////////////////
  PatchBay() {
    this.selected = 0;
    this.prevSelected = 0;
    this.channels = new Patch[8];
    this.synths = new Patch[16];
    this.channelPatches = new int[8];
    this.channelOn = new boolean[8];
    this.drawTrigger = new boolean[24];
    this.newSelection = true;
    this.synthRedraw = true;
    this.channelRedraw = true;
    for( int i = 0 ; i < 8 ; i++ ) {
      // initialize OnOff synths
      this.synths[i] = new Patch( 0 );
      // initialize Timed synths
      this.synths[i+8] = new Patch( 1 );
      // initialize channels (will be over-written in next loop)
      this.channels[i] = new Patch( 0 );
      this.channelOn[i] = true;
      this.drawTrigger[i] = true;
      this.drawTrigger[i+8] = true;
      this.drawTrigger[i+16] = true;
    }
    for( int i = 0 ; i < 4 ; i++ ) {
      // patch synths[0-3] to channels[0-3]
      this.channels[i].patchIn( this.synths[i] );
      this.channelPatches[i] = i;
      // patch synths[81] to channels[4-8]
      this.channels[i+4].patchIn( this.synths[i+8] );
      this.channelPatches[i+4] = i+8;
    }
  }
  
  
  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: triggerDrawSynth                                                   
  //     sets flag to redraw synth with index ind
  ///////////////////////////////////////////////////////////////////////////////
  void triggerDrawSynth( int ind ) {
    drawTrigger[ind+8] = true;
  }
  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: triggerDrawChannel                                                   
  //     sets flag to redraw channel with index ind
  ///////////////////////////////////////////////////////////////////////////////
  void triggerDrawChannel( int ind ) {
    drawTrigger[ind] = true;
  }
  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: clearDrawSynth                                                   
  //     clears flag to redraw synth with index ind
  ///////////////////////////////////////////////////////////////////////////////
  void clearDrawSynth( int ind ) {
    drawTrigger[ind+8] = false;
  }
  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: clearDrawChannel                                                   
  //     clears flag to redraw channel with index ind
  ///////////////////////////////////////////////////////////////////////////////
  void clearDrawChannel( int ind ) {
    drawTrigger[ind] = false;
  }
  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: drawFlagSynth                                                   
  //     clears flag to redraw channel with index ind
  ///////////////////////////////////////////////////////////////////////////////
  boolean drawFlagSynth( int ind ) {
    return drawTrigger[ind+8];
  }
  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: drawFlagChannel                                                   
  //     clears flag to redraw channel with index ind
  ///////////////////////////////////////////////////////////////////////////////
  boolean drawFlagChannel( int ind ) {
    return drawTrigger[ind];
  }
  
  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: setSelected                                                   
  //     sets selected to input ind
  ///////////////////////////////////////////////////////////////////////////////
  void setSelected( int ind ) {
    newSelection = true;
    prevSelected = selected;
    selected = ind;
    //if( prevSelected < 8 && selected >=8 || prevSelected >=8 && selected < 8 ) {
      synthRedraw = true;
      channelRedraw = true;
   // }
  }
  
  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: patchSelectedToChannel                                                   
  //     patches the selected synth to the channel with input index
  //     does nothing if a channel is selected
  ///////////////////////////////////////////////////////////////////////////////
  void patchSelectedToChannel( int channelIndex ) {
    if( selected > 7 ) {
      channels[channelIndex].patchIn( synths[selected-9] );
      channelRedraw = true;
    }
  }
  
  //////////////////////////////////////////////////////////////////////////////
  // METHOD: getSynthColor                                                       
  //     returns patch color (HSV)
  ///////////////////////////////////////////////////////////////////////////////
  color getSynthColor( int ind ) {
    return( color( synths[ind].h , synths[ind].s , synths[ind].v , synths[ind].a ) );
  }
  
  //////////////////////////////////////////////////////////////////////////////
  // METHOD: selectedPatch                                                       
  //     returns selected patch
  ///////////////////////////////////////////////////////////////////////////////
  Patch selectedPatch( ) {
    if( selected < 8 ) {
      return channels[selected];
    } else {
      return synths[selected-8];
    }
    
  }
  
  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: triggerToggle                                                       
  //     Toggles On flag
  ///////////////////////////////////////////////////////////////////////////////
  void triggerToggle( int c ) {
    channelOn[c] = !channelOn[c];
  }
}

////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////
// Class: Patch ///////////////////////
//////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////

class Patch {
  int type;              // 0 = onOff , 1 = timed 
  float h;               // hue [0,360]
  float s;               // saturation [0,1]
  float v;               // brightness [0,1]
  float a;               // alpha [0,255]
  int l;                 // [0,4]: 0=whole, 1=half, 2=quarter, 3=eight, 4=sixteenth
  
  // CONSTRUCTORS ///////////////////////////////////////////////////////////////////////
  Patch( int typeIn , float hIn , float sIn , float vIn , float aIn , int lIn ) {
    this.type = typeIn;
    this.h = hIn;
    this.s = sIn;
    this.v = vIn;
    this.a = aIn;
    this.l = lIn;
  }
  
  Patch( int typeIn  ) {
    this.type = typeIn;
    this.h = random(0,1);
    this.s =  random(0.8,1);
    this.v = random(0.8,1);
    this.a = 1;
    if( type == 0 ) { this.l = 0; }
    if( type == 1 ) { this.l = 2; }
  }
  
  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: patchIn                                                       
  //     copies input Patch's parameters to this one
  ///////////////////////////////////////////////////////////////////////////////
  void patchIn( Patch p ) {
    type = p.type;
    h = p.h;
    s = p.s;
    v = p.v;
    a = p.a;
    l = p.l;
  }
  
  //////////////////////////////////////////////////////////////////////////////
  // METHOD: getColor                                                       
  //     returns patch color (HSV)
  ///////////////////////////////////////////////////////////////////////////////
  color getColor() {
    return( color( h , s , v , a ) );
  }
}