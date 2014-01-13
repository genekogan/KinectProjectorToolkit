void setupGUI() 
{
  cp5 = new ControlP5(this);
  cp5.setFont(createFont("Courier", 16));
    
  // blobs  
  cp5.addSlider("blobDilate")
     .setPosition(50, 50).setSize(300, 20).setRange(0.1, 2.0).setValue(1.0);

  cp5.addRadioButton("sampling")
      .setPosition(50, 100).setSize(40, 20).setItemsPerRow(3).setSpacingColumn(70)
      .addItem("last", 0).addItem("sine", 1).addItem("mousex", 2);
  
  cp5.addNumberbox("numframes")
      .setPosition(400, 100).setSize(40, 20).setScrollSensitivity(1).setRange(1, 300).setValue(60);  

  // rendering toggles
  cp5.addToggle("renderBody").setPosition(50, 160).setSize(100,20).setValue(true);
  cp5.addToggle("renderRibbons").setPosition(280, 160).setSize(100,20).setValue(true);
  
  // shader selection
  cp5.addRadioButton("shader")
      .setPosition(50, 240).setSize(40, 20).setItemsPerRow(4).setSpacingColumn(70)
      .addItem("blob", 0).addItem("drip", 1).addItem("noise", 2).addItem("waves", 3);
  
  // shader selection
  cp5.addRadioButton("bground")
      .setPosition(50, 300).setSize(40, 20).setItemsPerRow(3).setSpacingColumn(85)
      .addItem("bgblack", 0).addItem("bgwhite", 1).addItem("bgblob", 2).addItem("bgdrip", 3).addItem("bgnoise", 4).addItem("bgwaves", 5);
  
  // ribbons
  cp5.addSlider("ribbonSpawnRate")
     .setPosition(50, 375).setSize(300, 20).setRange(0, 10).setValue(1);
  cp5.addRange("ribbonMaxAge")
     .setPosition(50, 400).setSize(300, 20).setHandleSize(10).setRange(3, 60).setRangeValues(20, 30);
  cp5.addRange("ribbonLength")
     .setPosition(50, 425).setSize(300, 20).setHandleSize(10).setRange(4, 50).setRangeValues(10, 20);
  cp5.addRange("ribbonSkip")
     .setPosition(50, 450).setSize(300, 20).setHandleSize(10).setRange(1, 8).setRangeValues(1, 2);
  cp5.addRange("ribbonSpeed")
     .setPosition(50, 475).setSize(300, 20).setHandleSize(10).setRange(1, 12).setRangeValues(1, 10);
  cp5.addRange("ribbonMargin")
     .setPosition(50, 500).setSize(300, 20).setHandleSize(10).setRange(0, 240).setRangeValues(30, 60);
  cp5.addRange("ribbonNoiseFactor")
     .setPosition(50, 525).setSize(300, 20).setHandleSize(10).setRange(0, 0.2).setRangeValues(0.01, 0.1);
  cp5.addRange("ribbonThickness")
     .setPosition(50, 550).setSize(300, 20).setHandleSize(10).setRange(0.5, 5.0).setRangeValues(1, 3);
  cp5.addRange("ribbonAlpha")
     .setPosition(50, 575).setSize(300, 20).setHandleSize(10).setRange(0, 255).setRangeValues(150, 250);
  cp5.addToggle("ribbonIsCurved").setPosition(50, 600).setSize(100,20).setValue(false);
  cp5.addToggle("ribbonIsWhite").setPosition(250, 600).setSize(100,20).setValue(true);
}

void controlEvent(ControlEvent theEvent) {
  if(theEvent.getName().equals("sampling"))
    samplingMode = (int) theEvent.group().value();
  else if(theEvent.getName().equals("shader")) {
    idxShader = (int) theEvent.group().value();
    setupShader(idxShader);
  }
  else if(theEvent.getName().equals("bground")) {
    idxBg = (int) theEvent.group().value();
    setupBackground(idxBg);
  }
}