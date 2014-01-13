class Ribbon
{
  ArrayList<PVector> contour;
  int age, maxAge, pos, len, speed, skip, margin, alph;
  color col;
  float noiseFactor, thickness;
  boolean isCurved;
  
  Ribbon(ArrayList<PVector> contour) {
    this.contour = contour;
    pos = (int) random(contour.size());
    age = 0;
    maxAge = (int) random(cp5.getController("ribbonMaxAge").getArrayValue(0), cp5.getController("ribbonMaxAge").getArrayValue(1));
    len = (int) random(cp5.getController("ribbonLength").getArrayValue(0), cp5.getController("ribbonLength").getArrayValue(1));
    skip = (int) random(cp5.getController("ribbonSkip").getArrayValue(0), cp5.getController("ribbonSkip").getArrayValue(1));
    speed = (int) random(cp5.getController("ribbonSpeed").getArrayValue(0), cp5.getController("ribbonSpeed").getArrayValue(1));
    margin = (int) random(cp5.getController("ribbonMargin").getArrayValue(0), cp5.getController("ribbonMargin").getArrayValue(1));
    noiseFactor = random(cp5.getController("ribbonNoiseFactor").getArrayValue(0), cp5.getController("ribbonNoiseFactor").getArrayValue(1));    
    thickness = random(cp5.getController("ribbonThickness").getArrayValue(0), cp5.getController("ribbonThickness").getArrayValue(1));
    alph = (int) random(cp5.getController("ribbonAlpha").getArrayValue(0), cp5.getController("ribbonAlpha").getArrayValue(1));
    isCurved = ribbonIsCurved;
    if (ribbonIsWhite)  col = color(255);  else  col = color(0);
  }
  
  void update() {
    age++;
    pos = (pos + speed) % contour.size();
  }
  
  void draw() {
    pushStyle();
    noFill();
    stroke(col, map(abs(age - 0.5*maxAge), 0.5*maxAge, 0, 0, alph));
    strokeWeight(thickness);
    beginShape();
    for (int i=0; i<len; i++) {
      int idx = (pos + i * skip) % contour.size();
      float nx = map(noise(noiseFactor*idx+10), 0, 1, -margin, margin);
      float ny = map(noise(noiseFactor*idx+20), 0, 1, -margin, margin);
      PVector p = contour.get(idx);
      if (isCurved)
        curveVertex(p.x + nx, p.y + ny);
      else
        vertex(p.x + nx, p.y + ny);
    }
    endShape();
    popStyle();
  }
}