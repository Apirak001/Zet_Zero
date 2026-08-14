import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/audio_service.dart';
import 'welcome_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool _isSoundOn = true;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? 'Green Hero';
    final email = user?.email ?? 'hero@ecoworld.com';
    final photoUrl = user?.photoURL;

    return Scaffold(
      backgroundColor: const Color(0xFF8EB89F), // สีเดียวกับธีม
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 40.0, bottom: 100.0), // bottom for nav bar
          child: Column(
            children: [
              // Avatar
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.greenAccent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 4),
                  boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
                ),
                child: ClipOval(
                  child: photoUrl != null
                      ? Image.network(photoUrl, fit: BoxFit.cover)
                      : const Icon(Icons.person, size: 60, color: Colors.black),
                ),
              ),
              const SizedBox(height: 16),
              
              // Name & Email
              Text(
                displayName,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black),
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black54),
              ),
              const SizedBox(height: 20),
              
              // Edit Profile Button (Change Password placeholder for now)
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('กำลังพัฒนาระบบเปลี่ยนรหัสผ่าน...')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  elevation: 0,
                ),
                child: const Text('Edit profile', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              ),
              
              const SizedBox(height: 40),
              
              // Preferences Section
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Preferences', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black54)),
              ),
              const SizedBox(height: 12),
              
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.black, width: 4),
                  boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(6, 6))],
                ),
                child: Column(
                  children: [
                    // Sound FX Toggle
                    _buildPreferenceItem(
                      icon: Icons.volume_up,
                      title: 'Sound Effects',
                      trailing: Switch(
                        value: _isSoundOn,
                        onChanged: (val) {
                          setState(() {
                            _isSoundOn = val;
                          });
                        },
                        activeColor: Colors.black,
                        activeTrackColor: Colors.green,
                      ),
                    ),
                    const Divider(color: Colors.black, height: 1, thickness: 2),
                    
                    // Music Toggle
                    _buildPreferenceItem(
                      icon: Icons.music_note,
                      title: 'Background Music',
                      trailing: Switch(
                        value: AudioService().isMusicOn,
                        onChanged: (val) async {
                          await AudioService().toggleMusic(val);
                          setState(() {});
                        },
                        activeColor: Colors.black,
                        activeTrackColor: Colors.green,
                      ),
                    ),
                    const Divider(color: Colors.black, height: 1, thickness: 2),
                    
                    // Password Change
                    _buildPreferenceItem(
                      icon: Icons.lock_outline,
                      title: 'Change Password',
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('กำลังพัฒนาระบบเปลี่ยนรหัสผ่าน...')),
                        );
                      },
                    ),
                    const Divider(color: Colors.black, height: 1, thickness: 2),
                    
                    // Logout
                    _buildPreferenceItem(
                      icon: Icons.logout,
                      title: 'Logout',
                      titleColor: Colors.red.shade700,
                      iconColor: Colors.red.shade700,
                      onTap: () async {
                        await AudioService().stopBGM();
                        await FirebaseAuth.instance.signOut();
                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const WelcomeView()),
                            (route) => false,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreferenceItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    Color titleColor = Colors.black,
    Color iconColor = Colors.black,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        constraints: const BoxConstraints(minHeight: 70),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: titleColor),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}
