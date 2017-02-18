///////////////////////////////////////////////////////////////////////
// Class: SynthAdjuster                                      //
///////////////////////////////////////////////////////////////////////
class SynthAdjuster {
  // FIELDS ///////////////////////////////////////////////////////////////////////
  PatchBay P;
  float x;                // control position x
  float y;                // control position y
  float w;                // control size x
  float h;                // control size y
  float H;
  float S;
  float V;
  float A;
  int L;
  Slider[] SL ;           // array of sliders: SL[0] = hue ; SL[1] = sat ; SL[2] = bri ; SL[3] = alpha
  LengthSelector LS;      // length selector
  boolean drawBGTriggered;

  // CONSTRUCTOR ////////////////////////////////////////////////////////////////
  SynthAdjuster( PatchBay Pin , float xIn, float yIn, float wIn, float hIn ) {
    this.P = Pin;
    this.x = xIn;
    this.y = yIn;
    this.w = wIn;
    this.h = hIn;
    this.SL = new Slider[4];
    this.SL[0] = new Slider( x, y, w, h/3, 2.0/3 );
    this.SL[1] = new Slider( x, h/3, 0.5*w, h/3, 1 );
    this.SL[2] = new Slider( x + 0.5*w, h/3, 0.5*w, h/3, 1 );
    this.SL[3] = new Slider( x, 2*h/3, 0.5*w, h/3, 1 );
    this.LS = new LengthSelector( x + 0.5*w , 2*h/3 , 0.5*w , h/3 , 2 );
    this.drawBGTriggered = false;
    setHSVAL();
  }
  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: setHSVA                                                       
  //     sets hue, saturation, value, alpha based on slider values and length
  ///////////////////////////////////////////////////////////////////////////////
  void setHSVAL() {
    H = 360*SL[0].value;
    S = SL[1].value;
    V = SL[2].value;
    A = 255*SL[3].value;
    L = LS.value;
    SL[0].drawTriggered = true;
    SL[1].drawTriggered = true;
    SL[2].drawTriggered = true;
    SL[3].drawTriggered = true;
    LS.drawTriggered = true;
    if( P.selected < 8 ) {
      // channel 0-8
      P.channels[P.selected].h = H;
      P.channels[P.selected].s = S;
      P.channels[P.selected].v = V;
      P.channels[P.selected].a = A;
    } else {
      P.synths[P.selected-8].h = H;
      P.synths[P.selected-8].s = S;
      P.synths[P.selected-8].v = V;
      P.synths[P.selected-8].a = A;
    }
  }

  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: triggerInput                                                       
  //     Checks input mouse position, and activates control if in bounds
  ///////////////////////////////////////////////////////////////////////////////
  void triggerInput( float mx, float my ) {
    if ( mx >= x && mx < x + w && my >= y && my < y + h ) {
      for ( int i = 0; i < 4; i++ ) {
        SL[i].triggerInput( mx, my );
      }
      LS.triggerInput( mx , my );
      setHSVAL();
    }
  }

  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: deactivate                                                       
  ///////////////////////////////////////////////////////////////////////////////
  void deactivate() {
    for ( int i = 0; i < 4; i++ ) {
      SL[i].deactivate();
      LS.deactivate();
    }
  }

  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: evolve                                                       
  ///////////////////////////////////////////////////////////////////////////////
  void evolve( float mx, float my ) {
    for ( int i = 0; i < 4; i++ ) {
      drawBGTriggered = SL[i].evolve( mx, my );
      if ( drawBGTriggered ) { 
        setHSVAL();
      }
    }
    if( P.selected != P.prevSelected ) {
      if( P.selected < 8 ) {
        // channel 0-8
        H = P.channels[P.selected].h;
        S = P.channels[P.selected].s;
        V = P.channels[P.selected].v;
        A = P.channels[P.selected].a;
      } else {
        println( P.selected-8 );
        H = P.synths[P.selected-8].h;
        S = P.synths[P.selected-8].s;
        V = P.synths[P.selected-8].v;
        A = P.synths[P.selected-8].a;
      }
      SL[0].value = H/360;
      SL[1].value = S;
      SL[2].value = V;
      SL[3].value = A/255;
    }
  }

  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: draw                                                       
  ///////////////////////////////////////////////////////////////////////////////
  void draw( ) {
    if ( true ) {
      drawBGTriggered = false;
      int N = 64;
      for ( int i = 0; i < N; i++ ) {
        float a = float(i) / float(N);
        float w0 = SL[0].sw / float(N);
        noStroke();
        strokeWeight(0);
        fill( 360*a, 1, 1 );
        rect( SL[0].sx + a*SL[0].sw, SL[0].sy + 0.35*SL[0].sh, w0, 0.3*SL[0].sh );
        w0 *= 0.5;
        fill( H, a, V );
        rect( SL[1].sx + a*SL[1].sw, SL[1].sy + 0.35*SL[1].sh, w0, 0.3*SL[1].sh );
        fill( H, S, a );
        rect( SL[2].sx + a*SL[2].sw, SL[2].sy + 0.35*SL[2].sh, w0, 0.3*SL[1].sh );
        fill( H, S, V, a*255 );
        rect( SL[3].sx + a*SL[3].sw, SL[3].sy + 0.35*SL[3].sh, w0, 0.3*SL[3].sh );
      }
    }

    for ( int i = 0; i < 4; i++ ) {
      SL[i].draw();
      LS.draw();
    }
  }
}

///////////////////////////////////////////////////////////////////////
// Class: LengthSelector                                             //
///////////////////////////////////////////////////////////////////////
class LengthSelector{ 
  int value;             // [0,4]: 0=whole, 1=half, 2=quarter, 3=eight, 4=sixteenth
  int pValue;            // previous value
  float x;                // control position x
  float y;                // control position y
  float w;                // control size x
  float h;                // control size y
  float sWeight;          // draw strokeWeight
  float gap;              // draw gap (pixels)
  float sx;               // selector position x
  float sy;               // selector position y
  float sw;               // selector size x
  float sh;               // selector size y
  color strokeColorActive;
  color strokeColorInActive;
  color fillColorSelected;
  color fillColorUnselected;
  boolean active;
  boolean drawTriggered;
  
  // CONSTRUCTOR ////////////////////////////////////////////////////////////////
  LengthSelector( float xIn, float yIn, float wIn, float hIn, int initValue ) {
    this.value = initValue;
    this.pValue = initValue;
    this.x = xIn;
    this.y = yIn;
    this.w = wIn;
    this.h = hIn;
    this.gap = 4;
    this.sWeight = 2;
    this.sx = x + gap;
    this.sy = y + gap;
    this.sw = w - 2*gap;
    this.sh = h - 2*gap;
    this.strokeColorActive = color( 0, 0, 1 );
    this.strokeColorInActive = color( 0, 0, 0.5 );
    this.fillColorSelected = color( 0, 0, 0.5 );
    this.fillColorUnselected = color( 0, 0, 0.25 );
    this.active = false;
    this.drawTriggered = true;
  }
  
  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: triggerInput                                                       
  //     Checks input mouse position, and activates control if in bounds
  ///////////////////////////////////////////////////////////////////////////////
  boolean triggerInput( float mx, float my ) {
    if ( mx >= x && mx < x + w && my >= y && my < y + h ) {
      active = true;
      setValue( mx, my );
      drawTriggered = true;
      return true;
    }
    return false;
  }
  
  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: deactivate                                                       
  ///////////////////////////////////////////////////////////////////////////////
  void deactivate() {
    if ( active ) {
      active = false;
      drawTriggered = true;
    }
  }

  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: setValue                                                       
  //     Checks input mouse position, and sets the value accordingly
  ///////////////////////////////////////////////////////////////////////////////
  void setValue( float mx, float my ) {
    pValue = value;
    for( int i = 0 ; i < 5 ; i++ ) {
      if( mx > sx + float(i)/5 * sw ) { 
        value = i;
      }
    }
  }
  
  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: draw                                                       
  //     draws control
  ///////////////////////////////////////////////////////////////////////////////
  void draw( ) {
    drawTriggered = false;
    float cr = 10;
    noFill();
    strokeWeight( sWeight );
    textAlign( CENTER , CENTER );
    textSize( 20 );
    if ( active ) { 
      stroke( strokeColorActive );
    } else { 
      stroke( strokeColorInActive );
    }
    //rect( x , y , w , h );
    rect( sx , sy, sw, sh, cr, cr, cr, cr );
    
    if( value == 0 ) { fill( fillColorSelected ); stroke( strokeColorActive ); }
    else             { fill( fillColorUnselected ); stroke( strokeColorInActive ); }
    rect( sx + gap , sy + gap , 0.2*sw - 2*gap , sh - 2*gap , cr , 0 , 0 , cr );
    if( value == 0 ) { fill( strokeColorActive ); }
    else             { fill( strokeColorInActive ); }
    text( "1" , sx + 0.1*sw , sy + 0.5*sh );
    
    if( value == 1 ) { fill( fillColorSelected ); stroke( strokeColorActive ); }
    else             { fill( fillColorUnselected ); stroke( strokeColorInActive ); }
    rect( sx + 0.2*sw + gap , sy + gap , 0.2*sw - 2*gap , sh - 2*gap );
    if( value == 1 ) { fill( strokeColorActive ); }
    else             { fill( strokeColorInActive ); }
    text( "1/2" , sx + 0.3*sw , sy + 0.5*sh );
    
    if( value == 2 ) { fill( fillColorSelected ); stroke( strokeColorActive ); }
    else             { fill( fillColorUnselected ); stroke( strokeColorInActive ); }
    rect( sx + 0.4*sw + gap , sy + gap , 0.2*sw - 2*gap , sh - 2*gap );
    if( value == 2 ) { fill( strokeColorActive ); }
    else             { fill( strokeColorInActive ); }
    text( "1/4" , sx + 0.5*sw , sy + 0.5*sh );
    
    if( value == 3 ) { fill( fillColorSelected ); stroke( strokeColorActive ); }
    else             { fill( fillColorUnselected ); stroke( strokeColorInActive ); }
    rect( sx + 0.6*sw + gap , sy + gap , 0.2*sw - 2*gap , sh - 2*gap );
    if( value == 3 ) { fill( strokeColorActive ); }
    else             { fill( strokeColorInActive ); }
    text( "1/8" , sx + 0.7*sw , sy + 0.5*sh );
    
    if( value == 4 ) { fill( fillColorSelected ); stroke( strokeColorActive ); }
    else             { fill( fillColorUnselected ); stroke( strokeColorInActive ); }
    rect( sx + 0.8*sw + gap , sy + gap , 0.2*sw - 2*gap , sh - 2*gap , 0 , cr , cr , 0 );
    if( value == 4 ) { fill( strokeColorActive ); }
    else             { fill( strokeColorInActive ); }
    text( "1/16" , sx + 0.9*sw , sy + 0.5*sh );
  }
  
  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: evolve                                                       
  ///////////////////////////////////////////////////////////////////////////////
  boolean evolve( float mx, float my ) {
    return false;
  }
}



///////////////////////////////////////////////////////////////////////
// Class: Slider                                                     //
///////////////////////////////////////////////////////////////////////
class Slider {
  // FIELDS ///////////////////////////////////////////////////////////////////////
  float value;            // [0,1]
  float pValue;           // previous value
  float x;                // control position x
  float y;                // control position y
  float w;                // control size x
  float h;                // control size y
  float sWeight;          // draw strokeWeight
  float gap;              // draw gap (pixels)
  float sx;               // slider position x
  float sy;               // slider position y
  float sw;               // slider size x
  float sh;               // slider size y
  color strokeColorActive;
  color strokeColorInActive;
  boolean active;
  boolean drawTriggered;
  float mx0;               // initial mouse position x
  float my0;               // initial mouse position y
  float mxp;               // previous mouse position x
  float myp;               // previous mouse position y

  // CONSTRUCTOR ////////////////////////////////////////////////////////////////
  Slider( float xIn, float yIn, float wIn, float hIn, float initValue ) {
    this.value = initValue;
    this.pValue = initValue;
    this.x = xIn;
    this.y = yIn;
    this.w = wIn;
    this.h = hIn;
    this.gap = 4;
    this.sWeight = 2;
    this.sx = x + gap;
    this.sy = y + gap;
    this.sw = w - 2*gap;
    this.sh = h - 2*gap;
    this.strokeColorActive = color( 0, 0, 1 );
    this.strokeColorInActive = color( 0, 0, 0.5 );
    this.active = false;
    this.drawTriggered = true;
    this.mx0 = 0;
    this.my0 = 0;
    this.mxp = 0;
    this.myp = 0;
  }

  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: triggerInput                                                       
  //     Checks input mouse position, and activates control if in bounds
  ///////////////////////////////////////////////////////////////////////////////
  boolean triggerInput( float mx, float my ) {
    if ( mx >= x && mx < x + w && my >= y && my < y + h ) {
      active = true;
      mxp = mx;
      myp = my;
      mx0 = mx;
      my0 = my;
      setValue( mx, my );
      drawTriggered = true;
      return true;
    }
    return false;
  }

  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: deactivate                                                       
  ///////////////////////////////////////////////////////////////////////////////
  void deactivate() {
    if ( active ) {
      active = false;
      drawTriggered = true;
    }
  }

  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: setValue                                                       
  //     Checks input mouse position, and sets the value accordingly
  ///////////////////////////////////////////////////////////////////////////////
  void setValue( float mx, float my ) {
    if ( mx <= sx ) { 
      value = 0;
    }
    if ( mx >= sx + sw ) {
      value = 1;
    }
    if ( mx > sx && mx < sx + sw ) { 
      value = ( mx - sx ) / sw ;
    }
  }

  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: draw                                                       
  //     draws control
  ///////////////////////////////////////////////////////////////////////////////
  void draw( ) {
    drawTriggered = false;
    float cr = 10;
    noFill();
    strokeWeight( sWeight );
    if ( active ) { 
      stroke( strokeColorActive );
    } else { 
      stroke( strokeColorInActive );
    }
    //rect( x , y , w , h );
    rect( sx, sy + 0.2*sh, sw, 0.6*sh, cr, cr, cr, cr );
    float wd = 0.1*sh;
    float xd = sx + value*sw - 0.5*wd;
    stroke( strokeColorActive );
    fill( strokeColorInActive );
    rect( xd, sy, wd, sh, cr, cr, cr, cr );
  }

  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: evolve                                                       
  ///////////////////////////////////////////////////////////////////////////////
  boolean evolve( float mx, float my ) {
    if ( active && mx != mxp ) {
      setValue( mx, my );
      mxp = mx;
      myp = my;
      drawTriggered = true;
      return true;
    }
    return false;
  }
}