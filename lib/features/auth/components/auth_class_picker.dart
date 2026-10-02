import 'package:flutter/material.dart';
import 'package:snapan_market/core/components/app_dropdown_field.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/features/auth/models/auth_constants.dart';

class AuthClassPicker extends StatelessWidget {
  final String? selectedGrade;
  final String? selectedMajor;
  final String? selectedClassNum;
  final String? classError;
  final ValueChanged<String?> onGradeChanged;
  final ValueChanged<String?> onMajorChanged;
  final ValueChanged<String?> onClassNumChanged;

  const AuthClassPicker({
    super.key,
    required this.selectedGrade,
    required this.selectedMajor,
    required this.selectedClassNum,
    this.classError,
    required this.onGradeChanged,
    required this.onMajorChanged,
    required this.onClassNumChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: AppDropdownField(
                label: 'Kelas',
                value: selectedGrade,
                options: AuthConstants.gradeOptions,
                hasError: classError != null && selectedGrade == null,
                onChanged: onGradeChanged,
              ),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              flex: 4,
              child: AppDropdownField(
                label: 'Jurusan',
                value: selectedMajor,
                options: AuthConstants.majorOptions,
                hasError: classError != null && selectedMajor == null,
                onChanged: onMajorChanged,
              ),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              flex: 3,
              child: AppDropdownField(
                label: 'Ruang',
                value: selectedClassNum,
                options: AuthConstants.classNumOptions,
                hasError: classError != null && selectedClassNum == null,
                onChanged: onClassNumChanged,
              ),
            ),
          ],
        ),
        if (classError != null)
          Padding(
            padding: const EdgeInsets.only(top: 6.0, left: 4.0),
            child: Text(
              classError!,
              style: const TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.w500,
                color: AppColors.error,
              ),
            ),
          ),
      ],
    );
  }
}
