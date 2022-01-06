import 'package:easy_web_view/easy_web_view.dart';
import 'package:easy_web_view/src/utils/embedded_js_content.dart';
import 'package:easy_web_view/src/utils/mobile_specific_params.dart';
import 'package:easy_web_view/src/utils/source_type.dart';
import 'package:easy_web_view/src/utils/web_specific_params.dart';
import 'package:easy_web_view/src/utils/webview_flutter_original_utils.dart';
import 'package:easy_web_view/src/controller/controller.dart' as web_ctrl;
import 'package:flutter/material.dart';

import 'impl.dart';

class EasyWebView extends StatefulWidget implements EasyWebViewImpl {
  const EasyWebView({
    Key? key,
    this.height,
    this.width,
    required this.src,
    required this.onLoaded,
    this.initialContent = 'about:blank',
    this.initialSourceType = SourceType.url,
    this.userAgent,
    this.webAllowFullScreen = true,
    this.onWebViewCreated,
    this.jsContent = const {},
    this.isHtml = false,
    this.isMarkdown = false,
    this.convertToWidgets = false,
    this.headers = const {},
    this.widgetsTextSelectable = false,
    this.crossWindowEvents = const [],
    this.webNavigationDelegate,
    this.ignoreAllGestures = false,
    this.javascriptMode = JavascriptMode.unrestricted,
    this.initialMediaPlaybackPolicy = AutoMediaPlaybackPolicy.requireUserActionForAllMediaTypes,
    this.onPageStarted,
    this.onPageFinished,
    this.onWebResourceError,
    this.webSpecificParams = const WebSpecificParams(),
    this.mobileSpecificParams = const MobileSpecificParams(),
  })  : assert((isHtml && isMarkdown) == false),
        super(key: key);

  @override
  _EasyWebViewState createState() => _EasyWebViewState();

  @override
  final double? height;

  @override
  final String src;

  @override
  final double? width;

  @override
  final bool webAllowFullScreen;

  @override
  final bool isMarkdown;

  @override
  final bool isHtml;

  @override
  final bool convertToWidgets;

  @override
  final Map<String, String> headers;

  @override
  final bool widgetsTextSelectable;

  @override
  final void Function() onLoaded;

  @override
  final List<CrossWindowEvent> crossWindowEvents;

  @override
  final WebNavigationDelegate? webNavigationDelegate;

  /// Callback which returns a referrence to the [WebViewXController]
  /// being created.
  @override
  final Function(web_ctrl.ModifiedWebViewController controller)? onWebViewCreated;

  /// A set of [EmbeddedJsContent].
  ///
  /// You can define JS functions, which will be embedded into
  /// the HTML source (won't do anything on URL) and you can later call them
  /// using the controller.
  ///
  /// For more info, see [EmbeddedJsContent].
  @override
  final Set<EmbeddedJsContent> jsContent;

  /// Initial content
  @override
  final String initialContent;

  /// Initial source type. Must match [initialContent]'s type.
  ///
  /// Example:
  /// If you set [initialContent] to '<p>hi</p>', then you should
  /// also set the [initialSourceType] accordingly, that is [SourceType.html].
  @override
  final SourceType initialSourceType;

  /// User-agent
  /// On web, this is only used when using [SourceType.urlBypass]
  @override
  final String? userAgent;

  /// Boolean value to specify if should ignore all gestures that touch the webview.
  ///
  /// You can change this later from the controller.
  final bool ignoreAllGestures;

  /// Boolean value to specify if Javascript execution should be allowed inside the webview
  final JavascriptMode javascriptMode;

  /// This defines if media content(audio - video) should
  /// auto play when entering the page.
  final AutoMediaPlaybackPolicy initialMediaPlaybackPolicy;

  /// Callback for when the page starts loading.
  final void Function(String src)? onPageStarted;

  /// Callback for when the page has finished loading (i.e. is shown on screen).
  final void Function(String src)? onPageFinished;

  /// Callback for when something goes wrong in while page or resources load.
  final void Function(WebResourceError error)? onWebResourceError;

  /// Parameters specific to the web version.
  /// This may eventually be merged with [mobileSpecificParams],
  /// if all features become cross platform.
  final WebSpecificParams webSpecificParams;

  /// Parameters specific to the web version.
  /// This may eventually be merged with [webSpecificParams],
  /// if all features become cross platform.
  final MobileSpecificParams mobileSpecificParams;
}

class _EasyWebViewState extends State<EasyWebView> {
  @override
  Widget build(BuildContext context) {
    return OptionalSizedChild(
      width: widget.width,
      height: widget.height,
      builder: (w, h) => Placeholder(),
    );
  }
}
