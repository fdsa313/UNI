import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/video.dart';
import 'api_service.dart';

class VideoService {
  // 백엔드는 '/api' 프리픽스를 사용하므로 그대로 사용한다
  static final String _baseUrl = ApiService.baseUrl; // 예: http://127.0.0.1:3000/api

  Future<Map<String, String>> _buildAuthHeaders() async {
    final token = await ApiService.getToken();
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // GET /videos - 모든 영상 목록 조회
  Future<List<Video>> getAllVideos() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/videos'),
            headers: await _buildAuthHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Video.fromJson(json)).toList();
      } else {
        throw Exception('영상 목록을 가져오는데 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 영상 목록 조회 오류: $e');
      rethrow;
    }
  }

  // GET /videos/:id - 특정 영상 조회
  Future<Video> getVideoById(String id) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/videos/$id'),
            headers: await _buildAuthHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return Video.fromJson(jsonData);
      } else {
        throw Exception('영상을 가져오는데 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 영상 조회 오류: $e');
      rethrow;
    }
  }

  // POST /videos - 새 영상 업로드
  Future<Video> uploadVideo({
    required String title,
    required String description,
    required String category,
    required File videoFile,
  }) async {
    try {
      // multipart 요청 생성
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/videos'),
      );

      // 헤더 설정
      final token = await ApiService.getToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // 텍스트 필드 추가
      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['category'] = category;

      // 영상 파일 추가
      final videoStream = http.ByteStream(videoFile.openRead());
      final videoLength = await videoFile.length();
      final multipartFile = http.MultipartFile(
        'videoFile',
        videoStream,
        videoLength,
        filename: videoFile.path.split('/').last,
      );
      request.files.add(multipartFile);

      // 요청 전송
      final streamedResponse = await request.send().timeout(const Duration(seconds: 20));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        return Video.fromJson(jsonData);
      } else {
        throw Exception('영상 업로드에 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 영상 업로드 오류: $e');
      rethrow;
    }
  }

  // PUT /videos/:id - 영상 정보 수정
  Future<Video> updateVideo({
    required String id,
    String? title,
    String? description,
    String? category,
  }) async {
    try {
      final Map<String, dynamic> updateData = {};
      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (category != null) updateData['category'] = category;

      final response = await http
          .put(
            Uri.parse('$_baseUrl/videos/$id'),
            headers: await _buildAuthHeaders(),
            body: json.encode(updateData),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return Video.fromJson(jsonData);
      } else {
        throw Exception('영상 수정에 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 영상 수정 오류: $e');
      rethrow;
    }
  }

  // DELETE /videos/:id - 영상 삭제
  Future<bool> deleteVideo(String id) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$_baseUrl/videos/$id'),
            headers: await _buildAuthHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('영상 삭제에 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 영상 삭제 오류: $e');
      rethrow;
    }
  }

  // 앱 종료용 영상 가져오기 (카테고리별)
  Future<Video?> getExitVideo() async {
    try {
      final videos = await getAllVideos();
      // 'exit' 또는 'app_exit' 카테고리의 영상을 찾기
      if (videos.isEmpty) return null;
      final filtered = videos.where((video) {
        final cat = video.category.toLowerCase();
        return cat.contains('exit') || cat.contains('app');
      }).toList();
      return (filtered.isNotEmpty) ? filtered.first : videos.first;
    } catch (e) {
      print('❌ 앱 종료 영상 조회 오류: $e');
      return null;
    }
  }
}
