import 'dart:convert';
import 'dart:typed_data';

import 'package:aner_astaner/core/config/imgbb_config.dart';
import 'package:http/http.dart' as http;

import '../../domain/repositories/profile_image_uploader.dart';

class ProfileImageService implements ProfileImageUploader {
  @override
  Future<String?> upload(Uint8List bytes) async {
    final response = await http.post(
      Uri.parse('https://api.imgbb.com/1/upload?key=${ImgbbConfig.apiKey}'),
      body: {'image': base64Encode(bytes), 'name': 'flutter_uploaded_image'},
    );

    if (response.statusCode != 200) return null;

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data['data'] as Map<String, dynamic>)['url'] as String?;
  }
}
