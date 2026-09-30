import 'package:flutter/material.dart';

class AuthBrandHeader extends StatelessWidget {
  final VoidCallback onBack;
  final String title;
  final String subtitle;

  const AuthBrandHeader({
    super.key,
    required this.onBack,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onBack,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1.0,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 4.0,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.chevron_left_rounded,
                size: 24.0,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ),
        const SizedBox(height: 22.0),
        Text(
          title,
          style: const TextStyle(
            fontSize: 27.0,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w400,
            color: Color(0xFF64748B),
            letterSpacing: -0.1,
          ),
        ),
      ],
    );
  }
}
