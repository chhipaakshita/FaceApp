import 'dart:io';

import 'package:camera/camera.dart';
import 'package:face_xc/models/user_model.dart';
import 'package:face_xc/profile.dart';
import 'package:face_xc/services/camera_service.dart';
import 'package:face_xc/services/facenet_service.dart';
import 'package:face_xc/services/ml_kit_service.dart';
import 'package:face_xc/widgets/FacePainter.dart';
import 'package:face_xc/widgets/Facetracker.dart';
import 'package:face_xc/widgets/app_button.dart';
import 'package:face_xc/widgets/app_text_field.dart';
import 'package:face_xc/widgets/auth_action_button.dart';
import 'package:face_xc/widgets/camera_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:math'as math;
class SignIn extends StatefulWidget {
  final CameraDescription cameraDescription;

  const SignIn({
    Key? key,
    required this.cameraDescription,
  }) : super(key: key);


  @override
  _SignInState createState() => _SignInState();
}
 enum Status { RIGHT, SMILE, LEFT, NEUTRAL, EYES_CLOSED, EYES_OPEN }
// enum Status {  NEUTRAL,  EYES_OPEN }
class _SignInState extends State<SignIn> {
  // final _formKey = GlobalKey<FormState>();
  CameraService _cameraService = CameraService();
  MLKitService _mlKitService = MLKitService();
  FaceNetService _faceNetService = FaceNetService.faceNetService;
  final _formKey = GlobalKey<FormState>();
  late Future _initializeControllerFuture;

  bool cameraInitializated = false;
  bool _detectingFaces = false;
  bool pictureTaked = false;

  bool isLogin = false;
  bool isSignup = false;
  // switchs when the user press the camera
  bool _saving = false;
  bool _bottomSheetVisible = false;
  Status currentStatus = Status.NEUTRAL;
  Set<Status> listOfStatus = Set.of(Status.values);
  late List data;
  late String imagePath;
  late Size imageSize;
  Face? faceDetected;
  bool _initializing = false;
  final TextEditingController _passwordTextEditingController =
  TextEditingController(text: '');
   // final bool isLogin = true;
  bool callonce = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("Face Detect List: $listOfStatus");
    data = listOfStatus.toList();
    data.shuffle();
    print('random $data');
    // data.insert(0, "Dummy");
    currentStatus = data.first;
    print(currentStatus);
    _start();
  }

  bool getindexstats(value) {
    if (value == data.last) {
      print('Face Detect Is Last');
      print(value);
      print(data.last);
      return true;
    }
    else {
      print('Face Detect Is Last ?');
      print(value);
      return false;
    }
  }

  String _getStatusLabel() {
    print('asking questions?');
    print(currentStatus);
    switch (currentStatus) {
      case Status.SMILE:
        return "Give us a smile 😀";
      case Status.RIGHT:
        return "Look right ➡";
      case Status.LEFT:
        return "Look left ⬅";
      case Status.NEUTRAL:
        return "Try to be neutral 🙂";
      case Status.EYES_CLOSED:
        return "Close your eyes ";
      case Status.EYES_OPEN:
        return "Keep your eyes open";
      default:
        return "All done for now ✅";
    }
  }

  String _processFace() {
    switch (currentStatus) {
      case Status.SMILE:
        {
          if (Facetracker(imageSize: imageSize, face: faceDetected!)
              .getSmileStaus()) {
            return "You're not smiling 😊";
          }
          else {
            final index = data.indexOf(currentStatus);
            currentStatus = data[index + 1];
            print('cssmile');
            print(currentStatus);
            return "Good Job 😊";
          }
        }
      case Status.NEUTRAL:
        {
          if (Facetracker(imageSize: imageSize, face: faceDetected!)
              .getNeutralStatus()) {
            return "You're not neutral 🙂";
          }
          else {
            // print('face detect2 ${data[2]}');
            final index = data.indexOf(currentStatus);
            currentStatus = data[index + 1];
            print('csn');
            print(currentStatus);
            return "Good Job 🙂";
          }
        }
      case Status.RIGHT:
        {
          if (Facetracker(imageSize: imageSize, face: faceDetected!)
              .getRightStatus()) {
            return "You're not looking right ➡";
          }
          else {
            // print('face detect3 ${data[3]}');
            final index = data.indexOf(currentStatus);
            currentStatus = data[index + 1];
            print('csright');
            print(currentStatus);
            return " Good Job 🙂 ";
          }
        }
      case Status.LEFT:
        {
          if (Facetracker(imageSize: imageSize, face: faceDetected!)
              .getLeftStatus()) {
            return "You're not looking left ⬅ !";
          }
          else {
            // print('face detect4 ${data[4]}');
            final index = data.indexOf(currentStatus);
            currentStatus = data[index + 1];
            print('csleft');
            print(currentStatus);
            return " Good Job 🙂 ";
          }
        }
      case Status.EYES_CLOSED:
        {
          if (Facetracker(imageSize: imageSize, face: faceDetected!)
              .eyeStatus()) {
            return "You're not closing your eyes !";
          }
          else {
            // print('face detect0 ${data[0]}');
            final index = data.indexOf(currentStatus);
            currentStatus = data[index + 1];
            print('cseye');
            print(currentStatus);
            return " Good Job 🙂 ";
          }
        }
      case Status.EYES_OPEN:
        {
          if (Facetracker(imageSize: imageSize, face: faceDetected!)
              .eyeStatus()) {
            return "Your eyes are not open";
          }
          else {
            // print('face detect0 ${data[0]}');
            final index = data.indexOf(currentStatus);
            currentStatus = data[index + 1];
            print('oseye');
            print(currentStatus);
            return " Good Job 🙂 ";
          }
        }
      default:
        {
          return "Current status is not valid";
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    const double mirror = math.pi;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (!_initializing && pictureTaked) {
                    print('heretest');
                    print(pictureTaked);
                    return Container(
                      width: width,
                      height: height,
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(mirror),
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: Column(
                            children: <Widget>[
                              Image.file(File(imagePath)),
                              FutureBuilder<Widget?>(
                                  future: _predictuseronfacedetect(),
                                  builder: (BuildContext context, AsyncSnapshot<Widget?> snapshot){
                                    if(snapshot.hasData)
                                    {
                                      return Column(
                                        children: [
                                          Text(''),
                                        ],
                                      );
                                    }
                                    return Container(child: Text(''));
                                  }
                              ),

                            ],
                          ),

                        ),
                      ),

                    );
                  }
                  else {
                    return Transform.scale(
                      scale: 1.0,
                      child: AspectRatio(
                        aspectRatio: MediaQuery
                            .of(context)
                            .size
                            .aspectRatio,
                        child: OverflowBox(
                          alignment: Alignment.center,
                          child: FittedBox(
                            fit: BoxFit.fitHeight,
                            child: Container(
                              width: width,
                              height: width *
                                  _cameraService
                                      .cameraController.value.aspectRatio,
                              child: Stack(
                                fit: StackFit.expand,
                                children: <Widget>[
                                  CameraPreview(
                                      _cameraService.cameraController),
                                  CustomPaint(
                                    painter: FacePainter(face: faceDetected,
                                        imageSize: imageSize),
                                  ),
                                  Container(
                                    child: (faceDetected != null &&
                                        getindexstats(currentStatus) == false)
                                        ? Column(
                                      children: [
                                        Container(
                                            margin: EdgeInsets.only(top: 95),
                                            child: Column(
                                              children: [
                                                Text(
                                                  _getStatusLabel(),
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight: FontWeight
                                                          .w600,
                                                      fontSize: 20,
                                                      backgroundColor: Colors
                                                          .white
                                                  ),
                                                  textAlign: TextAlign.start,
                                                ),
                                              ],
                                            )
                                        ),
                                        Padding(
                                          // padding: EdgeInsets.only(top: 300),
                                          padding: EdgeInsets.only(
                                              top: MediaQuery
                                                  .of(context)
                                                  .size
                                                  .height / 2),
                                          child: Column(
                                            children: [
                                              Text(
                                                _processFace(),
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 20,
                                                    backgroundColor: Colors
                                                        .white
                                                ),
                                                textAlign: TextAlign.end,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )
                                        : Container(
                                      child: (getindexstats(currentStatus) == true)
                                          ? Container(
                                          child: Column(
                                            children: [
                                              autofaceDetect(context),
                                            ],
                                          )

                                            )
                                          : Container(),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                }

                else {
                  return const Center(child: CircularProgressIndicator());
                }
              }),
                CameraHeader(
                  "LOGIN",
                  onBackPressed: _onBackPressed,
                )
        ],
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // floatingActionButton: !_bottomSheetVisible?AuthActionButton(
      //   _initializeControllerFuture,
      //   onPressed: onShot,
      //   isLogin: true,
      //   reload: _reload,
      // )
      //     : Container(),
    );
  }
  Future _signIn(context) async {
    String password = _passwordTextEditingController.text;
    if (predictedUser!.password == password) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => Profile(
                predictedUser!.user,
                imagePath: _cameraService.imagePath!,
              )));
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: Text('Wrong password!'),
          );
        },
      );
    }
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    // Dispose of the controller when the widget is disposed.
    _cameraService.dispose();
  }
  Future<Widget?> _predictuseronfacedetect() async {
    if (isLogin == false && isSignup == false && callonce == true) {
      print('here');
      print(isLogin);
      return predictdata();
    }
  }
  Widget signSheet(context, User? predictedUser) {
    print('signsheet here');
    print(isLogin);
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if(isLogin == true && predictedUser != null) ...[
            Container(
              color: Colors.green,
              height: 100,
            ),
            showWelcomeWidget(context, predictedUser.user)

          ] else if(isLogin == false && predictedUser == null ) ...[
             showNoUserFoundWidget(context)
          ]else ...[
            // showNoUserFoundWidget(context)
          ]
        ],
      ),
    );
  }
  Future<User?> _predictUser() async{
    User? userAndPass = await _faceNetService.predict();
    return userAndPass;
  }
  predictdata() async{
    var user = await _predictUser(); //if await problem not solve, look for solution how to call await in widget
    print("NullIssue======${user?.user}");
    print("password === ${user?.password}");
    print("model data =====${user?.modelData}");

    if (user != null) {
      setState(() {
        predictedUser = user;
        isLogin = true; // Show form with welcome back user name
        isSignup = false;
        print('Predicted');
      });
    } else {
      setState(() {
        predictedUser = null;
        isLogin = false;
        isSignup = true; //show form for signup
        print('May be not registered');
      });
    }
    print('reaching u');
    signSheet(context, predictedUser);
  }


  Widget showWelcomeWidget(context , predictuser){
    print('welcome here');
    return showModal(context, predictuser);
  }
  Widget showNoUserFoundWidget(context){
    print('no here');
    return showNoUserModal(context);
  }
  showNoUserModal(context){
    changeSystemColor(Colors.white);
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0)),
        ),
        builder: (context){
          return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Form(
                  key: _formKey,
                  child: Container(
                    color: Colors.white,
                    height: 300,
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          child: const Center(
                            child: Text(
                              'User not found 😞',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ))
          );

        }
    );
  }
  changeSystemColor(Color color){

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: color,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
  }

  showModal(context, predictuser){
    changeSystemColor(Colors.white);
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0)),
        ),
        builder: (context){
          return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Form(
                  key: _formKey,
                  child: Container(
                    color: Colors.white,
                    height: 300,
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          child: Center(
                            child: Text(
                              'Welcome back, ' + predictuser + '.',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ))
          );

        }
    );
  }
  void _start() async {
    _initializeControllerFuture =
        _cameraService.startService(widget.cameraDescription);
    await _initializeControllerFuture;

    setState(() {
      cameraInitializated = true;
    });

    _frameFaces();
  }

  void _frameFaces() {
    imageSize = _cameraService.getImageSize();

    _cameraService.cameraController.startImageStream((image) async {
      if (_cameraService.cameraController != null) {
        // if its currently busy, avoids overprocessing
        if (_detectingFaces) return;

        _detectingFaces = true;

        try {
          List<Face> faces = await _mlKitService.getFacesFromImage(image);

          if (faces != null) {
            if (faces.length > 0) {
              // preprocessing the image
              setState(() {
                faceDetected = faces[0];
              });

              if (_saving) {
                _saving = false;
                _faceNetService.setCurrentPrediction(image, faceDetected!);
              }
            } else {
              setState(() {
                faceDetected = null;
              });
            }
          }

          _detectingFaces = false;
        } catch (e) {
          print(e);
          _detectingFaces = false;
        }
      }
    });
  }

  Widget autofaceDetect(BuildContext context){
    return Container(
      child: callme(),
    );
  }
  callme(){
    _facdetected();
  }
   _facdetected() async{
    if(faceDetected != null && callonce== false) {
      setState(() {
        callonce = true;
        _saving = true;
      });
    }
      await Future.delayed(const Duration(milliseconds: 500));
      await _cameraService.cameraController.stopImageStream();
      await Future.delayed(const Duration(milliseconds: 200));
      XFile? file = await _cameraService.takePicture();
      imagePath = file.path;
      // await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _bottomSheetVisible = true;
        pictureTaked = true;
      });
      if (pictureTaked == true){
        print('I am true');
        // await Future.delayed(const Duration(milliseconds: 500));
      }


  }

  Future<bool> onShot() async {
    if (faceDetected == null) {
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: Text('No face detected!'),
          );
        },
      );

      return false;
    } else {
      _saving = true;

      await Future.delayed(const Duration(milliseconds: 500));
      await _cameraService.cameraController.stopImageStream();
      await Future.delayed(const Duration(milliseconds: 200));
      XFile file = await _cameraService.takePicture();

      setState(() {
        _bottomSheetVisible = true;
        pictureTaked = true;
        imagePath = file.path;
      });

      return true;
    }
  }

  _onBackPressed() {
    Navigator.of(context).pop();
  }

  _reload() {
    setState(() {
      _bottomSheetVisible = false;
      cameraInitializated = false;
      pictureTaked = false;
    });
    this._start();
  }

  // signSheet(context, User? predictedUser) {
  //   return Container(
  //     padding: EdgeInsets.all(20),
  //     child: Column(
  //       mainAxisSize: MainAxisSize.min,
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         isLogin && predictedUser != null
  //             ? Container(
  //           child: Text(
  //             'Welcome back, ' + predictedUser.user + '.',
  //             style: TextStyle(fontSize: 20),
  //           ),
  //
  //         )
  //             : isLogin
  //             ? Container(
  //             child: Text(
  //               'User not found 😞',
  //               style: TextStyle(fontSize: 20),
  //             ))
  //             : Container(),
  //         Container(
  //           child: Column(
  //             children: [
  //               isLogin
  //                   ? AppTextField(
  //                 controller: _userTextEditingController,
  //                 labelText: "Your Name",
  //               )
  //                   : Container(),
  //               SizedBox(height: 10),
  //               isLogin && predictedUser == null
  //                   ? Container()
  //                   : AppTextField(
  //                 controller: _passwordTextEditingController,
  //                 labelText: "Password",
  //                 isPassword: true,
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
