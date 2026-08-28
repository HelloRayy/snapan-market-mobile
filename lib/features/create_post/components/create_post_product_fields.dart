import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/core/utils/rupiah_input_formatter.dart';
import 'package:snapan_market/features/create_post/models/create_post_types.dart';

/// Product Selling Rich Input Fields:
/// 1. Nama Barang / Jasa *
/// 2. Harga (Rp) * with RupiahInputFormatter
/// 3. Deskripsi Singkat
/// 4. Titik COD di Sekolah + Quick Preset Chips
class CreatePostProductFields extends StatelessWidget {
  final TextEditingController productTitleController;
  final TextEditingController priceController;
  final TextEditingController descController;
  final GlobalKey titleKey;
  final GlobalKey priceKey;
  final GlobalKey descKey;
  final FocusNode titleFocusNode;
  final FocusNode priceFocusNode;
  final FocusNode descFocusNode;
  final SchoolPlace? selectedLocation;
  final VoidCallback onPickLocation;
  final ValueChanged<SchoolPlace> onLocationSelected;

  const CreatePostProductFields({
    super.key,
    required this.productTitleController,
    required this.priceController,
    required this.descController,
    required this.titleKey,
    required this.priceKey,
    required this.descKey,
    required this.titleFocusNode,
    required this.priceFocusNode,
    required this.descFocusNode,
    required this.selectedLocation,
    required this.onPickLocation,
    required this.onLocationSelected,
  });

  static const _codPresets = [
    {'name': 'Kantin', 'emoji': '🍜'},
    {'name': 'Lab PPLG', 'emoji': '💻'},
    {'name': 'Perpustakaan', 'emoji': '📚'},
    {'name': 'Depan Gerbang', 'emoji': '🏫'},
    {'name': 'Lapangan', 'emoji': '⚽'},
    {'name': 'Gazebo DKV', 'emoji': '☕'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Nama Barang / Jasa *
        _buildFieldLabel('Nama Barang / Jasa', isRequired: true),
        const SizedBox(height: 6.0),
        TextField(
          key: titleKey,
          focusNode: titleFocusNode,
          controller: productTitleController,
          cursorColor: AppColors.primary,
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w500,
            color: Color(0xFF0F172A),
          ),
          decoration: _buildCleanInputDecoration(
            hint: 'Tulis nama barang atau jasa...',
          ),
        ),
        const SizedBox(height: 14.0),

        // 2. Harga (Rp) *
        _buildFieldLabel('Harga (Rp)', isRequired: true),
        const SizedBox(height: 6.0),
        TextField(
          key: priceKey,
          focusNode: priceFocusNode,
          controller: priceController,
          keyboardType: TextInputType.number,
          cursorColor: AppColors.primary,
          inputFormatters: const [
            RupiahInputFormatter(),
          ],
          style: const TextStyle(
            fontSize: 15.0,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
          decoration: _buildCleanInputDecoration(
            hint: '0',
            prefixWidget: Padding(
              padding: const EdgeInsets.only(left: 14.0, right: 4.0),
              child: Text(
                'Rp ',
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: priceController.text.isNotEmpty
                      ? FontWeight.w700
                      : FontWeight.w400,
                  color: priceController.text.isNotEmpty
                      ? const Color(0xFF0F172A)
                      : const Color(0xFF94A3B8),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14.0),

        // 3. Deskripsi Singkat
        _buildFieldLabel('Deskripsi Singkat'),
        const SizedBox(height: 6.0),
        TextField(
          key: descKey,
          focusNode: descFocusNode,
          controller: descController,
          minLines: 3,
          maxLines: 4,
          cursorColor: AppColors.primary,
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w500,
            color: Color(0xFF0F172A),
          ),
          decoration: _buildCleanInputDecoration(
            hint: 'Tulis kondisi barang, kelengkapan, atau alasan jual...',
          ),
        ),
        const SizedBox(height: 14.0),

        // 4. Titik COD di Sekolah
        _buildFieldLabel('Titik COD di Sekolah'),
        const SizedBox(height: 6.0),
        TextField(
          readOnly: true,
          onTap: onPickLocation,
          style: const TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            hintText: selectedLocation != null
                ? selectedLocation!.name
                : 'Ketik titik temu COD (Kantin, Lab, dll)...',
            hintStyle: TextStyle(
              fontSize: 13.5,
              color: selectedLocation != null
                  ? const Color(0xFF0F172A)
                  : const Color(0xFF94A3B8),
              fontWeight:
                  selectedLocation != null ? FontWeight.w600 : FontWeight.w400,
            ),
            prefixIcon: const Icon(
              CupertinoIcons.location,
              size: 16.0,
              color: Color(0xFF64748B),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 8.0),

        // Quick Preset COD Chips
        Wrap(
          spacing: 6.0,
          runSpacing: 6.0,
          children: [
            for (var preset in _codPresets) ...[
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onLocationSelected(
                    SchoolPlace(
                      id: 'preset_${preset['name']}',
                      name: preset['name']!,
                      subtitle: 'Titik Temu COD Sekolah',
                      distance: 'Kampus SMKN 8',
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 5.0,
                  ),
                  decoration: BoxDecoration(
                    color: selectedLocation?.name == preset['name']
                        ? const Color(0xFFEFF6FF)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: selectedLocation?.name == preset['name']
                          ? AppColors.primary
                          : const Color(0xFFE2E8F0),
                      width: selectedLocation?.name == preset['name'] ? 1.4 : 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(preset['emoji']!, style: const TextStyle(fontSize: 12.0)),
                      const SizedBox(width: 4.0),
                      Text(
                        preset['name']!,
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: selectedLocation?.name == preset['name']
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: selectedLocation?.name == preset['name']
                              ? AppColors.primary
                              : const Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String text, {bool isRequired = false}) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1E293B),
        ),
        children: [
          if (isRequired)
            const TextSpan(
              text: ' *',
              style: TextStyle(
                color: Color(0xFFEF4444),
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }

  InputDecoration _buildCleanInputDecoration({
    required String hint,
    Widget? prefixWidget,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.w400,
        color: Color(0xFF94A3B8),
      ),
      prefixIcon: prefixWidget,
      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      filled: true,
      fillColor: Colors.white,
      focusColor: Colors.white,
      hoverColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
}
