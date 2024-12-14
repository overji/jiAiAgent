import { resourceManager } from '@kit.LocalizationKit';
import { util } from '@kit.ArkTS';
import Log from './log';

let log = new Log("[EnvStore]")

export class EnvStore {
  private static instance: EnvStore = new EnvStore();
  private envs: Map<string, string> | undefined;

  private constructor() {
  }

  public static GetInstance(): EnvStore {
    return EnvStore.instance
  }

  public init(rm: resourceManager.ResourceManager) {
    let contentBuf = rm.getRawFileContentSync("env/template_secret.json5")
    let decoder = new util.TextDecoder
    let contentStr = decoder.decodeToString(contentBuf)
    let secretObj = JSON.parse(contentStr) as object;
    let keys = Object.keys(secretObj)
    this.envs = new Map()
    keys.forEach((key) => {
      this.envs![key] = secretObj[key];
    })
  }

  private _get(key: string): string {
    if (this.envs) {
      return this.envs[key]
    }
    return ""
  }

  public get(key: string): () => string {
    return () => {
      return this._get(key)
    }
  }
}