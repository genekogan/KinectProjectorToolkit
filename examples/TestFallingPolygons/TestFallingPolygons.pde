import gab.opencv.*;
import SimpleOpenNI.*;
import KinectProjectorToolkit.*;
import fisica.*;

SimpleOpenNI kinect;
OpenCV opencv;
KinectProjectorToolkit kpc;
ArrayList<ProjectedContour> projectedContours;
FWorld world;
ArrayList<FPoly> users;

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
  
  // setup physics
  Fisica.init(this);
  world = new FWorld();
  world.setGravity(0, 800);
  world.setEdges(this, color(0));
  world.setEdgesRestitution(1.0);
  users = new ArrayList<FPoly>();
}

void draw()
{  
  kinect.update();  
  kpc.setDepthMapRealWorld(kinect.depthMapRealWorld()); 
  kpc.setKinectUserImage(kinect.userImage());
  opencv.loadImage(kpc.getImage());
    
  // reset physics obstacles
  for (FPoly user : users)  world.remove(user);
  users = new ArrayList<FPoly>();
  
  // for each projected contour, create new user obstacle
  projectedContours = new ArrayList<ProjectedContour>();
  ArrayList<Contour> contours = opencv.findContours();
  for (Contour contour : contours) {
    if (contour.area() > 2000) {
      ArrayList<PVector> cvContour = contour.getPoints();
      ProjectedContour projectedContour = kpc.getProjectedContour(cvContour, 1.0);
      projectedContours.add(projectedContour);
      
      FPoly newUser = new FPoly();
      newUser.setStrokeWeight(0);
      newUser.setFill(255, 255, 255);
      newUser.setDensity(10);
      newUser.setRestitution(0.5);
      ArrayList<PVector> p = projectedContour.getProjectedContours();
      for (int i=0; i<p.size(); i+=4)
        newUser.vertex(p.get(i).x, p.get(i).y);
      users.add(newUser);
      world.add(newUser);
    }
  }
  
  // draw
  background(255);
  world.step();
  world.draw(this);
  
  if (frameCount % 60 == 0)  addFallingPolygon();
}

void addFallingPolygon() {
  int cx = (int) random(0.1 * width, 0.9 * width);
  int n = (int) random(6, 12);      
  FPoly poly = new FPoly();
  poly.setFill(random(50, 255), random(50, 255), random(50, 255));
  poly.setStrokeWeight(1);
  poly.setDensity(10);
  poly.setRestitution(0.5);
  for (int i=0; i<n; i++) {
    float ang = map(i, 0, n, 0, TWO_PI);
    int rad = (int) random(30, 65);
    float x = cx + rad * cos(ang);
    float y = rad * sin(ang);
    poly.vertex(x, y);
  }
  world.add(poly);
}