import 'package:easy_web_view/easy_web_view.dart';
import 'package:easy_web_view/src/controller/interface.dart' as ctrl_interface;
import 'package:easy_web_view/src/utils/embedded_js_content.dart';
import 'package:easy_web_view/src/utils/mobile_specific_params.dart';
import 'package:easy_web_view/src/utils/source_type.dart';
import 'package:easy_web_view/src/utils/web_specific_params.dart';
import 'package:easy_web_view/src/utils/webview_flutter_original_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:html2md/html2md.dart' as html2md;
import 'package:http/http.dart' as http;
import 'package:markdown/markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class EasyWebViewImpl {
  final String src;
  final num? width, height;
  final bool webAllowFullScreen;
  final bool isMarkdown;
  final bool isHtml;
  final bool convertToWidgets;
  final Map<String, String> headers;
  final bool widgetsTextSelectable;
  final void Function() onLoaded;
  final List<CrossWindowEvent> crossWindowEvents;

  /// Callback to decide whether to allow navigation to the incoming url
  final WebNavigationDelegate? webNavigationDelegate;

  /// Callback which returns a referrence to the [WebViewXController]
  /// being created.
  final Function(ctrl_interface.ModifiedWebViewController controller)? onWebViewCreated;

  /// A set of [EmbeddedJsContent].
  ///
  /// You can define JS functions, which will be embedded into
  /// the HTML source (won't do anything on URL) and you can later call them
  /// using the controller.
  ///
  /// For more info, see [EmbeddedJsContent].
  final Set<EmbeddedJsContent> jsContent;

  /// Initial content
  final String initialContent;

  /// Initial source type. Must match [initialContent]'s type.
  ///
  /// Example:
  /// If you set [initialContent] to '<p>hi</p>', then you should
  /// also set the [initialSourceType] accordingly, that is [SourceType.html].
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

  const EasyWebViewImpl({
    Key? key,
    this.width,
    this.height,
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
    this.widgetsTextSelectable = false,
    this.headers = const {},
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
  }) : assert((isHtml && isMarkdown) == false);

  static String wrapHtml(String src) {
    if (EasyWebViewImpl.isValidHtml(src)) {
      return """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
</head>
<body>
$src
</body>
</html>
  """;
    }
    return src;
  }

  static String html2Md(String src) => html2md.convert(src);

  static String md2Html(String src) => markdownToHtml(src);

  static bool isUrl(String src) => src.startsWith('https://') || src.startsWith('http://');

  static bool isValidHtml(String src) => src.contains('<html>') && src.contains('</html>');
}

class OptionalSizedChild extends StatelessWidget {
  final double? width, height;
  final Widget Function(double, double) builder;

  const OptionalSizedChild({
    required this.width,
    required this.height,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    if (width != null && height != null) {
      return SizedBox(
        width: width,
        height: height,
        child: builder(width!, height!),
      );
    }
    return LayoutBuilder(
      builder: (context, dimens) {
        final w = width ?? dimens.maxWidth;
        final h = height ?? dimens.maxHeight;
        return SizedBox(
          width: w,
          height: h,
          child: builder(w, h),
        );
      },
    );
  }
}

class RemoteMarkdown extends StatelessWidget {
  const RemoteMarkdown({
    required this.src,
    required this.headers,
    required this.isSelectable,
  });

  final String src;
  final Map<String, String> headers;
  final bool isSelectable;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<http.Response>(
      future: http.get(Uri.parse(src), headers: headers),
      builder: (context, response) {
        if (!response.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        if (response.data?.statusCode == 200) {
          String content = response.data!.body;
          if (EasyWebViewImpl.isValidHtml(src)) {
            content = EasyWebViewImpl.html2Md(content);
          }
          return LocalMarkdown(
            data: content,
            isSelectable: isSelectable,
          );
        }
        return Center(child: Icon(Icons.error));
      },
    );
  }
}

class LocalMarkdown extends StatelessWidget {
  final String data;
  final bool isSelectable;

  const LocalMarkdown({
    required this.data,
    required this.isSelectable,
  });

  @override
  Widget build(BuildContext context) {
    return Markdown(
      data: data,
      onTapLink: (_, url, __) => url == null ? null : launch(url),
      selectable: isSelectable,
    );
  }
}
