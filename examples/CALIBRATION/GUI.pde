ControlP5 cp5;
Slider2D cPos;
PVector guiPos;

void setupGui() {
  cp5 = new ControlP5(this);
  cp5.setFont(createFont("Courier", 16));
  
  guiPos = new PVector(kinect.depthWidth()+60, 60);
  
  cPos = cp5.addSlider2D("chessPosition")
      .setPosition(guiPos.x, guiPos.y+30)
      .setSize(360, 300)
      .setArrayValue(new float[]{150, 120});
  
  cp5.addSlider("cwidth")
     .setPosition(guiPos.x, guiPos.y+360)
     .setHeight(30)
     .setWidth(345)
     .setRange(2, 800)
     .setLabel("Size"); 
  
  cp5.addToggle("isSearchingBoard")
     .setPosition(guiPos.x, guiPos.y+415)
     .setSize(105, 32)
     .setMode(ControlP5.SWITCH)
     .setLabel("Search");

  cp5.addButton("addPointPair")
     .setPosition(guiPos.x+135, guiPos.y+415)
     .setSize(105, 32)
     .setLabel("Add pair");

  cp5.addButton("clearPoints")
     .setPosition(guiPos.x+270, guiPos.y+415)
     .setSize(105, 32)
     .setLabel("Clear");
  
  cp5.addButton("calibrate")
     .setPosition(guiPos.x, guiPos.y+480)
     .setSize(105, 32);

  cp5.addButton("saveC")
     .setPosition(guiPos.x+135, guiPos.y+480)
     .setSize(105, 32)
     .setLabel("Save");
     
   cp5.addButton("loadC")
     .setPosition(guiPos.x+270, guiPos.y+480)
     .setSize(105, 32)
     .setLabel("Load");  

  cp5.addToggle("testingMode")
     .setPosition(15, 50+kinect.depthHeight())
     .setSize(105, 32)
     .setMode(ControlP5.SWITCH)
     .setLabel("Test Mode");

  cp5.addToggle("viewRgb")
     .setPosition(140, 50+kinect.depthHeight())
     .setSize(125, 32)
     .setMode(ControlP5.SWITCH)
     .setLabel("RGB");     
}

void controlEvent(ControlEvent theControlEvent) {
  try {
    if (theControlEvent.isFrom("chessPosition")) {
      cx = (int) map(cPos.arrayValue()[0], 0, 100, 0, pWidth);
      cy = (int) map(cPos.arrayValue()[1], 0, 100, 0, pHeight);
    }  
  } catch(Exception e) {};
}
