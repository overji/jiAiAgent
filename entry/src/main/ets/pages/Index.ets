import {AudioPlayer} from '../utils/AudioPlayer';
import {AudioRecorder} from '../utils/AudioRecorder';
import {ApiText2Speech} from '../utils/textToSpeech';
import {ApiSpeechToText} from '../utils/speechToText'
import { emitter } from '@kit.BasicServicesKit';

@Entry
@Component
struct Index{
  @State private start:boolean = false;
  @State private startRecord:boolean = false;
  @State private pauseRecord:boolean = false;
  @State private speechText:string = "hello";
  private audioPlayer:AudioPlayer = new AudioPlayer();
  private audioRecorder:AudioRecorder = new AudioRecorder();
  private text2Speech:ApiText2Speech = new ApiText2Speech();

  build() {
    Column(){
      ApiSpeechToText()
        .height("25%");
      Button((this.startRecord)?"结束录音":"开始录音")
        .onClick(()=> {
          if (this.startRecord) {
            this.audioRecorder.stopAudioRecorder();
          } else {
            this.audioRecorder.startAudioRecorder();
          }
          this.startRecord = !this.startRecord;
        });
      if(this.startRecord){
        Button((this.pauseRecord)?"重启录音":"暂停录音")
          .onClick(()=>{
            if(this.pauseRecord){
              this.audioRecorder.resumeAudioRecorder();
            } else {
              this.audioRecorder.pauseAudioRecorder();
            }
            this.pauseRecord = !this.pauseRecord;
          })
      }
      Button((this.start)?"点我暂停":"点我开始播放")
        .onClick(()=>{
          if(this.start)
          {
            this.audioPlayer.stopAVPlayer();
          }
          else
          {
            if(this.audioRecorder.isRecordOK())
            {
              this.audioPlayer.avPlayerUrl(this.audioRecorder.getRecordFileName());
            }
            else
            {
              this.audioPlayer.avPlayerFdSrc();
            }
          }
          this.start = !this.start;
        });

      Button(this.speechText)
        .onClick(()=>{
          if(!this.text2Speech.isBusy()){
            this.text2Speech.speak(this.speechText);
          }
        })
    }
  }

  aboutToAppear(): void {
    emitter.on({
      eventId: 17145,                      // 指定事件ID
      priority: emitter.EventPriority.HIGH // 事件优先级
    }, (data) => {
      let dict= data["data"];
      if(dict != undefined){
        let text:string = dict["VoiceText"];
        if(text !== ""){
          this.speechText = text;
        }
      }
    })
  }
}

