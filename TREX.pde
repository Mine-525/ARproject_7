import gab.opencv.*;
import processing.video.*;

final boolean MARKER_TRACKER_DEBUG = true;
final boolean BALL_DEBUG = false;

final boolean USE_SAMPLE_IMAGE = false;

// We've found that some Windows build-in cameras (e.g. Microsoft Surface)
// cannot work with processing.video.Capture.*.
// Instead we use DirectShow Library to launch these cameras.
final boolean USE_DIRECTSHOW = true;

// final double kMarkerSize = 0.036; // [m]
final double kMarkerSize = 0.024; // [m]

Capture cap;
DCapture dcap;
OpenCV opencv;

float fov = 45; // for camera capture

// Marker codes of scene and action
final int[] sceneList = {0x005A};
final int[] actionList = {0x0272};

HashMap<Integer, PMatrix3D> markerPoseMap;

MarkerTracker markerTracker;
PImage img;

KeyState keyState;

// control
boolean isReady = false;
boolean isStart = false;
int cntDown = 0;
boolean isJump = false;

int frameRate = 10;

// model parameters
double sceneScale = 0.02;
double dinoScale = 0.02;
double dinoXOff = 0;
double dinoYOff = 0;

void selectCamera() {
  String[] cameras = Capture.list();

  if (cameras == null) {
    println("Failed to retrieve the list of available cameras, will try the default");
    cap = new Capture(this, 640, 480);
  } else if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    printArray(cameras);

    // The camera can be initialized directly using an element
    // from the array returned by list():
    //cap = new Capture(this, cameras[5]);

    // Or, the settings can be defined based on the text in the list
    cap = new Capture(this, 1280, 720, "USB2.0 HD UVC WebCam", 30);
  }
}

void settings() {
  if (USE_SAMPLE_IMAGE) {
    // Here we introduced a new test image in Lecture 6 (20/05/27)
    size(1280, 720, P3D);
    opencv = new OpenCV(this, "./marker_test2.jpg");
    // size(1000, 730, P3D);
    // opencv = new OpenCV(this, "./marker_test.jpg");
  } else {
    if (USE_DIRECTSHOW) {
      dcap = new DCapture();
      size(dcap.width, dcap.height, P3D);
      opencv = new OpenCV(this, dcap.width, dcap.height);
    } else {
      selectCamera();
      size(cap.width, cap.height, P3D);
      opencv = new OpenCV(this, cap.width, cap.height);
    }
  }
}

void setup() {
    background(0);
    smooth();
    frameRate(frameRate);

    markerTracker = new MarkerTracker(kMarkerSize);

    if (!USE_DIRECTSHOW)
        cap.start();

    PMatrix3D cameraMat = ((PGraphicsOpenGL)g).camera;
    cameraMat.reset();

    keyState = new KeyState();

    markerPoseMap = new HashMap<Integer, PMatrix3D>();  // hashmap (code, pose)
}

void draw() {
    ArrayList<Marker> markers = new ArrayList<Marker>();
    markerPoseMap.clear();

    if (!USE_SAMPLE_IMAGE) {
        if (USE_DIRECTSHOW) {
            img = dcap.updateImage();
            opencv.loadImage(img);
        } else {
            if (cap.width <= 0 || cap.height <= 0) {
            println("Incorrect capture data. continue");
            return;
            }
            opencv.loadImage(cap);
        }
    }

  // use orthographic camera to draw images and debug lines
  // translate matrix to image center
    ortho();
    pushMatrix();
        translate(-width/2, -height/2,-(height/2)/tan(radians(fov)));
        markerTracker.findMarker(markers);
    popMatrix();

    for (int i = 0; i < markers.size(); i++) {
        Marker m = markers.get(i);
        markerPoseMap.put(m.code, m.pose);
    }
    
    pushMatrix();
        // ready if enough markers, start if last for 4 sec
        translate(-width/2, -height/2,-(height/2)/tan(radians(fov)));
        if (isStart == false && isReady == false){
            isReady = isReady(markers, isReady);
        }
        if (isStart == false && isReady == true){
            cntDown ++;
            if  (cntDown < frameRate){
                fill(255, 0, 0);
                textSize(40);
                textAlign(CENTER);
                text("Ready!", width/2, height/2);
            }
            if (cntDown >= frameRate){
                int resTime = ceil((frameRate*4 + 1 - cntDown)/frameRate);
                textSize(40);
                text("Start in " + resTime, width/2, height/2-10);
            }
            if (cntDown > frameRate*4)
                isStart = true;           
        }
        // show score
        if (isStart){
            frameCnt ++;
            text(frameCnt, width-200, 100)
        }
    popMatrix();

    // use perspective camera 
    perspective(radians(fov), float(width)/float(height), 0.01, 1000.0);

    // setup light
    ambientLight(180, 180, 180);
    directionalLight(180, 150, 120, 0, 1, 0);
    lights();    

    // draw scene if ready
    if isReady{
        pose_plane = markerPoseMap.get(sceneList[0]);
        applyMatrix(pose_plane);    
        drawPlane(sceneSize);  // ground

        PMatrix3D[] objOffs = new PMatrix3D[objNum];
        objOffs = obj(); // offset of Cactus etc. relative to the ground from game logic
        for (int i; i < objOffs.size(); i++){ 
            pushMatrix();
                applyMatrix(objOffs[i]);
                drawObj(sceneSize); // render
            popMatrix();
        }
    }

    // draw dino if start
    if (isStart){
        // jump action
        isJump = isJump(markerPoseMap, isStart, isJump);
        // jump height from game logic
        float dinoZOff = dinoOffset(isJump); 
        // render
        pushMatrix();
            translate(dinoXOff, dinoYOff, dinoZOff);
            drawDinor(dinoSize); 
        popMatrix(); 

        // game over
        if (isHit()){
            isStart = false;
        }
    }




}
