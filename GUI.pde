


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
  void triggerInput( float mx, float my ) {
    if ( mx >= x && mx < x + w && my >= y && my < y + h ) {
      active = true;
      mxp = mx;
      myp = my;
      mx0 = mx;
      my0 = my;
      setValue( mx, my );
      drawTriggered = true;
    }
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




float GUIstrokeWeight = 2;
float GUIgap = 4;
color GUIselectColor;
color GUIunSelectColor;

void drawChannelButton( float x, float y, int s, color c, boolean active ) {
  GUIunSelectColor = color( 0, 0, 0.5 );
  GUIselectColor = color( 0, 0, 1 );
  float bg = 4;
  if ( active ) {
    strokeWeight( 6 );
    stroke( GUIselectColor );
    fill( GUIunSelectColor );
    bg += 1;
  } else {
    strokeWeight( 2 );
    stroke( GUIunSelectColor );
    noFill();
  }
  float cr = 10;
  rect( x + bg, y + bg, 80 - 2*bg, 110, cr, cr, 0, 0 );
  if ( active ) {
    noStroke();
    fill( c );
  } else {
    stroke( c );
    noFill();
  }
  strokeWeight( 8 );
  ellipse( x + 40, y + 40, 50, 50 );
  textAlign( CENTER, CENTER );
  if ( active ) {
    fill( 0, 0, 0 );
  } else {
    fill( GUIunSelectColor );
  }
  textSize( 25 );
  text( s, x + 40, y + 38 );
}

void drawSynthButton( float x, float y, int s, color c, boolean active ) {
  float bg = 4;
  if ( active ) {
    strokeWeight( 6 );
    stroke( GUIselectColor );
    fill( GUIunSelectColor );
    bg += 1;
  } else {
    strokeWeight( 2 );
    stroke( GUIunSelectColor );
    noFill();
  }
  float cr = 10;
  rect( x + bg, y + bg, 80 - 2*bg, 80 - 2*bg, cr, cr, cr, cr );
  if ( active ) {
    noStroke();
    fill( c );
  } else {
    stroke( c );
    noFill();
  }
  strokeWeight( 8 );
  ellipse( x + 40, y + 40, 50, 50 );
  textAlign( CENTER, CENTER );
  if ( active ) {
    fill( 0, 0, 0 );
  } else {
    fill( GUIunSelectColor );
  }
  textSize( 25 );
  text( s, x + 40, y + 38 );
}

void drawRecordButton( float x, float y, float w, float h ) {
  stroke( GUIunSelectColor );
  strokeWeight( GUIstrokeWeight );
  fill( 255, 0, 0 );
  rect( x + GUIstrokeWeight, y + GUIstrokeWeight, w - 1.5*GUIstrokeWeight, h - 2*GUIstrokeWeight, 0.1*w, 0.1*w, 0.1*w, 0.1*w );
  noStroke();
  fill( 192, 0, 0 );
  ellipse( x + 0.5*w, y + 0.5*h, 0.60*w, 0.60*h );
}

void drawChannelButtons( float xIn, float yIn, float wIn, float hIn ) {
  float x = xIn + GUIstrokeWeight;
  float y = yIn + GUIstrokeWeight;
  float w = wIn - 2*GUIstrokeWeight;
  float h = hIn - 2*GUIstrokeWeight;
  float bw = w/8 - GUIgap;
  stroke( GUIunSelectColor );
  strokeWeight( GUIstrokeWeight );
  fill( 0, 0, 255 );
  for ( int i = 0; i < 8; i++ ) {
    rect( x + 0.5*GUIgap + (bw + GUIgap)*i, y, bw, h  );
  }
}

void drawMenuButtons( float xIn, float yIn, float wIn, float hIn ) {
  float x = xIn + GUIstrokeWeight;
  float y = yIn + GUIstrokeWeight;
  float w = wIn - 2*GUIstrokeWeight;
  float h = hIn - 2*GUIstrokeWeight;
  float bh = h/4 - GUIgap;
  stroke( GUIunSelectColor );
  strokeWeight( GUIstrokeWeight );
  fill( 0, 0, 255 );
  for ( int i = 0; i < 4; i++ ) {
    rect( x, y + 0.5*GUIgap + (bh + GUIgap)*i, w, bh  );
  }
}