import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

class ShipUpdatesScreen extends StatefulWidget {
  const ShipUpdatesScreen({super.key});

  @override
  State<ShipUpdatesScreen> createState() => _ShipUpdatesScreenState();
}

class _ShipUpdatesScreenState extends State<ShipUpdatesScreen> {
  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.inAppWebView);
      } else {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open page')),
      );
    }
  }

  Future<void> _callPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: Text(
          'Ship Updates & Alerts',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            tooltip: 'Open IRCTC Portal',
            icon: const Icon(Icons.open_in_browser_rounded, color: AppColors.primary),
            onPressed: () => _openUrl(AppConstants.shipAlertsUrl),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Official IRCTC Live Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0077B6), Color(0xFF0099E6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'OFFICIAL IRCTC PORTAL',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.directions_boat_filled_rounded, color: Colors.white, size: 24),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'ലക്ഷദ്വീപ് കപ്പൽ സർവീസ് തത്സമയ അറിയിപ്പുകൾ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'യാത്രാക്കപ്പലുകളുടെ സമയക്രമം, ടിക്കറ്റ് ബുക്കിംഗ്, കാലാവസ്ഥാ വ്യതിയാനങ്ങൾ എന്നിവയുടെ ഔദ്യോഗിക വിവരങ്ങൾ താഴെയുള്ള ബട്ടൺ വഴി തത്സമയം കാണാം.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _openUrl(AppConstants.shipAlertsUrl),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primaryDark,
                      minimumSize: const Size(double.infinity, 46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.campaign_rounded, size: 20),
                    label: const Text(
                      'Open Live Alerts & Announcements',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Quick Booking Action
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : AppColors.divider,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.confirmation_number_rounded, color: Colors.amber, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Online Ship Ticket Booking',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Book your passenger tickets directly',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _openUrl(AppConstants.shipBookingUrl),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                    child: const Text('Book Now'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Main Passenger Ships in Service
            Text(
              'Passenger Ships Fleet / യാത്രാക്കപ്പലുകൾ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),

            _buildShipTile(
              isDark: isDark,
              name: 'MV Kavaratti',
              nameMl: 'എം.വി കവരത്തി',
              capacity: '700 Passengers • All Weather Vessel',
              icon: Icons.directions_boat_rounded,
            ),
            _buildShipTile(
              isDark: isDark,
              name: 'MV Corals',
              nameMl: 'എം.വി കോറൽസ്',
              capacity: '400 Passengers • Modern Passenger Ship',
              icon: Icons.directions_boat_rounded,
            ),
            _buildShipTile(
              isDark: isDark,
              name: 'MV Lagoon',
              nameMl: 'എം.വി ലഗൂൺ',
              capacity: '400 Passengers • Modern Passenger Ship',
              icon: Icons.directions_boat_rounded,
            ),
            _buildShipTile(
              isDark: isDark,
              name: 'MV Arabian Sea',
              nameMl: 'എം.വി അറേബ്യൻ സീ',
              capacity: '250 Passengers • High Comfort',
              icon: Icons.directions_boat_rounded,
            ),
            _buildShipTile(
              isDark: isDark,
              name: 'MV Lakshadweep Sea',
              nameMl: 'എം.വി ലക്ഷദ്വീപ് സീ',
              capacity: '250 Passengers • High Comfort',
              icon: Icons.directions_boat_rounded,
            ),
            _buildShipTile(
              isDark: isDark,
              name: 'HSC Parali',
              nameMl: 'എച്ച്.എസ്.സി പറളി',
              capacity: 'Inter-Island High Speed Craft',
              icon: Icons.sailing_rounded,
            ),
            _buildShipTile(
              isDark: isDark,
              name: 'HSC Cheriyapani',
              nameMl: 'എച്ച്.എസ്.സി ചെറിയപാണി',
              capacity: 'Inter-Island High Speed Craft',
              icon: Icons.sailing_rounded,
            ),
            _buildShipTile(
              isDark: isDark,
              name: 'HSC Valiyapani',
              nameMl: 'എച്ച്.എസ്.സി വലിയപാണി',
              capacity: 'Inter-Island High Speed Craft',
              icon: Icons.sailing_rounded,
            ),
            _buildShipTile(
              isDark: isDark,
              name: 'HSC Black Marlin',
              nameMl: 'എച്ച്.എസ്.സി ബ്ലാക്ക് മാർലിൻ',
              capacity: 'Inter-Island High Speed Craft',
              icon: Icons.sailing_rounded,
            ),
            _buildShipTile(
              isDark: isDark,
              name: 'HSC Blue Marlin',
              nameMl: 'എച്ച്.എസ്.സി ബ്ലൂ മാർലിൻ',
              capacity: 'Inter-Island High Speed Craft',
              icon: Icons.sailing_rounded,
            ),
            _buildShipTile(
              isDark: isDark,
              name: 'HSC Skip Jack',
              nameMl: 'എച്ച്.എസ്.സി സ്കിപ്പ് ജാക്ക്',
              capacity: 'Inter-Island High Speed Craft',
              icon: Icons.sailing_rounded,
            ),

            const SizedBox(height: 24),

            // Port Offices Contact & Helplines
            Text(
              'Port Helpline Numbers / കൺട്രോൾ റൂം',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),

            _buildHelplineCard(
              isDark: isDark,
              title: 'Port Office Kochi (കൊച്ചി)',
              phone: '04842666111',
              subtitle: 'Willingdon Island Passenger Terminal',
            ),
            _buildHelplineCard(
              isDark: isDark,
              title: 'Port Office Beypore (ബേപ്പൂർ, കോഴിക്കോട്)',
              phone: '04952414074',
              subtitle: 'Beypore Port Terminal Office',
            ),
            _buildHelplineCard(
              isDark: isDark,
              title: 'Directorate of Port Services (കവരത്തി)',
              phone: '04896262255',
              subtitle: 'Kavaratti Island Central Control Room',
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildShipTile({
    required bool isDark,
    required String name,
    required String nameMl,
    required String capacity,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : AppColors.divider,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '($nameMl)',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  capacity,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelplineCard({
    required bool isDark,
    required String title,
    required String phone,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : AppColors.divider,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Call $phone',
            icon: const Icon(Icons.phone_in_talk_rounded, color: AppColors.primary),
            onPressed: () => _callPhone(phone),
          ),
        ],
      ),
    );
  }
}
