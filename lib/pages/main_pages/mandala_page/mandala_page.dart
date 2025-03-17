import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    
    // Create staggered animations for each card
    for (int i = 0; i < 3; i++) {
      _animations.add(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            i * 0.2,
            0.6 + (i * 0.2),
            curve: Curves.easeOut,
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

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'simple':
        return Colors.teal;
      case 'medium':
        return Colors.purple;
      case 'complex':
        return Colors.deepOrange;
      default:
        return Colors.blue;
    }
  }

  String _getDifficultyDescription(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'simple':
        return 'Perfect for beginners. Basic patterns to help you relax.';
      case 'medium':
        return 'Intermediate designs for focused meditation.';
      case 'complex':
        return 'Intricate patterns for deep concentration and mindfulness.';
      default:
        return '';
    }
  }

  IconData _getDifficultyIcon(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'simple':
        return Icons.brightness_low;
      case 'medium':
        return Icons.brightness_medium;
      case 'complex':
        return Icons.brightness_high;
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

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.1),
            Colors.white,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                        opacity: _animations[index].value,
                        child: child,
                      ),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: InkWell(
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
                      child: Container(
                        height: 160,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              color,
                              color.withOpacity(0.8),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.3),
                              blurRadius: 12,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              right: -20,
                              top: -20,
                              child: Icon(
                                _getDifficultyIcon(category['title']!),
                                size: 120,
                                color: Colors.white.withOpacity(0.2),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        _getDifficultyIcon(category['title']!),
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        category['title']!,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    _getDifficultyDescription(category['title']!),
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
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
