import 'dart:async';

import 'package:easy_web_view/src/utils/webview_flutter_original_utils.dart';

export 'src/unsupported.dart' if (dart.library.html) 'src/web.dart' if (dart.library.io) 'src/mobile.dart';

enum WebNavigationDecision { navigate, prevent }

class WebNavigationRequest {
  WebNavigationRequest({
    required this.content,
    required this.isForMainFrame,
  });

  /// The URL that will be loaded if the navigation is executed.
  // final String content;
  final NavigationContent content;

  /// Whether the navigation request is to be loaded as the main frame.
  final bool isForMainFrame;

  @override
  String toString() {
    return 'NavigationRequest(content: $content, isForMainFrame: $isForMainFrame)';
  }
}

typedef FutureOr<WebNavigationDecision> WebNavigationDelegate(WebNavigationRequest webNavigationRequest);

class CrossWindowEvent {
  final String name;
  final Function(dynamic) eventAction;

  CrossWindowEvent({
    required this.name,
    required this.eventAction,
  });
}
