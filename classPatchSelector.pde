///////////////////////////////////////////////////////////////////////
// Class: PatchSelector                                             //
///////////////////////////////////////////////////////////////////////
class PatchSelector{ 
  PatchBay P;        
  int value;              // [0,16]: the currently selected patch, -1 if no patch selected
  int pValue;             // previous value
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
  float pw;               // patch size x
  float ph;               // patch size y
  color strokeColorActive;
  color strokeColorInActive;
  color fillColorSelected;
  color fillColorUnselected;
  boolean active;             // is control active?
  boolean drawAllTriggered;   // flag for redrawing entire PatchSelector
  boolean[] drawTriggered;    // array[16] of flags to redraw individual buttons
  
  // CONSTRUCTOR ////////////////////////////////////////////////////////////////
  PatchSelector( PatchBay Pin , float xIn, float yIn, float wIn, float hIn, int initValue ) {
    this.P = Pin;
    this.value = initValue;
    this.pValue = -1;
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
    this.pw = sw/8;
    this.ph = sh/2;
    this.strokeColorActive = color( 0, 0, 1 );
    this.strokeColorInActive = color( 0, 0, 0.5 );
    this.fillColorSelected = color( 0, 0, 0.5 );
    this.fillColorUnselected = color( 0, 0, 0.25 );
    this.active = false;
    this.drawAllTriggered = true;
    this.drawTriggered = new boolean[8];
    for( int i = 0 ; i < 8 ; i++ ) { drawTriggered[i] = false; }
  }
  
  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: evolve                                                       
  ///////////////////////////////////////////////////////////////////////////////
  void evolve( ) {
    if( P.selected < 8 ) {
      pValue = value;
      value = -1;
    }
  }
  
  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: triggerInput                                                       
  //     Checks input mouse position, and activates control if in bounds
  ///////////////////////////////////////////////////////////////////////////////
  boolean triggerInput( float mx, float my ) {
    if ( mx >= x && mx < x + w && my >= y && my < y + h ) {
      active = true;
      setValue( mx, my );
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
    }
  }

  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: setValue                                                       
  //     Checks input mouse position, and sets the value accordingly
  ///////////////////////////////////////////////////////////////////////////////
  void setValue( float mx, float my ) {
    pValue = value;
    for( int i = 0 ; i < 8 ; i++ ) {
      if( mx >= sx + i*pw && mx < sx + (i+1)*pw ) {
        if( my >= sy && my < sy + ph ) { 
          value = i; 
          P.setSelected( value + 8 );
        }
        if( my >= sy + ph && my <= sy + sh ) { 
          value = i + 8; 
          P.setSelected( value + 8 );
        }
      }
    }
  }
  
  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: draw                                                       
  //     Draws the PatchSelector
  ///////////////////////////////////////////////////////////////////////////////
  void draw() {
    drawAllTriggered = false;
    float cr = 10;
    noFill();
    strokeWeight( sWeight );
    if ( active ) { 
      stroke( strokeColorActive );
    } else { 
      stroke( strokeColorInActive );
    }
    //rect( x , y , w , h );
    rect( sx , sy, sw, sh, cr, cr, cr, cr );
    // draw patches
    for( int i = 0 ; i < 16 ; i++ ) {
      drawPatch( i );
    }
  }
  
  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: drawPatch                                                       
  //     Draws one patch with input index
  ///////////////////////////////////////////////////////////////////////////////
  void drawPatch( int ind ) {
    float cr = 8;
    // get color valuse from PatchBay P
    float ch = P.synths[ind].h;
    float cs = P.synths[ind].s;
    float cv = P.synths[ind].v;
    float ca = P.synths[ind].a;
    noFill();
    strokeWeight( sWeight );
    textAlign( CENTER , CENTER );
    textSize( 20 );
    float rx = sx + pw*( ind % 8 ) + gap;
    float ry = sy + ph*( ind / 8 ) + gap;
    float rw = pw - 2*gap;
    float rh = ph - 2*gap;
    // draw outer rectangle
    if ( ind == value ) { 
      stroke( strokeColorActive );
      strokeWeight( 3*sWeight );
    } else { 
      stroke( strokeColorInActive );
      noFill();
    }
    rect( rx , ry, rw, rh, cr, cr, cr, cr );
    // draw circle and number
    textSize( 30 );
    if( ind == value ) {
      // selected patch
      strokeWeight(2);
      stroke( ch , 1 , 1 , 255 );
      fill( ch , cs , cv , 255 );
      ellipse( rx + 0.5*rw , ry + 0.5*rh , 0.8*rw , 0.8*rh );
      textAlign( CENTER , CENTER );
      if( cv < 0.5 ) {
        fill( 0 , 0 , 1 );
      } else {
        fill( 0 , 0 , 0 );
      }
      text( ind , rx + 0.5*rw , ry + 0.45*rh );
    } else {
      strokeWeight( 0.1*rw );
      noFill();
      stroke( ch , cs , cv , 255 );
      ellipse( rx + 0.5*rw , ry + 0.5*rh , 0.8*rw , 0.8*rh );
      textAlign( CENTER , CENTER );
      fill( 0 , 0 , 0.6 );
      noStroke();
      text( ind , rx + 0.5*rw , ry + 0.45*rh );
    }
  }
}