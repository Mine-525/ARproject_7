import java.util.LinkedList;
import java.sql.Timestamp;
import java.util.Random;

class GameWorld {
    // 500 * 500
    PVector size;
    Dino dino;
    LinkedList<Barrier> barriers;
    int baseScore;
    int score;
    int highScore;
    boolean isOver;
    Random r;
    int interval;

    GameWorld() {
        size = new PVector(500, 500, 0);
        reset();

        Timestamp timestamp = new Timestamp(System.currentTimeMillis());
        r = new Random(timestamp.getTime());
        interval = 0;
    }

    void reset() {
        dino = new Dino();
        barriers = new LinkedList<Barrier>();
        score = 0;
        isOver = false;
    }

    boolean checkNewBarrier() {
        if (barriers.isEmpty()) {
            return true;
        }

        Barrier last = barriers.getLast();
        if (size.x - last.pos.x >= interval) {
            int base = 200;
            int rand = r.nextInt(200);
            interval = base + rand;
            return true;
        }

        return false;
    }

    boolean checkCollision() {
        if (barriers.isEmpty()) return false;

        float dinoX1 = dino.pos.x;
        float dinoX2 = dino.pos.x + dino.width;
        
        // //original version
        // for (Barrier barrier : barriers) {
        //     if (dino.pos.y >= barrier.height) {
        //         continue;
        //     }

        //     float barrierX1 = barrier.pos.x;
        //     float barrierX2 = barrier.pos.x + barrier.width;

        //     if (barrierX1 > dinoX1 && barrierX1 < dinoX2) return true;
        //     if (barrierX2 > dinoX1 && barrierX2 < dinoX2) return true;
        // }

        //kitayama test
        float dinoY1 = dino.pos.y;
        float dinoY2 = dino.pos.y + dino.height;
        for (Barrier barrier : barriers) {
            if(barrier.checkCollision(dinoX1, dinoX2, dinoY1, dinoY2)){
                return true;
            }
        }

        return false;
    }

    void update() {
        // println("frameRate: "+frameRate);
        
        if (isOver) {
            return;
        }

        dino.update();
        for (Barrier barrier : barriers) {
            barrier.update();
        }

        baseScore += 10;
        score = baseScore / 100 * 10;
        if (score > highScore) {
            highScore = score;
        }

        if (checkNewBarrier()) {

            // // original version
            // Barrier newBarrier = new Barrier();

            //kitayama test
            Barrier newBarrier;
            if(r.nextInt(10)<8){
                newBarrier = new Cactus();
            } else{
                newBarrier = new Ptera();
            }

            barriers.add(newBarrier);
        }

        if (checkCollision()) {
            isOver = true;
        }

        if (!barriers.isEmpty()) {
            Barrier first = barriers.getFirst();
            if (first.pos.x + width < 0) {
                barriers.removeFirst();
            }
        }
    }

    void draw() {
        new Cource().draw();
        dino.draw();
        for (Barrier barrier : barriers) {
            barrier.draw();
        }
    }

    void dinoJump() {
        if (isOver) {
            reset();
            isOver = false;
        }

        if (dino.pos.y == 0) {
            dino.jump();
        }
    }
}

class Dino {
    PVector pos;
    float width;
    float height;
    float jumpSpeed;
    boolean isJumping;
    PShape Trex;
    
    Dino() {
        pos = new PVector(100, 0, 0);
        width = 50;
        height = 100;
        isJumping = false;
        Trex = loadShape("./Model_files/TREX.obj");
        Trex.width = this.width;
        Trex.height = this.height;
        Trex.scale(gameScale);
    }

    void update() {
        if (isJumping) {
            jumpSpeed -= 60 / frameRate;
            println("jumpSpeed: "+jumpSpeed);
            pos.y += jumpSpeed;
            if (pos.y < 0) {
                pos.y = 0;
                isJumping = false;
            }
        }
    }

    void jump() {
        jumpSpeed = 30;
        isJumping = true;
    }

    void draw() {
        float dinoZOff = -this.pos.y * gameScale * 0.001;
        pushMatrix();
            applyMatrix(pose_plane); 
            translate(dinoXOff, dinoYOff,dinoZOff);
            rotateX(radians(90));
            shape(Trex);
        popMatrix();
    }
}

class Barrier {
    PVector pos;
    float width;
    float height;
    float speed;

    Barrier() {
        pos = new PVector(1000, 0, 0);
        width = 40;
        height = 80;
        speed = 300;
    }

    void update() {
        pos.x -= speed / frameRate;
    }

    void draw() {}
    boolean checkCollision(float dinoX1, float dinoX2, float dinoY1, float dinoY2){
        return false;
    }
}

class Cactus extends Barrier{
    PShape cactus_body, cactus_top;
    int nOfBlocks;

    Cactus(int nOfBlocks){
        pos = new PVector(1000, 0, 0);
        this.nOfBlocks = nOfBlocks;
        width = 40;
        height = nOfBlocks*20;
        cactus_body = loadShape("./Model_files/Cuctas_body.obj");
        cactus_body.width = this.width;
        cactus_body.height = 20;
        cactus_body.scale(gameScale);
        cactus_top = loadShape("./Model_files/Cuctas_top.obj");
        cactus_top.width = this.width;
        cactus_top.height = 20;
        cactus_top.scale(gameScale);
    }

    Cactus(){
        this(4);
    }


    void draw(){
        float barrierZOff = -this.height*gameScale*0.001;
        float barrierYOff = -(this.pos.x-100) * gameScale * 0.001;
        pushMatrix();
            applyMatrix(pose_plane); 
            translate(0, barrierYOff, barrierZOff);
            for(int i=0; i<nOfBlocks-1; i++){
                shape(cactus_body);
                translate(0, 0, 20*gameScale*0.001);
            }
            shape(cactus_top);
        popMatrix();
    }

    boolean checkCollision(float dinoX1, float dinoX2, float dinoY1, float dinoY2){
        if (dinoY1 >= this.height) {
            return false;
        }

        float barrierX1 = this.pos.x;
        float barrierX2 = this.pos.x + this.width;

        if (barrierX1 > dinoX1 && barrierX1 < dinoX2) return true;
        if (barrierX2 > dinoX1 && barrierX2 < dinoX2) return true;

        return false;
    }
}

class Ptera extends Barrier{
    PShape ptera;

    Ptera(){
        pos = new PVector(1000, 100, 0);
        width = 80;
        height = 40;
        ptera = loadShape("./Model_files/Ptera.obj");
        ptera.width = this.width;
        ptera.height = this.height;
        ptera.scale(gameScale);
        ptera.rotateY(radians(180));
        
    }

    void draw(){
        float barrierYOff = -(this.pos.x-100) * gameScale * 0.001;
        float barrierZOff = -(this.pos.y) * gameScale * 0.001;
        pushMatrix();
            applyMatrix(pose_plane); 
            translate(0, barrierYOff, barrierZOff);
            rotateX(radians(90));
            shape(ptera);
        popMatrix();
    }

    
    boolean checkCollision(float dinoX1, float dinoX2, float dinoY1, float dinoY2){
        float barrierX1 = this.pos.x;
        float barrierX2 = this.pos.x + this.width;
        float barrierY1 = this.pos.y;
        float barrierY2 = this.pos.y + this.height;

        if (barrierX1 > dinoX1 && barrierX1 < dinoX2 && barrierY1 > dinoY1 && barrierY1 < dinoY2) return true;
        if (barrierX1 > dinoX1 && barrierX1 < dinoX2 && barrierY2 > dinoY1 && barrierY2 < dinoY2) return true;
        if (barrierX2 > dinoX1 && barrierX2 < dinoX2 && barrierY1 > dinoY1 && barrierY1 < dinoY2) return true;
        if (barrierX2 > dinoX1 && barrierX2 < dinoX2 && barrierY2 > dinoY1 && barrierY2 < dinoY2) return true;

        return false;
    }
}

class Cource{
    float width, length;

    Cource(float width, float length){
        this.width = width;
        this.length = length;
    }
    
    Cource(){
        this(200, 1000);
    }

    void draw(){
        float draw_scale = gameScale * 0.001;
        pushMatrix();
            applyMatrix(pose_plane); 
            noStroke();
            fill(153, 76, 0);
            translate(0, -100*draw_scale, 0);
            box(width*draw_scale, length*draw_scale, 0);
        popMatrix();
    }
}