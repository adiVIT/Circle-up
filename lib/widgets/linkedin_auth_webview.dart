import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LinkedInAuthWebView extends StatefulWidget {
  final String authUrl;

  const LinkedInAuthWebView({
    Key? key,
    required this.authUrl,
  }) : super(key: key);

  @override
  State<LinkedInAuthWebView> createState() => _LinkedInAuthWebViewState();
}

class _LinkedInAuthWebViewState extends State<LinkedInAuthWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasReturned = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('LinkedIn WebView page started: $url');
            _checkForAuthCode(url);
          },
          onPageFinished: (String url) {
            print('LinkedIn WebView page finished: $url');
            setState(() {
              _isLoading = false;
            });
            _checkForAuthCode(url);
          },
          onNavigationRequest: (NavigationRequest request) {
            print('LinkedIn WebView navigation request: ${request.url}');
            _checkForAuthCode(request.url);
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.authUrl));
  }

  void _checkForAuthCode(String url) {
    print('Checking URL for auth code: $url');

    // Check if the URL contains the redirect URI with authorization code
    // Look for LinkedIn's redirect URL or localhost callbacks
    if (url.contains('linkedin.com/developers/tools/oauth/redirect') ||
        url.contains('localhost') && url.contains('auth/linkedin/callback') ||
        url.contains('callback') ||
        url.contains('code=') ||
        url.contains('error=')) {
      try {
        final uri = Uri.parse(url);
        final code = uri.queryParameters['code'];
        final error = uri.queryParameters['error'];
        final errorDescription = uri.queryParameters['error_description'];

        print('📋 URL parameters: ${uri.queryParameters}');

        if (code != null && code.isNotEmpty && !_hasReturned) {
          print('✅ Authorization code captured: ${code.substring(0, 10)}...');
          _hasReturned = true;
          if (mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop(code);
          }
          return;
        }

        if (error != null && !_hasReturned) {
          print('❌ LinkedIn authorization error: $error');
          if (errorDescription != null) {
            print('❌ Error description: $errorDescription');
          }
          _hasReturned = true;
          if (mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop(null);
          }
          return;
        }
      } catch (e) {
        print('Error parsing URL: $e');
      }
    }

    // Also check for specific error patterns
    if (url.contains('error') && !url.contains('linkedin.com')) {
      print('❌ Detected error in redirect URL: $url');
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop(null);
      }
    }
  }

  void _showManualCodeEntry() {
    showDialog(
      context: context,
      builder: (context) {
        String? authCode;
        return AlertDialog(
          title: const Text('Manual Code Entry'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'If the redirect didn\'t work automatically, you can manually enter the authorization code from the URL.',
              ),
              const SizedBox(height: 16),
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
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (authCode != null && authCode!.isNotEmpty) {
                  Navigator.of(context).pop(authCode);
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LinkedIn Authorization'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(null),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showManualCodeEntry,
            tooltip: 'Enter code manually',
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading LinkedIn...'),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
