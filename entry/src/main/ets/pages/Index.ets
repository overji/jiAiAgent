import { webview } from '@kit.ArkWeb';

@Entry
@Component
struct WebComponent {
  controller: webview.WebviewController = new webview.WebviewController();

  writeToHTML(text:string){

    console.log(`text is here :${text}`)
    console.log(`sendText(String.raw\`${text}\`);`)
    console.log(`MathJax.Hub.Queue(["Typeset",MathJax.Hub,document.getElementById('mainContent')])`)
    this.controller.runJavaScript(`sendText(String.raw\`${text}\`);`);
  }

  build() {
    Column() {
      // 加载沙箱路径文件。
      Web({
        src: $rawfile("output.html"),
        controller: this.controller
      })
        .height("50%")
        .onConsole((event)=>{
          console.log('getMessage:'+event.message.getMessage());
          console.log('getMessageLevel:'+event.message.getMessageLevel());
          return false;
        })
      Button("click")
        .onClick(()=>{
          const text = String.raw `函数 \( z = u^2 \ln v \)，其中 \( u = \frac{y}{x} \) 和 \( v = 3y - 2x \)。`
          this.writeToHTML(text);
        })
    }
  }
}