import 'package:flutter/material.dart';

class TypingText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration duration;
  final Duration delay;
  final Curve curve;

  const TypingText({
    super.key,
    required this.text,
    required this.style,
    this.duration = const Duration(milliseconds: 900),
    this.delay = Duration.zero,
    this.curve = Curves.linear,
  });

  @override
  State<TypingText> createState() => _TypingTextState();
}

class _TypingTextState extends State<TypingText> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: widget.duration);

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Animation<double> progress = CurvedAnimation(parent: _controller, curve: widget.curve);
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final int count = (progress.value * widget.text.length).floor().clamp(0, widget.text.length);
        final visible = widget.text.substring(0, count);
        return Text(visible, style: widget.style);
      },
    );
  }
}
