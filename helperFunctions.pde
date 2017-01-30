// HELPFUL FUNCTIONS

// hsvColor takes HSV inputs and convertes them to RGB
color hsvColor( float h , float s , float v , float a ) {
  float c = v*s;
  float x = c*( 1 - abs( (h/60) % 2 - 1 ) );
  float m = v - c;
  float rp = 0;
  float gp = 0;
  float bp = 0;
  if( 0 <= h && h < 60 ) {
    rp = c;  gp = x ; bp = 0;
  }
  if( 60 <= h && h < 120 ) {
    rp = x;  gp = c ; bp = 0;
  }
  if( 120 <= h && h < 180 ) {
    rp = 0;  gp = c ; bp = x;
  }
  if( 180 <= h && h < 240 ) {
    rp = 0;  gp = x ; bp = c;
  }
  if( 240 <= h && h < 300 ) {
    rp = x;  gp = 0 ; bp = c;
  }
  if( 300 <= h && h < 360 ) {
    rp = c;  gp = 0 ; bp = x;
  }
  return color( (rp+m)*255 , (gp+m)*255 , (bp+m)*255 , a );
}
color hsvColor( float h , float s , float v ) {
  return hsvColor( h , s , v , 255 );
}