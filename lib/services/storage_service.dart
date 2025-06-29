import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload profile picture
  static Future<String?> uploadProfilePicture(
      String userId, File imageFile) async {
    try {
      final ref = _storage.ref().child('profile_pictures/$userId.jpg');
      final uploadTask = ref.putFile(imageFile);

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading profile picture: $e');
      return null;
    }
  }

  // Upload chat media (images, files)
  static Future<String?> uploadChatMedia(
      String chatId, String fileName, File file) async {
    try {
      final ref = _storage.ref().child('chat_media/$chatId/$fileName');
      final uploadTask = ref.putFile(file);

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading chat media: $e');
      return null;
    }
  }

  // Delete file
  static Future<bool> deleteFile(String filePath) async {
    try {
      final ref = _storage.ref().child(filePath);
      await ref.delete();
      return true;
    } catch (e) {
      print('Error deleting file: $e');
      return false;
    }
  }

  // Get download URL for a file
  static Future<String?> getDownloadUrl(String filePath) async {
    try {
      final ref = _storage.ref().child(filePath);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error getting download URL: $e');
      return null;
    }
  }
}
