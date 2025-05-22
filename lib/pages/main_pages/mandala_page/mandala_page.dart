import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stress_management/constants/colors.dart';
import '../../../providers/main_provider.dart';
import '../../../widgets/image_menu_item/image_menu_item.dart';
import '../../image_list_page/image_grid_list_page.dart';

class MandalaPage extends StatefulWidget {
  const MandalaPage({Key? key}) : super(key: key);

  @override
  State<MandalaPage> createState() => _MandalaPageState();
}

class _MandalaPageState extends State<MandalaPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Animation<double>> _animations = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Staggered animations
    for (int i = 0; i < 3; i++) {
      _animations.add(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            i * 0.2,
            0.6 + (i * 0.2),
            curve: Curves.easeOutBack,
          ),
        ),
      );
    }
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Green-themed difficulty colors
  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'simple':
        return const Color(0xFF81C784); // Light green
      case 'medium':
        return const Color(0xFF4CAF50); // Medium green
      case 'complex':
        return const Color(0xFF2E7D32); // Primary green
      default:
        return const Color(0xFF4CAF50);
    }
  }

  String _getDifficultyDescription(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'simple':
        return 'Perfect for beginners with basic patterns';
      case 'medium':
        return 'Balanced designs for focused sessions';
      case 'complex':
        return 'Intricate patterns for deep mindfulness';
      default:
        return '';
    }
  }

  IconData _getDifficultyIcon(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'simple':
        return Icons.auto_awesome;
      case 'medium':
        return Icons.auto_awesome_mosaic;
      case 'complex':
        return Icons.auto_fix_high;
      default:
        return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'title': 'Simple', 'asset': 'simple'},
      {'title': 'Medium', 'asset': 'medium'},
      {'title': 'Complex', 'asset': 'complex'},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Mandala Coloring',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.info_outline),
                        color: AppColors.primary,
                        onPressed: () {
                          _showInfoDialog(context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select a difficulty level to begin your mindfulness journey',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // Categories List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final color = _getDifficultyColor(category['title']!);
                  final mainProvider = context.read<MainProvider>();
                  final imageList = category['title'] == 'Simple'
                      ? mainProvider.simpleList
                      : category['title'] == 'Medium'
                      ? mainProvider.mediumList
                      : mainProvider.complexList;

                  return AnimatedBuilder(
                    animation: _animations[index],
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, 50 * (1 - _animations[index].value)),
                        child: Opacity(
                          opacity: _animations[index].value.clamp(0.0, 1.0),
                          child: child,
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      child: _DifficultyCard(
                        title: category['title']!,
                        description: _getDifficultyDescription(category['title']!),
                        icon: _getDifficultyIcon(category['title']!),
                        color: color,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ImageGridListPage(
                                dataList: imageList,
                                asset: category['asset']!,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
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

class _DifficultyCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DifficultyCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.9),
                color.withOpacity(0.7),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: 16,
                top: 16,
                child: Icon(
                  icon,
                  size: 60,
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            icon,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
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