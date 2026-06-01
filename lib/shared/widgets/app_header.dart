import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final bool showBackButton;
  final List<Widget>? actions;
  final Widget? leading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final VoidCallback? onBackPressed;
  final bool centerTitle;
  final double titleFontSize;
  final FontWeight titleFontWeight;
  final double? titleSpacing;

  const AppHeader({
    super.key,
    this.title,
    this.titleWidget,
    this.showBackButton = true,
    this.actions,
    this.leading,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.onBackPressed,
    this.centerTitle = false,
    this.titleFontSize = 20,
    this.titleFontWeight = FontWeight.w700,
    this.titleSpacing,
  }) : assert(title != null || titleWidget != null,
            'title atau titleWidget wajib diisi');

  static const Color primaryColor = Color(0xFF6B3EEA);
  static const Color textPrimary = Color(0xFF111827);
  static const Color background = Colors.white;

  @override
  Widget build(BuildContext context) {
    final effectiveForegroundColor = foregroundColor ?? textPrimary;

    return AppBar(
      centerTitle: centerTitle,
      elevation: elevation,
      scrolledUnderElevation: 0,
      titleSpacing: titleSpacing,
      backgroundColor: backgroundColor ?? background,
      foregroundColor: effectiveForegroundColor,
      iconTheme: IconThemeData(color: effectiveForegroundColor),
      leading: leading ??
          (showBackButton
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed:
                      onBackPressed ?? () => Navigator.of(context).maybePop(),
                )
              : null),
      title: titleWidget ??
          Text(
            title!,
            style: TextStyle(
              color: effectiveForegroundColor,
              fontSize: titleFontSize,
              fontWeight: titleFontWeight,
              letterSpacing: -0.2,
            ),
          ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}