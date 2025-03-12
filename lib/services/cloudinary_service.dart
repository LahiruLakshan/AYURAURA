import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

class CloudinaryService {
  final String cloudName = 'YOUR_CLOUD_NAME';
  final String apiKey = 'YOUR_API_KEY';
  final String apiSecret = 'YOUR_API_SECRET';

  /// Fetches a list of audio files from Cloudinary under the specified prefix
  Future<List<String>> getAudioTracks(String type) async {
    final String resourceType = 'video';  // Cloudinary treats audio as "video"
    final String prefix = 'Music Tracks/$type';

    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final String signature = _generateSignature('prefix=$prefix&resource_type=$resourceType&timestamp=$timestamp');

    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/resources/$resourceType'
          '?prefix=$prefix&api_key=$apiKey&timestamp=$timestamp&signature=$signature',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['resources'] as List)
          .map((resource) => resource['secure_url'].toString())
          .where((url) => url.endsWith('.mp3') || url.endsWith('.wav') || url.endsWith('.aac')) // Filter audio formats
          .toList();
    } else {
      throw Exception('Failed to load audio tracks: ${response.body}');
    }
  }

  /// Generates Cloudinary API signature
  String _generateSignature(String data) {
    final key = utf8.encode(apiSecret);
    final bytes = utf8.encode(data);
    final hmacSha1 = Hmac(sha1, key);
    final digest = hmacSha1.convert(bytes);
    return digest.toString();
  }
}
