import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'homepage.dart';
import 'main.dart';

class EnterUserDataScreen extends StatefulWidget {
  const EnterUserDataScreen({Key? key}) : super(key: key);

  @override
  _EnterUserDataScreenState createState() => _EnterUserDataScreenState();
}

class _EnterUserDataScreenState extends State<EnterUserDataScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  File? _imageFile;
  bool _uploading = false;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    setState(() {
      if (kIsWeb) {
        _imageFile = Image.network(pickedFile!.path) as File?;
      } else {
        _imageFile = File(pickedFile!.path);
      }
    });
  }

  Future<void> _uploadProfilePicture() async {
    if (_imageFile == null) return;

    setState(() {
      _uploading = true;
    });

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final storageRef =
          FirebaseStorage.instance.ref().child('profilePictures/$uid.jpg');
      await storageRef.putFile(_imageFile!);
      final profilePictureUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'profilePictureUrl': profilePictureUrl});
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload profile picture')));
    } finally {
      setState(() {
        _uploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      backgroundColor: getBackground(context),
      appBar: AppBar(
        title: const Text('Enter User Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_imageFile != null)
              SizedBox(
                height: 150,
                child: Image.file(_imageFile!),
              ),
            InkWell(
              onTap: () async {
                await showModalBottomSheet(
                  context: context,
                  builder: (context) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!kIsWeb)
                        ListTile(
                          leading: const Icon(Icons.camera_alt),
                          title: const Text('Take a picture'),
                          onTap: () {
                            _pickImage(ImageSource.camera);
                            Navigator.pop(context);
                          },
                        ),
                      ListTile(
                        leading: const Icon(Icons.photo_library),
                        title: const Text('Choose from gallery'),
                        onTap: () {
                          _pickImage(ImageSource.gallery);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: Text(
                    'Select Profile Picture',
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Enter your name',
              ),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                hintText: 'Enter your address',
              ),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _contactController,
              decoration: const InputDecoration(
                hintText: 'Enter your contact',
              ),
            ),
            const Spacer(),
            if (_uploading) const CircularProgressIndicator(),
            if (!_uploading)
              ElevatedButton(
                onPressed: () async {
                  final email = FirebaseAuth.instance.currentUser!.email;
                  final name = _nameController.text;
                  final address = _addressController.text;
                  final contact = _contactController.text;
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .set({
                    'email': email,
                    'name': name,
                    'address': address,
                    'contact': contact,
                  });
                  await _uploadProfilePicture();
                  {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  }
                },
                child: const Text('Submit'),
              ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}

//         _downloadUrl = downloadUrl;
//       });
