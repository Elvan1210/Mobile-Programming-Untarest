import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:untarest_app/models/search_news.dart';
import 'package:untarest_app/screens/auth/postdetailpage.dart';
import 'package:untarest_app/screens/home/search_features.dart';
import 'package:untarest_app/services/search_service.dart';
import 'package:untarest_app/utils/constants.dart';
import 'package:untarest_app/screens/profile/profile.dart';
import 'package:untarest_app/utils/search_bar.dart';
import 'package:untarest_app/widgets/news_feed_grid.dart';

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

class _HomeContent extends StatefulWidget {
  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  final TextEditingController _searchController = TextEditingController();
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

                //LOGO UNTAREST
                Padding(
                  padding: const EdgeInsets.only(left: 0, top: 30, bottom: 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Image.asset(
                      "assets/images/logo_UNTAREST.png",
                      height: 35,
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

                const SizedBox(height: 0), // jangan kasih jarak

                _TrendingVibesSection(
                  selectedCountry: selectedCountry,
                  onCountryChanged: _onCountryChanged,
                ),

                //FEEDS
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 0), // vertical=0
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

                      return NewsFeedGrid(articles: trendingPosts);
                    },
                  ),
                ),
              ],
            ))));
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

class _TrendingVibesSection extends StatelessWidget {
  final String selectedCountry;
  final Function(String) onCountryChanged;

  const _TrendingVibesSection({
    super.key,
    required this.selectedCountry,
    required this.onCountryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color.fromARGB(255, 245, 218, 218).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // --- Kiri: Logo + TrendingVibes ---
            Row(
              mainAxisSize: MainAxisSize.min,
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

            const Spacer(),

            // --- Kanan: Dropdown icon aja ---
            IconButton(
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.black87),
              onPressed: () {
                _showCountryPicker(context, [
                  'Indonesia',
                  'USA',
                  'Japan',
                  'South Korea',
                  'China',
                  'France',
                  'UK',
                  'Global',
                ], (country) {
                  onCountryChanged(country);
                });
              },
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
      const Text("TRENDING VIBES!",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red)),
      ...trending.map((article) => ListTile(
            leading: article.urlToImage.isNotEmpty
                ? Image.asset(article.urlToImage,
                    width: 40, height: 40, fit: BoxFit.cover)
                : const Icon(Icons.trending_up),
            title: Text(article.content),
            subtitle: Text(article.content),
          )),
    ],
  );
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
