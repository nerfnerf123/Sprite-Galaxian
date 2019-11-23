
import ddf.minim.*; // Import Sound Library

class SoundPlayer {
  Minim minimplay;
  AudioSample boomPlayer, popPlayer, cranberryPlayer;
  AudioSample oneUpPlayer, firePlayer, clickPlayer;
  AudioPlayer songPlayer;
  private boolean isPlaying = false;


  SoundPlayer(Object app) {
    minimplay = new Minim(app); 
    boomPlayer = minimplay.loadSample("explode.wav", 1024); 
    popPlayer = minimplay.loadSample("pop.wav", 1024);
    cranberryPlayer = minimplay.loadSample("drincc.wav", 1024);
    oneUpPlayer = minimplay.loadSample("1up.wav", 1024);
    firePlayer = minimplay.loadSample("fire.wav", 1024);
    clickPlayer = minimplay.loadSample("clicc.wav", 1024);
    
    songPlayer = minimplay.loadFile("song.mp3");
  }

  void playExplosion() {
    boomPlayer.trigger();
  }

  void playPop() {
    //popPlayer.trigger();
  }
  
  void playCranberry() {
    cranberryPlayer.trigger();
  }
  
  void play1Up(){
    oneUpPlayer.trigger();
  }
  
  void playFire(){
    firePlayer.trigger();
  }
  
  void playSong(){
    songPlayer.loop();
    isPlaying = true;
  }
  
  void stopSong(){
    songPlayer.pause();
    isPlaying = false;
  }

  void playClick(){
    clickPlayer.trigger();
  }
  
  void toggleSong(){
    playClick();
    if(isPlaying){
      stopSong();
    }else{
      playSong();
    }
  }
  
  
}
