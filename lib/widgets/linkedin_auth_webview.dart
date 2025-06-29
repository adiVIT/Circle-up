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
    if (url.contains('localhost:8080/auth/linkedin/callback') ||
        url.contains('localhost:3000/auth/linkedin/callback')) {
      final uri = Uri.parse(url);
      final code = uri.queryParameters['code'];
      final error = uri.queryParameters['error'];

      if (code != null && code.isNotEmpty) {
        print('✅ Authorization code captured: ${code.substring(0, 10)}...');
        Navigator.of(context).pop(code);
      } else if (error != null) {
        print('❌ LinkedIn authorization error: $error');
        Navigator.of(context).pop(null);
      }
    }
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
