import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class ImageStorageService {
  Future<String> saveImage(String originalPath) async {
    final directory = await getApplicationDocumentsDirectory();

    final imageDirectory = Directory(
      path.join(
        directory.path,
        'clothing_images',
      ),
    );

    if (!await imageDirectory.exists()) {
      await imageDirectory.create(
        recursive: true,
      );
    }

    final extension = path.extension(originalPath);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}$extension';
    final permanentPath = path.join(
      imageDirectory.path,
      fileName,
    );

    final originalFile = File(originalPath);
    final savedFile = await originalFile.copy(permanentPath);

    return savedFile.path;
  }

  Future<void> deleteImage(String imagePath) async {
    final file = File(imagePath);

    if (await file.exists()) {
      await file.delete();
    }
  }
}