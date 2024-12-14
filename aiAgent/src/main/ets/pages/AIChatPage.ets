import { router } from '@kit.ArkUI'
import { historyOpenAI,Message} from '../utils/HistoryOpenAI'
import { ApiSpeechToText } from '../utils/speechToText';
import { ApiText2Speech } from '../utils/textToSpeech';
import { emitter } from '@kit.BasicServicesKit';

// 传递进来的params参数
// studentAnswer:学生答案
// question:问题
// aiAnalysis:ai分析的结果
// correctAnswer:正确答案
// explanation:详细解答

@Entry
@Component
struct NewPage {
  @State private startQuestion:boolean = false;
  @State private readingAnswer:boolean = false;
  private studentAnswer:string =  (router.getParams() as Record<string, string>).studentAnswer;
  private question:string = (router.getParams() as Record<string,string>).question;
  private aiAnalysis:string = (router.getParams() as Record<string,string>).aiAnalysis;
  private correctAnswer:string = (router.getParams() as Record<string,string>).correctAnswer;
  private explanation:string = (router.getParams() as Record<string,string>).explanation;
  @State private speechText:string = "";
  @State private AIanswer:Array<Message> = [];
  private text2Speech:ApiText2Speech = new ApiText2Speech();
  private openAI:historyOpenAI = new historyOpenAI();


  build() {
    Column({space: 10}) {
      Row(){
        if(this.startQuestion && this.AIanswer){
          Scroll() {
            Text(this.getString())
              .fontSize(30)
              .width('100%')
              .textAlign(TextAlign.Center)
          }.height("100%");
        } else if(this.startQuestion){
          LoadingProgress()
            .width(120)
            .height(40)
        } else {
          Text(this.getString())
            .fontSize(30)
            .width('100%')
            .textAlign(TextAlign.Center)
            .height("100%");
        }
      }.height("65%")
      .width("100%");

      ApiSpeechToText()
        .height("20%");

      Row(){
        Button((this.readingAnswer)?"停止AI播放":"播放AI回复")
          .onClick(()=>{
            if(this.readingAnswer){
              this.text2Speech.stop()
            } else {
              this.readingAnswer = true;
              this.text2Speech.speak(this.AIanswer.toString());
            }
          })
      }.height("7.5%");



      Button("返回主界面")
        .onClick(() => {
          router.back(); // 返回上一页，当前页面会销毁
        })
        .height("7.5%");
    }
    .size({width: '100%', height: '100%'})
  }

  getString(){
    let ans = "";
    for(let m of this.AIanswer){
      ans += m.role + " " + m.content + "\n";
    }
    return ans;
  }

  aboutToDisappear(): void {
    this.text2Speech.stop();
  }

  aboutToAppear(): void {
    emitter.on({
      eventId:1001,
      priority: emitter.EventPriority.HIGH
    },(data)=>{
      let dict= data["data"];
      if(dict != undefined){
        this.startQuestion = dict["startQuestion"];
      }
    })

    emitter.on({
      eventId:1002,
      priority: emitter.EventPriority.HIGH
    },()=>{
      this.readingAnswer = false;
    })

    emitter.on({
      eventId: 17145,                      // 指定事件ID
      priority: emitter.EventPriority.HIGH // 事件优先级
    }, async (data) => {
      let dict= data["data"];
      if(dict != undefined){
        let text:string = dict["VoiceText"];
        if(text !== ""){
          this.speechText = text;
          this.AIanswer = await this.openAI.aiResponse(this.question,text);
        }
      }
    })
  }
}