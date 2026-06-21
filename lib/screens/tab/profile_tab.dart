import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../utils/app_theme.dart';
import '../edit_profile_screen.dart';

class ProfileTab extends StatelessWidget {
  final String uid;
  const ProfileTab({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppTheme.accent),
            onPressed: () async {
              final doc = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .get();
              if (!context.mounted) return;
              if (doc.exists) {
                final user = UserModel.fromMap(doc.data()!);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditProfileScreen(user: user),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: authService.userStream(uid),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.accent));
          }
          if (!snap.hasData || !snap.data!.exists) {
            return const Center(child: Text('User not found'));
          }

          final user =
              UserModel.fromMap(snap.data!.data() as Map<String, dynamic>);

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                      top: 32, bottom: 40, left: 16, right: 16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppTheme.primary, Color(0xFF0A1A40)],
                    ),
                  ),
                  child: Column(
                    children: [
                      // Avatar
                      Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppTheme.accent, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.accent.withOpacity(0.3),
                                  blurRadius: 20,
                                )
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 52,
                              backgroundColor: AppTheme.surfaceLight,
                              backgroundImage: user.photoUrl.isNotEmpty
                                  ? NetworkImage(user.photoUrl)
                                  : null,
                              child: user.photoUrl.isEmpty
                                  ? Text(
                                      user.fullName.isNotEmpty
                                          ? user.fullName[0].toUpperCase()
                                          : '?',
                                      style: GoogleFonts.poppins(
                                        fontSize: 36,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.accent,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.fullName,
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Info Cards
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account Information',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _InfoTile(
                        icon: Icons.person_outline,
                        label: 'Full Name',
                        value: user.fullName,
                      ),
                      _InfoTile(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: user.email,
                      ),
                      _InfoTile(
                        icon: Icons.camera_alt_outlined,
                        label: 'Instagram',
                        value: user.instagram.isNotEmpty
                            ? '@${user.instagram}'
                            : 'Not set',
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'App',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Logout Button
                      GestureDetector(
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              backgroundColor: AppTheme.cardBg,
                              title: Text('Log Out',
                                  style: GoogleFonts.poppins(
                                      color: AppTheme.textPrimary)),
                              content: Text(
                                'Are you sure you want to log out?',
                                style: GoogleFonts.poppins(
                                    color: AppTheme.textSecondary),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: Text('Cancel',
                                      style: GoogleFonts.poppins(
                                          color: AppTheme.textSecondary)),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.error),
                                  onPressed: () =>
                                      Navigator.pop(context, true),
                                  child: Text('Log Out',
                                      style: GoogleFonts.poppins(
                                          color: Colors.white)),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await authService.logout();
                            if (!context.mounted) return;
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/register',
                              (route) => false,
                            );
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppTheme.error.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.logout,
                                  color: AppTheme.error, size: 20),
                              const SizedBox(width: 12),
                              Text(
                                'Log Out',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.surfaceLight),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.accent, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
