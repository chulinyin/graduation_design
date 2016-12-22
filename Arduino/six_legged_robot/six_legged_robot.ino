// ==========================================================
// ====                六足机器人综合程序                        ====
// ==========================================================



// ======   各模块与 Arduino Mega2560 的连接方式    ======
// 左侧为模块引脚，右侧为2560引脚
/** 
 * LCD连接:
 * 
 * LCD  Arduino
 * PIN1 --> GND
 * PIN2 --> 5V
 * RS(CS) --> 8; 
 * RW(SID)--> 9; 
 * EN(CLK) --> 4;
 * PIN15 PSB --> GND;
 * BLA --> 5V
 * BLK --> GND
 */

/**
 * E34无线模块连接：
 * 
 * M0 --> 2;
 * M1 --> 3;
 * VCC --> 5V; 
 * GND --> GND; 
 * TX --> 0(RX0);
 * RX --> 1(TX0);
 */

/**
 * MPU9250九轴陀螺仪连接，使用串口通信
 * VCC --> 3.3/5 V; 
 * GND --> GND; 
 * TX --> 15(RX3);
*/

/**
 * MPU9250九轴陀螺仪连接，使用I2C通信
 * VCC --> 5 V; 
 * GND --> GND; 
 * SCL --> SCL(21);
 * SDL --> SDL(20)
 * INT --> 2、3、21、20、19、18 皆可，
*/

/**
 * V32舵机板连接
 * VS --> 5 V;
 * GND --> GND; //舵机板供电
 * RX --> 18(TX1);
 * 5V --> 5V //在无USB供电的情况下，与单片机连接。切勿与USB同时供电
 * GND --> GND  //与单片机共地
 */

// ======   ／各模块与 Arduino mega2560 的连接方式    ======


// ======   各模块数据初始化定义    ======

/* LCD模块的数据初始化定义  */
#include <Wire.h>
#include <JY901.h>
#include "LCD12864RSPI.h"
#define AR_SIZE( a ) sizeof( a ) / sizeof( a[0] )
 
unsigned char show0[]={0xC8,0xFD,0xD6,0xA7,0xB3,0xC5,0xD7,0xE3};  //三支撑足
unsigned char show1[]={0xCB,0xC4,0xD6,0xA7,0xB3,0xC5,0xD7,0xE3};  //四支撑足
unsigned char show2[]={0xCE,0xE5,0xD6,0xA7,0xB3,0xC5,0xD7,0xE3};  //五支撑足
unsigned char show3[]={0xD6,0xB1,0xD0,0xD0,0xB2,0xBD,0xCC,0xAC};  //直行步态
unsigned char show4[]={0xBA,0xE1,0xD0,0xD0,0xB2,0xBD,0xCC,0xAC};  //横行步态
unsigned char show5[]={0xD0,0xFD,0xD7,0xAA,0xB2,0xBD,0xCC,0xAC};  //旋转步态
unsigned char show6[]="km/h";
char str[4];  //定义速度值存储数组，4位，其中3位为数字，1位为小数点
double zc=0;  //支撑足转换
double zc_last=0;
double bt=0;  //步态转换
double bt_last =0;

/* 9250模块的数据初始化定义  */  
unsigned char Re_buf[11],counter=0; // 缓存接收到的9250数据
unsigned char sign=0;
float a[3],w[3],Angle[3],T; //三轴加速度、角速度、角度；
// unsigned char count = 0; // 每隔50个点取样
char data_9250[512];    // 存储要发送到上位机的信息


/* E34模块的数据初始化定义  */  
int M0 = 2; 
int M1 = 3; //M0、M1定义E34工作模式

/* 接收上位机的步态指令定义  */  
#define HEADER_R '$'     // 数据头
#define GAINT 'G'        // 标记
#define MESSAGE_BYTES 3  // 一共有3个字节

// ====  ／各模块数据初始化定义   =====


void setup() {

  /* LCD初始化 */             
  LCDA.Initialise(); // 屏幕初始化
  delay(100);


  /* 串口波特率初始化 */ 
  Serial.begin(115200);//E34接收发送数据波特率
  Serial1.begin(9600);//舵机板9600接收数据波特率
  Serial3.begin(115200);//9250接收数据波特率


  // 将E34定义为透传模式
  pinMode(M0,OUTPUT);
  pinMode(M1,OUTPUT);
}

void loop() {

/* LCD步态速度显示 */
  //vspeed=w[1]*0.12; //计算当前速度
  if( zc_last!= zc){
    if(zc==1){     
      LCDA.DisplayString(1,2,show0,AR_SIZE(show0)); //第二行第三格开始，显示文字"三支撑足"
    }else if(zc==2){ 
      LCDA.DisplayString(1,2,show1,AR_SIZE(show1)); //第二行第三格开始，显示文字"四支撑足"
    }else if(zc==3){
      LCDA.DisplayString(1,2,show2,AR_SIZE(show2)); //第二行第三格开始，显示文字"五支撑足"
    }

    zc_last = zc;
  }
          
  if( bt_last!= bt){      
    if(bt==1){       
      LCDA.DisplayString(2,2,show3,AR_SIZE(show3)); //第三行第格三开始，显示文字"直行"
    }else if(bt==2){    
      LCDA.DisplayString(2,2,show4,AR_SIZE(show4)); //第三行第三格开始，显示文字"横行"
    }else if(bt==3){   
      LCDA.DisplayString(2,2,show5,AR_SIZE(show5)); //第三行第三格开始，显示文字"旋转"
    }

    bt_last = bt;
  }


  //将E34设置为透传模式
  digitalWrite(M0, LOW);
  digitalWrite(M1, LOW);

  // 向上位机发送9250数据
  sendData();

  // 接收上位机发送的数据,收到的数据格式为： $G0、$G1...
  if(Serial.available() >= MESSAGE_BYTES) { 
    if( Serial.read() == HEADER_R){
      char tag = Serial.read();
      if(tag == GAINT){
        int gait =Serial.read();   //读取上位机发送的指令
        RcvMsgAnalyse(gait);       //根据指令执行相应动作组         
      }
    }
  }
}


/**************************************
           读取9250数据
**************************************/
void serialEvent3() {
  while (Serial3.available()) {   
    JY901.CopeSerialData(Serial3.read()); //Call JY901 data cope function
  }
}

// 发送的数据格式为 H, w[0], w[1], w[2], a[0], a[1], a[2], Angle[0], Angle[1], Angle[2],/n
void sendData(){
  a[0] = (float)JY901.stcAcc.a[0]/32768*16;
  a[1] = (float)JY901.stcAcc.a[1]/32768*16;
  a[2] = (float)JY901.stcAcc.a[2]/32768*16;

  w[0] = (float)JY901.stcGyro.w[0]/32768*2000;
  w[1] = (float)JY901.stcGyro.w[1]/32768*2000;
  w[2] = (float)JY901.stcGyro.w[2]/32768*2000;

  Angle[0] = (float)JY901.stcAngle.Angle[0]/32768*180;
  Angle[1] = (float)JY901.stcAngle.Angle[1]/32768*180;
  Angle[2] = (float)JY901.stcAngle.Angle[2]/32768*180;

  Serial.print('H'); //用来标记消息开始的特殊开头
  Serial.print(",");

  Serial.print(w[0]);
  Serial.print(",");
  Serial.print(w[1]);
  Serial.print(",");
  Serial.print(w[2]);
  Serial.print(",");

  Serial.print(a[0]);
  Serial.print(",");
  Serial.print(a[1]);
  Serial.print(",");
  Serial.print(a[2]);
  Serial.print(",");

  Serial.print(Angle[0]);
  Serial.print(",");
  Serial.print(Angle[1]);
  Serial.print(",");
  Serial.println(Angle[2]);  
  delay(50); //1s发送20个数据
}
  
/*********************************************
      分析步态指令，使机器人执行相应的动作
**********************************************/
void RcvMsgAnalyse(int gaitSign){
  switch(gaitSign){
    case 1:
      Serial1.print("#1GC30\r\n");  //控制舵机执行动作组1（初始化）30次
      bt=0;
      break;
    
    case 2: 
      Serial1.print("#2GC30\r\n");  //控制舵机执行动作组2（三足直行）循环30次 
      bt=1;
      zc=1;     
      break;

    case 3:
      Serial1.print("#3GC30\r\n");  //控制舵机执行动作组3（四足直行）循环30次
      bt=1;
      zc=2;
      break;

    case 4:
      Serial1.print("#4GC30\r\n");  //控制舵机执行动作组4（五足直行）循环30次
      bt=1;
      zc=3;
      break;
    
    case 5:
      Serial1.print("#5GC30\r\n");  //控制舵机执行动作组5（三足平移）循环30次
      bt=2;
      zc=1;
      break;

    case 6:
      Serial1.print("#6GC30\r\n");  //控制舵机执行动作组6（四足平移）循环30次
      bt=2;
      zc=2;
      break;

    case 7:
      Serial1.print("#7GC30\r\n");  //控制舵机执行动作组7（五足平移）循环30次 
      bt=2;
      zc=3;
      break;

    case 8:
      Serial1.print("#8GC30\r\n");  //控制舵机执行动作组7（三足旋转）循环30次
      bt=3;
      zc=1;   
      break;

    case 9:
      Serial1.print("#9GC30\r\n");  //控制舵机执行动作组9（四足旋转）循环30次
      bt=3;
      zc=2;      
      break;

    case 10:
      Serial1.print("#10GC30\r\n");  //控制舵机执行动作组10（五足旋转）循环30次
      bt=3;
      zc=3;
      break;
  }
}

