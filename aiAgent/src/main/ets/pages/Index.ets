import { CircleShape, router } from '@kit.ArkUI';

@Entry
@Component
struct Index{
  @State cur_x:number = 0;
  @State cur_y:number = 0;
  initial_x:number = this.cur_x;
  initial_y:number = this.cur_y;
  @State px:number = 0
  @State py:number = 0
  private ball_size:number = 100;

  build() {
    Column(){
      Text(this.px.toString());
      Text(this.py.toString());
        Button("跳转")
          .height(this.ball_size)
          .width(this.ball_size)
          .backgroundColor("#ffd0f7ff")
          .onTouch((event)=>{
            if(event.type == TouchType.Move){
              this.cur_x = event.touches[0].windowX - this.px;
              this.cur_y = event.touches[0].windowY - this.py;
            } else if (event.type == TouchType.Down) {
              this.px = event.touches[0].x;
              this.py = event.touches[0].y;
            }
          })
          .position({x:this.cur_x,y:this.cur_y})
          .onClick(()=>{
            router.pushUrl({
              url:"pages/AIChatPage",
              params:{
                studentAnswer:"3",
                question:"1+1等于几",
                aiAnalysis:"",
                correctAnswer:"2",
                explanation:"1+1=2"
              }
            })
          })
      }
  }
}

