import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class LandmarksScreen extends StatefulWidget {
  const LandmarksScreen({super.key});

  @override
  State<LandmarksScreen> createState() => _LandmarksScreen();
}

class _LandmarksScreen extends State<LandmarksScreen> {
  File? _image;
  String _result = '';
  String _wikiDescription = '';
  bool _loading = false;

  final picker = ImagePicker();
  final String apiKey = 'AIzaSyDkcf6VE1usD53k3ETx8gud_hPkpZVoOyU';

  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _result = '';
        _wikiDescription = '';
      });
      await detectLandmark(_image!);
    }
  }

  Future<void> detectLandmark(File imageFile) async {
    setState(() => _loading = true);

    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final body = jsonEncode({
      "requests": [
        {
          "image": {"content": base64Image},
          "features": [
            {"type": "LANDMARK_DETECTION", "maxResults": 5},
          ],
        },
      ],
    });

    final response = await http.post(
      Uri.parse("https://vision.googleapis.com/v1/images:annotate?key=$apiKey"),
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final annotations = json['responses'][0]['landmarkAnnotations'];

      if (annotations != null && annotations.isNotEmpty) {
        final bestMatch = annotations.reduce(
          (a, b) => (a['score'] ?? 0) > (b['score'] ?? 0) ? a : b,
        );

        final description = bestMatch['description'];
        setState(() {
          _result =
              "$description - ${(bestMatch['score'] * 100).toStringAsFixed(2)}%";
        });

        await fetchWikipediaDescription(description);
        await saveToFirebase(imageFile, description, _wikiDescription);
      } else {
        setState(() {
          _result = "Sorry, I couldn't recognize this monument.";
          _wikiDescription = '';
        });
      }
    } else {
      setState(() {
        _result = "Error: ${response.body}";
        _wikiDescription = '';
      });
    }

    setState(() => _loading = false);
  }

  Future<void> fetchWikipediaDescription(String query) async {
    final url = Uri.parse(
      'https://en.wikipedia.org/api/rest_v1/page/summary/${Uri.encodeComponent(query)}',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['extract'] != null) {
        setState(() {
          _wikiDescription = json['extract'];
        });
      } else {
        setState(() {
          _wikiDescription = "No additional information found on Wikipedia.";
        });
      }
    } else {
      setState(() {
        _wikiDescription = "Failed to fetch Wikipedia data.";
      });
    }
  }



  Future<void> saveToFirebase(
    File image,
    String name,
    String description,
  ) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = FirebaseStorage.instance.ref().child(
        'monuments/$fileName',
      );

      final uploadTask = storageRef.putFile(image);
      final snapshot = await uploadTask;
      final imageUrl = await snapshot.ref.getDownloadURL();

      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid ?? 'unknown';

      final now = DateTime.now();
      final formattedDate = DateFormat('dd/MM/yyyy – kk:mm').format(now);

      final data = {
        'name': name,
        'description': description,
        'imageUrl': imageUrl,
        'dateScanned': formattedDate,
        'userID': userId,
      };


      await FirebaseFirestore.instance.collection('monuments').add(data);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  'Monument saved successfully!',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      print("Error saving to Firebase: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save monument')));
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Color(0xFFCDD7F5),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Scan Monument',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (_image != null)
                Image.file(_image!, height: 250, fit: BoxFit.cover),
              const SizedBox(height: 16),
              if (_loading) CircularProgressIndicator(),
              if (!_loading)
                Column(
                  children: [
                    Text(
                      _result,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _wikiDescription,
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => pickImage(ImageSource.camera),
                    icon: Icon(Icons.camera_alt),
                    label: Text("Camera"),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => pickImage(ImageSource.gallery),
                    icon: Icon(Icons.photo),
                    label: Text("Gallery"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
