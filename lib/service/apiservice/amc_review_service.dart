import 'dart:convert';
import 'package:classia_amc/utills/constent/app_constant.dart';
import 'package:classia_amc/utills/constent/user_constant.dart';
import 'package:http/http.dart' as http;

class AmcReviewService {
  Future<Map<String, dynamic>> getReviews(
      int amcId, {
        int page = 1,
        int limit = 10,
      }) async {
    try {
      final url = Uri.parse('${AppConstant.API_URL}/user/review?amcId=$amcId');

      // Using http.Request to send body with GET
      final request = http.Request('GET', url);
      request.headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${UserConstants.TOKEN}',
      });
      request.body = json.encode({
        'page': page,
        'limit': limit,
        'amcId': amcId,
      });

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📡 Review API URL: $url');
      print('Response Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          return data;
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch reviews');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else {
        throw Exception('Failed to fetch reviews: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching reviews: $e');
    }
  }


  Future<Map<String, dynamic>> createReview({
    required int amcId,
    required int rating,
    required String comment,
  }) async {
    try {
      // Validate rating
      if (rating < 1 || rating > 5) {
        throw Exception('Rating must be between 1 and 5');
      }

      // Validate comment
      if (comment.trim().isEmpty) {
        throw Exception('Comment cannot be empty');
      }

      final url = Uri.parse('${AppConstant.API_URL}/user/create/review');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${UserConstants.TOKEN}',
        },
        body: json.encode({
          'amcId': amcId,
          'rating': rating,
          'comment': comment.trim(),
        }),
      );

      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          return data['data'];
        } else {
          throw Exception(data['message'] ?? 'Failed to submit review');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else if (response.statusCode == 400) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Invalid review data');
      } else {
        throw Exception('Failed to submit review: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error submitting review: $e');
    }
  }


  Map<int, int> calculateRatingDistribution(List<dynamic> reviews) {
    Map<int, int> distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

    for (var review in reviews) {
      int rating = review['rating'] as int;
      if (distribution.containsKey(rating)) {
        distribution[rating] = distribution[rating]! + 1;
      }
    }

    return distribution;
  }

  double getRatingPercentage(int rating, List<dynamic> reviews) {
    if (reviews.isEmpty) return 0.0;

    int count = reviews.where((review) => review['rating'] == rating).length;
    return (count / reviews.length) * 100;
  }
}