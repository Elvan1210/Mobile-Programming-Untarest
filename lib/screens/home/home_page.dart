import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:untarest_app/models/search_news.dart';
import 'package:untarest_app/screens/auth/postdetailpage.dart';
import 'package:untarest_app/screens/home/search_features.dart';
import 'package:untarest_app/services/search_service.dart';
import 'package:untarest_app/services/firestore_service.dart';
import 'package:untarest_app/utils/constants.dart';
import 'package:untarest_app/screens/profile/profile.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  late final List<Widget> _widgetOptions = <Widget>[
    _HomeContent(),
    const SearchFeatures(),
    const Center(
        child: Text('Halaman Create/Upload Placeholder',
            style: TextStyle(color: Colors.white))),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
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

class _HomeContent extends StatefulWidget {
  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  String selectedCountry = "Indonesia";
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
      final data = await SearchService().searchNews("", region: selectedCountry);
      setState(() {
        allNews = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        allNews = [];
        _isLoading = false;
      });
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
                  _TrendingVibesSection(
                    selectedCountry: selectedCountry,
                    onCountryChanged: _onCountryChanged,
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
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
                                                              value: loadingProgress.expectedTotalBytes != null
                                                                  ? loadingProgress.cumulativeBytesLoaded /
                                                                      loadingProgress.expectedTotalBytes!
                                                                  : null,
                                                              color: primaryColor,
                                                              strokeWidth: 2,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      headers: {
                                                        'User-Agent':
                                                            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
                                                      },
                                                      errorBuilder: (context, error, stackTrace) {
                                                        return Container(
                                                          height: 200,
                                                          decoration: BoxDecoration(
                                                            gradient: LinearGradient(
                                                              colors: [
                                                                Colors.grey[300]!,
                                                                Colors.grey[400]!,
                                                              ],
                                                              begin: Alignment.topLeft,
                                                              end: Alignment.bottomRight,
                                                            ),
                                                            borderRadius: BorderRadius.circular(15),
                                                          ),
                                                          child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              const Icon(
                                                                Icons.broken_image_outlined,
                                                                size: 50,
                                                                color: Colors.grey,
                                                              ),
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
                                                      },
                                                    )
                                                  : Image.asset(
                                                      article.urlToImage,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) {
                                                        return Container(
                                                          height: 200,
                                                          color: Colors.grey[300],
                                                          child: const Icon(
                                                            Icons.broken_image,
                                                            size: 50,
                                                            color: Colors.grey,
                                                          ),
                                                        );
                                                      },
                                                    ))
                                              : Container(
                                                  height: 200,
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        primaryColor.withOpacity(0.3),
                                                        primaryColor.withOpacity(0.5),
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
                                                        const Icon(
                                                          Icons.image_outlined,
                                                          size: 40,
                                                          color: Colors.white,
                                                        ),
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
                                                ),
                                        ),
                                        // Save/Bookmark Button
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: GestureDetector(
                                            onTap: () => _toggleSaveArticle(article),
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.9),
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.2),
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
                            },
                          ),
              ),
            ),
          ],
        ),
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
  final List<String> countries = [
    'Indonesia',
    'USA',
    'Japan',
    'South Korea',
    'China',
    'France',
    'UK',
    'Global',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color.fromARGB(255, 245, 218, 218).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // --- Kiri: Logo + TrendingVibes ---
            Row(
              children: [
                Image.asset(
                  'assets/images/trendup.png',
                  width: 30,
                  height: 30,
                ),
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

            // --- Kanan: Region filter ---
            Row(
              children: [
                Text(
                  widget.selectedCountry,
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(221, 168, 0, 0),
                      fontSize: 15),
                ),
                IconButton(
                  icon:
                      const Icon(Icons.arrow_drop_down, color: Colors.black87),
                  onPressed: () {
                    _showCountryPicker(context, countries, (country) {
                      widget.onCountryChanged(country);
                    });
                  },
                ),
              ],
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