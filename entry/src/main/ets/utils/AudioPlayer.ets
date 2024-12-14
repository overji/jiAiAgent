import {media} from '@kit.MediaKit';
import {fileIo as fs} from '@kit.CoreFileKit';
import {common} from '@kit.AbilityKit';
import {BusinessError} from '@kit.BasicServicesKit';
import {audio} from '@kit.AudioKit';

export class AudioPlayer
{
  private isSeek:boolean = true;
  private fd:number = 0;
  private count:number = 0;
  private avPlayer:media.AVPlayer|undefined = undefined;

  setAVPlayerCallback(avPlayer: media.AVPlayer) {
    avPlayer.on('seekDone',(seekDoneTime:number)=>{
      console.info(`AVPlayer seek succeeded, seek time is ${seekDoneTime}`);
    });
    avPlayer.on('error',(err:BusinessError)=>{
      console.error(`AVPlayer failed,code is ${err.code}, message is ${err.message}`);
      avPlayer.reset();
    });
    avPlayer.on('stateChange',async (state:string,reason:media.StateChangeReason)=>{
      switch (state){
        case 'idle':
          console.info('AVPlayer state idle called.');
          avPlayer.release();
          break;
        case 'initialized':
          console.info('AVPlayer state initialized called');
          avPlayer.audioRendererInfo = {
            usage: audio.StreamUsage.STREAM_USAGE_MUSIC,
            rendererFlags:0
          }
          avPlayer.prepare();
          break;
        case 'prepared':
          console.info('AVPlayer state prepared called.');
          avPlayer.play();
          break;
        case 'playing':
          console.info('AVPlayer state playing called.');
          break;
        case 'paused':
          console.info('AVPlayer state paused called.');
          break;
        case 'completed': // 播放结束后触发该状态机上报
          console.info('AVPlayer state completed called.');
          avPlayer.stop(); //调用播放结束接口
          break;
        case 'stopped': // stop接口成功调用后触发该状态机上报
          console.info('AVPlayer state stopped called.');
          avPlayer.reset(); // 调用reset接口初始化avplayer状态
          break;
        case 'released':
          console.info('AVPlayer state released called.');
          break;
        default:
          console.info('AVPlayer state unknown called.');
          break;
      }
    })
  }

  //此函数直接加载应用沙箱环境中的文件进行播放
  //请注意加载沙箱环境中文件的url构造方式，这里是使用的fd://xx，xx中填入你想要加载文件在打开(读写模式)后的fd号码
  async avPlayerUrl(fileName:string) {
    // 创建avPlayer实例对象
    this.avPlayer = await media.createAVPlayer();
    // 创建状态机变化回调函数
    this.setAVPlayerCallback(this.avPlayer);
    let fdPath = 'fd://';
    // 通过UIAbilityContext获取沙箱地址filesDir，以Stage模型为例
    let context = getContext(this) as common.UIAbilityContext;
    let pathDir = context.tempDir;
    let path = pathDir + `/${fileName}`;
    // 打开相应的资源文件地址获取fd，并为url赋值触发initialized状态机上报
    let file = await fs.open(path);
    fdPath = fdPath + '' + file.fd;
    this.isSeek = true; // 支持seek操作
    this.avPlayer.url = fdPath;
  }

  //此函数通过加载rawfile文件夹下的音频，实现播放音频的效果。
  async avPlayerFdSrc() {
    // 创建avPlayer实例对象
    this.avPlayer = await media.createAVPlayer();
    // 创建状态机变化回调函数
    this.setAVPlayerCallback(this.avPlayer);
    // 通过UIAbilityContext的resourceManager成员的getRawFd接口获取媒体资源播放地址
    // 返回类型为{fd,offset,length},fd为HAP包fd地址，offset为媒体资源偏移量，length为播放长度
    let context = getContext(this) as common.UIAbilityContext;
    let fileDescriptor = await context.resourceManager.getRawFd('02.mp3');
    let avFileDescriptor: media.AVFileDescriptor =
      { fd: fileDescriptor.fd, offset: fileDescriptor.offset, length: fileDescriptor.length };
    this.isSeek = true; // 支持seek操作
    // 为fdSrc赋值触发initialized状态机上报
    this.avPlayer.fdSrc = avFileDescriptor;
  }

  //此函数停止音频的播放。
  async stopAVPlayer(){
    if(this.avPlayer == undefined){
      return;
    }
    this.avPlayer.stop()
  }
}