import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_card.dart';

class AllergyGuideScreen extends StatelessWidget {
  const AllergyGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: AppConstants.paddingL),
                _buildHeroBanner(),
                const SizedBox(height: AppConstants.paddingL),
                _buildThreeDayRuleSection(),
                const SizedBox(height: AppConstants.paddingXL),
                _buildDangerFoodsSection(context),
                const SizedBox(height: AppConstants.paddingXL),
                _buildCommonAllergensSection(),
                const SizedBox(height: AppConstants.paddingXL),
                _buildSymptomCheckerSection(context),
                const SizedBox(height: AppConstants.paddingXL),
                _buildActionPlanSection(),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text('Allergy Guide', style: AppTextStyles.headlineMedium),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: AppColors.accentBlue.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Safety First 🛡️',
                  style: AppTextStyles.headlineMedium.copyWith(color: const Color(0xFF0D47A1)),
                ),
                const SizedBox(height: 4),
                Text(
                  'Introducing solid foods is a milestone. Learn to recognize allergens and introduce new foods safely.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFF1565C0),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Text('👶', style: TextStyle(fontSize: 48)),
        ],
      ),
    );
  }

  Widget _buildThreeDayRuleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('The Golden Safety Rule ⏳', style: AppTextStyles.headlineSmall),
        const SizedBox(height: AppConstants.paddingS),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('3️⃣', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: AppConstants.paddingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('The 3-Day Rule', style: AppTextStyles.titleLarge),
                        const SizedBox(height: 2),
                        Text(
                          'Introduce only ONE new single-ingredient food at a time (e.g., pureed apple) and wait 3 full days before introducing another new food.',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppConstants.paddingM),
                child: Divider(color: AppColors.divider),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🔍', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: AppConstants.paddingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Why wait?', style: AppTextStyles.titleLarge),
                        const SizedBox(height: 2),
                        Text(
                          'If your baby has an allergic reaction (like a rash or tummy upset), waiting 3 days makes it easy to isolate and identify exactly which food caused the reaction.',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDangerFoodsSection(BuildContext context) {
    final dangerFoods = [
      {
        'emoji': '🍯',
        'title': 'Honey',
        'reason': 'Contains botulism spores which can release toxins in an infant\'s immature digestive tract.',
        'age': 'Strictly avoid before 12 Months'
      },
      {
        'emoji': '🥛',
        'title': 'Cow\'s Milk',
        'reason': 'Hard to digest and contains high concentrations of proteins and minerals that can stress baby\'s kidneys.',
        'age': 'Strictly avoid before 12 Months'
      },
      {
        'emoji': '🧂',
        'title': 'Salt & Sugar',
        'reason': 'Added salt strains tiny kidneys; added sugar contributes to tooth decay and sets a preference for sweet food.',
        'age': 'Avoid adding to baby\'s food'
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Danger Foods (First Year) ⚠️', style: AppTextStyles.headlineSmall),
        Text('Avoid giving these items to babies under 1 year of age.', style: AppTextStyles.bodySmall),
        const SizedBox(height: AppConstants.paddingM),
        ...dangerFoods.map((food) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppConstants.paddingM),
            child: AppCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(food['emoji']!, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: AppConstants.paddingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(food['title']!, style: AppTextStyles.titleLarge),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.accentPinkLight,
                                borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                              ),
                              child: Text(
                                food['age']!,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.accentPink,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(food['reason']!, style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCommonAllergensSection() {
    final allergens = [
      {'emoji': '🥜', 'title': 'Peanuts & Tree Nuts', 'advice': 'Introduce in a smooth form (never whole nuts) diluted with water or breast milk.'},
      {'emoji': '🥚', 'title': 'Eggs', 'advice': 'Ensure egg whites and yolks are fully cooked. Scrambled or hard-boiled mash is ideal.'},
      {'emoji': '🥛', 'title': 'Dairy products', 'advice': 'While liquid cow\'s milk should be avoided, yogurt and plain paneer are generally well tolerated after 8M.'},
      {'emoji': '🌾', 'title': 'Wheat & Soy', 'advice': 'Introduce wheat via soft rotis or baby cereals. Soy can be introduced through plain tofu puree.'},
      {'emoji': '🐟', 'title': 'Fish & Shellfish', 'advice': 'Ensure fish is completely deboned and fully cooked. Puree or mash finely.'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Common Food Allergens 🍳', style: AppTextStyles.headlineSmall),
        Text('Introduce these one-by-one with caution.', style: AppTextStyles.bodySmall),
        const SizedBox(height: AppConstants.paddingM),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: allergens.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Padding(
                padding: EdgeInsets.only(right: index < allergens.length - 1 ? AppConstants.paddingM : 0),
                child: Container(
                  width: 180,
                  height: 180,
                  padding: const EdgeInsets.all(AppConstants.paddingM),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppConstants.radiusL),
                    border: Border.all(color: AppColors.divider),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['emoji']!, style: const TextStyle(fontSize: 28)),
                      const SizedBox(height: 6),
                      Text(item['title']!, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Expanded(
                        child: Text(
                          item['advice']!,
                          style: AppTextStyles.labelSmall.copyWith(fontSize: 10),
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSymptomCheckerSection(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 500;

    final mildCard = Container(
      padding: const EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(
        color: AppColors.accentOrangeLight,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: AppColors.accentOrange.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🟡', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
              Text(
                'Mild Symptoms',
                style: AppTextStyles.titleMedium.copyWith(color: AppColors.accentOrange, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildBulletText('• Skin hives or redness'),
          _buildBulletText('• Mild rash or itching'),
          _buildBulletText('• Rubbing eyes or nose'),
          _buildBulletText('• Diarrhea or spit up'),
        ],
      ),
    );

    final severeCard = Container(
      padding: const EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(
        color: AppColors.accentPinkLight,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: AppColors.accentPink.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🔴', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
              Text(
                'Severe Symptoms',
                style: AppTextStyles.titleMedium.copyWith(color: AppColors.accentPink, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildBulletText('• Swelling of lips/tongue'),
          _buildBulletText('• Trouble breathing'),
          _buildBulletText('• Persistent vomiting'),
          _buildBulletText('• Wheezing or coughing'),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Reaction Symptom Checker 🩺', style: AppTextStyles.headlineSmall),
        Text('Monitor your baby for up to 2 hours after feeding.', style: AppTextStyles.bodySmall),
        const SizedBox(height: AppConstants.paddingM),
        if (isSmallScreen) ...[
          mildCard,
          const SizedBox(height: AppConstants.paddingM),
          severeCard,
        ] else
          Row(
            children: [
              Expanded(child: mildCard),
              const SizedBox(width: AppConstants.paddingM),
              Expanded(child: severeCard),
            ],
          ),
      ],
    );
  }

  Widget _buildBulletText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(text, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textPrimary)),
    );
  }

  Widget _buildActionPlanSection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🚨', style: TextStyle(fontSize: 24)),
              const SizedBox(width: AppConstants.paddingM),
              Expanded(
                child: Text('Emergency Action Plan', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '1. Stop feeding the food immediately if you notice any reaction.',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 6),
          Text(
            '2. Call your pediatrician for advice if symptoms are mild.',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 6),
          Text(
            '3. Go to the nearest emergency room immediately or call an ambulance if the baby has difficulty breathing, severe facial swelling, or goes limp.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
