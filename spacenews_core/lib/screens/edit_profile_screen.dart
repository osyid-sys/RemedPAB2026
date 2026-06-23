import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _igCtrl;
  late final TextEditingController _photoCtrl;
  bool _loading = false;
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user.fullName);
    _igCtrl = TextEditingController(text: widget.user.instagram);
    _photoCtrl = TextEditingController(text: widget.user.photoUrl);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _igCtrl.dispose();
    _photoCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    final err = await _authService.updateUserData(widget.user.uid, {
      'fullName': _nameCtrl.text.trim(),
      'instagram': _igCtrl.text.trim(),
      'photoUrl': _photoCtrl.text.trim(),
    });
    setState(() => _loading = false);
    if (!mounted) return;
    if (err == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Profile updated successfully!'),
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: AppTheme.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _loading ? null : _save,
            child: Text(
              'Save',
              style: GoogleFonts.poppins(
                color: AppTheme.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar Preview
            Center(
              child: Stack(
                children: [
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _photoCtrl,
                    builder: (_, val, __) => CircleAvatar(
                      radius: 55,
                      backgroundColor: AppTheme.surfaceLight,
                      backgroundImage: val.text.isNotEmpty
                          ? NetworkImage(val.text)
                          : null,
                      child: val.text.isEmpty
                          ? Text(
                              _nameCtrl.text.isNotEmpty
                                  ? _nameCtrl.text[0].toUpperCase()
                                  : '?',
                              style: GoogleFonts.poppins(
                                fontSize: 40,
                                color: AppTheme.accent,
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Full Name
            TextFormField(
              controller: _nameCtrl,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),

            // Instagram
            TextFormField(
              controller: _igCtrl,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Instagram Username',
                prefixIcon: Icon(Icons.camera_alt_outlined),
                hintText: 'e.g. spacenews_fan',
              ),
            ),
            const SizedBox(height: 16),

            // Photo URL
            TextFormField(
              controller: _photoCtrl,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Photo URL',
                prefixIcon: Icon(Icons.image_outlined),
                hintText: 'https://example.com/photo.jpg',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Paste a direct URL to your profile picture',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 36),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _save,
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.primary,
                        ),
                      )
                    : const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
