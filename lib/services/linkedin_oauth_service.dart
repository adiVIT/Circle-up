import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';
import '../widgets/linkedin_auth_webview.dart';

class LinkedInOAuthService {
  // LinkedIn OAuth Configuration
  static const String clientId = '86bopv1tq3q75r';
  static const String clientSecret = 'WPL_AP1.ztWYfa01uyF1GBNl.k1DNWw==';

  // Your actual LinkedIn access token
  static const String actualAccessToken =
      'AQX1zYccGMpyRMOx61ASBi8M245o5dsJxSveKk_kjYFKDmI0kFTjCep9b-mkX6VGGakbzS73vLnHALt3fUAOs4nLi1_AbDMpyYxMxgST2U0JNe2WOeAQT14Rym6diFlMR19JsTkeHwXghARTj_tl57wFt4WPfFfFg-HktjhPnpku0AmNvZWOgXpB5VyyCrgpDx0hTNApd1bdlB1Qx_50elvojzXCgqZQ2X2xGN9e47wljGJzyqKIvhp2t6lKgix8uYVRhuvj6-_v93boqrk1ZmvRt-k7U_qdgS7j_JTHdvUXn_NF9uZGa195a0BB2wniHgHd-jMuBpRqDjO-Lb2wsDfUGtbYwA';

  // LinkedIn OpenID Connect API URLs (official endpoints)
  static const String userinfoUrl = 'https://api.linkedin.com/v2/userinfo';
  static const String profileUrl = 'https://api.linkedin.com/v2/people/~';
  static const String emailUrl =
      'https://api.linkedin.com/v2/emailAddress?q=members&projection=(elements*(handle~))';

  // Redirect URIs - these MUST match what's configured in LinkedIn Developer Console
  // Using LinkedIn's default redirect for better compatibility
  static const String _mobileRedirectUri =
      'https://www.linkedin.com/developers/tools/oauth/redirect';
  static const String _webRedirectUri =
      'http://localhost:3000/auth/linkedin/callback';
  static const String _alternativeWebRedirectUri =
      'http://localhost:8080/auth/linkedin/callback';

  static String get redirectUri {
    if (kIsWeb) {
      return _webRedirectUri;
    }
    return _mobileRedirectUri;
  }

  static List<String> get allRedirectUris {
    return [
      _webRedirectUri,
      _alternativeWebRedirectUri,
      _mobileRedirectUri,
    ];
  }

  // OpenID Connect scopes
  static const String scope = 'openid profile email';

  // LinkedIn OAuth URLs (for reference)
  static const String authorizationUrl =
      'https://www.linkedin.com/oauth/v2/authorization';
  static const String tokenUrl =
      'https://www.linkedin.com/oauth/v2/accessToken';

  /// Main sign-in method - Full LinkedIn OAuth 2.0 flow
  static Future<Map<String, dynamic>?> signInWithLinkedIn(
      BuildContext context) async {
    try {
      print('=== Starting LinkedIn OAuth 2.0 Flow ===');

      // Step 1: Build authorization URL
      final authUrl = _buildAuthorizationUrl();
      print('Authorization URL: $authUrl');

      // Step 2: Launch LinkedIn authorization page
      final authCode = await _launchLinkedInAuth(context, authUrl);
      if (authCode == null) {
        print('❌ User cancelled LinkedIn authorization');
        return null;
      }

      print('✅ Received authorization code: ${authCode.substring(0, 10)}...');

      // Step 3: Exchange authorization code for access token
      final accessToken = await _exchangeCodeForToken(authCode);
      if (accessToken == null) {
        print('❌ Failed to exchange code for access token');
        if (context.mounted) {
          _showErrorDialog(
              context, 'Failed to complete LinkedIn authentication');
        }
        return null;
      }

      print('✅ Received access token: ${accessToken.substring(0, 20)}...');

      // Step 4: Get user profile with the access token
      final profileData = await _getUserProfileWithStandardClient(accessToken);
      if (profileData != null) {
        print('✅ Successfully retrieved user profile');
        return _convertLinkedInProfile(profileData);
      } else {
        print('❌ Failed to retrieve user profile');
        if (context.mounted) {
          _showErrorDialog(context, 'Failed to retrieve LinkedIn profile');
        }
        return null;
      }
    } catch (e) {
      print('LinkedIn OAuth error: $e');
      if (context.mounted) {
        _showErrorDialog(
            context, 'LinkedIn authentication error: ${e.toString()}');
      }
      return null;
    }
  }

  /// Launch LinkedIn authorization page and capture the authorization code
  static Future<String?> _launchLinkedInAuth(
      BuildContext context, String authUrl) async {
    try {
      print('Launching LinkedIn authorization...');

      if (kIsWeb) {
        // For web, use URL launcher
        return await _launchLinkedInAuthWeb(context, authUrl);
      } else {
        // For mobile, use WebView
        return await _launchLinkedInAuthMobile(context, authUrl);
      }
    } catch (e) {
      print('Error launching LinkedIn auth: $e');
      return null;
    }
  }

  /// Launch LinkedIn auth for web platforms
  static Future<String?> _launchLinkedInAuthWeb(
      BuildContext context, String authUrl) async {
    try {
      final uri = Uri.parse(authUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);

        // Show dialog to capture the authorization code
        return await _showAuthCodeDialog(context);
      } else {
        print('Cannot launch LinkedIn URL');
        return null;
      }
    } catch (e) {
      print('Error launching LinkedIn auth for web: $e');
      return null;
    }
  }

  /// Launch LinkedIn auth for mobile platforms using WebView
  static Future<String?> _launchLinkedInAuthMobile(
      BuildContext context, String authUrl) async {
    try {
      return await Navigator.of(context).push<String>(
        MaterialPageRoute(
          builder: (context) => LinkedInAuthWebView(authUrl: authUrl),
        ),
      );
    } catch (e) {
      print('Error launching LinkedIn auth for mobile: $e');
      return null;
    }
  }

  /// Show dialog to capture authorization code (for web)
  static Future<String?> _showAuthCodeDialog(BuildContext context) async {
    String? authCode;

    return await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('LinkedIn Authorization'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'After authorizing the app, you will be redirected to a page. '
              'Please copy the authorization code from the URL and paste it here:',
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Paste authorization code here',
                border: OutlineInputBorder(),
                labelText: 'Authorization Code',
              ),
              onChanged: (value) {
                authCode = value.trim();
              },
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (authCode != null && authCode!.isNotEmpty) {
                Navigator.of(context).pop(authCode);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Please enter the authorization code')),
                );
              }
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  /// Exchange authorization code for access token
  static Future<String?> _exchangeCodeForToken(String authCode) async {
    try {
      print('Exchanging authorization code for access token...');

      final response = await http.post(
        Uri.parse(tokenUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: {
          'grant_type': 'authorization_code',
          'code': authCode,
          'client_id': clientId,
          'client_secret': clientSecret,
          'redirect_uri': redirectUri,
        },
      ).timeout(const Duration(seconds: 30));

      print('Token exchange response status: ${response.statusCode}');
      print('Token exchange response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['access_token'];
      } else {
        print(
            '❌ Token exchange failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error exchanging code for token: $e');
      return null;
    }
  }

  /// TEMP METHOD: Use hardcoded token for testing (remove this in production)
  static Future<Map<String, dynamic>?> signInWithLinkedInDirect(
      BuildContext context) async {
    try {
      print('=== LinkedIn Direct Authentication (Testing Only) ===');
      print(
          'Using hardcoded access token: ${actualAccessToken.substring(0, 20)}...');

      // Try multiple approaches for better compatibility
      Map<String, dynamic>? profileData;

      // Approach 1: Use standard http.Client (works best in Flutter)
      try {
        print('Trying standard HTTP client...');
        profileData =
            await _getUserProfileWithStandardClient(actualAccessToken);
        if (profileData != null) {
          print('✅ Standard HTTP client worked!');
          return _convertLinkedInProfile(profileData);
        }
      } catch (e) {
        print('Standard HTTP client failed: $e');
      }

      // Approach 2: Use custom HTTP client with SSL configuration
      if (profileData == null && !kIsWeb) {
        try {
          print('Trying custom HTTP client with SSL config...');
          final client = _createCustomHttpClient();
          try {
            profileData =
                await _getUserProfileWithToken(actualAccessToken, client);
            if (profileData != null) {
              print('✅ Custom HTTP client worked!');
              return _convertLinkedInProfile(profileData);
            }
          } finally {
            client.close();
          }
        } catch (e) {
          print('Custom HTTP client failed: $e');
        }
      }

      // If all approaches failed
      if (profileData == null) {
        print('❌ All HTTP client approaches failed');
        if (context.mounted) {
          _showErrorDialog(context,
              'LinkedIn authentication failed. Please check your internet connection and try again.');
        }
        return null;
      }

      return null;
    } catch (e) {
      print('LinkedIn OAuth error: $e');
      if (context.mounted) {
        _showErrorDialog(
            context, 'LinkedIn authentication error: ${e.toString()}');
      }
      return null;
    }
  }

  /// Use standard http.Client (works best in Flutter mobile)
  static Future<Map<String, dynamic>?> _getUserProfileWithStandardClient(
      String accessToken) async {
    try {
      print('Making request to LinkedIn userinfo endpoint...');

      // Use standard http.get - this works better in Flutter mobile
      final response = await http.get(
        Uri.parse(userinfoUrl),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'User-Agent': 'CircleUp-Flutter/1.0',
          'Connection':
              'close', // Force connection close to avoid keep-alive issues
        },
      ).timeout(const Duration(seconds: 30));

      print('Response status: ${response.statusCode}');
      print('Response headers: ${response.headers}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ LinkedIn userinfo data received: $data');
        return data;
      } else if (response.statusCode == 401) {
        print('❌ Access token expired or invalid: ${response.statusCode}');
        return null;
      } else {
        print(
            '❌ LinkedIn userinfo failed: ${response.statusCode} - ${response.body}');

        // Try legacy API with standard client
        return await _tryLegacyLinkedInAPIWithStandardClient(accessToken);
      }
    } catch (e) {
      print('Error with standard HTTP client: $e');
      return null;
    }
  }

  /// Try legacy LinkedIn API with standard http client
  static Future<Map<String, dynamic>?> _tryLegacyLinkedInAPIWithStandardClient(
      String accessToken) async {
    try {
      print('Trying legacy LinkedIn API with standard client...');

      final profileResponse = await http.get(
        Uri.parse(profileUrl),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'User-Agent': 'CircleUp-Flutter/1.0',
          'Connection': 'close',
        },
      ).timeout(const Duration(seconds: 30));

      if (profileResponse.statusCode == 200) {
        final profileData = jsonDecode(profileResponse.body);
        print('Legacy profile data: $profileData');

        // Try to get email separately
        String? email;
        try {
          final emailResponse = await http.get(
            Uri.parse(emailUrl),
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Accept': 'application/json',
              'User-Agent': 'CircleUp-Flutter/1.0',
              'Connection': 'close',
            },
          ).timeout(const Duration(seconds: 30));

          if (emailResponse.statusCode == 200) {
            final emailData = jsonDecode(emailResponse.body);
            if (emailData['elements'] != null &&
                emailData['elements'].isNotEmpty) {
              final handle = emailData['elements'][0]['handle~'];
              if (handle != null && handle['emailAddress'] != null) {
                email = handle['emailAddress'];
              }
            }
          }
        } catch (e) {
          print('Error getting email: $e');
        }

        // Convert legacy format to OpenID Connect format
        return _convertLegacyProfileToOpenIDConnect(profileData, email);
      } else {
        print(
            'Legacy profile API failed: ${profileResponse.statusCode} - ${profileResponse.body}');
      }

      return null;
    } catch (e) {
      print('Error trying legacy LinkedIn API with standard client: $e');
      return null;
    }
  }

  /// Create custom HTTP client with SSL configuration (fallback for non-web)
  static http.Client _createCustomHttpClient() {
    if (kIsWeb) {
      return http.Client(); // Use default client for web
    }

    final httpClient = HttpClient();

    // More permissive SSL configuration for mobile
    httpClient.badCertificateCallback = (cert, host, port) {
      // Allow LinkedIn and common SSL certificate authorities
      return host.contains('linkedin.com') ||
          host.contains('api.linkedin.com') ||
          host.contains('www.linkedin.com');
    };

    // Set reasonable timeouts
    httpClient.connectionTimeout = const Duration(seconds: 30);
    httpClient.idleTimeout = const Duration(seconds: 15);

    // Disable HTTP/2 which can cause issues on some mobile networks
    httpClient.autoUncompress = true;

    return IOClient(httpClient);
  }

  /// Get user profile using custom HTTP client (fallback)
  static Future<Map<String, dynamic>?> _getUserProfileWithToken(
      String accessToken, http.Client client) async {
    try {
      print('Fetching user profile via custom client...');

      final response = await client.get(
        Uri.parse(userinfoUrl),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'User-Agent': 'CircleUp-Flutter/1.0',
          'Connection': 'close',
        },
      ).timeout(const Duration(seconds: 30));

      print('Custom client response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Custom client userinfo data received: $data');
        return data;
      } else if (response.statusCode == 401) {
        print('Access token expired or invalid: ${response.statusCode}');
        return null;
      } else {
        print(
            'Custom client userinfo failed: ${response.statusCode} - ${response.body}');
        return await _tryLegacyLinkedInAPI(accessToken, client);
      }
    } catch (e) {
      print('Error calling userinfo endpoint with custom client: $e');
      return await _tryLegacyLinkedInAPI(accessToken, client);
    }
  }

  /// Fallback to legacy LinkedIn v2 API if OpenID Connect fails
  static Future<Map<String, dynamic>?> _tryLegacyLinkedInAPI(
      String accessToken, http.Client client) async {
    try {
      print('Trying legacy LinkedIn v2 API endpoints with custom client...');

      final profileResponse = await client.get(
        Uri.parse(profileUrl),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'User-Agent': 'CircleUp-Flutter/1.0',
          'Connection': 'close',
        },
      ).timeout(const Duration(seconds: 30));

      if (profileResponse.statusCode == 200) {
        final profileData = jsonDecode(profileResponse.body);
        print('Legacy profile data: $profileData');

        // Try to get email separately
        String? email;
        try {
          final emailResponse = await client.get(
            Uri.parse(emailUrl),
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Accept': 'application/json',
              'User-Agent': 'CircleUp-Flutter/1.0',
              'Connection': 'close',
            },
          ).timeout(const Duration(seconds: 30));

          if (emailResponse.statusCode == 200) {
            final emailData = jsonDecode(emailResponse.body);
            if (emailData['elements'] != null &&
                emailData['elements'].isNotEmpty) {
              final handle = emailData['elements'][0]['handle~'];
              if (handle != null && handle['emailAddress'] != null) {
                email = handle['emailAddress'];
              }
            }
          }
        } catch (e) {
          print('Error getting email: $e');
        }

        return _convertLegacyProfileToOpenIDConnect(profileData, email);
      } else {
        print(
            'Legacy profile API failed: ${profileResponse.statusCode} - ${profileResponse.body}');
      }

      return null;
    } catch (e) {
      print('Error trying legacy LinkedIn API: $e');
      return null;
    }
  }

  /// Convert legacy LinkedIn profile to OpenID Connect userinfo format
  static Map<String, dynamic> _convertLegacyProfileToOpenIDConnect(
      Map<String, dynamic> profile, String? email) {
    final firstName = profile['localizedFirstName'] ?? '';
    final lastName = profile['localizedLastName'] ?? '';

    return {
      'sub': profile['id'] ?? 'unknown',
      'given_name': firstName,
      'family_name': lastName,
      'name': '$firstName $lastName'.trim(),
      'email': email ?? 'noemail@linkedin.com',
      'email_verified': email != null,
      'picture': profile['profilePicture']?['displayImage~']?['elements']
          ?.last?['identifiers']
          ?.first?['identifier'],
      'locale': 'en-US',
    };
  }

  /// Convert LinkedIn OpenID Connect profile to our app format
  static Map<String, dynamic> _convertLinkedInProfile(
      Map<String, dynamic> linkedInProfile) {
    final firstName = linkedInProfile['given_name'] ?? '';
    final lastName = linkedInProfile['family_name'] ?? '';
    final fullName = linkedInProfile['name'] ?? '$firstName $lastName'.trim();

    // Handle locale - it can be a Map or String
    String localeString = 'Unknown';
    final locale = linkedInProfile['locale'];
    if (locale is Map<String, dynamic>) {
      final country = locale['country'] ?? '';
      final language = locale['language'] ?? '';
      localeString = '$language-$country'.toUpperCase();
    } else if (locale is String) {
      localeString = locale;
    }

    return {
      'id': linkedInProfile['sub'] ?? 'unknown',
      'firstName': firstName,
      'lastName': lastName,
      'name': fullName,
      'email': linkedInProfile['email'] ?? 'noemail@linkedin.com',
      'profilePicture': linkedInProfile['picture'],
      'companies': [
        {
          'name': 'LinkedIn Connected Company',
          'title': 'Professional',
          'startDate': DateTime.now().toIso8601String().split('T')[0],
          'endDate': null,
          'current': true,
          'location': localeString
        }
      ],
      'colleges': [
        {
          'name': 'LinkedIn University',
          'degree': 'Professional Degree',
          'field': 'Professional Development',
          'startDate': '2020-01-01',
          'endDate': '2024-01-01'
        }
      ],
      'skills': ['Professional Networking', 'LinkedIn', 'Career Development'],
      'location': localeString,
      'industry': 'Professional Services',
      'summary':
          'Connected through LinkedIn using OpenID Connect authentication.'
    };
  }

  /// Show error dialog to user
  static void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('LinkedIn Authentication Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Test the current access token with multiple approaches
  static Future<Map<String, dynamic>?> testCurrentAccessToken() async {
    print('=== Testing LinkedIn Access Token (Multiple Approaches) ===');

    // Try standard client first
    try {
      final result = await _getUserProfileWithStandardClient(actualAccessToken);
      if (result != null) {
        print('✅ Standard client test successful');
        return result;
      }
    } catch (e) {
      print('Standard client test failed: $e');
    }

    // Try custom client if not web
    if (!kIsWeb) {
      final client = _createCustomHttpClient();
      try {
        final result =
            await _getUserProfileWithToken(actualAccessToken, client);
        if (result != null) {
          print('✅ Custom client test successful');
          return result;
        }
      } catch (e) {
        print('Custom client test failed: $e');
      } finally {
        client.close();
      }
    }

    print('❌ All test approaches failed');
    return null;
  }

  /// Helper method to test different redirect URIs (for debugging only)
  static Future<void> testRedirectUris() async {
    print('=== Testing LinkedIn Redirect URIs ===');
    for (final uri in allRedirectUris) {
      final testUrl = _buildAuthorizationUrl(uri);
      print('Testing redirect URI: $uri');
      print('Full URL: $testUrl');
      print('---');
    }
    print('=====================================');
  }

  /// Build LinkedIn authorization URL (for reference only)
  static String _buildAuthorizationUrl([String? customRedirectUri]) {
    final params = {
      'response_type': 'code',
      'client_id': clientId,
      'redirect_uri': customRedirectUri ?? redirectUri,
      'scope': scope,
      'state': DateTime.now().millisecondsSinceEpoch.toString(),
    };

    final query = params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return '$authorizationUrl?$query';
  }
}
