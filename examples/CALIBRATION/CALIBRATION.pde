//==========================================================
// set resolution of your projector image/second monitor
// and name of your calibration file-to-be
int pWidth = 1024;
int pHeight = 768; 
String calibFilename = "calibration.txt";


//==========================================================
//==========================================================

import javax.swing.JFrame;
import SimpleOpenNI.*;
import gab.opencv.*;
import controlP5.*;
import Jama.*;

SimpleOpenNI kinect;
OpenCV opencv;
ChessboardFrame frameBoard;
ChessboardApplet ca;
PVector[] depthMap;
ArrayList<PVector> foundPoints = new ArrayList<PVector>();
ArrayList<PVector> projPoints = new ArrayList<PVector>();
ArrayList<PVector> ptsK, ptsP;
PVector testPoint, testPointP;
boolean isSearchingBoard = false;
boolean calibrated = false;
boolean testingMode = false;
int cx, cy, cwidth;

void setup() 
{
  size(1200, 768);
  textFont(createFont("Courier", 24));
  frameBoard = new ChessboardFrame();

  // set up kinect
  kinect = new SimpleOpenNI(this);
  kinect.setMirror(false);
  kinect.enableDepth();
  //kinect.kinect.enableIR();
  kinect.enableRGB();
  kinect.alternativeViewPointDepthToImage();
  opencv = new OpenCV(this, kinect.depthWidth(), kinect.depthHeight());

  // matching pairs
  ptsK = new ArrayList<PVector>();
  ptsP = new ArrayList<PVector>();
  testPoint = new PVector();
  testPointP = new PVector();
  setupGui();
}

void draw() 
{
  // draw chessboard onto scene
  projPoints = drawChessboard(cx, cy, cwidth);

  // update kinect and look for chessboard
  kinect.update();
  depthMap = kinect.depthMapRealWorld();
  opencv.loadImage(kinect.rgbImage());
  //opencv.loadImage(kinect.irImage());
  opencv.gray();

  if (isSearchingBoard)
    foundPoints = opencv.findChessboardCorners(4, 3);

  drawGui();
}

void drawGui() 
{
  background(0, 100, 0);

  // draw the RGB image
  pushMatrix();
  translate(30, 120);
  textSize(22);
  fill(255);
  //image(kinect.irImage(), 0, 0);
  image(kinect.rgbImage(), 0, 0);
  
  // draw chessboard corners, if found
  if (isSearchingBoard) {
    int numFoundPoints = 0;
    for (PVector p : foundPoints) {
      if (getDepthMapAt((int)p.x, (int)p.y).z > 0) {
        fill(0, 255, 0);
        numFoundPoints += 1;
      }
      else  fill(255, 0, 0);
      ellipse(p.x, p.y, 5, 5);
    }
    if (numFoundPoints == 12)  guiAdd.show();
    else                       guiAdd.hide();
  }
  else  guiAdd.hide();
  if (calibrated && testingMode) {
    fill(255, 0, 0);
    ellipse(testPoint.x, testPoint.y, 10, 10);
  }
  popMatrix();

  // draw GUI
  pushMatrix();
  pushStyle();
  translate(kinect.depthWidth()+70, 40);
  fill(0);
  rect(0, 0, 450, 680);
  fill(255);
  text(ptsP.size()+" pairs", 26, guiPos.y+525);
  popStyle();
  popMatrix();
}

ArrayList<PVector> drawChessboard(int x0, int y0, int cwidth) {
  ArrayList<PVector> projPoints = new ArrayList<PVector>();
  int cheight = (int)(cwidth * 0.8);
  ca.background(255);
  ca.fill(0);
  for (int j=0; j<4; j++) {
    for (int i=0; i<5; i++) {
      int x = int(x0 + map(i, 0, 5, 0, cwidth));
      int y = int(y0 + map(j, 0, 4, 0, cheight));
      if (i>0 && j>0)  projPoints.add(new PVector((float)x/pWidth, (float)y/pHeight));
      if ((i+j)%2==0)  ca.rect(x, y, cwidth/5, cheight/4);
    }
  }  
  ca.fill(0, 255, 0);
  if (calibrated)  
    ca.ellipse(testPointP.x, testPointP.y, 20, 20);  
  ca.redraw();
  return projPoints;
}


void addPointPair() {
  if (projPoints.size() == foundPoints.size()) {
    for (int i=0; i<projPoints.size(); i++) {
      ptsP.add( projPoints.get(i) );
      ptsK.add( getDepthMapAt((int) foundPoints.get(i).x, (int) foundPoints.get(i).y) );
    }
  }
  guiCalibrate.show();
  guiClear.show();
}

PVector getDepthMapAt(int x, int y) {
  PVector dm = depthMap[kinect.depthWidth() * y + x];
  return new PVector(dm.x, dm.y, dm.z);
}

void clearPoints() {
  ptsP.clear();
  ptsK.clear();
  guiSave.hide();
}

void saveC() {
  saveCalibration(calibFilename); 
}

void loadC() {
  println("load");
  loadCalibration(calibFilename);
  guiTesting.addItem("Testing Mode", 1);
}

void mousePressed() {
  if (calibrated && testingMode) {
    testPoint = new PVector(constrain(mouseX-30, 0, kinect.depthWidth()-1), 
                            constrain(mouseY-120, 0, kinect.depthHeight()-1));
    int idx = kinect.depthWidth() * (int) testPoint.y + (int) testPoint.x;
    testPointP = convertKinectToProjector(depthMap[idx]);
  }
}
