import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

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
        title: Text('Terms of Service', style: AppTextStyles.headlineMedium),
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
              '1. Acceptance of Terms',
              'By accessing, downloading, or using the Moms of Tomorrow mobile application ("the App"), you agree to be bound by these Terms of Service. If you do not agree to these terms, you are not authorized to use the App and must uninstall it immediately.',
            ),
            _buildSection(
              '2. Eligibility',
              'You must be at least 18 years of age (or the age of majority in your jurisdiction) and be a parent, expectant parent, or legal guardian to register an account and use the features provided in the App.',
            ),
            _buildSection(
              '3. NO MEDICAL ADVICE DISCLAIMER',
              'THE CONTENT, GUIDELINES, MEAL PLANS, RECIPES, MILESTONES, AND TIPS PROVIDED WITHIN THE APP ARE FOR GENERAL INFORMATIONAL AND EDUCATIONAL PURPOSES ONLY. THEY DO NOT CONSTITUTE MEDICAL ADVICE, DIAGNOSIS, OR TREATMENT. ALWAYS CONSULT A QUALIFIED PEDIATRICIAN, DOCTOR, OR HEALTHCARE PROVIDER CONCERNING THE HEALTH AND WELL-BEING OF YOURSELF AND YOUR BABY. NEVER DISREGARD PROFESSIONAL MEDICAL ADVICE BECAUSE OF SOMETHING READ IN THIS APP.',
            ),
            _buildSection(
              '4. User Accounts & Content',
              'You are responsible for keeping your login credentials confidential. You retain ownership of all media (photos, videos, notes) uploaded to your Memory Diary. However, you grant the App a license to process and store this content solely for displaying it back to you. You agree not to upload any offensive, unlawful, or infringing content.',
            ),
            _buildSection(
              '5. Limitation of Liability',
              'To the maximum extent permitted by law, Moms of Tomorrow, its developers, and affiliates shall not be liable for any direct, indirect, special, incidental, consequential, or exemplary damages arising out of your use of, or inability to use, the App. This includes health decisions made based on general advice rendered by the App.',
            ),
            _buildSection(
              '6. Changes to Services & Terms',
              'We reserve the right to modify, suspend, or discontinue any part of the App or revise these terms at any time. Continued use of the App following any update constitutes acceptance of the revised Terms of Service.',
            ),
            _buildSection(
              '7. Governing Law',
              'These terms shall be governed by and construed in accordance with the laws of your local jurisdiction, without regard to conflict of law principles.',
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
