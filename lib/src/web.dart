// ignore: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:convert';
import 'dart:js' as js;
import 'dart:html' as html;

import 'package:easy_web_view/src/utils/logger.dart';
import 'package:http/http.dart' as http;
import 'package:easy_web_view/easy_web_view.dart';
import 'package:easy_web_view/src/controller/controller.dart' as web_ctrl;
import 'package:easy_web_view/src/controller/impl/web.dart';
import 'package:easy_web_view/src/utils/constants.dart';
import 'package:easy_web_view/src/utils/embedded_js_content.dart';
import 'package:easy_web_view/src/utils/dart_ui_fix.dart' as ui;
import 'package:easy_web_view/src/utils/html_utils.dart';
import 'package:easy_web_view/src/utils/mobile_specific_params.dart';
import 'package:easy_web_view/src/utils/source_type.dart';
import 'package:easy_web_view/src/utils/web_specific_params.dart';
import 'package:easy_web_view/src/utils/webview_content_model.dart';
import 'package:easy_web_view/src/utils/webview_flutter_original_utils.dart';
import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

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
  late html.IFrameElement iframe;
  late String iframeViewType;
  late StreamSubscription iframeOnLoadSubscription;
  late js.JsObject jsWindowObject;
  late ModifiedWebViewController webViewController;

  late bool _didLoadInitialContent;
  late bool _ignoreAllGestures;
  @override
  void initState() {
    /* widget.onLoaded();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      final _iframe = _iframeElementMap[widget.key];
      _iframe?.onLoad.listen((event) {
        widget.onLoaded();
      });
    }); */
    _didLoadInitialContent = false;
    _ignoreAllGestures = widget.ignoreAllGestures;

    iframeViewType = _createViewType();
    super.initState();
  }

  @override
  void dispose() {
    iframeOnLoadSubscription.cancel();
    webViewController.removeListener(_handleChange);
    webViewController.removeIgnoreGesturesListener(
      _handleIgnoreGesturesChange,
    );
    super.dispose();
  }

  @override
  void didUpdateWidget(EasyWebView oldWidget) {
    if (oldWidget.height != widget.height) {
      if (mounted) setState(() {});
    }
    if (oldWidget.width != widget.width) {
      if (mounted) setState(() {});
    }
    if (oldWidget.src != widget.src) {
      if (mounted) setState(() {});
    }
    if (oldWidget.headers != widget.headers) {
      if (mounted) setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  // This creates a unique String to be used as the view type of the HtmlElementView
  String _createViewType() {
    return HtmlUtils.buildIframeViewType();
  }

  @override
  Widget build(BuildContext context) {
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
        _setup(src, w, h);
        return _iframeIgnorePointer(
          child: _htmlElement(iframeViewType),
          ignoring: _ignoreAllGestures,
        );
      },
    );
  }

  Widget _htmlElement(String iframeViewType) {
    return AbsorbPointer(
      child: RepaintBoundary(
        child: HtmlElementView(
          key: widget.key,
          viewType: iframeViewType,
        ),
      ),
    );
  }

  Widget _iframeIgnorePointer({
    required Widget child,
    bool ignoring = false,
  }) {
    return Stack(
      children: [
        child,
        if (ignoring)
          Positioned.fill(
            child: PointerInterceptor(
              child: Container(),
            ),
          )
        else
          const SizedBox.shrink(),
      ],
    );
  }

  static final _iframeElementMap = Map<Key, html.IFrameElement>();

  html.IFrameElement _createIFrame(String? src, double width, double height) {
    final key = widget.key ?? ValueKey('');
    if (_iframeElementMap[key] == null) {
      _iframeElementMap[key] = html.IFrameElement();
    }
    final iframeElement = _iframeElementMap[key];

    iframeElement!
      ..id = 'id_$iframeViewType'
      ..name = 'name_$iframeViewType'
      ..style.border = '0'
      ..allowFullscreen = widget.webAllowFullScreen
      ..height = height.toInt().toString()
      ..width = width.toInt().toString();

    widget.webSpecificParams.additionalSandboxOptions.forEach(iframeElement.sandbox!.add);

    if (widget.javascriptMode == JavascriptMode.unrestricted) {
      iframeElement.sandbox!.add('allow-scripts');
    }

    final allow = widget.webSpecificParams.additionalAllowOptions;

    if (widget.initialMediaPlaybackPolicy == AutoMediaPlaybackPolicy.alwaysAllow) {
      allow.add('autoplay');
    }

    iframeElement.allow = allow.reduce((curr, next) => '$curr; $next');

    html.window.addEventListener('onbeforeunload', (event) async {
      final beforeUnloadEvent = (event as html.BeforeUnloadEvent);
      if (widget.webNavigationDelegate == null) return;
      final webNavigationDecision =
          await widget.webNavigationDelegate!(WebNavigationRequest(content: NavigationContent(html.window.location.href, SourceType.url), isForMainFrame: true));
      if (webNavigationDecision == WebNavigationDecision.prevent) {
        // Cancel the event
        beforeUnloadEvent.preventDefault();
        // Chrome requires returnValue to be set
        beforeUnloadEvent.returnValue = '';
      } else {
        // Guarantee the browser unload by removing the returnValue property of the event
        beforeUnloadEvent.returnValue = null;
      }
    });

    /* if (widget.crossWindowEvents.isNotEmpty) {
      html.window.addEventListener('message', (event) {
        final eventData = (event as html.MessageEvent).data;
        widget.crossWindowEvents.forEach((crossWindowEvent) {
          final crossWindowEventListener = crossWindowEvent.eventAction;
          crossWindowEventListener(eventData);
        });
      });
    }
    String _src = src ?? '';
    if (src != null) {
      if (widget.isMarkdown) {
        _src = "data:text/html;charset=utf-8," + Uri.encodeComponent(EasyWebViewImpl.md2Html(src));
      }
      if (widget.isHtml) {
        _src = "data:text/html;charset=utf-8," + Uri.encodeComponent(EasyWebViewImpl.wrapHtml(src));
      }
    }
    iframeElement..src = _src; */

    return iframeElement;
  }

  void _setup(String? src, double width, double height) {
    iframe = _createIFrame(src, width, height);
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory('$iframeViewType', (int viewId) {
      return iframe;
    });

    if (iframe.name == 'name_$iframeViewType') {
      webViewController = _createWebViewController();

      if (widget.initialSourceType == SourceType.html ||
          widget.initialSourceType == SourceType.urlBypass ||
          (widget.initialSourceType == SourceType.url && widget.initialContent == 'about:blank')) {
        _connectJsToFlutter(then: _callOnWebViewCreatedCallback);
      } else {
        _callOnWebViewCreatedCallback();
      }

      _registerIframeOnLoadCallback();
    }
  }

  ModifiedWebViewController _createWebViewController() {
    return ModifiedWebViewController(
      initialContent: widget.initialContent,
      initialSourceType: widget.initialSourceType,
      ignoreAllGestures: _ignoreAllGestures,
    )
      ..addListener(_handleChange)
      ..addIgnoreGesturesListener(_handleIgnoreGesturesChange);
  }

  // Keep js "window" object referrence, so we can call functions on it later.
  // This happens only if we use HTML (because you can't alter the source code
  // of some other webpage that you pass in using the URL param)
  //
  // Iframe viewType is used as a disambiguator.
  // Check function [embedWebIframeJsConnector] from [HtmlUtils] for details.
  void _connectJsToFlutter({VoidCallback? then}) {
    js.context['$jsToDartConnectorFN$iframeViewType'] = (js.JsObject window) {
      jsWindowObject = window;

      /// Register dart callbacks one by one.
      for (final cb in widget.crossWindowEvents) {
        jsWindowObject[cb.name] = cb.eventAction;
      }

      // Register history callback
      jsWindowObject[webOnClickInsideIframeCallback] = (onClickCallbackObject) {
        _handleOnIframeClick(onClickCallbackObject as String);
      };

      webViewController.connector = jsWindowObject;

      then?.call();

      /* 
      // Registering the same events as we already do inside
      // HtmlUtils.embedClickListenersInPageSource(), but in Dart.
      // So far it seems to be working, but needs more testing.

      jsWindowObject.callMethod('addEventListener', [
        "click",
        js.allowInterop((event) {
          final href = jsWindowObject["document"]["activeElement"]["href"].toString();
          print(href);
        })
      ]);

      jsWindowObject.callMethod('addEventListener', [
        "submit",
        js.allowInterop((event) {
          final form = jsWindowObject["document"]["activeElement"]["form"];

          final method = form["method"].toString();

          if (method == 'get') {
            final action = jsWindowObject.callMethod(
              'eval',
              [
                "document.activeElement.form.action + '?' + new URLSearchParams(new FormData(document.activeElement.form))"
              ],
            ).toString();
            print(action);
          } else {
            // post
            final action = form["action"].toString();

            final formData = jsWindowObject
                .callMethod(
                  'eval',
                  ["[...new FormData(document.activeElement.form)]"],
                )
                .toString()
                .split(',');

            final mappedFields = <String, dynamic>{};
            for (var i = 0; i < formData.length; i++) {
              if (i % 2 != 0) {
                mappedFields[formData[i - 1]] = formData[i];
              }
            }
            print(mappedFields);
          }
        })
      ]);
      */
    };
  }

  void _registerIframeOnLoadCallback() {
    iframeOnLoadSubscription = iframe.onLoad.listen((event) {
      _debugLog('IFrame $iframeViewType has been (re)loaded.');

      if (!_didLoadInitialContent) {
        _didLoadInitialContent = true;
        _callOnPageStartedCallback(webViewController.value.source);
      } else {
        _callOnPageFinishedCallback(webViewController.value.source);
      }
    });
  }

  void _callOnWebViewCreatedCallback() {
    widget.onWebViewCreated?.call(webViewController);
  }

  void _callOnPageStartedCallback(String src) {
    widget.onPageStarted?.call(src);
  }

  void _callOnPageFinishedCallback(String src) {
    widget.onPageFinished?.call(src);
    widget.onLoaded();
  }

  // Called when WebViewController updates it's value
  void _handleChange() {
    final model = webViewController.value;
    final source = model.source;

    _callOnPageStartedCallback(source);
    _updateSource(model);
  }

  // Called when WebViewController updates it's ignoreAllGesturesNotifier value
  void _handleIgnoreGesturesChange() {
    setState(() {
      _ignoreAllGestures = webViewController.ignoresAllGestures;
    });
  }

  Future<bool> _checkNavigationAllowed(
    String pageSource,
    SourceType sourceType,
  ) async {
    if (widget.webNavigationDelegate == null) {
      return true;
    }

    final decision = await widget.webNavigationDelegate!(
      WebNavigationRequest(
        content: NavigationContent(pageSource, sourceType),
        isForMainFrame: true,
      ),
    );

    return decision == WebNavigationDecision.navigate;
  }

  // Updates the source depending if it is HTML or URL
  void _updateSource(WebViewContent model) {
    final source = model.source;

    if (source.isEmpty) {
      _debugLog('Cannot set empty source on webview.');
      return;
    }

    switch (model.sourceType) {
      case SourceType.html:
        iframe.srcdoc = HtmlUtils.preprocessSource(
          source,
          jsContent: widget.jsContent,
          windowDisambiguator: iframeViewType,
          forWeb: true,
        );
        break;
      case SourceType.url:
      case SourceType.urlBypass:
        if (source == 'about:blank') {
          iframe.srcdoc = HtmlUtils.preprocessSource(
            '<br>',
            jsContent: widget.jsContent,
            windowDisambiguator: iframeViewType,
            forWeb: true,
          );
          break;
        }

        if (!source.startsWith(RegExp('http[s]?://', caseSensitive: false))) {
          _debugLog('Invalid URL supplied for webview: $source');
          return;
        }

        if (model.sourceType == SourceType.url) {
          iframe.contentWindow!.location.href = source;
        } else {
          _tryFetchRemoteSource(
            method: 'get',
            url: source,
            headers: model.headers,
          );
        }
        break;
    }
  }

  Future<void> _handleOnIframeClick(String receivedObject) async {
    final dartObj = jsonDecode(receivedObject) as Map<String, dynamic>;
    final href = dartObj['href'] as String;
    _debugLog(dartObj.toString());

    if (!await _checkNavigationAllowed(href, webViewController.value.sourceType)) {
      _debugLog('Navigation not allowed for source:\n$href\n');
      return;
    }

    // (ㆆ_ㆆ)
    if (href == 'javascript:history.back()') {
      webViewController.goBack();
      return;
    } else if (href == 'javascript:history.forward()') {
      webViewController.goForward();
      return;
    }

    final method = dartObj['method'] as String;
    final body = dartObj['body'];

    final bodyMap = body == null
        ? null
        : (<String, String>{}..addEntries(
            (body as List<dynamic>).map(
              (e) => MapEntry<String, String>(
                e[0].toString(),
                e[1].toString(),
              ),
            ),
          ));

    _tryFetchRemoteSource(
      method: method,
      url: href,
      headers: webViewController.value.headers,
      body: bodyMap,
    );
  }

  void _tryFetchRemoteSource({
    required String method,
    required String url,
    Map<String, String>? headers,
    Object? body,
  }) {
    _fetchPageSourceBypass(
      method: method,
      url: url,
      headers: headers,
      body: body,
    ).then((source) {
      _setPageSourceAfterBypass(url, source);

      webViewController.webRegisterNewHistoryEntry(WebViewContent(
        source: url,
        sourceType: SourceType.urlBypass,
        headers: headers,
        webPostRequestBody: body,
      ));

      _debugLog('Got a new history entry: $url\n');
    }).catchError((e) {
      widget.onWebResourceError?.call(WebResourceError(
        description: 'Failed to fetch the page at $url\nError:\n$e\n',
        errorCode: WebResourceErrorType.connect.index,
        errorType: WebResourceErrorType.connect,
        domain: Uri.parse(url).authority,
        failingUrl: url,
      ));
      _debugLog('Failed to fetch the page at $url\nError:\n$e\n');
    });
  }

  Future<String> _fetchPageSourceBypass({
    required String method,
    required String url,
    Map<String, String>? headers,
    Object? body,
  }) async {
    final proxyList = widget.webSpecificParams.proxyList;

    if (widget.userAgent != null) {
      (headers ??= <String, String>{}).putIfAbsent(
        userAgentHeadersKey,
        () => widget.userAgent!,
      );
    }

    for (var i = 0; i < proxyList.length; i++) {
      final proxy = proxyList[i];
      _debugLog('Using proxy: ${proxy.runtimeType}');

      final proxiedUri = Uri.parse(proxy.buildProxyUrl(url));

      Future<http.Response> request;

      if (method == 'get') {
        request = http.get(proxiedUri, headers: headers);
      } else {
        request = http.post(proxiedUri, headers: headers, body: body);
      }

      try {
        final response = await request;
        return proxy.extractPageSource(response.body);
      } catch (e) {
        _debugLog(
          'Failed to fetch the page at $url from proxy ${proxy.runtimeType}.',
        );

        if (i == proxyList.length - 1) {
          return Future.error(
            'None of the provided proxies were able to fetch the given page.',
          );
        }

        continue;
      }
    }

    return Future.error('Bad state');
  }

  void _setPageSourceAfterBypass(String pageUrl, String pageSource) {
    final replacedPageSource = HtmlUtils.embedClickListenersInPageSource(
      pageUrl,
      pageSource,
    );

    iframe.srcdoc = HtmlUtils.preprocessSource(
      replacedPageSource,
      jsContent: widget.jsContent,
      windowDisambiguator: iframeViewType,
      forWeb: true,
    );
  }

  void _debugLog(String text) {
    if (widget.webSpecificParams.printDebugInfo) {
      log(text);
    }
  }
}
