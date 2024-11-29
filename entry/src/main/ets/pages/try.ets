// // xxx.ets
// import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
// import { webview } from '@kit.ArkWeb';
// import { GlobalContext } from './GlobalContext';
//
//
//
//
//
// @Entry
// @Component
// struct WebComponent {
//   controller: webview.WebviewController = new webview.WebviewController();
//   url:string = "";
//
//   aboutToAppear(): void {
//     GlobalContext.getContext().setObject("filesDir", getContext().filesDir);
//     console.log("Sandbox path is " + GlobalContext.getContext().getObject("filesDir"));
//
//     this.url = 'file://' + GlobalContext.getContext().getObject("filesDir") + '/htmlPages_saver/ji_temp_1732860971892.html';
//   }
//
//   build() {
//     Column() {
//       // 加载沙箱路径文件。
//       Web({ src: this.url, controller: this.controller })
//     }
//   }
// }