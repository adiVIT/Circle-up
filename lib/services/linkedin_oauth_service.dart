import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

class LinkedInOAuthService {
  // LinkedIn OAuth Configuration - Update these with your real credentials
  static const String clientId =
      '86bopv1tq3q75r'; // Your real LinkedIn Client ID
  static const String clientSecret =
      'WPL_AP1.ztWYfa01uyF1GBNl.k1DNWw=='; // Your real LinkedIn Client Secret
  // Different redirect URIs for different platforms
  static const String _mobileRedirectUri = 'circleup://auth/linkedin/callback';
  static const String _webRedirectUri =
      'http://localhost:3000/auth/linkedin/callback';

  // Alternative redirect URIs to try if the primary ones don't work
  static const String _alternativeWebRedirectUri =
      'http://localhost:8080/auth/linkedin/callback';

  static String get redirectUri {
    // Check if running on web
    if (kIsWeb) {
      return _webRedirectUri;
    }
    return _mobileRedirectUri;
  }

  // Method to get all possible redirect URIs for debugging
  static List<String> get allRedirectUris {
    return [
      _webRedirectUri,
      _alternativeWebRedirectUri,
      _mobileRedirectUri,
    ];
  }

  // Updated OpenID Connect scopes
  static const String scope = 'openid profile email';

  // LinkedIn OpenID Connect URLs
  static const String authorizationUrl =
      'https://www.linkedin.com/oauth/v2/authorization';
  static const String tokenUrl =
      'https://www.linkedin.com/oauth/v2/accessToken';
  static const String userinfoUrl = 'https://api.linkedin.com/v2/userinfo';

  // Start LinkedIn OAuth flow with platform-specific handling
  static Future<Map<String, dynamic>?> signInWithLinkedIn(
      BuildContext context) async {
    try {
      // Print debugging information
      print('=== LinkedIn OAuth Debug Info ===');
      print('Platform: ${kIsWeb ? 'Web' : 'Mobile'}');
      print('Client ID: $clientId');
      print('Current Redirect URI: $redirectUri');
      print('All possible redirect URIs: ${allRedirectUris.join(', ')}');
      print('================================');

      // Generate authorization URL
      final authUrl = _buildAuthorizationUrl();
      print('Opening LinkedIn OAuth URL: $authUrl');

      String? authCode;

      if (kIsWeb) {
        // For web: redirect to LinkedIn directly
        authCode = await _handleWebOAuth(authUrl);
      } else {
        // For mobile: use WebView
        authCode = await _showLinkedInWebView(context, authUrl);
      }

      if (authCode != null) {
        print('Received authorization code: $authCode');

        // Exchange authorization code for access token and ID token
        final tokenData = await _getAccessToken(authCode);

        if (tokenData != null && tokenData['access_token'] != null) {
          print('Received access token');

          // Get user profile using the userinfo endpoint
          final profileData = await _getUserProfile(tokenData['access_token']);

          if (profileData != null) {
            // Convert to our expected format
            return _convertLinkedInProfile(profileData);
          } else {
            print('Failed to get user profile');
            return null;
          }
        } else {
          print('Failed to get access token');
          return null;
        }
      } else {
        print('No authorization code received');
        return null;
      }

      return null;
    } catch (e) {
      print('LinkedIn OAuth error: $e');
      return null;
    }
  }

  // Handle web OAuth by opening LinkedIn in new tab
  static Future<String?> _handleWebOAuth(String authUrl) async {
    try {
      print('Web OAuth: Opening LinkedIn in new tab...');
      print('OAuth URL: $authUrl');

      // Open LinkedIn OAuth in a new tab/window
      if (await canLaunchUrl(Uri.parse(authUrl))) {
        await launchUrl(
          Uri.parse(authUrl),
          mode: LaunchMode.externalApplication,
        );

        // For web demo purposes, simulate successful authentication
        // In production, you'd implement proper callback handling
        await Future.delayed(const Duration(seconds: 3));

        // Return a demo authorization code for testing
        // Real implementation would get this from the callback URL
        return 'demo_web_auth_code_${DateTime.now().millisecondsSinceEpoch}';
      } else {
        print('Could not launch LinkedIn OAuth URL');
        return null;
      }
    } catch (e) {
      print('Error launching LinkedIn OAuth URL: $e');
      return null;
    }
  }

  // Show LinkedIn OAuth page in WebView (mobile only)
  static Future<String?> _showLinkedInWebView(
      BuildContext context, String authUrl) async {
    return await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => _LinkedInWebViewScreen(authUrl: authUrl),
      ),
    );
  }

  // Build LinkedIn authorization URL with OpenID Connect scopes
  static String _buildAuthorizationUrl([String? customRedirectUri]) {
    final params = {
      'response_type': 'code',
      'client_id': clientId,
      'redirect_uri': customRedirectUri ?? redirectUri,
      'scope': scope, // Using OpenID Connect scopes
      'state': DateTime.now().millisecondsSinceEpoch.toString(),
    };

    final query = params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return '$authorizationUrl?$query';
  }

  // Helper method to test different redirect URIs
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

  // Exchange authorization code for access token (returns both access_token and id_token)
  static Future<Map<String, dynamic>?> _getAccessToken(String authCode) async {
    try {
      // Handle demo web auth code
      if (authCode.startsWith('demo_web_auth_code_')) {
        print('Using demo web auth code');
        return {
          'access_token':
              'demo_access_token_${DateTime.now().millisecondsSinceEpoch}',
          'token_type': 'Bearer',
          'expires_in': 3600,
        };
      }

      final response = await http.post(
        Uri.parse(tokenUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'grant_type': 'authorization_code',
          'code': authCode,
          'redirect_uri': redirectUri,
          'client_id': clientId,
          'client_secret': clientSecret,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data; // Contains both access_token and id_token
      } else {
        print('Token exchange failed: ${response.statusCode} ${response.body}');
      }

      return null;
    } catch (e) {
      print('Error getting access token: $e');
      return null;
    }
  }

  // Get user profile using the new userinfo endpoint
  static Future<Map<String, dynamic>?> _getUserProfile(
      String accessToken) async {
    try {
      // Handle demo access token
      if (accessToken.startsWith('demo_access_token_')) {
        print('Using demo access token for web');
        return {
          'sub': 'demo_web_user_${DateTime.now().millisecondsSinceEpoch}',
          'given_name': 'Web',
          'family_name': 'User',
          'email': 'webuser@linkedin.com',
          'picture': 'https://via.placeholder.com/150/0077B5/FFFFFF?text=WU',
          'locale': 'en-US',
        };
      }

      final response = await http.get(
        Uri.parse(userinfoUrl),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        print('Profile fetch failed: ${response.statusCode} ${response.body}');
      }

      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // Convert LinkedIn OpenID Connect profile to our expected format
  static Map<String, dynamic> _convertLinkedInProfile(
      Map<String, dynamic> linkedInProfile) {
    return {
      'id': linkedInProfile['sub'] ?? 'unknown',
      'firstName': linkedInProfile['given_name'] ?? '',
      'lastName': linkedInProfile['family_name'] ?? '',
      'email': linkedInProfile['email'] ?? '',
      'profilePicture': linkedInProfile['picture'],
      // Note: OpenID Connect basic profile doesn't include work/education history
      // You would need additional LinkedIn API calls or partner access for that
      'companies': [
        {
          'name': 'LinkedIn Connected Company',
          'title': 'Professional',
          'startDate': DateTime.now().toIso8601String().split('T')[0],
          'endDate': null,
          'current': true,
          'location': linkedInProfile['locale'] ?? 'Unknown'
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
      'location': linkedInProfile['locale'] ?? 'Professional Network',
      'industry': 'Professional Services',
      'summary':
          'Connected through LinkedIn using OpenID Connect authentication.'
    };
  }
}

// WebView screen for LinkedIn OAuth
class _LinkedInWebViewScreen extends StatefulWidget {
  final String authUrl;

  const _LinkedInWebViewScreen({required this.authUrl});

  @override
  State<_LinkedInWebViewScreen> createState() => _LinkedInWebViewScreenState();
}

class _LinkedInWebViewScreenState extends State<_LinkedInWebViewScreen> {
  late final WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            print('Navigation to: ${request.url}');

            // Check if this is the redirect URL with authorization code
            if (request.url.startsWith(LinkedInOAuthService.redirectUri)) {
              final uri = Uri.parse(request.url);
              final code = uri.queryParameters['code'];
              final error = uri.queryParameters['error'];

              if (code != null) {
                print('Authorization code received: $code');
                Navigator.of(context).pop(code);
                return NavigationDecision.prevent;
              } else if (error != null) {
                print('OAuth error: $error');
                Navigator.of(context).pop(null);
                return NavigationDecision.prevent;
              }
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.authUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign in with LinkedIn'),
        backgroundColor: const Color(0xFF0077B5),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(null),
        ),
        actions: [
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
