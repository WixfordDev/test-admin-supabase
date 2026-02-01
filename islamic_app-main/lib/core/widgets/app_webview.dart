import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AppWebview extends StatefulWidget {
  final String url;
  final Color bgColor;
  final Function(String)? onPageFinished;
  final bool enableZoom;

  const AppWebview({
    super.key,
    required this.url,
    required this.bgColor,
    this.onPageFinished,
    this.enableZoom = true,
  });

  @override
  State<AppWebview> createState() => _AppWebviewState();
}

class _AppWebviewState extends State<AppWebview> {
  final loadingProgress = ValueNotifier<int>(0);
  final hasError = ValueNotifier<bool>(false);
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  @override
  void dispose() {
    loadingProgress.dispose();
    hasError.dispose();
    super.dispose();
  }

  void _initializeController() {
    controller = WebViewController()
      ..setBackgroundColor(widget.bgColor)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(widget.enableZoom)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            loadingProgress.value = 0;
            hasError.value = false;

            // Improved viewport meta tag script with better scaling options
            controller.runJavaScript('''
              var viewport = document.querySelector('meta[name="viewport"]');
              if (!viewport) {
                viewport = document.createElement('meta');
                viewport.name = 'viewport';
                document.head.appendChild(viewport);
              }
              viewport.content = 'width=device-width, initial-scale=1.0, maximum-scale=${widget.enableZoom ? '5.0' : '1.0'}, user-scalable=${widget.enableZoom ? 'yes' : 'no'}';
              
              // Fix for content scaling
              document.body.style.transform = 'scale(1.0)';
              document.body.style.transformOrigin = '0 0';
              document.body.style.width = '100%';
            ''');
          },
          onProgress: (progress) {
            loadingProgress.value = progress;
          },
          onPageFinished: (url) {
            loadingProgress.value = 100;

            // Additional JavaScript to fix scaling after page load
            controller.runJavaScript('''
              // Force layout recalculation
              document.body.style.minWidth = '100vw';
              document.querySelectorAll('img, video, canvas').forEach(function(elem) {
                if (elem.offsetWidth > window.innerWidth) {
                  elem.style.maxWidth = '100%';
                  elem.style.height = 'auto';
                }
              });
            ''');

            if (widget.onPageFinished != null) {
              widget.onPageFinished!(url);
            }
          },
          onNavigationRequest: (navigation) {
            // Handle navigation logic here if needed
            return NavigationDecision.navigate;
          },
          onWebResourceError: (error) {
            hasError.value = true;
          },
        ),
      );

    _loadUrl();
  }

  void _loadUrl() {
    try {
      controller.loadRequest(Uri.parse(widget.url));
    } catch (e) {
      hasError.value = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: controller),
        ValueListenableBuilder<int>(
          valueListenable: loadingProgress,
          builder: (context, progress, _) {
            if (progress < 100) {
              return Container(
                color: widget.bgColor.withValues(alpha: 0.5),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        value: progress / 100.0,
                        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$progress%',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        ValueListenableBuilder<bool>(
          valueListenable: hasError,
          builder: (context, error, _) {
            if (error) {
              return Container(
                color: widget.bgColor,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load page',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          hasError.value = false;
                          loadingProgress.value = 0;
                          _loadUrl();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
