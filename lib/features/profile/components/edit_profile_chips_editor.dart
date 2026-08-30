import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Interactive Interest/Bakat Chips Editor matching EditProfilePage.tsx
///
/// Features:
/// - Chip pills with 'X' delete buttons
/// - Inline input field for '+ Tambah minat...' with comma & enter parser
/// - Automatic Unicode emoji sanitization
/// - Tactile haptic feedback on add/remove
class EditProfileChipsEditor extends StatefulWidget {
  final List<String> tags;
  final ValueChanged<List<String>> onTagsChanged;

  const EditProfileChipsEditor({
    super.key,
    required this.tags,
    required this.onTagsChanged,
  });

  @override
  State<EditProfileChipsEditor> createState() => _EditProfileChipsEditorState();
}

class _EditProfileChipsEditorState extends State<EditProfileChipsEditor> {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String _cleanTag(String raw) {
    return raw
        .replaceAll(RegExp(r'[\u{1F300}-\u{1FAFF}\u{1F600}-\u{1F64F}\u{1F680}-\u{1F6FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]', unicode: true), '')
        .trim();
  }

  void _handleAddTag(String rawTag) {
    final clean = _cleanTag(rawTag);
    if (clean.isEmpty) return;

    if (widget.tags.any((t) => t.toLowerCase() == clean.toLowerCase())) {
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Minat "$clean" sudah ada di profil'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
        ),
      );
      return;
    }

    HapticFeedback.lightImpact();
    final updated = List<String>.from(widget.tags)..add(clean);
    widget.onTagsChanged(updated);
    _inputController.clear();
  }

  void _handleRemoveTag(String tagToRemove) {
    HapticFeedback.lightImpact();
    final updated = widget.tags.where((t) => t != tagToRemove).toList();
    widget.onTagsChanged(updated);
  }

  @override
  void dispose() {
    _inputController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Label & Subtext hint
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Minat',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.1,
                ),
              ),
              Text(
                'Pisahkan dengan koma / enter',
                style: TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10.0),

          // Wrap List of Chips + Inline Input
          Wrap(
            spacing: 6.0,
            runSpacing: 8.0,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ...widget.tags.map((tag) => GestureDetector(
                    onTap: () => _handleRemoveTag(tag),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(11.0, 4.0, 7.0, 4.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F4F5),
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(
                          color: const Color(0xFFE4E4E7),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            tag,
                            style: const TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(width: 4.0),
                          const Icon(
                            Icons.close_rounded,
                            size: 13.0,
                            color: Color(0xFF94A3B8),
                          ),
                        ],
                      ),
                    ),
                  )),

              // Inline Input Field
              Container(
                constraints: const BoxConstraints(minWidth: 120.0, maxWidth: 180.0),
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: TextField(
                  controller: _inputController,
                  focusNode: _focusNode,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF0F172A),
                  ),
                  decoration: const InputDecoration(
                    hintText: '+ Tambah minat...',
                    hintStyle: TextStyle(
                      fontSize: 13.5,
                      color: Color(0xFF94A3B8),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 6.0),
                  ),
                  onChanged: (val) {
                    if (val.contains(',') || val.contains('\n')) {
                      final parts = val.split(RegExp(r'[,\\n]'));
                      for (final part in parts) {
                        _handleAddTag(part);
                      }
                      _inputController.clear();
                    }
                  },
                  onSubmitted: (val) {
                    _handleAddTag(val);
                    _focusNode.requestFocus();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
