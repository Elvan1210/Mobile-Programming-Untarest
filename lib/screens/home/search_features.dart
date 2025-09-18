import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:untarest_app/utils/constants.dart';

class SearchFeatures extends StatefulWidget {
  const SearchFeatures({super.key});

  @override
  State<SearchFeatures> createState() => _SearchFeaturesState();
}

class _SearchFeaturesState extends State<SearchFeatures> {
  final TextEditingController _controller = TextEditingController();

  List<String> allData = [
    "Ahmad Sahroni kabur ke Singapura",
    "DPR Naik Gaji Uhuy",
    "Solo Leveling Live Adaptation",
    "UNTAR CUP 2025",
  ];

  List<String> results = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, //hilangin tombol back
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: _controller,
            onChanged: (value) {
              setState(() {
                results = allData
                    .where((e) => e.toLowerCase().contains(value.toLowerCase()))
                    .toList();
              });
            },
            style: const TextStyle(fontFamily: "Poppins"), // font di input
            decoration: InputDecoration(
              hintText: "Untarian let's search for your daily new vibes!",
              hintStyle: const TextStyle(fontFamily: "Poppins"),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
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
        child: results.isEmpty
            ? const Center(
                child: Text(
                  "Yakin bukan kabar hoax? Tidak ada loh.",
                  style: TextStyle(fontFamily: "Poppins", fontSize: 16),
                ),
              )
            : ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.article, color: Colors.black),
                    title: Text(
                      results[index],
                      style: const TextStyle(
                        fontFamily: "Poppins",
                        color: Colors.black,
                      ),
                    ),
                  );
                },
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 1, // posisi di Search
        onTap: (i) {},
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
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
