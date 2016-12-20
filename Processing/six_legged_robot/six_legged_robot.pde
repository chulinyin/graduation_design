/* 导入所需库 */
import processing.opengl.*;
import processing.serial.*;
import peasy.*;
import controlP5.*;

import java.util.*;
import java.text.*;


/* 对象声明 */
PFont pfont, listfont;
Serial serialPort;
ControlP5 cp5;
PeasyCam cam;
DisplayTable angSpeedTable, accelSpeedTable, yprTable;
DrawWaveform angSpeedWF, accelSpeedWF, yprWF;

PrintWriter output;
Table dataRecord;
// TableRow newRow;
DateFormat fnameFormat = new java.text.SimpleDateFormat("yyMMdd_HHmm");
DateFormat timeFormat = new SimpleDateFormat("hh:mm:ss");
String  fileName;
float firstRecordTime;
/* 全局参数设定 */

// 波特率
final int BAUD_RATE = 115200;

// 用于接收串口数据：包含角速度、角度、加速度的包
char counter = 1;             // 用于记录从下位机接收到的有效数据的次数
String HEADER_R = "H";        // 用于标记有效接收数据开始的符号
float firstYaw = 0;

// 用于发送串口数据：$G0 第二位包含所需要执行的步态 
public static final char HEADER_S = '$';            // 用于标记发送数据开始的符号
public static final char GAIT = 'G';

// 步态列表
String[] gaitNameList = new String[]{ "初始化", 
                                      "三足直行", "四足直行", "五足直行",
                                      "三足平移", "四足平移", "五足平移",
                                      "三足旋转", "四足旋转", "五足旋转"
                                    };

// 角速度
float[] angSpeed = new float[3];
String[] angSpeedName = new String[]{"Wx", "Wy", "Wz"};
String angSpeedUnit = "˚/s";

// 加速度
float[] accelSpeed = new float[3];
String[] accelSpeedName = new String[]{"Ax", "Ay", "Az"};
String accelSpeedUnit = "m/s²";

// 欧拉角 :偏航角(绕z)、俯仰角(绕x)、横滚角(绕y)
float[] ypr = new float[3]; 
String[] yprName = new String[]{"Yaw", "Pitch", "Roll"};
String yprUnit = "˚";

// X轴单位
String unitX = "t / s";


void setup(){
  // 系统初始化
  size(1200, 750,OPENGL);
  // cam = new PeasyCam(this, width/2, height/2, 0, 500);
  lights();
  smooth();

  cp5 = new ControlP5(this);

  // 加载字体
  // String[] fontList = PFont.list();
  // printArray(fontList);
  pfont = createFont("MicrosoftSansSerif",22,true);
  listfont = createFont("MicrosoftSansSerif",12,true);
  textFont(pfont);
  // ControlFont font = new ControlFont(pfont,241);
  
  // 创建 cp5 对象
 
  // 显示可用串口列表
  String[] portNameList = Serial.list();
  drawPortList(portNameList);

  // 显示步态列表
  drawGaitList(gaitNameList);

  // 数据表格对象初始化 
  angSpeedTable = new DisplayTable("角速度：", angSpeedName , angSpeedUnit);
  accelSpeedTable = new DisplayTable("加速度：", accelSpeedName, accelSpeedUnit);
  yprTable = new DisplayTable("欧拉角：", yprName, yprUnit);
  

  // 波形图对象初始化
  angSpeedWF = new DrawWaveform();
  accelSpeedWF = new DrawWaveform();
  yprWF = new DrawWaveform();

  // 日志文件初始化

  dataRecord = new Table();
  dataRecord.addColumn("time",Table.FLOAT);
  dataRecord.addColumn("Wx",Table.FLOAT);
  dataRecord.addColumn("Wy",Table.FLOAT);
  dataRecord.addColumn("Wz",Table.FLOAT);
  dataRecord.addColumn("Ax",Table.FLOAT);
  dataRecord.addColumn("Ay",Table.FLOAT);
  dataRecord.addColumn("Az",Table.FLOAT);
  dataRecord.addColumn("Yaw",Table.FLOAT);
  dataRecord.addColumn("Pitch",Table.FLOAT);
  dataRecord.addColumn("Roll",Table.FLOAT);
   // newRow = dataRecord.addRow();

  // output = createWriter(fileName + ".csv");
}

void draw(){

	background(255);

  textSize(20);
  fill(0);
  text("请选择一个端口",77,110);
  text("请选择一种步态",77,305); 

  // 画出数据表和折线图
  drawDataTable();

  pushMatrix();
    translate(180, 580);
    rotateY(radians(ypr[0])); 
    rotateZ(radians(ypr[2]));
    rotateX(radians(-ypr[1])); 
    scale(0.6);
    drawBody(95, 63, 43, 143, 20);
  popMatrix();
  delay(100);
}


// 画串口列表
void drawPortList(String [] portNameList){
  cp5.addScrollableList("portList")
     .setPosition(77, 130)
     .setSize(200, 125)
     .setBarHeight(25)
     .setItemHeight(30)
     .setFont(listfont)
     .setColorBackground(color(#28448A))
     .addItems(portNameList);
     ;
}

// 画步态列表
void drawGaitList(String [] gaitNameList){
  cp5.addScrollableList("gaitList")
     .setPosition(77, 325)
     .setSize(200, 125)
     .setBarHeight(30)
     .setItemHeight(25)
     .setFont(listfont)
     .setColorBackground(color(#26407F))
     .addItems(gaitNameList);
     ;
}

// 画出数据表和折线图
void drawDataTable(){
  pushMatrix();

  // 分别画出角速度、加速度和欧拉角的列表
  angSpeedTable.setPosition(435,110)
               .showTable()
               .pushData(angSpeed)
               ;

  accelSpeedTable.setPosition(435,310)
                 .showTable()
                 .pushData(accelSpeed)
                 ;

  yprTable.setPosition(435,510)
          .showTable()
          .pushData(ypr)
          ;

  // 分别画出角速度、加速度和欧拉角的折线图
  angSpeedWF.setPosition(700,115)
            .setSize(430,125)
            .setRange(1000)
            .setUnit(unitX,"w / "+angSpeedUnit)
            .showCoord()
            .pushData(angSpeed)
            ; 
            
  accelSpeedWF.setPosition(700,315)
              .setSize(430,125)
              .setRange(20)
              .setUnit(unitX,"a / "+accelSpeedUnit)
              .showCoord()
              .pushData(accelSpeed)
              ;
  yprWF.setPosition(700,515)
       .setSize(430,125)
       .setRange(360)
       .setUnit(unitX,"e / "+yprUnit)
       .showCoord()
       .pushData(ypr) 
       ;
  popMatrix();  
}

// 画六足躯干
void drawBody(float x1, float y1, float x2, float y2, float z){
  pushMatrix();
  // 旋转之后的坐标系为 向左为x,向里为y,向上为z，
  // 所以如果之前得到的数据是在右手笛卡尔下的，
  // 只需要将 x轴的数据变为相反数即可。
  rotateX(PI/2);
  rotateZ(PI);

  // 上位机的视觉需要
  rotateZ(-PI/10);
  rotateY(-PI/20); 
  noStroke();
  // 顶面
  beginShape();
    fill(212, 220, 240);
      vertex(x1, y1, z);
      vertex(x2, y2, z);

      vertex(-x2, y2, z);
      vertex(-x1, y1, z);

      vertex(-x1, -y1, z);
      vertex(-x2, -y2, z);

      vertex(x2, -y2, z);
      vertex(x1, -y1, z);
  endShape(CLOSE);

  
  strokeWeight(3);
    stroke(#55AAF7);
    line(0,0,z,-30,0,z); //-x

    stroke(#73BD49);
    line(0,0,z,0,60,z); // +y

    stroke(#F19030);
    line(0,0,z,0,0,z+30); //+z
  stroke(0);
  strokeWeight(1);

  // 底面
  beginShape();
    fill(100, 100, 100);
      vertex(x1, y1, -z);
      vertex(x2, y2, -z);

      vertex(-x2, y2, -z);
      vertex(-x1, y1, -z);

      vertex(-x1, -y1, -z);
      vertex(-x2, -y2, -z);

      vertex(x2, -y2, -z);
      vertex(x1, -y1, -z);
  endShape(CLOSE);

  // 画棱边
  beginShape(QUAD_STRIP);
    fill(255);
    stroke(100);
    strokeWeight(1.5);
      // 象限 1
      vertex(x1, y1, z);  
      vertex(x1, y1, -z);

    fill(252,72,71);    
      vertex(x2, y2, z);  
      vertex(x2, y2, -z); 

      // 象限 2
  
      vertex(-x2, y2, z); 
      vertex(-x2, y2, -z);    
    fill(255);
      vertex(-x1, y1, z); 
      vertex(-x1, y1, -z);
  

      // 象限 3
      vertex(-x1, -y1, z);    
      vertex(-x1, -y1, -z);
      vertex(-x2, -y2, z);    
      vertex(-x2, -y2, -z);   

      // 象限 4
      vertex(x2, -y2, z);
      vertex(x2, -y2, -z);    
      vertex(x1, -y1, z);
      vertex(x1, -y1, -z);

     vertex(x1, y1, z);  
     vertex(x1, y1, -z); 
    stroke(0);
    strokeWeight(1);        
  endShape(); 
  popMatrix();
}

// 串口列表点击事件
void portList(int n) {

  // 如果之前已有串口打开，则关闭。
  if(serialPort != null){
    serialPort.stop();
    serialPort = null;
    println("Stopped the previous serial port");
  }

  String currentPortName = "" + cp5.get(ScrollableList.class, "portList").getItem(n).get("name");
  
  // 打开所选串口
  try{
    serialPort = new Serial(this, Serial.list()[n], BAUD_RATE);
    // serialPort.write('r');
    serialPort.bufferUntil('\n');
    println("Succss: connect the serial port: " + currentPortName);
  }catch(Exception e){
    System.err.println("Error: can not connect the serial port: " + currentPortName);
  }

}

// 步态列表点击事件
void gaitList(int n){
  if(serialPort != null){
    String currentGainName = "" + cp5.get(ScrollableList.class, "gaitList").getItem(n).get("name");
    println("Begin "+currentGainName);

    serialPort.write(HEADER_S);
    serialPort.write(GAIT);
    serialPort.write(n+1);
    println("Sended a message: " + HEADER_S + GAIT +(n+1));
  }else{
    println("Error: Please select a useful serial port at first.");
  }
}

// 串口事件，进行数据校验，对正确数据进行存储
// 接收的数据格式为 H,a[0], a[1], a[2], w[0], w[1], w[2], Angle[0], Angle[1], Angle[2],/n
void serialEvent(Serial port) {
  String myString = port.readStringUntil('\n');
  myString = trim(myString);
  // println("Received a message:" + myString);

  if(myString.startsWith(HEADER_R)){
    myString= myString.substring(2);
    float sensors[] = float(split(myString, ','));
    angSpeed[0] = sensors[0];
    angSpeed[1] = sensors[1];
    angSpeed[2] = sensors[2];

    accelSpeed[0] = sensors[3];
    accelSpeed[1] = sensors[4];
    accelSpeed[2] = sensors[5];

    ypr[0] = sensors[8]; // 偏航角，绕z轴的角度
    ypr[1] = sensors[6]; // 俯仰角，绕x轴的角度 //<>//
    ypr[2] = sensors[7]; // 横滚角，绕y轴的角度

    // 连接上位机后，如果缓存第一次的偏航角，
    // 然后以后的偏航角都减去这个值，
    // 则相当于第一次连接时，芯片y轴的指向被定偏航参考轴
    
    if(counter<2){
     firstYaw = sensors[8];
     firstRecordTime = millis()/1000.0;
     //output = createWriter(fileName + ".csv");
    }
    ypr[0] = keepDecimal(sensors[8]- firstYaw,2);
    counter++; // 用于记录从下位机接收有效数据的次数6630
 //<>//
    float time = millis()/1000.0 - firstRecordTime; //<>//
    cacheData(keepDecimal(time, 2), angSpeed, accelSpeed, ypr);
  }
  //else if(myString.startsWith("#")){
  //  println("Received a message from arduino:" + myString);
  //} // 测试下位机能否收到上位机的步态命令
}

void cacheData(float time, float[] angSpeed, float[] accelSpeed, float[] ypr){
  TableRow newRow;
  newRow = dataRecord.addRow();
  newRow.setFloat("time", time);
  newRow.setFloat("Wx", angSpeed[0]);
  newRow.setFloat("Wy", angSpeed[1]); //<>//
  newRow.setFloat("Wz", angSpeed[2]);

  newRow.setFloat("Ax", accelSpeed[0]);
  newRow.setFloat("Ay", accelSpeed[1]);
  newRow.setFloat("Az", accelSpeed[2]);

  newRow.setFloat("Yaw", ypr[0]);
  newRow.setFloat("Pitch", ypr[1]);
  newRow.setFloat("Roll", ypr[2]);
}
void saveData2File(Table table, String path){
  try{
    saveTable(table, path);
  }catch (Exception e) {
    println("Error: can't save data to the path "+ path);
  }
}
void keyPressed(){
  if(key == CODED && keyCode == DOWN){
    Date now = new Date();
    fileName = fnameFormat.format(now);
    saveData2File(dataRecord, "data/"+fileName+".csv");
  }
}
// 保留n位小数
float keepDecimal(float data, int place){
  return (float)(Math.round(data*pow(10, place))/pow(10, place));
}