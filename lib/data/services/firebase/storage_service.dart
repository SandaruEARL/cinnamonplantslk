import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import '../../../core/utils/constants.dart';


class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload profile picture
  Future<String> uploadProfilePicture(String userId, File imageFile) async {
    try {
      final compressedFile = await _compressImage(imageFile);
      final ref = _storage.ref(). child(
        '${AppConstants.profilePicsPath}/$userId.jpg',
      );

      await ref.putFile(compressedFile);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload profile picture: $e');
    }
  }

  // Upload advertisement images
  Future<List<String>> uploadAdImages(String adId, List<File> imageFiles) async {
    try {
      final List<String> downloadUrls = [];

      for (int i = 0; i < imageFiles.length; i++) {
        final compressedFile = await _compressImage(imageFiles[i]);
        final ref = _storage.ref().child(
          '${AppConstants.adImagesPath}/$adId/image_$i.jpg',
        );

        await ref.putFile(compressedFile);
        final url = await ref.getDownloadURL();
        downloadUrls.add(url);
      }

      return downloadUrls;
    } catch (e) {
      throw Exception('Failed to upload ad images: $e');
    }
  }

  // Upload chat image
  Future<String> uploadChatImage(String chatId, File imageFile) async {
    try {
      final compressedFile = await _compressImage(imageFile);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ref = _storage.ref().child(
        '${AppConstants.chatImagesPath}/$chatId/$timestamp.jpg',
      );

      await ref.putFile(compressedFile);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload chat image: $e');
    }
  }

  // Delete file
  Future<void> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  // Compress image
  Future<File> _compressImage(File file) async {
    try {
      final imageBytes = await file.readAsBytes();
      final image = img.decodeImage(imageBytes);

      if (image == null) return file;

      // Resize if too large
      img.Image resized = image;
      if (image.width > 1080 || image.height > 1080) {
        resized = img.copyResize(
          image,
          width: image.width > image.height ? 1080 : null,
          height: image.height > image.width ? 1080 : null,
        );
      }

      // Compress
      final compressedBytes = img.encodeJpg(resized, quality: 85);

      // Save to temp file
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(compressedBytes);

      return tempFile;
    } catch (e) {
      return file; // Return original if compression fails
    }
  }
}