boolean metaOn;

void keyPressed() {
  int t = millis();
  // METRONOME CONTROLS
  // trigger metronome input
  if (key == 'q') {
    M.triggerInput( t );
    M.sync( t );
  }
  // reset metronome
  if (key == 'w') {
    M.reset();
  }
  // metaOn flag
  if (key == 'a') { metaOn = true; }
  
  // LOOP CONTROLS
  // triggerInput
  if (key == 'x') { L.triggerInput( 0 , t ); }
  if (key == 'c') { L.triggerInput( 1 , t ); }
  if (key == 'v') { L.triggerInput( 2 , t ); }
  if (key == 'b') { L.triggerInput( 3 , t ); }
  if (key == 'n') { L.triggerInput( 4 , t ); }
  if (key == 'm') { L.triggerInput( 5 , t ); }
  if (key == ',') { L.triggerInput( 6 , t ); }
  if (key == '.') { L.triggerInput( 7 , t ); }
  // toggleOn
  if (key == 's' && !metaOn ) { L.toggleOn( 0 ); }
  if (key == 'd' && !metaOn ) { L.toggleOn( 1 ); }
  if (key == 'f' && !metaOn ) { L.toggleOn( 2 ); }
  if (key == 'g' && !metaOn ) { L.toggleOn( 3 ); }
  if (key == 'h' && !metaOn ) { L.toggleOn( 4 ); }
  if (key == 'j' && !metaOn ) { L.toggleOn( 5 ); }
  if (key == 'k' && !metaOn ) { L.toggleOn( 6 ); }
  if (key == 'l' && !metaOn ) { L.toggleOn( 7 ); }
  // triggerReset
  if (key == 's' && metaOn ) { L.triggerReset( 0 ); }
  if (key == 'd' && metaOn ) { L.triggerReset( 1 ); }
  if (key == 'f' && metaOn ) { L.triggerReset( 2 ); }
  if (key == 'g' && metaOn ) { L.triggerReset( 3 ); }
  if (key == 'h' && metaOn ) { L.triggerReset( 4 ); }
  if (key == 'j' && metaOn ) { L.triggerReset( 5 ); }
  if (key == 'k' && metaOn ) { L.triggerReset( 6 ); }
  if (key == 'l' && metaOn ) { L.triggerReset( 7 ); }
  
}
void keyReleased() {
  int t = millis();
  
  // metaOn flag
  if (key == 'a') { metaOn = false; }
  
  // LOOP CONTROLS
  // clearInput
  if (key == 'x') { L.clearInput( 0 , t ); }
  if (key == 'c') { L.clearInput( 1 , t ); }
  if (key == 'v') { L.clearInput( 2 , t ); }
  if (key == 'b') { L.clearInput( 3 , t ); }
  if (key == 'n') { L.clearInput( 4 , t ); }
  if (key == 'm') { L.clearInput( 5 , t ); }
  if (key == ',') { L.clearInput( 6 , t ); }
  if (key == '.') { L.clearInput( 7 , t ); }  

}