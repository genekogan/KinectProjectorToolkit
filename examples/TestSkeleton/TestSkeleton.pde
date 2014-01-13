import SimpleOpenNI.*;
import KinectProjectorToolkit.*;

SimpleOpenNI kinect;
KinectProjectorToolkit kpc;

int SIZE_JOINTS = 20;

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
  
  background(255);
  drawProjectedSkeletons();
}

void drawProjectedSkeletons() {
  int[] userList = kinect.getUsers();
  for(int i=0; i<userList.length; i++) {
    if(kinect.isTrackingSkeleton(userList[i])) {
      PVector pHead = getProjectedJoint(userList[i], SimpleOpenNI.SKEL_HEAD);
      PVector pNeck = getProjectedJoint(userList[i], SimpleOpenNI.SKEL_NECK);
      PVector pTorso = getProjectedJoint(userList[i], SimpleOpenNI.SKEL_TORSO);
      PVector pLeftShoulder = getProjectedJoint(userList[i], SimpleOpenNI.SKEL_LEFT_SHOULDER);
      PVector pRightShoulder = getProjectedJoint(userList[i], SimpleOpenNI.SKEL_RIGHT_SHOULDER);
      PVector pLeftElbow = getProjectedJoint(userList[i], SimpleOpenNI.SKEL_LEFT_ELBOW);
      PVector pRightElbow = getProjectedJoint(userList[i], SimpleOpenNI.SKEL_RIGHT_ELBOW);
      PVector pLeftHand = getProjectedJoint(userList[i], SimpleOpenNI.SKEL_LEFT_HAND);
      PVector pRightHand = getProjectedJoint(userList[i], SimpleOpenNI.SKEL_RIGHT_HAND);      
      PVector pLeftHip = getProjectedJoint(userList[i], SimpleOpenNI.SKEL_LEFT_HIP);
      PVector pRightHip = getProjectedJoint(userList[i], SimpleOpenNI.SKEL_RIGHT_HIP);
      PVector pLeftKnee = getProjectedJoint(userList[i], SimpleOpenNI.SKEL_LEFT_KNEE);
      PVector pRightKnee = getProjectedJoint(userList[i], SimpleOpenNI.SKEL_RIGHT_KNEE);
      PVector pLeftFoot = getProjectedJoint(userList[i], SimpleOpenNI.SKEL_LEFT_FOOT);
      PVector pRightFoot = getProjectedJoint(userList[i], SimpleOpenNI.SKEL_RIGHT_FOOT);
      
      stroke(0, 0, 255);
      strokeWeight(16);
      line(pHead.x, pHead.y, pNeck.x, pNeck.y);
      line(pNeck.x, pNeck.y, pTorso.x, pTorso.y);
      line(pNeck.x, pNeck.y, pLeftShoulder.x, pLeftShoulder.y);
      line(pLeftShoulder.x, pLeftShoulder.y, pLeftElbow.x, pLeftElbow.y);
      line(pLeftElbow.x, pLeftElbow.y, pLeftHand.x, pLeftHand.y);
      line(pNeck.x, pNeck.y, pRightShoulder.x, pRightShoulder.y);
      line(pRightShoulder.x, pRightShoulder.y, pRightElbow.x, pRightElbow.y);
      line(pRightElbow.x, pRightElbow.y, pRightHand.x, pRightHand.y);
      line(pTorso.x, pTorso.y, pLeftHip.x, pLeftHip.y);
      line(pLeftHip.x, pLeftHip.y, pLeftKnee.x, pLeftKnee.y);
      line(pLeftKnee.x, pLeftKnee.y, pLeftFoot.x, pLeftFoot.y);
      line(pTorso.x, pTorso.y, pRightHip.x, pRightHip.y);
      line(pRightHip.x, pRightHip.y, pRightKnee.x, pRightKnee.y);
      line(pRightKnee.x, pRightKnee.y, pRightFoot.x, pRightFoot.y);   
      
      fill(255, 0, 0);
      noStroke();
      ellipse(pHead.x, pHead.y, SIZE_JOINTS, SIZE_JOINTS);
      ellipse(pNeck.x, pNeck.y, SIZE_JOINTS, SIZE_JOINTS);
      ellipse(pTorso.x, pTorso.y, SIZE_JOINTS, SIZE_JOINTS);
      ellipse(pLeftShoulder.x, pLeftShoulder.y, SIZE_JOINTS, SIZE_JOINTS);
      ellipse(pRightShoulder.x, pRightShoulder.y, SIZE_JOINTS, SIZE_JOINTS);
      ellipse(pLeftElbow.x, pLeftElbow.y, SIZE_JOINTS, SIZE_JOINTS);
      ellipse(pRightElbow.x, pRightElbow.y, SIZE_JOINTS, SIZE_JOINTS);
      ellipse(pLeftHand.x, pLeftHand.y, SIZE_JOINTS, SIZE_JOINTS);
      ellipse(pRightHand.x, pRightHand.y, SIZE_JOINTS, SIZE_JOINTS);
      ellipse(pLeftHip.x, pLeftHip.y, SIZE_JOINTS, SIZE_JOINTS);
      ellipse(pRightHip.x, pRightHip.y, SIZE_JOINTS, SIZE_JOINTS);
      ellipse(pLeftKnee.x, pLeftKnee.y, SIZE_JOINTS, SIZE_JOINTS);
      ellipse(pRightKnee.x, pRightKnee.y, SIZE_JOINTS, SIZE_JOINTS);
      ellipse(pLeftFoot.x, pLeftFoot.y, SIZE_JOINTS, SIZE_JOINTS);
      ellipse(pRightFoot.x, pRightFoot.y, SIZE_JOINTS, SIZE_JOINTS);
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