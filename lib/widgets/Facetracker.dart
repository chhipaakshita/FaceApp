import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class Facetracker{
  final Size imageSize;
  Face face;

  Facetracker({required this.imageSize, required this.face});

  bool getSmileStaus(){
    print('Left Eye Open: ');
    print(face.leftEyeOpenProbability);
    print(' ');
    print('Right Eye Open: ');
    print(face.rightEyeOpenProbability);
    double? smileProb = face.smilingProbability;
    print('Face Detect Probability');
    print(smileProb);
    if(smileProb! < 0.20)
    {
      print('Face Detect Not Smiling');
      return true;
    }
    else{
      print('Face Detect Smiling');
      return false;
    }
  }
  bool getNeutralStatus(){
    print('Left Eye Open: ');
    print(face.leftEyeOpenProbability);
    print(' ');
    print('Right Eye Open: ');
    print(face.rightEyeOpenProbability);
    double? smileProb = face.smilingProbability;
    print('Face Detect Neutral Probability');
    print(smileProb);
    if(smileProb! > 0.020)
    {
      print('Try not to laugh ! 🙂');
      return true;
    }
    else{
      return false;
    }
  }
  bool getRightStatus(){
    print('Left Eye Open: ');
    print(face.leftEyeOpenProbability);
    print(' ');
    print('Right Eye Open: ');
    print(face.rightEyeOpenProbability);
    double rightProb = face.headEulerAngleY!;
    print('Face Detect head right Probability');
    print(rightProb);
    if(face.headEulerAngleY! > -15){
      print('Face Detect Not right');
      return true;
    }else{
      print('Face Detect right');
      return false;
    }
  }

  bool getLeftStatus(){
    print('Left Eye Open: ');
    print(face.leftEyeOpenProbability);
    print(' ');
    print('Right Eye Open: ');
    print(face.rightEyeOpenProbability);
    double leftProb = face.headEulerAngleY!;
    print('Face Detect head left Probability');
    print(leftProb);
    if(leftProb <15){
      print('Face Detect Not left');
      return true;
    }else{
      print('Face Detect left');
      return false;
    }
  }

  bool eyeStatus(){
    print('Left Eye Open: ');
    print(face.leftEyeOpenProbability);
    print(' ');
    print('Right Eye Open: ');
    print(face.rightEyeOpenProbability);
    if (face.leftEyeOpenProbability! < 0.1 || face.rightEyeOpenProbability! < 0.1){
      return true;
    }else{
      return false;
    }
  }

  bool eyeStatusopen(){
    print('Left Eye Open: ');
    print(face.leftEyeOpenProbability);
    print(' ');
    print('Right Eye Open: ');
    print(face.rightEyeOpenProbability);
    if (face.leftEyeOpenProbability! > 0.8 && face.rightEyeOpenProbability! > 0.8){
      return true;
    }else{
      return false;
    }
  }

}