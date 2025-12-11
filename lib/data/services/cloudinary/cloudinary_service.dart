import 'dart:io';
import 'package:cloudinary_api/uploader/cloudinary_uploader.dart';
import 'package:cloudinary_api/src/request/model/uploader_params.dart';
import 'package:cloudinary_url_gen/cloudinary.dart';

class CloudinaryService {
  late final Cloudinary _cloudinary;

  CloudinaryService() {
    _cloudinary = Cloudinary.fromStringUrl(
        'cloudinary://814431196595558:yjspimdaN3aFuK7OQW9k41GA0hE@cinnamonmarketplace'
    );
    _cloudinary.config.urlConfig.secure = true;
  }

  /// Upload advertisement images
  Future<List<String>> uploadAdImages(List<File> images) async {
    final List<String> uploadedUrls = [];

    for (int i = 0; i < images.length; i++) {
      try {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final response = await _cloudinary.uploader().upload(
          images[i].path,
          params: UploadParams(
            publicId: 'ads/${timestamp}_$i',
            folder: 'cinnamon_marketplace/advertisements',
            resourceType: 'image',
            uniqueFilename: true,
            overwrite: false,
          ),
        );

        if (response?.data?.secureUrl != null) {
          uploadedUrls.add(response!.data!.secureUrl!);
        }
      } catch (e) {
        throw Exception('Failed to upload advertisement image: $e');
      }
    }

    return uploadedUrls;
  }

  /// Upload profile picture
  Future<String> uploadProfileImage(File image, String userId) async {
    try {
      final response = await _cloudinary.uploader().upload(
        image.path,
        params: UploadParams(
          publicId: 'profiles/$userId',
          folder: 'cinnamon_marketplace/profiles',
          resourceType: 'image',
          uniqueFilename: false,
          overwrite: true,
        ),
      );

      if (response?.data?.secureUrl != null) {
        return response!.data!.secureUrl!;
      } else {
        throw Exception('No URL returned from Cloudinary');
      }
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  /// Delete image by public ID (optional - for cleanup)
  /// Delete image by public ID (optional - for cleanup)
  Future<void> deleteImage(String publicId) async {
    try {
      await _cloudinary.uploader().destroy(
          DestroyParams(publicId: publicId)
      );
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }

}