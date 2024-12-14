import { EnvStore } from '../utils/EnvStore';import http from '@ohos.net.http';
import List from '@ohos.util.List';
import { BusinessError, emitter } from '@kit.BasicServicesKit';

const baseUrl = EnvStore.GetInstance().get("openai_baseurl")
const apiKey = EnvStore.GetInstance().get("openai_apikey")
const maxSize = 10

export interface Message{
  role:string,
  content:string
}

interface ExtraData{
  model:string,
  messages: Message[],
  temperature:number
}

export class historyOpenAI
{
  private maxSize = 10
  private extraData:ExtraData = {
    model: "gpt-4o-mini",
    messages: [],
    temperature: 0.7
  }
  private options: http.HttpRequestOptions = {
    method: http.RequestMethod.POST,
    header: {
      "Content-Type": "application/json",
      "Authorization": "Bearer " + apiKey()
    },
    extraData:this.extraData
  }

  questionAndProblem(question:string,problem: string){
    return problem;
    return "请你作为一位经验丰富的教师，针对以下题目进行详细解答和作答批改。请严格按照要求组织内容：\n" +
      "\n" +
      "1. **解答规范**\n" +
      "   - 分析题目中的已知条件和目标\n" +
      "   - 确保每个步骤都有清晰的解释\n" +
      "   - 给出尽可能简单直白的解释回答学生的问题，禁止使用公式，而且禁止使用任何具有markdown风格的格式返回，不得使用任何markdown语法，应当是口头化的纯文本解释\n" +
      "   - 作为一个老师，希望你可以语气尽可能和善，并且该鼓励学生的地方要鼓励\n " +
      "\n" +

      "2. **输出格式**\n" +
      "请确保：\n" +
      "- 一段简洁的文本,尽量避免书面语言(包括公式和符号,一定需要的话,也请尽量用文字描述)\n" +
      "- 基础字段必须填写\n" +
      "- 错误分析要具体明确\n" +
      "- 改进建议要有针对性和可操作性\n" +
      "\n" +
      "题目是：\n" + question +
      "学生疑问：\n" + problem +
      "\n" +
      "请开始你的解答。"
  }

  async aiResponse(question:string,studentProblem:string): Promise<Message[]>
  {
    // let result:object | undefined = await this.completion(this.questionAndProblem(question,studentProblem));
    let result = await this.completion(this.questionAndProblem(question,studentProblem)).catch((err:BusinessError)=>{
      console.error(`Failed to completion, err name: ${err.name}, err code: ${err.code}`)
    });
    if (!result) {
      return  [];
    }
    let str:string = JSON.stringify(result);
    let text = Object(result)["choices"][0]["message"]["content"] as string;
    this.addToMessage("system",text);
    return this.extraData.messages;
  }

  async completion(prompt: string): Promise<object | undefined> {
    let request = http.createHttp();
    let url = baseUrl() + "/v1/chat/completions"
    this.addToMessage("user",prompt);
    console.error(JSON.stringify(this.options))
    console.info(`Send request to ${url}, options: ${this.options}`)
    try{
      let response = await request.request(url, this.options);
      console.info(`get response: ${typeof response.result} ${response.result}`)
      let jsonObj = JSON.parse(response.result as string) as object;
      console.info(`translate response to json ${JSON.stringify(jsonObj)}`)
      return jsonObj;
    } catch (e) {
      console.error(`error occur: ${JSON.stringify(e)}`)
    }
    return undefined;
  }

  addToMessage(role:string,content:string){
    if(this.extraData.messages.length > 2*this.maxSize){
      this.extraData.messages = [];
    }
    this.extraData.messages.push({
      "role":role,
      "content":content
    })
    this.options.extraData = this.extraData;
  }
}