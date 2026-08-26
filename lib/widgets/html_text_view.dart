// import 'package:flutter/material.dart';
// import 'package:flutter_html/flutter_html.dart';
// import 'package:flutter_html_table/flutter_html_table.dart';
// import 'package:club_fitness/core/services/url_services.dart';
// import 'package:club_fitness/core/themes/theme.dart';

// class HtmlTextView extends StatelessWidget {
//   final String htmlContent;
//   final double? height;
//   final TextStyle? defaultStyle;
//   final TextAlign? textAlign;
//   final Color? textColor;
//   final Color? tableHeaderColor;
//   final Color? tableBorderColor;

//   const HtmlTextView(
//     this.htmlContent, {
//     super.key,
//     this.height,
//     this.defaultStyle,
//     this.textAlign,
//     this.textColor,
//     this.tableHeaderColor,
//     this.tableBorderColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: height,
//       child: Html(
//         data: htmlContent,
//         extensions: [const TableHtmlExtension()],
//         onLinkTap: (url, attributes, element) {
//           if (url == null) return;
//           UrlServices.launchRegularUrl(url);
//         },
//         style: {
//           "table": Style(width: Width.auto()),
//           "th": Style(
//             padding: HtmlPaddings.all(8),
//             backgroundColor: tableHeaderColor ?? Colors.grey.shade200,
//             border: Border.all(
//               color: tableBorderColor ?? Colors.grey,
//               width: 1,
//             ),
//             fontWeight: FontWeight.bold,
//           ),
//           "td": Style(
//             padding: HtmlPaddings.all(8),
//             border: Border.all(
//               color: tableBorderColor ?? Colors.grey,
//               width: 1,
//             ),
//           ),
//           "body": Style(
//             margin: Margins.zero,
//             padding: HtmlPaddings.zero,
//             color: textColor,
//           ),
//           "p": Style(
//             margin: Margins.only(bottom: 12),
//             fontSize: FontSize.medium,
//             textAlign: textAlign,
//             color: textColor,
//           ),
//           "li": Style(
//             margin: Margins.only(bottom: 8),
//             textAlign: textAlign,
//             color: textColor,
//           ),
//           "ol": Style(
//             padding: HtmlPaddings.symmetric(horizontal: 16),
//             textAlign: textAlign,
//             color: textColor,
//           ),
//           "ul": Style(
//             padding: HtmlPaddings.symmetric(horizontal: 16),
//             textAlign: textAlign,
//             color: textColor,
//           ),
//           "b": Style(fontWeight: FontWeight.bold, color: textColor),
//           "strong": Style(fontWeight: FontWeight.bold, color: textColor),

//           // Add these missing styles inside your existing style map:
//           "h3": Style(
//             fontSize: FontSize.large,
//             fontWeight: FontWeight.bold,
//             color: textColor,
//             margin: Margins.only(top: 16, bottom: 8),
//           ),
//           "h4": Style(
//             fontSize: FontSize.medium,
//             fontWeight: FontWeight.bold,
//             color: textColor,
//           ),
//           "hr": Style(margin: Margins.symmetric(vertical: 16)),
//           "a": Style(
//             color: RColors.primary,
//             textDecoration: TextDecoration.underline,
//           ),
//           "blockquote": Style(
//             padding: HtmlPaddings.only(left: 12),
//             border: const Border(
//               left: BorderSide(color: RColors.primaryDim, width: 3),
//             ),
//             color: RColors.textSecondary,
//             fontStyle: FontStyle.italic,
//           ),

//           // Also tighten up heading margins for document-style content:
//           "h1": Style(
//             fontSize: FontSize.xxLarge,
//             fontWeight: FontWeight.bold,
//             color: textColor,
//             margin: Margins.only(
//               top: 0,
//               bottom: 12,
//             ), // top: 0 for the first heading
//           ),
//           "h2": Style(
//             fontSize: FontSize.xLarge,
//             fontWeight: FontWeight.bold,
//             color: textColor,
//             margin: Margins.only(top: 20, bottom: 8),
//           ),
//         },
//         shrinkWrap: true,
//       ),
//     );
//   }
// }

// class HtmlExpandableText extends StatefulWidget {
//   final String htmlContent;
//   final TextStyle? defaultStyle;
//   final TextAlign? textAlign;
//   final CrossAxisAlignment? crossAxisAlignment;
//   final Color? textColor;
//   final double collapsedHeight;
//   final Color? tableHeaderColor;
//   final Color? tableBorderColor;

//   const HtmlExpandableText(
//     this.htmlContent, {
//     super.key,
//     this.defaultStyle,
//     this.textAlign,
//     this.crossAxisAlignment,
//     this.textColor,
//     this.collapsedHeight = 100,
//     this.tableHeaderColor,
//     this.tableBorderColor,
//   });

//   @override
//   State<HtmlExpandableText> createState() => _HtmlExpandableTextState();
// }

// class _HtmlExpandableTextState extends State<HtmlExpandableText> {
//   final GlobalKey _htmlKey = GlobalKey();
//   bool _expanded = false;
//   double? _fullHeight;
//   double _collapsedHeight = 100; // Approx. 4 lines height

//   @override
//   void initState() {
//     _collapsedHeight = widget.collapsedHeight;
//     super.initState();
//     // Delay height calculation to next frame
//     WidgetsBinding.instance.addPostFrameCallback((_) => _measureFullHeight());
//   }

//   void _measureFullHeight() {
//     final context = _htmlKey.currentContext;
//     if (context == null) return;
//     final box = context.findRenderObject() as RenderBox?;
//     if (box != null && mounted) {
//       setState(() {
//         _fullHeight = box.size.height;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final double maxHeight = _expanded
//         ? (_fullHeight ?? double.infinity)
//         : _collapsedHeight;
//     return Column(
//       crossAxisAlignment: widget.crossAxisAlignment ?? CrossAxisAlignment.start,
//       children: [
//         AnimatedContainer(
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeInOut,
//           constraints: BoxConstraints(maxHeight: maxHeight),
//           child: SingleChildScrollView(
//             physics: const NeverScrollableScrollPhysics(),
//             child: Html(
//               key: _htmlKey,
//               extensions: [const TableHtmlExtension()],
//               data: widget.htmlContent,
//               shrinkWrap: true,
//               onLinkTap: (url, attributes, element) {
//                 if (url == null) return;
//                 UrlServices.launchRegularUrl(url);
//               },
//               style: {
//                 "table": Style(width: Width.auto()),
//                 "th": Style(
//                   padding: HtmlPaddings.all(8),
//                   backgroundColor:
//                       widget.tableHeaderColor ?? Colors.grey.shade200,
//                   border: Border.all(
//                     color: widget.tableBorderColor ?? Colors.grey,
//                     width: 1,
//                   ),
//                   fontWeight: FontWeight.bold,
//                 ),
//                 "td": Style(
//                   padding: HtmlPaddings.all(8),
//                   border: Border.all(
//                     color: widget.tableBorderColor ?? Colors.grey,
//                     width: 1,
//                   ),
//                 ),
//                 "body": Style(
//                   margin: Margins.zero,
//                   padding: HtmlPaddings.zero,
//                   color: widget.textColor,
//                 ),
//                 "p": Style(
//                   margin: Margins.only(bottom: 12),
//                   fontSize: FontSize.medium,
//                   textAlign: widget.textAlign,
//                   color: widget.textColor,
//                 ),
//                 "li": Style(
//                   margin: Margins.only(bottom: 8),
//                   textAlign: widget.textAlign,
//                   color: widget.textColor,
//                 ),
//                 "ol": Style(
//                   padding: HtmlPaddings.symmetric(horizontal: 16),
//                   textAlign: widget.textAlign,
//                   color: widget.textColor,
//                 ),
//                 "ul": Style(
//                   padding: HtmlPaddings.symmetric(horizontal: 16),
//                   textAlign: widget.textAlign,
//                   color: widget.textColor,
//                 ),

//                 // Add these missing styles inside your existing style map:
//                 "h3": Style(
//                   fontSize: FontSize.large,
//                   fontWeight: FontWeight.bold,
//                   color: widget.textColor,
//                   margin: Margins.only(top: 16, bottom: 8),
//                 ),
//                 "h4": Style(
//                   fontSize: FontSize.medium,
//                   fontWeight: FontWeight.bold,
//                   color: widget.textColor,
//                 ),
//                 "hr": Style(margin: Margins.symmetric(vertical: 16)),
//                 "a": Style(
//                   color: RColors.primary,
//                   textDecoration: TextDecoration.underline,
//                 ),
//                 "blockquote": Style(
//                   padding: HtmlPaddings.only(left: 12),
//                   border: const Border(
//                     left: BorderSide(color: RColors.primaryDim, width: 3),
//                   ),
//                   color: RColors.textSecondary,
//                   fontStyle: FontStyle.italic,
//                 ),

//                 // Also tighten up heading margins for document-style content:
//                 "h1": Style(
//                   fontSize: FontSize.xxLarge,
//                   fontWeight: FontWeight.bold,
//                   color: widget.textColor,
//                   margin: Margins.only(
//                     top: 0,
//                     bottom: 12,
//                   ), // top: 0 for the first heading
//                 ),
//                 "h2": Style(
//                   fontSize: FontSize.xLarge,
//                   fontWeight: FontWeight.bold,
//                   color: widget.textColor,
//                   margin: Margins.only(top: 20, bottom: 8),
//                 ),
//                 "b": Style(
//                   fontWeight: FontWeight.bold,
//                   color: widget.textColor,
//                 ),
//                 "strong": Style(
//                   fontWeight: FontWeight.bold,
//                   color: widget.textColor,
//                 ),
//               },
//             ),
//           ),
//         ),
//         if (_fullHeight != null && _fullHeight! > _collapsedHeight)
//           GestureDetector(
//             onTap: () => setState(() => _expanded = !_expanded),
//             child: Padding(
//               padding: const EdgeInsets.only(top: 8),
//               child: Text(
//                 _expanded ? "Read Less" : "Read More",
//                 style: const TextStyle(
//                   color: RColors.primary,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//       ],
//     );
//   }
// }

// class MultiExpandableHtmlText extends StatefulWidget {
//   final String htmlContent;
//   final TextStyle? defaultStyle;
//   final TextAlign? textAlign;
//   final CrossAxisAlignment? crossAxisAlignment;
//   final Color? textColor;
//   final double collapsedHeight;
//   final Color? tableHeaderColor;
//   final Color? tableBorderColor;

//   const MultiExpandableHtmlText(
//     this.htmlContent, {
//     super.key,
//     this.defaultStyle,
//     this.textAlign,
//     this.crossAxisAlignment,
//     this.textColor,
//     this.collapsedHeight = 100,
//     this.tableHeaderColor,
//     this.tableBorderColor,
//   });

//   @override
//   State<MultiExpandableHtmlText> createState() =>
//       _MultiExpandableHtmlTextState();
// }

// class _MultiExpandableHtmlTextState extends State<MultiExpandableHtmlText> {
//   final GlobalKey _htmlKey = GlobalKey();
//   double? _fullHeight;
//   double _currentHeight = 0;

//   @override
//   void initState() {
//     super.initState();
//     _currentHeight = widget.collapsedHeight;
//     WidgetsBinding.instance.addPostFrameCallback((_) => _measureFullHeight());
//   }

//   void _measureFullHeight() {
//     final context = _htmlKey.currentContext;
//     if (context == null) return;
//     final box = context.findRenderObject() as RenderBox?;
//     if (box != null && mounted) {
//       setState(() {
//         _fullHeight = box.size.height;
//         // If the full content is shorter than the initial collapsed height,
//         // just show it all immediately.
//         if (_fullHeight! <= widget.collapsedHeight) {
//           _currentHeight = _fullHeight!;
//         }
//       });
//     }
//   }

//   bool get _isFullyExpanded =>
//       _fullHeight != null && _currentHeight >= _fullHeight!;

//   bool get _needsExpandButton =>
//       _fullHeight != null && _fullHeight! > widget.collapsedHeight;

//   void _expandOneStep() {
//     if (_fullHeight == null) return;
//     setState(() {
//       final next = _currentHeight + (widget.collapsedHeight * 2);
//       // Clamp to full height so we never overshoot.
//       _currentHeight = next > _fullHeight! ? _fullHeight! : next;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: widget.crossAxisAlignment ?? CrossAxisAlignment.start,
//       children: [
//         AnimatedContainer(
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeInOut,
//           constraints: BoxConstraints(maxHeight: _currentHeight),
//           child: SingleChildScrollView(
//             physics: const NeverScrollableScrollPhysics(),
//             child: Html(
//               key: _htmlKey,
//               extensions: const [TableHtmlExtension()],
//               data: widget.htmlContent,
//               shrinkWrap: true,
//               onLinkTap: (url, attributes, element) {
//                 if (url == null) return;
//                 UrlServices.launchRegularUrl(url);
//               },
//               style: {
//                 "table": Style(width: Width.auto()),
//                 "th": Style(
//                   padding: HtmlPaddings.all(8),
//                   backgroundColor:
//                       widget.tableHeaderColor ?? Colors.grey.shade200,
//                   border: Border.all(
//                     color: widget.tableBorderColor ?? Colors.grey,
//                     width: 1,
//                   ),
//                   fontWeight: FontWeight.bold,
//                 ),
//                 "td": Style(
//                   padding: HtmlPaddings.all(8),
//                   border: Border.all(
//                     color: widget.tableBorderColor ?? Colors.grey,
//                     width: 1,
//                   ),
//                 ),
//                 "body": Style(
//                   margin: Margins.zero,
//                   padding: HtmlPaddings.zero,
//                   color: widget.textColor,
//                 ),
//                 "p": Style(
//                   margin: Margins.only(bottom: 12),
//                   fontSize: FontSize.medium,
//                   textAlign: widget.textAlign,
//                   color: widget.textColor,
//                 ),
//                 "li": Style(
//                   margin: Margins.only(bottom: 8),
//                   textAlign: widget.textAlign,
//                   color: widget.textColor,
//                 ),
//                 "ol": Style(
//                   padding: HtmlPaddings.symmetric(horizontal: 16),
//                   textAlign: widget.textAlign,
//                   color: widget.textColor,
//                 ),
//                 "ul": Style(
//                   padding: HtmlPaddings.symmetric(horizontal: 16),
//                   textAlign: widget.textAlign,
//                   color: widget.textColor,
//                 ),

//                 // Add these missing styles inside your existing style map:
//                 "h3": Style(
//                   fontSize: FontSize.large,
//                   fontWeight: FontWeight.bold,
//                   color: widget.textColor,
//                   margin: Margins.only(top: 16, bottom: 8),
//                 ),
//                 "h4": Style(
//                   fontSize: FontSize.medium,
//                   fontWeight: FontWeight.bold,
//                   color: widget.textColor,
//                 ),
//                 "hr": Style(margin: Margins.symmetric(vertical: 16)),
//                 "a": Style(
//                   color: RColors.primary,
//                   textDecoration: TextDecoration.underline,
//                 ),
//                 "blockquote": Style(
//                   padding: HtmlPaddings.only(left: 12),
//                   border: const Border(
//                     left: BorderSide(color: RColors.primaryDim, width: 3),
//                   ),
//                   color: RColors.textSecondary,
//                   fontStyle: FontStyle.italic,
//                 ),

//                 // Also tighten up heading margins for document-style content:
//                 "h1": Style(
//                   fontSize: FontSize.xxLarge,
//                   fontWeight: FontWeight.bold,
//                   color: widget.textColor,
//                   margin: Margins.only(
//                     top: 0,
//                     bottom: 12,
//                   ), // top: 0 for the first heading
//                 ),
//                 "h2": Style(
//                   fontSize: FontSize.xLarge,
//                   fontWeight: FontWeight.bold,
//                   color: widget.textColor,
//                   margin: Margins.only(top: 20, bottom: 8),
//                 ),
//                 "b": Style(
//                   fontWeight: FontWeight.bold,
//                   color: widget.textColor,
//                 ),
//                 "strong": Style(
//                   fontWeight: FontWeight.bold,
//                   color: widget.textColor,
//                 ),
//               },
//             ),
//           ),
//         ),
//         if (_needsExpandButton && !_isFullyExpanded)
//           GestureDetector(
//             onTap: _expandOneStep,
//             child: const Padding(
//               padding: EdgeInsets.only(top: 8),
//               child: Text(
//                 "Read More",
//                 style: TextStyle(
//                   color: RColors.primary,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//       ],
//     );
//   }
// }
