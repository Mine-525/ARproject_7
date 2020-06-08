boolean isReady(ArrayList<Marker> markers, boolean isReady){
    int markerNum = markers.size();
    fill(255, 0, 0);
    textSize(40);
    text(markerNum, width/2-40, height/2);
    if (markerNum <4){   
        fill(255, 0, 0);
        textSize(40);
        text("Marker not enough ", width/2, height/2);
        isReady = false;
    }else{
        isReady = true;
    }

    return isReady;
}

// int isStart(HashMap<Integer, PMatrix3D> markerPoseMap, boolean isStart, int[] actionList, int cntNoJump){
//     PMatrix3D pose_jump = markerPoseMap.get(actionList[0]);
//     if (pose_jump == null){
//         cntNoJump ++;
//     }else{
//         cntJump ++;
//     }
//     if (cntNoJump > 10){
//         fill(255, 0, 0);
//         textSize(40);
//         int resTime = ceil((41 - cntNoJump)/10);
//         text("Start in " + resTime, width/2, height/2-10);
//     }
//     return cntNoJump;
// }

boolean isJump(HashMap<Integer, PMatrix3D> markerPoseMap, boolean isStart, boolean isJump){
    PMatrix3D pose_jump = markerPoseMap.get(actionList[0]);
    if (isJump == false && pose_jump == null){
        isJump = true;
    }
    if (isJump == true && pose_jump != null){
        isJump = false;
    }
    fill(255, 0, 0);
    textSize(40);
    text(String.valueOf(isJump), 400,200);
    return isJump;
}