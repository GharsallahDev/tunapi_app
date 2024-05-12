import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';

class Upload extends StatefulWidget {
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  String? uploadedImageUrl;
  String? processedImageUrl;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text("Upload Image"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF9C901),
                  foregroundColor: Colors.white,
                ),
                onPressed: _isUploading ? null : pickImage,
                child: _isUploading
                    ? Container(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 3,
                        ),
                      )
                    : Icon(Icons.photo_library),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF9C901),
                  foregroundColor: Colors.white,
                ),
                child: _isProcessing
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                    : Text("Process"),
                onPressed: _isProcessing ? null : uploadToServer,
              ),
              SizedBox(height: 20),
              isSmallScreen
                  ? buildSmallScreenLayout()
                  : buildLargeScreenLayout(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _isUploading = true;
      });
      final bytes = await pickedFile.readAsBytes();
      var formData = FormData.fromMap({
        "file": MultipartFile.fromBytes(bytes, filename: pickedFile.name),
      });
      var dio = Dio();
      try {
        var response =
            await dio.post('http://192.168.1.104:5000/upload', data: formData);
        if (response.statusCode == 200) {
          setState(() {
            uploadedImageUrl = response.data['uploaded_url'];
          });
        } else {
          print("Failed to upload image. Status code: ${response.statusCode}");
        }
      } catch (e) {
        print("Failed to upload image: $e");
      } finally {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> uploadToServer() async {
    if (uploadedImageUrl == null) {
      print("No image uploaded");
      return;
    }
    setState(() {
      _isProcessing = true;
    });

    var dio = Dio();
    var formData = FormData.fromMap({
      "image_url": uploadedImageUrl,
    });

    try {
      var response =
          await dio.post('http://192.168.1.104:5000/predict', data: formData);
      if (response.statusCode == 200) {
        print('Response Received: ${response.data}');
        processedImageUrl = response.data['image_url'];
      } else {
        print("Failed to get prediction. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Failed to send prediction request: $e");
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Widget buildSmallScreenLayout() {
    return Column(
      children: [
        buildMediaSection(
            "Uploaded Media",
            uploadedImageUrl != null
                ? Image.network(uploadedImageUrl!)
                : Text("No image uploaded"),
            true),
        SizedBox(height: 20),
        buildMediaSection(
            "Processed Media",
            processedImageUrl != null
                ? Image.network(processedImageUrl!)
                : Text("No processed media available"),
            true),
      ],
    );
  }

  Widget buildLargeScreenLayout() {
    return Row(
      children: [
        Expanded(
            child: buildMediaSection(
                "Uploaded Media",
                uploadedImageUrl != null
                    ? Image.network(uploadedImageUrl!)
                    : Text("No image uploaded"),
                false)),
        SizedBox(width: 20),
        Expanded(
            child: buildMediaSection(
                "Processed Media",
                processedImageUrl != null
                    ? Image.network(processedImageUrl!)
                    : Text("No processed media available"),
                false)),
      ],
    );
  }

  Widget buildMediaSection(String title, Widget content, bool fullWidth) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFF9C901)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(title, style: Theme.of(context).textTheme.headline6),
          SizedBox(height: 10),
          content
        ],
      ),
    );
  }
}