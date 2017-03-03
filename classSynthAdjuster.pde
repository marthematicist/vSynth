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
  Slider HSL ;           // hue slider
  VSlider ASL;            // alpha slider
  LengthSelector LS;      // length selector
  SVPicker SVP;           // saturation value picker
  boolean drawTriggered;

  // CONSTRUCTOR ////////////////////////////////////////////////////////////////
  SynthAdjuster( PatchBay Pin , float xIn, float yIn, float wIn, float hIn ) {
    this.P = Pin;
    this.x = xIn;
    this.y = yIn;
    this.w = wIn;
    this.h = hIn;
    this.HSL = new Slider( x, y, 7.0/16*w, h/3, P.channels[P.selected].h );
    //this.ASL = new Slider( x + 0.5*w, h/3, 0.5*w, h/3, 1 );
    this.ASL = new VSlider( x + 7.0/16*w, y + 0*h/3, 1.0/16*w, 3*h/3, 1 - P.channels[P.selected].a );
    this.LS = new LengthSelector( P , x + 0.5*w , 2*h/3 , 0.5*w , h/3 , P.channels[P.selected].l );
    this.SVP = new SVPicker( x, h/3, 7.0/16*w, 2*h/3, P.channels[P.selected].s , 1 - P.channels[P.selected].v );
    this.drawTriggered = true;
    setHSVAL();
  }
  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: setHSVA                                                       
  //     sets hue, saturation, value, alpha based on slider values and length
  ///////////////////////////////////////////////////////////////////////////////
  void setHSVAL() {
    H = HSL.value;
    S = SVP.S;
    V = 1-SVP.V;
    A = (1-ASL.value);
    L = LS.value;
    HSL.drawTriggered = true;
    ASL.drawTriggered = true;
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
    P.drawTrigger[P.selected] = true;
  }

  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: triggerInput                                                       
  //     Checks input mouse position, and activates control if in bounds
  ///////////////////////////////////////////////////////////////////////////////
  void triggerInput( float mx, float my ) {
    if ( mx >= x && mx < x + w && my >= y && my < y + h ) {
      drawTriggered = true;
      HSL.triggerInput( mx, my );
      ASL.triggerInput( mx, my );
      LS.triggerInput( mx , my );
      SVP.triggerInput( mx , my );
      setHSVAL();
    }
  }

  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: deactivate                                                       
  ///////////////////////////////////////////////////////////////////////////////
  void deactivate() {
    HSL.deactivate();
    ASL.deactivate();
    LS.deactivate();
    SVP.deactivate();
  }

  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: evolve                                                       
  ///////////////////////////////////////////////////////////////////////////////
  void evolve( float mx, float my ) {
    if( SVP.evolve(mx,my) || HSL.evolve(mx,my) || ASL.evolve(mx,my) ) {
      drawTriggered = true;
      setHSVAL();
    }
    if( P.newSelection ) {
      P.newSelection = false;
      drawTriggered = true;
      if( P.selected < 8 ) {
        // channel 0-8
        S = P.channels[P.selected].s;
        V = P.channels[P.selected].v;
        A = P.channels[P.selected].a;
        L = P.channels[P.selected].l;
      } else {
        H = P.synths[P.selected-8].h;
        S = P.synths[P.selected-8].s;
        V = P.synths[P.selected-8].v;
        A = P.synths[P.selected-8].a;
        L = P.synths[P.selected-8].l;
      }
      HSL.value = H;
      ASL.value = 1-A;
      SVP.S = S;
      SVP.V = 1-V;
      LS.value = L;
    }
  }

  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: draw                                                       
  ///////////////////////////////////////////////////////////////////////////////
  void draw( ) {
    if ( drawTriggered ) {
      //println( "drawing SynthAdjuster " + frameCount );
      drawTriggered = false;
      int N = 32;
      int M = 16;
      float amt = 1.08;
      float w0 = HSL.sw / float(N);
      float h3 = ASL.sh / float(N);
      float svw = SVP.sw / float(N);
      float svh = SVP.sh / float(M);
      noStroke();
      fill( 0 , 0 , 0 );
      rect( x , y , w , h );
      fill( 0 , 0 , 1 );
      textAlign( CENTER , CENTER );
      textSize( 10 );
      text( "A\nL\nP\nH\nA" , ASL.sx + 0.5*ASL.sw , ASL.sy + 0.47*ASL.sh );
      for ( int i = 0; i < N; i++ ) {
        float a = float(i) / float(N);
        fill( a, 1, 1 );
        rect( HSL.sx + i*w0, HSL.sy + 0.35*HSL.sh, w0*amt, 0.3*HSL.sh );
        fill( H, S, V , (1-a) );
        rect( ASL.sx + 0.35*ASL.sw, ASL.sy +  i*h3, 0.3*ASL.sw , h3*amt );
        //rect( ASL.sx + i*w3, ASL.sy + 0.35*ASL.sh, w3, 0.3*ASL.sh );
        for( int m = 0 ; m < M ; m++ ) {
          float b = float(m) / float(M);
          fill( H , a , 1-b );
          rect( SVP.sx + i*svw , SVP.sy + m*svh , svw*amt , svh*amt );
        }
        
      }
     HSL.draw();
     ASL.draw();
     LS.draw();
     SVP.draw();
    }
  }
}



///////////////////////////////////////////////////////////////////////
// Class: LengthSelector                                             //
///////////////////////////////////////////////////////////////////////
class LengthSelector{ 
  PatchBay P;
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
  LengthSelector( PatchBay Pin , float xIn, float yIn, float wIn, float hIn, int initValue ) {
    this.P = Pin;
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
    P.selectedPatch().l = value;
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
    textSize( 15 );
    if ( active ) { 
      stroke( strokeColorActive );
    } else { 
      stroke( strokeColorInActive );
    }
    //rect( x , y , w , h );
    rect( sx , sy, sw, sh, cr, cr, cr, cr );
    
    if( P.selectedPatch().type == 0 ) {
      stroke( strokeColorActive );
      noFill();
      rect( sx + gap , sy + gap , sw - 2*gap , sh - 2*gap , cr , cr , cr , cr );
      fill( strokeColorActive );
      noStroke();
      text( "ON/OFF: LENGTH SET BY INPUT" , sx + 0.5*sw , sy + 0.5*sh );
    } else {
      
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

///////////////////////////////////////////////////////////////////////
// Class: VSlider                                                     //
///////////////////////////////////////////////////////////////////////
class VSlider {
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
  VSlider( float xIn, float yIn, float wIn, float hIn, float initValue ) {
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
    if ( my <= sy ) { 
      value = 0;
    }
    if ( my >= sy + sh ) {
      value = 1;
    }
    if ( my > sy && my < sy + sh ) { 
      value = ( my - sy ) / sh ;
    }
  }

  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: draw                                                       
  //     draws control
  ///////////////////////////////////////////////////////////////////////////////
  void draw( ) {
    drawTriggered = false;
    float cr = 5;
    noFill();
    strokeWeight( sWeight );
    if ( active ) { 
      stroke( strokeColorActive );
    } else { 
      stroke( strokeColorInActive );
    }
    rect( sx + 0.2*sw , sy , 0.6*sw, sh, cr, cr, cr, cr );
    float hd = 0.1*sw;
    float yd = sy + value*sh - 0.5*hd;
    stroke( strokeColorActive );
    fill( strokeColorInActive );
    rect( sx, yd, sw, hd, cr, cr, cr, cr );
  }

  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: evolve                                                       
  ///////////////////////////////////////////////////////////////////////////////
  boolean evolve( float mx, float my ) {
    if ( active && my != myp ) {
      setValue( mx, my );
      mxp = mx;
      myp = my;
      drawTriggered = true;
      return true;
    }
    return false;
  }
}

///////////////////////////////////////////////////////////////////////
// Class: SVPicker                                             //
///////////////////////////////////////////////////////////////////////
class SVPicker { 
  // FIELDS ///////////////////////////////////////////////////////////////////////
  float S;                // [0,1] saturation
  float V;                // [0,1] brightness
  float pS;              // prev S
  float pV ;             // prev V
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
  SVPicker( float xIn, float yIn, float wIn, float hIn, float SIn , float VIn ) {
    this.S = SIn;
    this.pS = SIn;
    this.V = VIn;
    this.pV = VIn;
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
    if( mx <= sx ) { S = 0; }
    if( mx >= sx + sw ) { S = 1; }
    if( my <= sy ) { V = 0; }
    if( my >= sy + sh ) { V = 1; }
    if ( mx > sx && mx < sx + sw  ) { 
      S = ( mx - sx ) / sw ;
    }
    if( my > sy && my < sy + sh ) {
      V = ( my - sy ) / sh ;
    }
  }

  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: draw                                                       
  //     draws control
  ///////////////////////////////////////////////////////////////////////////////
  void draw( ) {
    drawTriggered = false;
    float cr = 10;
    float ss = 10;
    noFill();
    strokeWeight( sWeight );
    if ( active ) { 
      stroke( strokeColorActive );
    } else { 
      stroke( strokeColorInActive );
    }
    //rect( x , y , w , h );
    rect( sx, sy, sw, sh );
    stroke( strokeColorActive );
    fill( 0 , 0 , 0 );
    ellipse( sx + S*sw , sy + V*sh , ss , ss );
  }

  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: evolve                                                       
  ///////////////////////////////////////////////////////////////////////////////
  boolean evolve( float mx, float my ) {
    if ( active && ( mx != mxp || my != myp ) ) {
      setValue( mx, my );
      mxp = mx;
      myp = my;
      drawTriggered = true;
      return true;
    }
    return false;
  }
}