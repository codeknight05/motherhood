import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  /// Upload a memory video and return its secure URL.
  static Future<String> uploadMemoryVideo({
    required File file,
    required String userId,
    required String babyId,
  }) async {
    final response = await _cloudinary.uploadFile(
      CloudinaryFile.fromFile(
        file.path,
        folder: 'motherhood/$userId/$babyId',
        resourceType: CloudinaryResourceType.Video,
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

  /// Extracts the Cloudinary public_id from a secure URL.
  /// e.g. https://res.cloudinary.com/cloud/image/upload/v123/motherhood/uid/bid/abc.jpg
  ///   → motherhood/uid/bid/abc
  static String? extractPublicId(String url) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      // Find 'upload' segment index
      final uploadIdx = segments.indexOf('upload');
      if (uploadIdx == -1 || uploadIdx + 1 >= segments.length) return null;
      // Skip the version segment (starts with 'v' followed by digits)
      var startIdx = uploadIdx + 1;
      if (startIdx < segments.length &&
          RegExp(r'^v\d+$').hasMatch(segments[startIdx])) {
        startIdx++;
      }
      if (startIdx >= segments.length) return null;
      // Join remaining segments and strip file extension
      final joined = segments.sublist(startIdx).join('/');
      final dotIdx = joined.lastIndexOf('.');
      return dotIdx != -1 ? joined.substring(0, dotIdx) : joined;
    } catch (_) {
      return null;
    }
  }

  /// Delete a Cloudinary asset by calling a Supabase Edge Function.
  /// The Edge Function holds the Cloudinary API secret server-side.
  /// If the function is not deployed yet, this logs and returns silently
  /// (the Supabase row is still deleted — the asset becomes orphaned).
  static Future<void> deletePhoto(String imageUrl) async {
    final publicId = extractPublicId(imageUrl);
    if (publicId == null) return;

    try {
      await Supabase.instance.client.functions.invoke(
        'delete-cloudinary-asset',
        body: {'public_id': publicId},
      );
    } catch (e) {
      // Edge Function not deployed yet — asset will be orphaned on Cloudinary.
      // The Supabase row is deleted separately, so the app won't show it.
      debugPrint('[Cloudinary] delete-cloudinary-asset not available: $e');
    }
  }
}
