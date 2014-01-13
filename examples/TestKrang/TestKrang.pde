import SimpleOpenNI.*;
import KinectProjectorToolkit.*;
import processing.video.*;

SimpleOpenNI kinect;
KinectProjectorToolkit kpc;
Movie krang;

void setup()
{
  size(displayWidth, displayHeight, P2D); 
  imageMode(CENTER);
  
  // setup Kinect
  kinect = new SimpleOpenNI(this); 
  kinect.enableDepth();
  kinect.enableUser();
  kinect.alternativeViewPointDepthToImage();
  
  // setup Kinect Projector Toolkit
  kpc = new KinectProjectorToolkit(this, kinect.depthWidth(), kinect.depthHeight());
  kpc.loadCalibration("calibration.txt");
  
  // load KRANG!!
  krang = new Movie(this, "krang.mp4");
  krang.loop();
}

void movieEvent(Movie m) {
  m.read();
}

void draw()
{  
  kinect.update();  
  kpc.setDepthMapRealWorld(kinect.depthMapRealWorld()); 
  
  background(255);
  int[] userList = kinect.getUsers();
  for (int i=0; i<userList.length; i++) {
    if (kinect.isTrackingSkeleton(userList[i])) {
      PVector torso = getProjectedJoint(userList[i], SimpleOpenNI.SKEL_TORSO);
      float w = 100; //map(torso.z, 3500, 500, 80, 320);
      image(krang, torso.x, torso.y, w, w*(krang.height/krang.width));
      println(torso);
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