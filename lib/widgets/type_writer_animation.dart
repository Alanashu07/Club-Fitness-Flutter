import 'dart:async';

import 'package:flutter/material.dart';
import 'package:club_fitness/widgets/common_widgets.dart';

class TypewriterText extends StatefulWidget {
  final String text;
  final Duration duration;
  final TextStyle? style;
  final TextAlign textAlign;

  const TypewriterText({
    super.key,
    required this.text,
    this.duration = const Duration(milliseconds: 1500),
    this.style,
    this.textAlign = TextAlign.start,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText>
    with SingleTickerProviderStateMixin {
  late String _displayedText;
  Timer? _timer;
  int _charIndex = 0;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  @override
  void didUpdateWidget(covariant TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _startTyping();
    }
  }

  void _startTyping() {
    _timer?.cancel();
    _displayedText = '';
    _charIndex = 0;

    _timer = Timer.periodic(
      Duration(
        milliseconds: (widget.duration.inMilliseconds ~/ widget.text.length)
            .clamp(20, 100),
      ),
      (timer) {
        if (_charIndex >= widget.text.length) {
          timer.cancel();
        } else {
          setState(() {
            _displayedText += widget.text[_charIndex];
            _charIndex++;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextWidget(
      _displayedText,
      style: widget.style,
      textAlign: widget.textAlign,
    );
  }
}
