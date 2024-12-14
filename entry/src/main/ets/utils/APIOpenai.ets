import { router } from '@kit.ArkUI'
import { EnvStore } from '../utils/EnvStore';
import http from '@ohos.net.http';
import List from '@ohos.util.List';

// 传递进来的params参数
// studentAnswer:学生答案
// question:问题
// aiAnalysis:ai分析的结果
// correctAnswer:正确答案
// explanation:详细解答

const baseUrl = EnvStore.GetInstance().get("openai_baseurl")
const apiKey = EnvStore.GetInstance().get("openai_apikey")

class APIOpenai {
  private studentAnswer:string =  (router.getParams() as Record<string, string>).studentAnswer;
  private question:string = (router.getParams() as Record<string,string>).question;
  private aiAnalysis:string = (router.getParams() as Record<string,string>).aiAnalysis;
  private correctAnswer:string = (router.getParams() as Record<string,string>).correctAnswer;
  private explanation:string = (router.getParams() as Record<string,string>).explanation;
  private options: http.HttpRequestOptions = {
    method: http.RequestMethod.POST,
    header: {
      "Content-Type": "application/json",
      "Authorization": "Bearer " + apiKey()
    },
    extraData: {
      "model": "gpt-4o-mini",
      "messages": [],
      "temperature": 0.7
    }
  }

  questionAndProblem(problem: string){
  return "请你作为一位经验丰富的教师，针对以下题目进行详细解答和作答批改。请严格按照要求组织内容：\n" +
    "\n" +
    "1. **解答规范**\n" +
    "   - 分析题目中的已知条件和目标\n" +
    "   - 确保每个步骤都有清晰的解释\n" +
    "   - 给出尽可能简单直白的解释回答学生的问题，尽可能避免使用公式，最好是口头化的文本解释\n" +
    "   - 作为一个老师，希望你可以语气尽可能和善，并且该鼓励学生的地方要鼓励\n " +
    "\n" +

    "2. **输出格式**\n" +
    "```json\n" +
    "{\n" +
    "    \"result\": \"你作为老师的回复\",\n" +
    "}\n" +
    "```\n" +
    "\n" +
    "请确保：\n" +
    "- JSON格式完整正确\n" +
    "- 基础字段必须填写\n" +
    "- 错误分析要具体明确\n" +
    "- 改进建议要有针对性和可操作性\n" +
    "\n" +
    "题目是：\n" + this.question +
    "学生疑问：\n" + problem +
    "\n" +
    "请开始你的解答。"
}

  AI(studentProblem:string):string
  {
    let result:Promise<object | undefined> = this.completion(this.questionAndProblem(studentProblem));
    if (result === undefined) {
      return  "";
    }
    let text = Object(result)["choices"][0]["message"]["content"] as string;
    return text;
  }

  async completion(prompt: string): Promise<object | undefined> {
    let request = http.createHttp();
    let url = baseUrl() + "/v1/chat/completions"

    console.info(`Send request to ${url}, options: ${this.options}`)
      let response = await request.request(url, this.options);
      console.info(`get response: ${typeof response.result} ${response.result}`)
      let jsonObj = JSON.parse(response.result as string) as object;
      console.info(`translate response to json ${JSON.stringify(jsonObj)}`)
      return jsonObj;
  }

  addToMessage(role:string,content:string){
    let extraData:object = this.options.extraData as object;
    let messages:List<object> = extraData["messages"];
    messages.add({
      "role":role,
      "content":content
    })
  }
}