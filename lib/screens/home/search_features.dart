import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untarest_app/services/search_service.dart';
import 'package:untarest_app/services/firestore_service.dart';
import 'package:untarest_app/models/search_news.dart';
import 'package:untarest_app/widgets/news_feed_grid.dart';
import 'package:untarest_app/screens/profile/user_profile_page.dart';

enum SearchType { vibes, users }

class SearchFeatures extends StatefulWidget {
  const SearchFeatures({super.key});

  @override
  State<SearchFeatures> createState() => _SearchFeaturesState();
}

class _SearchFeaturesState extends State<SearchFeatures> {
  final TextEditingController _controller = TextEditingController();
  final SearchService _newsService = SearchService();
  final FirestoreService _userService = FirestoreService();

  List<NewsArticle> _newsResults = [];
  List<QueryDocumentSnapshot> _userResults = [];

  bool _isLoading = false;
  bool _showClearButton = false; // <-- State baru untuk tombol hapus
  SearchType _searchType = SearchType.vibes;

  @override
  void initState() {
    super.initState();
    _searchNews(""); // Memuat berita awal
    // Listener untuk mendeteksi perubahan teks
    _controller.addListener(() {
      if (mounted) {
        setState(() {
          _showClearButton = _controller.text.isNotEmpty;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_searchType == SearchType.vibes) {
      _searchNews(query);
    } else {
      _searchUsers(query);
    }
  }

  void _searchNews(String query) async {
    setState(() => _isLoading = true);
    try {
      final data = await _newsService.searchNews(query.isEmpty ? "" : query);
      if (mounted) setState(() => _newsResults = data);
    } catch (e) {
      if (mounted) setState(() => _newsResults = []);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _searchUsers(String query) async {
    if (query.isEmpty) {
      if (mounted) setState(() => _userResults = []);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final result = await _userService.searchUsers(query);
      if (mounted) setState(() => _userResults = result.docs);
    } catch (e) {
      if (mounted) setState(() => _userResults = []);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- FUNGSI BARU UNTUK MENGHAPUS TEKS ---
  void _clearSearch() {
    _controller.clear();
    if (_searchType == SearchType.vibes) {
      _searchNews(""); // Kembali ke tampilan berita awal
    } else {
      _searchUsers(""); // Kosongkan hasil pencarian user
    }
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: TextField(
          controller: _controller,
          onChanged: _onSearchChanged,
          style: const TextStyle(fontFamily: "Poppins"),
          decoration: InputDecoration(
            hintText: _searchType == SearchType.vibes
                ? "Untarian let's search for your daily new vibes!"
                : "Cari pengguna berdasarkan username...",
            hintStyle: const TextStyle(fontFamily: "Poppins", fontSize: 12),
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            // --- PERUBAHAN DI SINI ---
            suffixIcon: _showClearButton
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: _clearSearch,
                  )
                : null, // Tampilkan tombol hanya jika ada teks
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/BG_UNTAR.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: CupertinoSlidingSegmentedControl<SearchType>(
                groupValue: _searchType,
                backgroundColor: Colors.white.withOpacity(0.5),
                thumbColor: Colors.white,
                onValueChanged: (SearchType? value) {
                  if (value != null) {
                    setState(() {
                      _searchType = value;
                      _clearSearch(); // Hapus pencarian saat mengganti mode
                    });
                  }
                },
                children: const {
                  SearchType.vibes:
                      Padding(padding: EdgeInsets.all(8), child: Text('Vibes')),
                  SearchType.users:
                      Padding(padding: EdgeInsets.all(8), child: Text('Users')),
                },
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    if (_searchType == SearchType.vibes) {
      return NewsFeedGrid(articles: _newsResults);
    } else {
      if (_controller.text.isEmpty) {
        return const Center(
          child: Text(
            "Ketik username untuk mencari...",
            style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
          ),
        );
      }

      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('username',
                isGreaterThanOrEqualTo: _controller.text.toLowerCase())
            .where('username',
                isLessThanOrEqualTo: '${_controller.text.toLowerCase()}\uf8ff')
            .limit(10)
            .snapshots(), // 🔥 realtime
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "Tidak ada pengguna ditemukan",
                style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
              ),
            );
          }

          final users = snapshot.data!.docs;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userData = users[index].data() as Map<String, dynamic>;
              final userId = users[index].id;
              final profileImageUrl = userData['profileImageUrl'];
              final username = userData['username'] ?? 'No Username';
              final nim = userData['nim'] ?? ''; // ✅ NIM realtime

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: profileImageUrl != null
                        ? NetworkImage(profileImageUrl)
                        : null,
                    child: profileImageUrl == null
                        ? Text(username.isNotEmpty
                            ? username[0].toUpperCase()
                            : 'U')
                        : null,
                  ),
                  title: Text(
                    username,
                    style: const TextStyle(fontFamily: 'Poppins'),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserProfilePage(userId: userId),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      );
    }
  }
}
