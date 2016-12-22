#include <Wire.h>
#include <JY901.h>
/*
Test on Uno R3.
JY901   UnoR3
TX <---> 0(Rx)
*/

int a[3], w[3], Angle[3];

void setup() 
{
  Serial.begin(9600);
}

void loop() 
{

  /*
  //print received data. Data was received in serialEvent;
  Serial.print("Time:20");Serial.print(JY901.stcTime.ucYear);Serial.print("-");Serial.print(JY901.stcTime.ucMonth);Serial.print("-");Serial.print(JY901.stcTime.ucDay);
  Serial.print(" ");Serial.print(JY901.stcTime.ucHour);Serial.print(":");Serial.print(JY901.stcTime.ucMinute);Serial.print(":");Serial.println((float)JY901.stcTime.ucSecond+(float)JY901.stcTime.usMiliSecond/1000);
               
  Serial.print("Acc:");Serial.print((float)JY901.stcAcc.a[0]/32768*16);Serial.print(" ");Serial.print((float)JY901.stcAcc.a[1]/32768*16);Serial.print(" ");Serial.println((float)JY901.stcAcc.a[2]/32768*16);
  
  Serial.print("Gyro:");Serial.print((float)JY901.stcGyro.w[0]/32768*2000);Serial.print(" ");Serial.print((float)JY901.stcGyro.w[1]/32768*2000);Serial.print(" ");Serial.println((float)JY901.stcGyro.w[2]/32768*2000);
  
  Serial.print("Angle:");Serial.print((float)JY901.stcAngle.Angle[0]/32768*180);Serial.print(" ");Serial.print((float)JY901.stcAngle.Angle[1]/32768*180);Serial.print(" ");Serial.println((float)JY901.stcAngle.Angle[2]/32768*180);
  
  Serial.print("Mag:");Serial.print(JY901.stcMag.h[0]);Serial.print(" ");Serial.print(JY901.stcMag.h[1]);Serial.print(" ");Serial.println(JY901.stcMag.h[2]);
  
  Serial.print("Pressure:");Serial.print(JY901.stcPress.lPressure);Serial.print(" ");Serial.println((float)JY901.stcPress.lAltitude/100);
  
  Serial.print("DStatus:");Serial.print(JY901.stcDStatus.sDStatus[0]);Serial.print(" ");Serial.print(JY901.stcDStatus.sDStatus[1]);Serial.print(" ");Serial.print(JY901.stcDStatus.sDStatus[2]);Serial.print(" ");Serial.println(JY901.stcDStatus.sDStatus[3]);
  
  Serial.print("Longitude:");Serial.print(JY901.stcLonLat.lLon/10000000);Serial.print("Deg");Serial.print((double)(JY901.stcLonLat.lLon % 10000000)/1e5);Serial.print("m Lattitude:");
  Serial.print(JY901.stcLonLat.lLat/10000000);Serial.print("Deg");Serial.print((double)(JY901.stcLonLat.lLat % 10000000)/1e5);Serial.println("m");
  
  Serial.print("GPSHeight:");Serial.print((float)JY901.stcGPSV.sGPSHeight/10);Serial.print("m GPSYaw:");Serial.print((float)JY901.stcGPSV.sGPSYaw/10);Serial.print("Deg GPSV:");Serial.print((float)JY901.stcGPSV.lGPSVelocity/1000);Serial.println("km/h");
  
  Serial.println("");
  delay(500);
  */
 sendData();

}

/*
  SerialEvent occurs whenever a new data comes in the
 hardware serial RX.  This routine is run between each
 time loop() runs, so using delay inside loop can delay
 response.  Multiple bytes of data may be available.
 */
void serialEvent() 
{
  while (Serial.available()) 
  {
    JY901.CopeSerialData(Serial.read()); //Call JY901 data cope function
  }
}
// 发送的数据格式为 H,a[0], a[1], a[2], w[0], w[1], w[2], Angle[0], Angle[1], Angle[2],/n
void sendData(){
  a[0] = (int)JY901.stcAcc.a[0]/32768*16;
  a[1] = (int)JY901.stcAcc.a[1]/32768*16;
  a[2] = (int)JY901.stcAcc.a[2]/32768*16;
  w[0] = JY901.stcGyro.w[0]/32768*2000;
  w[1] = JY901.stcGyro.w[1]/32768*2000;
  w[2] = JY901.stcGyro.w[2]/32768*2000;
  Angle[0] = (int)JY901.stcAngle.Angle[0]/32768*180;
  Angle[1] = (int)JY901.stcAngle.Angle[1]/32768*180;
  Angle[2] = (int)JY901.stcAngle.Angle[2]/32768*180;

  char data_6050[100];
  sprintf(data_6050, "%d,%d,%d,%d,%d,%d,%d,%d,%d", a[0], a[1], a[2], w[0], w[1], w[2], Angle[0], Angle[1], Angle[2]);
  Serial.print('H'); //用来标记消息开始的特殊开头
  Serial.print(",");
  Serial.println(data_6050);
  delay(50);
}

