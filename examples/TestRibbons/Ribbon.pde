class Ribbon
{
  ArrayList<PVector> contour;
  int age, maxAge, pos, len, speed, skip, margin;
  
  Ribbon(ArrayList<PVector> contour) {
    this.contour = contour;
    maxAge = 24;
    age = 0;
    pos = (int) random(contour.size());
    len = 36;
    skip = 1;
    speed = 3;
    margin = 40;
  }
  
  void update() {
    age++;
    pos = (pos + speed) % contour.size();
  }
  
  void draw() {
    pushStyle();
    noFill();
    stroke(255, 150);
    strokeWeight(4);
    beginShape();
    for (int i=0; i<len; i++) {
      int idx = (pos + i * skip) % contour.size();
      float nx = map(noise(0.1*idx+10), 0, 1, -margin, margin);
      float ny = map(noise(0.1*idx+20), 0, 1, -margin, margin);
      PVector p = contour.get(idx);
      vertex(p.x + nx, p.y + ny);
    }
    endShape();
    popStyle();
  }
}