PShape trex, cuctas;
float x1, y1;

void setup() {
  size(500, 500, P3D);
  smooth();
  trex = loadShape("TREX.obj");
  //trex.scale(1000);
  trex.rotateY(radians(90));
  
  cuctas = loadShape("Cuctas_body.obj");
  
  x1 = width;
}

void draw() {
  background(0);
  translate(0, height/2);
  lights();
  perspective(radians(60), float(width)/float(height), 0.01, 1000.0);
  
  //rotateX(radians(-30));
  
  shape(trex, 100, 0, 50, 100);
  //s.rotateY(.01);
  
  pushMatrix();
    translate(width/2,0,0);
    //rotateX(radians(-30));
    noStroke();
    fill(100, 70, 45);
    box(width, 10, 150);
  popMatrix();
  
  pushMatrix();
    //translate(x1, -15, 0);
    shape(cuctas, x1, 0, 15, 30);
  popMatrix();
  x1--;
}
