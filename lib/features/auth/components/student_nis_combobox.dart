import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:snapan_market/core/services/student_registry_service.dart';
import 'package:snapan_market/features/auth/components/auth_text_field.dart';

/// Floating combobox for student NIS lookup.
/// Uses Flutter OverlayEntry so popup list floats OVER other fields without pushing layout downwards.
class StudentNisCombobox extends StatefulWidget {
  final TextEditingController controller;
  final String? errorText;
  final RegisteredStudent? verifiedStudent;
  final ValueChanged<RegisteredStudent?> onStudentSelected;

  const StudentNisCombobox({
    super.key,
    required this.controller,
    this.errorText,
    this.verifiedStudent,
    required this.onStudentSelected,
  });

  @override
  State<StudentNisCombobox> createState() => _StudentNisComboboxState();
}

class _StudentNisComboboxState extends State<StudentNisCombobox> {
  final LayerLink _layerLink = LayerLink();
  final FocusNode _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;
  List<RegisteredStudent> _suggestions = [];

  @override
  void initState() {
    super.initState();
    unawaited(StudentRegistryService.instance.refresh());
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _removeOverlay();
      }
    });
  }

  @override
  void dispose() {
    _removeOverlay();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    final clean = value.trim();

    // Reset verified student status if user modifies input away from verified NIS
    if (widget.verifiedStudent != null && widget.verifiedStudent!.nis != clean) {
      widget.onStudentSelected(null);
    }

    if (clean.length >= 2) {
      final results = StudentRegistryService.instance.searchStudents(clean);
      setState(() {
        _suggestions = results.take(6).toList();
      });

      if (_suggestions.isNotEmpty && _focusNode.hasFocus) {
        _showOverlay();
      } else {
        _removeOverlay();
      }

      // Live async check ke Supabase jika pencarian lokal nihil atau data baru di-input admin
      StudentRegistryService.instance.searchStudentsAsync(clean).then((remoteResults) {
        if (mounted && _focusNode.hasFocus && widget.controller.text.trim() == clean) {
          if (remoteResults.isNotEmpty) {
            setState(() {
              _suggestions = remoteResults.take(6).toList();
            });
            _showOverlay();
          }
        }
      });
    } else {
      _removeOverlay();
    }
  }

  void _showOverlay() {
    _removeOverlay();
    final overlayState = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          width: _layerLink.leaderSize?.width ?? MediaQuery.of(context).size.width - 48,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: const Offset(0.0, 58.0),
            child: Material(
              elevation: 8.0,
              shadowColor: Colors.black.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16.0),
              color: Colors.white,
              clipBehavior: Clip.antiAlias,
              child: Container(
                constraints: const BoxConstraints(maxHeight: 230.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                ),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _suggestions.length,
                  separatorBuilder: (_, _) => const Divider(
                    height: 1.0,
                    thickness: 0.8,
                    color: Color(0xFFF1F5F9),
                  ),
                  itemBuilder: (context, index) {
                    final student = _suggestions[index];
                    return InkWell(
                      onTap: () {
                        if (student.isClaimed) {
                          HapticFeedback.mediumImpact();
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('NIS ${student.nis} sudah memiliki akun aktif. Silakan masuk.'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }
                        HapticFeedback.selectionClick();
                        widget.controller.text = student.nis;
                        widget.onStudentSelected(student);
                        _removeOverlay();
                        _focusNode.unfocus();
                      },
                      child: Opacity(
                        opacity: student.isClaimed ? 0.55 : 1.0,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 3.5),
                                decoration: BoxDecoration(
                                  color: student.isClaimed
                                      ? const Color(0xFFE2E8F0)
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(6.0),
                                ),
                                child: Text(
                                  student.nis,
                                  style: TextStyle(
                                    fontFamily: 'SFPro',
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w700,
                                    color: student.isClaimed
                                        ? const Color(0xFF64748B)
                                        : const Color(0xFF334155),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      student.name,
                                      style: TextStyle(
                                        fontFamily: 'SFPro',
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.w600,
                                        color: student.isClaimed
                                            ? const Color(0xFF64748B)
                                            : const Color(0xFF0F172A),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          student.classGroup,
                                          style: const TextStyle(
                                            fontFamily: 'SFPro',
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                        if (student.isClaimed) ...[
                                          const SizedBox(width: 6.0),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 5.0,
                                              vertical: 1.5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFEF3C7),
                                              borderRadius: BorderRadius.circular(4.0),
                                            ),
                                            child: const Text(
                                              'Sudah Terdaftar',
                                              style: TextStyle(
                                                fontFamily: 'SFPro',
                                                fontSize: 10.0,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFFD97706),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                student.isClaimed ? LucideIcons.lock : LucideIcons.arrowUpRight,
                                size: 15.0,
                                color: student.isClaimed
                                    ? const Color(0xFFD97706)
                                    : const Color(0xFF94A3B8),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );

    overlayState.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    final isVerified = widget.verifiedStudent != null;

    final String labelText = isVerified
        ? 'NIS Terverifikasi • ${widget.verifiedStudent!.classGroup}'
        : 'NIS Siswa';

    final Widget suffixIcon = isVerified
        ? const Padding(
            padding: EdgeInsets.only(right: 14.0),
            child: Icon(
              LucideIcons.circleCheck,
              size: 20.0,
              color: Color(0xFF16A34A),
            ),
          )
        : Padding(
            padding: const EdgeInsets.only(right: 14.0),
            child: Icon(
              _focusNode.hasFocus ? LucideIcons.chevronUp : LucideIcons.chevronsUpDown,
              size: 18.0,
              color: const Color(0xFF94A3B8),
            ),
          );

    return CompositedTransformTarget(
      link: _layerLink,
      child: Focus(
        focusNode: _focusNode,
        child: AuthInputField(
          label: labelText,
          hint: 'Masukkan NIS / nama lengkap',
          prefixIcon: LucideIcons.idCard,
          controller: widget.controller,
          errorText: widget.errorText,
          isValid: isVerified,
          customSuffixIcon: suffixIcon,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.text,
          onChanged: _onChanged,
        ),
      ),
    );
  }
}
