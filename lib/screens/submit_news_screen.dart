import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

class SubmitNewsScreen extends StatefulWidget {
  const SubmitNewsScreen({super.key});

  @override
  State<SubmitNewsScreen> createState() => _SubmitNewsScreenState();
}

class _SubmitNewsScreenState extends State<SubmitNewsScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _storyController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];

  final List<String> _islands = [
    'Kavaratti (കവരത്തി)',
    'Agatti (അഗത്തി)',
    'Amini (അമിനി)',
    'Andrott (ആന്ത്രോത്ത്)',
    'Kalpeni (കൽപ്പേനി)',
    'Kiltan (കിൽത്താൻ)',
    'Chetlat (ചെത്ലത്ത്)',
    'Kadmat (കടമത്ത്)',
    'Minicoy (മിനിക്കോയ്)',
    'Bitra (ബിത്ര)',
    'Kochi (കൊച്ചി)',
    'Other (മറ്റുള്ളവ)',
  ];

  late String _selectedIsland;

  @override
  void initState() {
    super.initState();
    _selectedIsland = _islands.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _storyController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.camera) {
        final photo = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
        if (photo != null) {
          setState(() {
            _selectedImages.add(photo);
          });
        }
      } else {
        final photos = await _picker.pickMultiImage(imageQuality: 85);
        if (photos.isNotEmpty) {
          setState(() {
            _selectedImages.addAll(photos);
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not access photos')),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _sendToWhatsAppDesk() async {
    final title = _titleController.text.trim();
    final story = _storyController.text.trim();
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a headline for the news')),
      );
      return;
    }

    if (story.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the news story details')),
      );
      return;
    }

    final message = '''
📰 *DWEEP DIARY - CITIZEN NEWS SUBMISSION*
━━━━━━━━━━━━━━━━━━━━
📌 *Headline:*
$title

📍 *Island/Region:*
$_selectedIsland

👤 *Reporter Name:*
${name.isEmpty ? 'Reader' : name}

📞 *Contact Phone:*
${phone.isEmpty ? 'Not provided' : phone}

📝 *News Story Details:*
$story

━━━━━━━━━━━━━━━━━━━━
Official Editorial Desk: ${AppConstants.whatsAppEditorialNumber}
''';

    // Always open WhatsApp directly with Dweep Diary Editorial Desk (+918289883750)
    // without ever opening the contact picker!
    final cleanPhone = '918289883750';
    final directWaUri = Uri.parse('whatsapp://send?phone=$cleanPhone&text=${Uri.encodeComponent(message)}');
    final webWaUri = Uri.parse('https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}');

    try {
      if (await canLaunchUrl(directWaUri)) {
        await launchUrl(directWaUri, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(webWaUri)) {
        await launchUrl(webWaUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(webWaUri, mode: LaunchMode.platformDefault);
      }

      if (_selectedImages.isNotEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Dweep Diary WhatsApp തുറന്നു. തിരഞ്ഞെടുത്ത ചിത്രങ്ങൾ അയക്കാൻ ചാറ്റിലെ 📎 (Attach) ഐക്കൺ ക്ലിക്ക് ചെയ്യുക.',
            ),
            duration: Duration(seconds: 5),
            backgroundColor: Color(0xFF1EBE5D),
          ),
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open WhatsApp. Please check if WhatsApp is installed.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: Text(
          'Submit News',
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Editorial Notice Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : AppColors.primaryLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : AppColors.primary.withOpacity(0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.verified_user_rounded, color: AppColors.primary, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Editorial Verification',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isDark ? Colors.white : AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'നിങ്ങൾ അയക്കുന്ന വാർത്തകളും ചിത്രങ്ങളും ദ്വീപ് ഡയറി എഡിറ്റോറിയൽ ഡെസ്ക് പരിശോധിച്ച് ഉറപ്പുവരുത്തിയ ശേഷം മാത്രമേ പ്രസിദ്ധീകരിക്കുകയുള്ളൂ.',
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.5,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'WhatsApp Desk: ${AppConstants.whatsAppEditorialNumber}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1EBE5D),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Headline Field
            Text(
              'News Headline / വാർത്തയുടെ തലക്കെട്ട് *',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'ഉദാ: ലക്ഷദ്വീപിൽ പുതിയ യാത്രാക്കപ്പൽ സർവീസ് തുടങ്ങി...',
                hintStyle: TextStyle(
                  color: isDark ? Colors.white38 : AppColors.textSecondary,
                  fontSize: 13,
                ),
                filled: true,
                fillColor: isDark ? AppColors.darkSurface : Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: isDark ? const Color(0xFF334155) : AppColors.divider,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Island Selection Dropdown
            Text(
              'Select Island / പ്രദേശം *',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : AppColors.divider,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedIsland,
                  isExpanded: true,
                  dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
                  items: _islands.map((String island) {
                    return DropdownMenuItem<String>(
                      value: island,
                      child: Text(
                        island,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedIsland = newValue;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // News Details Field
            Text(
              'News Details / വാർത്തയുടെ വിവരങ്ങൾ *',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _storyController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'എവിടെ, എപ്പോൾ, എന്താണ് സംഭവിച്ചത് എന്ന പൂർണ്ണ വിവരങ്ങൾ ഇവിടെ രേഖപ്പെടുത്തുക...',
                hintStyle: TextStyle(
                  color: isDark ? Colors.white38 : AppColors.textSecondary,
                  fontSize: 13,
                ),
                filled: true,
                fillColor: isDark ? AppColors.darkSurface : Colors.white,
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: isDark ? const Color(0xFF334155) : AppColors.divider,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Photos Section (Add from Gallery / Camera)
            Text(
              'Attach News Photos / ചിത്രങ്ങൾ ചേർക്കാം (${_selectedImages.length})',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.photo_library_rounded, size: 18),
                  label: const Text('Gallery'),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.camera_alt_rounded, size: 18),
                  label: const Text('Camera'),
                ),
              ],
            ),

            if (_selectedImages.isNotEmpty) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 85,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(_selectedImages[index].path),
                            width: 85,
                            height: 85,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 2,
                          right: 2,
                          child: InkWell(
                            onTap: () => _removeImage(index),
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close_rounded, size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Reporter Name & Phone
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Name / പേര്',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'Name',
                          hintStyle: TextStyle(
                            color: isDark ? Colors.white38 : AppColors.textSecondary,
                            fontSize: 13,
                          ),
                          filled: true,
                          fillColor: isDark ? AppColors.darkSurface : Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: isDark ? const Color(0xFF334155) : AppColors.divider,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Phone / ഫോൺ നമ്പർ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: 'WhatsApp No',
                          hintStyle: TextStyle(
                            color: isDark ? Colors.white38 : AppColors.textSecondary,
                            fontSize: 13,
                          ),
                          filled: true,
                          fillColor: isDark ? AppColors.darkSurface : Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: isDark ? const Color(0xFF334155) : AppColors.divider,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // WhatsApp Direct Submission Button
            ElevatedButton.icon(
              onPressed: _sendToWhatsAppDesk,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.send_rounded, size: 20),
              label: Text(
                _selectedImages.isNotEmpty
                    ? 'Send News & ${_selectedImages.length} Photos via WhatsApp'
                    : 'Send to Dweep Diary WhatsApp Desk',
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
