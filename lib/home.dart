import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'package:camera/camera.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late CameraController _cameraController; // cam controller
  File? _image;
  List? _result;
  bool _imageSelected = false;
  bool _loading=false;
  final _imagePicker=ImagePicker();
  bool _isCameraOpen = false;

  Future<void> _toggleCamera() async {
    if (_isCameraOpen) {
      await _cameraController.stopImageStream();
    } else {
      if (_cameraController.value.isInitialized) {
        await _cameraController.startImageStream(_processCameraFrame);
      } else {
        // Initialize the camera controller before starting the stream
        await _initCamera();
      }
    }
    setState(() {
      _isCameraOpen = !_isCameraOpen;
    });
  }


  @override
  Future getImage(ImageSource source) async {
    final image = await ImagePicker().pickImage(source: source);
    if (image == null) {
      return;
    }
    final imageTemporary = File(image.path);
    setState(() {
      _image = imageTemporary;
      _imageSelected = false;
      _result = null;
    });
    classifyImage(_image);
  }
  Future classifyImage(File? image) async {
    if(image==null){return;}
    var output = await Tflite.runModelOnImage(path: image.path,numResults: 2);
    print("-----------------------------------------$output");

    setState(() {
      _loading=false;
      _result=output;
      print(_result);
    });
  }

  Future loadModel() async {
    await Tflite.loadModel(
        model:"assets/best-fp16.tflite",
        labels: "assets/labels.txt"
    );
  }

  @override
  void initState(){
    super.initState();
    _loading=true;
    loadModel().then((value){
      setState(() {
        _loading=false;
      });
    });
    _initCamera();  //camera initialized
  }


  Future<void> _initCamera() async{
    final cameras=await availableCameras();
    final camera=cameras.first;
    _cameraController=CameraController(camera, ResolutionPreset.medium);
    await _cameraController.initialize();
    _cameraController.startImageStream(_processCameraFrame);
  }

  void _processCameraFrame(CameraImage image) async {
    if (_loading) {
      return;
    }
    _loading = true;

    // List? output = await Tflite.runModelOnFrame(
    //   bytesList: image.planes.map((plane) {
    //     return plane.bytes;
    //   }).toList(),
    // );
    print("--------------------------------");
    setState(() {
      _loading = false;
      //_result = output;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Detector'),
      ),
      body: Center(
        child: Column(
          children: [
            _image != null
                ? Image.file(
              _image!,
              width: 250,
              height: 250,
              fit: BoxFit.cover,
            )
                : _isCameraOpen
                  ? CameraPreview(_cameraController)
                  : Container(),
            CustomButton('Pick from Gallery', () => getImage(ImageSource.gallery)),
            CustomButton(
            _isCameraOpen ? 'Close Camera' : 'Open Camera',() => _toggleCamera()),

            if (_result != null)
              Text(
                'Prediction: ${_result![0]['label']}',
                style: TextStyle(fontSize: 20),
              ),
          ],
        ),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String title;
  final VoidCallback onClick;

  CustomButton(this.title, this.onClick);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      child: ElevatedButton(
        onPressed: onClick,
        child: Align(
          alignment: Alignment.center,
          child: Text(title),
        ),
      ),
    );
  }
}
