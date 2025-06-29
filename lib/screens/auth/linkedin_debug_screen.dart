import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/linkedin_oauth_service.dart';
import '../../services/linkedin_test_service.dart';

class LinkedInDebugScreen extends StatefulWidget {
  const LinkedInDebugScreen({Key? key}) : super(key: key);

  @override
  State<LinkedInDebugScreen> createState() => _LinkedInDebugScreenState();
}

class _LinkedInDebugScreenState extends State<LinkedInDebugScreen> {
  String? selectedRedirectUri;
  final TextEditingController _customUriController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedRedirectUri = LinkedInOAuthService.redirectUri;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LinkedIn OAuth Debug'),
        backgroundColor: const Color(0xFF0077B5),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Configuration
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Configuration',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Client ID: ${LinkedInOAuthService.clientId}'),
                    const SizedBox(height: 4),
                    Text(
                        'Platform: ${LinkedInOAuthService.redirectUri.contains('localhost') ? 'Web' : 'Mobile'}'),
                    const SizedBox(height: 4),
                    Text(
                        'Current Redirect URI: ${LinkedInOAuthService.redirectUri}'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Available Redirect URIs
            const Text(
              'Available Redirect URIs',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            ...LinkedInOAuthService.allRedirectUris
                .map(
                  (uri) => Card(
                    child: ListTile(
                      title: Text(uri),
                      subtitle: Text(uri.contains('localhost')
                          ? 'Web Development'
                          : 'Mobile App'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: uri));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Copied to clipboard')),
                              );
                            },
                          ),
                          Radio<String>(
                            value: uri,
                            groupValue: selectedRedirectUri,
                            onChanged: (value) {
                              setState(() {
                                selectedRedirectUri = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),

            const SizedBox(height: 16),

            // Custom Redirect URI
            const Text(
              'Custom Redirect URI',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _customUriController,
              decoration: const InputDecoration(
                hintText: 'Enter custom redirect URI',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // Test Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      LinkedInOAuthService.testRedirectUris();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Check console for test URLs')),
                      );
                    },
                    child: const Text('Test All URIs'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _testSelectedUri,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0077B5),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Test Selected URI'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // OAuth Flow Test Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _testOAuthFlow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0077B5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  '🔐 Test Full OAuth Flow (User Login)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Quick Test Button (Direct Token)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _quickTest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  '⚡ Quick Test - Direct Token (Testing Only)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Access Token Test Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _testAccessToken,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Test Access Token'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _testUserCreation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Test User Creation'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Instructions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Instructions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('1. Go to LinkedIn Developer Console'),
                    const Text('2. Select your app (Client ID shown above)'),
                    const Text('3. Go to Auth tab'),
                    const Text(
                        '4. Add the redirect URI to "Authorized redirect URLs"'),
                    const Text('5. Save changes'),
                    const Text('6. Test the authentication flow'),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        const url = 'https://www.linkedin.com/developers/apps';
                        Clipboard.setData(const ClipboardData(text: url));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'LinkedIn Developer Console URL copied')),
                        );
                      },
                      child: const Text('Copy LinkedIn Developer Console URL'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _testSelectedUri() {
    final uri = _customUriController.text.isNotEmpty
        ? _customUriController.text
        : selectedRedirectUri;

    if (uri != null) {
      final testUrl =
          'https://www.linkedin.com/oauth/v2/authorization?response_type=code&client_id=${LinkedInOAuthService.clientId}&redirect_uri=${Uri.encodeComponent(uri)}&scope=${Uri.encodeComponent(LinkedInOAuthService.scope)}&state=test_${DateTime.now().millisecondsSinceEpoch}';

      print('Testing with URI: $uri');
      print('Test URL: $testUrl');

      Clipboard.setData(ClipboardData(text: testUrl));

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Test URL Generated'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                  'Test URL copied to clipboard. Open it in a browser to test.'),
              const SizedBox(height: 8),
              const Text('Redirect URI:'),
              SelectableText(uri),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _testAccessToken() async {
    LinkedInTestService.validateOAuthConfiguration();
    final result = await LinkedInTestService.testUserInfo();

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Access token test successful! Check console for details.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Access token test failed. Check console for details.')),
      );
    }
  }

  void _testOAuthFlow() async {
    try {
      print('🔐 Starting full LinkedIn OAuth flow test...');

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Call the new OAuth flow
      final userData = await LinkedInOAuthService.signInWithLinkedIn(context);

      // Close loading indicator
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (userData != null) {
        // Show success dialog with user data
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('🎉 OAuth Flow Successful!'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Name: ${userData['name']}'),
                    Text('Email: ${userData['email']}'),
                    Text('ID: ${userData['id']}'),
                    const SizedBox(height: 8),
                    const Text('✅ User would be authenticated and signed in!'),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ OAuth flow failed or was cancelled'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Close loading indicator if still open
      if (mounted) {
        Navigator.of(context).pop();
      }

      print('OAuth flow error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ OAuth flow error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _quickTest() async {
    final success = await LinkedInTestService.quickTest();

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              '✅ LinkedIn connection successful! Check console for details.'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('❌ LinkedIn connection failed. Check console for details.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _testUserCreation() async {
    final userData = await LinkedInTestService.createTestUserData();

    if (userData != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Test User Data'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: ${userData['firstName']} ${userData['lastName']}'),
                Text('Email: ${userData['email']}'),
                Text('ID: ${userData['id']}'),
                const SizedBox(height: 8),
                const Text('This data would be used to create a user profile.'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to create test user data. Check console.')),
      );
    }
  }

  @override
  void dispose() {
    _customUriController.dispose();
    super.dispose();
  }
}
