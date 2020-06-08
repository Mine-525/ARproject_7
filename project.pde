GameWorld world;

void settings() {
    size(600, 600);
}

void setup() {
    world = new GameWorld();
}


void draw() {
    background(255);
    world.update();
    world.draw();
}

void keyPressed(){
  if(key == ' '){
    world.dinoJump();
  }
}