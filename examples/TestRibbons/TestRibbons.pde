import gab.opencv.*;
import SimpleOpenNI.*;
import KinectProjectorToolkit.*;

SimpleOpenNI kinect;
OpenCV opencv;
KinectProjectorToolkit kpc;
ArrayList<ProjectedContour> projectedContours;
ArrayList<Ribbon> ribbons;

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
  
  // initialize ribbons
  ribbons = new ArrayList<Ribbon>();
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
      ProjectedContour projectedContour = kpc.getProjectedContour(cvContour, 1.2);
      projectedContours.add(projectedContour);
    }
  }
    
  // add a ribbon
  if (projectedContours.size() > 0)  addNewRibbons(3);
  
  background(0);
  
  // draw ribbons
  ArrayList<Ribbon> nextRibbons = new ArrayList<Ribbon>();
  for (Ribbon r : ribbons) {
    r.update();
    r.draw();
    if (r.age < r.maxAge)  nextRibbons.add(r);
  }
  ribbons = nextRibbons;
}

void addNewRibbons(int n) {
  for (int i=0; i<n; i++) {
    int p = (int) random(projectedContours.size());
    ArrayList<PVector> contourPoints = projectedContours.get(p).getProjectedContours();
    Ribbon newRibbon = new Ribbon(contourPoints);
    ribbons.add(newRibbon); 
  }
}