import { textToSpeech } from '@kit.CoreSpeechKit';
import { BusinessError, emitter } from '@kit.BasicServicesKit';
import { systemDateTime } from '@kit.BasicServicesKit';

export class ApiText2Speech {
  private ttsEngine: textToSpeech.TextToSpeechEngine|undefined = undefined;

  constructor() {
    this.createByCallback();
  }

  // 创建引擎，通过callback形式返回
  private createByCallback() {
    // 设置创建引擎参数
    let extraParam: Record<string, Object> = {"style": 'interaction-broadcast', "locate": 'CN', "name": 'EngineName'};
    let initParamsInfo: textToSpeech.CreateEngineParams = {
      language: 'zh-CN',
      person: 0,
      online: 1,
      extraParams: extraParam
    };

    // 调用createEngine方法
    textToSpeech.createEngine(initParamsInfo, (err: BusinessError, textToSpeechEngine: textToSpeech.TextToSpeechEngine) => {
      if (!err) {
        console.info('Succeeded in creating engine.');
        // 接收创建引擎的实例
        this.ttsEngine = textToSpeechEngine;
      } else {
        console.error(`Failed to create engine. Code: ${err.code}, message: ${err.message}.`);
      }
    });
  };

  // 调用speak播报方法
  public speak(text:string) {
    if(text == ""){
      emitter.emit({
        eventId:1002,
        priority:emitter.EventPriority.IMMEDIATE
      })
    }
    if(this.ttsEngine == undefined)return;
    let speakListener: textToSpeech.SpeakListener = {
      // 开始播报回调
      onStart(requestId: string, response: textToSpeech.StartResponse) {
        console.info(`onStart, requestId: ${requestId} response: ${JSON.stringify(response)}`);
      },
      // 完成播报回调
      onComplete(requestId: string, response: textToSpeech.CompleteResponse) {
        emitter.emit({
          eventId:1002,
          priority:emitter.EventPriority.IMMEDIATE
        })
        console.info(`onComplete, requestId: ${requestId} response: ${JSON.stringify(response)}`);
      },
      // 停止播报完成回调，调用stop方法并完成时会触发此回调
      onStop(requestId: string, response: textToSpeech.StopResponse) {
        emitter.emit({
          eventId:1002,
          priority:emitter.EventPriority.IMMEDIATE
        })
        console.info(`onStop, requestId: ${requestId} response: ${JSON.stringify(response)}`);
      },
      // 返回音频流
      onData(requestId: string, audio: ArrayBuffer, response: textToSpeech.SynthesisResponse) {
        console.info(`onData, requestId: ${requestId} sequence: ${JSON.stringify(response)} audio: ${JSON.stringify(audio)}`);
      },
      // 错误回调，播报过程发生错误时触发此回调
      onError(requestId: string, errorCode: number, errorMessage: string) {
        console.error(`onError, requestId: ${requestId} errorCode: ${errorCode} errorMessage: ${errorMessage}`);
      }
    };
    // 设置回调
    this.ttsEngine.setListener(speakListener);
    // 设置播报相关参数
    let extraParam: Record<string, Object> = {"queueMode": 0, "speed": 1, "volume": 2, "pitch": 1, "languageContext": 'zh-CN', "audioType": "pcm", "soundChannel": 3, "playType":1}
    let curTime = systemDateTime.getTime().toString();
    let speakParams: textToSpeech.SpeakParams = {
      requestId: `${curTime}-t2s`, // requestId在同一实例内仅能用一次，请勿重复设置
      extraParams: extraParam
    };
    // 调用speak播报方法
    this.ttsEngine.speak(text, speakParams);
  };

  public stop():void{
    if(this.ttsEngine == undefined)return;
    this.ttsEngine.stop();
  }

  public isBusy():boolean{
    if(this.ttsEngine == undefined)return false;
    return this.ttsEngine.isBusy();
  }
}