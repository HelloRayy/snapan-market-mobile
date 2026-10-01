import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileSearchBar extends StatelessWidget {
  final String searchQuery;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const ProfileSearchBar({
    super.key,
    required this.searchQuery,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14.0, 8.0, 14.0, 4.0),
      child: Container(
        height: 40.0,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
        ),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 12.0, right: 8.0),
              child: Icon(CupertinoIcons.search, size: 18.0, color: Color(0xFF94A3B8)),
            ),
            Expanded(
              child: TextField(
                autofocus: true,
                controller: TextEditingController(text: searchQuery)
                  ..selection = TextSelection.fromPosition(TextPosition(offset: searchQuery.length)),
                onChanged: onChanged,
                style: const TextStyle(fontSize: 13.5, color: Color(0xFF0F172A)),
                decoration: const InputDecoration(
                  hintText: 'Cari utas atau media di profil...',
                  hintStyle: TextStyle(fontSize: 13.5, color: Color(0xFF94A3B8)),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                ),
              ),
            ),
            if (searchQuery.isNotEmpty)
              GestureDetector(
                onTap: onClear,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Icon(CupertinoIcons.clear_thick_circled, size: 16.0, color: Color(0xFF94A3B8)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
