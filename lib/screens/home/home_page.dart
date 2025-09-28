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

  late final List<Widget> _widgetOptions = <Widget>[
    _HomeContent(),
    const Center(child: Text('Halaman Explore/Search Placeholder', style: TextStyle(color: Colors.white))),
    const Center(child: Text('Halaman Create/Upload Placeholder', style: TextStyle(color: Colors.white))),
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
                colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
              ),
              activeIcon: SvgPicture.asset(
                'assets/images/logo_TrendBottomNav.svg',
                width: 28,
                height: 28,
                colorFilter: const ColorFilter.mode(primaryColor, BlendMode.srcIn),
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

class _HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10),
              const _TrendingVibesSection(),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(25)),
                ),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.7,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.asset(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: primaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Trending Vibes ✨",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  shadows: [
                    Shadow(color: Colors.black54, blurRadius: 1.0)
                  ],
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
                    icon:
                        const Icon(Icons.arrow_drop_down, color: primaryColor),
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

class _TrendingCard extends StatelessWidget {
  final NewsArticle article;

  const _TrendingCard({required this.article});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  const BorderRadius.vertical(top: Radius.circular(15)),
              child: article.urlToImage.isNotEmpty
                  ? (isNetworkImage(article.urlToImage)
                      ? Image.network(article.urlToImage,
                          fit: BoxFit.cover, width: double.infinity)
                      : Image.asset(article.urlToImage,
                          fit: BoxFit.cover, width: double.infinity))
                  : Container(
                      color: Colors.grey[300],
                      child: const Center(
                          child:
                              Icon(Icons.image, size: 40, color: Colors.grey)),
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
    );
  }
}