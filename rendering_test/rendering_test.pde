PShape s;
float x1, y1;

void setup() {
  size(720, 480, P3D);
  smooth();
  s = loadShape("TREX.obj");
  s.scale(1000);
  s.rotateY(radians(90));
  
  x1 = 300;
}

void draw() {
  background(0);
  translate(width/2, height/2);
  lights();
  perspective(radians(45), float(width)/float(height), 0.01, 1000.0);
  
  rotateX(radians(-30));
  
  shape(s, -180, 0);
  //s.rotateY(.01);
  
  pushMatrix();
    translate(0,10,0);
    //rotateX(radians(-30));
    noStroke();
    fill(100, 70, 45);
    box(width, 10, 150);
  popMatrix();
  
  pushMatrix();
    translate(x1, 0, 0);
    noStroke();
    fill(0, 255, 0);
    box(10, 100, 50);
  popMatrix();
  x1--;
}
