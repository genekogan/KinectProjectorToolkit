public class ChessboardFrame extends JFrame {
  public ChessboardFrame() {
    setBounds(displayWidth,0,pWidth,pHeight);
    ca = new ChessboardApplet();
    add(ca);
    removeNotify(); 
    setUndecorated(true); 
    setAlwaysOnTop(false); 
    setResizable(false);  
    addNotify();     
    ca.init();
    show();
  }
}

public class ChessboardApplet extends PApplet {
  public void setup() {
    noLoop();
  }
  public void draw() {
  }
}

void saveCalibration(String filename) {
  String[] coeffs = getCalibrationString();
  saveStrings(dataPath(filename), coeffs);
}

void loadCalibration(String filename) {
  String[] s = loadStrings(dataPath(filename));
  x = new Jama.Matrix(11, 1);
  for (int i=0; i<s.length; i++)
    x.set(i, 0, Float.parseFloat(s[i]));
  calibrated = true;
  println("done loading");
}