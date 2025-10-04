import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UntarestSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool readOnly;

  const UntarestSearchBar({
    super.key,
    required this.controller,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          readOnly: readOnly,
          style: const TextStyle(fontFamily: "Poppins"),
          decoration: InputDecoration(
            hintText: "Untarian, let's search for your daily new vibes!",
            hintStyle: const TextStyle(fontFamily: "Poppins", fontSize: 8.7),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(10.0),
              child: SvgPicture.asset(
                'assets/images/logo_Search.svg',
                width: 24,
                height: 15,
                colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
              ),
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
