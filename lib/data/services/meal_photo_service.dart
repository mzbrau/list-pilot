import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../repositories/meal_repository.dart';

class MealPhotoService {
  MealPhotoService(this._repo);

  final MealRepository _repo;
  final _picker = ImagePicker();

  Future<File?> resolvePhotoFile(String? relativePath) async {
    if (relativePath == null || relativePath.isEmpty) return null;
    final docs = await getApplicationDocumentsDirectory();
    final file = File(p.join(docs.path, relativePath));
    if (!await file.exists()) return null;
    return file;
  }

  Future<File?> pickAndSavePhoto(int mealId) async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (picked == null) return null;

    final meal = await _repo.getMealById(mealId);
    if (meal == null) return null;

    if (meal.photoPath != null) {
      await _deletePhotoFile(meal.photoPath!);
    }

    final relativePath = await _copyToAppStorage(mealId, picked.path);
    await _repo.updateMeal(id: mealId, photoPath: relativePath);
    return resolvePhotoFile(relativePath);
  }

  Future<void> removePhoto(int mealId) async {
    final meal = await _repo.getMealById(mealId);
    if (meal?.photoPath != null) {
      await _deletePhotoFile(meal!.photoPath!);
    }
    await _repo.updateMeal(id: mealId, clearPhoto: true);
  }

  Future<File?> downloadAndSavePhoto(int mealId, String imageUrl) async {
    final meal = await _repo.getMealById(mealId);
    if (meal == null) return null;

    final response = await http
        .get(Uri.parse(imageUrl))
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) return null;

    if (meal.photoPath != null) {
      await _deletePhotoFile(meal.photoPath!);
    }

    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'meal_photos'));
    await dir.create(recursive: true);
    final destPath = p.join(dir.path, '$mealId.jpg');
    await File(destPath).writeAsBytes(response.bodyBytes);

    final relativePath = p.join('meal_photos', '$mealId.jpg');
    await _repo.updateMeal(id: mealId, photoPath: relativePath);
    return File(destPath);
  }

  Future<String> _copyToAppStorage(int mealId, String sourcePath) async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'meal_photos'));
    await dir.create(recursive: true);
    final destPath = p.join(dir.path, '$mealId.jpg');
    await File(sourcePath).copy(destPath);
    return p.join('meal_photos', '$mealId.jpg');
  }

  Future<void> _deletePhotoFile(String relativePath) async {
    final file = await resolvePhotoFile(relativePath);
    if (file != null && await file.exists()) {
      await file.delete();
    }
  }
}
