// import 'package:flutter/material.dart';
// import 'package:flutter_quill/flutter_quill.dart';
// import 'package:club_fitness/config/navigation/routes_class.dart';
// import 'package:club_fitness/core/constants/constants.dart';
// import 'package:club_fitness/core/themes/theme.dart';
// import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';

// class FullscreenDescriptionEditor extends StatefulWidget {
//   final QuillController controller;
//   final void Function(String html) onDone;
//   final String placeholder, title;

//   const FullscreenDescriptionEditor({
//     super.key,
//     required this.controller,
//     required this.onDone,
//     required this.placeholder,
//     required this.title,
//   });

//   @override
//   State<FullscreenDescriptionEditor> createState() =>
//       _FullscreenDescriptionEditorState();
// }

// class _FullscreenDescriptionEditorState
//     extends State<FullscreenDescriptionEditor> {
//   late QuillController _tempController;
//   final FocusNode _focusNode = FocusNode();

//   @override
//   void initState() {
//     super.initState();
//     // Create a temporary controller with the same document
//     _tempController = QuillController(
//       document: Document.fromJson(
//         widget.controller.document.toDelta().toJson(),
//       ),
//       selection: widget.controller.selection,
//     );
//   }

//   @override
//   void dispose() {
//     _focusNode.dispose();
//     _tempController.dispose();
//     super.dispose();
//   }

//   String _convertToHtml() {
//     final delta = _tempController.document.toDelta();
//     final html = QuillDeltaToHtmlConverter(delta.toJson()).convert();
//     return html;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.close, color: RColors.textPrimary, size: 24.w),
//           onPressed: () => context.pop(),
//         ),
//         title: Text(
//           widget.title,
//           style: FontConstant.oxygenMediumBold.copyWith(
//             fontSize: 18.w,
//             color: RColors.textPrimary,
//           ),
//         ),
//         actions: [
//           TextButton.icon(
//             onPressed: () {
//               final html = _convertToHtml();
//               widget.onDone(html);
//               context.pop();
//             },
//             icon: Icon(Icons.check, color: RColors.primary, size: 20.w),
//             label: Text(
//               'Done',
//               style: FontConstant.oxygenMediumBold.copyWith(
//                 color: RColors.primary,
//               ),
//             ),
//           ),
//           16.w.width,
//         ],
//       ),
//       body: SafeArea(
//         child: Column(
//           children: [
//             Divider(height: 1, color: Colors.grey.shade200),
//             Expanded(
//               child: Container(
//                 margin: EdgeInsets.all(16.w),
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade50,
//                   borderRadius: BorderRadius.circular(12.w),
//                   border: Border.all(color: Colors.grey.shade200, width: 1),
//                 ),
//                 child: Column(
//                   children: [
//                     Expanded(
//                       child: QuillEditor(
//                         focusNode: _focusNode,
//                         scrollController: ScrollController(),
//                         controller: _tempController,
//                         config: QuillEditorConfig(
//                           placeholder: widget.placeholder,
//                           textInputAction: TextInputAction.newline,
//                           textCapitalization: TextCapitalization.sentences,
//                           padding: const EdgeInsets.all(16),
//                         ),
//                       ),
//                     ),
//                     Container(
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.only(
//                           bottomLeft: Radius.circular(12.w),
//                           bottomRight: Radius.circular(12.w),
//                         ),
//                         border: Border(
//                           top: BorderSide(
//                             color: Colors.grey.shade200,
//                             width: 1,
//                           ),
//                         ),
//                       ),

//                       child: QuillSimpleToolbar(
//                         controller: _tempController,
//                         config: const QuillSimpleToolbarConfig(
//                           multiRowsDisplay: false,
//                           showAlignmentButtons: true,

//                           // buttonOptions: QuillSimpleToolbarButtonOptions(
//                           //   bold: QuillToolbarToggleStyleButtonOptions(
//                           //     iconData: FlaticonRoundedIcons.srBold,
//                           //   ),
//                           //   italic: QuillToolbarToggleStyleButtonOptions(
//                           //     iconData: FlaticonRoundedIcons.srItalic,
//                           //   ),
//                           //   underLine: QuillToolbarToggleStyleButtonOptions(
//                           //     iconData: FlaticonRoundedIcons.srUnderline,
//                           //   ),
//                           //   strikeThrough: QuillToolbarToggleStyleButtonOptions(
//                           //     iconData: FlaticonRoundedIcons.srStrikethrough,
//                           //   ),
//                           //   inlineCode: QuillToolbarToggleStyleButtonOptions(
//                           //     iconData: FlaticonRoundedIcons.srCodeSimple,
//                           //   ),
//                           //   subscript: QuillToolbarToggleStyleButtonOptions(
//                           //     iconData: FlaticonRoundedIcons.srSubscript,
//                           //   ),
//                           //   superscript: QuillToolbarToggleStyleButtonOptions(
//                           //     iconData: FlaticonRoundedIcons.srSuperscript,
//                           //   ),
//                           //   listBullets: QuillToolbarToggleStyleButtonOptions(
//                           //     iconData: FlaticonRoundedIcons.srList,
//                           //   ),
//                           //   listNumbers: QuillToolbarToggleStyleButtonOptions(
//                           //     iconData: FlaticonRoundedIcons.srHastag,
//                           //   ),
//                           //   toggleCheckList:
//                           //       QuillToolbarToggleCheckListButtonOptions(
//                           //         iconData: FlaticonRoundedIcons.srListCheck,
//                           //       ),
//                           //   codeBlock: QuillToolbarToggleStyleButtonOptions(
//                           //     iconData: FlaticonRoundedIcons.srFileCode,
//                           //   ),
//                           //   quote: QuillToolbarToggleStyleButtonOptions(
//                           //     iconData: FlaticonRoundedIcons.srQuoteRight,
//                           //   ),
//                           //   indentIncrease: QuillToolbarIndentButtonOptions(
//                           //     iconData: FlaticonRoundedIcons.srIndent,
//                           //   ),
//                           //   indentDecrease: QuillToolbarIndentButtonOptions(
//                           //     iconData: FlaticonRoundedIcons.srOutdent,
//                           //   ),
//                           //   linkStyle: QuillToolbarLinkStyleButtonOptions(
//                           //     iconData: FlaticonRoundedIcons.srLink,
//                           //   ),
//                           //   search: QuillToolbarSearchButtonOptions(
//                           //     iconData: FlaticonRoundedIcons.srSearch,
//                           //   ),
//                           //   undoHistory: QuillToolbarHistoryButtonOptions(
//                           //     iconData: FlaticonRoundedIcons.srUndo,
//                           //   ),
//                           //   redoHistory: QuillToolbarHistoryButtonOptions(
//                           //     iconData: FlaticonRoundedIcons.srRedo,
//                           //   ),
//                           //   clearFormat: QuillToolbarClearFormatButtonOptions(
//                           //     iconData: FlaticonRoundedIcons.srTextSlash,
//                           //   ),
//                           //   color: QuillToolbarColorButtonOptions(
//                           //     iconData: FlaticonRoundedIcons.srPalette,
//                           //   ),
//                           //   backgroundColor: QuillToolbarColorButtonOptions(
//                           //     iconData: FlaticonRoundedIcons.srFill,
//                           //   ),
//                           //   selectAlignmentButtons:
//                           //       QuillToolbarSelectAlignmentButtonOptions(
//                           //         iconsData: QuillSelectAlignmentValues(
//                           //           leftAlignment:
//                           //               FlaticonRoundedIcons.srAlignLeft,
//                           //           centerAlignment:
//                           //               FlaticonRoundedIcons.srAlignCenter,
//                           //           rightAlignment:
//                           //               FlaticonRoundedIcons.srSymbol,
//                           //           justifyAlignment:
//                           //               FlaticonRoundedIcons.srAlignJustify,
//                           //         ),
//                           //       ),
//                           //   selectHeaderStyleDropdownButton:
//                           //       QuillToolbarSelectHeaderStyleDropdownButtonOptions(
//                           //         iconData: FlaticonRoundedIcons.srHeading,
//                           //       ),
//                           // ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
