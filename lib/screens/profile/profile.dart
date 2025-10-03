import 'package:flutter/material.dart';
import 'dart:io';
import 'edit_profile.dart';
import 'package:untarest_app/models/post_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _name = 'Nama Lengkap';
  String _nim = 'NIM';
  File? _imageFile;

  List<UserPost> userPosts = [];

  static const Color untarRed = Color.fromARGB(255, 118, 0, 0);

  void _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfilePage()),
    );

    if (result != null) {
      setState(() {
        _name = result['name'];
        _nim = result['nim'];
        _imageFile = result['imageFile'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: untarRed,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          // 1. Background Image UNTAR
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/BG_UNTAR.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // 2. Overlay Gelap
          Container(
            color: Colors.black.withOpacity(0.5),
          ),

          // 3. Konten Utama (Header & My Uploads)
          SingleChildScrollView(
            child: Column(
              children: [
                // Bagian Header Profil
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 100),

                      // Avatar (Semi-Transparan dengan Ikon Person)
                      _imageFile != null
                          ? CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.transparent,
                              child: ClipOval(
                                child: Image.file(
                                  _imageFile!,
                                  fit: BoxFit.cover,
                                  width: 120,
                                  height: 120,
                                ),
                              ),
                            )
                          : Container(
                              width: 120, // 2 * radius
                              height: 120, // 2 * radius
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                // Background abu-abu semi-transparan
                                color: Colors.grey.withOpacity(0.5),
                              ),
                              child: const Icon(
                                Icons.person, // Menggunakan ikon person kembali
                                size:
                                    50, // Ukuran ikon dikecilkan (dari 60 menjadi 50)
                                color: Colors.white,
                              ),
                            ),

                      const SizedBox(height: 15),
                      Text(
                        _name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          shadows: [
                            Shadow(color: Colors.black54, blurRadius: 4.0)
                          ],
                        ),
                      ),
                      Text(
                        _nim,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          color: Colors.white70,
                          shadows: [
                            Shadow(color: Colors.black54, blurRadius: 4.0)
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _ProfileButton(
                        text: 'Edit Profile',
                        onPressed: _navigateToEditProfile,
                        icon: Icons.edit,
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),

                // Bagian Konten "My Uploads" (Kartu Putih)
                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(minHeight: screenHeight * 0.55),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'My Uploads',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: untarRed,
                          ),
                        ),
                        const Divider(height: 30, color: Colors.grey),
                        userPosts.isEmpty
                            ? Column(
                                children: [
                                  const SizedBox(height: 20),
                                  Icon(Icons.image_not_supported_outlined,
                                      size: 80, color: Colors.grey[300]),
                                  const SizedBox(height: 10),
                                  const Text("Belum ada Feeds!",
                                      style: TextStyle(color: Colors.grey)),
                                  const SizedBox(height: 20),
                                  _UploadButton(),
                                  const SizedBox(height: 80),
                                ],
                              )
                            : GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                ),
                                itemCount: userPosts.length,
                                itemBuilder: (context, index) {
                                  final post = userPosts[index];
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(post.imagePath),
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData icon;

  static const Color untarRed = Color.fromARGB(255, 118, 0, 0);

  const _ProfileButton({
    required this.text,
    required this.onPressed,
    this.icon = Icons.arrow_forward,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: untarRed,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        elevation: 5,
      ),
    );
  }
}

class _UploadButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.add_circle_outline),
      label: const Text('Upload Feeds Baru'),
      style: OutlinedButton.styleFrom(
        foregroundColor: _ProfilePageState.untarRed,
        side: const BorderSide(color: _ProfilePageState.untarRed, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
    );
  }
}
