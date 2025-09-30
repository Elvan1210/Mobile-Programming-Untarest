import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:untarest_app/models/search_news.dart';
import 'package:untarest_app/screens/home/search_features.dart';
import 'package:untarest_app/screens/auth/postdetailpage.dart';
import 'package:untarest_app/services/search_service.dart';
import 'package:untarest_app/utils/constants.dart';
import 'package:untarest_app/screens/profile/profile.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

<<<<<<< HEAD
class HomePage extends StatelessWidget {
  const HomePage({super.key});
=======
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  late final List<Widget> _widgetOptions = <Widget>[
    _HomeContent(),
    const Center(
        child: Text('Halaman Explore/Search Placeholder',
            style: TextStyle(color: Colors.white))),
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
>>>>>>> 941ece4cccdb7b7e158cd0e3ec8a3ffc8cc677ed

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
          child: const TextField(
            decoration: InputDecoration(
              hintText: 'Search for ideas',
              prefixIcon: Icon(Icons.search),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
            ),
          ),
        ),
=======
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
>>>>>>> 941ece4cccdb7b7e158cd0e3ec8a3ffc8cc677ed
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
<<<<<<< HEAD
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Create',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: 0,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
=======
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
>>>>>>> 941ece4cccdb7b7e158cd0e3ec8a3ffc8cc677ed
      ),
    );
  }
}

class _HomeContent extends StatefulWidget {
  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  List<NewsArticle> allNews = [];
  Set<String> savedArticles = {}; // Store in memory for now
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllNews();
  }

  void _toggleSaveArticle(NewsArticle article) {
    setState(() {
      final articleId = article.urlToImage;
      if (savedArticles.contains(articleId)) {
        savedArticles.remove(articleId);
      } else {
        savedArticles.add(articleId);
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          savedArticles.contains(article.urlToImage) 
            ? '✓ Foto disimpan!' 
            : 'Foto dihapus dari simpanan',
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

  Future<void> _loadAllNews() async {
    setState(() => _isLoading = true);
    try {
      final data = await SearchService().searchNews("");
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

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(imageUrl, fit: BoxFit.cover),
=======
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.95),
        elevation: 1,
        centerTitle: false,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            "UNTAREST",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchFeatures()),
              );
            },
            icon: SizedBox(
              width: 40,
              height: 40,
              child: Center(
                child: SvgPicture.asset(
                  'assets/images/logo_Search.svg',
                  width: 24,
                  height: 24,
                  colorFilter:
                      const ColorFilter.mode(primaryColor, BlendMode.srcIn),
                ),
              ),
>>>>>>> 941ece4cccdb7b7e158cd0e3ec8a3ffc8cc677ed
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/BG_UNTAR.png"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Color.fromARGB(50, 118, 0, 0),
              BlendMode.multiply,
            ),
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: const [
                  SizedBox(height: 10),
                  _TrendingVibesSection(),
                  SizedBox(height: 20),
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
                              final isSaved = savedArticles.contains(article.urlToImage);
                              
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PostDetailPage(article: article),
                                    ),
                                  );
                                },
                                child: Stack(
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
  const _TrendingVibesSection({super.key});

  @override
  State<_TrendingVibesSection> createState() => _TrendingVibesSectionState();
}

class _TrendingVibesSectionState extends State<_TrendingVibesSection> {
  String selectedRegion = "all";
  final List<String> regions = ["all", "Indonesia", "World"];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Trending Vibes ✨",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  shadows: [Shadow(color: Colors.black54, blurRadius: 1.0)],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedRegion,
                    icon: const Icon(Icons.arrow_drop_down, color: primaryColor),
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        color: primaryColor,
                        fontWeight: FontWeight.bold),
                    items: regions
                        .map((r) => DropdownMenuItem(
                              value: r,
                              child: Text(r),
                            ))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedRegion = val ?? "all";
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 140,
            child: FutureBuilder<List<NewsArticle>>(
              future: SearchService().searchNews("", region: selectedRegion),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: Colors.white));
                } else if (snapshot.hasError) {
                  return const Center(
                      child: Text("Gagal memuat trend.",
                          style: TextStyle(color: Colors.white)));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text("Tidak ada trend saat ini.",
                          style: TextStyle(color: Colors.white)));
                } else {
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final article = snapshot.data![index];
                      return _TrendingCard(article: article);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
<<<<<<< HEAD
=======

class _TrendingCard extends StatelessWidget {
  final NewsArticle article;

  const _TrendingCard({required this.article});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PostDetailPage(article: article),
          ),
        );
      },
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: article.urlToImage.isNotEmpty
                      ? (isNetworkImage(article.urlToImage)
                          ? Image.network(
                              article.urlToImage,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              headers: {
                                'User-Agent':
                                    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.broken_image,
                                      size: 50, color: Colors.grey),
                                );
                              },
                            )
                          : Image.asset(article.urlToImage,
                              fit: BoxFit.cover, width: double.infinity))
                      : Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, size: 40),
                        ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  article.content,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    fontFamily: "Poppins",
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
>>>>>>> 941ece4cccdb7b7e158cd0e3ec8a3ffc8cc677ed
