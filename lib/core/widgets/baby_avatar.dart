import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class BabyAvatar extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final String? name;

  const BabyAvatar({
    super.key,
    this.imageUrl,
    this.size = 56,
    this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryLight,
        border: Border.all(color: AppColors.primaryMid, width: 2),
      ),
      child: ClipOval(
        child: imageUrl != null
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.primaryLight,
      child: Center(
        child: Text(
          name?.isNotEmpty == true ? name![0].toUpperCase() : '👶',
          style: TextStyle(
            fontSize: size * 0.4,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
