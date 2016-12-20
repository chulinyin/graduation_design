class DisplayTable{
	String tableName;
	String[] dataName;
	String unit;
	float x;
	float y;

  DisplayTable(String _tableName, String[] _dataName, String _unit){
  	tableName = _tableName;
  	dataName = _dataName;
  	unit =_unit;
  }

  DisplayTable setPosition(float _x, float _y){
    x = _x;
    y = _y;
    return this;
  }
  
  DisplayTable showTable(){
  	fill(0);
  	text(tableName, x-10, y);

  	stroke(#55AAF7);
    strokeWeight(2.5);
  	line(x, y+32, x+10, y+32);
  	stroke(#73BD49);
  	line(x, y+72, x+10, y+72);
  	stroke(#F19030);
  	line(x, y+112, x+10, y+112);
    strokeWeight(1);

  	//fill(0);
  	//text(dataName[0] + ":  " + "---" + "  " + unit,  x+26, y+40);
  	//text(dataName[1] + ":  " + "---" + "  " + unit,  x+26, y+80);
  	//text(dataName[2] + ":  " + "---" + "  " + unit,  x+26, y+120);
  	return this;
  }
  
  void pushData(float[]data){
    fill(0);
    text(dataName[0] + ":  " + data[0] + "  " + unit,  x+26, y+40);
    text(dataName[1] + ":  " + data[1] + "  " + unit,  x+26, y+80);
    text(dataName[2] + ":  " + data[2] + "  " + unit,  x+26, y+120);
  }
}