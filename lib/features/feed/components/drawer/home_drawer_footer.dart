import 'package:flutter/material.dart';

/// Pinned footer branding and version display for navigation drawer.
class HomeDrawerFooter extends StatelessWidget {
  final Color borderColor;
  final Color inkColor;
  final Color mutedColor;

  const HomeDrawerFooter({
    super.key,
    required this.borderColor,
    required this.inkColor,
    required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: borderColor, width: 1.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Snaps - Stable Version V 1.0.4',
            style: TextStyle(
              fontFamily: 'SFPro',
              fontSize: 12.0,
              fontWeight: FontWeight.w600,
              color: inkColor,
            ),
          ),
          const SizedBox(height: 2.0),
          Text(
            'E-Commerce & Social Feed • SMKN 8 Semarang',
            style: TextStyle(
              fontFamily: 'SFPro',
              fontSize: 10.5,
              color: mutedColor,
            ),
          ),
        ],
      ),
    );
  }
}
