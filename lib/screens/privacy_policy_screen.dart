import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  Future<void> _openInBrowser(BuildContext context) async {
    final uri = Uri.parse(AppConstants.privacyPolicyUrl);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.inAppBrowserView)) {
        await launchUrl(uri, mode: LaunchMode.inAppWebView);
      }
    } catch (_) {
      try {
        await launchUrl(uri, mode: LaunchMode.inAppWebView);
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open browser')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        elevation: 0.8,
        title: Text(
          'Privacy Policy',
          style: TextStyle(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            tooltip: 'Open in Browser',
            icon: const Icon(Icons.open_in_browser_rounded, color: AppColors.primary),
            onPressed: () => _openInBrowser(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF0D3B66), const Color(0xFF001F3F)]
                      : [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/drawer_logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.shield_outlined,
                          size: 30,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Dweep Diary Privacy Policy',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Official News Portal of Lakshadweep (www.dweepdiary.in)',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _buildSectionCard(
              isDark: isDark,
              icon: Icons.info_outline_rounded,
              title: 'Introduction',
              content:
                  'Welcome to Dweep Diary. Your privacy is important to us, and we are committed to protecting it. This Privacy Policy outlines how we handle user information when you use our mobile application and visit our website, www.dweepdiary.in.',
            ),

            _buildSectionCard(
              isDark: isDark,
              icon: Icons.person_off_outlined,
              title: '1. Information We Collect',
              content:
                  'We do not collect any personal data from users who visit our portal or use our mobile app. Dweep Diary is designed to provide authentic news, notices, and updates from Lakshadweep without requiring visitors to create an account or share any personal information.',
            ),

            _buildSectionCard(
              isDark: isDark,
              icon: Icons.verified_user_outlined,
              title: '2. How We Use Your Information',
              content:
                  'Since we do not collect any user data, we do not use or process any personal information. Our platform is purely informational and public-service oriented.',
            ),

            _buildSectionCard(
              isDark: isDark,
              icon: Icons.share_outlined,
              title: '3. Sharing Your Information',
              content:
                  'As we do not collect any personal information, there is no user data to sell, rent, or share with third parties.',
            ),

            _buildSectionCard(
              isDark: isDark,
              icon: Icons.storage_rounded,
              title: '4. Data Retention',
              content:
                  'We do not retain any personal information as none is collected during your use of our application or website.',
            ),

            _buildSectionCard(
              isDark: isDark,
              icon: Icons.security_rounded,
              title: '5. Data Security',
              content:
                  'While we do not collect personal user data, we implement modern SSL/TLS encryption and security protocols to ensure your connection to Dweep Diary is safe and protected.',
            ),

            _buildSectionCard(
              isDark: isDark,
              icon: Icons.cookie_outlined,
              title: '6. Cookies and Tracking Technologies',
              content:
                  'Our mobile application does not use tracking cookies to monitor personal behavior or collect personally identifiable information.',
            ),

            _buildSectionCard(
              isDark: isDark,
              icon: Icons.link_rounded,
              title: '7. Third-Party Links & Services',
              content:
                  'Dweep Diary may contain links to external sites (such as official administration portals or YouTube videos). We are not responsible for the privacy practices or content of third-party platforms. We encourage you to review their policies.',
            ),

            _buildSectionCard(
              isDark: isDark,
              icon: Icons.gavel_rounded,
              title: '8. Your Rights',
              content:
                  'Because we do not store or process personal data, there is no private data to delete or manage. If you have any inquiries or editorial concerns, you may contact our editorial desk anytime.',
            ),

            _buildSectionCard(
              isDark: isDark,
              icon: Icons.child_care_rounded,
              title: '9. Children\'s Privacy',
              content:
                  'Our application is family-friendly and news-focused. We do not collect personal data from minors or any age groups.',
            ),

            _buildSectionCard(
              isDark: isDark,
              icon: Icons.update_rounded,
              title: '10. Changes to This Privacy Policy',
              content:
                  'We may periodically update this policy to reflect any feature changes or regulatory requirements. Any updates will be published with the revised date.',
            ),

            const SizedBox(height: 12),

            // Contact & Help Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? Colors.white12 : Colors.black.withOpacity(0.06),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Contact Us Regarding Privacy',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Email: ${AppConstants.officialEmail}\nPhone: ${AppConstants.officialPhoneDisplay}\nKiltan Island, Lakshadweep - 682558',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => _openInBrowser(context),
                      icon: const Icon(Icons.open_in_new_rounded, size: 16),
                      label: const Text('View on Official Website'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required bool isDark,
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black.withOpacity(0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.45,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
