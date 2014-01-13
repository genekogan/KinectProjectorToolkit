import gab.opencv.*;
import SimpleOpenNI.*;
import KinectProjectorToolkit.*;

SimpleOpenNI kinect;
OpenCV opencv;
KinectProjectorToolkit kpc;
ArrayList<ProjectedContour> projectedContours;
PVector[] pts;

int NUM_PTS = 256;
float LERP_RATE = 0.1;

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
  kpc.setContourSmoothness(3);  
  
  pts = new PVector[NUM_PTS];
  for (int i=0; i<NUM_PTS; i++)
    pts[i] = new PVector(width/2, height/2);
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
  
  // make for arbitrary number of people
  
  // draw projected contours
  background(0);
  for (int i=0; i<projectedContours.size(); i++) {
    ProjectedContour projectedContour = projectedContours.get(i);
    ArrayList<PVector> contour = projectedContour.getProjectedContours();
    for (int j=0; j<NUM_PTS; j++) {
      float ang = map(j, 0, NUM_PTS, 0, TWO_PI);
      //float ang = (0.01*frameCount + map(j, 0, NUM_PTS, 0, TWO_PI)) % TWO_PI;
      PVector p1 = new PVector(width/2 + width * cos(ang), height/2 + width * sin(ang));
      PVector p2 = contour.get((int) map(j, 0, NUM_PTS-1, 0, contour.size()-1));
      pts[j] = PVector.lerp(pts[j], p2, LERP_RATE); //new PVector(lerp(pts[j].x, p2.x, LERP_RATE), lerp(pts[j].y, p2.y, LERP_RATE));      
      strokeWeight(3.0 / projectedContours.size());
      stroke(255, 180);
      line(p1.x, p1.y, pts[j].x, pts[j].y);      
    }
  }
}