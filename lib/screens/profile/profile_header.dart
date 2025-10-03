import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String nim;
  final String? profileImageUrl;
  final VoidCallback? onEditPressed;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.nim,
    this.profileImageUrl,
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 60.0, bottom: 20.0),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 56,
                  backgroundImage: profileImageUrl != null
                      ? NetworkImage(profileImageUrl!)
                      : null,
                  child: profileImageUrl == null
                      ? const Icon(Icons.person, size: 60, color: Colors.grey)
                      : null,
                ),
              ),
              // Tombol edit hanya akan muncul jika onEditPressed TIDAK null
              if (onEditPressed != null)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: onEditPressed,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 118, 0, 0),
                        shape: BoxShape.circle,
                        border: Border.fromBorderSide(
                          BorderSide(color: Colors.white, width: 2),
                        ),
                      ),
                      child: const Icon(Icons.edit, color: Colors.white, size: 20),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
              color: Colors.black, // Warna diubah ke hitam
              shadows: [Shadow(blurRadius: 1, color: Colors.white54)]
            ),
          ),
          const SizedBox(height: 4),
          Text(
            nim,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Poppins',
              color: Colors.black54, // Warna diubah ke abu-abu gelap
              shadows: [Shadow(blurRadius: 1, color: Colors.white54)]
            ),
          ),
        ],
      ),
    );
  }
}

