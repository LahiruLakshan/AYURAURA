import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/main_provider.dart';
import '../../../widgets/image_grid_item/image_grid_item.dart';

class SavedImagePage extends StatefulWidget {
  const SavedImagePage({Key? key}) : super(key: key);

  @override
  State<SavedImagePage> createState() => _SavedImagePageState();
}

class _SavedImagePageState extends State<SavedImagePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<MainProvider>(
        builder: (context, snapshot, child) {
          if (snapshot.savedImageList.isEmpty) {
            return Center(
              child: Text(
                "You have not colored yet!",
                style: TextStyle(
                  fontFamily: 'McLaren',
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
            );
          }

          return Container(
            color: Colors.white,
            child: GridView.builder(
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: snapshot.savedImageList.length,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: ImageGridItem(
                      file: snapshot.savedImageList[index].pathToFile(),
                      index: index,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),

      // Center(
      //   child: Image.file(context.read<MainProvider>().savedImageList[0]),
      // ),
    );
  }
}
