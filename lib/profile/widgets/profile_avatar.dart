import 'package:flutter/material.dart';
import 'package:joyin/core/app_colors.dart';

class ProfileAvatar extends StatelessWidget {
  final String? photoUrl;
  final bool isLoading;
  final VoidCallback onEditTap;

  const ProfileAvatar({
    super.key,
    this.photoUrl,
    required this.isLoading,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      imageProvider = NetworkImage(photoUrl!);
    }

    return SizedBox(
      height: 130,
      width: 130,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Lingkaran Foto
          Align(
            alignment: Alignment.center,
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 56,
                backgroundColor: const Color(0xFFE0E0E0),
                backgroundImage: imageProvider,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : (imageProvider == null
                        ? const Icon(Icons.person, size: 60, color: Colors.white)
                        : null),
              ),
            ),
          ),
          // Tombol Edit (Pensil)
          Positioned(
            right: 24,
            bottom: 8,
            child: GestureDetector(
              onTap: isLoading ? null : onEditTap,
              child: Container(
                height: 28,
                width: 28,
                decoration: BoxDecoration(
                  color: AppColors.joyin, // Ganti warna hardcoded
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}