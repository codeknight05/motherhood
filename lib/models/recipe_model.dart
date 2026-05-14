class RecipeIngredient {
  final String name;
  final String quantity;
  final String? imageUrl;

  const RecipeIngredient({
    required this.name,
    required this.quantity,
    this.imageUrl,
  });
}

class RecipeStep {
  final int stepNumber;
  final String title;
  final String? description;

  const RecipeStep({
    required this.stepNumber,
    required this.title,
    this.description,
  });
}

enum RecipeCategory {
  breakfast,
  midMorning,
  lunch,
  eveningSnack,
  dinner,
  bedtime,
}

extension RecipeCategoryExt on RecipeCategory {
  String get label {
    switch (this) {
      case RecipeCategory.breakfast:    return 'Breakfast';
      case RecipeCategory.midMorning:   return 'Mid Morning';
      case RecipeCategory.lunch:        return 'Lunch';
      case RecipeCategory.eveningSnack: return 'Evening Snack';
      case RecipeCategory.dinner:       return 'Dinner';
      case RecipeCategory.bedtime:      return 'Bedtime';
    }
  }

  String get emoji {
    switch (this) {
      case RecipeCategory.breakfast:    return '🌅';
      case RecipeCategory.midMorning:   return '🍎';
      case RecipeCategory.lunch:        return '☀️';
      case RecipeCategory.eveningSnack: return '🌤️';
      case RecipeCategory.dinner:       return '🌙';
      case RecipeCategory.bedtime:      return '🍼';
    }
  }
}

class RecipeModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final int cookTimeMinutes;
  final int calories;
  final String tag; // e.g. "Summer special", "High Protein"
  final String benefit; // short benefit text
  final List<String> ageGroups; // e.g. ['6-8 Months', '9-12 Months']
  final RecipeCategory category;
  final List<RecipeIngredient> ingredients;
  final List<RecipeStep> steps;
  final String howToServe;
  final bool isBookmarked;

  const RecipeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.cookTimeMinutes,
    required this.calories,
    required this.tag,
    required this.benefit,
    required this.ageGroups,
    required this.category,
    required this.ingredients,
    required this.steps,
    required this.howToServe,
    this.isBookmarked = false,
  });

  RecipeModel copyWith({bool? isBookmarked}) {
    return RecipeModel(
      id: id,
      name: name,
      description: description,
      imageUrl: imageUrl,
      cookTimeMinutes: cookTimeMinutes,
      calories: calories,
      tag: tag,
      benefit: benefit,
      ageGroups: ageGroups,
      category: category,
      ingredients: ingredients,
      steps: steps,
      howToServe: howToServe,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}

// ─── Sample Recipes ───────────────────────────────────────────────────────────

final sampleRecipes = <RecipeModel>[
  RecipeModel(
    id: '1',
    name: 'Moong Dal Khichdi',
    description:
        'A wholesome, easy-to-digest one-pot meal made with moong dal and rice. '
        'Rich in protein and carbohydrates, this is one of the best first foods '
        'for babies starting solids. The soft texture makes it perfect for little ones.',
    imageUrl: 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=600',
    cookTimeMinutes: 20,
    calories: 120,
    tag: 'High Protein',
    benefit: 'Easy to digest',
    ageGroups: ['6-8 Months', '9-12 Months'],
    category: RecipeCategory.breakfast,
    ingredients: [
      RecipeIngredient(name: 'Moong Dal (split)', quantity: '2 tbsp'),
      RecipeIngredient(name: 'Rice', quantity: '2 tbsp'),
      RecipeIngredient(name: 'Ghee', quantity: '1 tsp'),
      RecipeIngredient(name: 'Cumin seeds', quantity: '¼ tsp'),
      RecipeIngredient(name: 'Water', quantity: '1 cup'),
      RecipeIngredient(name: 'Salt', quantity: 'A pinch (optional)'),
    ],
    steps: [
      RecipeStep(stepNumber: 1, title: 'Wash and soak', description: 'Wash moong dal and rice together. Soak for 15 minutes.'),
      RecipeStep(stepNumber: 2, title: 'Temper the ghee', description: 'Heat ghee in a pressure cooker. Add cumin seeds and let them splutter.'),
      RecipeStep(stepNumber: 3, title: 'Add dal and rice', description: 'Add the soaked dal and rice. Stir for 1 minute.'),
      RecipeStep(stepNumber: 4, title: 'Pressure cook', description: 'Add water and pressure cook for 3–4 whistles until very soft.'),
      RecipeStep(stepNumber: 5, title: 'Mash and serve', description: 'Mash well to a smooth consistency. Add more water if needed.'),
    ],
    howToServe:
        'Serve warm at room temperature.\nFor younger babies (6–7 months), blend to a smooth puree.\nFor older babies, leave slightly textured.',
  ),

  RecipeModel(
    id: '2',
    name: 'Carrot & Potato Puree',
    description:
        'A naturally sweet and vibrant puree packed with beta-carotene and vitamins. '
        'Carrots provide Vitamin A for eye health while potato adds energy-giving carbohydrates. '
        'This is a perfect first food for babies starting solids.',
    imageUrl: 'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=600',
    cookTimeMinutes: 15,
    calories: 85,
    tag: 'Rich in Vit A',
    benefit: 'Supports eye health',
    ageGroups: ['6-8 Months', '9-12 Months'],
    category: RecipeCategory.lunch,
    ingredients: [
      RecipeIngredient(name: 'Carrot', quantity: '1 medium'),
      RecipeIngredient(name: 'Potato', quantity: '1 small'),
      RecipeIngredient(name: 'Ghee', quantity: '½ tsp'),
      RecipeIngredient(name: 'Water', quantity: 'As needed'),
    ],
    steps: [
      RecipeStep(stepNumber: 1, title: 'Peel and chop', description: 'Peel carrot and potato. Chop into small cubes.'),
      RecipeStep(stepNumber: 2, title: 'Steam', description: 'Steam the vegetables for 10–12 minutes until completely soft.'),
      RecipeStep(stepNumber: 3, title: 'Blend', description: 'Blend with a little water to a smooth puree.'),
      RecipeStep(stepNumber: 4, title: 'Add ghee', description: 'Mix in ghee for healthy fats and better nutrient absorption.'),
    ],
    howToServe:
        'Serve warm.\nFor 6-month babies, blend very smooth.\nFor 8+ months, leave slightly chunky to encourage chewing.',
  ),

  RecipeModel(
    id: '3',
    name: 'Ragi Porridge',
    description:
        'Ragi (finger millet) is a nutritional powerhouse — rich in calcium, iron, and fibre. '
        'This simple porridge is one of the best foods for growing babies and is a '
        'traditional Indian weaning food used for generations.',
    imageUrl: 'https://images.unsplash.com/photo-1517093157656-b9eccef91cb1?w=600',
    cookTimeMinutes: 15,
    calories: 110,
    tag: 'High in Calcium',
    benefit: 'Good for bones',
    ageGroups: ['6-8 Months', '9-12 Months', '1-2 Years'],
    category: RecipeCategory.eveningSnack,
    ingredients: [
      RecipeIngredient(name: 'Ragi flour', quantity: '2 tbsp'),
      RecipeIngredient(name: 'Breast milk / Formula', quantity: '½ cup'),
      RecipeIngredient(name: 'Water', quantity: '½ cup'),
      RecipeIngredient(name: 'Jaggery powder', quantity: '1 tsp (optional, 8M+)'),
    ],
    steps: [
      RecipeStep(stepNumber: 1, title: 'Mix ragi', description: 'Mix ragi flour with water to form a lump-free paste.'),
      RecipeStep(stepNumber: 2, title: 'Cook', description: 'Cook on low flame, stirring continuously for 5–7 minutes.'),
      RecipeStep(stepNumber: 3, title: 'Add milk', description: 'Add breast milk or formula and stir well.'),
      RecipeStep(stepNumber: 4, title: 'Sweeten', description: 'For babies 8 months+, add a pinch of jaggery powder.'),
      RecipeStep(stepNumber: 5, title: 'Cool and serve', description: 'Cool to room temperature before serving.'),
    ],
    howToServe:
        'Serve warm but not hot.\nFor 6-month babies, keep thin consistency.\nFor older babies, make it thicker.',
  ),

  RecipeModel(
    id: '4',
    name: 'Lauki Halwa (Bottle Gourd Halwa)',
    description:
        'A wholesome Indian dessert made with bottle gourd, milk, and natural sweeteners '
        'like jaggery or dates. This healthier version of lauki halwa is nourishing, '
        'delicious, and perfect as an occasional treat for babies 10 months and older.',
    imageUrl: 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=600',
    cookTimeMinutes: 50,
    calories: 220,
    tag: 'Summer special',
    benefit: 'Cooling & nourishing',
    ageGroups: ['10-12 Months', '1-2 Years'],
    category: RecipeCategory.dinner,
    ingredients: [
      RecipeIngredient(name: 'Bottle Gourd (Lauki)', quantity: '3 cups grated'),
      RecipeIngredient(name: 'Powdered jaggery', quantity: '4–5 tbsp'),
      RecipeIngredient(name: 'Ghee', quantity: '3 tbsp'),
      RecipeIngredient(name: 'Milk', quantity: '1.5 cups'),
      RecipeIngredient(name: 'Cardamom powder', quantity: '¼ tsp'),
      RecipeIngredient(name: 'Almonds chopped', quantity: '1 tbsp'),
      RecipeIngredient(name: 'Cashews', quantity: '1 tbsp, chopped'),
    ],
    steps: [
      RecipeStep(stepNumber: 1, title: 'Prepare the Lauki', description: 'Peel, grate and squeeze out excess water from the bottle gourd.'),
      RecipeStep(stepNumber: 2, title: 'Boil the Milk', description: 'Bring milk to a boil in a heavy-bottomed pan.'),
      RecipeStep(stepNumber: 3, title: 'Cook the Lauki', description: 'Add grated lauki to the milk. Cook on medium flame, stirring often.'),
      RecipeStep(stepNumber: 4, title: 'Add Milk', description: 'Continue cooking until the mixture thickens and milk is absorbed.'),
      RecipeStep(stepNumber: 5, title: 'Sweeten Naturally', description: 'Add jaggery powder and cardamom. Mix well.'),
      RecipeStep(stepNumber: 6, title: 'Finish', description: 'Add ghee and cook for 2–3 more minutes.'),
      RecipeStep(stepNumber: 7, title: 'Garnish & Serve', description: 'Top with chopped almonds and cashews.'),
    ],
    howToServe:
        'Serve warm in winter.\nServe chilled in summer.\nGreat as an occasional dessert or festive treat.',
  ),

  RecipeModel(
    id: '5',
    name: 'Mashed Banana',
    description:
        'The simplest and most nutritious first food for babies. Bananas are naturally '
        'sweet, easy to digest, and packed with potassium and energy. No cooking required!',
    imageUrl: 'https://images.unsplash.com/photo-1490818387583-1baba5e638af?w=600',
    cookTimeMinutes: 5,
    calories: 90,
    tag: 'Rich in Potassium',
    benefit: 'Good for energy',
    ageGroups: ['6-8 Months', '9-12 Months'],
    category: RecipeCategory.midMorning,
    ingredients: [
      RecipeIngredient(name: 'Ripe banana', quantity: '½ medium'),
      RecipeIngredient(name: 'Breast milk / Formula', quantity: '1–2 tbsp (optional)'),
    ],
    steps: [
      RecipeStep(stepNumber: 1, title: 'Choose ripe banana', description: 'Use a fully ripe banana with brown spots for maximum sweetness.'),
      RecipeStep(stepNumber: 2, title: 'Mash', description: 'Mash with a fork until completely smooth.'),
      RecipeStep(stepNumber: 3, title: 'Thin if needed', description: 'Add breast milk or formula to thin the consistency for younger babies.'),
    ],
    howToServe:
        'Serve immediately after mashing — banana oxidises quickly.\nDo not store mashed banana.',
  ),

  RecipeModel(
    id: '6',
    name: 'Lauki Moong Dal Puree',
    description:
        'A light, easily digestible dinner option combining the cooling properties of '
        'bottle gourd with the protein of moong dal. Perfect for babies who need a '
        'gentle, soothing meal before bedtime.',
    imageUrl: 'https://images.unsplash.com/photo-1555252333-9f8e92e65df9?w=600',
    cookTimeMinutes: 20,
    calories: 95,
    tag: 'Light & Soothing',
    benefit: 'Good for sleep',
    ageGroups: ['6-8 Months', '9-12 Months'],
    category: RecipeCategory.dinner,
    ingredients: [
      RecipeIngredient(name: 'Lauki (bottle gourd)', quantity: '¼ cup chopped'),
      RecipeIngredient(name: 'Moong dal', quantity: '2 tbsp'),
      RecipeIngredient(name: 'Cumin seeds', quantity: '¼ tsp'),
      RecipeIngredient(name: 'Ghee', quantity: '½ tsp'),
      RecipeIngredient(name: 'Water', quantity: '1 cup'),
    ],
    steps: [
      RecipeStep(stepNumber: 1, title: 'Wash dal', description: 'Wash moong dal thoroughly.'),
      RecipeStep(stepNumber: 2, title: 'Pressure cook', description: 'Pressure cook lauki and dal together with water for 3 whistles.'),
      RecipeStep(stepNumber: 3, title: 'Temper', description: 'Heat ghee, add cumin seeds, let splutter.'),
      RecipeStep(stepNumber: 4, title: 'Blend', description: 'Blend the cooked dal and lauki to a smooth puree.'),
      RecipeStep(stepNumber: 5, title: 'Mix and serve', description: 'Add the tempering to the puree. Serve warm.'),
    ],
    howToServe:
        'Serve warm before bedtime.\nThe light nature of this dish aids digestion and promotes better sleep.',
  ),
];

// Weekly meal plan data
final sampleWeeklyMealPlan = {
  'Mon': [
    {'meal': 'Breakfast', 'time': '8:00 AM', 'recipe': sampleRecipes[0], 'emoji': '🌅'},
    {'meal': 'Mid Morning', 'time': '10:30 AM', 'recipe': sampleRecipes[4], 'emoji': '🍎'},
    {'meal': 'Lunch', 'time': '1:00 PM', 'recipe': sampleRecipes[1], 'emoji': '☀️'},
    {'meal': 'Evening Snack', 'time': '4:00 PM', 'recipe': sampleRecipes[2], 'emoji': '🌤️'},
    {'meal': 'Dinner', 'time': '7:00 PM', 'recipe': sampleRecipes[5], 'emoji': '🌙'},
  ],
  'Tue': [
    {'meal': 'Breakfast', 'time': '8:00 AM', 'recipe': sampleRecipes[2], 'emoji': '🌅'},
    {'meal': 'Mid Morning', 'time': '10:30 AM', 'recipe': sampleRecipes[4], 'emoji': '🍎'},
    {'meal': 'Lunch', 'time': '1:00 PM', 'recipe': sampleRecipes[0], 'emoji': '☀️'},
    {'meal': 'Evening Snack', 'time': '4:00 PM', 'recipe': sampleRecipes[1], 'emoji': '🌤️'},
    {'meal': 'Dinner', 'time': '7:00 PM', 'recipe': sampleRecipes[5], 'emoji': '🌙'},
  ],
};
