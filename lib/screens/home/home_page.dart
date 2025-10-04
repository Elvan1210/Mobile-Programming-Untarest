import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:untarest_app/models/search_news.dart';
import 'package:untarest_app/screens/auth/postdetailpage.dart';
import 'package:untarest_app/screens/home/search_features.dart';
import 'package:untarest_app/services/search_service.dart';
import 'package:untarest_app/services/firestore_service.dart';
import 'package:untarest_app/utils/constants.dart';
import 'package:untarest_app/screens/profile/profile.dart';
import 'package:untarest_app/utils/search_bar.dart';

// --- TAMBAHKAN IMPORT INI ---
import 'package:untarest_app/screens/home/create_post_page.dart';

// Helper function to check if a URL is a network URL
bool isNetworkImage(String url) {
  return url.startsWith('http://') || url.startsWith('https://');
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // --- PERUBAHAN DI SINI ---
  // Ganti placeholder dengan halaman CreatePostPage yang baru
  late final List<Widget> _widgetOptions = <Widget>[
    const _HomeContent(),
    const SearchFeatures(),
    const CreatePostPage(), // <-- HALAMAN PLACEHOLDER SUDAH DIGANTI
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _goToSearch() {
    setState(() {
      _selectedIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              spreadRadius: 0,
              blurRadius: 10,
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.white,
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: [
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/images/logo_TrendBottomNav.svg',
                width: 24,
                height: 24,
                colorFilter:
                    const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
              ),
              activeIcon: SvgPicture.asset(
                'assets/images/logo_TrendBottomNav.svg',
                width: 28,
                height: 28,
                colorFilter:
                    const ColorFilter.mode(primaryColor, BlendMode.srcIn),
              ),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
                icon: Icon(Icons.search), label: 'Search'),
            const BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              label: 'Create',
            ),
            const BottomNavigationBarItem(
                icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

// (Sisa kode di bawah ini tidak ada perubahan)
class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  final TextEditingController _searchController = TextEditingController();
  String selectedCountry = "Global";
  List<NewsArticle> allNews = [];
  bool _isLoading = true;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _loadAllNews();
  }

  void _onCountryChanged(String country) {
    setState(() {
      selectedCountry = country;
    });
    _loadAllNews();
  }

  Future<void> _loadAllNews() async {
    setState(() => _isLoading = true);
    try {
      final data =
          await SearchService().searchNews("", region: selectedCountry);
      if (mounted) {
        setState(() {
          allNews = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          allNews = [];
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleSaveArticle(NewsArticle article) async {
    try {
      final isSaved = await _firestoreService.isSaved(article.url);
      await _firestoreService.toggleSave(
        article.url,
        article.urlToImage,
        article.content,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isSaved ? 'Dihapus dari simpanan' : '🔖 Disimpan!',
              style: const TextStyle(fontFamily: 'Poppins'),
            ),
            duration: const Duration(milliseconds: 1500),
            backgroundColor: primaryColor,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/BG_UNTAR.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 0, top: 30, bottom: 0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Image.asset(
                        "assets/images/logo_UNTAREST.png",
                        height: 50,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  UntarestSearchBar(
                    controller: _searchController,
                    readOnly: true,
                    onTap: () {
                      final parentState =
                          context.findAncestorStateOfType<_HomePageState>();
                      parentState?._goToSearch();
                    },
                  ),
                  _TrendingVibesSection(
                    selectedCountry: selectedCountry,
                    onCountryChanged: _onCountryChanged,
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(25)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 400,
                        child: Center(
                          child: CircularProgressIndicator(color: primaryColor),
                        ),
                      )
                    : allNews.isEmpty
                        ? const SizedBox(
                            height: 400,
                            child: Center(
                              child: Text(
                                "Tidak ada konten saat ini.",
                                style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          )
                        : MasonryGridView.count(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: allNews.length,
                            itemBuilder: (context, index) {
                              final article = allNews[index];
                              return buildArticleCard(article);
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildArticleCard(NewsArticle article) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PostDetailPage(article: article),
          ),
        );
      },
      child: StreamBuilder<bool>(
        stream: _firestoreService.isSavedStream(article.url),
        builder: (context, snapshot) {
          final isSaved = snapshot.data ?? false;

          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: article.urlToImage.isNotEmpty
                    ? (isNetworkImage(article.urlToImage)
                        ? Image.network(
                            article.urlToImage,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    color: primaryColor,
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                            headers: const {
                              'User-Agent':
                                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return buildErrorImagePlaceholder(article);
                            },
                          )
                        : Image.asset(
                            article.urlToImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return buildErrorImagePlaceholder(article);
                            },
                          ))
                    : buildNoImagePlaceholder(article),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => _toggleSaveArticle(article),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: isSaved ? primaryColor : Colors.grey[700],
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildNoImagePlaceholder(NewsArticle article) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withValues(alpha: 0.3),
            primaryColor.withValues(alpha: 0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.image_outlined, size: 40, color: Colors.white),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                article.content,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildErrorImagePlaceholder(NewsArticle article) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey[300]!, Colors.grey[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.broken_image_outlined, size: 50, color: Colors.grey),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              article.content,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: Colors.black54,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendingVibesSection extends StatefulWidget {
  final String selectedCountry;
  final Function(String) onCountryChanged;

  const _TrendingVibesSection({
    required this.selectedCountry,
    required this.onCountryChanged,
  });
  
  @override
  State<_TrendingVibesSection> createState() => _TrendingVibesSectionState();
}

class _TrendingVibesSectionState extends State<_TrendingVibesSection> {
  List<String> _regions = ['Global'];
  
  @override
  void initState() {
    super.initState();
    _loadRegions();
  }
  
  Future<void> _loadRegions() async {
    try {
      final regions = await SearchService().getAvailableRegions();
      if (mounted) {
        setState(() {
          _regions = regions;
        });
      }
    } catch (_) {
      // Keep default regions on error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color.fromARGB(255, 245, 218, 218).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/trendup.png', width: 30, height: 30),
                const SizedBox(width: 8),
                SizedBox(
                  height: 28,
                  child: Image.asset(
                    'assets/images/LOGO_TRENDINGVIBES.png',
                    fit: BoxFit.contain,
                    color: const Color.fromARGB(255, 168, 34, 24),
                  ),
                ),
              ],
            ),
            const Spacer(),
            IconButton(
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.black87),
              onPressed: () {
                _showCountryPicker(context, _regions, (country) {
                  widget.onCountryChanged(country);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

void _showCountryPicker(
    BuildContext context, List<String> countries, Function(String) onSelected) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      String filter = '';
      return StatefulBuilder(
        builder: (context, setState) {
          final filtered = countries
              .where((c) => c.toLowerCase().contains(filter.toLowerCase()))
              .toList();
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search country...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (val) => setState(() => filter = val),
                ),
                SizedBox(
                  height: 180,
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemExtent: 60,
                    itemBuilder: (context, idx) {
                      return ListTile(
                        title: Text(filtered[idx]),
                        onTap: () {
                          Navigator.pop(context);
                          onSelected(filtered[idx]);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
