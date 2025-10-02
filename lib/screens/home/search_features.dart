import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:untarest_app/services/search_service.dart';
import 'package:untarest_app/models/search_news.dart';
import 'package:untarest_app/widgets/news_feed_grid.dart';

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
            onSubmitted: (val) {
              _searchNews(val);
              FocusScope.of(context).unfocus();
            },
            style: const TextStyle(fontFamily: "Poppins"),
            decoration: InputDecoration(
              hintText: "Untarian let's search for your daily new vibes!",
              hintStyle: const TextStyle(fontFamily: "Poppins", fontSize: 8.5),
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
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // nutup keyboard & suggestions
          setState(() {
            suggestions.clear(); // biar dropdown suggestions ilang
          });
        },
        child: Container(
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
              : ListView(
                  padding: const EdgeInsets.all(8),
                  children: [
                    if (topSuggestions.isNotEmpty &&
                        _controller.text.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
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
                          physics: const NeverScrollableScrollPhysics(),
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
                                setState(() =>
                                    suggestions.clear()); // tutup dropdown
                              },
                            );
                          },
                        ),
                      ),
                    // Feeds
                    NewsFeedGrid(articles: results),
                  ],
                ),
        ),
      ),
    );
  }
}
