import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Single interactive row item for the navigation drawer.
class HomeDrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color inkColor;
  final Color mutedColor;
  final Color hoverColor;
  final VoidCallback? onTap;
  final VoidCallback? onClose;
  final Color? textColor;
  final Color? iconColor;
  final Widget? trailingWidget;
  final bool hasChevron;
  final bool isDestructive;

  const HomeDrawerItem({
    super.key,
    required this.icon,
    required this.label,
    required this.inkColor,
    required this.mutedColor,
    required this.hoverColor,
    this.onTap,
    this.onClose,
    this.textColor,
    this.iconColor,
    this.trailingWidget,
    this.hasChevron = false,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTextColor = textColor ?? inkColor;
    final effectiveIconColor = iconColor ?? mutedColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          if (onClose != null) {
            onClose!();
          } else {
            Navigator.of(context).maybePop();
          }
          onTap?.call();
        },
        borderRadius: BorderRadius.circular(10.0),
        hoverColor: hoverColor,
        splashColor: hoverColor,
        highlightColor: Colors.transparent,
        child: Container(
          height: 46.0,
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Icon(
                icon,
                size: 20.0,
                color: effectiveIconColor,
              ),
              const SizedBox(width: 14.0),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'SFPro',
                    fontSize: 14.5,
                    fontWeight: isDestructive ? FontWeight.w600 : FontWeight.w500,
                    color: effectiveTextColor,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              if (trailingWidget != null)
                trailingWidget!
              else if (hasChevron)
                Icon(
                  CupertinoIcons.chevron_forward,
                  size: 15.0,
                  color: mutedColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
