import media from '@ohos.multimedia.media';
import fileIo from '@ohos.file.fs';
import { BusinessError } from '@kit.BasicServicesKit';

export class AudioRecorder {
  private avRecorder:media.AVRecorder|undefined = undefined;
  private avProfile: media.AVRecorderProfile = { //华为官方文档中的对象构造方式不可直接用于现版本，必须要声明avProfile为media.AVRecorderProfile
    audioBitrate: 100000, // 音频比特率
    audioChannels: 2, // 音频声道数
    audioCodec: media.CodecMimeType.AUDIO_AAC, // 音频编码格式，当前只支持aac
    audioSampleRate: 48000, // 音频采样率
    fileFormat: media.ContainerFormatType.CFT_MPEG_4A, // 封装格式，当前只支持m4a
  };
  private avConfig: media.AVRecorderConfig = { //同样的，这里必须要声明avConfig为media.AVRecorderConfig
    audioSourceType: media.AudioSourceType.AUDIO_SOURCE_TYPE_MIC, // 音频输入源，这里设置为麦克风
    profile: this.avProfile,
    // 参考应用文件访问与管理开发示例新建并读写一个文件
    url:""
  };

  private file:fileIo.File|undefined = undefined;

  // 注册audioRecorder回调函数
  setAudioRecorderCallback() {
    // 状态机变化回调函数
    if(this.avRecorder == undefined){
      return;
    }
    this.avRecorder.on('stateChange', (state, reason) => {
      console.log(`AudioRecorder current state is ${state}`);
    })
    // 错误上报回调函数
    this.avRecorder.on('error', (err) => {
      console.error(`AudioRecorder failed, code is ${err.code}, message is ${err.message}`);
    })
  }

  // 开始录制对应的流程
  private async startRecordingProcess() {
    // 1.创建录制实例
    console.error(`0start Recording Process now!`)
    this.avRecorder = await media.createAVRecorder();
    console.error(`1start Recording Process now!`)
    this.setAudioRecorderCallback();
    console.error(`2start Recording Process now!${this.avConfig.url}`)
    // 2.获取录制文件fd赋予avConfig里的url；参考FilePicker文档
    // 3.配置录制参数完成准备工作
    // 其实这里不用回调函数也可以
    await this.avRecorder.prepare(this.avConfig).then(() => {
      console.log('Invoke prepare succeeded.');
    }, (err:BusinessError) => {
      console.error(`Invoke prepare failed, code is ${err.code}, message is ${err.message}`);
    })
    // 4.开始录制
    await this.avRecorder.start();
  }

  // 暂停录制对应的流程
  private async pauseRecordingProcess() {
    if(this.avRecorder == undefined){
      return;
    }
    if (this.avRecorder.state === 'started') { // 仅在started状态下调用pause为合理状态切换
      await this.avRecorder.pause();
    }
  }

  // 恢复录制对应的流程
  private async resumeRecordingProcess() {
    if(this.avRecorder == undefined){
      return;
    }
    if (this.avRecorder.state === 'paused') { // 仅在paused状态下调用resume为合理状态切换
      await this.avRecorder.resume();
    }
  }

  // 停止录制对应的流程
  private async stopRecordingProcess() {
    if(this.avRecorder == undefined){
      return;
    }
    // 1. 停止录制
    if (this.avRecorder.state === 'started'
      || this.avRecorder.state === 'paused') { // 仅在started或者paused状态下调用stop为合理状态切换
      await this.avRecorder.stop();
    }
    // 2.重置
    await this.avRecorder.reset();
    // 3.释放录制实例
    await this.avRecorder.release();
    // 4.关闭录制文件fd
  }

  /*初始化avRecorder，并且设置音频存储的路径。
  这里由于音频将在后续被立刻播放,所以把音频放入了应用context中的tempDir文件夹中
  请注意该文件夹在应用运行结束后会被直接清除掉，所以音频文件不会长久地留在盘中。*/
  async startAudioRecorder() {
    console.error("now Start Audio Recorder");
    let tempPath = getContext().tempDir;
    let path = tempPath + "/audio.m4a"
    console.error(`path here ${path}`)
    fileIo.createRandomAccessFileSync(path,fileIo.OpenMode.CREATE);
    this.file = fileIo.openSync(path,fileIo.OpenMode.READ_WRITE);
    this.avConfig.url = "fd://" + this.file.fd.toString(); //注意在这里对avConfig中的url进行了修改
    console.error(`avconfig here ${this.avConfig.url}`)
    await this.startRecordingProcess(); // 开始录制
  }

  //包裹函数，检查avRecorder是否为空，如果不为空则暂停录制
  public async pauseAudioRecorder() {
    console.error("now Pause Audio Recorder");
    if(this.avRecorder == undefined){
      return;
    }
    await this.pauseRecordingProcess();
  }

  //包裹函数，检查avRecorder是否为空，如果不为空则从暂停中恢复录制
  public async resumeAudioRecorder() {
    console.error("now Resume Audio Recorder");
    if(this.avRecorder == undefined){
      return;
    }
    await this.resumeRecordingProcess();
  }

  //包裹函数，检查avRecorder是否为空，如果不为空则停止录制。
  public async stopAudioRecorder() {
    console.error("now Stop Audio Recorder");
    console.error(`${this.file?.name},${this.avRecorder == undefined}`)
    if(this.avRecorder == undefined){
      return;
    }
    await this.stopRecordingProcess();
  }

  //包裹函数，检查
  public getRecordFileFdNumber(): number {
    if(this.file == undefined){
      return 0;
    }
    return this.file.fd;
  }

  //返回file的名称
  public getRecordFileName():string {
    if(this.file == undefined){
      return "";
    }
    return this.file.name;
  }

  //确认录制是否完成
  public isRecordOK():boolean {
    return !(this.file == undefined || this.avRecorder == undefined);
  }
}