import 'dart:async';

import 'package:easy_web_view/easy_web_view.dart';
import 'package:easy_web_view/src/controller/impl/mobile.dart';
import 'package:easy_web_view/src/utils/embedded_js_content.dart';
import 'package:easy_web_view/src/utils/html_utils.dart';
import 'package:easy_web_view/src/utils/mobile_specific_params.dart';
import 'package:easy_web_view/src/utils/source_type.dart';
import 'package:easy_web_view/src/utils/web_specific_params.dart';
import 'package:easy_web_view/src/utils/webview_content_model.dart';
import 'package:easy_web_view/src/utils/webview_flutter_original_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:webview_flutter/platform_interface.dart' as wf_pi;
import 'package:webview_flutter/webview_flutter.dart' as wf;
import 'package:easy_web_view/src/controller/interface.dart' as ctrl_interface;

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
  final Function(ctrl_interface.ModifiedWebViewController controller)? onWebViewCreated;

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
  late wf.WebViewController originalWebViewController;
  late ModifiedWebViewController modifiedWebViewController;

  late bool _ignoreAllGestures;

  @override
  void initState() {
    super.initState();

    _ignoreAllGestures = widget.ignoreAllGestures;
    modifiedWebViewController = _createWebViewXController();
    // Enable hybrid composition.
    //if (wf.Platform.isAndroid) wf.WebView.platform = wf.SurfaceAndroidWebView();
  }

  @override
  void dispose() {
    modifiedWebViewController.removeListener(_handleChange);
    modifiedWebViewController.removeIgnoreGesturesListener(
      _handleIgnoreGesturesChange,
    );
    super.dispose();
  }

  @override
  void didUpdateWidget(EasyWebView oldWidget) {
    if (oldWidget.src != widget.src) {
      originalWebViewController.loadUrl(_updateUrl(widget.src), headers: widget.headers);
    }
    if (oldWidget.height != widget.height) {
      if (mounted) setState(() {});
    }
    if (oldWidget.width != widget.width) {
      if (mounted) setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  String _updateUrl(String url) {
    String _src = url;
    if (widget.isMarkdown) {
      _src = "data:text/html;charset=utf-8," + Uri.encodeComponent(EasyWebViewImpl.md2Html(url));
    }
    if (widget.isHtml) {
      _src = "data:text/html;charset=utf-8," + Uri.encodeComponent(EasyWebViewImpl.wrapHtml(url));
    }
    widget.onLoaded();
    return _src;
  }

  @override
  Widget build(BuildContext context) {
    final javascriptMode = widget.javascriptMode == JavascriptMode.unrestricted ? wf.JavascriptMode.unrestricted : wf.JavascriptMode.disabled;

    final initialMediaPlaybackPolicy = widget.initialMediaPlaybackPolicy == AutoMediaPlaybackPolicy.alwaysAllow
        ? wf.AutoMediaPlaybackPolicy.always_allow
        : wf.AutoMediaPlaybackPolicy.require_user_action_for_all_media_types;

    void onWebResourceError(wf_pi.WebResourceError err) => widget.onWebResourceError!(
          WebResourceError(
            description: err.description,
            errorCode: err.errorCode,
            domain: err.domain,
            errorType: WebResourceErrorType.values.singleWhere(
              (value) => value.toString() == err.errorType.toString(),
            ),
            failingUrl: err.failingUrl,
          ),
        );

    FutureOr<wf.NavigationDecision> navigationDelegate(wf.NavigationRequest request) async {
      if (widget.webNavigationDelegate == null) {
        modifiedWebViewController.value = modifiedWebViewController.value.copyWith(source: request.url);
        return wf.NavigationDecision.navigate;
      }

      final delegate = await widget.webNavigationDelegate!.call(
        WebNavigationRequest(
          content: NavigationContent(request.url, modifiedWebViewController.value.sourceType),
          isForMainFrame: request.isForMainFrame,
        ),
      );

      switch (delegate) {
        case WebNavigationDecision.navigate:
          // When clicking on an URL, the sourceType stays the same.
          // That's because you cannot move from URL to HTML just by clicking.
          // Also we don't take URL_BYPASS into consideration because it has no effect here in mobile
          modifiedWebViewController.value = modifiedWebViewController.value.copyWith(
            source: request.url,
          );
          return wf.NavigationDecision.navigate;
        case WebNavigationDecision.prevent:
          return wf.NavigationDecision.prevent;
      }
    }

    void onWebViewCreated(wf.WebViewController webViewController) {
      originalWebViewController = webViewController;

      modifiedWebViewController.connector = originalWebViewController;
      // Calls onWebViewCreated to pass the refference upstream
      if (widget.onWebViewCreated != null) {
        widget.onWebViewCreated!(modifiedWebViewController);
      }
    }

    final javascriptChannels = widget.crossWindowEvents
        .map(
          (cw) => wf.JavascriptChannel(
            name: cw.name,
            onMessageReceived: (msg) => cw.eventAction(msg.message),
          ),
        )
        .toSet();

    final webview = wf.WebView(
      key: widget.key,
      initialUrl: _initialContent(),
      javascriptMode: javascriptMode,
      onWebViewCreated: onWebViewCreated,
      javascriptChannels: javascriptChannels,
      gestureRecognizers: widget.mobileSpecificParams.mobileGestureRecognizers,
      onPageStarted: widget.onPageStarted,
      onPageFinished: widget.onPageFinished,
      initialMediaPlaybackPolicy: initialMediaPlaybackPolicy,
      onWebResourceError: onWebResourceError,
      gestureNavigationEnabled: widget.mobileSpecificParams.gestureNavigationEnabled,
      debuggingEnabled: widget.mobileSpecificParams.debuggingEnabled,
      navigationDelegate: navigationDelegate,
      userAgent: widget.userAgent,
    );

    return OptionalSizedChild(
      width: widget.width,
      height: widget.height,
      builder: (w, h) {
        String src = widget.src;
        if (widget.convertToWidgets) {
          if (EasyWebViewImpl.isUrl(src)) {
            return RemoteMarkdown(
              src: src,
              headers: widget.headers,
              isSelectable: widget.widgetsTextSelectable,
            );
          }
          String _markdown = '';
          if (widget.isMarkdown) {
            _markdown = src;
          }
          if (widget.isHtml) {
            src = EasyWebViewImpl.wrapHtml(src);
            _markdown = EasyWebViewImpl.html2Md(src);
          }
          return LocalMarkdown(
            data: _markdown,
            isSelectable: widget.widgetsTextSelectable,
          );
        }
        return IgnorePointer(
          ignoring: _ignoreAllGestures,
          child: webview,
        );
      },
    );
  }

  // Returns initial data
  String? _initialContent() {
    if (widget.initialSourceType == SourceType.html) {
      return HtmlUtils.preprocessSource(
        widget.initialContent,
        jsContent: widget.jsContent,
        encodeHtml: true,
      );
    }
    return widget.initialContent;
  }

  // Creates a WebViewController and adds the listener
  ModifiedWebViewController _createWebViewXController() {
    return ModifiedWebViewController(
      initialContent: widget.initialContent,
      initialSourceType: widget.initialSourceType,
      ignoreAllGestures: _ignoreAllGestures,
    )
      ..addListener(_handleChange)
      ..addIgnoreGesturesListener(_handleIgnoreGesturesChange);
  }

  // Prepares the source depending if it is HTML or URL
  String _prepareContent(WebViewContent model) {
    if (model.sourceType == SourceType.html) {
      return HtmlUtils.preprocessSource(
        model.source,
        jsContent: widget.jsContent,

        // Needed for mobile webview in order to URI-encode the HTML
        encodeHtml: true,
      );
    }
    return model.source;
  }

  // Called when WebViewXController updates it's value
  void _handleChange() {
    final newModel = modifiedWebViewController.value;

    originalWebViewController.loadUrl(
      _prepareContent(newModel),
      headers: newModel.headers,
    );
  }

  // Called when the ValueNotifier inside WebViewXController updates it's value
  void _handleIgnoreGesturesChange() {
    setState(() {
      _ignoreAllGestures = modifiedWebViewController.ignoresAllGestures;
    });
  }
}
