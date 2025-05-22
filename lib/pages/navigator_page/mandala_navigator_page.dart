import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stress_management/pages/main_pages/mandala_page/mandala_page.dart';
import 'package:stress_management/pages/main_pages/saved_image_list/saved_image_page.dart';
import 'package:stress_management/providers/main_provider.dart';
import 'package:stress_management/widgets/my_app_bar/my_app_bar.dart';

class MandalaNavigator extends StatefulWidget {
  const MandalaNavigator({Key? key}) : super(key: key);

  @override
  State<MandalaNavigator> createState() => _MandalaNavigatorState();
}

class _MandalaNavigatorState extends State<MandalaNavigator> {
  int _currentIndex = 0;
  late PageController _pageController;

  final List<String> _titles = ["Mandala Coloring", "Your Creations"];
  final List<IconData> _icons = [Icons.palette, Icons.collections];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      context.read<MainProvider>().loadData();
      context.read<MainProvider>().getImageList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: MyAppBar(
      //   title: _titles[_currentIndex],
      //   actions: [
      //     IconButton(
      //       icon: Icon(Icons.info_outline),
      //       onPressed: () {
      //         _showInfoDialog(context);
      //       },
      //     ),
      //   ],
      // ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        children: const <Widget>[
          MandalaPage(),
          SavedImagePage(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            _titles.length,
                (index) => _NavBarItem(
              icon: _icons[index],
              label: _titles[index],
              isActive: _currentIndex == index,
              onTap: () {
                setState(() => _currentIndex = index);
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Mandala Coloring'),
        content: const Text(
          'Coloring mandalas can help reduce stress and improve focus. '
              'Your creations are automatically saved for future reference.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.green.shade50 : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isActive
              ? Border.all(color: Colors.green.shade100, width: 1)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.green : Colors.grey.shade600,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? Colors.green : Colors.grey.shade600,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}