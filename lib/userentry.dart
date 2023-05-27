import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
      _imageFile = File(pickedFile!.path);
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
      // Handle any potential error during uploading
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to upload profile picture')));
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
            if (_uploading) // Show circular progress indicator if uploading is true
              const CircularProgressIndicator(),
            if (!_uploading) // Show submit button if not uploading
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
                  Navigator.pop(context);
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


//////////////image working////////////////////////////////////
// import 'dart:typed_data';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
//
// class UserEntryPage extends StatefulWidget {
//   @override
//   _UserEntryPageState createState() => _UserEntryPageState();
// }
//
// class _UserEntryPageState extends State<UserEntryPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _addressController = TextEditingController();
//   Uint8List _imageData = Uint8List(0);
//   bool _isUploading = false;
//   late String _downloadUrl;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('New User Entry'),
//       ),
//       body: SingleChildScrollView(
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: TextFormField(
//                   controller: _nameController,
//                   decoration: InputDecoration(
//                     labelText: 'Name',
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (value) {
//                     if (value!.isEmpty) {
//                       return 'Please enter a name';
//                     }
//                     return null;
//                   },
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: TextFormField(
//                   controller: _addressController,
//                   decoration: InputDecoration(
//                     labelText: 'Address',
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (value) {
//                     if (value!.isEmpty) {
//                       return 'Please enter an address';
//                     }
//                     return null;
//                   },
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: GestureDetector(
//                   onTap: () {
//                     _pickImage(ImageSource.gallery);
//                   },
//                   child: _imageData == null
//                       ? Icon(
//                     Icons.add_a_photo,
//                     size: 100.0,
//                   )
//                       : Image.memory(
//                     _imageData,
//                     height: 200.0,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//               _isUploading
//                   ? CircularProgressIndicator()
//                   : Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                 child: ElevatedButton(
//                   onPressed: _startUpload,
//                   child: Text('Save'),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _pickImage(ImageSource source) async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: source);
//     if (pickedFile != null) {
//         setState(() async {
//           _imageData = await pickedFile.readAsBytes();
//         });
//     }
//   }
//   void _startUpload() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isUploading = true;
//       });
//       final user = FirebaseAuth.instance.currentUser;
//       final storage = FirebaseStorage.instance;
//       final storageRef = storage.ref().child('user_pics/${user!.uid}.jpg');
//         final bytes = _imageData.buffer.asUint8List();
//         final uploadTask = storageRef.putData(bytes);
//         await uploadTask;
//
//       final downloadUrl = await storageRef.getDownloadURL();
//       setState(() {
//         _downloadUrl = downloadUrl;
//       });
//
//       final usersRef = FirebaseFirestore.instance.collection('users');
//       final data = {
//         'name': _nameController.text,
//         'address': _addressController.text,
//         'email': user.email,
//         'profilePictureUrl': _downloadUrl,
//       };
//       await usersRef.doc(user.uid).set(data);
//
//       setState(() {
//         _isUploading = false;
//       });
//       Navigator.pop(context);
//     }
//   }
// }

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'homepage.dart';
//
// class EnterUserDataScreen extends StatefulWidget {
//   const EnterUserDataScreen({Key? key}) : super(key: key);
//
//   @override
//   _EnterUserDataScreenState createState() => _EnterUserDataScreenState();
// }
//
// class _EnterUserDataScreenState extends State<EnterUserDataScreen> {
//   final FirebaseFirestore _db = FirebaseFirestore.instance;
//
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//
//   String? _name;
//   String? _contact;
//   String? _address;
//
//   bool _isLoading = false;
//
//   void _submitForm() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true;
//       });
//       _formKey.currentState!.save();
//
//       try {
//         String email = FirebaseAuth.instance.currentUser!.email!;
//         await _db.collection('users').add({
//           'name': _name,
//           'contact': _contact,
//           'address': _address,
//           'email': email,
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('User data saved successfully!')),
//         );
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const HomePage()),
//         );     } catch (error) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('An error occurred while saving user data: $error')),
//         );
//       } finally {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }
//
//   @override
//     Widget build(BuildContext context) {
//     return Scaffold(
//     appBar: AppBar(
//     title: const Text('Enter User Data'),
//     ),
//     body: Padding(
//     padding: const EdgeInsets.all(16.0),
//     child: Form(
//     key: _formKey,
//     child: SingleChildScrollView(
//     child: Column(
//     crossAxisAlignment: CrossAxisAlignment.stretch,
//     children: <Widget>[
//     const SizedBox(height: 16.0),
//     TextFormField(
//     decoration: const InputDecoration(labelText: 'Name'),
//     validator: (value) {
//     if (value!.isEmpty) {
//     return 'Please enter a name.';
//     }
//     return null;
//     },
//     onSaved: (value) {
//     _name = value;
//     },
//     ),
//       const SizedBox(height: 16.0),
//       TextFormField(
//         decoration: const InputDecoration(labelText: 'Contact Number'),
//         validator: (value) {
//           if (value!.isEmpty) {
//             return 'Please enter Contact Number.';
//           }
//           return null;
//         },
//         onSaved: (value) {
//           _contact = value;
//         },
//       ),
//     const SizedBox(height: 16.0),
//     TextFormField(
//     decoration: const InputDecoration(labelText: 'Address'),
//     validator: (value) {
//     if (value!.isEmpty) {
//     return 'Please enter an address.';
//     }
//     return null;
//     },
//     onSaved: (value) {
//     _address = value;
//     },
//     ),
//     const SizedBox(height: 16.0),
//     ElevatedButton(
//     onPressed: _isLoading ? null : _submitForm,
//     child: const Text('Save'),
//     ),
//     ],
//     ),
//     ),
//     ),
//     ),
//     );
//     }
//   }
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// import 'dart:html' if (dart.library.io) 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class EnterUserDataScreen extends StatefulWidget {
//   const EnterUserDataScreen({Key? key}) : super(key: key);
//
//   @override
//   _EnterUserDataScreenState createState() => _EnterUserDataScreenState();
// }
//
// class _EnterUserDataScreenState extends State<EnterUserDataScreen> {
//   final FirebaseFirestore _db = FirebaseFirestore.instance;
//   final FirebaseStorage _storage = FirebaseStorage.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//
//   String? _name;
//   String? _address;
//   String? _profilePictureUrl;
//
//   bool _isLoading = false;
//
//   Future<String?> _pickImage() async {
//     final image = await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (image == null) {
//       return null;
//     }
//     return image.path;
//   }
//
//
//
//   Future<String> _uploadImage(File image) async {
//     // Create a reference to the location you want to upload to in Firebase Storage
//     Reference ref = _storage.ref().child('profile_pictures/${DateTime.now().toString()}');
//     // Upload the file to Firebase Storage
//     UploadTask uploadTask = ref.putFile(image);
//
//     // Wait for the upload to complete
//     TaskSnapshot taskSnapshot = await uploadTask;
//
//     // Return the download URL for the image
//     return await taskSnapshot.ref.getDownloadURL();
//   }
//
//   Future<void> _submitForm() async {
//     if (_formKey.currentState!.validate()) {
//       _formKey.currentState!.save();
//       setState(() {
//         _isLoading = true;
//       });
//       try {
//         // Upload the profile picture to Firebase Storage if it was changed
//         if (_profilePictureUrl != null) {
//           File image = File(_profilePictureUrl!);
//           _profilePictureUrl = await _uploadImage(image);
//         }
//
//         // Get the UID of the current user
//         String email = _auth.currentUser!.email!;
//
//         // Check if the user has already entered their data
//         var querySnapshot = await _db.collection('users').where('email', isEqualTo: email).get();
//         if (querySnapshot.docs.isNotEmpty) {
//           // The user has already entered their data
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('You have already entered your data.'),
//             ),
//           );
//         } else {
//           // Save the user data to Firestore
//           await _db.collection('users').doc().set({
//             'name': _name,
//             'email': email,
//             'address': _address,
//             'profilePictureUrl': _profilePictureUrl,
//           });
//           Navigator.of(context).pop();
//         }
//       } catch (error) {
//         setState(() {
//           _isLoading = false;
//         });
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('An error occurred while saving the data.'),
//           ),
//         );
//       }
//     }
//   }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Form(
//         child:Center(
//         key: _formKey,
//         child: ListView(
//           padding: const EdgeInsets.all(16.0),
//           children: [
//             GestureDetector(
//               onTap: _pickImage,
//               child: CircleAvatar(
//                 radius: 50.0,
//                 backgroundImage: _profilePictureUrl != null ? FileImage(File(_profilePictureUrl!)) : null,
//                 child: _profilePictureUrl == null ? const Icon(Icons.person) : null,
//               ),
//             ),
//             const SizedBox(height: 16.0),
//             TextFormField(
//               decoration: const InputDecoration(labelText: 'Name'),
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter your name.';
//                 }
//                 return null;
//               },
//               onSaved: (value) {
//                 _name = value;
//               },
//             ),
//             const SizedBox(height: 16.0),
//             TextFormField(
//               decoration: const InputDecoration(labelText: 'Address'),
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter your address.';
//                 }
//               },
//               onSaved:
//                   (value) {
//                 _address = value;
//               },
//             ),
//             const SizedBox(height: 16.0),
//             ElevatedButton(
//               onPressed: _submitForm,
//               child: _isLoading ? const CircularProgressIndicator() : const Text('Save'),
//             ),
//           ],
//         ),
//       ),
//       ),
//     );
//   }
// }
//
