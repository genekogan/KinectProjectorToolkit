import SimpleOpenNI.*;
import KinectProjectorToolkit.*;

SimpleOpenNI kinect;
KinectProjectorToolkit kpc;

void setup()
{
  size(displayWidth, displayHeight, P2D); 
  
  // setup Kinect
  kinect = new SimpleOpenNI(this); 
  kinect.enableDepth();
  kinect.enableUser();
  kinect.alternativeViewPointDepthToImage();
  
  // setup Kinect Projector Toolkit
  kpc = new KinectProjectorToolkit(this, kinect.depthWidth(), kinect.depthHeight());
  kpc.loadCalibration("calibration.txt");
}

void draw()
{  
  kinect.update();  
  kpc.setDepthMapRealWorld(kinect.depthMapRealWorld()); 
  
  background(0);
  int[] userList = kinect.getUsers();
  if (userList.length == 2) {
    if (kinect.isTrackingSkeleton(userList[0]) && kinect.isTrackingSkeleton(userList[1])) {
      PVector rh1 = getProjectedJoint(userList[0], SimpleOpenNI.SKEL_RIGHT_HAND);
      PVector rh2 = getProjectedJoint(userList[1], SimpleOpenNI.SKEL_RIGHT_HAND);
      stroke(255, 60, 60, 220);
      noFill();
      strokeWeight(4);
      line(rh1.x, rh1.y, rh2.x, rh2.y);
    }
  } 
}


PVector getProjectedJoint(int userId, int jointIdx) {
  PVector jointKinectRealWorld = new PVector();
  PVector jointProjected = new PVector();
  kinect.getJointPositionSkeleton(userId, jointIdx, jointKinectRealWorld);
  jointProjected = kpc.convertKinectToProjector(jointKinectRealWorld);
  return jointProjected;
}


// -----------------------------------------------------------------
// SimpleOpenNI events -- do not need to modify these...

void onNewUser(SimpleOpenNI curContext, int userId) {
  println("onNewUser - userId: " + userId);
  curContext.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curContext, int userId) {
  println("onLostUser - userId: " + userId);
}

void onVisibleUser(SimpleOpenNI curContext, int userId) {
  println("onVisibleUser - userId: " + userId);
}