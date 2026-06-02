import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Privacy Policy', style: AppTextStyles.headlineMedium),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Last Updated: June 2026', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textHint)),
            const SizedBox(height: AppConstants.paddingL),
            _buildSection(
              '1. Information We Collect',
              'We collect basic profile information to personalize your app experience. This includes your email address when registering or logging in. We also collect details about your baby, such as their name, birth/due date, gender, height, and weight. Additionally, any photos or videos you upload to your private Memory Diary are securely stored.',
            ),
            _buildSection(
              '2. How We Use Your Data',
              'Your information is used strictly to deliver tailored parenting and pregnancy guidance. Specifically, we use your baby\'s age to compile daily milestones and weekly meal plans, schedule immunizations, and securely display your uploaded memories. We do not sell, lease, or distribute your personal data to third-party marketing companies.',
            ),
            _buildSection(
              '3. Data Storage & Security',
              'Your profile and baby details are securely stored in our Supabase cloud database using encrypted connections. Media uploads (photos/videos) are hosted on Cloudinary with secure URLs. We enforce robust security protocols to prevent unauthorized access, alteration, or disclosure of your data.',
            ),
            _buildSection(
              '4. Third-Party Services',
              'We utilize reputable third-party cloud integrations to run the app:\n'
              '• Supabase (Database, Auth, and Storage)\n'
              '• Cloudinary (Image & Video Hosting)\n'
              '• Groq/Google (AI Recipe & Tip Generation)\n\n'
              'These services adhere to strict industry-standard security and compliance policies.',
            ),
            _buildSection(
              '5. Control Over Your Data',
              'You retain complete ownership and control of your data. You can edit your profile details, delete individual memory entries, or reset all baby records. If you wish to delete your account permanently, you can do so via Profile -> Delete All My Data. This action immediately purges all database records and media files permanently.',
            ),
            _buildSection(
              '6. Contact Support',
              'For any questions, concerns, or requests regarding this Privacy Policy or your personal information, please reach out to our team at support@motherhood-app.com.',
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingXL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppConstants.paddingS),
          Text(
            content,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.5),
          ),
        ],
      ),
    );
  }
}
