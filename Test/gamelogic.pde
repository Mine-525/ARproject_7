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
        size = new PVector(500, 500);
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
            Barrier newBarrier = new Barrier();
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

    Dino() {
        pos = new PVector(100, 0);
        width = 50;
        height = 100;
        isJumping = false;
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
    }
}

class Barrier {
    PVector pos;
    float width;
    float height;
    float speed;

    Barrier() {
        pos = new PVector(1000, 0);
        width = 40;
        height = 80;
        speed = 300;
    }

    void update() {
        pos.x -= speed / frameRate;
    }

    void draw() {
        stroke(255, 0, 0);
        fill(255, 0, 0);
        rect(pos.x, pos.y, width, height);
    }
}
