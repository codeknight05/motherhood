import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';

class HelpFaqScreen extends StatelessWidget {
  const HelpFaqScreen({super.key});

  static const List<Map<String, String>> _faqs = [
    {
      'question': 'What is MotherHood?',
      'answer': 'MotherHood is your dedicated parenting and pregnancy companion. We provide personalized weekly guidelines, custom nutrition meal plans, vaccination trackers, and a private memory diary to help you navigate every stage of motherhood.'
    },
    {
      'question': 'Is the advice in the app medical?',
      'answer': 'No. All insights, milestones, nutrition advice, and guides are for informational and educational purposes only. MotherHood does not provide medical advice. Always consult with a qualified pediatrician or healthcare provider for any medical concerns.'
    },
    {
      'question': 'How do vaccination reminders work?',
      'answer': 'Based on your baby\'s birth date, the app schedules recommended immunizations. You can track when they are due, mark them as completed, and enter custom dates if they have already been administered.'
    },
    {
      'question': 'How are the meal plans customized?',
      'answer': 'We generate weekly meal plans tailored to your baby\'s age group (e.g., 6–8 months, 9–12 months). You can customize meal slots, view step-by-step recipes, and automatically compile shopping lists for the week.'
    },
    {
      'question': 'Where is my data stored?',
      'answer': 'Your profile, baby progress, and milestones are securely stored in Supabase. Photos and videos in your Memory Diary are uploaded securely to Cloudinary. You can delete all your data permanently at any time from your Profile settings.'
    },
    {
      'question': 'Can I use the app during pregnancy?',
      'answer': 'Yes! The app features a dedicated pregnancy mode showing weekly trimester guides, baby size estimations, prenatal care reminders, and hydration goals to support you throughout your pregnancy.'
    },
  ];

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
        title: Text('Help & FAQ', style: AppTextStyles.headlineMedium),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.paddingL),
        itemCount: _faqs.length,
        itemBuilder: (context, index) {
          final faq = _faqs[index];
          return Container(
            margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppConstants.radiusL),
              border: Border.all(color: AppColors.divider),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                iconColor: AppColors.primary,
                collapsedIconColor: AppColors.textHint,
                tilePadding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL, vertical: 4),
                title: Text(
                  faq['question']!,
                  style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: AppConstants.paddingL,
                      right: AppConstants.paddingL,
                      bottom: AppConstants.paddingL,
                    ),
                    child: Text(
                      faq['answer']!,
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
