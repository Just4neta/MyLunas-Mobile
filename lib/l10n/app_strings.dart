// lib/l10n/app_strings.dart

class AppStrings {
  static String locale = 'ms'; // default: Bahasa Melayu

  static String get(String key) {
    return (_strings[locale] ?? _strings['ms']!)[key] ?? key;
  }

  static const Map<String, Map<String, String>> _strings = {
    'ms': {
      // Login
      'login_title': 'MyLUNAS Mobile',
      'login_subtitle': 'Log masuk untuk akses semua sistem',
      'login_email': 'Email',
      'login_password': 'Kata Laluan',
      'login_remember': 'Ingat Saya',
      'login_forgot': 'Lupa Password?',
      'login_button': 'LOG MASUK',
      'login_verifying': 'Mengesahkan akaun anda...',
      'login_connecting': 'Menyambung ke sistem MyLUNAS...',
      'login_loading': 'Memuat turun konfigurasi...',
      'login_error': 'Log masuk gagal. Sila semak email/password.',
      'login_network_error': 'Ralat sambungan. Sila semak internet anda.',
      'login_contact_admin': 'Sila hubungi admin IT',
      'login_email_empty': 'Sila masukkan email',
      'login_email_invalid': 'Format email tidak sah',
      'login_password_empty': 'Sila masukkan kata laluan',
      'version': 'Versi 1.0.0',

      // Home
      'home_footer': 'Copyright © MyLUNAS 2026. Developed by LUNAS-ISD.',
      'home_coming_soon': 'Akan datang',
      'home_unavailable': 'Sistem ini belum tersedia buat masa ini.',
      'home_exit_title': 'Keluar Aplikasi',
      'home_exit_content': 'Adakah anda pasti mahu keluar dari MyLUNAS Mobile?',
      'home_exit_confirm': 'Keluar',
      'home_cancel': 'Batal',

      // Profile
      'profile_title': 'Profil & Tetapan',
      'profile_staff': 'Staf MyLUNAS',
      'profile_change_photo': 'Tukar gambar profil',
      'profile_account_info': 'Maklumat Akaun',
      'profile_email': 'Email',
      'profile_company': 'Syarikat',
      'profile_company_name': 'Lumut Naval Shipyard',
      'profile_contact': 'Hubungi',
      'profile_mars_title': 'Tetapan MARS Approval',
      'profile_mars_saved': 'Credentials MARS dah disimpan',
      'profile_mars_empty': 'Belum ada credentials MARS — sistem akan tunjuk login page',
      'profile_mars_userid': 'MARS User ID',
      'profile_mars_password': 'MARS Password',
      'profile_mars_save': 'Simpan Credentials MARS',
      'profile_mars_delete': 'Padam Credentials MARS',
      'profile_mars_fill': 'Sila isi User ID dan Password MARS',
      'profile_mars_success': 'Credentials MARS berjaya disimpan!',
      'profile_mars_cleared': 'Credentials MARS telah dipadamkan',
      'profile_app_info': 'Maklumat Aplikasi',
      'profile_version': 'Versi',
      'profile_developer': 'Dibangunkan oleh',
      'profile_copyright': 'Hakcipta',
      'profile_language': 'Bahasa / Language',
      'profile_logout': 'LOG KELUAR',
      'logout_title': 'Log Keluar',
      'logout_content': 'Adakah anda pasti mahu log keluar?',
      'logout_confirm': 'Log Keluar',
      'logout_cancel': 'Batal',

      // Quote
      'quote_tap': 'Ketik untuk teruskan',
      'quote_skip': 'Skip',
      'quote_exit': 'Exit',
    },

    'en': {
      // Login
      'login_title': 'MyLUNAS Mobile',
      'login_subtitle': 'Sign in to access all LUNAS systems',
      'login_email': 'Email',
      'login_password': 'Password',
      'login_remember': 'Remember Me',
      'login_forgot': 'Forgot Password?',
      'login_button': 'SIGN IN',
      'login_verifying': 'Verifying your account...',
      'login_connecting': 'Connecting to MyLUNAS systems...',
      'login_loading': 'Loading configuration...',
      'login_error': 'Login failed. Please check your email and password.',
      'login_network_error': 'Connection error. Please check your internet connection.',
      'login_contact_admin': 'Please contact your IT Administrator',
      'login_email_empty': 'Please enter your email',
      'login_email_invalid': 'Invalid email format',
      'login_password_empty': 'Please enter your password',
      'version': 'Version 1.0.0',

      // Home
      'home_footer': 'Copyright © MyLUNAS 2026. Developed by LUNAS-ISD.',
      'home_coming_soon': 'Coming soon',
      'home_unavailable': 'This system is not yet available.',
      'home_exit_title': 'Exit Application',
      'home_exit_content': 'Are you sure you want to exit MyLUNAS Mobile?',
      'home_exit_confirm': 'Exit',
      'home_cancel': 'Cancel',

      // Profile
      'profile_title': 'Profile & Settings',
      'profile_staff': 'LUNAS Staff',
      'profile_change_photo': 'Change profile photo',
      'profile_account_info': 'Account Information',
      'profile_email': 'Email',
      'profile_company': 'Company',
      'profile_company_name': 'Lumut Naval Shipyard',
      'profile_contact': 'Contact',
      'profile_mars_title': 'MARS Approval Settings',
      'profile_mars_saved': 'MARS credentials are saved',
      'profile_mars_empty': 'No MARS credentials — login page will be shown',
      'profile_mars_userid': 'MARS User ID',
      'profile_mars_password': 'MARS Password',
      'profile_mars_save': 'Save MARS Credentials',
      'profile_mars_delete': 'Remove MARS Credentials',
      'profile_mars_fill': 'Please enter MARS User ID and Password',
      'profile_mars_success': 'MARS credentials saved successfully!',
      'profile_mars_cleared': 'MARS credentials have been removed',
      'profile_app_info': 'Application Information',
      'profile_version': 'Version',
      'profile_developer': 'Developed by',
      'profile_copyright': 'Copyright',
      'profile_language': 'Bahasa / Language',
      'profile_logout': 'LOG OUT',
      'logout_title': 'Log Out',
      'logout_content': 'Are you sure you want to log out?',
      'logout_confirm': 'Log Out',
      'logout_cancel': 'Cancel',

      // Quote
      'quote_tap': 'Tap to continue',
      'quote_skip': 'Skip',
      'quote_exit': 'Exit',
    },
  };
}
