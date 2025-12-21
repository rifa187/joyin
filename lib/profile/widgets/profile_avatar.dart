import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:joyin/core/app_colors.dart';
import 'package:joyin/core/env.dart';

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
      try {
        final resolvedUrl = _resolvePhotoUrl(photoUrl!.trim());
        if (resolvedUrl != null) {
          imageProvider = NetworkImage(resolvedUrl);
        } else {
          imageProvider = MemoryImage(base64Decode(photoUrl!));
        }
      } catch (e) {
        debugPrint("Gagal memuat gambar: $e");
      }
    }

    return SizedBox(
      height: 130,
      width: 130,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: Alignment.center,
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 56,
                backgroundColor: const Color(0xFFE0E0E0),
                
                backgroundImage: imageProvider,
                
                // <--- PERBAIKAN DISINI: Cek dulu imageProvider null atau tidak
                onBackgroundImageError: imageProvider != null 
                    ? (exception, stackTrace) {
                        debugPrint("Error menampilkan gambar: $exception");
                      }
                    : null, 
                // ---------------------------------------------------------

                child: isLoading
                    ? const CircularProgressIndicator()
                    : (imageProvider == null
                        ? const Icon(Icons.person, size: 60, color: Colors.white)
                        : null),
              ),
            ),
          ),
          
          Positioned(
            right: 24,
            bottom: 8,
            child: GestureDetector(
              onTap: isLoading ? null : onEditTap,
              child: Container(
                height: 28,
                width: 28,
                decoration: BoxDecoration(
                  color: AppColors.joyin,
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

  String? _resolvePhotoUrl(String raw) {
    if (raw.isEmpty) return null;
    if (raw.startsWith('http')) return raw;
    if (raw.startsWith('/') || raw.startsWith('uploads/')) {
      return _joinBase(Env.apiBaseUrl, raw);
    }
    if (raw.contains('/uploads/')) {
      return _joinBase(Env.apiBaseUrl, raw.startsWith('/') ? raw : '/$raw');
    }
    return null;
  }

  String _joinBase(String base, String path) {
    if (base.endsWith('/') && path.startsWith('/')) {
      return '$base${path.substring(1)}';
    }
    if (!base.endsWith('/') && !path.startsWith('/')) {
      return '$base/$path';
    }
    return '$base$path';
  }
}
