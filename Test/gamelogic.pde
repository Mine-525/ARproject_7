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
        for (Barrier barrier : barriers) {
            if (dino.pos.y >= barrier.height) {
                continue;
            }

            float barrierX1 = barrier.pos.x;
            float barrierX2 = barrier.pos.x + barrier.width;

            if (barrierX1 > dinoX1 && barrierX1 < dinoX2) return true;
            if (barrierX2 > dinoX1 && barrierX2 < dinoX2) return true;
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
        // pushMatrix();
        //     applyMatrix(pose_plane);
        //     noStroke();
        //     fill(0);
        //     box(0.01, 0.001, 0.001);
        // popMatrix();
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
        Trex.scale(0.3);
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
        stroke(0);
        fill(0);
        rect(pos.x, pos.y, width, height);
        float dinoZOff = -this.pos.y * gameScale;
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

    void draw() {
        // stroke(255, 0, 0);
        // fill(255, 0, 0);
        // rect(pos.x, pos.y, width, height);
    }
}

class Cactus extends Barrier{
    PShape cactus_body, cactus_top;

    Cactus(){
        cactus_body = loadShape("./Model_files/Cuctas_body.obj");
        cactus_top = loadShape("./Model_files/Cuctas_top.obj");
        cactus_body.scale(0.2);
        cactus_top.scale(0.2);
    }

    void draw(){
        float barrierOff = -(this.pos.x-100) * gameScale;
        pushMatrix();
            applyMatrix(pose_plane);
            translate(0, barrierOff, 0);
            rotateX(radians(90));
            // shape(cactus_body);
            translate(0, 0.01, 0);
            rotateX(radians(90));
            shape(cactus_top);
        popMatrix();
    }
}

class Ptera extends Barrier{
    PShape ptera;

    Ptera(){
        ptera = loadShape("./Model_files/Ptera.obj");
        ptera.scale(0.1);
        ptera.rotateY(radians(180));
    }

    void draw(){
        float barrierOff = -(this.pos.x-100) * gameScale;
        pushMatrix();
            applyMatrix(pose_plane);
            translate(0, barrierOff, 0);
            rotateX(radians(90));
            shape(ptera);
        popMatrix();
    }
}
