import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/secure_storage.dart';
import '../l10n/app_strings.dart';
import '../l10n/locale_controller.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _email = '';
  File? _profileImage;
  final LocaleController _localeController = LocaleController();

  final _marsUsernameController = TextEditingController();
  final _marsPasswordController = TextEditingController();
  bool _marsObscurePassword = true;
  bool _hasMarsCredentials = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadMarsCredentials();
    _localeController.addListener(() => setState(() {}));
  }

  Future<void> _loadProfile() async {
    String? email = await SecureStorage.getUsername();
    setState(() => _email = email ?? 'pengguna@mylunas.com.my');
  }

  Future<void> _loadMarsCredentials() async {
    String? marsUser = await SecureStorage.getMarsUsername();
    String? marsPass = await SecureStorage.getMarsPassword();
    setState(() {
      _hasMarsCredentials = marsUser != null && marsUser.isNotEmpty;
      _marsUsernameController.text = marsUser ?? '';
      _marsPasswordController.text = marsPass ?? '';
    });
  }

  Future<void> _saveMarsCredentials() async {
    if (_marsUsernameController.text.isEmpty || _marsPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.get('profile_mars_fill')), backgroundColor: Colors.red),
      );
      return;
    }
    await SecureStorage.saveMarsCredentials(
      _marsUsernameController.text.trim(),
      _marsPasswordController.text,
    );
    setState(() => _hasMarsCredentials = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppStrings.get('profile_mars_success')), backgroundColor: Colors.green),
    );
  }

  Future<void> _clearMarsCredentials() async {
    await SecureStorage.clearMarsCredentials();
    setState(() {
      _hasMarsCredentials = false;
      _marsUsernameController.clear();
      _marsPasswordController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppStrings.get('profile_mars_cleared')), backgroundColor: Colors.orange),
    );
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _profileImage = File(result.files.single.path!));
    }
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.get('logout_title')),
        content: Text(AppStrings.get('logout_content')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.get('logout_cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              await SecureStorage.clearAll();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: Text(AppStrings.get('logout_confirm')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1565C0),
      appBar: AppBar(
        title: Text(AppStrings.get('profile_title')),
        backgroundColor: const Color(0xFF0D3B6E),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Avatar
            Stack(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 110, height: 110,
                    decoration: BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: ClipOval(
                      child: _profileImage != null
                          ? Image.file(_profileImage!, fit: BoxFit.cover)
                          : const Icon(Icons.person, size: 65, color: Color(0xFF0D3B6E)),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0, right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 32, height: 32,
                      decoration: const BoxDecoration(color: Color(0xFF0D3B6E), shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(_email, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(AppStrings.get('profile_staff'), style: const TextStyle(color: Colors.white70, fontSize: 13)),
            TextButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.edit, color: Colors.white70, size: 14),
              label: Text(AppStrings.get('profile_change_photo'), style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ),
            const SizedBox(height: 20),

            // Account Info
            _buildCard(
              title: AppStrings.get('profile_account_info'),
              children: [
                _buildInfoRow(Icons.email, AppStrings.get('profile_email'), _email),
                _buildInfoRow(Icons.business, AppStrings.get('profile_company'), AppStrings.get('profile_company_name')),
                _buildInfoRow(Icons.phone, AppStrings.get('profile_contact'), 'admin@mylunas.com.my'),
              ],
            ),
            const SizedBox(height: 16),

            // Language Toggle
            _buildCard(
              title: AppStrings.get('profile_language'),
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _localeController.setLocale('ms'),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _localeController.currentLocale == 'ms'
                                ? const Color(0xFF0D3B6E)
                                : Colors.grey.shade100,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                            ),
                            border: Border.all(
                              color: _localeController.currentLocale == 'ms'
                                  ? const Color(0xFF0D3B6E)
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Column(
                            children: [
                              const Text('🇲🇾', style: TextStyle(fontSize: 22)),
                              const SizedBox(height: 4),
                              Text(
                                'Bahasa Melayu',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _localeController.currentLocale == 'ms'
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _localeController.setLocale('en'),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _localeController.currentLocale == 'en'
                                ? const Color(0xFF0D3B6E)
                                : Colors.grey.shade100,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                            border: Border.all(
                              color: _localeController.currentLocale == 'en'
                                  ? const Color(0xFF0D3B6E)
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Column(
                            children: [
                              const Text('🇬🇧', style: TextStyle(fontSize: 22)),
                              const SizedBox(height: 4),
                              Text(
                                'English',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _localeController.currentLocale == 'en'
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
            const SizedBox(height: 16),

            // MARS Settings
            _buildCard(
              title: AppStrings.get('profile_mars_title'),
              titleIcon: _hasMarsCredentials
                  ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
                  : const Icon(Icons.warning_amber, color: Colors.orange, size: 20),
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: _hasMarsCredentials
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _hasMarsCredentials ? Colors.green : Colors.orange),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        _hasMarsCredentials ? Icons.check_circle : Icons.info_outline,
                        color: _hasMarsCredentials ? Colors.green : Colors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          AppStrings.get(_hasMarsCredentials ? 'profile_mars_saved' : 'profile_mars_empty'),
                          style: TextStyle(
                            fontSize: 12,
                            color: _hasMarsCredentials ? Colors.green.shade700 : Colors.orange.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                TextFormField(
                  controller: _marsUsernameController,
                  decoration: InputDecoration(
                    labelText: AppStrings.get('profile_mars_userid'),
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true, fillColor: Colors.grey.shade50,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _marsPasswordController,
                  obscureText: _marsObscurePassword,
                  decoration: InputDecoration(
                    labelText: AppStrings.get('profile_mars_password'),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_marsObscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _marsObscurePassword = !_marsObscurePassword),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true, fillColor: Colors.grey.shade50,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saveMarsCredentials,
                    icon: const Icon(Icons.save),
                    label: Text(AppStrings.get('profile_mars_save')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D3B6E), foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                if (_hasMarsCredentials) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _clearMarsCredentials,
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      label: Text(AppStrings.get('profile_mars_delete'), style: const TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // App Info
            _buildCard(
              title: AppStrings.get('profile_app_info'),
              children: [
                _buildInfoRow(Icons.info, AppStrings.get('profile_version'), '1.0.0'),
                _buildInfoRow(Icons.code, AppStrings.get('profile_developer'), 'LUNAS-ISD'),
                _buildInfoRow(Icons.copyright, AppStrings.get('profile_copyright'), '© MyLUNAS 2026'),
              ],
            ),
            const SizedBox(height: 24),

            // Logout
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: Text(AppStrings.get('profile_logout'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required List<Widget> children, Widget? titleIcon}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D3B6E))),
              if (titleIcon != null) ...[const SizedBox(width: 8), titleIcon],
            ],
          ),
          const Divider(),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF1565C0)),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.black54), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _localeController.removeListener(() => setState(() {}));
    _marsUsernameController.dispose();
    _marsPasswordController.dispose();
    super.dispose();
  }
}