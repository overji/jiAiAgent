import { speechRecognizer } from '@kit.CoreSpeechKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo } from '@kit.CoreFileKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import AudioCapturer from './AudioCapturer';
import { systemDateTime } from '@kit.BasicServicesKit';
import {emitter} from '@kit.BasicServicesKit';

const TAG = 'CoreSpeechKitDemo';

@Component
export struct ApiSpeechToText {
  private createCount: number = 0;
  @State private nowStart:boolean = false;
  @State private resultOver: boolean = false;
  @State private voiceInfo: string = "";
  @State private tempInfo:string = "";
  private sessionId: string = `${systemDateTime.getTime().toString()}-SI`;
  private mAudioCapturer = new AudioCapturer();
  private asrEngine: speechRecognizer.SpeechRecognitionEngine|undefined = undefined;

  build() {
    Column(){
      Text(this.voiceInfo + this.tempInfo)
        .height("70%");
      Row(){
        Button((this.nowStart)?((this.resultOver)?"停止录音":"..."):((this.voiceInfo=="")?"开始录音":"重新录音"))
          .onClick(()=>{
            if(this.nowStart){
              if(!this.resultOver){
                this.endListening()
              }
            } else {
              this.startListening();
            }
          });
        if(!this.nowStart && this.voiceInfo != ""){
          Button("询问大模型")
            .onClick(()=>{
              console.log("nihao!!");
              emitter.emit({
                eventId:17145,
                priority:emitter.EventPriority.HIGH
              },{
                data: {
                  "VoiceText" : this.voiceInfo
                }
              })
            });
        }
      }
    }
  }

  // 创建引擎，通过callback形式返回
  private async createByCallback() {
    // 设置创建引擎参数
    let extraParam: Record<string, Object> = {"locate": "CN", "recognizerMode": "short"};
    let initParamsInfo: speechRecognizer.CreateEngineParams = {
      language: 'zh-CN',
      online: 1,
      extraParams: extraParam
    };

    // 调用createEngine方法
    this.asrEngine = await speechRecognizer.createEngine(initParamsInfo);
  }

  // 查询语种信息，以callback形式返回
  private queryLanguagesCallback() {
    if(this.asrEngine == undefined)return;
    // 设置查询相关参数
    let languageQuery: speechRecognizer.LanguageQuery = {
      sessionId: '123456'
    };
    // 调用listLanguages方法
    this.asrEngine.listLanguages(languageQuery, (err: BusinessError, languages: Array<string>) => {
      if (!err) {
        // 接收目前支持的语种信息
        hilog.info(0x0000, TAG, `Succeeded in listing languages, result: ${JSON.stringify(languages)}`);
      } else {
        hilog.error(0x0000, TAG, `Failed to create engine. Code: ${err.code}, message: ${err.message}.`);
      }
    });
  };

  // 开始识别
  private startListeningForWriteAudio() {
    if(this.asrEngine == undefined)return;
    // 设置开始识别的相关参数
    let recognizerParams: speechRecognizer.StartParams = {
      sessionId: this.sessionId,
      audioInfo: { audioType: 'pcm', sampleRate: 16000, soundChannel: 1, sampleBit: 16 } //audioInfo参数配置请参考AudioInfo
    }
    // 调用开始识别方法
    this.asrEngine.startListening(recognizerParams);
  };

  private startListeningForRecording() {
    if(this.asrEngine == undefined)return;
    let audioParam: speechRecognizer.AudioInfo = { audioType: 'pcm', sampleRate: 16000, soundChannel: 1, sampleBit: 16 }
    let extraParam: Record<string, Object> = {
      "recognitionMode": 0,
      "vadBegin": 2000,
      "vadEnd": 3000,
      "maxAudioDuration": 20000
    }
    let recognizerParams: speechRecognizer.StartParams = {
      sessionId: this.sessionId,
      audioInfo: audioParam,
      extraParams: extraParam
    }
    hilog.info(0x0000, TAG, 'startListening start');
    this.asrEngine.startListening(recognizerParams);
  };



  // 写音频流
  private async writeAudio() {
    if(this.asrEngine == undefined)return;
    this.startListeningForWriteAudio();
    hilog.error(0x0000, TAG, `Failed to read from file. Code`);
    let ctx = getContext(this);
    let filenames: string[] = fileIo.listFileSync(ctx.filesDir);
    if (filenames.length <= 0) {
      hilog.error(0x0000, TAG, `Failed to read from file. Code`);
      return;
    }
    hilog.error(0x0000, TAG, `Failed to read from file. Code`);
    let filePath: string = `${ctx.filesDir}/${filenames[0]}`;
    let file = fileIo.openSync(filePath, fileIo.OpenMode.READ_WRITE);
    try {
      let buf: ArrayBuffer = new ArrayBuffer(1280);
      let offset: number = 0;
      while (1280 == fileIo.readSync(file.fd, buf, {
        offset: offset
      })) {
        let uint8Array: Uint8Array = new Uint8Array(buf);
        this.asrEngine.writeAudio("123456", uint8Array);
        await this.countDownLatch(1);
        offset = offset + 1280;
      }
    } catch (err) {
      hilog.error(0x0000, TAG, `Failed to read from file. Code: ${err.code}, message: ${err.message}.`);
    } finally {
      if (null != file) {
        fileIo.closeSync(file);
      }
    }
  }

  // 麦克风语音转文本
  private async startRecording() {
    if(this.asrEngine == undefined)return;
    this.startListeningForRecording();
    // 录音获取音频
    let data: ArrayBuffer;
    hilog.info(0x0000, TAG, 'create capture success');
    this.mAudioCapturer.init((dataBuffer: ArrayBuffer) => {
      if(this.asrEngine == undefined)return;
      hilog.info(0x0000, TAG, 'start write');
      hilog.info(0x0000, TAG, 'ArrayBuffer ' + JSON.stringify(dataBuffer));
      data = dataBuffer
      let unit8Array: Uint8Array = new Uint8Array(data);
      hilog.info(0x0000, TAG, 'ArrayBuffer unit8Array ' + JSON.stringify(unit8Array));
      // 写入音频流
      this.asrEngine.writeAudio("1234567", unit8Array);
    });
  };
  // 计时
  public async countDownLatch(count: number) {
    while (count > 0) {
      await this.sleep(40);
      count--;
    }
  }
  // 睡眠
  private sleep(ms: number):Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  // 设置回调
  private setListener() {
    if(this.asrEngine == undefined)return;
    // 创建回调对象
    let setListener: speechRecognizer.RecognitionListener = {
      // 开始识别成功回调
      onStart:(sessionId: string, eventMessage: string)=>{
        hilog.info(0x0000, TAG, `onStart, sessionId: ${sessionId} eventMessage: ${eventMessage}`);
      },
      // 事件回调
      onEvent:(sessionId: string, eventCode: number, eventMessage: string)=>{
        hilog.info(0x0000, TAG, `onEvent, sessionId: ${sessionId} eventCode: ${eventCode} eventMessage: ${eventMessage}`);
      },
      // 识别结果回调，包括中间结果和最终结果
      onResult:(sessionId: string, result: speechRecognizer.SpeechRecognitionResult)=>{
        if(result.isFinal) {
          this.resultOver = true;
          this.voiceInfo += result.result;
          this.tempInfo = "";
        } else {
          this.resultOver = false;
          this.tempInfo = result.result;
        }
        hilog.info(0x0000, TAG, `onResult, sessionId: ${sessionId} sessionId: ${JSON.stringify(result)}`);
      },
      // 识别完成回调
      onComplete:(sessionId: string, eventMessage: string)=>{
        hilog.info(0x0000, TAG, `onComplete, sessionId: ${sessionId} eventMessage: ${eventMessage}`);
      },
      // 错误回调，错误码通过本方法返回
      // 返回错误码1002200002，开始识别失败，重复启动startListening方法时触发
      // 更多错误码请参考错误码参考
      onError:(sessionId: string, errorCode: number, errorMessage: string)=>{
        hilog.error(0x0000, TAG, `onError, sessionId: ${sessionId} errorCode: ${errorCode} errorMessage: ${errorMessage}`);
      },
    }
    // 设置回调
    this.asrEngine.setListener(setListener);
  };

  aboutToAppear(): void {
    this.createByCallback().then(()=>{
      this.setListener();
    })
  }

  public startListening(){
    this.nowStart = true;
    this.voiceInfo = "";
    this.startListeningForRecording();
  }

  public endListening(){
    this.nowStart = false;
    if(this.asrEngine == undefined)return "";
    this.asrEngine.finish(this.sessionId);
    return this.voiceInfo;
  }

  public getVoiceText(){
    return this.voiceInfo;
  }
}