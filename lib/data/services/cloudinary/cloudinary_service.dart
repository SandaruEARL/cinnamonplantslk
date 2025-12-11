import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class CloudinaryService {
  static const String cloudName = 'dffpwcb7b';
  static const String apiKey = '837666793599892';
  static const String apiSecret = 'rWBNndQN82SoM5vLUxxLzRzwRZ4';

  /// Compress image before upload
  Future<File> _compressImage(File file, {int quality = 85}) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        minWidth: 1920,
        minHeight: 1920,
        format: CompressFormat.jpeg,
      );

      if (result != null) {
        final originalSize = await file.length();
        final compressedSize = await result.length();
        final savedPercent = ((originalSize - compressedSize) / originalSize * 100).toStringAsFixed(1);
        print('   📉 Compressed: ${(originalSize / 1024).toStringAsFixed(1)}KB → ${(compressedSize / 1024).toStringAsFixed(1)}KB (saved $savedPercent%)');
        return File(result.path);
      }

      return file;
    } catch (e) {
      print('   ⚠️ Compression failed, using original: $e');
      return file;
    }
  }

  /// Upload advertisement images with parallel processing
  Future<List<String>> uploadAdImages(List<File> images) async {
    if (images.isEmpty) return [];

    print('📤 Starting optimized upload for ${images.length} images');
    final startTime = DateTime.now();

    try {
      // Step 1: Compress all images in parallel
      print('🔄 Compressing ${images.length} images...');
      final compressionFutures = images.map((img) => _compressImage(img)).toList();
      final compressedImages = await Future.wait(compressionFutures);

      // Step 2: Upload in batches of 3 for optimal performance
      print('📤 Uploading compressed images...');
      final List<String> uploadedUrls = [];
      final batchSize = 3;

      for (int i = 0; i < compressedImages.length; i += batchSize) {
        final end = (i + batchSize < compressedImages.length)
            ? i + batchSize
            : compressedImages.length;
        final batch = compressedImages.sublist(i, end);

        final batchFutures = <Future<String?>>[];
        for (int j = 0; j < batch.length; j++) {
          batchFutures.add(_uploadSingleImage(batch[j], i + j));
        }

        final batchResults = await Future.wait(batchFutures);
        uploadedUrls.addAll(batchResults.whereType<String>());
      }

      final duration = DateTime.now().difference(startTime).inSeconds;
      print('✅ Upload complete: ${uploadedUrls.length}/${images.length} successful in ${duration}s');

      if (uploadedUrls.isEmpty && images.isNotEmpty) {
        throw Exception('Failed to upload any images. Check your internet connection.');
      }

      return uploadedUrls;
    } catch (e, stackTrace) {
      print('❌ Upload error: $e');
      print('Stack: $stackTrace');
      rethrow;
    }
  }

  /// Upload single image (internal method)
  Future<String?> _uploadSingleImage(File image, int index) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final publicId = 'ads_${DateTime.now().millisecondsSinceEpoch}_$index';
      final folder = 'cinnamon_marketplace/advertisements';
      final eager = 'w_400,h_400,c_fill,q_auto:eco,f_auto|w_800,h_800,c_limit,q_auto,f_auto';

      // ✅ CRITICAL FIX: Include ALL parameters in signature (alphabetically ordered)
      // Cloudinary validates: eager, eager_async, folder, public_id, timestamp
      final paramsToSign = 'eager=$eager&eager_async=true&folder=$folder&public_id=$publicId&timestamp=$timestamp$apiSecret';
      final signature = sha1.convert(utf8.encode(paramsToSign)).toString();

      print('   📸 Uploading image ${index + 1}');

      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      final request = http.MultipartRequest('POST', uri);

      // Add the signed parameters (these are part of the signature)
      request.fields['folder'] = folder;
      request.fields['public_id'] = publicId;
      request.fields['timestamp'] = timestamp.toString();
      request.fields['signature'] = signature;

      // Add api_key (NOT part of signature)
      request.fields['api_key'] = apiKey;

      // Add eager transformations (THESE ARE part of signature!)
      request.fields['eager'] = eager;
      request.fields['eager_async'] = 'true';

      request.files.add(await http.MultipartFile.fromPath('file', image.path));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseData);
        final url = jsonResponse['secure_url'] as String;
        print('   ✅ Uploaded: $url');
        return url;
      } else {
        print('   ❌ Upload failed: $responseData');
        return null;
      }
    } catch (e) {
      print('   ❌ Error uploading image ${index + 1}: $e');
      return null;
    }
  }

  /// Upload profile picture
  Future<String> uploadProfileImage(File image, String userId) async {
    try {
      print('📤 Compressing profile image...');
      final compressedImage = await _compressImage(image, quality: 90);

      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final publicId = 'profiles_$userId';
      final folder = 'cinnamon_marketplace/profiles';
      final eager = 'w_200,h_200,c_fill,g_face,q_auto,f_auto|w_400,h_400,c_fill,g_face,q_auto,f_auto';

      // ✅ CRITICAL FIX: Include ALL parameters in signature (alphabetically ordered)
      final paramsToSign = 'eager=$eager&eager_async=true&folder=$folder&overwrite=true&public_id=$publicId&timestamp=$timestamp$apiSecret';
      final signature = sha1.convert(utf8.encode(paramsToSign)).toString();

      print('📤 Uploading profile image');

      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      final request = http.MultipartRequest('POST', uri);

      // Add signed parameters (these are part of the signature)
      request.fields['folder'] = folder;
      request.fields['overwrite'] = 'true';
      request.fields['public_id'] = publicId;
      request.fields['timestamp'] = timestamp.toString();
      request.fields['signature'] = signature;

      // Add api_key (NOT part of signature)
      request.fields['api_key'] = apiKey;

      // Eager transformations for profile (THESE ARE part of signature!)
      request.fields['eager'] = eager;
      request.fields['eager_async'] = 'true';

      request.files.add(await http.MultipartFile.fromPath('file', compressedImage.path));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseData);
        final url = jsonResponse['secure_url'] as String;
        print('✅ Profile image uploaded: $url');
        return url;
      } else {
        print('❌ Upload failed: $responseData');
        throw Exception('Failed to upload profile image');
      }
    } catch (e) {
      print('❌ Error: $e');
      throw Exception('Failed to upload profile image: $e');
    }
  }

  /// Delete image by public ID
  Future<void> deleteImage(String publicId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      final paramsToSign = 'public_id=$publicId&timestamp=$timestamp$apiSecret';
      final signature = sha1.convert(utf8.encode(paramsToSign)).toString();

      print('🗑️ Deleting image: $publicId');

      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/destroy');
      final response = await http.post(
        uri,
        body: {
          'public_id': publicId,
          'timestamp': timestamp.toString(),
          'api_key': apiKey,
          'signature': signature,
        },
      );

      if (response.statusCode == 200) {
        print('✅ Image deleted successfully');
      } else {
        print('❌ Delete failed: ${response.body}');
      }
    } catch (e) {
      print('❌ Error deleting image: $e');
      throw Exception('Failed to delete image: $e');
    }
  }

  /// Get optimized image URL with Cloudinary transformations
  static String getOptimizedImageUrl(
      String originalUrl, {
        int? width,
        int? height,
        String quality = 'auto',
        String format = 'auto',
        String crop = 'limit',
      }) {
    if (originalUrl.isEmpty || !originalUrl.contains('/upload/')) {
      return originalUrl;
    }

    final parts = originalUrl.split('/upload/');
    if (parts.length != 2) return originalUrl;

    final transformations = <String>[];

    if (width != null) transformations.add('w_$width');
    if (height != null) transformations.add('h_$height');
    transformations.add('c_$crop');
    transformations.add('q_$quality');
    transformations.add('f_$format');

    final transformationString = transformations.join(',');
    return '${parts[0]}/upload/$transformationString/${parts[1]}';
  }

  /// Get thumbnail URL (for grid/list views)
  static String getThumbnailUrl(String originalUrl, {int size = 400}) {
    return getOptimizedImageUrl(
      originalUrl,
      width: size,
      height: size,
      crop: 'fill',
      quality: 'auto:eco',
    );
  }

  /// Get detail view URL (for product details)
  static String getDetailUrl(String originalUrl, {int maxWidth = 1200}) {
    return getOptimizedImageUrl(
      originalUrl,
      width: maxWidth,
      crop: 'limit',
      quality: 'auto:good',
    );
  }

  /// Get tiny blur placeholder URL (for instant loading)
  static String getPlaceholderUrl(String originalUrl) {
    return getOptimizedImageUrl(
      originalUrl,
      width: 20,
      height: 20,
      crop: 'fill',
      quality: 'auto:low',
    );
  }
}