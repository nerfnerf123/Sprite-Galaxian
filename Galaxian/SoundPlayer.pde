
import ddf.minim.*; // Import Sound Library

class SoundPlayer {
  Minim minimplay;
  AudioSample boomPlayer, popPlayer, cranberryPlayer;
  
  AudioSample[] spriteCranberrySFX;
  AudioPlayer songPlayer;


  SoundPlayer(Object app) {
    minimplay = new Minim(app); 
    boomPlayer = minimplay.loadSample("explode.wav", 1024); 
    popPlayer = minimplay.loadSample("pop.wav", 1024);
    cranberryPlayer = minimplay.loadSample("pop.wav", 1024);
    
    AudioSample queryPlayer = minimplay.loadSample("lebron noises/i have just one query.wav", 1024);
    AudioSample wannaPlayer = minimplay.loadSample("lebron noises/wanna sprite cranberry.wav", 1024);
    AudioSample clearPlayer = minimplay.loadSample("lebron noises/the answer is clear.wav", 1024);
    AudioSample thirstyPlayer = minimplay.loadSample("lebron noises/thirsty.wav", 1024);
    spriteCranberrySFX = new AudioSample[] {queryPlayer, wannaPlayer, clearPlayer, thirstyPlayer};
    
    songPlayer = minimplay.loadFile("song.mp3");
  }

  void playExplosion() {
    boomPlayer.trigger();
  }

  void playPop() {
    popPlayer.trigger();
  }
  
  void playCranberry() {
    cranberryPlayer.trigger();
  }
  
  void playSong(){
    songPlayer.loop();
  }
  
  void stopSong(){
    songPlayer.pause();
  }
  
  
  void playRandomSFX(){
    int choice = (int)(random(spriteCranberrySFX.length));
    spriteCranberrySFX[choice].trigger();
  }
  
  int index = 0;
  void playOrderedSFX(){
    spriteCranberrySFX[index].trigger();
    
    index = (index+1) % spriteCranberrySFX.length;
  }
}
