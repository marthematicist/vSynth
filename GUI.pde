




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