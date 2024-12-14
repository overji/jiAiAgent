import {AudioPlayer} from '../utils/AudioPlayer';

// @Entry
@Component
struct AudioPlayer_Component{
  private audioPlayer:AudioPlayer = new AudioPlayer();
  build() {
    Button("nihao")
      .onClick(()=>{
        this.audioPlayer.avPlayerFdSrc();
      })
  }
}