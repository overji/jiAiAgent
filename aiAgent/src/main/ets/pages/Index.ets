import {ApiText2Speech} from '../utils/textToSpeech';
import {ApiSpeechToText} from '../utils/speechToText'
import { emitter } from '@kit.BasicServicesKit';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct Index{
  @State private start:boolean = false;
  @State private startRecord:boolean = false;
  @State private pauseRecord:boolean = false;

  build() {
    Column(){

      Button("跳转")
        .onClick(()=>{
          router.pushUrl({
            url:"pages/AIChatPage",
            params:{
              studentAnswer:"3",
              question:"1+1等于几",
              aiAnalysis:"",
              correctAnswer:"2",
              explanation:"1+1=2"
            }
          })
        })
    }
  }


}

