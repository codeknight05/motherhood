-- ============================================================
-- MotherHood — Weekly Meal Plans & Recipes Setup (Updated for Age Groups)
-- ============================================================

-- 1. Schema Migration: Add age_group column to weekly_meal_plans
alter table public.weekly_meal_plans add column if not exists age_group text;

-- Reset existing data
truncate table public.weekly_meal_plans cascade;
truncate table public.recipes cascade;

-- ── Seed Recipes ─────────────────────────────────────────────

-- 1. Healthy Pregnancy Recipes (101 to 128)
insert into public.recipes (id, name, description, image_url, cook_time_minutes, calories, tag, benefit, age_groups, category, ingredients, steps, how_to_serve)
values
(
  '101', 'Vegetable Poha & Boiled Egg',
  'A light and iron-rich flattened rice dish loaded with fresh veggies, served with a protein-packed boiled egg.',
  'https://images.unsplash.com/photo-1601050690597-df056fb4ce78?w=600', 15, 280, 'Iron & Protein Rich', 'Steady morning energy',
  array['pregnant'], 'breakfast',
  '[{"name": "Poha (Flattened rice)", "quantity": "1 cup"}, {"name": "Boiled Egg (or Paneer)", "quantity": "1 large"}, {"name": "Mixed vegetables", "quantity": "½ cup"}, {"name": "Peanuts", "quantity": "1 tbsp"}, {"name": "Ghee / Oil", "quantity": "1 tsp"}, {"name": "Glass of milk", "quantity": "1 glass"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Rinse Poha", "description": "Rinse poha in a colander under running water and keep aside to drain."}, {"stepNumber": 2, "title": "Saute vegetables", "description": "Heat oil in a pan, roast peanuts, then saute mustard seeds, curry leaves, onions, and vegetables."}, {"stepNumber": 3, "title": "Combine", "description": "Add turmeric, salt, and drained poha. Mix gently. Cook for 2 minutes."}, {"stepNumber": 4, "title": "Plate & Serve", "description": "Plate the poha with a boiled egg or paneer cubes on the side and a glass of warm milk."}]'::jsonb,
  'Serve hot with a squeeze of fresh lemon juice.'
),
(
  '102', 'Chapatis with Dal & Mixed Veg',
  'A classic, balanced meal containing fiber-rich whole wheat chapatis, protein-dense yellow dal, and mixed vegetable curry, served with curd and salad.',
  'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=600', 30, 420, 'Fibre & Protein', 'Supports red blood cells',
  array['pregnant'], 'lunch',
  '[{"name": "Whole wheat chapatis", "quantity": "2 pieces"}, {"name": "Yellow Dal", "quantity": "1 cup"}, {"name": "Mixed vegetable curry", "quantity": "1 cup"}, {"name": "Plain Curd", "quantity": "½ cup"}, {"name": "Fresh Salad", "quantity": "1 bowl"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Boil dal", "description": "Pressure cook yellow split lentils with turmeric, cumin, and ginger."}, {"stepNumber": 2, "title": "Cook vegetables", "description": "Saute carrots, peas, and cauliflower with minimal spices and ghee."}, {"stepNumber": 3, "title": "Roll chapatis", "description": "Prepare soft whole wheat chapatis on a tawa."}, {"stepNumber": 4, "title": "Serve", "description": "Serve chapatis warm alongside the dal, veg curry, curd, and fresh salad."}]'::jsonb,
  'Serve warm as a wholesome lunch.'
),
(
  '103', 'Apple & Almonds snack',
  'A quick and refreshing snack combining dietary fiber from apples with healthy monounsaturated fats from raw almonds.',
  'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=600', 5, 160, 'Healthy Fats & Fiber', 'Boosts brain power',
  array['pregnant'], 'eveningSnack',
  '[{"name": "Red Apple", "quantity": "1 medium"}, {"name": "Raw Almonds", "quantity": "1 handful"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Chop apple", "description": "Wash, core, and slice the apple into wedges."}, {"stepNumber": 2, "title": "Serve", "description": "Arrange apple slices on a plate with almonds."}]'::jsonb,
  'Eat fresh as a nutritious mid-afternoon or evening snack.'
),
(
  '104', 'Brown Rice with Rajma & Salad',
  'A nourishing dinner of complex carbohydrates from brown rice and folate-rich red kidney beans (Rajma) curry, completed with a refreshing cucumber salad.',
  'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=600', 35, 380, 'High Folate & Fiber', 'Digestive comfort',
  array['pregnant'], 'dinner',
  '[{"name": "Cooked Brown Rice", "quantity": "1 cup"}, {"name": "Rajma (Kidney beans) curry", "quantity": "1 cup"}, {"name": "Cucumber salad", "quantity": "1 bowl"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Cook Rajma", "description": "Soak Rajma overnight. Pressure cook and simmer in onion-tomato gravy with ginger and garlic."}, {"stepNumber": 2, "title": "Steam rice", "description": "Steam brown rice until tender."}, {"stepNumber": 3, "title": "Serve", "description": "Serve kidney bean curry hot over brown rice with cucumber salad."}]'::jsonb,
  'Serve warm.'
),
(
  '105', 'Vegetable Upma & Chutney',
  'A classic South Indian breakfast made with semolina, carrots, and beans, served with coconut chutney and milk.',
  'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=600', 20, 290, 'Complex Carbs', 'Steady energy release',
  array['pregnant'], 'breakfast',
  '[{"name": "Semolina (Suji)", "quantity": "½ cup"}, {"name": "Mixed vegetables", "quantity": "½ cup"}, {"name": "Ghee", "quantity": "1 tsp"}, {"name": "Coconut chutney", "quantity": "2 tbsp"}, {"name": "Glass of milk", "quantity": "1 glass"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Roast Suji", "description": "Dry roast semolina on low flame until aromatic and keep aside."}, {"stepNumber": 2, "title": "Saute veggies", "description": "Saute mustard seeds, ginger, curry leaves, and veggies in ghee."}, {"stepNumber": 3, "title": "Boil and mix", "description": "Add water, bring to boil, and slowly stir in suji to avoid lumps. Simmer for 2 minutes."}, {"stepNumber": 4, "title": "Serve", "description": "Serve warm with coconut chutney and a glass of milk."}]'::jsonb,
  'Serve hot.'
),
(
  '106', 'Chapatis with Chole & Veg Sabzi',
  'Chickpeas (Chole) cooked in aromatic spices, providing plant-based iron and protein, served with whole wheat chapatis and salad.',
  'https://images.unsplash.com/photo-1589302168068-964664d93dc0?w=600', 30, 440, 'Iron & Protein Rich', 'Supports fetal tissue growth',
  array['pregnant'], 'lunch',
  '[{"name": "Chapatis", "quantity": "2 pieces"}, {"name": "Chole (Chickpea curry)", "quantity": "1 cup"}, {"name": "Vegetable sabzi", "quantity": "1 cup"}, {"name": "Salad", "quantity": "1 bowl"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Cook chickpeas", "description": "Soak chickpeas, boil them, and cook in onion, tomato, and spices gravy."}, {"stepNumber": 2, "title": "Prepare sabzi", "description": "Stir fry mixed vegetables with a pinch of turmeric and cumin."}, {"stepNumber": 3, "title": "Serve", "description": "Serve hot chickpea curry with soft chapatis, vegetable sabzi, and fresh salad."}]'::jsonb,
  'Serve warm.'
),
(
  '107', 'Roasted Chana & Buttermilk',
  'Crunchy dry-roasted chickpeas rich in protein and fiber, paired with refreshing probiotic-filled buttermilk.',
  'https://images.unsplash.com/photo-1517093157656-b9eccef91cb1?w=600', 5, 180, 'Low Fat & High Protein', 'Supports digestion & hydration',
  array['pregnant', 'postpartum'], 'eveningSnack',
  '[{"name": "Roasted Chana", "quantity": "1 small bowl"}, {"name": "Fresh Buttermilk", "quantity": "1 glass"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Prepare buttermilk", "description": "Whisk curd with water, add a pinch of black salt and roasted cumin powder."}, {"stepNumber": 2, "title": "Serve", "description": "Serve roasted chana on a plate alongside the buttermilk."}]'::jsonb,
  'Enjoy immediately.'
),
(
  '108', 'Vegetable Khichdi & Curd',
  'A soothing, comforting one-pot dinner of rice, lentils, and mixed veggies, served with cooling curd and carrot salad.',
  'https://images.unsplash.com/photo-1596797038530-2c107229654b?w=600', 25, 340, 'Easy to Digest', 'Gentle on stomach',
  array['pregnant'], 'dinner',
  '[{"name": "Rice & Lentils mixture", "quantity": "1 cup"}, {"name": "Mixed chopped vegetables", "quantity": "½ cup"}, {"name": "Curd", "quantity": "½ cup"}, {"name": "Carrot salad", "quantity": "1 bowl"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Pressure cook", "description": "Pressure cook washed rice, moong dal, and vegetables together with ghee and cumin seeds for 3 whistles."}, {"stepNumber": 2, "title": "Plate", "description": "Serve hot khichdi topped with a little ghee alongside fresh curd and carrot salad."}]'::jsonb,
  'Serve warm.'
),
(
  '109', 'Oats Porridge with Nuts & Banana',
  'Warm oatmeal cooked in milk, enriched with crunchy chopped almonds, walnuts, and sliced banana.',
  'https://images.unsplash.com/photo-1517686469429-8bdb88b9f907?w=600', 15, 310, 'High Fiber & Calcium', 'Promotes bone & heart health',
  array['pregnant'], 'breakfast',
  '[{"name": "Rolled Oats", "quantity": "½ cup"}, {"name": "Milk", "quantity": "1 cup"}, {"name": "Banana", "quantity": "1 medium"}, {"name": "Mixed chopped nuts", "quantity": "2 tbsp"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Cook oats", "description": "Simmer oats in milk on medium heat until thick and cooked (5-7 minutes)."}, {"stepNumber": 2, "title": "Assemble", "description": "Pour oats porridge into a bowl. Slice banana on top and sprinkle with chopped nuts."}]'::jsonb,
  'Serve hot.'
),
(
  '110', 'Rice with Sambar & Beans Poriyal',
  'Fibre-packed South Indian beans poriyal cooked with grated coconut, served with steamed rice, lentil vegetable sambar, and curd.',
  'https://images.unsplash.com/photo-1589302168068-964664d93dc0?w=600', 30, 400, 'Antioxidant Rich', 'Supports cell protection',
  array['pregnant', 'postpartum'], 'lunch',
  '[{"name": "Steamed Rice", "quantity": "1 cup"}, {"name": "Vegetable Sambar", "quantity": "1 cup"}, {"name": "Beans poriyal", "quantity": "½ cup"}, {"name": "Curd", "quantity": "½ cup"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Boil sambar", "description": "Cook pigeon peas (toor dal) with tamarind and mixed vegetables like drumsticks and pumpkin."}, {"stepNumber": 2, "title": "Steam beans", "description": "Saute chopped green beans with mustard seeds, curry leaves, and grated coconut."}, {"stepNumber": 3, "title": "Serve", "description": "Serve steamed rice hot with vegetable sambar poured over, alongside beans poriyal and curd."}]'::jsonb,
  'Serve warm.'
),
(
  '111', 'Sprouts Chaat',
  'A healthy, protein-rich snack made of green gram sprouts tossed with onions, tomatoes, and tangy lemon.',
  'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=600', 10, 150, 'Protein & Folate Rich', 'Supports tissue repair & growth',
  array['pregnant', 'postpartum'], 'eveningSnack',
  '[{"name": "Boiled Sprouts (Moong)", "quantity": "1 cup"}, {"name": "Onion & Tomato chopped", "quantity": "4 tbsp"}, {"name": "Mint & Coriander leaves", "quantity": "2 tbsp"}, {"name": "Lemon juice", "quantity": "1 tsp"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Toss ingredients", "description": "Combine boiled sprouts, chopped onions, tomatoes, coriander, green chili (optional), salt, and cumin powder in a bowl."}, {"stepNumber": 2, "title": "Lemon squeeze", "description": "Drizzle with lemon juice and mix well before serving."}]'::jsonb,
  'Serve fresh.'
),
(
  '112', 'Chapatis with Paneer Curry & Veg',
  'Paneer cooked in tomato gravy, providing bone-strengthening calcium, served with whole wheat chapatis.',
  'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=600', 25, 450, 'Calcium & Protein Rich', 'Supports baby''s bone development',
  array['pregnant', 'postpartum'], 'dinner',
  '[{"name": "Chapatis", "quantity": "2 pieces"}, {"name": "Paneer curry", "quantity": "1 cup"}, {"name": "Mixed vegetable stir-fry", "quantity": "1 cup"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Cook paneer", "description": "Saute paneer cubes in tomato gravy with mild spices and a splash of milk or cashew paste."}, {"stepNumber": 2, "title": "Stir-fry veg", "description": "Stir-fry bell peppers, broccoli, and peas with olive oil and cumin."}, {"stepNumber": 3, "title": "Serve", "description": "Serve paneer curry hot with whole wheat chapatis and mixed veggies."}]'::jsonb,
  'Serve warm.'
),
(
  '113', 'Moong Dal Chilla & Mint Chutney',
  'Savory pancakes made with soaked moong dal paste, served with zesty mint chutney and fresh fruit.',
  'https://images.unsplash.com/photo-1601050690597-df056fb4ce78?w=600', 20, 260, 'High Protein & Folate', 'Supports red blood cells',
  array['pregnant', 'postpartum'], 'breakfast',
  '[{"name": "Moong dal batter", "quantity": "1 cup"}, {"name": "Grated carrots", "quantity": "3 tbsp"}, {"name": "Mint chutney", "quantity": "2 tbsp"}, {"name": "Fresh fruit (orange/papaya)", "quantity": "1 piece"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Prepare batter", "description": "Blend soaked yellow moong dal with ginger into a smooth batter. Mix in salt and grated carrots."}, {"stepNumber": 2, "title": "Cook chilla", "description": "Pour a ladle of batter onto a hot greased griddle. Cook both sides until golden brown."}, {"stepNumber": 3, "title": "Serve", "description": "Serve warm with mint chutney and fresh fruit."}]'::jsonb,
  'Serve fresh.'
),
(
  '114', 'Chapatis with Dal & Palak Sabzi',
  'Folate-packed spinach (Palak) stir-fry paired with comforting lentil dal and whole wheat chapatis.',
  'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=600', 25, 410, 'Folate & Iron Heavy', 'Essential for blood & neural cells',
  array['pregnant', 'postpartum'], 'lunch',
  '[{"name": "Chapatis", "quantity": "2 pieces"}, {"name": "Yellow Dal", "quantity": "1 cup"}, {"name": "Palak (Spinach) sabzi", "quantity": "1 cup"}, {"name": "Plain Curd", "quantity": "½ cup"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Saute spinach", "description": "Heat ghee, add cumin, and saute chopped spinach with garlic and mild spices until cooked."}, {"stepNumber": 2, "title": "Assemble", "description": "Serve chapatis with hot yellow dal, spinach sabzi, and curd."}]'::jsonb,
  'Serve warm.'
),
(
  '115', 'Fruit Smoothie',
  'A healthy, dairy-based drink blended with mixed berries, banana, yogurt, and honey.',
  'https://images.unsplash.com/photo-1553530666-ba11a7da3888?w=600', 10, 200, 'Antioxidant & Calcium', 'Hydrating & bone-supporting',
  array['pregnant'], 'eveningSnack',
  '[{"name": "Mixed Berries", "quantity": "½ cup"}, {"name": "Banana", "quantity": "½ medium"}, {"name": "Yogurt", "quantity": "½ cup"}, {"name": "Milk", "quantity": "½ cup"}, {"name": "Honey", "quantity": "1 tsp"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Blend", "description": "Blend berries, banana, yogurt, milk, and honey until completely smooth. Pour into a glass."}]'::jsonb,
  'Serve chilled.'
),
(
  '116', 'Vegetable Pulao & Raita',
  'An aromatic rice dish loaded with peas, carrots, and beans, served with cooling yogurt raita.',
  'https://images.unsplash.com/photo-1589302168068-964664d93dc0?w=600', 30, 360, 'Fibre & Probiotics', 'Supports digestive balance',
  array['pregnant', 'postpartum'], 'dinner',
  '[{"name": "Basmati rice cooked", "quantity": "1 cup"}, {"name": "Mixed vegetables", "quantity": "½ cup"}, {"name": "Yogurt (for Raita)", "quantity": "½ cup"}, {"name": "Cucumber & Tomato", "quantity": "¼ cup chopped"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Cook pulao", "description": "Saute whole spices and veggies. Add soaked rice and water. Cook on low heat until fluffy."}, {"stepNumber": 2, "title": "Prepare raita", "description": "Whisk yogurt with chopped cucumber, tomato, salt, and roasted cumin powder."}, {"stepNumber": 3, "title": "Serve", "description": "Serve pulao warm alongside the cooling raita."}]'::jsonb,
  'Serve hot.'
),
(
  '117', 'Idli & Sambar',
  'Steamed fermented rice cakes, easily digestible and gentle on the gut, served with vegetable sambar.',
  'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=600', 25, 240, 'Probiotic & Easy Digest', 'Gut health & energy',
  array['pregnant', 'postpartum'], 'breakfast',
  '[{"name": "Idlis", "quantity": "2 pieces"}, {"name": "Vegetable Sambar", "quantity": "1 cup"}, {"name": "Glass of milk", "quantity": "1 glass"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Steam Idlis", "description": "Pour fermented idli batter into idli moulds and steam for 10-12 minutes."}, {"stepNumber": 2, "title": "Assemble", "description": "Serve soft steamed idlis warm with piping hot vegetable sambar and a glass of milk."}]'::jsonb,
  'Serve warm.'
),
(
  '118', 'Rice with Fish Curry & Stir Fry',
  'Fresh, omega-3 rich fish (or high-protein soybean) curry, served with steamed rice and stir-fry.',
  'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=600', 30, 460, 'Omega-3 & Protein Rich', 'Essential for brain development & recovery',
  array['pregnant', 'postpartum'], 'lunch',
  '[{"name": "Steamed Rice", "quantity": "1 cup"}, {"name": "Fish Curry (or Soybean curry)", "quantity": "1 cup"}, {"name": "Vegetable stir-fry", "quantity": "1 cup"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Cook fish/soy", "description": "Simmer fish fillets or soaked soy chunks in coconut-tomato gravy with curry leaves."}, {"stepNumber": 2, "title": "Stir fry", "description": "Briefly stir fry cabbage, carrots, and bell peppers in mustard oil."}, {"stepNumber": 3, "title": "Serve", "description": "Serve fish/soy curry hot over steamed rice alongside the vegetable stir fry."}]'::jsonb,
  'Serve hot.'
),
(
  '119', 'Walnuts & Orange',
  'Omega-3 rich walnuts paired with a fresh orange containing Vitamin C to assist with recovery.',
  'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=600', 5, 190, 'Omega-3 & Vit C', 'Brain health & immunity',
  array['pregnant', 'postpartum'], 'eveningSnack',
  '[{"name": "Orange", "quantity": "1 medium"}, {"name": "Walnuts", "quantity": "1 handful"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Peel orange", "description": "Peel and segment the orange."}, {"stepNumber": 2, "title": "Assemble", "description": "Serve orange segments with walnuts on a plate."}]'::jsonb,
  'Eat fresh.'
),
(
  '120', 'Chapatis with Mixed Dal & Veg',
  'A high-fiber comforting dinner of chapatis, multi-lentil mixed dal, and green vegetable curry.',
  'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=600', 25, 390, 'Balanced Protein & Fiber', 'Digestive comfort',
  array['pregnant', 'postpartum'], 'dinner',
  '[{"name": "Chapatis", "quantity": "2 pieces"}, {"name": "Mixed Dal", "quantity": "1 cup"}, {"name": "Mixed vegetable curry", "quantity": "1 cup"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Cook mixed dal", "description": "Boil toor dal, moong dal, and masoor dal together. Temper with ghee, cumin, and garlic."}, {"stepNumber": 2, "title": "Serve", "description": "Serve hot mixed dal with whole wheat chapatis and mixed vegetable curry."}]'::jsonb,
  'Serve warm.'
),
(
  '121', 'Whole Wheat Veg Sandwich & Milk',
  'A toasted whole wheat sandwich stuffed with paneer and cucumbers, served with warm milk.',
  'https://images.unsplash.com/photo-1525351484163-7529414344d8?w=600', 15, 270, 'Calcium & Protein', 'Sustained energy',
  array['pregnant', 'postpartum'], 'breakfast',
  '[{"name": "Whole wheat bread", "quantity": "2 slices"}, {"name": "Paneer & Veggies", "quantity": "½ cup"}, {"name": "Ghee / Butter", "quantity": "1 tsp"}, {"name": "Glass of milk", "quantity": "1 glass"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Assemble sandwich", "description": "Place sliced paneer, tomato, and cucumber between bread slices. Toast in a pan with ghee until crispy."}, {"stepNumber": 2, "title": "Serve", "description": "Serve warm sandwich with a glass of milk."}]'::jsonb,
  'Serve warm.'
),
(
  '122', 'Chapatis with Paneer Bhurji',
  'Crumbled paneer scrambled with onions, capsicum, and tomatoes. High in protein and calcium.',
  'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=600', 20, 430, 'Protein & Calcium Heavy', 'Supports baby''s growth & recovery',
  array['pregnant', 'postpartum'], 'lunch',
  '[{"name": "Chapatis", "quantity": "2 pieces"}, {"name": "Paneer bhurji", "quantity": "1 cup"}, {"name": "Salad", "quantity": "1 bowl"}, {"name": "Curd", "quantity": "½ cup"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Cook Paneer", "description": "Saute onions, green chilies, ginger, and tomatoes. Add crumbled paneer and spice powders. Cook for 5 minutes."}, {"stepNumber": 2, "title": "Serve", "description": "Serve warm scrambled paneer with chapatis, fresh salad, and curd."}]'::jsonb,
  'Serve warm.'
),
(
  '123', 'Corn Chaat',
  'Boiled sweet corn kernels tossed with tomatoes, lime juice, and a pinch of black salt.',
  'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=600', 10, 160, 'High Fiber', 'Boosts digestion',
  array['pregnant', 'postpartum'], 'eveningSnack',
  '[{"name": "Boiled sweet corn", "quantity": "1 cup"}, {"name": "Chopped tomato", "quantity": "3 tbsp"}, {"name": "Lemon juice", "quantity": "1 tsp"}, {"name": "Coriander", "quantity": "1 tbsp"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Mix", "description": "Toss boiled corn, chopped tomato, coriander, salt, and lemon juice in a bowl. Mix thoroughly."}]'::jsonb,
  'Serve fresh.'
),
(
  '124', 'Vegetable Khichdi & Beetroot Salad',
  'A gentle, easy-to-digest dinner of vegetable lentil khichdi, paired with beetroot salad.',
  'https://images.unsplash.com/photo-1596797038530-2c107229654b?w=600', 25, 330, 'Folate & Fiber Rich', 'Easy digestion & recovery support',
  array['pregnant', 'postpartum'], 'dinner',
  '[{"name": "Rice & Moong Dal khichdi", "quantity": "1 cup"}, {"name": "Beetroot salad", "quantity": "1 bowl"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Slice beetroot", "description": "Peel and grate or thinly slice beetroot. Toss with lime juice and salt."}, {"stepNumber": 2, "title": "Serve", "description": "Serve hot vegetable khichdi with beetroot salad."}]'::jsonb,
  'Serve warm.'
),
(
  '125', 'Dosa & Sambar',
  'Crispy South Indian rice crepes made from fermented batter, served with hot lentil vegetable sambar.',
  'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=600', 20, 250, 'Fermented & Nutritious', 'Supports gut health & lactation',
  array['pregnant', 'postpartum'], 'breakfast',
  '[{"name": "Dosa batter", "quantity": "1 cup"}, {"name": "Vegetable Sambar", "quantity": "1 cup"}, {"name": "Fresh fruit (Apple/Banana)", "quantity": "1 piece"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Cook Dosa", "description": "Spread a ladle of batter on a hot tawa. Drizzle ghee and cook until golden brown and crispy."}, {"stepNumber": 2, "title": "Serve", "description": "Roll up and serve crispy dosa with hot sambar and fresh fruit."}]'::jsonb,
  'Serve hot.'
),
(
  '126', 'Rice with Dal & Mixed Veg',
  'Steamed rice, protein-packed yellow dal, mixed vegetable curry, and curd.',
  'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=600', 30, 410, 'Balanced Nutrients', 'Simple & nourishing',
  array['pregnant', 'postpartum'], 'lunch',
  '[{"name": "Steamed Rice", "quantity": "1 cup"}, {"name": "Comforting Dal", "quantity": "1 cup"}, {"name": "Mixed vegetable curry", "quantity": "1 cup"}, {"name": "Curd", "quantity": "½ cup"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Assemble", "description": "Serve comforting dal over hot steamed rice alongside mixed vegetable curry and curd."}]'::jsonb,
  'Serve warm.'
),
(
  '127', 'Dry Fruits & Fresh Coconut Water',
  'Dates, figs, and fresh coconut water to replenish electrolytes after postpartum birth.',
  'https://images.unsplash.com/photo-1490818387583-1baba5e638af?w=600', 5, 210, 'Electrolytes & Minerals', 'Boosts hydration & lactation',
  array['pregnant', 'postpartum'], 'eveningSnack',
  '[{"name": "Coconut water", "quantity": "1 glass"}, {"name": "Dates & Dried Figs", "quantity": "1 small handful"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Serve", "description": "Pour fresh coconut water into a glass. Serve dry fruits on a small plate."}]'::jsonb,
  'Drink fresh.'
),
(
  '128', 'Chapatis with Chickpea Curry',
  'Protein-dense white chickpea curry served alongside whole wheat chapatis.',
  'https://images.unsplash.com/photo-1589302168068-964664d93dc0?w=600', 30, 420, 'Fibre & Protein High', 'Supports blood sugar & tissue repair',
  array['pregnant', 'postpartum'], 'dinner',
  '[{"name": "Chapatis", "quantity": "2 pieces"}, {"name": "Chickpea curry (Chole)", "quantity": "1 cup"}, {"name": "Salad", "quantity": "1 bowl"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Serve", "description": "Serve spiced chickpea curry warm alongside soft chapatis and a crisp green salad."}]'::jsonb,
  'Serve warm.'
),

-- 2. Postpartum Specific Recipes (201 to 215)
(
  '201', 'Ragi Porridge, Eggs & Dates',
  'Postpartum recovery breakfast featuring iron-rich Ragi Porridge, boiled eggs, and sweet dates for tissue healing.',
  'https://images.unsplash.com/photo-1517093157656-b9eccef91cb1?w=600', 20, 320, 'Lactation & Tissue Recovery', 'Replenishes iron and calcium',
  array['postpartum'], 'breakfast',
  '[{"name": "Ragi flour", "quantity": "3 tbsp"}, {"name": "Milk", "quantity": "1 cup"}, {"name": "Boiled Eggs", "quantity": "2 pieces"}, {"name": "Dates", "quantity": "3 pieces"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Cook Ragi", "description": "Mix ragi flour with water, simmer on low heat, then add milk and cook until thick."}, {"stepNumber": 2, "title": "Assemble", "description": "Serve warm ragi porridge alongside boiled eggs and sweet dates."}]'::jsonb,
  'Serve warm.'
),
(
  '203', 'Almonds, Walnuts & Fruit',
  'A healthy snack rich in monounsaturated fats and essential omega-3 for postpartum mental clarity and lactation support.',
  'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=600', 5, 180, 'Healthy Fats & Minerals', 'Supports breast milk quality',
  array['postpartum'], 'eveningSnack',
  '[{"name": "Almonds", "quantity": "1 handful"}, {"name": "Walnuts", "quantity": "½ handful"}, {"name": "Fresh fruit", "quantity": "1 piece"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Serve", "description": "Assemble raw nuts with sliced fresh seasonal fruit on a plate."}]'::jsonb,
  'Eat fresh.'
),
(
  '204', 'Rice with Rajma & Veg Stir Fry',
  'Comforting rice dinner containing protein-packed rajma (kidney beans) and a high-fiber mixed vegetable stir fry.',
  'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=600', 35, 390, 'High Protein & Fiber', 'Aids tissue recovery',
  array['postpartum'], 'dinner',
  '[{"name": "Steamed Rice", "quantity": "1 cup"}, {"name": "Rajma curry", "quantity": "1 cup"}, {"name": "Vegetable stir-fry", "quantity": "1 cup"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Assemble", "description": "Plate steamed rice and rajma curry, and serve alongside fresh vegetable stir fry."}]'::jsonb,
  'Serve warm.'
),
(
  '205', 'Vegetable Upma & Banana',
  'Nourishing semolina upma cooked with ghee and carrots, served with a fresh banana for muscle recovery and potassium.',
  'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=600', 20, 300, 'Complex Carbs & Potassium', 'Boosts postpartum energy levels',
  array['postpartum'], 'breakfast',
  '[{"name": "Semolina (Suji)", "quantity": "½ cup"}, {"name": "Vegetables mixed", "quantity": "½ cup"}, {"name": "Banana", "quantity": "1 piece"}, {"name": "Glass of milk", "quantity": "1 glass"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Upma cooking", "description": "Cook roasted semolina with tempered mustard seeds, ginger, curry leaves, and veggies."}, {"stepNumber": 2, "title": "Serve", "description": "Serve warm upma with a fresh banana and glass of milk."}]'::jsonb,
  'Serve hot.'
),
(
  '206', 'Chapatis with Chole & Mixed Veg',
  'Fiber-rich meal featuring soft chapatis, protein-heavy chickpea chole, and a light mixed vegetable curry.',
  'https://images.unsplash.com/photo-1589302168068-964664d93dc0?w=600', 30, 430, 'Protein & Fiber Rich', 'Aids recovery and satiety',
  array['postpartum'], 'lunch',
  '[{"name": "Chapatis", "quantity": "2 pieces"}, {"name": "Chole curry", "quantity": "1 cup"}, {"name": "Mixed vegetable curry", "quantity": "1 cup"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Assemble", "description": "Serve chickpea curry and mixed vegetables alongside soft warm chapatis."}]'::jsonb,
  'Serve warm.'
),
(
  '209', 'Oats Porridge with Nuts, Seeds & Apple',
  'High-fiber oats cooked in milk and topped with flaxseeds, chia seeds, chopped walnuts, and fresh apple.',
  'https://images.unsplash.com/photo-1517686469429-8bdb88b9f907?w=600', 15, 320, 'Fiber & Omega-3 Heavy', 'Aids digestive health & lactation',
  array['postpartum'], 'breakfast',
  '[{"name": "Rolled Oats", "quantity": "½ cup"}, {"name": "Milk", "quantity": "1 cup"}, {"name": "Flax & Chia seeds", "quantity": "1 tbsp"}, {"name": "Apple", "quantity": "1 small"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Cook oats", "description": "Simmer oats in milk until creamy. Mix in seeds and top with sliced apple and walnuts."}]'::jsonb,
  'Serve warm.'
),
(
  '215', 'Banana Milk Smoothie',
  'A calorie-dense and calcium-rich smoothie blended with ripe banana, milk, and honey. Boosts energy for breastfeeding mothers.',
  'https://images.unsplash.com/photo-1553530666-ba11a7da3888?w=600', 10, 220, 'Calcium & Potassium Boost', 'Lactation & energy support',
  array['postpartum'], 'eveningSnack',
  '[{"name": "Banana", "quantity": "1 medium"}, {"name": "Milk", "quantity": "1 cup"}, {"name": "Honey", "quantity": "1 tbsp"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Blend", "description": "Blend banana, milk, and honey until thick and creamy."}]'::jsonb,
  'Serve fresh.'
),

-- 3. Baby and Toddler Recipes (301 to 393)
(
  '301', 'Rice Porridge / Cereal',
  'A smooth, easily digestible starter porridge made from finely ground rice.',
  'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=600', 15, 90, 'Easy Digest', 'Perfect first starter grain',
  array['6-8 Months', '9-12 Months'], 'breakfast',
  '[{"name": "Ground rice powder", "quantity": "2 tbsp"}, {"name": "Water / Breast milk", "quantity": "1 cup"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Mix", "description": "Whisk rice powder in water to prevent lumps. Simmer on low heat for 10 minutes until cooked."}, {"stepNumber": 2, "title": "Cool", "description": "Cool down and thin with breast milk or formula if desired."}]'::jsonb,
  'Serve warm at liquid or thin puree consistency.'
),
(
  '302', 'Mashed Carrot Puree',
  'A naturally sweet and vitamin A-rich carrot puree, steamed and mashed smooth.',
  'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=600', 15, 45, 'Rich in Vitamin A', 'Supports eye development',
  array['6-8 Months'], 'lunch',
  '[{"name": "Carrot", "quantity": "1 medium"}, {"name": "Water", "quantity": "As needed"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Steam", "description": "Peel and chop carrot. Steam for 10 minutes until completely fork-tender."}, {"stepNumber": 2, "title": "Mash", "description": "Mash with a fork or blend to a smooth, lump-free puree."}]'::jsonb,
  'Serve fresh and warm.'
),
(
  '303', 'Breast Milk or Formula',
  'A vital source of hydration, immunoglobulins, and complete nutrition for your growing baby.',
  'https://images.unsplash.com/photo-1553530666-ba11a7da3888?w=600', 5, 120, 'Perfect Hydration', 'Primary nutrient source',
  array['6-8 Months'], 'eveningSnack',
  '[{"name": "Breast milk / Formula", "quantity": "1 feed"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Prepare", "description": "Prepare formula feed or warm expressed breast milk according to standards."}]'::jsonb,
  'Feed immediately.'
),
(
  '304', 'Mashed Banana / Banana Mash',
  'A soft, naturally sweet banana mash rich in potassium and energy-giving carbohydrates.',
  'https://images.unsplash.com/photo-1490818387583-1baba5e638af?w=600', 5, 80, 'Potassium Boost', 'Highly energetic and soft',
  array['6-8 Months', '9-12 Months'], 'dinner',
  '[{"name": "Ripe Banana", "quantity": "½ piece"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Mash", "description": "Peel a ripe banana (preferably with brown spots) and mash thoroughly using a fork."}]'::jsonb,
  'Serve immediately after mashing.'
),
(
  '305', 'Ragi Porridge',
  'An iron-dense, calcium-rich traditional porridge made from sprouted finger millet.',
  'https://images.unsplash.com/photo-1517093157656-b9eccef91cb1?w=600', 15, 110, 'Calcium & Iron Heavy', 'Promotes bone growth',
  array['6-8 Months', '9-12 Months'], 'breakfast',
  '[{"name": "Sprouted Ragi Flour", "quantity": "2 tbsp"}, {"name": "Water", "quantity": "1 cup"}, {"name": "Ghee", "quantity": "2 drops"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Cook Ragi", "description": "Mix ragi flour in water. Cook on medium-low flame while stirring continuously to prevent lumps for 8 minutes."}, {"stepNumber": 2, "title": "Ghee top", "description": "Stir in a couple of drops of ghee at the end."}]'::jsonb,
  'Serve warm.'
),
(
  '306', 'Pumpkin Puree',
  'A gentle, smooth puree made from yellow pumpkin, rich in vitamins and easy on the gut.',
  'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=600', 15, 40, 'Gut Friendly', 'High in beta-carotene',
  array['6-8 Months'], 'lunch',
  '[{"name": "Yellow Pumpkin chopped", "quantity": "½ cup"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Steam & Mash", "description": "Steam pumpkin cubes for 10 minutes. Mash well or blend into a velvety puree."}]'::jsonb,
  'Serve immediately.'
),
(
  '307', 'Steamed Apple Puree',
  'A soft, stewed apple puree that is gentle on baby''s developing digestive system.',
  'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=600', 15, 60, 'High Fiber', 'Gentle on tummy',
  array['6-8 Months'], 'dinner',
  '[{"name": "Sweet Apple", "quantity": "½ piece"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Stew apple", "description": "Peel, core, and slice apple. Steam or stew with 2 tbsp of water until soft."}, {"stepNumber": 2, "title": "Mash", "description": "Mash or blend into a smooth sauce."}]'::jsonb,
  'Serve lukewarm.'
),
(
  '308', 'Oats Porridge',
  'A comforting, fiber-rich oats porridge prepared with milk, breast milk, or formula.',
  'https://images.unsplash.com/photo-1517686469429-8bdb88b9f907?w=600', 10, 100, 'Fiber Rich', 'Steady morning energy',
  array['6-8 Months', '9-12 Months'], 'breakfast',
  '[{"name": "Rolled Oats powder", "quantity": "2 tbsp"}, {"name": "Water / Milk", "quantity": "1 cup"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Cook oats", "description": "Cook oats powder in water or milk for 5-7 minutes. Stir frequently until smooth and creamy."}]'::jsonb,
  'Serve warm.'
),
(
  '309', 'Sweet Potato Puree',
  'Creamy, sweet potato puree packed with beta-carotene, vitamins, and minerals.',
  'https://images.unsplash.com/photo-1596797038530-2c107229654b?w=600', 20, 75, 'Calorie Dense & Vitamin Rich', 'Steady energy support',
  array['6-8 Months'], 'lunch',
  '[{"name": "Sweet Potato", "quantity": "1 small"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Steam", "description": "Peel, cube, and steam sweet potato for 15 minutes until very soft."}, {"stepNumber": 2, "title": "Blend", "description": "Blend or mash thoroughly with a little warm water."}]'::jsonb,
  'Serve warm.'
),
(
  '310', 'Mashed Pear',
  'A gentle and high-fiber mashed pear puree, helpful for healthy bowel movements.',
  'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=600', 12, 50, 'High Fiber', 'Aids healthy digestion',
  array['6-8 Months'], 'dinner',
  '[{"name": "Ripe Pear", "quantity": "½ piece"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Steam & Mash", "description": "Peel, core, and steam pear slices for 8 minutes. Mash with a fork."}]'::jsonb,
  'Serve fresh.'
),
(
  '311', 'Rice and Moong Dal Porridge',
  'A simple protein-carb blend of soft-cooked rice and yellow split moong lentils.',
  'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=600', 20, 110, 'Protein & Carbs', 'Easy digestion & muscle growth',
  array['6-8 Months'], 'breakfast',
  '[{"name": "Rice", "quantity": "1 tbsp"}, {"name": "Moong dal", "quantity": "1 tbsp"}, {"name": "Water", "quantity": "1 cup"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Cook soft", "description": "Wash and pressure cook rice and dal together in water until mushy. Blend or mash into porridge."}]'::jsonb,
  'Serve warm.'
),
(
  '312', 'Avocado Mash',
  'A rich source of healthy fats and brain-boosting nutrients, mashed to a smooth cream.',
  'https://images.unsplash.com/photo-1490818387583-1baba5e638af?w=600', 5, 130, 'Healthy Fats', 'Supports brain development',
  array['6-8 Months', '9-12 Months'], 'lunch',
  '[{"name": "Ripe Avocado", "quantity": "¼ piece"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Mash", "description": "Scoop out ripe avocado flesh and mash well with a spoon until smooth."}]'::jsonb,
  'Serve immediately.'
),
(
  '313', 'Carrot and Potato Mash',
  'A smooth mash of sweet carrots and potatoes, providing balanced energy.',
  'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=600', 20, 80, 'Carbohydrates & Vit A', 'Rich energy source',
  array['6-8 Months'], 'dinner',
  '[{"name": "Carrot cubed", "quantity": "¼ cup"}, {"name": "Potato cubed", "quantity": "¼ cup"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Steam & Mash", "description": "Steam carrot and potato cubes together for 15 minutes. Mash together with a spoon."}]'::jsonb,
  'Serve warm.'
),
(
  '314', 'Beetroot Puree',
  'An iron-rich, earthy beetroot puree steamed and blended smooth.',
  'https://images.unsplash.com/photo-1596797038530-2c107229654b?w=600', 20, 35, 'Iron Rich', 'Supports blood cell health',
  array['6-8 Months'], 'lunch',
  '[{"name": "Beetroot cubed", "quantity": "½ cup"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Steam & Blend", "description": "Steam beetroot cubes until tender (15-20 mins). Blend to a smooth paste."}]'::jsonb,
  'Serve fresh.'
),
(
  '315', 'Pumpkin and Carrot Mash',
  'A colorful, sweet combination of steamed pumpkin and carrot, mashed smooth.',
  'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=600', 15, 45, 'Immunity Boost', 'Packed with antioxidants',
  array['6-8 Months'], 'lunch',
  '[{"name": "Pumpkin cubed", "quantity": "¼ cup"}, {"name": "Carrot cubed", "quantity": "¼ cup"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Steam & Combine", "description": "Steam together for 10 minutes. Mash into a smooth paste."}]'::jsonb,
  'Serve warm.'
),
(
  '316', 'Apple Puree',
  'A nutritious, smooth puree of sweet apples.',
  'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=600', 15, 55, 'Fiber Rich', 'Aids digestive health',
  array['6-8 Months'], 'dinner',
  '[{"name": "Apple", "quantity": "½ piece"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Steam & Mash", "description": "Core, slice and steam the apple. Puree using a fork or blender."}]'::jsonb,
  'Serve lukewarm.'
),
(
  '317', 'Sweet Potato Mash',
  'Creamy, warm mashed sweet potatoes.',
  'https://images.unsplash.com/photo-1596797038530-2c107229654b?w=600', 20, 80, 'Complex Carbs', 'Energy giving',
  array['6-8 Months', '9-12 Months'], 'lunch',
  '[{"name": "Sweet Potato cubed", "quantity": "½ cup"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Steam & Mash", "description": "Steam sweet potato cubes for 15 minutes, then mash well with ghee or water."}]'::jsonb,
  'Serve warm.'
),
(
  '318', 'Pear Puree',
  'Steamed and pureed sweet pears, rich in fiber.',
  'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=600', 10, 48, 'Soluble Fiber', 'Promotes gut movement',
  array['6-8 Months', '9-12 Months'], 'dinner',
  '[{"name": "Pear", "quantity": "½ piece"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Puree", "description": "Steam pear cubes until soft (8 mins). Blend until smooth."}]'::jsonb,
  'Serve warm.'
),
(
  '319', 'Moong Dal Khichdi (Mashed)',
  'A classic, comforting blend of rice and yellow moong lentils cooked soft and mashed with a touch of ghee.',
  'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=600', 25, 120, 'Easy Protein', 'Highly digestible & comforting',
  array['6-8 Months', '9-12 Months'], 'lunch',
  '[{"name": "Rice", "quantity": "2 tbsp"}, {"name": "Yellow Moong Dal", "quantity": "1 tbsp"}, {"name": "Ghee", "quantity": "¼ tsp"}, {"name": "Water", "quantity": "1 cup"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Pressure cook", "description": "Wash rice and dal. Pressure cook with water for 4 whistles until very soft."}, {"stepNumber": 2, "title": "Ghee & Mash", "description": "Add a touch of ghee and mash it completely with a spoon."}]'::jsonb,
  'Serve warm.'
),
(
  '320', 'Suji (Semolina) Porridge',
  'A smooth, warm semolina porridge cooked with ghee and milk.',
  'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=600', 15, 120, 'Easy Energy', 'Gentle on stomach',
  array['6-8 Months', '9-12 Months'], 'breakfast',
  '[{"name": "Suji (Semolina)", "quantity": "2 tbsp"}, {"name": "Ghee", "quantity": "½ tsp"}, {"name": "Milk / Water", "quantity": "1 cup"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Roast", "description": "Roast suji in a pan with ghee until aromatic."}, {"stepNumber": 2, "title": "Boil", "description": "Slowly add water or milk while stirring continuously. Cook for 5 minutes until thickened."}]'::jsonb,
  'Serve warm.'
),
(
  '321', 'Moong Dal Soup with Soft Rice Mash',
  'A warm, protein-packed lentil soup mixed with soft-cooked rice.',
  'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=600', 20, 110, 'Protein Rich', 'Gentle, soothing meal',
  array['6-8 Months'], 'dinner',
  '[{"name": "Yellow Moong Dal", "quantity": "2 tbsp"}, {"name": "Cooked Rice", "quantity": "¼ cup"}, {"name": "Water", "quantity": "1 cup"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Cook soup", "description": "Boil moong dal in water until completely dissolved. Strain the soup."}, {"stepNumber": 2, "title": "Mash with rice", "description": "Mix the warm soup with soft-cooked mashed rice."}]'::jsonb,
  'Serve warm.'
),
(
  '322', 'Oats Porridge with Fruit Puree',
  'Comforting oats porridge topped with a dollop of fresh fruit puree.',
  'https://images.unsplash.com/photo-1517686469429-8bdb88b9f907?w=600', 15, 130, 'High Fiber', 'Naturally sweet and nutritious',
  array['6-8 Months'], 'breakfast',
  '[{"name": "Oats powder", "quantity": "2 tbsp"}, {"name": "Milk / Water", "quantity": "1 cup"}, {"name": "Apple / Banana puree", "quantity": "2 tbsp"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Cook oats", "description": "Simmer oats in milk/water for 5 mins. Top with fresh apple or banana puree."}]'::jsonb,
  'Serve warm.'
),
(
  '323', 'Vegetable Khichdi',
  'A wholesome, single-pot meal of rice, moong dal, carrots, and peas cooked soft.',
  'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=600', 25, 130, 'Balanced Diet', 'Packed with vitamins & proteins',
  array['6-8 Months', '9-12 Months'], 'lunch',
  '[{"name": "Rice", "quantity": "2 tbsp"}, {"name": "Moong Dal", "quantity": "1 tbsp"}, {"name": "Carrots & Peas chopped", "quantity": "2 tbsp"}, {"name": "Ghee", "quantity": "½ tsp"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Pressure cook", "description": "Cook all ingredients in a pressure cooker with 1.25 cups of water for 4 whistles."}, {"stepNumber": 2, "title": "Mash", "description": "Mash well to a soft texture."}]'::jsonb,
  'Serve warm.'
),
(
  '324', 'Sweet Potato and Carrot Mash',
  'A nourishing, colorful mash of sweet potato and carrot.',
  'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=600', 20, 85, 'Immunity & Energy', 'Vibrant vitamin booster',
  array['6-8 Months', '9-12 Months'], 'dinner',
  '[{"name": "Sweet Potato cubed", "quantity": "¼ cup"}, {"name": "Carrot cubed", "quantity": "¼ cup"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Steam & Mash", "description": "Steam sweet potato and carrot cubes for 15 minutes. Mash together with a few drops of ghee."}]'::jsonb,
  'Serve warm.'
),
(
  '325', 'Dal Rice Mash',
  'Well-cooked rice mashed together with yellow dal and a drops of ghee.',
  'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=600', 20, 115, 'Iron & Protein', 'Classic daily diet staple',
  array['6-8 Months', '9-12 Months'], 'lunch',
  '[{"name": "Cooked Rice", "quantity": "¼ cup"}, {"name": "Cooked yellow dal", "quantity": "¼ cup"}, {"name": "Ghee", "quantity": "¼ tsp"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Mix", "description": "Combine warm dal and cooked rice. Mash thoroughly using a spoon and top with ghee."}]'::jsonb,
  'Serve warm.'
),
(
  '326', 'Papaya Mash',
  'Sweet, ripe papaya mashed smooth, rich in vitamin C and digestive enzymes.',
  'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=600', 5, 50, 'Vitamin C Rich', 'Supports digestion',
  array['6-8 Months'], 'eveningSnack',
  '[{"name": "Ripe Papaya", "quantity": "¼ cup"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Mash", "description": "Remove seeds and mash fresh papaya flesh with a fork until smooth."}]'::jsonb,
  'Serve fresh.'
),
(
  '327', 'Pumpkin and Potato Mash',
  'A comforting, soft mash of sweet pumpkin and potatoes.',
  'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=600', 20, 70, 'Easy Digest', 'Soothing dinner option',
  array['6-8 Months'], 'dinner',
  '[{"name": "Pumpkin cubed", "quantity": "¼ cup"}, {"name": "Potato cubed", "quantity": "¼ cup"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Steam & Mash", "description": "Steam pumpkin and potato cubes for 12 minutes. Mash well."}]'::jsonb,
  'Serve warm.'
),
(
  '328', 'Vegetable Puree (Carrot, Pumpkin, Beans)',
  'A vitamin-dense puree of carrots, pumpkin, and green beans.',
  'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=600', 20, 55, 'Multivitamin', 'Nutritious green-orange blend',
  array['6-8 Months'], 'lunch',
  '[{"name": "Carrot", "quantity": "2 tbsp"}, {"name": "Pumpkin", "quantity": "2 tbsp"}, {"name": "Green Beans", "quantity": "1 tbsp"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Steam & Blend", "description": "Steam chopped vegetables until soft. Puree in a blender."}]'::jsonb,
  'Serve fresh.'
),
(
  '329', 'Soft Idli Mashed with Ghee',
  'A soft, steamed fermented rice cake crumbled and mixed with a drop of ghee.',
  'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=600', 20, 100, 'Probiotic', 'Light and gut friendly',
  array['9-12 Months'], 'breakfast',
  '[{"name": "Steamed Idli", "quantity": "1 piece"}, {"name": "Ghee", "quantity": "¼ tsp"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Mash idli", "description": "Crumble the warm idli into small pieces, add a touch of ghee and soft mash."}]'::jsonb,
  'Serve warm.'
),
(
  '330', 'Vegetable Khichdi (Rice, Moong Dal, Carrot)',
  'A delicious rice-lentil dish cooked soft with carrots.',
  'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=600', 25, 125, 'High Protein & Vit A', 'Supports muscle & vision',
  array['9-12 Months'], 'lunch',
  '[{"name": "Rice", "quantity": "2 tbsp"}, {"name": "Moong Dal", "quantity": "1 tbsp"}, {"name": "Carrot chopped", "quantity": "2 tbsp"}, {"name": "Ghee", "quantity": "½ tsp"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Cook", "description": "Pressure cook all ingredients with 1.25 cups of water. Mash lightly."}]'::jsonb,
  'Serve warm.'
),
(
  '331', 'Banana Slices',
  'Bite-sized, soft banana slices for self-feeding practice.',
  'https://images.unsplash.com/photo-1490818387583-1baba5e638af?w=600', 5, 80, 'Pincer Grasp Practice', 'Promotes feeding coordination',
  array['9-12 Months'], 'eveningSnack',
  '[{"name": "Ripe Banana", "quantity": "½ piece"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Slice", "description": "Peel banana and slice into thin wheels or small bite-sized pieces."}]'::jsonb,
  'Eat fresh.'
),
(
  '332', 'Dal Rice Mash with Vegetables',
  'Wholesome dal and rice mashed together with soft-cooked carrots and peas.',
  'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=600', 25, 130, 'Balanced Nutrition', 'Rich in iron and fiber',
  array['9-12 Months'], 'lunch',
  '[{"name": "Cooked Rice", "quantity": "¼ cup"}, {"name": "Yellow Dal", "quantity": "¼ cup"}, {"name": "Carrot & Peas steamed", "quantity": "2 tbsp"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Mash together", "description": "Combine hot rice, dal, and soft vegetables. Mash together until easily chewable."}]'::jsonb,
  'Serve warm.'
),
(
  '333', 'Steamed Apple Pieces',
  'Soft-steamed apple slices, perfect for practicing chewing and pincer grasp.',
  'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=600', 15, 60, 'Chewing Practice', 'Soft finger food',
  array['9-12 Months'], 'eveningSnack',
  '[{"name": "Apple", "quantity": "½ piece"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Steam pieces", "description": "Slice apple into sticks. Steam for 8 minutes until soft enough to squash between fingers."}]'::jsonb,
  'Cool to warm and serve.'
),
(
  '334', 'Vegetable Upma (Soft Mashed)',
  'A soft, roasted semolina dish cooked with onions, carrots, and ghee.',
  'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=600', 20, 110, 'Carbohydrates', 'Steady release of energy',
  array['9-12 Months'], 'breakfast',
  '[{"name": "Suji", "quantity": "3 tbsp"}, {"name": "Grated carrots", "quantity": "1 tbsp"}, {"name": "Ghee", "quantity": "½ tsp"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Cook upma", "description": "Saute carrots. Add roasted suji, water, and simmer until thick and mushy."}]'::jsonb,
  'Serve warm.'
),
(
  '335', 'Pumpkin and Moong Dal Khichdi',
  'A protein-rich khichdi of rice, moong dal, and sweet pumpkin.',
  'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=600', 25, 120, 'Antioxidant & Protein', 'Supports immune system',
  array['9-12 Months'], 'lunch',
  '[{"name": "Rice", "quantity": "2 tbsp"}, {"name": "Moong Dal", "quantity": "1 tbsp"}, {"name": "Pumpkin cubed", "quantity": "2 tbsp"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Cook soft", "description": "Pressure cook all ingredients with 1.25 cups of water. Mash well."}]'::jsonb,
  'Serve warm.'
),
(
  '336', 'Papaya Cubes',
  'Small, soft cubes of ripe papaya for self-feeding.',
  'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=600', 5, 45, 'Vitamin C', 'Helps iron absorption',
  array['9-12 Months'], 'eveningSnack',
  '[{"name": "Ripe Papaya", "quantity": "¼ cup"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Cut cubes", "description": "Peel papaya and cut into tiny cubes (½ cm size) that baby can grab."}]'::jsonb,
  'Serve fresh.'
),
(
  '337', 'Soft Curd Rice',
  'Soothing curd rice prepared with soft-cooked rice and fresh yogurt.',
  'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=600', 10, 100, 'Probiotic & Calcium', 'Gentle on baby''s tummy',
  array['9-12 Months'], 'dinner',
  '[{"name": "Soft-cooked rice", "quantity": "¼ cup"}, {"name": "Fresh Curd", "quantity": "¼ cup"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Combine", "description": "Mash rice well. Stir in curd until smooth and creamy."}]'::jsonb,
  'Serve cool.'
),
(
  '338', 'Oats and Banana Porridge',
  'A warm oats porridge sweetened with mashed banana.',
  'https://images.unsplash.com/photo-1517686469429-8bdb88b9f907?w=600', 10, 120, 'High Fiber', 'Naturally sweet breakfast',
  array['9-12 Months'], 'breakfast',
  '[{"name": "Oats", "quantity": "2 tbsp"}, {"name": "Milk / Water", "quantity": "1 cup"}, {"name": "Banana mashed", "quantity": "2 tbsp"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Cook", "description": "Simmer oats in milk. Stir in banana mash at the end. Cool."}]'::jsonb,
  'Serve warm.'
),
(
  '339', 'Soft Chapati Soaked in Dal',
  'A whole wheat chapati soaked in yellow dal until completely soft and mashed.',
  'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=600', 20, 150, 'Iron & Carbohydrates', 'Introduces wheat texture',
  array['9-12 Months'], 'lunch',
  '[{"name": "Chapati", "quantity": "½ piece"}, {"name": "Yellow Dal", "quantity": "½ cup"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Soak & Mash", "description": "Tear chapati into small pieces. Soak in hot dal for 15 mins. Mash completely with a spoon."}]'::jsonb,
  'Serve warm.'
),
(
  '340', 'Pear Pieces',
  'Soft pear segments for practicing finger feeding.',
  'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=600', 5, 40, 'High Fiber', 'Encourages independence',
  array['9-12 Months'], 'eveningSnack',
  '[{"name": "Ripe Pear", "quantity": "½ piece"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Prepare", "description": "Peel and cut pear into soft, easy-to-hold slices."}]'::jsonb,
  'Serve fresh.'
),
(
  '341', 'Vegetable Soup with Rice Mash',
  'A warm, nutritious vegetable broth mixed with soft mashed rice.',
  'https://images.unsplash.com/photo-1596797038530-2c107229654b?w=600', 25, 95, 'Hydration & Vitamins', 'Warm and comforting',
  array['9-12 Months'], 'dinner',
  '[{"name": "Mixed veg soup", "quantity": "½ cup"}, {"name": "Soft rice", "quantity": "3 tbsp"}]'::jsonb,
  '[{"stepNumber": 2, "title": "Combine", "description": "Mix hot vegetable soup with mashed rice to form a wet porridge."}]'::jsonb,
  'Serve warm.'
),
(
  '342', 'Mini Dosa Pieces with Sambar',
  'Mini soft fermented rice crepes served with a non-spicy, healthy vegetable sambar.',
  'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=600', 20, 110, 'Easy Digest & Probiotic', 'Tasty South Indian snack',
  array['9-12 Months'], 'breakfast',
  '[{"name": "Dosa batter", "quantity": "½ cup"}, {"name": "Vegetable Sambar", "quantity": "½ cup"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Make dosa", "description": "Pour mini soft dosas on tawa using ghee. Tear into bits."}, {"stepNumber": 2, "title": "Sambar soak", "description": "Dip or serve with warm sambar."}]'::jsonb,
  'Serve warm.'
),
(
  '343', 'Rice, Dal, and Spinach Mash',
  'A soft, iron-rich mash of rice, yellow lentils, and fresh spinach.',
  'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=600', 25, 120, 'Iron & Protein Rich', 'Helps brain and body growth',
  array['9-12 Months'], 'lunch',
  '[{"name": "Rice & Dal cooked", "quantity": "½ cup"}, {"name": "Spinach pureed", "quantity": "2 tbsp"}, {"name": "Ghee", "quantity": "¼ tsp"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Mash together", "description": "Combine rice, dal, and warm spinach puree. Mash well and add ghee."}]'::jsonb,
  'Serve warm.'
),
(
  '344', 'Yogurt with Fruit Puree',
  'Creamy yogurt topped with a sweet, fresh fruit puree.',
  'https://images.unsplash.com/photo-1490818387583-1baba5e638af?w=600', 5, 110, 'Calcium & Probiotics', 'Delicious gut booster',
  array['9-12 Months'], 'eveningSnack',
  '[{"name": "Fresh Curd", "quantity": "½ cup"}, {"name": "Fruit puree (Mango/Apple)", "quantity": "2 tbsp"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Assemble", "description": "Layer fruit puree on top of curd in a small bowl."}]'::jsonb,
  'Serve cool.'
),
(
  '345', 'Suji Porridge',
  'Simple roasted semolina porridge sweetened with milk.',
  'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=600', 15, 110, 'Easy Digest', 'Nutritious & light breakfast',
  array['9-12 Months'], 'breakfast',
  '[{"name": "Suji", "quantity": "2 tbsp"}, {"name": "Milk", "quantity": "1 cup"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Cook suji", "description": "Roast suji. Simmer in milk until it thickens."}]'::jsonb,
  'Serve warm.'
),
(
  '346', 'Vegetable Pulao (Mashed)',
  'Fragrant basmati rice cooked soft with mixed vegetables and mashed.',
  'https://images.unsplash.com/photo-1589302168068-964664d93dc0?w=600', 25, 130, 'Vitamins & Fiber', 'Balanced family-style meal',
  array['9-12 Months', '1-2 Years'], 'lunch',
  '[{"name": "Rice", "quantity": "¼ cup"}, {"name": "Mixed vegetables", "quantity": "2 tbsp"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Cook & Mash", "description": "Cook pulao with mild spices. Mash the vegetables and rice soft."}]'::jsonb,
  'Serve warm.'
),
(
  '347', 'Curd Rice with Mashed Vegetables',
  'Soft curd rice mixed with finely grated, steamed carrots and peas.',
  'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=600', 10, 110, 'Probiotics', 'Cooling and nutritious',
  array['9-12 Months'], 'lunch',
  '[{"name": "Soft rice", "quantity": "¼ cup"}, {"name": "Curd", "quantity": "¼ cup"}, {"name": "Grated steamed carrot", "quantity": "1 tbsp"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Combine", "description": "Stir curd and soft rice together. Mix in grated carrot."}]'::jsonb,
  'Serve fresh.'
),
(
  '348', 'Banana and Papaya Mix',
  'A delicious combination of mashed banana and ripe papaya.',
  'https://images.unsplash.com/photo-1490818387583-1baba5e638af?w=600', 5, 75, 'Vit C & Potassium', 'Sweet and colorful fruit snack',
  array['9-12 Months', '1-2 Years'], 'eveningSnack',
  '[{"name": "Ripe Banana", "quantity": "¼ cup"}, {"name": "Ripe Papaya", "quantity": "¼ cup"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Mash together", "description": "Combine banana and papaya in a bowl. Mash well with a fork."}]'::jsonb,
  'Eat fresh.'
),
(
  '349', 'Vegetable Idli',
  'Steamed rice cakes loaded with grated carrots and beans.',
  'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=600', 20, 110, 'Fibre & Probiotics', 'Perfect morning energy',
  array['9-12 Months', '1-2 Years'], 'breakfast',
  '[{"name": "Idli batter", "quantity": "½ cup"}, {"name": "Grated carrots & beans", "quantity": "2 tbsp"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Steam", "description": "Mix veggies in idli batter. Steam for 10 minutes."}]'::jsonb,
  'Serve warm with ghee.'
),
(
  '350', 'Dal Rice with Mixed Vegetables & Ghee',
  'Steamed rice, comforting yellow dal, and a side of soft carrot-beans stir fry served with curd.',
  'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=600', 25, 140, 'Complete Meal', 'Classic daily diet staple',
  array['9-12 Months'], 'lunch',
  '[{"name": "Rice & Dal", "quantity": "½ cup"}, {"name": "Veggies stir-fry", "quantity": "2 tbsp"}, {"name": "Ghee", "quantity": "¼ tsp"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Combine", "description": "Combine dal rice and soft-cooked vegetables. Serve warm."}]'::jsonb,
  'Serve warm.'
),
(
  '351', 'Yogurt with Mashed Fruit',
  'Fresh, probiotic curd topped with sweet, ripe seasonal fruits.',
  'https://images.unsplash.com/photo-1490818387583-1baba5e638af?w=600', 5, 100, 'Calcium & Probiotics', 'Gut-friendly delicious snack',
  array['9-12 Months'], 'eveningSnack',
  '[{"name": "Curd", "quantity": "½ cup"}, {"name": "Mashed banana / apple", "quantity": "2 tbsp"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Mix", "description": "Mix curd with fruit mash in a small bowl."}]'::jsonb,
  'Serve fresh.'
),
(
  '352', 'Soft Chapati Soaked in Dal',
  'A whole wheat chapati soaked in yellow dal until completely soft and mashed.',
  'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=600', 20, 140, 'Iron & Carbohydrates', 'Classic wheat transition meal',
  array['9-12 Months', '1-2 Years'], 'dinner',
  '[{"name": "Chapati", "quantity": "½ piece"}, {"name": "Yellow Dal", "quantity": "½ cup"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Soak & Serve", "description": "Soak chapati in hot dal for 15 minutes. Mash with a spoon."}]'::jsonb,
  'Serve warm.'
),
(
  '353', 'Ragi Porridge & Steamed Apple Pieces',
  'Warm finger millet porridge served alongside sweet steamed apple slices.',
  'https://images.unsplash.com/photo-1517093157656-b9eccef91cb1?w=600', 20, 130, 'Calcium & Iron Heavy', 'Promotes bone growth',
  array['9-12 Months'], 'breakfast',
  '[{"name": "Ragi flour", "quantity": "2 tbsp"}, {"name": "Steamed apple", "quantity": "¼ cup"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Combine", "description": "Prepare ragi porridge. Serve with soft steamed apple slices."}]'::jsonb,
  'Serve warm.'
),
(
  '354', 'Curd',
  'Fresh home-made curd, rich in probiotics.',
  'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=600', 5, 60, 'Probiotics', 'Supports digestive health',
  array['9-12 Months', '1-2 Years'], 'lunch',
  '[{"name": "Curd", "quantity": "½ cup"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Serve", "description": "Pour fresh curd into a small bowl."}]'::jsonb,
  'Serve cool.'
),
(
  '355', 'Paneer Bhurji with Soft Rice',
  'Soft scrambled cottage cheese (paneer) served over warm, soft-cooked rice.',
  'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=600', 20, 160, 'Calcium & Protein', 'Excellent muscle developer',
  array['9-12 Months', '1-2 Years'], 'dinner',
  '[{"name": "Crumbled paneer", "quantity": "¼ cup"}, {"name": "Soft rice", "quantity": "¼ cup"}, {"name": "Ghee", "quantity": "¼ tsp"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Cook paneer", "description": "Saute crumbled paneer with a pinch of turmeric in ghee. Serve over warm rice."}]'::jsonb,
  'Serve warm.'
),
(
  '356', 'Mini Dosa with Sambar',
  'Mini soft fermented rice crepes served with a non-spicy, healthy vegetable sambar.',
  'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=600', 20, 120, 'Probiotic & Energy', 'Traditional South Indian breakfast',
  array['9-12 Months', '1-2 Years'], 'breakfast',
  '[{"name": "Dosa batter", "quantity": "½ cup"}, {"name": "Sambar", "quantity": "½ cup"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Cook Dosa", "description": "Cook soft, small dosas on tawa. Serve with warm vegetable sambar."}]'::jsonb,
  'Serve hot.'
),
(
  '357', 'Spinach Dal Rice',
  'A nutritious, iron-rich combination of steamed rice, yellow dal, and pureed spinach.',
  'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=600', 25, 125, 'Iron & Protein', 'Highly nutritious daily meal',
  array['9-12 Months', '1-2 Years'], 'lunch',
  '[{"name": "Rice & Dal", "quantity": "½ cup"}, {"name": "Spinach pureed", "quantity": "2 tbsp"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Mix", "description": "Mix spinach puree, yellow dal, and soft rice. Serve warm."}]'::jsonb,
  'Serve warm.'
),
(
  '358', 'Vegetable Upma',
  'A soft, roasted semolina dish cooked with onions, carrots, and ghee.',
  'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=600', 20, 110, 'Carbohydrates', 'Steady release of energy',
  array['9-12 Months', '1-2 Years'], 'dinner',
  '[{"name": "Suji", "quantity": "3 tbsp"}, {"name": "Carrots & Peas", "quantity": "2 tbsp"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Cook Upma", "description": "Cook roasted semolina with water, ghee, and steamed vegetables."}]'::jsonb,
  'Serve warm.'
),
(
  '359', 'Oats Porridge with Fruit',
  'Comforting oats porridge topped with a dollop of fresh fruit.',
  'https://images.unsplash.com/photo-1517686469429-8bdb88b9f907?w=600', 15, 130, 'High Fiber', 'Naturally sweet and nutritious',
  array['9-12 Months', '1-2 Years'], 'breakfast',
  '[{"name": "Oats", "quantity": "3 tbsp"}, {"name": "Milk", "quantity": "1 cup"}, {"name": "Fruit pieces (banana/apple)", "quantity": "¼ cup"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Cook Oats", "description": "Simmer oats in milk. Mix in fresh fruit pieces before serving."}]'::jsonb,
  'Serve warm.'
),
(
  '360', 'Soft Chapati Pieces with Vegetable Curry',
  'Soft chapati served with a mild, nutritious mixed vegetable curry.',
  'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=600', 25, 150, 'High Fiber & Carbs', 'Encourages chewing development',
  array['9-12 Months', '1-2 Years'], 'lunch',
  '[{"name": "Chapati", "quantity": "1 piece"}, {"name": "Veg Curry", "quantity": "½ cup"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Tear and serve", "description": "Tear chapati into soft, bite-sized pieces and serve with mixed vegetable curry."}]'::jsonb,
  'Serve warm.'
),
(
  '361', 'Yogurt',
  'Fresh, creamy probiotic curd.',
  'https://images.unsplash.com/photo-1490818387583-1baba5e638af?w=600', 5, 70, 'Probiotics', 'Supports digestive balance',
  array['9-12 Months', '1-2 Years'], 'eveningSnack',
  '[{"name": "Yogurt", "quantity": "½ cup"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Serve", "description": "Serve plain fresh yogurt in a small bowl."}]'::jsonb,
  'Serve cool.'
),
(
  '362', 'Scrambled Egg & Toast Fingers',
  'A soft, fluffy scrambled egg served with soft whole wheat toast fingers.',
  'https://images.unsplash.com/photo-1601050690597-df056fb4ce78?w=600', 15, 140, 'High Protein & Iron', 'Perfect muscle building breakfast',
  array['9-12 Months', '1-2 Years'], 'breakfast',
  '[{"name": "Egg", "quantity": "1 large"}, {"name": "Whole wheat bread", "quantity": "1 slice"}, {"name": "Ghee", "quantity": "½ tsp"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Scramble", "description": "Whisk egg and cook in ghee until soft scrambled."}, {"stepNumber": 2, "title": "Toast bread", "description": "Lightly toast bread and cut into strips (toast fingers)."}]'::jsonb,
  'Serve fresh.'
),
(
  '363', 'Curd Rice with Vegetables',
  'Curd rice combined with steamed carrots and peas.',
  'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=600', 10, 110, 'Probiotics', 'Cooling and nutritious',
  array['9-12 Months', '1-2 Years'], 'lunch',
  '[{"name": "Soft rice", "quantity": "¼ cup"}, {"name": "Curd", "quantity": "¼ cup"}, {"name": "Carrots & Peas steamed", "quantity": "2 tbsp"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Mix", "description": "Combine warm rice, curd, and steamed veggies. Mix well."}]'::jsonb,
  'Serve fresh.'
),
(
  '364', 'Chikoo Pieces',
  'Bite-sized pieces of sweet, ripe sapodilla (chikoo).',
  'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=600', 5, 55, 'High Energy', 'Sweet and easy to digest',
  array['9-12 Months', '1-2 Years'], 'eveningSnack',
  '[{"name": "Chikoo", "quantity": "1 medium"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Slice", "description": "Peel chikoo, remove seeds, and chop into soft small bite-sized pieces."}]'::jsonb,
  'Serve fresh.'
),
(
  '365', 'Dal Rice with Carrot and Peas',
  'Rice and dal served with soft-cooked carrots and peas.',
  'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=600', 25, 130, 'Balanced Diet', 'Packed with protein & fiber',
  array['9-12 Months'], 'dinner',
  '[{"name": "Rice & Dal", "quantity": "½ cup"}, {"name": "Carrot & Peas", "quantity": "2 tbsp"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Serve", "description": "Plate warm dal rice alongside soft-cooked carrots and peas."}]'::jsonb,
  'Serve warm.'
),
(
  '366', 'Vegetable Poha',
  'A light, iron-rich flattened rice dish cooked with carrots, peas, and turmeric.',
  'https://images.unsplash.com/photo-1601050690597-df056fb4ce78?w=600', 20, 110, 'Iron Rich', 'Light and nutritious breakfast',
  array['9-12 Months', '1-2 Years'], 'breakfast',
  '[{"name": "Poha", "quantity": "½ cup"}, {"name": "Mixed vegetables", "quantity": "¼ cup"}, {"name": "Ghee", "quantity": "½ tsp"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Cook Poha", "description": "Rinse poha. Saute veggies in ghee, add turmeric, then toss in poha."}]'::jsonb,
  'Serve hot.'
),
(
  '367', 'Rice with Fish or Paneer',
  'Soft-cooked rice served with mild boneless fish curry or paneer cubes.',
  'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=600', 30, 160, 'Omega-3 & Protein', 'Supports healthy brain development',
  array['9-12 Months', '1-2 Years'], 'lunch',
  '[{"name": "Rice", "quantity": "½ cup"}, {"name": "Fish / Paneer curry", "quantity": "¼ cup"}, {"name": "Vegetables", "quantity": "2 tbsp"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Plate", "description": "Serve soft-cooked rice hot with mild boneless fish or paneer curry and steamed veggies."}]'::jsonb,
  'Serve warm.'
),
(
  '368', 'Vegetable Pulao',
  'A delicious and aromatic rice dish cooked with carrots, beans, and peas.',
  'https://images.unsplash.com/photo-1589302168068-964664d93dc0?w=600', 30, 140, 'Vitamins & Fiber', 'Wholesome family dinner',
  array['9-12 Months', '1-2 Years'], 'dinner',
  '[{"name": "Rice", "quantity": "½ cup"}, {"name": "Mixed vegetables", "quantity": "¼ cup"}, {"name": "Ghee", "quantity": "½ tsp"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Cook Pulao", "description": "Saute veggies. Cook rice with vegetables, mild cardamom, and ghee."}]'::jsonb,
  'Serve hot.'
),
(
  '369', 'Idli with Sambar',
  'Soft steamed fermented rice cakes served with aromatic vegetable lentil sambar.',
  'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=600', 25, 120, 'Gut Friendly & Light', 'Promotes digestive comfort',
  array['9-12 Months', '1-2 Years'], 'breakfast',
  '[{"name": "Idlis", "quantity": "2 pieces"}, {"name": "Vegetable Sambar", "quantity": "½ cup"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Serve", "description": "Serve warm steamed idlis alongside piping hot vegetable sambar."}]'::jsonb,
  'Serve warm.'
),
(
  '370', 'Mixed Vegetable Khichdi',
  'A comforting one-pot dinner of rice, lentils, and mixed veggies.',
  'https://images.unsplash.com/photo-1596797038530-2c107229654b?w=600', 25, 130, 'Folate & Protein', 'Soothing and nutritious dinner',
  array['9-12 Months', '1-2 Years'], 'lunch',
  '[{"name": "Rice & Lentils", "quantity": "½ cup"}, {"name": "Chopped vegetables", "quantity": "¼ cup"}, {"name": "Ghee", "quantity": "½ tsp"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Cook Khichdi", "description": "Pressure cook rice, dal, and vegetables together with ghee."}]'::jsonb,
  'Serve warm.'
),
(
  '371', 'Vegetable Idli with Sambar & Milk',
  'Steamed veggie idli served with warm lentil sambar and a glass of milk.',
  'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=600', 25, 210, 'Fibre & Probiotics', 'Perfect morning energy',
  array['1-2 Years'], 'breakfast',
  '[{"name": "Vegetable Idli", "quantity": "2 pieces"}, {"name": "Sambar", "quantity": "½ cup"}, {"name": "Milk", "quantity": "1 glass"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Serve", "description": "Serve warm steamed idlis with sambar and a glass of milk."}]'::jsonb,
  'Serve warm.'
),
(
  '372', 'Dal Rice with Carrot & Beans Sabzi',
  'Steamed rice, comforting yellow dal, and a side of soft carrot-beans stir fry served with curd.',
  'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=600', 25, 230, 'Balanced Diet', 'Rich in iron and fiber',
  array['1-2 Years'], 'lunch',
  '[{"name": "Rice & Dal", "quantity": "½ cup"}, {"name": "Carrot & Beans", "quantity": "¼ cup"}, {"name": "Curd", "quantity": "½ cup"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Plate", "description": "Serve dal rice alongside carrot & beans sabzi and curd."}]'::jsonb,
  'Serve warm.'
),
(
  '373', 'Banana & Cheese Cube',
  'A quick snack of sliced banana and a small cheddar cheese cube.',
  'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=600', 5, 120, 'Calcium & Potassium', 'Steady afternoon energy',
  array['1-2 Years'], 'eveningSnack',
  '[{"name": "Ripe Banana", "quantity": "1 piece"}, {"name": "Cheese cube", "quantity": "1 piece"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Plate", "description": "Slice banana and serve with a cheese cube on the side."}]'::jsonb,
  'Eat fresh.'
),
(
  '374', 'Chapati with Paneer Curry',
  'Soft whole wheat chapati pieces served with a mild paneer curry.',
  'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=600', 25, 260, 'Calcium & Protein', 'Supports healthy muscle growth',
  array['1-2 Years'], 'dinner',
  '[{"name": "Chapati", "quantity": "1 piece"}, {"name": "Paneer curry", "quantity": "½ cup"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Serve", "description": "Serve warm chapati pieces with mild paneer curry."}]'::jsonb,
  'Serve warm.'
),
(
  '375', 'Ragi Porridge & Apple Pieces',
  'Warm finger millet porridge served alongside sweet steamed apple slices.',
  'https://images.unsplash.com/photo-1517093157656-b9eccef91cb1?w=600', 20, 180, 'Calcium & Iron Heavy', 'Bone and brain development',
  array['1-2 Years'], 'breakfast',
  '[{"name": "Ragi powder", "quantity": "2 tbsp"}, {"name": "Apple slices", "quantity": "¼ cup"}, {"name": "Milk", "quantity": "1 cup"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Combine", "description": "Prepare ragi porridge in milk. Serve with sweet steamed apple pieces."}]'::jsonb,
  'Serve warm.'
),
(
  '376', 'Vegetable Khichdi & Yogurt',
  'Warm vegetable khichdi served with cooling fresh yogurt.',
  'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=600', 25, 220, 'Antioxidant & Probiotic', 'Comforting digestion booster',
  array['1-2 Years'], 'lunch',
  '[{"name": "Vegetable Khichdi", "quantity": "½ cup"}, {"name": "Yogurt", "quantity": "½ cup"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Serve", "description": "Serve hot khichdi topped with a little ghee alongside fresh yogurt."}]'::jsonb,
  'Serve warm.'
),
(
  '377', 'Boiled Sweet Potato Cubes',
  'Steamed, soft sweet potato cubes, rich in fiber and vitamins.',
  'https://images.unsplash.com/photo-1596797038530-2c107229654b?w=600', 20, 110, 'Vitamin A & Fiber', 'Steady energy release',
  array['1-2 Years'], 'eveningSnack',
  '[{"name": "Sweet Potato", "quantity": "½ cup cubed"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Boil", "description": "Boil or steam sweet potato cubes until completely tender."}]'::jsonb,
  'Serve warm.'
),
(
  '378', 'Dosa with Potato Masala',
  'Soft dosa wrap served with a mild, spiced potato filling.',
  'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=600', 20, 240, 'Carbohydrates & Energy', 'Popular and energetic dinner',
  array['1-2 Years'], 'dinner',
  '[{"name": "Dosa", "quantity": "1 piece"}, {"name": "Potato Masala", "quantity": "½ cup"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Serve", "description": "Serve warm dosa with a mild potato filling inside."}]'::jsonb,
  'Serve warm.'
),
(
  '379', 'Vegetable Poha & Milk',
  'Light vegetable poha served with a glass of milk.',
  'https://images.unsplash.com/photo-1601050690597-df056fb4ce78?w=600', 20, 200, 'Iron & Calcium', 'Light morning starter',
  array['1-2 Years'], 'breakfast',
  '[{"name": "Vegetable Poha", "quantity": "½ cup"}, {"name": "Milk", "quantity": "1 glass"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Serve", "description": "Serve warm vegetable poha alongside a glass of warm milk."}]'::jsonb,
  'Serve hot.'
),
(
  '380', 'Rice, Dal, and Spinach Sabzi',
  'Rice and dal served with a side of soft-cooked spinach sabzi.',
  'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=600', 25, 230, 'Iron & Protein', 'Classic daily diet staple',
  array['1-2 Years'], 'lunch',
  '[{"name": "Rice & Dal", "quantity": "½ cup"}, {"name": "Spinach sabzi", "quantity": "¼ cup"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Plate", "description": "Serve comforting dal and rice with a side of soft spinach."}]'::jsonb,
  'Serve warm.'
),
(
  '381', 'Papaya Pieces',
  'Bite-sized pieces of sweet, ripe papaya.',
  'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=600', 5, 60, 'Vitamin C Rich', 'Excellent digestive support',
  array['1-2 Years'], 'eveningSnack',
  '[{"name": "Papaya pieces", "quantity": "½ cup"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Prepare", "description": "Peel and chop fresh papaya into small cubes."}]'::jsonb,
  'Serve fresh.'
),
(
  '382', 'Chapati with Mixed Vegetable Curry',
  'Soft chapati served with a mild, nutritious mixed vegetable curry.',
  'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=600', 25, 240, 'Fiber & Vitamins', 'Digestive comfort',
  array['1-2 Years'], 'dinner',
  '[{"name": "Chapati", "quantity": "1 piece"}, {"name": "Mixed veg curry", "quantity": "½ cup"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Serve", "description": "Tear chapati into pieces and serve with warm mixed vegetable curry."}]'::jsonb,
  'Serve warm.'
),
(
  '383', 'Boiled Corn',
  'Steamed sweet corn kernels, tender and sweet.',
  'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=600', 10, 90, 'High Fiber', 'Boosts digestion',
  array['1-2 Years'], 'eveningSnack',
  '[{"name": "Sweet Corn", "quantity": "½ cup"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Steam", "description": "Steam sweet corn kernels with a pinch of salt."}]'::jsonb,
  'Serve warm.'
),
(
  '384', 'Egg Omelette & Soft Toast',
  'A soft, thin egg omelette folded and served with warm toast.',
  'https://images.unsplash.com/photo-1601050690597-df056fb4ce78?w=600', 15, 220, 'High Protein & Grains', 'Wholesome growth energy',
  array['1-2 Years'], 'breakfast',
  '[{"name": "Eggs", "quantity": "2 large"}, {"name": "Whole wheat bread", "quantity": "1 slice"}, {"name": "Ghee", "quantity": "1 tsp"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Make omelette", "description": "Whisk eggs with a pinch of pepper. Cook in a tawa with ghee."}, {"stepNumber": 2, "title": "Serve", "description": "Serve omelette with warm toasted bread."}]'::jsonb,
  'Serve fresh.'
),
(
  '385', 'Rice with Fish/Chicken or Paneer',
  'Steam rice served with a mild fish, chicken, or paneer curry and soft veggies.',
  'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=600', 30, 260, 'Protein & Omega-3', 'Aids brain & tissue development',
  array['1-2 Years'], 'lunch',
  '[{"name": "Steamed Rice", "quantity": "½ cup"}, {"name": "Fish/Chicken/Paneer curry", "quantity": "½ cup"}, {"name": "Vegetables", "quantity": "¼ cup"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Serve", "description": "Serve warm rice with curry and a side of soft veggies."}]'::jsonb,
  'Serve warm.'
),
(
  '386', 'Yogurt with Fruit',
  'Fresh, probiotic curd topped with sweet, ripe seasonal fruits.',
  'https://images.unsplash.com/photo-1490818387583-1baba5e638af?w=600', 5, 120, 'Probiotic & Vitamins', 'Excellent gut health booster',
  array['1-2 Years'], 'eveningSnack',
  '[{"name": "Curd", "quantity": "½ cup"}, {"name": "Chopped fruit", "quantity": "¼ cup"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Serve", "description": "Combine fresh curd and fruit segments in a bowl."}]'::jsonb,
  'Serve cool.'
),
(
  '387', 'Chapati with Dal and Vegetables',
  'Soft chapati pieces served with a side of warm yellow dal and soft vegetables.',
  'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=600', 25, 230, 'Balanced nutrition', 'Nourishing and filling dinner',
  array['1-2 Years'], 'lunch',
  '[{"name": "Chapati", "quantity": "1 piece"}, {"name": "Yellow Dal", "quantity": "½ cup"}, {"name": "Steamed vegetables", "quantity": "¼ cup"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Assemble", "description": "Serve chapati warm with dal and vegetables on the side."}]'::jsonb,
  'Serve warm.'
),
(
  '388', 'Chikoo or Banana',
  'Fresh, sweet ripe fruit (chikoo or banana).',
  'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=600', 5, 80, 'Potassium & Minerals', 'Sustained energy boost',
  array['1-2 Years'], 'eveningSnack',
  '[{"name": "Chikoo / Banana", "quantity": "1 piece"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Serve", "description": "Peel and chop fruit into small bite-sized slices."}]'::jsonb,
  'Serve fresh.'
),
(
  '389', 'Rice with Vegetable Stew',
  'Soft rice served with a coconut milk-based mild vegetable stew.',
  'https://images.unsplash.com/photo-1596797038530-2c107229654b?w=600', 25, 220, 'Antioxidant & Probiotic', 'Creamy, warm vegetable dinner',
  array['1-2 Years'], 'dinner',
  '[{"name": "Steamed Rice", "quantity": "½ cup"}, {"name": "Vegetable stew", "quantity": "½ cup"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Assemble", "description": "Pour mild vegetable stew over warm steamed rice."}]'::jsonb,
  'Serve warm.'
),
(
  '390', 'Upma with Vegetables',
  'Nutritious semolina upma loaded with peas, carrots, and beans.',
  'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=600', 20, 160, 'Complex Carbs', 'Steady morning starter',
  array['1-2 Years'], 'breakfast',
  '[{"name": "Upma", "quantity": "½ cup"}, {"name": "Ghee", "quantity": "½ tsp"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Serve", "description": "Serve warm upma topped with a little ghee."}]'::jsonb,
  'Serve hot.'
),
(
  '391', 'Mixed Vegetable Khichdi & Curd',
  'Warm vegetable khichdi served with cooling fresh yogurt.',
  'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=600', 25, 240, 'Protein & Probiotic', 'Digestive comfort staple',
  array['1-2 Years'], 'lunch',
  '[{"name": "Khichdi", "quantity": "½ cup"}, {"name": "Curd", "quantity": "½ cup"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Serve", "description": "Serve hot vegetable khichdi with a bowl of curd."}]'::jsonb,
  'Serve warm.'
),
(
  '392', 'Seasonal Fruit',
  'A healthy serving of fresh, chopped seasonal fruit.',
  'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=600', 5, 60, 'Vitamins & Minerals', 'Fresh fruit snack',
  array['1-2 Years'], 'eveningSnack',
  '[{"name": "Fresh seasonal fruit", "quantity": "½ cup chopped"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Prepare", "description": "Wash, peel and chop seasonal fruit into small cubes."}]'::jsonb,
  'Serve fresh.'
),
(
  '393', 'Chapati with Paneer and Peas Curry',
  'Soft chapati pieces served with a mild cottage cheese and peas curry.',
  'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=600', 25, 250, 'Protein & Calcium', 'Healthy bones & muscles development',
  array['1-2 Years'], 'dinner',
  '[{"name": "Chapati", "quantity": "1 piece"}, {"name": "Paneer & Peas curry", "quantity": "½ cup"}]'::jsonb,
  '[{"stepNumber": 1, "title": "Serve", "description": "Serve soft chapati pieces with warm paneer and peas curry."}]'::jsonb,
  'Serve warm.'
);


-- ── Seed Weekly Meal Plans ──────────────────────────────────

-- 1. Weekly Meal Plan for Pregnant Women (Pregnancy menu)
-- Day 0 (Mon) to 6 (Sun) mapping to recipes (Exactly 4 slots per day)
insert into public.weekly_meal_plans (role, age_group, day_index, slot_index, meal_name, time_label, emoji, recipe_id)
values
-- Monday
('pregnant', 'Pregnancy', 0, 0, 'Breakfast', '8:00 AM', '🌅', '101'),
('pregnant', 'Pregnancy', 0, 1, 'Lunch', '1:00 PM', '☀️', '102'),
('pregnant', 'Pregnancy', 0, 2, 'Evening Snack', '4:30 PM', '🌤️', '103'),
('pregnant', 'Pregnancy', 0, 3, 'Dinner', '7:30 PM', '🌙', '104'),
-- Tuesday
('pregnant', 'Pregnancy', 1, 0, 'Breakfast', '8:00 AM', '🌅', '105'),
('pregnant', 'Pregnancy', 1, 1, 'Lunch', '1:00 PM', '☀️', '106'),
('pregnant', 'Pregnancy', 1, 2, 'Evening Snack', '4:30 PM', '🌤️', '107'),
('pregnant', 'Pregnancy', 1, 3, 'Dinner', '7:30 PM', '🌙', '108'),
-- Wednesday
('pregnant', 'Pregnancy', 2, 0, 'Breakfast', '8:00 AM', '🌅', '109'),
('pregnant', 'Pregnancy', 2, 1, 'Lunch', '1:00 PM', '☀️', '110'),
('pregnant', 'Pregnancy', 2, 2, 'Evening Snack', '4:30 PM', '🌤️', '111'),
('pregnant', 'Pregnancy', 2, 3, 'Dinner', '7:30 PM', '🌙', '112'),
-- Thursday
('pregnant', 'Pregnancy', 3, 0, 'Breakfast', '8:00 AM', '🌅', '113'),
('pregnant', 'Pregnancy', 3, 1, 'Lunch', '1:00 PM', '☀️', '114'),
('pregnant', 'Pregnancy', 3, 2, 'Evening Snack', '4:30 PM', '🌤️', '115'),
('pregnant', 'Pregnancy', 3, 3, 'Dinner', '7:30 PM', '🌙', '116'),
-- Friday
('pregnant', 'Pregnancy', 4, 0, 'Breakfast', '8:00 AM', '🌅', '117'),
('pregnant', 'Pregnancy', 4, 1, 'Lunch', '1:00 PM', '☀️', '118'),
('pregnant', 'Pregnancy', 4, 2, 'Evening Snack', '4:30 PM', '🌤️', '119'),
('pregnant', 'Pregnancy', 4, 3, 'Dinner', '7:30 PM', '🌙', '120'),
-- Saturday
('pregnant', 'Pregnancy', 5, 0, 'Breakfast', '8:00 AM', '🌅', '121'),
('pregnant', 'Pregnancy', 5, 1, 'Lunch', '1:00 PM', '☀️', '122'),
('pregnant', 'Pregnancy', 5, 2, 'Evening Snack', '4:30 PM', '🌤️', '123'),
('pregnant', 'Pregnancy', 5, 3, 'Dinner', '7:30 PM', '🌙', '124'),
-- Sunday
('pregnant', 'Pregnancy', 6, 0, 'Breakfast', '8:00 AM', '🌅', '125'),
('pregnant', 'Pregnancy', 6, 1, 'Lunch', '1:00 PM', '☀️', '126'),
('pregnant', 'Pregnancy', 6, 2, 'Evening Snack', '4:30 PM', '🌤️', '127'),
('pregnant', 'Pregnancy', 6, 3, 'Dinner', '7:30 PM', '🌙', '128');

-- 2. Weekly Meal Plan for Babies (Parent role, age_group = '6 Months')
insert into public.weekly_meal_plans (role, age_group, day_index, slot_index, meal_name, time_label, emoji, recipe_id)
values
-- Monday
('parent', '6 Months', 0, 0, 'Breakfast', '8:00 AM', '🌅', '301'),
('parent', '6 Months', 0, 1, 'Lunch', '1:00 PM', '☀️', '302'),
('parent', '6 Months', 0, 2, 'Evening Snack', '4:30 PM', '🌤️', '303'),
('parent', '6 Months', 0, 3, 'Dinner', '7:30 PM', '🌙', '304'),
-- Tuesday
('parent', '6 Months', 1, 0, 'Breakfast', '8:00 AM', '🌅', '305'),
('parent', '6 Months', 1, 1, 'Lunch', '1:00 PM', '☀️', '306'),
('parent', '6 Months', 1, 2, 'Evening Snack', '4:30 PM', '🌤️', '303'),
('parent', '6 Months', 1, 3, 'Dinner', '7:30 PM', '🌙', '307'),
-- Wednesday
('parent', '6 Months', 2, 0, 'Breakfast', '8:00 AM', '🌅', '308'),
('parent', '6 Months', 2, 1, 'Lunch', '1:00 PM', '☀️', '309'),
('parent', '6 Months', 2, 2, 'Evening Snack', '4:30 PM', '🌤️', '303'),
('parent', '6 Months', 2, 3, 'Dinner', '7:30 PM', '🌙', '310'),
-- Thursday
('parent', '6 Months', 3, 0, 'Breakfast', '8:00 AM', '🌅', '311'),
('parent', '6 Months', 3, 1, 'Lunch', '1:00 PM', '☀️', '312'),
('parent', '6 Months', 3, 2, 'Evening Snack', '4:30 PM', '🌤️', '303'),
('parent', '6 Months', 3, 3, 'Dinner', '7:30 PM', '🌙', '313'),
-- Friday
('parent', '6 Months', 4, 0, 'Breakfast', '8:00 AM', '🌅', '305'),
('parent', '6 Months', 4, 1, 'Lunch', '1:00 PM', '☀️', '314'),
('parent', '6 Months', 4, 2, 'Evening Snack', '4:30 PM', '🌤️', '303'),
('parent', '6 Months', 4, 3, 'Dinner', '7:30 PM', '🌙', '304'),
-- Saturday
('parent', '6 Months', 5, 0, 'Breakfast', '8:00 AM', '🌅', '308'),
('parent', '6 Months', 5, 1, 'Lunch', '1:00 PM', '☀️', '315'),
('parent', '6 Months', 5, 2, 'Evening Snack', '4:30 PM', '🌤️', '303'),
('parent', '6 Months', 5, 3, 'Dinner', '7:30 PM', '🌙', '316'),
-- Sunday
('parent', '6 Months', 6, 0, 'Breakfast', '8:00 AM', '🌅', '301'),
('parent', '6 Months', 6, 1, 'Lunch', '1:00 PM', '☀️', '317'),
('parent', '6 Months', 6, 2, 'Evening Snack', '4:30 PM', '🌤️', '303'),
('parent', '6 Months', 6, 3, 'Dinner', '7:30 PM', '🌙', '318');

-- 3. Weekly Meal Plan for Babies (Parent role, age_group = '6–8 Months')
insert into public.weekly_meal_plans (role, age_group, day_index, slot_index, meal_name, time_label, emoji, recipe_id)
values
-- Monday
('parent', '6–8 Months', 0, 0, 'Breakfast', '8:00 AM', '🌅', '305'),
('parent', '6–8 Months', 0, 1, 'Lunch', '1:00 PM', '☀️', '319'),
('parent', '6–8 Months', 0, 2, 'Evening Snack', '4:30 PM', '🌤️', '304'),
('parent', '6–8 Months', 0, 3, 'Dinner', '7:30 PM', '🌙', '309'),
-- Tuesday
('parent', '6–8 Months', 1, 0, 'Breakfast', '8:00 AM', '🌅', '301'),
('parent', '6–8 Months', 1, 1, 'Lunch', '1:00 PM', '☀️', '313'),
('parent', '6–8 Months', 1, 2, 'Evening Snack', '4:30 PM', '🌤️', '307'),
('parent', '6–8 Months', 1, 3, 'Dinner', '7:30 PM', '🌙', '308'),
-- Wednesday
('parent', '6–8 Months', 2, 0, 'Breakfast', '8:00 AM', '🌅', '320'),
('parent', '6–8 Months', 2, 1, 'Lunch', '1:00 PM', '☀️', '306'),
('parent', '6–8 Months', 2, 2, 'Evening Snack', '4:30 PM', '🌤️', '318'),
('parent', '6–8 Months', 2, 3, 'Dinner', '7:30 PM', '🌙', '321'),
-- Thursday
('parent', '6–8 Months', 3, 0, 'Breakfast', '8:00 AM', '🌅', '322'),
('parent', '6–8 Months', 3, 1, 'Lunch', '1:00 PM', '☀️', '323'),
('parent', '6–8 Months', 3, 2, 'Evening Snack', '4:30 PM', '🌤️', '304'),
('parent', '6–8 Months', 3, 3, 'Dinner', '7:30 PM', '🌙', '324'),
-- Friday
('parent', '6–8 Months', 4, 0, 'Breakfast', '8:00 AM', '🌅', '305'),
('parent', '6–8 Months', 4, 1, 'Lunch', '1:00 PM', '☀️', '325'),
('parent', '6–8 Months', 4, 2, 'Evening Snack', '4:30 PM', '🌤️', '326'),
('parent', '6–8 Months', 4, 3, 'Dinner', '7:30 PM', '🌙', '327'),
-- Saturday
('parent', '6–8 Months', 5, 0, 'Breakfast', '8:00 AM', '🌅', '301'),
('parent', '6–8 Months', 5, 1, 'Lunch', '1:00 PM', '☀️', '328'),
('parent', '6–8 Months', 5, 2, 'Evening Snack', '4:30 PM', '🌤️', '316'),
('parent', '6–8 Months', 5, 3, 'Dinner', '7:30 PM', '🌙', '319'),
-- Sunday
('parent', '6–8 Months', 6, 0, 'Breakfast', '8:00 AM', '🌅', '308'),
('parent', '6–8 Months', 6, 1, 'Lunch', '1:00 PM', '☀️', '317'),
('parent', '6–8 Months', 6, 2, 'Evening Snack', '4:30 PM', '🌤️', '318'),
('parent', '6–8 Months', 6, 3, 'Dinner', '7:30 PM', '🌙', '325');

-- 4. Weekly Meal Plan for Babies (Parent role, age_group = '8–10 Months')
insert into public.weekly_meal_plans (role, age_group, day_index, slot_index, meal_name, time_label, emoji, recipe_id)
values
-- Monday
('parent', '8–10 Months', 0, 0, 'Breakfast', '8:00 AM', '🌅', '329'),
('parent', '8–10 Months', 0, 1, 'Lunch', '1:00 PM', '☀️', '330'),
('parent', '8–10 Months', 0, 2, 'Evening Snack', '4:30 PM', '🌤️', '331'),
('parent', '8–10 Months', 0, 3, 'Dinner', '7:30 PM', '🌙', '317'),
-- Tuesday
('parent', '8–10 Months', 1, 0, 'Breakfast', '8:00 AM', '🌅', '305'),
('parent', '8–10 Months', 1, 1, 'Lunch', '1:00 PM', '☀️', '332'),
('parent', '8–10 Months', 1, 2, 'Evening Snack', '4:30 PM', '🌤️', '333'),
('parent', '8–10 Months', 1, 3, 'Dinner', '7:30 PM', '🌙', '308'),
-- Wednesday
('parent', '8–10 Months', 2, 0, 'Breakfast', '8:00 AM', '🌅', '334'),
('parent', '8–10 Months', 2, 1, 'Lunch', '1:00 PM', '☀️', '335'),
('parent', '8–10 Months', 2, 2, 'Evening Snack', '4:30 PM', '🌤️', '336'),
('parent', '8–10 Months', 2, 3, 'Dinner', '7:30 PM', '🌙', '337'),
-- Thursday
('parent', '8–10 Months', 3, 0, 'Breakfast', '8:00 AM', '🌅', '338'),
('parent', '8–10 Months', 3, 1, 'Lunch', '1:00 PM', '☀️', '339'),
('parent', '8–10 Months', 3, 2, 'Evening Snack', '4:30 PM', '🌤️', '340'),
('parent', '8–10 Months', 3, 3, 'Dinner', '7:30 PM', '🌙', '341'),
-- Friday
('parent', '8–10 Months', 4, 0, 'Breakfast', '8:00 AM', '🌅', '342'),
('parent', '8–10 Months', 4, 1, 'Lunch', '1:00 PM', '☀️', '343'),
('parent', '8–10 Months', 4, 2, 'Evening Snack', '4:30 PM', '🌤️', '344'),
('parent', '8–10 Months', 4, 3, 'Dinner', '7:30 PM', '🌙', '324'),
-- Saturday
('parent', '8–10 Months', 5, 0, 'Breakfast', '8:00 AM', '🌅', '345'),
('parent', '8–10 Months', 5, 1, 'Lunch', '1:00 PM', '☀️', '346'),
('parent', '8–10 Months', 5, 2, 'Evening Snack', '4:30 PM', '🌤️', '312'),
('parent', '8–10 Months', 5, 3, 'Dinner', '7:30 PM', '🌙', '319'),
-- Sunday
('parent', '8–10 Months', 6, 0, 'Breakfast', '8:00 AM', '🌅', '305'),
('parent', '8–10 Months', 6, 1, 'Lunch', '1:00 PM', '☀️', '347'),
('parent', '8–10 Months', 6, 2, 'Evening Snack', '4:30 PM', '🌤️', '348'),
('parent', '8–10 Months', 6, 3, 'Dinner', '7:30 PM', '🌙', '325');

-- 5. Weekly Meal Plan for Babies (Parent role, age_group = '10–12 Months')
insert into public.weekly_meal_plans (role, age_group, day_index, slot_index, meal_name, time_label, emoji, recipe_id)
values
-- Monday
('parent', '10–12 Months', 0, 0, 'Breakfast', '8:00 AM', '🌅', '349'),
('parent', '10–12 Months', 0, 1, 'Lunch', '1:00 PM', '☀️', '350'),
('parent', '10–12 Months', 0, 2, 'Evening Snack', '4:30 PM', '🌤️', '351'),
('parent', '10–12 Months', 0, 3, 'Dinner', '7:30 PM', '🌙', '352'),
-- Tuesday
('parent', '10–12 Months', 1, 0, 'Breakfast', '8:00 AM', '🌅', '353'),
('parent', '10–12 Months', 1, 1, 'Lunch', '1:00 PM', '☀️', '323'),
('parent', '10–12 Months', 1, 2, 'Evening Snack', '4:30 PM', '🌤️', '336'),
('parent', '10–12 Months', 1, 3, 'Dinner', '7:30 PM', '🌙', '355'),
-- Wednesday
('parent', '10–12 Months', 2, 0, 'Breakfast', '8:00 AM', '🌅', '356'),
('parent', '10–12 Months', 2, 1, 'Lunch', '1:00 PM', '☀️', '357'),
('parent', '10–12 Months', 2, 2, 'Evening Snack', '4:30 PM', '🌤️', '331'),
('parent', '10–12 Months', 2, 3, 'Dinner', '7:30 PM', '🌙', '358'),
-- Thursday
('parent', '10–12 Months', 3, 0, 'Breakfast', '8:00 AM', '🌅', '359'),
('parent', '10–12 Months', 3, 1, 'Lunch', '1:00 PM', '☀️', '360'),
('parent', '10–12 Months', 3, 2, 'Evening Snack', '4:30 PM', '🌤️', '361'),
('parent', '10–12 Months', 3, 3, 'Dinner', '7:30 PM', '🌙', '319'),
-- Friday
('parent', '10–12 Months', 4, 0, 'Breakfast', '8:00 AM', '🌅', '362'),
('parent', '10–12 Months', 4, 1, 'Lunch', '1:00 PM', '☀️', '363'),
('parent', '10–12 Months', 4, 2, 'Evening Snack', '4:30 PM', '🌤️', '364'),
('parent', '10–12 Months', 4, 3, 'Dinner', '7:30 PM', '🌙', '365'),
-- Saturday
('parent', '10–12 Months', 5, 0, 'Breakfast', '8:00 AM', '🌅', '366'),
('parent', '10–12 Months', 5, 1, 'Lunch', '1:00 PM', '☀️', '367'),
('parent', '10–12 Months', 5, 2, 'Evening Snack', '4:30 PM', '🌤️', '340'),
('parent', '10–12 Months', 5, 3, 'Dinner', '7:30 PM', '🌙', '368'),
-- Sunday
('parent', '10–12 Months', 6, 0, 'Breakfast', '8:00 AM', '🌅', '369'),
('parent', '10–12 Months', 6, 1, 'Lunch', '1:00 PM', '☀️', '370'),
('parent', '10–12 Months', 6, 2, 'Evening Snack', '4:30 PM', '🌤️', '348'),
('parent', '10–12 Months', 6, 3, 'Dinner', '7:30 PM', '🌙', '352');

-- 6. Weekly Meal Plan for Toddlers (Parent role, age_group = '1–2 Years')
insert into public.weekly_meal_plans (role, age_group, day_index, slot_index, meal_name, time_label, emoji, recipe_id)
values
-- Monday
('parent', '1–2 Years', 0, 0, 'Breakfast', '8:00 AM', '🌅', '371'),
('parent', '1–2 Years', 0, 1, 'Lunch', '1:00 PM', '☀️', '372'),
('parent', '1–2 Years', 0, 2, 'Evening Snack', '4:30 PM', '🌤️', '373'),
('parent', '1–2 Years', 0, 3, 'Dinner', '7:30 PM', '🌙', '374'),
-- Tuesday
('parent', '1–2 Years', 1, 0, 'Breakfast', '8:00 AM', '🌅', '375'),
('parent', '1–2 Years', 1, 1, 'Lunch', '1:00 PM', '☀️', '376'),
('parent', '1–2 Years', 1, 2, 'Evening Snack', '4:30 PM', '🌤️', '377'),
('parent', '1–2 Years', 1, 3, 'Dinner', '7:30 PM', '🌙', '378'),
-- Wednesday
('parent', '1–2 Years', 2, 0, 'Breakfast', '8:00 AM', '🌅', '379'),
('parent', '1–2 Years', 2, 1, 'Lunch', '1:00 PM', '☀️', '380'),
('parent', '1–2 Years', 2, 2, 'Evening Snack', '4:30 PM', '🌤️', '381'),
('parent', '1–2 Years', 2, 3, 'Dinner', '7:30 PM', '🌙', '382'),
-- Thursday
('parent', '1–2 Years', 3, 0, 'Breakfast', '8:00 AM', '🌅', '359'),
('parent', '1–2 Years', 3, 1, 'Lunch', '1:00 PM', '☀️', '363'),
('parent', '1–2 Years', 3, 2, 'Evening Snack', '4:30 PM', '🌤️', '383'),
('parent', '1–2 Years', 3, 3, 'Dinner', '7:30 PM', '🌙', '319'),
-- Friday
('parent', '1–2 Years', 4, 0, 'Breakfast', '8:00 AM', '🌅', '384'),
('parent', '1–2 Years', 4, 1, 'Lunch', '1:00 PM', '☀️', '385'),
('parent', '1–2 Years', 4, 2, 'Evening Snack', '4:30 PM', '🌤️', '386'),
('parent', '1–2 Years', 4, 3, 'Dinner', '7:30 PM', '🌙', '368'),
-- Saturday
('parent', '1–2 Years', 5, 0, 'Breakfast', '8:00 AM', '🌅', '356'),
('parent', '1–2 Years', 5, 1, 'Lunch', '1:00 PM', '☀️', '387'),
('parent', '1–2 Years', 5, 2, 'Evening Snack', '4:30 PM', '🌤️', '388'),
('parent', '1–2 Years', 5, 3, 'Dinner', '7:30 PM', '🌙', '389'),
-- Sunday
('parent', '1–2 Years', 6, 0, 'Breakfast', '8:00 AM', '🌅', '390'),
('parent', '1–2 Years', 6, 1, 'Lunch', '1:00 PM', '☀️', '391'),
('parent', '1–2 Years', 6, 2, 'Evening Snack', '4:30 PM', '🌤️', '392'),
('parent', '1–2 Years', 6, 3, 'Dinner', '7:30 PM', '🌙', '393');
