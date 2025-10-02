import 'package:flutter/material.dart';

class ProfileTabs extends StatelessWidget {
  final int selectedTab;
  final Function(int) onTabSelected;

  const ProfileTabs({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _TabButton(
            // Placeholder for Photos icon - replace with your PNG
            icon: Icons.photo_library,
            isSelected: selectedTab == 0,
            onTap: () => onTabSelected(0),
            label: 'Photos',
          ),
          _TabButton(
            // Placeholder for Liked icon - replace with your PNG
            icon: Icons.favorite,
            isSelected: selectedTab == 1,
            onTap: () => onTabSelected(1),
            label: 'Liked',
          ),
          _TabButton(
            // Placeholder for Saved icon - replace with your PNG
            icon: Icons.bookmark,
            isSelected: selectedTab == 2,
            onTap: () => onTabSelected(2),
            label: 'Saved',
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final String label;

  static const Color untarRed = Color.fromARGB(255, 118, 0, 0);

  const _TabButton({
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? untarRed : Colors.white.withOpacity(0.5),
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isSelected ? 0.3 : 0.1),
              blurRadius: isSelected ? 10 : 5,
              offset: Offset(0, isSelected ? 4 : 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: isSelected ? untarRed : Colors.white,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? untarRed : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Alternative version using Image.asset for PNG icons
// To use this, uncomment and replace the _TabButton class above
/*
class _TabButton extends StatelessWidget {
  final String imagePath;  // Path to your PNG icon
  final bool isSelected;
  final VoidCallback onTap;
  final String label;

  static const Color untarRed = Color.fromARGB(255, 118, 0, 0);

  const _TabButton({
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: isSelected 
              ? Colors.white 
              : Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? untarRed : Colors.white.withOpacity(0.5),
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isSelected ? 0.3 : 0.1),
              blurRadius: isSelected ? 10 : 5,
              offset: Offset(0, isSelected ? 4 : 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 40,
              height: 40,
              color: isSelected ? untarRed : Colors.white,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? untarRed : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/
