// import 'package:flutter/material.dart';
// import 'package:flutter_quill/flutter_quill.dart';
// import 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';
// import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';
// import 'package:animations/animations.dart';

// import 'common_widgets.dart';

// // ─────────────────────────────────────────────
// // QuillHtmlEditor
// // ─────────────────────────────────────────────

// /// A rich-text editor backed by [flutter_quill] that:
// ///  • Accepts initial content as an HTML string
// ///  • Exposes [getHtml] to read back the current content as HTML
// ///  • Shows a full-screen button that opens the editor in a new
// ///    route using [OpenItem] / [OpenContainer] (shared controller)
// ///
// /// Parameters
// /// ----------
// /// [height]        – Fixed height of the collapsed editor (px).
// /// [initialHtml]   – Optional HTML to pre-populate the editor.
// /// [onHtmlChanged] – Called with the latest HTML whenever the delta changes.
// /// [readOnly]      – If true the toolbar is hidden and editing is disabled.
// class QuillHtmlEditor extends StatefulWidget {
//   final double height;
//   final String? initialHtml;
//   final ValueChanged<String>? onHtmlChanged;
//   final bool readOnly;
//   final String placeholder;

//   const QuillHtmlEditor({
//     super.key,
//     required this.height,
//     this.initialHtml,
//     this.onHtmlChanged,
//     this.readOnly = false,
//     this.placeholder = 'Start typing…',
//   });

//   @override
//   State<QuillHtmlEditor> createState() => _QuillHtmlEditorState();
// }

// class _QuillHtmlEditorState extends State<QuillHtmlEditor> {
//   late final QuillController _controller;
//   final FocusNode _focusNode = FocusNode();

//   // ── lifecycle ──────────────────────────────

//   @override
//   void initState() {
//     super.initState();
//     _controller = _buildController(widget.initialHtml);
//     _controller.addListener(_onDeltaChanged);
//   }

//   QuillController _buildController(String? html) {
//     if (html == null || html.trim().isEmpty) {
//       return QuillController.basic();
//     }
//     final ops = HtmlToDelta().convert(html);
//     final doc = Document.fromDelta(ops);
//     return QuillController(
//       document: doc,
//       selection: const TextSelection.collapsed(offset: 0),
//     );
//   }

//   void _onDeltaChanged() {
//     widget.onHtmlChanged?.call(_toHtml());
//   }

//   String _toHtml() {
//     final delta = _controller.document.toDelta();
//     final converter = QuillDeltaToHtmlConverter(
//       delta.toJson().cast<Map<String, dynamic>>(),
//       ConverterOptions.forEmail(),
//     );
//     return converter.convert();
//   }

//   /// Public API – call this to get the current HTML from outside.
//   String getHtml() => _toHtml();

//   @override
//   void dispose() {
//     _controller.removeListener(_onDeltaChanged);
//     _controller.dispose();
//     _focusNode.dispose();
//     super.dispose();
//   }

//   // ── build ───────────────────────────────────

//   @override
//   Widget build(BuildContext context) {
//     return _CollapsedEditor(
//       height: widget.height,
//       controller: _controller,
//       focusNode: _focusNode,
//       readOnly: widget.readOnly,
//       toHtml: _toHtml,
//       placeholder: widget.placeholder,
//     );
//   }
// }

// // ─────────────────────────────────────────────
// // _CollapsedEditor  (the "closed" view)
// // ─────────────────────────────────────────────
// class _CollapsedEditor extends StatelessWidget {
//   final double height;
//   final QuillController controller;
//   final FocusNode focusNode;
//   final bool readOnly;
//   final String Function() toHtml;
//   final String placeholder;

//   const _CollapsedEditor({
//     required this.height,
//     required this.controller,
//     required this.focusNode,
//     required this.readOnly,
//     required this.toHtml,
//     required this.placeholder,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;

//     return Container(
//       decoration: BoxDecoration(
//         border: Border.all(color: colorScheme.outlineVariant),
//         borderRadius: BorderRadius.circular(12),
//         color: colorScheme.surface,
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // ── toolbar row ────────────────────
//           if (!readOnly)
//             _ToolbarRow(
//               controller: controller,
//               // Full-screen button sits at the right end of the toolbar
//               trailing: _FullScreenButton(
//                 controller: controller,
//                 focusNode: focusNode,
//                 readOnly: readOnly,
//                 placeholder: placeholder,
//               ),
//             ),

//           // ── editor body ────────────────────
//           SizedBox(
//             height: height,
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 12),
//               child: QuillEditor.basic(
//                 controller: controller,
//                 focusNode: focusNode,
//                 config: QuillEditorConfig(
//                   placeholder: placeholder,
//                   padding: const EdgeInsets.symmetric(vertical: 8),
//                   autoFocus: false,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// // _ToolbarRow
// // ─────────────────────────────────────────────
// class _ToolbarRow extends StatelessWidget {
//   final QuillController controller;
//   final Widget trailing;

//   const _ToolbarRow({required this.controller, required this.trailing});

//   @override
//   Widget build(BuildContext context) {
//     return DecoratedBox(
//       decoration: BoxDecoration(
//         border: Border(
//           bottom: BorderSide(
//             color: Theme.of(context).colorScheme.outlineVariant,
//           ),
//         ),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: QuillSimpleToolbar(
//               controller: controller,
//               config: const QuillSimpleToolbarConfig(
//                 showAlignmentButtons: true,
//                 showColorButton: true,
//                 showBackgroundColorButton: true,
//                 multiRowsDisplay: false,
//               ),
//             ),
//           ),
//           trailing,
//           const SizedBox(width: 4),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// // _FullScreenButton  (uses OpenItem)
// // ─────────────────────────────────────────────
// class _FullScreenButton extends StatelessWidget {
//   final QuillController controller;
//   final FocusNode focusNode;
//   final bool readOnly;
//   final String placeholder;

//   const _FullScreenButton({
//     required this.controller,
//     required this.focusNode,
//     required this.readOnly,
//     required this.placeholder,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return OpenItem(
//       // ── open (full-screen) view ────────────
//       openChild: _FullScreenEditor(
//         controller: controller,
//         focusNode: focusNode,
//         readOnly: readOnly,
//         placeholder: placeholder,
//       ),
//       // ── closed (icon button) view ──────────
//       closedChild: const Tooltip(
//         message: 'Full screen',
//         child: IconButton(
//           icon: Icon(Icons.open_in_full_rounded, size: 18),
//           onPressed: null, // tap handled by OpenContainer
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// // _FullScreenEditor  (the "open" view)
// // ─────────────────────────────────────────────
// class _FullScreenEditor extends StatelessWidget {
//   final QuillController controller;
//   final FocusNode focusNode;
//   final bool readOnly;
//   final String placeholder;

//   const _FullScreenEditor({
//     required this.controller,
//     required this.focusNode,
//     required this.readOnly,
//     required this.placeholder,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;

//     return Scaffold(
//       backgroundColor: colorScheme.surface,
//       appBar: AppBar(
//         backgroundColor: colorScheme.surface,
//         surfaceTintColor: Colors.transparent,
//         elevation: 0,
//         title: const Text('Editor'),
//         leading: IconButton(
//           icon: const Icon(Icons.close_fullscreen_rounded),
//           tooltip: 'Exit full screen',
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         bottom: readOnly
//             ? null
//             : PreferredSize(
//                 preferredSize: const Size.fromHeight(kToolbarHeight),
//                 child: DecoratedBox(
//                   decoration: BoxDecoration(
//                     border: Border(
//                       bottom: BorderSide(color: colorScheme.outlineVariant),
//                     ),
//                   ),
//                   child: QuillSimpleToolbar(
//                     controller: controller,
//                     config: const QuillSimpleToolbarConfig(
//                       showAlignmentButtons: true,
//                       showColorButton: true,
//                       showBackgroundColorButton: true,
//                       multiRowsDisplay: false,
//                     ),
//                   ),
//                 ),
//               ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         child: QuillEditor.basic(
//           controller: controller,
//           focusNode: focusNode,
//           config: QuillEditorConfig(
//             placeholder: placeholder,
//             padding: const EdgeInsets.symmetric(vertical: 8),
//             expands: true,
//           ),
//         ),
//       ),
//     );
//   }
// }
