///////////////////////////////////////////////////////////////////////
// Class: SynthSliders                                                  //
///////////////////////////////////////////////////////////////////////
class SynthSliders {
  // FIELDS ///////////////////////////////////////////////////////////////////////
  float x;                // control position x
  float y;                // control position y
  float w;                // control size x
  float h;                // control size y
  float H;
  float S;
  float V;
  float A;
  Slider[] SL ;           // array of sliders: SL[0] = hue ; SL[1] = sat ; SL[2] = bri ; SL[3] = alpha
  boolean drawBGTriggered;

  // CONSTRUCTOR ////////////////////////////////////////////////////////////////
  SynthSliders( float xIn, float yIn, float wIn, float hIn ) {
    this.x = xIn;
    this.y = yIn;
    this.w = wIn;
    this.h = hIn;
    this.SL = new Slider[4];
    this.SL[0] = new Slider( x, y, w, h/3, 2.0/3 );
    this.SL[1] = new Slider( x, h/3, 0.5*w, h/3, 1 );
    this.SL[2] = new Slider( x + 0.5*w, h/3, 0.5*w, h/3, 1 );
    this.SL[3] = new Slider( x, 2*h/3, 0.5*w, h/3, 1 );
    this.drawBGTriggered = false;
    setHSVA();
  }
  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: setHSVA                                                       
  //     sets hue, saturation, value, alpha based on slider values
  ///////////////////////////////////////////////////////////////////////////////
  void setHSVA() {
    H = 360*SL[0].value;
    S = SL[1].value;
    V = SL[2].value;
    A = 255*SL[3].value;
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
    }
  }

  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: deactivate                                                       
  ///////////////////////////////////////////////////////////////////////////////
  void deactivate() {
    for ( int i = 0; i < 4; i++ ) {
      SL[i].deactivate();
    }
  }

  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: evolve                                                       
  ///////////////////////////////////////////////////////////////////////////////
  void evolve( float mx, float my ) {
    for ( int i = 0; i < 4; i++ ) {
      drawBGTriggered = SL[i].evolve( mx, my );
      if ( drawBGTriggered ) { 
        setHSVA();
      }
    }
    if ( drawBGTriggered ) { 
      setHSVA();
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
      if ( SL[i].drawTriggered ) {
        SL[i].draw();
      }
    }
  }
}