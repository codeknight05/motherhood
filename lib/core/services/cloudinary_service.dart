import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';

/// Cloudinary image upload service.
/// Uses unsigned uploads — safe to use in client apps.
class CloudinaryService {
  CloudinaryService._();

  // ← Replace with your actual Cloud Name from cloudinary.com dashboard
  static const String _cloudName = 'dpfowxtg2';
  static const String _uploadPreset = 'motherhood_memories';

  static final _cloudinary = CloudinaryPublic(
    _cloudName,
    _uploadPreset,
    cache: false,
  );

  /// Upload a memory photo and return its secure URL.
  /// [folder] organises files in Cloudinary (e.g. userId/babyId)
  static Future<String> uploadMemoryPhoto({
    required File file,
    required String userId,
    required String babyId,
  }) async {
    final response = await _cloudinary.uploadFile(
      CloudinaryFile.fromFile(
        file.path,
        folder: 'motherhood/$userId/$babyId',
        resourceType: CloudinaryResourceType.Image,
      ),
    );
    return response.secureUrl;
  }

  /// Upload a baby avatar and return its secure URL.
  static Future<String> uploadBabyAvatar({
    required File file,
    required String babyId,
  }) async {
    final response = await _cloudinary.uploadFile(
      CloudinaryFile.fromFile(
        file.path,
        folder: 'motherhood/avatars',
        publicId: babyId,
        resourceType: CloudinaryResourceType.Image,
      ),
    );
    return response.secureUrl;
  }

  /// Returns a thumbnail URL for a given Cloudinary image URL.
  /// Useful for grid views — loads faster than full resolution.
  static String thumbnailUrl(String originalUrl, {int width = 300, int height = 300}) {
    // Insert transformation into the Cloudinary URL
    return originalUrl.replaceFirst(
      '/upload/',
      '/upload/w_$width,h_$height,c_fill,q_auto,f_auto/',
    );
  }
}
