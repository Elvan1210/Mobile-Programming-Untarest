import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String nim;
  final String? profileImageUrl;
  final VoidCallback onEditPressed;

  static const Color untarRed = Color.fromARGB(255, 118, 0, 0);

  const ProfileHeader({
    super.key,
    required this.name,
    required this.nim,
    this.profileImageUrl,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Profile Picture
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey.withOpacity(0.3),
                  backgroundImage: profileImageUrl != null
                      ? NetworkImage(profileImageUrl!)
                      : null,
                  child: profileImageUrl == null
                      ? const Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: onEditPressed,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: untarRed,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Name
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black45,
                  blurRadius: 4.0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // NIM
          Text(
            nim,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              shadows: const [
                Shadow(
                  color: Colors.black45,
                  blurRadius: 4.0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
