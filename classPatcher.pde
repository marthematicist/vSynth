///////////////////////////////////////////////////////////////////////
// Class: Patcher                                             //
///////////////////////////////////////////////////////////////////////
class Patcher{ 
  PatchBay P;
  Loop L;
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
  color fillColor;
  boolean active;             // is control active?
  boolean drawTriggered;   // flag for redrawing entire PatchSelector
  
  // CONSTRUCTOR ////////////////////////////////////////////////////////////////
  Patcher( PatchBay Pin , Loop Lin , float xIn, float yIn, float wIn, float hIn ) {
    this.P = Pin;
    this.L = Lin;
    this.x = xIn;
    this.y = yIn;
    this.w = wIn;
    this.h = hIn;
    this.gap = 4;
    this.sWeight = 8;
    this.sx = x + gap;
    this.sy = y + gap;
    this.sw = w - 2*gap;
    this.sh = h - 2*gap;
    this.pw = sw/8;
    this.ph = sh;
    this.strokeColorActive = color( 0, 0, 0.5 );
    this.strokeColorInActive = color( 0, 0, 0.25 );
    this.fillColor = color( 0, 0, 0.25 );
    this.active = false;
    this.drawTriggered = true;
  }
  
  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: evolve                                                       
  ///////////////////////////////////////////////////////////////////////////////
  void evolve( ) {
    if( P.selected >=8 ) {
      if( !active ) { drawTriggered = true; }
      active = true; 
    } 
    else { 
      if( active ) { drawTriggered = true; }
      active = false; 
    }
  }
  
    
  ///////////////////////////////////////////////////////////////////////////////
  // METHOD: triggerInput                                                       
  //     Checks input mouse position, and activates control if in bounds
  ///////////////////////////////////////////////////////////////////////////////
  boolean triggerInput( float mx, float my ) {
    if( active ) {
      if ( mx >= x && mx < x + w && my >= y && my < y + h ) {
        for( int i = 0 ; i < 8 ; i++ ) {
          if( mx >= sx + i*pw && mx < sx + (i+1)*pw ) {
            if( my >= sy && my < sy + ph ) { 
              if( P.channels[i].type != P.synths[P.selected - 8].type ) {
                L.triggerReset( i );
              }
              P.channels[i].patchIn( P.synths[P.selected - 8] );
              P.channelRedraw = true;
              P.channelPatches[i] = P.selected - 8;
            }
          }
        }
        return true;
      }
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
  // METHOD: draw                                                       
  //     Draws the PatchSelector
  ///////////////////////////////////////////////////////////////////////////////
  void draw() {
    if( drawTriggered ) {
      println( "drawing Patcher" );
      drawTriggered = false;
      fill( 0 , 0 , 0 );
      noStroke();
      rect( x , y , w , h );
      strokeJoin( ROUND );
      float cr = 10;
      strokeWeight( sWeight );
      if ( active ) { 
        stroke( strokeColorActive );
        fill( fillColor );
      } else { 
        stroke( strokeColorInActive );
        noFill();
      }
      // draw patches
      for( int i = 0 ; i < 8 ; i++ ) {
        float xt = sx + i*pw + gap;
        float yt = sy;
        float wt = pw - 2*gap;
        float ht = ph;
        triangle( xt , yt , xt + wt , yt , xt + 0.5*wt , yt + ht );
      }
    }
  }
}