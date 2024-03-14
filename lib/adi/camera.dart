import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';

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

                      // Navigate to new screen with image location
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImagePage(imagePath: imagePath),
                        ),
                      );
                      ;
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

class ImagePage extends StatelessWidget {
  final String imagePath;

  const ImagePage({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Captured Image'),
      ),
      body: Center(
        child: Text('Image Location: $imagePath'),
      ),
    );
  }
}
