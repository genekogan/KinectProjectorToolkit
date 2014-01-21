ControlP5 cp5;
Slider2D guiCpos;
Slider guiCwidth;
Toggle guiSearching;
Button guiAdd, guiClear, guiCalibrate, guiSave, guiLoad;
RadioButton guiTesting;
PVector guiPos;

void setupGui() {
  cp5 = new ControlP5(this);
  cp5.setFont(createFont("Courier", 16));
  
  guiPos = new PVector(kinect.depthWidth()+90, 60);
  
  guiCpos = cp5.addSlider2D("chessPosition")
      .setLabel("Chessboard Position")
      .setPosition(guiPos.x, guiPos.y+15)
      .setSize(400, 360)
      .setArrayValue(new float[]{0, 0});
  
  guiCwidth = cp5.addSlider("cwidth")
     .setPosition(guiPos.x, guiPos.y+420)
     .setHeight(30)
     .setWidth(345)
     .setRange(5, 800)
     .setValue(100)
     .setLabel("Size"); 
  
  guiSearching = cp5.addToggle("isSearchingBoard")
     .setPosition(guiPos.x, guiPos.y+470)
     .setSize(125, 32)
     //.setMode(ControlP5.SWITCH)
     .setLabel("Searching?");

  guiAdd = cp5.addButton("addPointPair")
     .setLabel("Add pair")
     .setPosition(guiPos.x+150, guiPos.y+540)
     .setSize(105, 32)
     .hide();

  guiClear = cp5.addButton("clearPoints")
     .setPosition(guiPos.x+300, guiPos.y+540)
     .setSize(105, 32)
     .setLabel("Clear")
     .hide();
  
  guiCalibrate = cp5.addButton("calibrate")
     .setPosition(guiPos.x, guiPos.y+600)
     .setSize(105, 32)
     .hide();

  guiSave = cp5.addButton("saveC")
     .setPosition(guiPos.x+150, guiPos.y+600)
     .setSize(105, 32)
     .setLabel("Save")
     .hide();
     
  guiLoad = cp5.addButton("loadC")
     .setPosition(guiPos.x+300, guiPos.y+600)
     .setSize(105, 32)
     .setLabel("Load");  
     
  guiTesting = cp5.addRadioButton("mode")
      .setPosition(35, 30)
      .setSize(80, 50)
      .setItemsPerRow(2)
      .setSpacingColumn(250)
      .addItem("Calibration Mode", 0)
      .activate(0);
}

void controlEvent(ControlEvent theControlEvent) {
  try {
    if (theControlEvent.isFrom("chessPosition")) {
      cx = (int) map(guiCpos.arrayValue()[0], 0, 100, 0, pWidth);
      cy = (int) map(guiCpos.arrayValue()[1], 0, 100, 0, pHeight);
    }  
  } catch(Exception e) {
    println(e);
  }
  if (theControlEvent.isFrom("mode")) {
    if (theControlEvent.getValue() == 1.0) {
      testingMode = true;
    }
  }
}