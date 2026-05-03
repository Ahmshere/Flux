import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Анимированное число — "прокручивается" при изменении значения
class AnimatedNumber extends StatefulWidget {
  final double value;
  final TextStyle? style;
  final String Function(double) formatter;

  const AnimatedNumber({
    super.key,
    required this.value,
    required this.formatter,
    this.style,
  });

  @override
  State<AnimatedNumber> createState() => _AnimatedNumberState();
}

class _AnimatedNumberState extends State<AnimatedNumber>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  double _oldValue = 0;
  double _newValue = 0;

  @override
  void initState() {
    super.initState();
    _oldValue = widget.value;
    _newValue = widget.value;
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
  }

  @override
  void didUpdateWidget(AnimatedNumber old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _oldValue = old.value;
      _newValue = widget.value;
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final current = _oldValue + (_newValue - _oldValue) * _anim.value;
        return Text(
          widget.formatter(current),
          style: widget.style,
        );
      },
    );
  }
}
