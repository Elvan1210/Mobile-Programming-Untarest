import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:untarest_app/screens/home/home_page.dart';
import 'package:untarest_app/utils/constants.dart';
import 'package:untarest_app/services/search_service.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:untarest_app/screens/auth/postdetailpage.dart';
import 'package:untarest_app/models/search_news.dart';

class SearchFeatures extends StatefulWidget {
  const SearchFeatures({super.key});

  @override
  State<SearchFeatures> createState() => _SearchFeaturesState();
}

class _SearchFeaturesState extends State<SearchFeatures> {
  final TextEditingController _controller = TextEditingController();
  final SearchService _service = SearchService();

  List<NewsArticle> results = [];
  List<String> suggestions = [];
  bool _isLoading = false;

  void _searchNews(String query) async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.searchNews(query);
      setState(() => results = data);
      // Update suggestions based on query
      setState(() {
        suggestions = data
            .map((a) => a.content)
            .where((title) => title.toLowerCase().contains(query.toLowerCase()))
            .toSet()
            .toList();
      });
    } catch (e) {
      setState(() {
        results = [];
        suggestions = [];
      });
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
    final topSuggestions = suggestions.take(4).toList();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: null, // No back button
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: _controller,
            onChanged: (q) {
              _searchNews(q);
            },
            onSubmitted: _searchNews,
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
        child: Column(
          children: [
            // Suggestions dropdown
            if (topSuggestions.isNotEmpty && _controller.text.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: topSuggestions.length,
                  itemBuilder: (context, idx) {
                    final suggestion = topSuggestions[idx];
                    return ListTile(
                      title: Text(
                        suggestion,
                        style: const TextStyle(fontFamily: "Poppins"),
                      ),
                      onTap: () {
                        _controller.text = suggestion;
                        _searchNews(suggestion);
                        FocusScope.of(context).unfocus();
                      },
                    );
                  },
                ),
              ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : results.isEmpty
                      ? const Center(
                          child: Text(
                            "Yakin bukan kabar hoax? Tidak ada loh",
                            style:
                                TextStyle(fontFamily: "Poppins", fontSize: 16),
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        PostDetailPage(article: article),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: article.urlToImage.isNotEmpty
                                    ? (isNetworkImage(article.urlToImage)
                                        ? Image.network(
                                            article.urlToImage,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.asset(
                                            article.urlToImage,
                                            fit: BoxFit.cover,
                                          ))
                                    : Container(
                                        color: Colors.grey[300],
                                        child:
                                            const Icon(Icons.image, size: 40),
                                      ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 1,
        onTap: (i) {
          if (i == 0) {
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/home', (route) => false);
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
