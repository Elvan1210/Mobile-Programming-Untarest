import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:untarest_app/models/search_news.dart';
import 'package:untarest_app/screens/auth/postdetailpage.dart';
import 'package:untarest_app/screens/home/search_features.dart';
import 'package:untarest_app/services/search_service.dart';
import 'package:untarest_app/utils/constants.dart';
import 'package:untarest_app/screens/profile/profile.dart';

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
  String selectedCountry = "Indonesia"; // default

  void _onCountryChanged(String country) {
    setState(() {
      selectedCountry = country;
    });
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              _TrendingVibesSection(
                selectedCountry: selectedCountry,
                onCountryChanged: _onCountryChanged,
              ),
              const SizedBox(height: 5),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                child: FutureBuilder<List<NewsArticle>>(
                  future:
                      SearchService().searchNews("", region: selectedCountry),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return const Text("Gagal memuat post trending");
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text("Belum ada trending vibes di sini");
                    }

                    final trendingPosts = snapshot.data!
                        .where((a) => a.isTrending == true)
                        .toList();

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: trendingPosts.length,
                      itemBuilder: (context, index) {
                        final post = trendingPosts[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PostDetailPage(article: post),
                              ),
                            );
                          },
                          child: _PhotoCard(imageUrl: post.urlToImage),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoCard extends StatelessWidget {
  final String imageUrl;

  const _PhotoCard({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        child: imageUrl.isNotEmpty
            ? (isNetworkImage(imageUrl)
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.broken_image,
                          size: 50, color: Colors.grey);
                    },
                  )
                : Image.asset(imageUrl, fit: BoxFit.cover))
            : Container(
                color: Colors.grey[300],
                child: const Icon(Icons.image, size: 40),
              ),
      ),
    );
  }
}

class _TrendingVibesSection extends StatefulWidget {
  final String selectedCountry;
  final Function(String) onCountryChanged;

  const _TrendingVibesSection({
    super.key,
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

class _TrendingCard extends StatelessWidget {
  final NewsArticle article;

  const _TrendingCard({required this.article});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      // max 250px biar gak kegedean, min 180px biar tetap kebaca
      width: screenWidth < 400 ? screenWidth * 0.8 : 250,
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
          // Bagian gambar
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: article.urlToImage.isNotEmpty
                ? (isNetworkImage(article.urlToImage)
                    ? Image.network(
                        article.urlToImage,
                        height: 100,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        headers: {
                          'User-Agent':
                              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.broken_image,
                              size: 50, color: Colors.grey);
                        },
                      )
                    : Image.asset(
                        article.urlToImage,
                        height: 100,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ))
                : Container(
                    height: 100,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, size: 40),
                  ),
          ),

          // Bagian text
          Padding(
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
        ],
      ),
    );
  }
}

// Trending Vibes Widget
Widget trendingVibes(List<NewsArticle> articles) {
  final trending = articles.where((a) => a.isTrending == true).take(4).toList();
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text("TRENDING VIBES!",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red)),
      ...trending.map((article) => ListTile(
            leading: article.urlToImage.isNotEmpty
                ? Image.asset(article.urlToImage,
                    width: 40, height: 40, fit: BoxFit.cover)
                : Icon(Icons.trending_up),
            title: Text(article.content),
            subtitle: Text(article.content),
          )),
    ],
  );
}

//last edited-eln
void _showCountryPicker(
    BuildContext context, List<String> countries, Function(String) onSelected) {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
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
                  decoration: InputDecoration(
                    hintText: 'Search country...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (val) => setState(() => filter = val),
                ),
                SizedBox(
                  height: 180, // 3 items * 60px each
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
