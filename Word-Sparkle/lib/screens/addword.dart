import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../customs/customcolors.dart';
import 'home.dart';

class AddWord extends StatefulWidget {
  const AddWord({Key? key}) : super(key: key);

  @override
  State<AddWord> createState() => _AddWordState();
}

class _AddWordState extends State<AddWord> {
  final _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _picker = ImagePicker();

  File? _image;
  final _formKey = GlobalKey<FormState>();
  final _turkceController = TextEditingController();
  final _ingilizceController = TextEditingController();
  final _cumleController = TextEditingController();

  @override
  void dispose() {
    _turkceController.dispose();
    _ingilizceController.dispose();
    _cumleController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    setState(() {
      _image = pickedFile != null ? File(pickedFile.path) : null;
    });
  }

  Future<void> _addDataToFirestore() async {
    final user = _auth.currentUser;
    if (user != null) {
      String? imageUrl;
      if (_image != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('images/${DateTime.now().millisecondsSinceEpoch}');
        await storageRef.putFile(_image!);
        imageUrl = await storageRef.getDownloadURL();
      }

      final kelimeData = {
        'turkce': _turkceController.text,
        'ingilizce': _ingilizceController.text,
        'cumle': _cumleController.text,
        'imageUrl': imageUrl,
        'nextTestDate': Timestamp.now(),
        'addedDate': Timestamp.now(),
      };

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('words')
          .add(kelimeData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: CustomColors.themecolor,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: deviceWidth,
                height: deviceHeight / 10,
                decoration: const BoxDecoration(
                  color: CustomColors.themecolor,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back,
                        size: 40,
                        color: CustomColors.lighttextcolor,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'KELİME EKLE',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: CustomColors.darktextcolor,
                      ),
                    ),
                    const Spacer(flex: 2),
                  ],
                ),
              ),
              InkWell(
                onTap: _pickImage,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: CustomColors.lighttextcolor,
                      border: Border.all(
                        color: CustomColors.buttoncolor,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: _image != null
                        ? Image.file(_image!, fit: BoxFit.cover)
                        : const Center(
                            child: Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 30,
                            ),
                          ),
                  ),
                ),
              ),
              Form(
                key: _formKey,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _turkceController,
                              label: 'Türkçe Kelime',
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? 'Türkçe kelime boş olamaz'
                                      : null,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildTextField(
                              controller: _ingilizceController,
                              label: 'İngilizce Kelime',
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? 'İngilizce kelime boş olamaz'
                                      : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _cumleController,
                        label: 'Örnek Cümleler',
                        maxLines: 5,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Örnek cümleler boş olamaz'
                            : null,
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            await _addDataToFirestore();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const HomeScreen()),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    const Text('Lütfen tüm alanları doldurun'),
                                duration: const Duration(seconds: 2),
                                backgroundColor: CustomColors.errorcolor,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(200, 50),
                          backgroundColor: Colors.black.withOpacity(0.75),
                        ),
                        child: const Text(
                          'EKLE',
                          style: TextStyle(
                              fontSize: 20, color: CustomColors.lighttextcolor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    // customs dosyasına aktarılacak customwidget olarak kullanılacak
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 10),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              filled: true,
              fillColor: CustomColors.lighttextcolor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: CustomColors.lighttextcolor),
              ),
              errorStyle: TextStyle(color: CustomColors.errorcolor),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: CustomColors.errorcolor),
              ),
            ),
            validator: validator,
          ),
        ],
      ),
    );
  }
}
