import 'package:flutter/material.dart';
import 'package:snapan_market/core/services/supabase_service.dart';
import 'package:snapan_market/core/theme/app_colors.dart';

/// Bottom sheet dialog to search SMKN 8 students and initiate a new direct chat.
class DirectMessagesNewChatSheet extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>> onUserSelected;

  const DirectMessagesNewChatSheet({
    super.key,
    required this.onUserSelected,
  });

  @override
  State<DirectMessagesNewChatSheet> createState() => _DirectMessagesNewChatSheetState();
}

class _DirectMessagesNewChatSheetState extends State<DirectMessagesNewChatSheet> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _isLoading = false;

  void _search(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) {
      setState(() => _results = []);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final res = await SupabaseService.instance.searchProfiles(clean);
      if (mounted) {
        setState(() {
          _results = res;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        height: 480.0,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          children: [
            Container(
              width: 36.0,
              height: 4.0,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
            const SizedBox(height: 12.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Kirim Pesan Baru',
                  style: TextStyle(
                    fontSize: 17.0,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close_rounded, size: 22.0, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            Container(
              height: 42.0,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Icon(Icons.search_rounded, size: 18.0, color: Color(0xFF94A3B8)),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      onChanged: _search,
                      style: const TextStyle(fontSize: 14.0, color: Color(0xFF0F172A)),
                      decoration: const InputDecoration(
                        hintText: 'Cari nama atau username siswa SMKN 8...',
                        hintStyle: TextStyle(fontSize: 13.5, color: Color(0xFF94A3B8)),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  if (_controller.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _controller.clear();
                        _search('');
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Icon(Icons.cancel_rounded, size: 16.0, color: Color(0xFF94A3B8)),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10.0),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.primary,
                      ),
                    )
                  : _results.isEmpty
                      ? Center(
                          child: Text(
                            _controller.text.isEmpty
                                ? 'Ketik nama siswa atau penjual untuk memulai percakapan.'
                                : 'Tidak ditemukan profil siswa dengan nama tersebut.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 13.0, color: Color(0xFF94A3B8)),
                          ),
                        )
                      : ListView.separated(
                          itemCount: _results.length,
                          separatorBuilder: (_, __) => const Divider(
                            height: 1.0,
                            color: Color(0xFFF1F5F9),
                          ),
                          itemBuilder: (context, index) {
                            final user = _results[index];
                            final name = user['full_name'] as String? ?? 'Siswa';
                            final username = user['username'] as String? ?? '';
                            final avatar = user['avatar_url'] as String? ?? '';
                            final classGroup = user['class_group'] as String? ?? 'SMKN 8 Semarang';

                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(vertical: 4.0),
                              leading: CircleAvatar(
                                radius: 20.0,
                                backgroundColor: const Color(0xFFEEF0FF),
                                backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
                                child: avatar.isEmpty
                                    ? Text(
                                        name.isNotEmpty ? name[0].toUpperCase() : 'U',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                        ),
                                      )
                                    : null,
                              ),
                              title: Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.5,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              subtitle: Text(
                                '@$username · $classGroup',
                                style: const TextStyle(
                                  fontSize: 12.0,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              onTap: () => widget.onUserSelected(user),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
