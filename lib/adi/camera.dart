import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late String _imageLocation = '';

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _controller = CameraController(firstCamera, ResolutionPreset.high);

    return _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<String> _captureAndSaveImage() async {
    try {
      final XFile picture = await _controller.takePicture();
      final String imagePath = picture.path;

      // Save the location of the captured image
      setState(() {
        _imageLocation = imagePath;
      });
      

      var url1 = Uri.parse("https://api.luxand.cloud/photo/crop");
      var url2 = Uri.parse("https://api.luxand.cloud/photo/similarity");
      http.post(url1, body: {
        "photo": picture,
      }, headers: {
        "token": "c4265864de90473e90781a0d43c7bbb5"
      }).then((value) => print(value));

      return imagePath;
    } catch (e) {
      print('Error capturing image: $e');
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera Example'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                CameraPreview(_controller),
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Capture and save image when button is pressed
                      final imagePath = await _captureAndSaveImage();

                      print('Image saved: $imagePath');
                      ImagePath(imagePath1: imagePath);
                    },
                    child: Text('Capture Image'),
                  ),
                ),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class ImagePath {
  const ImagePath({
    this.imagePath1,
    this.imagePath2,
  });
  final String? imagePath1;
  final String? imagePath2;
}
