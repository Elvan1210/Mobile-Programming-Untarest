import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:untarest_app/screens/home/home_page.dart';
import 'package:untarest_app/utils/constants.dart';
import 'package:untarest_app/models/search_news.dart';
import 'package:untarest_app/services/search_service.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class SearchFeatures extends StatefulWidget {
  const SearchFeatures({super.key});

  @override
  State<SearchFeatures> createState() => _SearchFeaturesState();
}

class _SearchFeaturesState extends State<SearchFeatures> {
  final TextEditingController _controller = TextEditingController();
  final SearchService _service = SearchService();

  List<NewsArticle> results = [];
  bool _isLoading = false;

  void _searchNews(String query) async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.searchNews(query);
      setState(() => results = data);
    } catch (e) {
      setState(() => results = []);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _searchNews(""); // Show all news initially
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: _controller,
            onSubmitted: _searchNews,
            onChanged: (q) {
              if (q.isEmpty) _searchNews("");
            },
            style: const TextStyle(fontFamily: "Poppins"),
            decoration: InputDecoration(
              hintText: "Untarian let's search for your daily new vibes!",
              hintStyle: const TextStyle(fontFamily: "Poppins"),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(10.0),
                child: SvgPicture.asset(
                  'assets/images/logo_Search.svg',
                  width: 24,
                  height: 24,
                  color: Colors.grey,
                ),
              ),
            ),
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : results.isEmpty
                ? const Center(
                    child: Text(
                      "Yakin bukan kabar hoax? Tidak ada loh",
                      style: TextStyle(fontFamily: "Poppins", fontSize: 16),
                    ),
                  )
                : MasonryGridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    padding: const EdgeInsets.all(10),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final article = results[index];
                      return GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => Dialog(
                              child: article.urlToImage.isNotEmpty
                                  ? Image.network(article.urlToImage,
                                      fit: BoxFit.contain)
                                  : const Icon(Icons.article, size: 100),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            children: [
                              article.urlToImage.isNotEmpty
                                  ? Image.network(
                                      article.urlToImage,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    )
                                  : Container(
                                      color: Colors.grey[300],
                                      child:
                                          const Icon(Icons.article, size: 40),
                                    ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  color: Colors.black.withOpacity(0.5),
                                  padding: const EdgeInsets.all(4),
                                  child: Text(
                                    article.title,
                                    style: const TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 1,
        onTap: (i) {
          if (i == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/images/logo_TrendBottomNav.svg',
              width: 24,
              height: 24,
            ),
            activeIcon: SvgPicture.asset(
              'assets/images/logo_TrendBottomNav.svg',
              width: 28,
              height: 28,
              color: Color.fromARGB(255, 2, 0, 143),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Create',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }
}
