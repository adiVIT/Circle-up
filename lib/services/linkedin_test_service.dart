import 'dart:convert';
import 'package:http/http.dart' as http;

class LinkedInTestService {
  // Test with the actual access token you received
  static const String testAccessToken =
      'AQX1zYccGMpyRMOx61ASBi8M245o5dsJxSveKk_kjYFKDmI0kFTjCep9b-mkX6VGGakbzS73vLnHALt3fUAOs4nLi1_AbDMpyYxMxgST2U0JNe2WOeAQT14Rym6diFlMR19JsTkeHwXghARTj_tl57wFt4WPfFfFg-HktjhPnpku0AmNvZWOgXpB5VyyCrgpDx0hTNApd1bdlB1Qx_50elvojzXCgqZQ2X2xGN9e47wljGJzyqKIvhp2t6lKgix8uYVRhuvj6-_v93boqrk1ZmvRt-k7U_qdgS7j_JTHdvUXn_NF9uZGa195a0BB2wniHgHd-jMuBpRqDjO-Lb2wsDfUGtbYwA';

  static const String userinfoUrl = 'https://api.linkedin.com/v2/userinfo';

  // Test the actual LinkedIn API with your access token
  static Future<Map<String, dynamic>?> testUserInfo() async {
    try {
      print('=== Testing LinkedIn Access Token ===');
      print('Token: ${testAccessToken.substring(0, 20)}...');

      final response = await http.get(
        Uri.parse(userinfoUrl),
        headers: {
          'Authorization': 'Bearer $testAccessToken',
          'Accept': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response headers: ${response.headers}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Response data: $data');
        return data;
      } else {
        print('Error response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error testing access token: $e');
      return null;
    }
  }

  // Test LinkedIn profile endpoint (v2 API)
  static Future<Map<String, dynamic>?> testProfileEndpoint() async {
    try {
      print('=== Testing LinkedIn Profile Endpoint ===');

      // Test the basic profile endpoint
      final profileResponse = await http.get(
        Uri.parse('https://api.linkedin.com/v2/people/~'),
        headers: {
          'Authorization': 'Bearer $testAccessToken',
          'Accept': 'application/json',
        },
      );

      print('Profile response status: ${profileResponse.statusCode}');

      if (profileResponse.statusCode == 200) {
        final profileData = jsonDecode(profileResponse.body);
        print('Profile data: $profileData');
        return profileData;
      } else {
        print('Profile error: ${profileResponse.body}');
      }

      // Test the email endpoint
      final emailResponse = await http.get(
        Uri.parse(
            'https://api.linkedin.com/v2/emailAddress?q=members&projection=(elements*(handle~))'),
        headers: {
          'Authorization': 'Bearer $testAccessToken',
          'Accept': 'application/json',
        },
      );

      print('Email response status: ${emailResponse.statusCode}');

      if (emailResponse.statusCode == 200) {
        final emailData = jsonDecode(emailResponse.body);
        print('Email data: $emailData');
      } else {
        print('Email error: ${emailResponse.body}');
      }

      return null;
    } catch (e) {
      print('Error testing profile endpoint: $e');
      return null;
    }
  }

  // Create a test user from the token data
  static Future<Map<String, dynamic>?> createTestUserData() async {
    final userInfo = await testUserInfo();

    if (userInfo != null) {
      // Convert the LinkedIn userinfo to our expected format
      return {
        'id': userInfo['sub'] ??
            'test_user_${DateTime.now().millisecondsSinceEpoch}',
        'firstName': userInfo['given_name'] ?? 'Test',
        'lastName': userInfo['family_name'] ?? 'User',
        'email': userInfo['email'] ?? 'test@linkedin.com',
        'profilePicture': userInfo['picture'],
        'companies': [
          {
            'name': 'LinkedIn Test Company',
            'title': 'Test Position',
            'startDate': DateTime.now().toIso8601String().split('T')[0],
            'endDate': null,
            'current': true,
            'location': userInfo['locale'] ?? 'Unknown'
          }
        ],
        'colleges': [
          {
            'name': 'Test University',
            'degree': 'Test Degree',
            'field': 'Test Field',
            'startDate': '2020-01-01',
            'endDate': '2024-01-01'
          }
        ],
        'skills': ['LinkedIn API', 'OAuth 2.0', 'Testing'],
        'location': userInfo['locale'] ?? 'Test Location',
        'industry': 'Technology',
        'summary': 'Test user created from LinkedIn OAuth token'
      };
    }

    return null;
  }

  // Validate the current OAuth configuration
  static void validateOAuthConfiguration() {
    print('=== LinkedIn OAuth Configuration Validation ===');
    print('Access Token Length: ${testAccessToken.length}');
    print('Token starts with: ${testAccessToken.substring(0, 10)}');
    print('Token is valid format: ${testAccessToken.startsWith('AQ')}');
    print('UserInfo URL: $userinfoUrl');
    print('=============================================');
  }
}
