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
  kpc.setContourSmoothness(8);
  
  // setup physics
  Fisica.init(this);
  world = new FWorld();
  world.setGravity(0, 0);
  world.setEdges(this, color(0));
  for (int i=0; i<16; i++){
    FCircle ball = new FCircle(24);
    ball.setNoStroke();    
    ball.setFill(random(255), random(255), random(255));
    ball.setPosition(random(width), random(height));
    ball.setVelocity(random(-300, 300), random(-300, 300));
    ball.setRestitution(1);
    ball.setDamping(0);
    world.add(ball);
  }
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
      for (PVector p : projectedContour.getProjectedContours())
        newUser.vertex(p.x, p.y);
      //ArrayList<PVector> points = projectedContour.getProjectedContours();
      //for (int i=0; i<points.size(); i+=2) {
      //  PVector p = points.get(i);
      //  newUser.vertex(p.x, p.y);
      //}
      users.add(newUser);
      world.add(newUser);
    }
  }
  
  // draw
  background(0);
  world.step();
  world.draw(this);
}