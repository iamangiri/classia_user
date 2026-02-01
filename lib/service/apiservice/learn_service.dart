import 'dart:convert';
import 'package:classia_amc/utills/constent/app_constant.dart';
import 'package:http/http.dart' as http;
import '../../models/course_models.dart';
import '../../utills/constent/user_constant.dart';
import '../WithoutLogin/auth_login_check_service.dart';

class LearnService {
  static Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${UserConstants.TOKEN}',
    };
  }

  static Future<CourseListResponse> getCourseList({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstant.API_URL}/course/list?page=$page&limit=$limit'),
        headers: _getHeaders(),
      );

      print('getCourseList statusCode: ${response.statusCode}');
      print('getCourseList body: ${response.body}');

      await checkValidUserWithRouter(response.statusCode);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return CourseListResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load courses: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching courses: $e');
    }
  }

  static Future<CourseDetailResponse> getCourseDetails(int courseId) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstant.API_URL}/course/$courseId'),
        headers: _getHeaders(),
      );

      print('getCourseDetails statusCode: ${response.statusCode}');
      print('getCourseDetails body: ${response.body}');

      await checkValidUserWithRouter(response.statusCode);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return CourseDetailResponse.fromJson(jsonData);
      } else {
        throw Exception(
            'Failed to load course details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching course details: $e');
    }
  }

  static Future<EnrollmentResponse> enrollInCourse(int courseId) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstant.API_URL}/course/$courseId/enroll'),
        headers: _getHeaders(),
      );

      print('enrollInCourse statusCode: ${response.statusCode}');
      print('enrollInCourse body: ${response.body}');

      await checkValidUserWithRouter(response.statusCode);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return EnrollmentResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to enroll in course: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error enrolling in course: $e');
    }
  }

  /// Get user's enrolled courses
  static Future<UserEnrollmentsResponse> getUserEnrollments() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstant.API_URL}/user/enrollments'),
        headers: _getHeaders(),
      );

      print('getUserEnrollments statusCode: ${response.statusCode}');
      print('getUserEnrollments body: ${response.body}');

      await checkValidUserWithRouter(response.statusCode);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return UserEnrollmentsResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load enrollments: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching enrollments: $e');
    }
  }

  /// Get course content
  static Future<CourseContentResponse> getCourseContent(
    int courseId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${AppConstant.API_URL}/course/$courseId/content?page=$page&limit=$limit'),
        headers: _getHeaders(),
      );

      print('getCourseContent statusCode: ${response.statusCode}');
      print('getCourseContent body: ${response.body}');

      await checkValidUserWithRouter(response.statusCode);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return CourseContentResponse.fromJson(jsonData);
      } else {
        throw Exception(
            'Failed to load course content: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching course content: $e');
    }
  }

  /// Get course progress
  static Future<CourseProgressResponse> getCourseProgress(int courseId) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstant.API_URL}/course/$courseId/progress'),
        headers: _getHeaders(),
      );

      print('getCourseProgress statusCode: ${response.statusCode}');
      print('getCourseProgress body: ${response.body}');

      await checkValidUserWithRouter(response.statusCode);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return CourseProgressResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load progress: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching progress: $e');
    }
  }

  /// Mark content as complete
  static Future<ApiResponse> markContentComplete(
    int courseId,
    int contentId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(
            '${AppConstant.API_URL}/course/$courseId/content/$contentId/complete'),
        headers: _getHeaders(),
      );

      print('markContentComplete statusCode: ${response.statusCode}');
      print('markContentComplete body: ${response.body}');

      await checkValidUserWithRouter(response.statusCode);

      final jsonData = jsonDecode(response.body);
      return ApiResponse.fromJson(jsonData);
    } catch (e) {
      throw Exception('Error marking content complete: $e');
    }
  }

  /// Submit MCQ answer
  static Future<ApiResponse> submitMCQAnswer(
    int courseId,
    int contentId,
    Map<String, dynamic> answerData,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(
            '${AppConstant.API_URL}/course/$courseId/content/$contentId/mcq/submit'),
        headers: _getHeaders(),
        body: jsonEncode(answerData),
      );

      print('submitMCQAnswer statusCode: ${response.statusCode}');
      print('submitMCQAnswer body: ${response.body}');

      await checkValidUserWithRouter(response.statusCode);

      final jsonData = jsonDecode(response.body);
      return ApiResponse.fromJson(jsonData);
    } catch (e) {
      throw Exception('Error submitting MCQ answer: $e');
    }
  }

  /// Request certificate
  static Future<ApiResponse> requestCertificate(int courseId) async {
    try {
      final response = await http.post(
        Uri.parse(
            '${AppConstant.API_URL}/course/$courseId/certificate/request'),
        headers: _getHeaders(),
      );

      print('requestCertificate statusCode: ${response.statusCode}');
      print('requestCertificate body: ${response.body}');

      await checkValidUserWithRouter(response.statusCode);

      final jsonData = jsonDecode(response.body);
      return ApiResponse.fromJson(jsonData);
    } catch (e) {
      throw Exception('Error requesting certificate: $e');
    }
  }

  /// Get user's certificates
  static Future<UserCertificatesResponse> getUserCertificates() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstant.API_URL}/user/certificates'),
        headers: _getHeaders(),
      );

      print('getUserCertificates statusCode: ${response.statusCode}');
      print('getUserCertificates body: ${response.body}');

      await checkValidUserWithRouter(response.statusCode);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return UserCertificatesResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load certificates: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching certificates: $e');
    }
  }
}
