import 'package:flutter/material.dart';

/// Crown Badge `👑 Pembuat Utas` for post author (1:1 Web React amber crown styling)
class CommentAuthorBadge extends StatelessWidget {
  const CommentAuthorBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: const Color(0xFFFDE68A), width: 0.8),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.workspace_premium_rounded,
            size: 11.0,
            color: Color(0xFFD97706),
          ),
          SizedBox(width: 3.0),
          Text(
            'Pembuat Utas',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFFB45309),
              letterSpacing: -0.2,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
