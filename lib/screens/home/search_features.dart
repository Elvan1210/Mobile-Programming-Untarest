import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untarest_app/services/search_service.dart';
import 'package:untarest_app/services/firestore_service.dart';
import 'package:untarest_app/models/search_news.dart';
import 'package:untarest_app/widgets/news_feed_grid.dart';
import 'package:untarest_app/screens/profile/user_profile_page.dart';
import 'package:untarest_app/utils/constants.dart';

enum SearchType { trends, users, posts }

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
  List<DocumentSnapshot> _postResults = [];

  bool _isLoading = false;
  bool _showClearButton = false; // <-- State baru untuk tombol hapus
  SearchType _searchType = SearchType.trends;
  List<String> _regions = [];
  String _selectedRegion = 'Global';
  bool _showSuggestions = false;
  final FocusNode _searchFocusNode = FocusNode();
  
  // Popular search suggestions based on news content
  final List<String> _searchSuggestions = [
    'Lisa', 'Jisoo', 'Blackpink', 'Trump', 'Donald Trump',
    'Anime', 'Attack on Titan', 'Jujutsu Kaisen', 'Studio Ghibli',
    'Memes', 'Politics', 'Gaming', 'Love and Deepspace',
    'Taylor Swift', 'Celebrity', 'K-Pop', 'Indonesia',
    'Global trends', 'Entertainment', 'News',
  ];
  
  List<String> _filteredSuggestions = [];

  @override
  void initState() {
    super.initState();
    _loadRegions();
    _searchNews(""); // Memuat berita awal (default Global -> trending)
    
    // Listener untuk mendeteksi perubahan teks dan fokus
    _controller.addListener(() {
      if (mounted) {
        final query = _controller.text;
        setState(() {
          _showClearButton = query.isNotEmpty;
          if (query.isNotEmpty) {
            _filteredSuggestions = _searchSuggestions
                .where((suggestion) => 
                    suggestion.toLowerCase().contains(query.toLowerCase()))
                .take(5)
                .toList();
            _showSuggestions = _filteredSuggestions.isNotEmpty && _searchFocusNode.hasFocus;
          } else {
            _filteredSuggestions = [];
            _showSuggestions = false;
          }
        });
      }
    });
    
    _searchFocusNode.addListener(() {
      if (mounted) {
        setState(() {
          _showSuggestions = _searchFocusNode.hasFocus && 
                            _controller.text.isNotEmpty && 
                            _filteredSuggestions.isNotEmpty;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_searchType == SearchType.trends) {
      _searchNews(query);
    } else if (_searchType == SearchType.users) {
      _searchUsers(query);
    } else {
      _searchPosts(query);
    }
  }

  Future<void> _loadRegions() async {
    try {
      final regions = await _newsService.getAvailableRegions();
      if (mounted) {
        setState(() {
          _regions = regions;
          // Ensure _selectedRegion is valid
          if (!_regions.contains(_selectedRegion)) {
            _selectedRegion = _regions.isNotEmpty ? _regions.first : 'Global';
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _regions = ['Global']; // Fallback
          _selectedRegion = 'Global';
        });
      }
    }
  }

  void _searchNews(String query) async {
    setState(() => _isLoading = true);
    try {
      // When Global selected, SearchService will filter to region Global and isTrending:true
      final regionParam = _selectedRegion.isEmpty ? 'global' : _selectedRegion;
      final data = await _newsService.searchNews(
        query.isEmpty ? "" : query,
        region: regionParam,
      );
      if (mounted) setState(() => _newsResults = data);
    } catch (e) {
      if (mounted) setState(() => _newsResults = []);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _searchUsers(String query) async {
    // Users are searched via StreamBuilder in real-time, no need to store results
    // This method is kept for consistency but doesn't need to do anything
  }

  void _searchPosts(String query) async {
    if (query.isEmpty) {
      if (mounted) setState(() => _postResults = []);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final result = await _userService.searchUserPostsByText(query);
      if (mounted) setState(() => _postResults = result);
    } catch (e) {
      if (mounted) setState(() => _postResults = []);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- FUNGSI BARU UNTUK MENGHAPUS TEKS ---
  void _clearSearch() {
    _controller.clear();
    _filteredSuggestions = [];
    _showSuggestions = false;
    if (_searchType == SearchType.trends) {
      _searchNews(""); // Kembali ke tampilan berita awal
    } else {
      _searchUsers(""); // Kosongkan hasil pencarian user
    }
    FocusScope.of(context).unfocus();
  }
  
  void _selectSuggestion(String suggestion) {
    _controller.text = suggestion;
    _showSuggestions = false;
    _onSearchChanged(suggestion);
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
          focusNode: _searchFocusNode,
          onChanged: _onSearchChanged,
          style: const TextStyle(fontFamily: "Poppins"),
          decoration: InputDecoration(
            hintText: _searchType == SearchType.trends
                ? "Untarian let's search for your daily new trends!"
                : _searchType == SearchType.users
                ? "Cari pengguna berdasarkan username..."
                : "Ketik kata kunci atau #hashtag untuk mencari...",
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
      body: Stack(
        children: [
          Container(
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
                    backgroundColor: Colors.white.withValues(alpha: 0.5),
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
                      SearchType.trends:
                          Padding(padding: EdgeInsets.all(8), child: Text('Trends')),
                      SearchType.users:
                          Padding(padding: EdgeInsets.all(8), child: Text('Users')),
                      SearchType.posts:
                          Padding(padding: EdgeInsets.all(8), child: Text('Posts')),
                    },
                  ),
                ),
                if (_searchType == SearchType.trends)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        const Text(
                          'Region:',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButton<String>(
                              value: _selectedRegion,
                              items: _regions
                                  .map((r) => DropdownMenuItem<String>(
                                        value: r,
                                        child: Text(r,
                                            style: const TextStyle(
                                                fontFamily: 'Poppins')),
                                      ))
                                  .toList(),
                              onChanged: (val) {
                                if (val == null) return;
                                setState(() {
                                  _selectedRegion = val;
                                });
                                _searchNews(_controller.text);
                              },
                              isExpanded: true,
                              underline: const SizedBox.shrink(),
                            ),
                          ),
                        ),
                      ],
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
          // Search suggestions dropdown
          if (_showSuggestions)
            Positioned(
              top: 0,
              left: 16,
              right: 16,
              child: Container(
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _filteredSuggestions.length,
                  separatorBuilder: (context, index) => const Divider(
                    height: 1,
                    color: Colors.grey,
                    indent: 16,
                    endIndent: 16,
                  ),
                  itemBuilder: (context, index) {
                    final suggestion = _filteredSuggestions[index];
                    return ListTile(
                      dense: true,
                      leading: const Icon(
                        Icons.search,
                        color: Colors.grey,
                        size: 20,
                      ),
                      title: Text(
                        suggestion,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                        ),
                      ),
                      onTap: () => _selectSuggestion(suggestion),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_searchType == SearchType.trends) {
      return NewsFeedGrid(articles: _newsResults);
    } else if (_searchType == SearchType.users) {
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
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userData = users[index].data() as Map<String, dynamic>;
              final userId = users[index].id;
              final profileImageUrl = userData['profileImageUrl'];
              final username = userData['username'] ?? 'No Username';

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
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
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (userData['namaLengkap'] != null &&
                          userData['namaLengkap'].toString().isNotEmpty)
                        Text(
                          userData['namaLengkap'],
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                      if (userData['nim'] != null &&
                          userData['nim'].toString().isNotEmpty)
                        Text(
                          'NIM: ${userData['nim']}',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            color: Colors.black54,
                          ),
                        ),
                    ],
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
    } else {
      // Posts search
      if (_controller.text.isEmpty) {
        return const Center(
          child: Text(
            "Ketik kata kunci atau #hashtag untuk mencari...",
            style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
            textAlign: TextAlign.center,
          ),
        );
      }

      if (_postResults.isEmpty) {
        return const Center(
          child: Text(
            "Tidak ada post ditemukan",
            style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
          ),
        );
      }

      return GridView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: _postResults.length,
        itemBuilder: (context, index) {
          final postData = _postResults[index].data() as Map<String, dynamic>;
          final postId = _postResults[index].id;

          return GestureDetector(
            onTap: () {
              // Navigate to post detail - you can implement UserPostDetailPage later
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Post detail: $postId')),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white.withValues(alpha: 0.9),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(8)),
                      child: Image.network(
                        postData['imageUrl'],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(color: Colors.grey[200]);
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image,
                                color: Colors.grey),
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '@${postData['username']}',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          postData['description'] ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                          ),
                        ),
                        if (postData['hashtags'] != null &&
                            (postData['hashtags'] as List).isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Wrap(
                              spacing: 4,
                              children: (postData['hashtags'] as List)
                                  .take(3) // Show max 3 hashtags
                                  .map((hashtag) => Text(
                                        hashtag,
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 9,
                                          color: primaryColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }
}
