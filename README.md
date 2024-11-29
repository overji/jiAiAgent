# 在arkts上动态显示latex文本的一种方案

##  1.代码实现
**Index.ets :**
```arkts
import { webview } from '@kit.ArkWeb';
import { FileManager } from "../utils/addFile"
import { fileUri } from '@kit.CoreFileKit';
import util from '@ohos.util';
import fileIo from '@ohos.file.fs'


@Entry
@Component
struct WebComponent {
  controller: webview.WebviewController = new webview.WebviewController();

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
          let text = String.raw`函数 \( z = u^2 \ln v \)，其中 \( u = \frac{y}{x} \) 和 \( v = 3y - 2x \)。`
          console.log(`text is here :${text}`)
          console.log(`sendText(String.raw\`${text}\`);`)
          console.log(`MathJax.Hub.Queue(["Typeset",MathJax.Hub,document.getElementById('mainContent')])`)
          this.controller.runJavaScript(`sendText(String.raw\`${text}\`);`);
        })

    }
  }
}
```

**output.html:**
```html
<!DOCTYPE html>

<html>
<head>
  <title>解数学题</title>
  <script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.7/MathJax.js?config=TeX-MML-AM_CHTML"></script>
  <meta charset="utf-8"/>
</head>
<body>
<p id="mainContent">
  6666666 如果 \(\{a_n\}\) 是等差数列，则 \( a_n = a + (n-1)d \)，其中 \( a \) 是首项，\( d \) 是公差。
</p>
<script>
  function sendText(text){
    // Convert HTML entities back to LaTeX syntax

    document.getElementById('mainContent').innerHTML = text;
    console.log("here is web")
    console.log(text);
    MathJax.Hub.Queue(["Typeset", MathJax.Hub]);
  }

  MathJax.Hub.Config({
    tex2jax: {
      inlineMath: [['$', '$'], ['\\(', '\\)']]
    }
  });

  MathJax.Hub.Queue(function() {
    // Render LaTeX after converting from Markdown
    document.getElementById('mainContent').innerHTML = marked.parse(document.getElementById('mainContent').innerHTML);
  });
</script>
</body>
</html>
```

## 2.使用方法
将output.html文件放入./entry/src/main/resources/rawfile(如果没有请自行创建)文件夹下即可

## 3.原理说明
大致思路即是:
使用webview渲染html页面，调用sendText方法将文本插入html页面，
调用mathJax，对页面上的latex文本进行渲染。