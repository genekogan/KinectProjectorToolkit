import gab.opencv.*;
import SimpleOpenNI.*;
import KinectProjectorToolkit.*;

SimpleOpenNI kinect;
OpenCV opencv;
KinectProjectorToolkit kpc;
ArrayList<ProjectedContour> projectedContours;
PGraphics pg;
PShader shade;

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
  
  // load shader and PGraphics
  pg = createGraphics(600, 800, P2D);
  shade = loadShader("waves.glsl");
  shade.set("resolution", float(pg.width), float(pg.height));
  pg.shader(shade);
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
  
  // draw PGraphics object with shader
  shade.set("time", millis()/1000.0);
  pg.beginDraw();
  pg.rect(0, 0, pg.width, pg.height);
  pg.endDraw();
  
  // draw projected contours
  background(0);
  for (int i=0; i<projectedContours.size(); i++) {
    ProjectedContour projectedContour = projectedContours.get(i);
    beginShape();
    texture(pg);
    for (PVector p : projectedContour.getProjectedContours()) {
      PVector t = projectedContour.getTextureCoordinate(p);
      vertex(p.x, p.y, pg.width * t.x, pg.height * t.y);
    }
    endShape();
  }
}
