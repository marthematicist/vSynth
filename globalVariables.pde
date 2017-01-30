PGraphics drawBuffer;

color bgColor = color( 0 , 0 , 0 , 255 );
float blockAlpha = 255;
color blockColor0 = color( 255 , 255 , 255 , blockAlpha );
color blockColor1 = color( 255 , 0 , 0 , blockAlpha );
color blockColor2 = color( 0 , 255 , 0 , blockAlpha );
color blockColor3 = color( 0 , 0 , 255 , blockAlpha );
color blockBorderColor = color( 128 , 128 , 128 , blockAlpha );

boolean blockTriggered0 = false;
boolean blockTriggered1 = false;
boolean blockTriggered2 = false;
boolean blockTriggered3 = false;

color beatColor = color( 128 , 0 , 255 , 255 );
boolean beatTriggered = false;

Metronome M;
ChannelLoop C;
Loop L;

int RAnum = 40;

Scene00 S00;