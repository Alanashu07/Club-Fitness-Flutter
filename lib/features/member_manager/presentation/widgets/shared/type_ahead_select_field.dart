
import 'package:club_fitness/config/theme/theme.dart';
import 'package:club_fitness/core/services/search_services.dart';
import 'package:club_fitness/features/member_manager/member_manager.dart';
import 'package:flutter/material.dart';

/// Type-ahead selector.
///
/// * Filters [items] with [SearchService.fuzzySearch] while typing.
/// * Picking a suggestion fills the field with its label.
/// * On blur: if exactly one suggestion matches the typed text it is selected
///   automatically (no tap needed); otherwise the field reverts to the
///   current selection. Clearing the text calls [onCleared].
class TypeAheadSelectField<T extends Object> extends StatefulWidget {
  final String label;
  final String hint;
  final IconData icon;
  final List<T> items;
  final T? selected;
  final String Function(T) labelOf;
  final String Function(T) searchTextOf;
  final String Function(T)? subtitleOf;
  final ValueChanged<T> onSelected;
  final VoidCallback? onCleared;

  const TypeAheadSelectField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.items,
    required this.selected,
    required this.labelOf,
    required this.searchTextOf,
    required this.onSelected,
    this.subtitleOf,
    this.onCleared,
  });

  @override
  State<TypeAheadSelectField<T>> createState() =>
      _TypeAheadSelectFieldState<T>();
}

class _TypeAheadSelectFieldState<T extends Object>
    extends State<TypeAheadSelectField<T>> {
  late final TextEditingController _ctrl;
  final FocusNode _focus = FocusNode();

  String _textFor(T? v) => v == null ? '' : widget.labelOf(v);

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: _textFor(widget.selected));
    _focus.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant TypeAheadSelectField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Keep the text in sync when the selection is changed from outside
    // (prefill, async plan loading, reset…) while the user isn't typing.
    if (!_focus.hasFocus && _ctrl.text != _textFor(widget.selected)) {
      _ctrl.text = _textFor(widget.selected);
    }
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  List<T> _filter(String query) => SearchService.fuzzySearch(
    widget.items,
    query,
    widget.searchTextOf,
  ).toList();

  void _onFocusChange() {
    if (_focus.hasFocus) {
      // Select everything so typing replaces the current choice quickly.
      _ctrl.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _ctrl.text.length,
      );
      return;
    }
    _commit();
  }

  void _commit() {
    final text = _ctrl.text.trim();
    final current = widget.selected;

    if (text.isEmpty) {
      if (current != null) widget.onCleared?.call();
      return;
    }
    if (current != null && widget.labelOf(current) == text) return;

    final matches = _filter(text);
    final exact = matches
        .where((m) => widget.labelOf(m).toLowerCase() == text.toLowerCase())
        .toList();

    T? pick;
    if (matches.length == 1) {
      pick = matches.first;
    } else if (exact.length == 1) {
      pick = exact.first;
    }

    if (pick != null) {
      _ctrl.text = widget.labelOf(pick);
      widget.onSelected(pick);
    } else {
      _ctrl.text = _textFor(current); // revert
    }
  }

  Iterable<T> _options(TextEditingValue value) {
    final q = value.text.trim();
    final current = widget.selected;
    if (q.isEmpty || (current != null && widget.labelOf(current) == q)) {
      return widget.items;
    }
    return _filter(q);
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.selected;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SheetLabel(widget.label),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            return RawAutocomplete<T>(
              textEditingController: _ctrl,
              focusNode: _focus,
              displayStringForOption: widget.labelOf,
              optionsBuilder: _options,
              onSelected: (value) {
                widget.onSelected(value);
                // Unfocus after the parent has rebuilt with the new selection.
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) _focus.unfocus();
                });
              },
              fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                return Container(
                  decoration: sheetFieldDecoration().copyWith(
                    border: Border.all(
                      color: focusNode.hasFocus
                          ? AppTheme.primary.withAOpacity(0.6)
                          : Colors.white.withAOpacity(0.06),
                    ),
                  ),
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    onSubmitted: (_) => onSubmit(),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: widget.hint,
                      hintStyle: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        widget.icon,
                        color: AppTheme.textSecondary,
                        size: 18,
                      ),
                      suffixIcon: current != null
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: AppTheme.primary,
                              size: 18,
                            )
                          : const Icon(
                              Icons.unfold_more_rounded,
                              color: AppTheme.textSecondary,
                              size: 18,
                            ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                    ),
                  ),
                );
              },
              optionsViewBuilder: (context, onSelected, options) {
                if (options.isEmpty) return const SizedBox.shrink();
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 6,
                    color: AppTheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.white.withAOpacity(0.08)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: SizedBox(
                      width: constraints.maxWidth,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 220),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (context, i) {
                            final o = options.elementAt(i);
                            final highlighted =
                                AutocompleteHighlightedOption.of(context) == i;
                            final isSelected =
                                current != null &&
                                widget.labelOf(current) == widget.labelOf(o);
                            final subtitle = widget.subtitleOf?.call(o);
                            return InkWell(
                              onTap: () => onSelected(o),
                              child: Container(
                                color: highlighted
                                    ? Colors.white.withAOpacity(0.06)
                                    : Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            subtitle == null
                                                ? widget.labelOf(o)
                                                : widget
                                                      .searchTextOf(o)
                                                      .split(' ')
                                                      .first,
                                            style: TextStyle(
                                              color: isSelected
                                                  ? AppTheme.primary
                                                  : Colors.white,
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          if (subtitle != null) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              subtitle,
                                              style: const TextStyle(
                                                color: AppTheme.textSecondary,
                                                fontSize: 11.5,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    if (isSelected)
                                      const Icon(
                                        Icons.check_rounded,
                                        color: AppTheme.primary,
                                        size: 18,
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}