import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class KnowledgeResource {
  final String id;
  final String title;
  final String description;
  final String category;
  final String sourceName;
  final String sourceUrl;
  final String resourceType;
  final String readTime;
  final String imageUrl;
  final bool isFeatured;
  final bool isTrending;
  final int sortOrder;

  const KnowledgeResource({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.sourceName,
    required this.sourceUrl,
    required this.resourceType,
    required this.readTime,
    required this.imageUrl,
    this.isFeatured = false,
    this.isTrending = false,
    this.sortOrder = 0,
  });

  factory KnowledgeResource.fromJson(Map<String, dynamic> json) {
    return KnowledgeResource(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      sourceName: json['source_name'] as String? ?? 'Trusted source',
      sourceUrl: json['source_url'] as String,
      resourceType: json['resource_type'] as String? ?? 'Guide',
      readTime: json['read_time'] as String? ?? 'Read',
      imageUrl: json['image_url'] as String? ?? '',
      isFeatured: json['is_featured'] as bool? ?? false,
      isTrending: json['is_trending'] as bool? ?? false,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }

  static Color colorForCategory(String category) {
    switch (category) {
      case 'Pregnancy':
        return AppColors.accentPink;
      case 'Newborn Care':
        return AppColors.accentOrange;
      case 'Feeding & Nutrition':
        return AppColors.accentGreen;
      case 'Sleep & Safety':
        return AppColors.primary;
      case 'Child Development':
        return AppColors.accentBlue;
      case 'Postpartum':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  static Color lightColorForCategory(String category) {
    switch (category) {
      case 'Pregnancy':
        return AppColors.accentPinkLight;
      case 'Newborn Care':
        return AppColors.accentOrangeLight;
      case 'Feeding & Nutrition':
        return AppColors.accentGreenLight;
      case 'Sleep & Safety':
        return AppColors.primaryLight;
      case 'Child Development':
        return AppColors.accentBlueLight;
      case 'Postpartum':
        return const Color(0xFFFFEBEE);
      default:
        return AppColors.primaryLight;
    }
  }

  static String emojiForCategory(String category) {
    switch (category) {
      case 'Pregnancy':
        return '🤰';
      case 'Newborn Care':
        return '🍼';
      case 'Feeding & Nutrition':
        return '🥗';
      case 'Sleep & Safety':
        return '🌙';
      case 'Child Development':
        return '🧠';
      case 'Postpartum':
        return '💗';
      default:
        return '📚';
    }
  }
}

const fallbackKnowledgeResources = <KnowledgeResource>[
  KnowledgeResource(
    id: 'acog-postpartum-care',
    title: 'Postpartum care and the weeks after birth',
    description:
        'ACOG guidance on postpartum visits, recovery questions, emotions, breastfeeding, contraception, and future health.',
    category: 'Postpartum',
    sourceName: 'ACOG',
    sourceUrl: 'https://www.acog.org/womens-health/faqs/having-a-baby',
    resourceType: 'FAQ',
    readTime: '8 min read',
    imageUrl: 'https://images.unsplash.com/photo-1544126592-807ade215a0b?w=600',
    isFeatured: true,
    isTrending: true,
    sortOrder: 1,
  ),
  KnowledgeResource(
    id: 'acog-exercise-after-pregnancy',
    title: 'Exercise after pregnancy',
    description:
        'When movement can resume after birth, how to restart safely, and why postpartum activity supports recovery.',
    category: 'Postpartum',
    sourceName: 'ACOG',
    sourceUrl:
        'https://www.acog.org/womens-health/faqs/exercise-after-pregnancy',
    resourceType: 'FAQ',
    readTime: '7 min read',
    imageUrl:
        'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=600',
    isFeatured: true,
    sortOrder: 2,
  ),
  KnowledgeResource(
    id: 'acog-postpartum-depression',
    title: 'Postpartum depression: signs and support',
    description:
        'ACOG guidance on baby blues, postpartum depression, when to call your ob-gyn, and treatment options.',
    category: 'Postpartum',
    sourceName: 'ACOG',
    sourceUrl: 'https://www.acog.org/womens-health/faqs/postpartum-depression',
    resourceType: 'FAQ',
    readTime: '8 min read',
    imageUrl:
        'https://images.unsplash.com/photo-1512290923902-8a9f81dc236c?w=600',
    isTrending: true,
    sortOrder: 3,
  ),
  KnowledgeResource(
    id: 'acog-postpartum-birth-control',
    title: 'Postpartum birth control options',
    description:
        'A practical guide to choosing contraception after birth, including timing and breastfeeding considerations.',
    category: 'Postpartum',
    sourceName: 'ACOG',
    sourceUrl:
        'https://www.acog.org/womens-health/faqs/postpartum-birth-control',
    resourceType: 'FAQ',
    readTime: '9 min read',
    imageUrl:
        'https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=600',
    sortOrder: 4,
  ),
  KnowledgeResource(
    id: 'cdc-pregnancy-vaccines',
    title: 'Vaccine recommendations during pregnancy',
    description:
        'CDC recommendations for vaccines before, during, and after pregnancy to help protect mother and baby.',
    category: 'Pregnancy',
    sourceName: 'CDC',
    sourceUrl:
        'https://www.cdc.gov/vaccines-pregnancy/recommended-vaccines/index.html',
    resourceType: 'Guide',
    readTime: '6 min read',
    imageUrl: 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=600',
    isFeatured: true,
    sortOrder: 5,
  ),
  KnowledgeResource(
    id: 'aap-umbilical-cord-care',
    title: 'Umbilical cord care in newborns',
    description:
        'AAP guidance on keeping the cord stump clean and dry, warning signs, and when to call the pediatrician.',
    category: 'Newborn Care',
    sourceName: 'HealthyChildren.org / AAP',
    sourceUrl:
        'https://www.healthychildren.org/English/ages-stages/baby/bathing-skin-care/pages/Umbilical-Cord-Care.aspx',
    resourceType: 'Guide',
    readTime: '5 min read',
    imageUrl:
        'https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?w=600',
    isFeatured: true,
    sortOrder: 6,
  ),
  KnowledgeResource(
    id: 'cdc-breastfeeding-guidance',
    title: 'Breastfeeding recommendations and guidance',
    description:
        'CDC guidance on breastfeeding duration, expressed milk, cleaning feeding items, and support systems.',
    category: 'Feeding & Nutrition',
    sourceName: 'CDC',
    sourceUrl:
        'https://www.cdc.gov/breastfeeding/php/guidelines-recommendations/index.html',
    resourceType: 'Guide',
    readTime: '6 min read',
    imageUrl:
        'https://images.unsplash.com/photo-1590641935647-1c8f2d4f1f59?w=600',
    isTrending: true,
    sortOrder: 7,
  ),
  KnowledgeResource(
    id: 'cdc-vitamin-d-breastfeeding',
    title: 'Vitamin D and breastfeeding',
    description:
        'CDC information on vitamin D needs for breastfed and partially breastfed infants.',
    category: 'Feeding & Nutrition',
    sourceName: 'CDC',
    sourceUrl:
        'https://www.cdc.gov/breastfeeding-special-circumstances/hcp/diet-micronutrients/vitamin-d.html',
    resourceType: 'Clinical note',
    readTime: '4 min read',
    imageUrl:
        'https://images.unsplash.com/photo-1526256262350-7da7584cf5eb?w=600',
    sortOrder: 8,
  ),
  KnowledgeResource(
    id: 'cdc-safe-sleep',
    title: 'Helping babies sleep safely',
    description:
        'CDC safe sleep steps based on AAP recommendations to reduce sleep-related infant death risk.',
    category: 'Sleep & Safety',
    sourceName: 'CDC',
    sourceUrl:
        'https://www.cdc.gov/sudden-infant-death/sleep-safely/index.html',
    resourceType: 'Safety guide',
    readTime: '7 min read',
    imageUrl: 'https://images.unsplash.com/photo-1555252333-9f8e92e65df9?w=600',
    isFeatured: true,
    isTrending: true,
    sortOrder: 10,
  ),
  KnowledgeResource(
    id: 'aap-safe-sleep',
    title: 'AAP policy explained: safe sleep',
    description:
        'AAP safe sleep recommendations explained for families, including back sleeping and a firm, flat surface.',
    category: 'Sleep & Safety',
    sourceName: 'HealthyChildren.org / AAP',
    sourceUrl:
        'https://www.healthychildren.org/English/ages-stages/baby/sleep/Pages/A-Parents-Guide-to-Safe-Sleep.aspx',
    resourceType: 'Policy explainer',
    readTime: '10 min read',
    imageUrl: 'https://images.unsplash.com/photo-1546015720-b8b30df5aa27?w=600',
    sortOrder: 10,
  ),
  KnowledgeResource(
    id: 'cdc-developmental-milestones',
    title: 'CDC developmental milestones',
    description:
        'Milestone checklists and guidance for tracking how children play, learn, speak, act, and move.',
    category: 'Child Development',
    sourceName: 'CDC',
    sourceUrl: 'https://www.cdc.gov/milestones',
    resourceType: 'Checklist hub',
    readTime: '6 min read',
    imageUrl:
        'https://images.unsplash.com/photo-1566004100631-35d015d6a491?w=600',
    isFeatured: true,
    isTrending: true,
    sortOrder: 11,
  ),
  KnowledgeResource(
    id: 'cdc-positive-parenting-infants',
    title: 'Positive parenting tips for infants',
    description:
        'CDC tips for nurturing, protecting, and supporting development during the first year.',
    category: 'Child Development',
    sourceName: 'CDC',
    sourceUrl:
        'https://www.cdc.gov/child-development/positive-parenting-tips/infants.html',
    resourceType: 'Guide',
    readTime: '6 min read',
    imageUrl:
        'https://images.unsplash.com/photo-1519689680058-324335c77eba?w=600',
    sortOrder: 12,
  ),
  KnowledgeResource(
    id: 'acog-postpartum-recovery-video',
    title: 'Postpartum recovery after birth',
    description:
        'ACOG video resource on physical and emotional recovery after having a baby.',
    category: 'Postpartum',
    sourceName: 'ACOG',
    sourceUrl: 'https://www.acog.org/womens-health/videos/postpartum-recovery',
    resourceType: 'Video',
    readTime: 'Watch',
    imageUrl: 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=600',
    isFeatured: true,
    sortOrder: 13,
  ),
  KnowledgeResource(
    id: 'cdc-hear-her-stories-video',
    title: 'Hear Her: pregnancy and postpartum warning signs',
    description:
        'CDC campaign videos and stories that help families recognize urgent maternal warning signs.',
    category: 'Postpartum',
    sourceName: 'CDC',
    sourceUrl: 'https://www.cdc.gov/hearher/personal-stories/index.html',
    resourceType: 'Video',
    readTime: 'Watch',
    imageUrl:
        'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=600',
    isTrending: true,
    sortOrder: 14,
  ),
  KnowledgeResource(
    id: 'nichd-safe-to-sleep-videos',
    title: 'Safe to Sleep videos',
    description:
        'NICHD videos for families on creating a safe sleep environment for babies.',
    category: 'Sleep & Safety',
    sourceName: 'NICHD',
    sourceUrl:
        'https://safetosleep.nichd.nih.gov/resources/social-digital/videos',
    resourceType: 'Video',
    readTime: 'Watch',
    imageUrl: 'https://images.unsplash.com/photo-1546015720-b8b30df5aa27?w=600',
    sortOrder: 15,
  ),
  KnowledgeResource(
    id: 'cdc-milestones-videos',
    title: 'Milestones in action videos',
    description:
        'CDC video examples of developmental milestones by age to help parents know what to look for.',
    category: 'Child Development',
    sourceName: 'CDC',
    sourceUrl:
        'https://www.cdc.gov/ncbddd/actearly/milestones/milestones-in-action.html',
    resourceType: 'Video',
    readTime: 'Watch',
    imageUrl:
        'https://images.unsplash.com/photo-1566004100631-35d015d6a491?w=600',
    sortOrder: 16,
  ),
  KnowledgeResource(
    id: 'acog-postpartum-depression-audio',
    title: 'Postpartum depression podcast',
    description:
        'ACOG audio conversation about postpartum depression, symptoms, and getting help.',
    category: 'Postpartum',
    sourceName: 'ACOG',
    sourceUrl:
        'https://www.acog.org/womens-health/experts-and-stories/the-latest/postpartum-depression',
    resourceType: 'Audio',
    readTime: 'Listen',
    imageUrl:
        'https://images.unsplash.com/photo-1516280440614-37939bbacd81?w=600',
    isTrending: true,
    sortOrder: 17,
  ),
  KnowledgeResource(
    id: 'nih-safe-to-sleep-audio',
    title: 'Safe infant sleep audio resources',
    description:
        'NICHD Safe to Sleep audio and media resources for family education.',
    category: 'Sleep & Safety',
    sourceName: 'NICHD',
    sourceUrl:
        'https://safetosleep.nichd.nih.gov/resources/social-digital/audio',
    resourceType: 'Audio',
    readTime: 'Listen',
    imageUrl:
        'https://images.unsplash.com/photo-1516280440614-37939bbacd81?w=600',
    sortOrder: 18,
  ),
];
