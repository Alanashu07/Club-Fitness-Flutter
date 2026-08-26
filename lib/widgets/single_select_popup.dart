import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:club_fitness/core/constants/constants.dart';

import 'common_widgets.dart';

class SingleSelectPopup<T> extends StatefulWidget {
  final List<T> items;
  final String title;
  final String Function(T item) displayBuilder;
  final List<T> Function(String query)? filterBuilder;

  const SingleSelectPopup({
    super.key,
    required this.items,
    required this.title,
    required this.displayBuilder,
    this.filterBuilder,
  });

  @override
  State<SingleSelectPopup<T>> createState() => _SingleSelectPopupState<T>();
}

class _SingleSelectPopupState<T> extends State<SingleSelectPopup<T>> {
  final TextEditingController controller = TextEditingController();
  List<T> get filteredItems {
    if (widget.filterBuilder != null) {
      return widget.filterBuilder!(controller.text);
    }
    final query = controller.text.toLowerCase();
    if (query.isEmpty) return widget.items;
    return widget.items.where((item) {
      return widget.displayBuilder(item).toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: 12.w.all,
      margin: 12.w.all,
      constraints: BoxConstraints(maxWidth: context.width * .8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Spacer(),
              TextWidget(widget.title, style: FontConstant.oxygenMediumBold),
              const Spacer(),
              IconButton(
                onPressed: context.pop,
                icon: const Icon(CupertinoIcons.xmark_circle),
              ),
            ],
          ),
          const Divider(),
          // CustomTextField(
          //   controller: controller,
          //   label: 'Search here...',
          //   onChanged: (value) => setState(() {}),
          // ),
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: context.height * 0.5),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: filteredItems.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  return InkWell(
                    onTap: () {
                      context.pop(item);
                    },
                    child: TextWidget(
                      widget.displayBuilder(item),
                      padding: 12.w.all,
                      style: FontConstant.oxygenSmallBold,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
