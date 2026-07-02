import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker     _picker  = ImagePicker();

  Future<String?> pickAndUploadUserImage(String userId) async =>
      _pickAndUpload('profiles/$userId/profile.jpg');

  Future<String?> pickAndUploadChildImage(String childId) async =>
      _pickAndUpload('children/$childId/profile.jpg');

  Future<String?> _pickAndUpload(String storagePath) async {
    try {
      final XFile? image = await _picker.pickImage(
        source:       ImageSource.gallery,
        maxWidth:     512,
        maxHeight:    512,
        imageQuality: 75,
      );
      if (image == null) return null;

      final ref = _storage.ref().child(storagePath);
      await ref.putFile(File(image.path));
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }
}