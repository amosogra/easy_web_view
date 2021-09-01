import 'package:easy_web_view/easy_web_view.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String src = 'https://flutter.dev';
  String src2 = 'https://flutter.dev/community';
  String src3 = 'http://www.youtube.com/embed/IyFZznAk69U';
  static ValueKey key = ValueKey('key_0');
  static ValueKey key2 = ValueKey('key_1');
  static ValueKey key3 = ValueKey('key_2');
  bool _isHtml = false;
  bool _blockNavigation = false;
  bool _isMarkdown = false;
  bool _useWidgets = false;
  bool _editing = false;
  bool _isSelectable = false;
  bool _showSummernote = false;

  bool open = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Easy Web View'),
          leading: IconButton(
            icon: Icon(Icons.access_time),
            onPressed: () {
              setState(() {
                print("Click!");
                open = !open;
              });
            },

            //tooltip: "Menu",
          ),
          actions: <Widget>[
            Builder(builder: (context) {
              return IconButton(
                icon: Icon(_editing ? Icons.close : Icons.settings),
                onPressed: () {
                  if (mounted)
                    setState(() {
                      _editing = !_editing;
                    });
                },
              );
            }),
          ],
        ),
        body: _editing
            ? SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    SwitchListTile(
                      title: Text('Html Content'),
                      value: _isHtml,
                      onChanged: (val) {
                        if (mounted)
                          setState(() {
                            _isHtml = val;
                            if (val) {
                              _isMarkdown = false;
                              src = htmlContent;
                            } else {
                              src = url;
                            }
                          });
                      },
                    ),
                    SwitchListTile(
                      title: Text('Block Html Navigation'),
                      value: _blockNavigation,
                      onChanged: (val) {
                        if (mounted)
                          setState(() {
                            _blockNavigation = val;
                          });
                      },
                    ),
                    SwitchListTile(
                      title: Text('Markdown Content'),
                      value: _isMarkdown,
                      onChanged: (val) {
                        if (mounted)
                          setState(() {
                            _isMarkdown = val;
                            if (val) {
                              _isHtml = false;
                              src = markdownContent;
                            } else {
                              src = url;
                            }
                          });
                      },
                    ),
                    SwitchListTile(
                      title: Text('Use Widgets'),
                      value: _useWidgets,
                      onChanged: (val) {
                        if (mounted)
                          setState(() {
                            _useWidgets = val;
                          });
                      },
                    ),
                    SwitchListTile(
                      title: Text('Selectable Text'),
                      value: _isSelectable,
                      onChanged: (val) {
                        if (mounted)
                          setState(() {
                            _isSelectable = val;
                          });
                      },
                    ),
                    SwitchListTile(
                      title: Text('Show Summernote'),
                      value: _showSummernote,
                      onChanged: (val) {
                        if (mounted)
                          setState(() {
                            _showSummernote = val;
                            if (val) {
                              _isMarkdown = false;
                              _isHtml = true;
                              src = summernoteHtml;
                            } else {
                              src = url;
                            }
                          });
                      },
                    ),
                  ],
                ),
              )
            : Stack(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                          flex: 1,
                          child: EasyWebView(
                            src: src,
                            onLoaded: () {
                              print('$key: Loaded: $src');
                            },
                            isHtml: _isHtml,
                            isMarkdown: _isMarkdown,
                            convertToWidgets: _useWidgets,
                            key: key,
                            widgetsTextSelectable: _isSelectable,
                            webNavigationDelegate: (_) => _blockNavigation ? WebNavigationDecision.prevent : WebNavigationDecision.navigate,
                            crossWindowEvents: [
                              CrossWindowEvent(
                                  name: 'Test',
                                  eventAction: (eventMessage) {
                                    print('Event message: $eventMessage');
                                  }),
                            ],
                            // width: 100,
                            // height: 100,
                          )),
                      Expanded(
                        flex: 1,
                        child: EasyWebView(
                          onLoaded: () {
                            print('$key2: Loaded: $src2');
                          },
                          src: src2,
                          isHtml: _isHtml,
                          isMarkdown: _isMarkdown,
                          convertToWidgets: _useWidgets,
                          widgetsTextSelectable: _isSelectable,
                          key: key2,
                          webNavigationDelegate: (_) => _blockNavigation ? WebNavigationDecision.prevent : WebNavigationDecision.navigate,
                          // width: 100,
                          // height: 100,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Expanded(
                        flex: 3,
                        child: Container(),
                      ),
                      Expanded(
                          flex: 1,
                          child: Container(
                            width: (open) ? 500 : 0,
                            child: EasyWebView(
                                src: src3,
                                onLoaded: () {
                                  print('$key3: Loaded: $src3');
                                },
                                isHtml: _isHtml,
                                isMarkdown: _isMarkdown,
                                convertToWidgets: _useWidgets,
                                widgetsTextSelectable: _isSelectable,
                                key: key3
                                // width: 100,
                                // height: 100,
                                ),
                          )),
                    ],
                  )
                ],
              ));
  }

  String get htmlContent => """
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1 plus MathML 2.0//EN" "http://www.w3.org/Math/DTD/mathml2/xhtml-math11-f.dtd"><html xmlns="http://www.w3.org/1999/xhtml"><!--This file was converted to xhtml by LibreOffice - see https://cgit.freedesktop.org/libreoffice/core/tree/filter/source/xslt for the code.--><head profile="http://dublincore.org/documents/dcmi-terms/"><meta http-equiv="Content-Type" content="application/xhtml+xml; charset=utf-8"/><title xml:lang="en-US">- no title specified</title><meta name="DCTERMS.title" content="" xml:lang="en-US"/><meta name="DCTERMS.language" content="en-US" scheme="DCTERMS.RFC4646"/><meta name="DCTERMS.source" content="http://xml.openoffice.org/odf2xhtml"/><meta name="DCTERMS.creator" content="Fruitful"/><meta name="DCTERMS.issued" content="2021-08-27T12:00:00" scheme="DCTERMS.W3CDTF"/><meta name="DCTERMS.modified" content="2021-09-01T13:53:22.543000000" scheme="DCTERMS.W3CDTF"/><meta name="DCTERMS.provenance" content="" xml:lang="en-US"/><meta name="DCTERMS.subject" content="," xml:lang="en-US"/><link rel="schema.DC" href="http://purl.org/dc/elements/1.1/" hreflang="en"/><link rel="schema.DCTERMS" href="http://purl.org/dc/terms/" hreflang="en"/><link rel="schema.DCTYPE" href="http://purl.org/dc/dcmitype/" hreflang="en"/><link rel="schema.DCAM" href="http://purl.org/dc/dcam/" hreflang="en"/><style type="text/css">
    @page {  }
    table { border-collapse:collapse; border-spacing:0; empty-cells:show }
    td, th { vertical-align:top; font-size:12pt;}
    h1, h2, h3, h4, h5, h6 { clear:both;}
    ol, ul { margin:0; padding:0;}
    li { list-style: none; margin:0; padding:0;}
    /* "li span.odfLiEnd" - IE 7 issue*/
    li span. { clear: both; line-height:0; width:0; height:0; margin:0; padding:0; }
    span.footnodeNumber { padding-right:1em; }
    span.annotation_style_by_filter { font-size:95%; font-family:Arial; background-color:#fff000;  margin:0; border:0; padding:0;  }
    span.heading_numbering { margin-right: 0.8rem; }* { margin:0;}
    .P1 { font-size:11pt; line-height:150%; margin-bottom:0.111in; margin-left:0.5in; margin-right:0in; margin-top:0in; text-align:left ! important; text-indent:0in; font-family:Calibri; writing-mode:horizontal-tb; direction:ltr; }
    .P10 { font-size:11pt; line-height:150%; margin-bottom:0.111in; margin-left:0in; margin-right:0in; margin-top:0in; text-align:left ! important; text-indent:0in; font-family:Calibri; writing-mode:horizontal-tb; direction:ltr; }
    .P11 { font-size:11pt; line-height:150%; margin-bottom:0.111in; margin-left:0in; margin-right:0in; margin-top:0in; text-align:left ! important; text-indent:0in; font-family:Times New Roman; writing-mode:horizontal-tb; direction:ltr; }
    .P12 { font-size:11pt; line-height:150%; margin-bottom:0.111in; margin-left:0in; margin-right:0in; margin-top:0in; text-align:left ! important; text-indent:0in; font-family:Calibri; writing-mode:horizontal-tb; direction:ltr; }
    .P13 { font-size:12pt; line-height:150%; margin-bottom:0.111in; margin-left:1in; margin-right:0in; margin-top:0in; text-align:left ! important; text-indent:0in; font-family:Times New Roman; writing-mode:horizontal-tb; direction:ltr; }
    .P14 { font-size:11pt; line-height:150%; margin-bottom:0.111in; margin-left:1in; margin-right:0in; margin-top:0in; text-align:left ! important; text-indent:0in; font-family:Times New Roman; writing-mode:horizontal-tb; direction:ltr; }
    .P15 { font-size:11pt; line-height:150%; margin-bottom:0.111in; margin-left:1.25in; margin-right:0in; margin-top:0in; text-align:left ! important; text-indent:0in; font-family:Times New Roman; writing-mode:horizontal-tb; direction:ltr; }
    .P16 { font-size:11pt; line-height:150%; margin-bottom:0.111in; margin-top:0in; text-align:left ! important; font-family:Calibri; writing-mode:horizontal-tb; direction:ltr; }
    .P17 { font-size:11pt; line-height:150%; margin-bottom:0.111in; margin-top:0in; text-align:center ! important; font-family:Calibri; writing-mode:horizontal-tb; direction:ltr; }
    .P18 { font-size:11pt; line-height:150%; margin-bottom:0.111in; margin-top:0in; text-align:left ! important; font-family:Times New Roman; writing-mode:horizontal-tb; direction:ltr; }
    .P19 { font-size:11pt; line-height:150%; margin-bottom:0.111in; margin-top:0in; text-align:left ! important; font-family:Calibri; writing-mode:horizontal-tb; direction:ltr; margin-left:0in; margin-right:0in; text-indent:0in; }
    .P2 { font-size:11pt; line-height:150%; margin-bottom:0.111in; margin-left:0.5in; margin-right:0in; margin-top:0in; text-align:left ! important; text-indent:0in; font-family:Calibri; writing-mode:horizontal-tb; direction:ltr; }
    .P3 { font-size:11pt; line-height:150%; margin-bottom:0.111in; margin-left:0.5in; margin-right:0in; margin-top:0in; text-align:left ! important; text-indent:0in; font-family:Calibri; writing-mode:horizontal-tb; direction:ltr; }
    .P4 { font-size:11pt; line-height:150%; margin-bottom:0.111in; margin-left:0.5in; margin-right:0in; margin-top:0in; text-align:left ! important; text-indent:0in; font-family:Calibri; writing-mode:horizontal-tb; direction:ltr; }
    .P5 { font-size:11pt; line-height:150%; margin-bottom:0.111in; margin-left:0.5in; margin-right:0in; margin-top:0in; text-align:left ! important; text-indent:0in; font-family:Calibri; writing-mode:horizontal-tb; direction:ltr; }
    .P6 { font-size:11pt; line-height:150%; margin-bottom:0.111in; margin-left:0.5in; margin-right:0in; margin-top:0in; text-align:left ! important; text-indent:0in; font-family:Calibri; writing-mode:horizontal-tb; direction:ltr; }
    .P7 { font-size:12pt; line-height:150%; margin-bottom:0.111in; margin-left:0.5in; margin-right:0in; margin-top:0in; text-align:left ! important; text-indent:0in; font-family:Times New Roman; writing-mode:horizontal-tb; direction:ltr; }
    .P8 { font-size:11pt; line-height:150%; margin-bottom:0.111in; margin-left:0.5in; margin-right:0in; margin-top:0in; text-align:left ! important; text-indent:0in; font-family:Times New Roman; writing-mode:horizontal-tb; direction:ltr; }
    .P9 { font-size:11pt; line-height:150%; margin-bottom:0.111in; margin-left:0.5in; margin-right:0in; margin-top:0in; text-align:left ! important; text-indent:0in; font-family:Calibri; writing-mode:horizontal-tb; direction:ltr; }
    .Bullet_20_Symbols { font-family:OpenSymbol; }
    .Internet_20_link { color:#0563c1; text-decoration:underline; }
    .T2 { font-family:Times New Roman; font-size:12pt; }
    .T3 { font-family:Times New Roman; font-size:12pt; }
    .T4 { font-family:Times New Roman; font-size:12pt; font-weight:bold; }
    /* ODF styles with no properties representable as CSS */
    .ListLabel_20_2 .ListLabel_20_3 .ListLabel_20_4 .ListLabel_20_5 .ListLabel_20_6 .ListLabel_20_7 .ListLabel_20_8 .ListLabel_20_9 .Numbering_20_Symbols  { }
    </style></head><body dir="ltr" style="max-width:8.2681in;margin-top:1in; margin-bottom:1in; margin-left:1.25in; margin-right:1in; "><p class="P17"><span class="T2">TERMS AND CONDITIONS FOR MAXITAG</span></p><ol><li><p class="P1" style="margin-left:1.27cm;"><span style="display:block;float:left;min-width:0.635cm;">1.</span><span class="T2">Introduction</span><span class="odfLiEnd"/> </p></li><li><p class="P2" style="margin-left:1.27cm;"><span style="display:block;float:left;min-width:0.635cm;">2.</span><span class="T2">Registration</span><span class="odfLiEnd"/> </p></li><li><p class="P2" style="margin-left:1.27cm;"><span style="display:block;float:left;min-width:0.635cm;">3.</span><span class="T2">Referrals</span><span class="odfLiEnd"/> </p></li><li><p class="P2" style="margin-left:1.27cm;"><span style="display:block;float:left;min-width:0.635cm;">4.</span><span class="T2">Sales/buying</span><span class="odfLiEnd"/> </p></li><li><p class="P2" style="margin-left:1.27cm;"><span style="display:block;float:left;min-width:0.635cm;">5.</span><span class="T2">Return of products</span><span class="odfLiEnd"/> </p></li><li><p class="P2" style="margin-left:1.27cm;"><span style="display:block;float:left;min-width:0.635cm;">6.</span><span class="T2">Payments</span><span class="odfLiEnd"/> </p></li><li><p class="P2" style="margin-left:1.27cm;"><span style="display:block;float:left;min-width:0.635cm;">7.</span><span class="T2">warranties</span><span class="odfLiEnd"/> </p></li><li><p class="P2" style="margin-left:1.27cm;"><span style="display:block;float:left;min-width:0.635cm;">8.</span><span class="T2">Use of website and applications</span><span class="odfLiEnd"/> </p></li><li><p class="P2" style="margin-left:1.27cm;"><span style="display:block;float:left;min-width:0.635cm;">9.</span><span class="T2">Copyrights and trademarks</span><span class="odfLiEnd"/> </p></li><li><p class="P2" style="margin-left:1.27cm;"><span style="display:block;float:left;min-width:0.635cm;">10.</span><span class="T2">Data privacy</span><span class="odfLiEnd"/> </p></li><li><p class="P2" style="margin-left:1.27cm;"><span style="display:block;float:left;min-width:0.635cm;">11.</span><span class="T2">Indemnification</span><span class="odfLiEnd"/> </p></li><li><p class="P2" style="margin-left:1.27cm;"><span style="display:block;float:left;min-width:0.635cm;">12.</span><span class="T2">Breach of our terms and conditions</span><span class="odfLiEnd"/> </p></li><li><p class="P2" style="margin-left:1.27cm;"><span style="display:block;float:left;min-width:0.635cm;">13.</span><span class="T2">Notice of change</span><span class="odfLiEnd"/> </p></li><li><p class="P2" style="margin-left:1.27cm;"><span style="display:block;float:left;min-width:0.635cm;">14.</span><span class="T2">Third party </span><span class="odfLiEnd"/> </p></li><li><p class="P2" style="margin-left:1.27cm;"><span style="display:block;float:left;min-width:0.635cm;">15.</span><span class="T2">Laws and jurisdiction</span><span class="odfLiEnd"/> </p></li><li><p class="P2" style="margin-left:1.27cm;"><span style="display:block;float:left;min-width:0.635cm;">16.</span><span class="T2">Our company details</span><span class="odfLiEnd"/> </p></li></ol><p class="P8"> </p><p class="P10"><span class="T4">INTRODUCTION</span></p><p class="P16"><span class="T2">MAXITAG LIMITED is a manufacturing and marketing company, registered in Nigeria, that operates an online affiliate marketing platform known as MAXITAG (www.maxitaglimited.com). People are at liberty to register to become affiliates and are hereafter referred to as “Distributors”. Distributors enjoy up to 30% discount when they use their promo code to make purchases or sales. The General terms and conditions applies both to Distributors and customers alike.</span></p><p class="P16"><span class="T2">By using this online market platform, it means you agree totally with these terms and conditions. And if for any reason you disagree with any of these terms and conditions, you should not use our online platform.</span></p><p class="P18"> </p><p class="P16"><span class="T4">REGISTRATION</span></p><ol><li><p class="P3" style="margin-left:1.27cm;"><span style="display:block;float:left;min-width:0.635cm;">a.</span><span class="T2">REGISTRATION AND MEMBERSHIP with our online platform is not open to persons under 1</span><span class="T3">3</span><span class="T2"> years old. In a situation where MAXITAG discovers that there is an underage registration, MAXITAG reserves the right to terminate such an account and cancel all the benefits accrued to it. In a case where a minor under the age of 1</span><span class="T3">3</span><span class="T2"> wishes to be a member, such registration can only be done by the parent or Legal guardian who is also a registered member of MAXITAG.</span><span class="odfLiEnd"/> </p></li><li><p class="P3" style="margin-left:1.27cm;"><span style="display:block;float:left;min-width:0.635cm;">b.</span><span class="T2">While you can freely browse through our website, you will require registration to make purchase as a customer and to further become a distributor with us.</span><span class="odfLiEnd"/> </p></li><li><p class="P3" style="margin-left:1.27cm;"><span style="display:block;float:left;min-width:0.635cm;">c.</span><span class="T2">While registration as a customer is free, further upgrade to a distributor comes with a fee of N10,000 (Ten thousand Naira) only.</span><span class="odfLiEnd"/> </p></li><li><p class="P3" style="margin-left:1.27cm;"><span style="display:block;float:left;min-width:0.635cm;">d.</span><span class="T2">You will be required to enter an e-mail and a password at the point of registration. You will also update your profile to further complete your registration either as a customer or Distributor.</span><span class="odfLiEnd"/> </p></li><li><p class="P3" style="margin-left:1.27cm;"><span style="display:block;float:left;min-width:0.635cm;">e.</span><span class="T2">By completing your registration, you affirm that the information you have given is accurate and up to date, and that you agree with our general terms and conditions as well as our privacy policy.</span><span class="odfLiEnd"/> </p></li><li><p class="P3" style="margin-left:1.27cm;"><span style="display:block;float:left;min-width:0.635cm;">f.</span><span class="T2">If discovered that you gave a misleading or false information, such account shall be suspended or terminated. And every benefit accruing to the account cancelled. </span><span class="odfLiEnd"/> </p></li></ol><p class="P7"> </p><p class="P10"><span class="T4">REFERRAL</span></p><p class="P16"><span class="T2">When a registration of a Distributor is completed via your referral link, a certain benefit accrues to you according to our structured bonus system. However, MAXITAG retains the right to review this benefit at any time as it deems necessary.</span></p><p class="P18"> </p><p class="P10"><span class="T4">SALES AND PURCHASES</span></p><p class="P16"><span class="T2">While sales can only be made by Distributors, purchases are made by both registered customer and Distributors.</span></p><p class="P16"><span class="T2">When a customer purchases an item using the promo code of a distributor, he /she will enjoy discount on the product of up to 30%.</span></p><p class="P11"> </p><p class="P10"><span class="T4">PAYMENTS</span></p><p class="P10"><span class="T2">While using any of the payment method(s) on our market platform, MAXITAG will not be responsible or assume any liability, whatsoever in respect of any loss or damage arising directly or indirectly to you due to payment issues arising out of such transactions. You shall approach your bank to rectify such issues.</span></p><p class="P8"> </p><p class="P10"><span class="T4">LOSS OR RETURN OF PRODUCTS AND REFUNDS</span></p><p class="P16"><span class="T2">MAXITAG shall take liability of products lost in transit or damaged in the course of shipment. Such products may be returned and another one resent to you. There shall be no refunds in such case.  In the event that the items are damaged after receipt, the risk falls on the customer.</span></p><p class="P16"><span class="T2">But in a situation where a product had been paid for, but was not available for shipment within a specific time, then the customer will be refunded the very amount paid for the product accordingly.</span></p><p class="P11"> </p><p class="P10"><span class="T4">WARRANTIES</span></p><p class="P16"><span class="T2">Products with specified warranties can be returned for repairs or outright replacement if issues arise from factory defects. MAXITAG reserves the right to investigate the cause of such damages and to determine whether it is a factory defect or a damage caused by the misuse of such product by the customer. In an event that it is determined that it was a damage caused by the customer, the customer will pay for the cost of repairs. </span></p><p class="P16"><span class="T2">Otherwise, every other product purchased on our online platform cannot be returned when delivered intact.</span></p><p class="P11"> </p><p class="P10"><span class="T4">USE OF WEBSITE AND APPLICATIONS</span></p><ul><li><p class="P6" style="margin-left:1.27cm;"><span class="Bullet_20_Symbols" style="display:block;float:left;min-width:0.635cm;">•</span><span class="T2">our website and application can only be used for the purpose of buying and selling of MAXITAG PRODUCTS. </span><span class="odfLiEnd"/> </p></li><li><p class="P6" style="margin-left:1.27cm;"><span class="Bullet_20_Symbols" style="display:block;float:left;min-width:0.635cm;">•</span><span class="T2">DISTRIBUTORS can share their link for registration and their promo codes for purchases.</span><span class="odfLiEnd"/> </p></li><li><p class="P6" style="margin-left:1.27cm;"><span class="Bullet_20_Symbols" style="display:block;float:left;min-width:0.635cm;">•</span><span class="T2">Distributors can advertise our products on various platforms. This product images will have their link attached to them.</span><span class="odfLiEnd"/> </p></li><li><p class="P6" style="margin-left:1.27cm;"><span class="Bullet_20_Symbols" style="display:block;float:left;min-width:0.635cm;">•</span><span class="T2">Besides the aforementioned, our website can only be used for purposes approved at any time by MAXITAG.</span><span class="odfLiEnd"/> </p></li><li><p class="P6" style="margin-left:1.27cm;"><span class="Bullet_20_Symbols" style="display:block;float:left;min-width:0.635cm;">•</span><span class="T2">Hence, any other use of the website, other than that mentioned above constitute a violation of this terms and conditions. And MAXITAG reserves the right to terminate or suspend such an account, with loss of any accrued benefits.</span><span class="odfLiEnd"/> </p></li><li><p class="P6" style="margin-left:1.27cm;"><span class="Bullet_20_Symbols" style="display:block;float:left;min-width:0.635cm;">•</span><span class="T2">Any use of the website or application for criminal activities or any other activity violating the extant laws, MAXITAG will be forced to report such a person to relevant authorities.</span><span class="odfLiEnd"/> </p></li><li><p class="P6" style="margin-left:1.27cm;"><span class="Bullet_20_Symbols" style="display:block;float:left;min-width:0.635cm;">•</span><span class="T2">Our online market platform contains only products sold in Nigeria. But we will upgrade to other countries later.</span><span class="odfLiEnd"/> </p></li><li><p class="P6" style="margin-left:1.27cm;"><span class="Bullet_20_Symbols" style="display:block;float:left;min-width:0.635cm;">•</span><span class="T2">You can either use our web address </span><a href="http://www.maxitaglimited.com/" class="Internet_20_link"><span class="Internet_20_link"><span class="T2">www.maxitaglimited.com</span></span></a><span class="T2"> on a browser or download the application from Google Play Store with the name MAXITAG.</span><span class="odfLiEnd"/> </p></li></ul><p class="P13"> </p><p class="P10"><span class="T4">COPYRIGHTS AND TRADEMARKS</span></p><p class="P16"><span class="T2">All material on our website, including documents, video clips, illustrations, audio clips, and images, are owned by MAXITAG LIMITED and are protected by copyrights, trademarks, and other intellectual property rights.</span></p><p class="P16"><span class="T2">MAXITAG logos and our other registered and unregistered trademarks are trademarks belonging to MAXITAG LIMITED; we therefore grant no permission for the use of these trademarks, and such use may constitute an infringement of our rights</span></p><p class="P16"><span class="T2"> You must not copy, republish, post, transmit or distribute such trademarks in any way whether directly or indirectly and you must not assist some other persons to do so. </span></p><p class="P11"> </p><p class="P10"><span class="T4">DATA PRIVACY</span></p><p class="P16"><span class="T2">Our data privacy is captured in our PRIVACY POLICY on our website. Using our website, means you totally agree with our privacy policy.</span></p><p class="P11"> </p><p class="P10"><span class="T4">INDEMNIFICATION</span></p><p class="P10"><span class="T2">You shall indemnify and keep indemnified MAXITAG LIMITED, its owners, subsidiaries, affiliates and their respective officers, directors, distributors, employees, from any claim or demand, or actions including legal expenses, made by you or any third party or penalty imposed due to or arising out of your use of the goods or services, or in the event you breach this Terms and conditions, the Privacy Policy and other laws, rules or regulations.</span></p><p class="P11"> </p><p class="P10"><span class="T4">BREACH OF TERMS AND CONDITIONS</span></p><p class="P16"><span class="T2">When you breach our terms and conditions or/and our policies, or we suspect that you have breached our terms and conditions, we may:</span></p><ol><li><p class="P4" style="margin-left:1.27cm;"><span style="display:block;float:left;min-width:1.27cm;">i.</span><span class="T2">Temporary suspend your account </span><span class="odfLiEnd"/> </p></li><li><p class="P4" style="margin-left:1.27cm;"><span style="display:block;float:left;min-width:1.27cm;">ii.</span><span class="T2">Permanently terminate your account, where you will lose all benefits accrued to you</span><span class="odfLiEnd"/> </p></li><li><p class="P4" style="margin-left:1.27cm;"><span style="display:block;float:left;min-width:1.27cm;">iii.</span><span class="T2">Report you to relevant government agencies and take strict legal actions against you</span><span class="odfLiEnd"/> </p></li><li><p class="P4" style="margin-left:1.27cm;"><span style="display:block;float:left;min-width:1.27cm;">iv.</span><span class="T2">Warn other users about your account.</span><span class="odfLiEnd"/> </p></li></ol><p class="P19"><span class="T2">You are not to circumvent your suspension, blocking or termination by fresh registration or impersonation as that will also make us institute further litigations against you. </span></p><p class="P11"> </p><p class="P10"><span class="T4">NOTICE OF CHANGE</span></p><p class="P19"><span class="T2">Maxitag Limited reserve the right to make changes or updates to this terms and conditions at any time the need arises without prior notification. It takes effect the moment it is updated on our web page.</span></p><p class="P11"> </p><p class="P10"><span class="T4">DISTRIBUTORS TERMS</span></p><ol><li><p class="P5" style="margin-left:1.27cm;"><span style="display:block;float:left;min-width:1.27cm;">i.</span><span class="T2">Every distributor has the right to buy and sell via his link on the platform.</span><span class="odfLiEnd"/> </p></li><li><p class="P5" style="margin-left:1.27cm;"><span style="display:block;float:left;min-width:1.27cm;">ii.</span><span class="T2">MAXITAG will only be responsible for the shipment of products that the distributors do not wish to take delivery of. </span><span class="odfLiEnd"/> </p></li><li><p class="P5" style="margin-left:1.27cm;"><span style="display:block;float:left;min-width:1.27cm;">iii.</span><span class="T2">In an event where the distributor takes delivery of the product from our store, he/she shall be liable for any damage afterwards.</span><span class="odfLiEnd"/> </p></li><li><p class="P5" style="margin-left:1.27cm;"><span style="display:block;float:left;min-width:1.27cm;">iv.</span><span class="T2">Every Distributor has a dashboard where he/she monitors the progress of his product order and shipment.</span><span class="odfLiEnd"/> </p></li><li><p class="P5" style="margin-left:1.27cm;"><span style="display:block;float:left;min-width:1.27cm;">v.</span><span class="T2">Distributors can also monitor all their income and bonuses accrued to them both from referral bonuses, sales profits and sales bonuses. </span><span class="odfLiEnd"/> </p></li></ol><p class="P15"> </p><p class="P10"><span class="T4">TERMINATION OF SALES</span></p><p class="P9"><span class="T2">MAXITAG reserves the absolute right to modify or stop the sale of part or all our goods and services with or without prior notification. You hereby agree that MAXITAG will under no circumstance be held liable by you or any third party for any modification or discontinuance of sales of goods or services on our website</span></p><p class="P14"> </p><p class="P10"><span class="T4">THIRD PARTY</span></p><p class="P9"><span class="T2">A contract under these terms and conditions is for our mutual benefit, and is not intended for any third party.</span></p><p class="P7"> </p><p class="P10"><span class="T4">JURISDICTION AND LEGAL MATTERS</span></p><p class="P9"><span class="T2">The content of this terms and condition shall be governed by the laws of the Federal Republic of Nigeria. Any dispute resolution shall be handled by a court with such jurisdiction here in Nigeria.</span></p><p class="P7"> </p><p class="P10"><span class="T4">OUR CONTACT</span></p><p class="P10"><span class="T2">You can reach out to us via e-mail at …………………………………</span></p><p class="P12"><span class="T2">Phone: 08148082797</span></p></body></html>
""";

  String get htmlContentx => """
<!DOCTYPE html>
<html>
<head>
<title>Page Title</title>
</head>
<body>
<h1>This is a Heading</h1>
<p>This is a paragraph.</p>
</body>
</html>
""";

  String get markdownContent => """
# This is a heading
## Here's a smaller heading
This is a paragraph
* Here's a bulleted list
* Another item
1. And an ordered list
1. The numbers don't matter
> This is a qoute
[This is a link to Flutter](https://flutter.dev)
""";

  String get embeedHtml => """
<iframe width="560" height="315" src="https://www.youtube.com/embed/rtBkU4pvHcw?controls=0" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
""";

  String get url => 'https://flutter.dev';

  String summernoteHtml = '''
<html>
  <head>
    <meta charset="UTF-8">
    <script src="https://code.jquery.com/jquery-3.4.1.slim.min.js" integrity="sha384-J6qa4849blE2+poT4WnyKhv5vZF5SrPo0iEjwBvKU7imGFAV0wwj1yYfoRSJoZ+n" crossorigin="anonymous"></script>
    <link href="https://cdn.jsdelivr.net/npm/summernote@0.8.18/dist/summernote-lite.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/summernote@0.8.18/dist/summernote-lite.min.js"></script>
  </head>
  <body>
    <div id="summernote"></div>
    <script>
    window.onload = function () {
      \$('#summernote').summernote({
        height: 400,
        tabsize: 2,
        callbacks: {
          onChange: function() {
            \$('#html-content').text(\$('#summernote').summernote('code'));
            
            window.parent.postMessage(\$('#summernote').summernote('code'), '*');
            if (window.Test != null) {
              window.Test.postMessage(\$('#summernote').summernote('code'));
            }
          }
        },
        toolbar: [
          ['style', ['style']],
          ['font', ['bold', 'underline', 'clear']],
          ['color', ['color']],
          ['para', ['ul', 'ol', 'paragraph']],
          ['table', ['table']],
          ['insert', ['link', 'picture']],
          ['view', ['codeview']]
        ]
      });
    }
    </script>
    <div id="html-content" style="display: none"></div>
  </body>
</html>
''';
}
