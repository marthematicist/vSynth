float GUIstrokeWeight = 2;
float GUIgap = 4;

void drawRecordButton( float x , float y , float w , float h ) {
  stroke( 128 , 128 , 128 );
  strokeWeight( GUIstrokeWeight );
  fill( 255 , 0 , 0 );
  rect( x + GUIstrokeWeight , y + GUIstrokeWeight , w - 1.5*GUIstrokeWeight , h - 2*GUIstrokeWeight , 0.1*w , 0.1*w , 0.1*w , 0.1*w );
  noStroke();
  fill( 192 , 0 , 0 );
  ellipse( x + 0.5*w , y + 0.5*h , 0.60*w , 0.60*h );
}

void drawChannelButtons( float xIn , float yIn , float wIn , float hIn ) {
  float x = xIn + GUIstrokeWeight;
  float y = yIn + GUIstrokeWeight;
  float w = wIn - 2*GUIstrokeWeight;
  float h = hIn - 2*GUIstrokeWeight;
  float bw = w/8 - GUIgap;
  stroke( 128 , 128 , 128 );
  strokeWeight( GUIstrokeWeight );
  fill( 0 , 0 , 255 );
  for( int i = 0 ; i < 8 ; i++ ) {
    rect( x + 0.5*GUIgap + (bw + GUIgap)*i , y , bw , h  );
  }
  
}

void drawMenuButtons( float xIn , float yIn , float wIn , float hIn ) {
  float x = xIn + GUIstrokeWeight;
  float y = yIn + GUIstrokeWeight;
  float w = wIn - 2*GUIstrokeWeight;
  float h = hIn - 2*GUIstrokeWeight;
  float bh = h/4 - GUIgap;
  stroke( 128 , 128 , 128 );
  strokeWeight( GUIstrokeWeight );
  fill( 0 , 0 , 255 );
  for( int i = 0 ; i < 4 ; i++ ) {
    rect( x  , y + 0.5*GUIgap + (bh + GUIgap)*i , w , bh  );
  }
}

void colorFun( float xIn , float yIn , float wIn , float hIn ) {
  float x = xIn ;
  float y = yIn ;
  float w = wIn ;
  float h = hIn ;
  float bw = w/128;
  noStroke();
  fill( 0 , 0 , 255 );
  for( int i = 0 ; i < 128 ; i++ ) {
    fill( hsvColor( 360*float(i)/128 , 1 , 1 , 255 ) );
    rect( x + (bw)*i , y , bw , h  );
  }
}