import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class StorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload a captured image and return its download URL
  static Future<String?> uploadAlertImage(File imageFile, String alertId) async {
    try {
      final fileName = path.basename(imageFile.path);
      final ref = _storage.ref().child('alert_images/$alertId/$fileName');

      final uploadTask = await ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }

  /// Delete an image from storage
  static Future<void> deleteAlertImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      print('Delete error: $e');
    }
  }

  /// Get all images for an alert
  static Future<List<String>> getAlertImages(String alertId) async {
    try {
      final ref = _storage.ref().child('alert_images/$alertId');
      final result = await ref.listAll();
      final urls = await Future.wait(
        result.items.map((item) => item.getDownloadURL()),
      );
      return urls;
    } catch (e) {
      print('List error: $e');
      return [];
    }
  }
}