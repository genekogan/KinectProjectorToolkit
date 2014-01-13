void addFireBall(int userId) {
  PVector ctr, torso, vel;
  if (random(1) < 0.5)  ctr = getProjectedJoint(userId, SimpleOpenNI.SKEL_LEFT_HAND);
  else                  ctr = getProjectedJoint(userId, SimpleOpenNI.SKEL_RIGHT_HAND);
  torso = getProjectedJoint(userId, SimpleOpenNI.SKEL_TORSO);
  vel = PVector.sub(ctr, torso);
  fireballs.add(new Fireball(ctr, vel));
}

void drawFireballs() {
  ArrayList<Fireball> next = new ArrayList<Fireball>();
  for (Fireball fireball : fireballs) {
    fireball.update();
    fireball.draw();
    if (fireball.active)  next.add(fireball);
  }
  fireballs = next;
}

void renderFireball() {
  pgFireball.beginDraw();
  pgFireball.clear();
  pgFireball.colorMode(HSB);
  pgFireball.noStroke();
  pgFireball.translate(pgFireball.width/2, pgFireball.height/2);
  for (int k=0; k<24; k++) {
    pgFireball.fill(map(k, 0, 24, 5, 40),
            map(noise(0.01*k+10, 0.01*frameCount+15), 0, 1, 180, 250), 
            map(noise(0.01*k+20, 0.01*frameCount+25), 0, 1, 180, 250), 100);
    pgFireball.rotate(noise(k));
    pgFireball.beginShape();
    for (int i=0; i<120; i++) {
      float ang = map(i, 0, 120, 0, TWO_PI);
      float rad = map(noise(0.04*i+k, 0.03*frameCount+5), 0, 1, 
                      map(k, 0, 24, pgFireball.width/6, 0),
                      map(k, 0, 24, pgFireball.width/2, 10));
      float x = rad * cos(ang);
      float y = rad * sin(ang);
      pgFireball.curveVertex(x, y);
    }
    pgFireball.endShape(CLOSE);
  }
  pgFireball.endDraw();  
}

class Fireball 
{
  float t;
  PVector ctr, vel;
  boolean active;
  float maxSize;
  
  Fireball(PVector ctr, PVector vel) {
    this.ctr = ctr;
    this.vel = vel;
    vel.setMag(5.0);
    t = 0;
    maxSize = 300;
    active = true;
  }
  
  void update() {
    ctr.add(vel);
    t += 3.0;
    if (ctr.x < -180 || ctr.x > width + 180 || ctr.y < -180 || ctr.y > height + 180) 
      active = false;
  }
  
  void draw() {
    pushMatrix();
    pushStyle();
    translate(ctr.x, ctr.y);
    image(pgFireball, 0, 0, constrain(t, 0, maxSize), constrain(t, 0, maxSize));
    popStyle();
    popMatrix();
  }
}