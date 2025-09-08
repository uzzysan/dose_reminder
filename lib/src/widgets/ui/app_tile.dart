import 'package:flutter/material.dart';

class AppTile extends StatelessWidget {
  const AppTile({
    super.key,
    this.onTap,
    required this.child,
    this.baseColor,
    this.padding,
    this.radius,
    this.margin,
  });

  final VoidCallback? onTap;
  final Widget child;
  final Color? baseColor; // bez przezroczystości (np. Colors.white lub ciemno-szary dla dark)
  final EdgeInsetsGeometry? padding;
  final double? radius;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final Color tileBase = baseColor ?? (isDark ? const Color(0xFF2B2B2D) : Colors.white);

    return Container(
      margin: margin,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.all(Radius.circular(radius ?? 16)),
          child: Container(
            decoration: BoxDecoration(
              color: tileBase.withValues(alpha: 0.30), // 30% przezroczystości
              borderRadius: BorderRadius.all(Radius.circular(radius ?? 16)),
              border: Border.all(color: tileBase, width: 1), // ta sama barwa, bez przezroczystości
            ),
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}
