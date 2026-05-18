enum MemoryTag {
  milestone,
  firstTime,
  everyday,
  special,
  funny,
  growth,
}

extension MemoryTagExt on MemoryTag {
  String get label {
    switch (this) {
      case MemoryTag.milestone:
        return 'Milestone';
      case MemoryTag.firstTime:
        return 'First Time';
      case MemoryTag.everyday:
        return 'Everyday';
      case MemoryTag.special:
        return 'Special';
      case MemoryTag.funny:
        return 'Funny';
      case MemoryTag.growth:
        return 'Growth';
    }
  }

  String get emoji {
    switch (this) {
      case MemoryTag.milestone:
        return '🏆';
      case MemoryTag.firstTime:
        return '⭐';
      case MemoryTag.everyday:
        return '☀️';
      case MemoryTag.special:
        return '💗';
      case MemoryTag.funny:
        return '😄';
      case MemoryTag.growth:
        return '📏';
    }
  }

  String get dbValue {
    switch (this) {
      case MemoryTag.milestone:   return 'milestone';
      case MemoryTag.firstTime:   return 'first_time';
      case MemoryTag.everyday:    return 'everyday';
      case MemoryTag.special:     return 'special';
      case MemoryTag.funny:       return 'funny';
      case MemoryTag.growth:      return 'growth';
    }
  }

  static MemoryTag fromDb(String value) {
    switch (value) {
      case 'milestone':   return MemoryTag.milestone;
      case 'first_time':  return MemoryTag.firstTime;
      case 'special':     return MemoryTag.special;
      case 'funny':       return MemoryTag.funny;
      case 'growth':      return MemoryTag.growth;
      default:            return MemoryTag.everyday;
    }
  }}

class MemoryEntry {
  final String id;
  final String babyId;
  final String? imagePath;   // local file path (before upload)
  final String? imageUrl;    // remote image URL (after upload)
  final String? videoPath;   // local video file path (before upload)
  final String? videoUrl;    // remote video URL (after upload)
  final String? caption;
  final DateTime date;
  final MemoryTag tag;
  final int? ageMonths;

  const MemoryEntry({
    required this.id,
    required this.babyId,
    this.imagePath,
    this.imageUrl,
    this.videoPath,
    this.videoUrl,
    this.caption,
    required this.date,
    required this.tag,
    this.ageMonths,
  });

  bool get isVideo => videoUrl != null || videoPath != null;
  bool get hasMedia => imagePath != null || imageUrl != null || videoPath != null || videoUrl != null;

  /// Cloudinary video thumbnail URL — replaces /video/upload/ with /video/upload/so_0/
  String? get videoThumbnailUrl {
    if (videoUrl == null) return null;
    return videoUrl!.replaceFirst('/video/upload/', '/video/upload/so_0,w_400,h_400,c_fill,q_auto,f_jpg/');
  }

  MemoryEntry copyWith({
    String? id,
    String? babyId,
    String? imagePath,
    String? imageUrl,
    String? videoPath,
    String? videoUrl,
    String? caption,
    DateTime? date,
    MemoryTag? tag,
    int? ageMonths,
  }) {
    return MemoryEntry(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      imagePath: imagePath ?? this.imagePath,
      imageUrl: imageUrl ?? this.imageUrl,
      videoPath: videoPath ?? this.videoPath,
      videoUrl: videoUrl ?? this.videoUrl,
      caption: caption ?? this.caption,
      date: date ?? this.date,
      tag: tag ?? this.tag,
      ageMonths: ageMonths ?? this.ageMonths,
    );
  }

  String get displayImage => imagePath ?? imageUrl ?? '';
  bool get hasImage => imagePath != null || imageUrl != null;
}

MemoryTag memoryTagFromDb(String value) {
  switch (value) {
    case 'milestone':   return MemoryTag.milestone;
    case 'first_time':  return MemoryTag.firstTime;
    case 'special':     return MemoryTag.special;
    case 'funny':       return MemoryTag.funny;
    case 'growth':      return MemoryTag.growth;
    default:            return MemoryTag.everyday;
  }
}

// Sample memories for UI
final sampleMemories = [
  MemoryEntry(
    id: '1',
    babyId: '1',
    imageUrl: 'https://images.unsplash.com/photo-1555252333-9f8e92e65df9?w=400',
    caption: 'First time sitting up all by herself! 🎉',
    date: DateTime(2025, 3, 15),
    tag: MemoryTag.milestone,
    ageMonths: 7,
  ),
  MemoryEntry(
    id: '2',
    babyId: '1',
    imageUrl: 'https://images.unsplash.com/photo-1519340241574-2cec6aef0c01?w=400',
    caption: 'Bath time is her favourite time of the day',
    date: DateTime(2025, 3, 10),
    tag: MemoryTag.everyday,
    ageMonths: 7,
  ),
  MemoryEntry(
    id: '3',
    babyId: '1',
    imageUrl: 'https://images.unsplash.com/photo-1490818387583-1baba5e638af?w=400',
    caption: 'Trying solids for the first time — she loved it!',
    date: DateTime(2025, 2, 20),
    tag: MemoryTag.firstTime,
    ageMonths: 6,
  ),
  MemoryEntry(
    id: '4',
    babyId: '1',
    imageUrl: 'https://images.unsplash.com/photo-1517093157656-b9eccef91cb1?w=400',
    caption: 'Sunday morning cuddles 💕',
    date: DateTime(2025, 2, 9),
    tag: MemoryTag.special,
    ageMonths: 6,
  ),
  MemoryEntry(
    id: '5',
    babyId: '1',
    imageUrl: 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400',
    caption: 'Caught her laughing at the ceiling fan 😂',
    date: DateTime(2025, 1, 28),
    tag: MemoryTag.funny,
    ageMonths: 5,
  ),
  MemoryEntry(
    id: '6',
    babyId: '1',
    imageUrl: 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=400',
    caption: '5 months old today! Growing so fast 📏',
    date: DateTime(2025, 1, 12),
    tag: MemoryTag.growth,
    ageMonths: 5,
  ),
];
