import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class CameraPhotoSection extends StatelessWidget {
  final File? image;
  final Uint8List? imageBytes;
  final VoidCallback? onPickPhoto;
  final bool enabled;
  final bool loading;

  const CameraPhotoSection({
    super.key,
    this.image,
    this.imageBytes,
    this.onPickPhoto,
    this.enabled = true,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final active = enabled && !loading;
    final hasImage = imageBytes != null || image != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 86,
                  height: 86,
                  color: const Color(0xFFF8FAFC),
                  child: hasImage
                      ? Image.memory(
                          imageBytes!,
                          fit: BoxFit.cover,
                        )
                      : const Icon(
                          Icons.camera_alt_outlined,
                          size: 34,
                          color: Color(0xFF94A3B8),
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Foto Presensi',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      !enabled
                          ? 'Masuk ke radius kantor terlebih dahulu untuk mengambil foto.'
                          : !hasImage
                              ? 'Ambil foto terlebih dahulu sebelum absen.'
                              : 'Foto sudah siap. Anda bisa melanjutkan absensi.',
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.35,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: active ? onPickPhoto : null,
              icon: loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      !hasImage
                          ? Icons.camera_alt_rounded
                          : Icons.refresh_rounded,
                    ),
              label: Text(!hasImage ? 'Ambil Foto' : 'Ambil Ulang Foto'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFE5E7EB),
                disabledForegroundColor: const Color(0xFF9CA3AF),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}