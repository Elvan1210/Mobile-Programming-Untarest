import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:untarest_app/models/search_news.dart';
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            "UNTAREST",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: Color.fromARGB(255, 118, 0, 0),
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              debugPrint("Search Pressed");
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
                      const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
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
                const SizedBox(height: 10),
                const _TrendingVibesSection(),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: const [
                      _PhotoCard(
                        imageUrl: 'assets/images/img1_dummy.png',
                        title: 'PREZIDEN UNTAR',
                        description: 'Joget di sidang senat naik..',
                      ),
                      _PhotoCard(
                        imageUrl: 'assets/images/img2_dummy.png',
                        title: 'UNTAREST',
                        description: 'Guru dan dosen..',
                      ),
                      _PhotoCard(
                        imageUrl: 'assets/images/img3_dummy.png',
                        title: 'HIMTI UNTAR',
                        description: 'HIMTI UNTAR..',
                      ),
                      _PhotoCard(
                        imageUrl: 'assets/images/img4_dummy.png',
                        title: 'UNTAR CUP',
                        description: 'Futsal..',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/images/logo_TrendBottomNav.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
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
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }
}

class _PhotoCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String description;

  const _PhotoCard({
    required this.imageUrl,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(imageUrl, fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: "Poppins",
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              description,
              style: const TextStyle(
                fontFamily: "Poppins",
                fontSize: 12,
                color: Colors.grey,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
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
            children: [
              const Text(
                "Trending Vibes ✨",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(width: 10),
              DropdownButton<String>(
                value: selectedRegion,
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
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 120,
            child: FutureBuilder<List<NewsArticle>>(
              future: SearchService().searchNews("", region: selectedRegion),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text("Gagal memuat trend."));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Tidak ada trend saat ini."));
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

class _TrendingCard extends StatelessWidget {
  final NewsArticle article;

  const _TrendingCard({required this.article});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
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
                            headers: {
                              'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.broken_image, size: 50, color: Colors.grey);
                            },
                          )
                        : Image.asset(article.urlToImage, fit: BoxFit.cover))
                    : Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, size: 40),
                      ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              article.content,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                fontFamily: "Poppins",
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