class DrawWaveform {
  //float[] data;         // 输入数据
  float x, y;             // 左上顶点坐标
  float w, h;             // 大小
  float range;            // Y 轴范围
  String unitX, unitY;    // 轴单位
  float[][] cache = new float[3][10000];        // 缓存数据
  int mark = 0;           // 下一位数据存储标志位
  int scaleFactor = 1;    // 缩放因子
  
  DrawWaveform setPosition(float _x, float _y){
    x = _x;
    y = _y;
    return this;
  }

  DrawWaveform setSize(float _w, float _h){
    w =  _w;
    h = _h;
    return this;
  }

  DrawWaveform setRange(float _range){
    range = _range;
    return this;
  }

  DrawWaveform setUnit(String _unitX, String _unitY){
    unitX = _unitX;
    unitY = _unitY;
    return this;
  } 

  DrawWaveform showCoord(){
    pushMatrix();
      translate(x,y+h/2);
      stroke(0);

      // 原点
      textSize(14);
      text("0", -15, 5);

      // x轴、y轴单位
      text(unitX, w-10, 18);
      text(unitY, 10, -h/2);

      // x轴
      line(0, 0, w, 0);
      line(w, 0, w-3, 3);
      line(w, 0, w-3, -3);

      // y轴
      line(0, -h/2, 0, h/2);
      line(0, -h/2, 3, -h/2+3);
      line(0, -h/2, -3, -h/2+3);
    popMatrix(); 
    return this;
  }

  void pushData(float[] data){
    //cache= new float[data.length][];

    for(int i =0; i<data.length; i++){
      //cache[i] = new float[10000];
      cache[i][mark] = data[i]; 
    }
    mark++; // 下一位数据存储标志位 +1
    
    pushMatrix();
      translate(x,y+h/2);
      
      // 每当现有数据长度超过宽度时，横轴单位长度（初始为1）增加一倍
      if(mark > scaleFactor*w){
        scaleFactor *= 2;
      }
      if(mark > cache[0].length){
        mark = 0;
      }
      
      // 从缓存里获取每个类别的数据，并绘制
      for(int i = 0; i < cache.length; i++){
        noFill();
        beginShape();
          // 变换线的颜色
          switch(i){
            case 0:
              stroke(#55AAF7);
              break;
            case 1:
              stroke(#73BD49);
              break;
            case 2:
              stroke(#F19030);
              break;
            default:
              stroke(#ff0000);
          } 
          for(int j = 0; j < mark; j++){
            vertex(j/scaleFactor, -cache[i][j]*h/(2*range)); // 因为 p5中 y+ 是向下的
            
          } 
        endShape();     
      }
    popMatrix(); 
  }    
}