import HiLog from '@ohos.hilog'

export default class Log {
  private static readonly DOMAIN = 0x0007
  private static readonly TAG: string = '[EDU_AI]'
  public static readonly LEVEL_DEBUG = 0;
  public static readonly LEVEL_LOG = 1;
  public static readonly LEVEL_INFO = 2;
  public static readonly LEVEL_WARN = 3;
  public static readonly LEVEL_ERROR = 4;
  //  public static LOG_LEVEL = Log.LEVEL_LOG;
  public static LOG_LEVEL = -1;

  public static debug(message: string) {
    if (Log.LOG_LEVEL <= Log.LEVEL_DEBUG) {
      HiLog.debug(Log.DOMAIN, Log.TAG, message)
    }
  }

  public static log(message: string) {
    if (Log.LOG_LEVEL <= Log.LEVEL_LOG) {
      HiLog.info(Log.DOMAIN, Log.TAG, message)
    }
  }

  public static info(message: string) {
    if (Log.LOG_LEVEL <= Log.LEVEL_INFO) {
      HiLog.info(Log.DOMAIN, Log.TAG, message)
    }
  }

  public static warn(message: string) {
    if (Log.LOG_LEVEL <= Log.LEVEL_WARN) {
      HiLog.warn(Log.DOMAIN, Log.TAG, message)
    }
  }

  public static error(message: string) {
    if (Log.LOG_LEVEL <= Log.LEVEL_ERROR) {
      HiLog.error(Log.DOMAIN, Log.TAG, message)
    }
  }

  private prefix: string;

  constructor(prefix: string) {
    this.prefix = prefix
  }

  public debug(message: string) {
    if (Log.LOG_LEVEL <= Log.LEVEL_DEBUG) {
      HiLog.debug(Log.DOMAIN, Log.TAG, this.prefix + message)
    }
  }

  public log(message: string) {
    if (Log.LOG_LEVEL <= Log.LEVEL_LOG) {
      HiLog.info(Log.DOMAIN, Log.TAG, this.prefix + message)
    }
  }

  public info(message: string) {
    if (Log.LOG_LEVEL <= Log.LEVEL_INFO) {
      HiLog.info(Log.DOMAIN, Log.TAG, this.prefix + message)
    }
  }

  public warn(message: string) {
    if (Log.LOG_LEVEL <= Log.LEVEL_WARN) {
      HiLog.warn(Log.DOMAIN, Log.TAG, this.prefix + message)
    }
  }

  public error(message: string) {
    if (Log.LOG_LEVEL <= Log.LEVEL_ERROR) {
      HiLog.error(Log.DOMAIN, Log.TAG, this.prefix + message)
    }
  }
}