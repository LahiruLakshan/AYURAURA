import 'package:flutter/material.dart';
import '../../models/image_model/image_model.dart';
import '../../widgets/image_grid_item/image_grid_item.dart';

class ImageGridListPage extends StatefulWidget {
  final List<ImageModelData> dataList;
  final String asset;
  const ImageGridListPage({Key? key, required this.dataList, required this.asset})
      : super(key: key);

  @override
  State<ImageGridListPage> createState() => _ImageGridListPageState();
}

class _ImageGridListPageState extends State<ImageGridListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          widget.asset.toUpperCase(),
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: widget.dataList.isEmpty
            ? Center(
                child: Text(
                  "No images available",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
              )
            : GridView.builder(
                padding: EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: widget.dataList.length,
                itemBuilder: (context, index) {
                  final item = widget.dataList[index];
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
                        path: item.path,
                        asset: widget.asset,
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
