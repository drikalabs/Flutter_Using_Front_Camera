import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

Future <void> main()async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.last;
  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      home: CameraApp(camera: firstCamera),
    )
  );
}

class CameraApp extends StatefulWidget{
  final CameraDescription camera;
  CameraApp({
    Key key,
    @required this.camera
  }):super(key:key);
  @override
  _CameraAppState createState() => _CameraAppState();
}
class _CameraAppState extends State<CameraApp>{
  CameraController _cameraController;
  Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _cameraController =CameraController(
      widget.camera,
      ResolutionPreset.medium
    );
    _initializeControllerFuture =_cameraController.initialize();
  }
  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _initializeControllerFuture,
        builder: (context,snapshot){
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_cameraController);
          }
          return Center(child: CircularProgressIndicator());
        }
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.camera_alt),
          onPressed:()async{
            try {
              await _initializeControllerFuture;
              final path= join((await getTemporaryDirectory()).path,'${DateTime.now()}.png');
              await _cameraController.takePicture(path);
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context)=>DisplayImageScreen(imagePath: path) )
                  );
            } catch (e) {
              print(e);
            }
          }
          ),
    );
  }

}
class DisplayImageScreen extends StatelessWidget{
  final String imagePath;
  DisplayImageScreen({
    Key key,
   @required this.imagePath
  }):super(key:key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Image.file(File(imagePath)),
    );
  }
}