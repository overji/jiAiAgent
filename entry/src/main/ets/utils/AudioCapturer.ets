/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2023. All rights reserved.
 */

import {audio} from '@kit.AudioKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import {BusinessError} from '@kit.BasicServicesKit';
import { inspector } from '@kit.ArkUI';


const TAG = 'AudioCapturer';

/**
 * Audio collector tool
 */
export default class AudioCapturer {
  /**
   * Collector object
   */
  private mAudioCapturer:audio.AudioCapturer|undefined = undefined;

  /**
   * Audio Data Callback Method
   */
  private mDataCallBack: ((data: ArrayBuffer) => void)|undefined = undefined;

  /**
   * Indicates whether recording data can be obtained.
   */
  private mCanWrite: boolean = true;

  /**
   * Audio stream information
   */
  private audioStreamInfo:audio.AudioStreamInfo = {
    samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_16000,
    channels: audio.AudioChannel.CHANNEL_1,
    sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE,
    encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW
  }

  /**
   * Audio collector information
   */
  private audioCapturerInfo:audio.AudioCapturerInfo = {
    source: audio.SourceType.SOURCE_TYPE_MIC,
    capturerFlags: 0
  }

  /**
   * Audio Collector Option Information
   */
  private audioCapturerOptions:audio.AudioCapturerOptions = {
    streamInfo: this.audioStreamInfo,
    capturerInfo: this.audioCapturerInfo
  }

  /**
   *  Initialize
   * @param audioListener
   */
  public async init(dataCallBack: (data: ArrayBuffer) => void) {
    if (null != this.mAudioCapturer) {
      hilog.error(0x0000, TAG, 'AudioCapturerUtil already init');
      return;
    }
    this.mDataCallBack = dataCallBack;
    let audiocap= await audio.createAudioCapturer(this.audioCapturerOptions).catch((error:BusinessError) => {
      hilog.error(0x0000, TAG, `AudioCapturerUtil init createAudioCapturer failed, code is ${error.code}, message is ${error.message}`);
    });
    if(audiocap){
      this.mAudioCapturer = audiocap;
    }
  }

  /**
   * start recording
   */
  public async start() {
    hilog.error(0x0000, TAG, `AudioCapturerUtil start`);
    if(this.mAudioCapturer == undefined)return;
    if(this.mDataCallBack == undefined)return;
    let stateGroup = [audio.AudioState.STATE_PREPARED, audio.AudioState.STATE_PAUSED, audio.AudioState.STATE_STOPPED];
    if (stateGroup.indexOf(this.mAudioCapturer.state) === -1) {
      hilog.error(0x0000, TAG, `AudioCapturerUtil start failed`);
      return;
    }
    this.mCanWrite = true;
    await this.mAudioCapturer.start();
    while (this.mCanWrite) {
      let bufferSize = await this.mAudioCapturer.getBufferSize();
      let buffer = await this.mAudioCapturer.read(bufferSize, true);
      this.mDataCallBack(buffer)
    }
  }

  /**
   * stop recording
   */
  public async stop() {
    if(this.mAudioCapturer == undefined)return;
    if (this.mAudioCapturer.state !== audio.AudioState.STATE_RUNNING && this.mAudioCapturer.state !== audio.AudioState.STATE_PAUSED) {
      hilog.error(0x0000, TAG, `AudioCapturerUtil stop Capturer is not running or paused`);
      return;
    }
    this.mCanWrite = false;
    await this.mAudioCapturer.stop();
  }

  /**
   * release
   */
  public async release() {
    if(this.mAudioCapturer == undefined)return;
    if (this.mAudioCapturer.state === audio.AudioState.STATE_RELEASED || this.mAudioCapturer.state === audio.AudioState.STATE_NEW) {
      hilog.error(0x0000, TAG, `Capturer already released`);
      return;
    }
    await this.mAudioCapturer.release();
    this.mAudioCapturer = undefined;
  }
}