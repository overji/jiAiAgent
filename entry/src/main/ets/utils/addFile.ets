// import fileio from '@ohos.fileio';
// function write(text: string,fileName: string = '01.html') {
//   let fd = fileio.openSync(fileName, 0o102, 0o666);
//   fileio.write(fd, text, (error, length) => {
//     if(!error) {
//       console.log("write success, write length: " + length);
//     }
//   })
//   fileio.closeSync(fd);
// }
// function read(path: string) {
//   let fd = fileio.openSync(path + "/" + this.fileName, 0o102, 0o666);
//   let buffer = new ArrayBuffer(4096);
//   fileio.read(fd, buffer, (error, data) => {
//     if(!error) {
//       let s:string = String.fromCodePoint.apply(null, new Uint8Array(data.buffer));
//       console.log("" + s);
//       let d = decodeURIComponent(escape(s));
//       console.log("read success, read content: " + d);
//     }
//   })
// }

import fileIo from '@ohos.file.fs'
import { BusinessError } from '@kit.BasicServicesKit';
import systemDateTime from '@ohos.systemDateTime' ;
import util from '@ohos.util';

export class FileManager {
  public defaultFileName: string;
  public templatePath:string;

  constructor(defaultFileName: string = '01.html') {
    this.defaultFileName = defaultFileName;
    this.templatePath = getContext().filesDir + "/htmlPages_saver"
    this.initialDir();
  }

  initialDir()
  {
    if(!fileIo.accessSync(this.templatePath)){
      fileIo.mkdirSync(this.templatePath);
      console.log(`success create ${this.templatePath}`);
    }
    else
    {
      console.log(`${this.templatePath} already exists!`);
    }
  }

  getCurTimeStr():string
  {
    let cur:number = systemDateTime.getTime()
    return cur.toString();
  }

  writeHtml(input_str:string):string
  {
    let header = `<!DOCTYPE html><html><head><title>解数学题</title><script src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.7/MathJax.js?config=TeX-MML-AM_CHTML"></script><meta charset="utf-8"/></head><body><p id="mainContent">最终答案为：</p><script type="text/javascript">MathJax.Hub.Config({tex2jax: {inlineMath: [['$', '$'], ['\\(', '\\)']]}});MathJax.Hub.Queue(function() {document.getElementById('mainContent').innerHTML = marked.parse(document.getElementById('mainContent').innerHTML);});</script></body></html>`
    return this.writeToFile(header);
  }


  
  writeToFile(input_str:string):string
  {
    let filePath = `${this.templatePath}/ji_temp_${this.getCurTimeStr()}.html`;
    this.initialDir();
    fileIo.createRandomAccessFileSync(filePath,fileIo.OpenMode.CREATE);
    const file:fileIo.File = fileIo.openSync(filePath,fileIo.OpenMode.READ_WRITE);
    try{
      fileIo.writeSync(file.fd,input_str);
    } catch (err) {
      console.log("error in write!!!")
    }
    console.log("OK to Write File (Ji)")
    fileIo.closeSync(file.fd);

    return filePath;
  }

  deleteAll()
  {
    try{
      fileIo.rmdirSync(this.templatePath);
    } catch (err) {
      console.log("error in remove dir!!!")
    }
  }
}
