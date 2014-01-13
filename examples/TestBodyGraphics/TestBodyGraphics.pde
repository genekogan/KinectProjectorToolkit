import gab.opencv.*;
import SimpleOpenNI.*;
import KinectProjectorToolkit.*;

SimpleOpenNI kinect;
OpenCV opencv;
KinectProjectorToolkit kpc;
ArrayList<ProjectedContour> projectedContours;
ArrayList<PGraphics> projectedGraphics;

void setup()
{
  size(displayWidth, displayHeight, P2D); 

  // setup Kinect
  kinect = new SimpleOpenNI(this); 
  kinect.enableDepth();
  kinect.enableUser();
  kinect.alternativeViewPointDepthToImage();
  
  // setup OpenCV
  opencv = new OpenCV(this, kinect.depthWidth(), kinect.depthHeight());

  // setup Kinect Projector Toolkit
  kpc = new KinectProjectorToolkit(this, kinect.depthWidth(), kinect.depthHeight());
  kpc.loadCalibration("calibration.txt");
  kpc.setContourSmoothness(4);
  
  projectedGraphics = initializeProjectedGraphics();
}

void draw()
{  
  kinect.update();  
  kpc.setDepthMapRealWorld(kinect.depthMapRealWorld()); 
  kpc.setKinectUserImage(kinect.userImage());
  opencv.loadImage(kpc.getImage());
  
  // get projected contours
  projectedContours = new ArrayList<ProjectedContour>();
  ArrayList<Contour> contours = opencv.findContours();
  for (Contour contour : contours) {
    if (contour.area() > 2000) {
      ArrayList<PVector> cvContour = contour.getPoints();
      ProjectedContour projectedContour = kpc.getProjectedContour(cvContour, 1.0);
      projectedContours.add(projectedContour);
    }
  }
  
  // draw projected contours
  background(0);
  for (int i=0; i<projectedContours.size(); i++) {
    ProjectedContour projectedContour = projectedContours.get(i);
    PGraphics pg = projectedGraphics.get(i%3);    
    beginShape();
    texture(pg);
    for (PVector p : projectedContour.getProjectedContours()) {
      PVector t = projectedContour.getTextureCoordinate(p);
      vertex(p.x, p.y, pg.width * t.x, pg.height * t.y);
    }
    endShape();
  }
}

ArrayList<PGraphics> initializeProjectedGraphics() {
  ArrayList<PGraphics> projectedGraphics = new ArrayList<PGraphics>();
  for (int p=0; p<3; p++) {
    color col = color(random(255), random(255), random(255));
    PGraphics pg = createGraphics(800, 400, P2D);
    pg.beginDraw();
    pg.background(random(255));
    pg.noStroke();
    for (int i=0; i<100; i++) {
      pg.fill(red(col)+(int)random(-30,30), green(col)+(int)random(-30,30), blue(col)+(int)random(-30,30)); 
      if      (p==0)  pg.ellipse(random(pg.width), random(pg.height), random(200), random(200));
      else if (p==1)  pg.rect(random(pg.width), random(pg.height), random(200), random(200));
      else if (p==2)  pg.triangle(random(pg.width), random(pg.height), random(pg.width), random(pg.height), random(pg.width), random(pg.height));
    }
    pg.endDraw();
    projectedGraphics.add(pg);
  }  
  return projectedGraphics;
}