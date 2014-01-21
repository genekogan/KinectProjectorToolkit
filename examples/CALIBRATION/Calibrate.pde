Jama.Matrix A, x, y;
  
void calibrate() {
  A = new Jama.Matrix(ptsP.size()*2, 11);
  y = new Jama.Matrix(ptsP.size()*2, 1);
  for(int i=0; i < ptsP.size()*2; i=i+2){
    PVector kc = ptsK.get(i/2);
    PVector projC = ptsP.get(i/2);
    A.set(i, 0, kc.x);
    A.set(i, 1, kc.y);
    A.set(i, 2, kc.z);
    A.set(i, 3, 1);
    A.set(i, 4, 0);
    A.set(i, 5, 0);
    A.set(i, 6, 0);
    A.set(i, 7, 0);
    A.set(i, 8, -projC.x*kc.x);
    A.set(i, 9, -projC.x*kc.y);
    A.set(i,10, -projC.x*kc.z);
    
    y.set(i, 0, projC.x);
 
    A.set(i+1, 0, 0);
    A.set(i+1, 1, 0);
    A.set(i+1, 2, 0);
    A.set(i+1, 3, 0);
    A.set(i+1, 4, kc.x);
    A.set(i+1, 5, kc.y);
    A.set(i+1, 6, kc.z);
    A.set(i+1, 7, 1);
    A.set(i+1, 8, -projC.y*kc.x);
    A.set(i+1, 9, -projC.y*kc.y);
    A.set(i+1,10, -projC.y*kc.z);
    
    y.set(i+1, 0, projC.y);
  }
  QRDecomposition problem = new QRDecomposition(A);
  x = problem.solve(y);
  if (!calibrated) {
    calibrated = true;
    guiSave.show();
    guiTesting.addItem("Testing Mode", 1);
  }
}
 
PVector convertKinectToProjector(PVector kp) {
  PVector out = new PVector();
  float denom = (float)x.get(8,0)*kp.x + (float)x.get(9,0)*kp.y + (float)x.get(10,0)*kp.z + 1;
  out.x = pWidth * ((float)x.get(0,0)*kp.x + (float)x.get(1,0)*kp.y + (float)x.get(2,0)*kp.z + (float)x.get(3,0)) / denom;
  out.y = pHeight * ((float)x.get(4,0)*kp.x + (float)x.get(5,0)*kp.y + (float)x.get(6,0)*kp.z + (float)x.get(7,0)) / denom;
  return out;
}

String[] getCalibrationString() {
  String[] coeffs = new String[11];
  for (int i=0; i<11; i++)
    coeffs[i] = ""+x.get(i,0);
  return coeffs;
}

void printMatrix(Jama.Matrix M) {
  double[][] a = M.getArray();
  for (int i=0; i<a.length; i++) {
    for (int j=0; j<a[i].length; j++) {
      println(i + " " + j + " : " + a[i][j]);
    }
  }
}
