import 'milestone_model.dart';

// ── Library entry point ───────────────────────────────────────────────────────

/// Returns all 6 CategoryGuidance objects for a given age band index.
List<CategoryGuidance> guidanceForAgeBand(int bandIndex) {
  return MilestoneCategory.values
      .map((cat) => _guidanceFor(bandIndex, cat))
      .toList();
}

/// Returns guidance for a specific category + age band.
CategoryGuidance guidanceForCategory(int bandIndex, MilestoneCategory category) {
  return _guidanceFor(bandIndex, category);
}

/// Overlay Supabase statuses onto library milestones.
/// [supabaseStatuses] maps milestone title (lowercase) → (status, achievedDate)
CategoryGuidance enrichGuidance(
  CategoryGuidance guidance,
  Map<String, (MilestoneStatus, String?)> supabaseStatuses,
) {
  final updated = guidance.milestones.map((m) {
    final key = m.title.toLowerCase();
    if (supabaseStatuses.containsKey(key)) {
      final (status, date) = supabaseStatuses[key]!;
      return m.copyWith(status: status, achievedDate: date);
    }
    return m;
  }).toList();
  return CategoryGuidance(
    category: guidance.category,
    ageBandIndex: guidance.ageBandIndex,
    aboutText: guidance.aboutText,
    milestones: updated,
    activities: guidance.activities,
    signsToLookFor: guidance.signsToLookFor,
    whenToWorry: guidance.whenToWorry,
    commonConcerns: guidance.commonConcerns,
    parentTips: guidance.parentTips,
  );
}

// ── Dispatcher ────────────────────────────────────────────────────────────────

CategoryGuidance _guidanceFor(int band, MilestoneCategory cat) {
  // Bands 0-5 (0-8 weeks) share newborn content
  if (band <= 5) return _newbornGuidance(band, cat);
  // Bands 6-7 (2-4 months)
  if (band <= 7) return _twoToFourMonthsGuidance(band, cat);
  // Bands 8-9 (4-6 months)
  if (band <= 9) return _fourToSixMonthsGuidance(band, cat);
  // Band 10 (6-9 months)
  if (band == 10) return _sixToNineMonthsGuidance(band, cat);
  // Band 11 (9-12 months)
  if (band == 11) return _nineToTwelveMonthsGuidance(band, cat);
  // Bands 12-13 (1-2 years)
  if (band <= 13) return _oneToTwoYearsGuidance(band, cat);
  // Bands 14-15 (2-3 years)
  if (band <= 15) return _twoToThreeYearsGuidance(band, cat);
  // Bands 16-17 (3-5 years)
  if (band <= 17) return _threeToFiveYearsGuidance(band, cat);
  // Band 18 (5-6 years)
  return _fiveToSixYearsGuidance(band, cat);
}

// ── 0-8 Weeks (Newborn) ───────────────────────────────────────────────────────

CategoryGuidance _newbornGuidance(int band, MilestoneCategory cat) {
  final label = ageBands[band].label;
  switch (cat) {
    case MilestoneCategory.grossMotor:
      return CategoryGuidance(
        category: cat, ageBandIndex: band,
        aboutText: 'In the first weeks, your newborn\'s movements are mostly reflexive. They will gradually gain more control of their head and limbs. Tummy time is the most important activity you can do right now.',
        milestones: [
          MilestoneItem(id: 'nb_gm_1_$band', title: 'Lifts head briefly during tummy time', description: 'Raises head off the surface when placed on tummy.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'nb_gm_2_$band', title: 'Turns head side to side', description: 'Moves head left and right when lying on back.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'nb_gm_3_$band', title: 'Moves arms and legs actively', description: 'Kicks legs and waves arms spontaneously.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
        ],
        activities: [
          MilestoneActivity(title: 'Daily Tummy Time', description: 'Place baby on tummy for 1-2 minutes after each nappy change.', emoji: '🍼', steps: ['Lay baby on a firm flat surface.', 'Get down to their level and make eye contact.', 'Start with 1 minute and increase gradually.']),
          MilestoneActivity(title: 'Gentle Stretches', description: 'Gently move baby\'s arms and legs in a cycling motion.', emoji: '🌟', steps: ['Lay baby on their back.', 'Gently cycle their legs like a bicycle.', 'Repeat 5-10 times twice a day.']),
        ],
        signsToLookFor: [
          MilestoneSign(title: 'Lifts head briefly during tummy time', description: 'Even a second counts in the first weeks.', isPositive: true),
          MilestoneSign(title: 'Startles to loud sounds', description: 'Shows the nervous system is responding.', isPositive: true),
          MilestoneSign(title: 'No head movement at all during tummy time', description: 'May need more practice or evaluation.', isPositive: false),
        ],
        whenToWorry: [
          MilestoneWarning(title: 'No movement in arms or legs', description: 'If baby shows very little spontaneous movement, consult your doctor.', emoji: '⚠️'),
          MilestoneWarning(title: 'Head always falls to one side', description: 'Could indicate torticollis — worth checking with a paediatrician.', emoji: '📋'),
        ],
        commonConcerns: [
          CommonConcern(question: 'How much tummy time does my newborn need?', answer: 'Start with 1-2 minutes, 2-3 times a day. Gradually increase to 30 minutes total per day by 3 months. Always supervise tummy time.'),
          CommonConcern(question: 'My baby hates tummy time. What should I do?', answer: 'Try tummy time on your chest, use a rolled towel under their chest, or do it right after a nappy change when they\'re alert. Keep sessions short and positive.'),
        ],
        parentTips: [
          'Start tummy time from day one — even 1 minute counts!',
          'Alternate which side you hold baby to encourage equal head turning.',
          'Skin-to-skin time also counts as tummy time.',
        ],
      );

    case MilestoneCategory.fineMotor:
      return CategoryGuidance(
        category: cat, ageBandIndex: band,
        aboutText: 'Newborn fine motor skills are mostly reflexive. The grasp reflex is strong — baby will grip your finger tightly. Over the coming weeks, these reflexes will gradually become more intentional.',
        milestones: [
          MilestoneItem(id: 'nb_fm_1_$band', title: 'Grasps finger when placed in palm', description: 'Reflexively grips a finger placed in their hand.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'nb_fm_2_$band', title: 'Brings hands to face', description: 'Moves hands toward mouth or face.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'nb_fm_3_$band', title: 'Opens and closes hands', description: 'Begins to open and close fists.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
        ],
        activities: [
          MilestoneActivity(title: 'Finger Grasp Play', description: 'Let baby grip your finger during feeding or cuddle time.', emoji: '🤝', steps: ['Place your finger in baby\'s palm.', 'Let them grip it naturally.', 'Gently wiggle your finger to stimulate the grasp.']),
        ],
        signsToLookFor: [
          MilestoneSign(title: 'Strong grasp reflex', description: 'Baby grips your finger tightly — this is normal and healthy.', isPositive: true),
          MilestoneSign(title: 'Hands mostly fisted', description: 'Normal in newborns — hands will open more over time.', isPositive: true),
        ],
        whenToWorry: [
          MilestoneWarning(title: 'No grasp reflex at all', description: 'If baby doesn\'t grip when you place your finger in their palm, mention it to your doctor.', emoji: '⚠️'),
        ],
        commonConcerns: [
          CommonConcern(question: 'My baby\'s hands are always fisted. Is that normal?', answer: 'Yes, completely normal in the first 2-3 months. The grasp reflex keeps hands closed. They will open more as the reflex fades around 3-4 months.'),
        ],
        parentTips: [
          'Let baby grip your finger during feeds — it\'s bonding and stimulation.',
          'Avoid mittens when possible so baby can feel and explore with their hands.',
        ],
      );

    case MilestoneCategory.language:
      return CategoryGuidance(
        category: cat, ageBandIndex: band,
        aboutText: 'Your newborn already recognises your voice from the womb. They communicate through crying, and will soon begin making small sounds. Talk to your baby constantly — every word you say is building their brain.',
        milestones: [
          MilestoneItem(id: 'nb_la_1_$band', title: 'Startles to loud sounds', description: 'Reacts to sudden loud noises.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'nb_la_2_$band', title: 'Recognises parent\'s voice', description: 'Calms or turns toward familiar voices.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'nb_la_3_$band', title: 'Makes small throaty sounds', description: 'Produces soft grunts and vowel-like sounds.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
        ],
        activities: [
          MilestoneActivity(title: 'Talk During Routines', description: 'Narrate everything you do during nappy changes, feeds, and baths.', emoji: '💬', steps: ['Describe what you\'re doing: "Now I\'m putting on your nappy."', 'Use a warm, sing-song voice.', 'Pause and wait — even newborns respond to pauses.']),
          MilestoneActivity(title: 'Sing Lullabies', description: 'Singing helps baby learn rhythm and language patterns.', emoji: '🎵', steps: ['Choose 2-3 simple songs.', 'Sing them consistently at sleep time.', 'Baby will begin to recognise and calm to them.']),
        ],
        signsToLookFor: [
          MilestoneSign(title: 'Calms to your voice', description: 'Shows baby recognises and is soothed by familiar voices.', isPositive: true),
          MilestoneSign(title: 'Different cries for different needs', description: 'Hunger cry vs discomfort cry — you\'ll learn to tell them apart.', isPositive: true),
        ],
        whenToWorry: [
          MilestoneWarning(title: 'No startle response to loud sounds', description: 'Could indicate hearing issues. Mention to your doctor at the next check-up.', emoji: '👂'),
          MilestoneWarning(title: 'Does not calm to familiar voices', description: 'If baby never settles to your voice, worth discussing with your paediatrician.', emoji: '💬'),
        ],
        commonConcerns: [
          CommonConcern(question: 'Should I talk to my newborn even though they don\'t understand?', answer: 'Absolutely yes. Every word you say builds neural connections. Babies who are talked to more have significantly larger vocabularies by age 2.'),
        ],
        parentTips: [
          'Talk to your baby constantly — narrate your day.',
          'Read aloud even to a newborn — the rhythm and tone matter.',
          'Respond to every sound baby makes — it teaches them communication is two-way.',
        ],
      );

    case MilestoneCategory.cognitive:
      return CategoryGuidance(
        category: cat, ageBandIndex: band,
        aboutText: 'Newborns are already learning. They prefer faces over objects, high-contrast patterns, and their mother\'s smell. Every interaction is building the foundation for all future learning.',
        milestones: [
          MilestoneItem(id: 'nb_co_1_$band', title: 'Focuses on faces 20-30cm away', description: 'Can see and focus on faces at close range.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'nb_co_2_$band', title: 'Prefers high-contrast patterns', description: 'Shows more interest in black and white patterns.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'nb_co_3_$band', title: 'Follows moving object briefly', description: 'Tracks a slow-moving object with eyes.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
        ],
        activities: [
          MilestoneActivity(title: 'Face Time', description: 'Hold your face 20-30cm from baby and make slow expressions.', emoji: '😊', steps: ['Get close to baby\'s face.', 'Smile slowly and hold the expression.', 'Stick out your tongue — baby may imitate!']),
          MilestoneActivity(title: 'High-Contrast Cards', description: 'Show black and white patterns to stimulate visual development.', emoji: '🖤', steps: ['Hold a high-contrast card 20-30cm away.', 'Move it slowly side to side.', 'Watch baby\'s eyes track it.']),
        ],
        signsToLookFor: [
          MilestoneSign(title: 'Stares at your face intently', description: 'Shows visual focus is developing.', isPositive: true),
          MilestoneSign(title: 'Eyes track a moving object', description: 'Even briefly — this is great visual development.', isPositive: true),
        ],
        whenToWorry: [
          MilestoneWarning(title: 'Eyes don\'t track at all by 6 weeks', description: 'If baby\'s eyes don\'t follow a moving object by 6 weeks, mention to your doctor.', emoji: '👁️'),
          MilestoneWarning(title: 'Eyes appear crossed or misaligned', description: 'Occasional crossing is normal in newborns, but persistent crossing needs evaluation.', emoji: '⚠️'),
        ],
        commonConcerns: [
          CommonConcern(question: 'My baby stares at the ceiling fan. Is that normal?', answer: 'Yes! Ceiling fans are high-contrast moving objects — exactly what newborn eyes are drawn to. It\'s great visual stimulation.'),
          CommonConcern(question: 'When will my baby recognise me?', answer: 'Babies recognise their mother\'s face within days of birth. By 2-3 months they will smile specifically at familiar faces.'),
        ],
        parentTips: [
          'Your face is the best toy for a newborn.',
          'Vary your facial expressions slowly — baby is studying you.',
          'Black and white books and cards are great for visual stimulation.',
        ],
      );

    case MilestoneCategory.social:
      return CategoryGuidance(
        category: cat, ageBandIndex: band,
        aboutText: 'Social development begins at birth. Your newborn already prefers your face and voice over strangers. Skin-to-skin contact, eye contact, and responsive caregiving are the foundations of secure attachment.',
        milestones: [
          MilestoneItem(id: 'nb_so_1_$band', title: 'Makes eye contact', description: 'Focuses on and holds eye contact with a face.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'nb_so_2_$band', title: 'Calms when picked up', description: 'Settles when held or comforted by caregiver.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'nb_so_3_$band', title: 'Shows first social smile', description: 'Smiles in response to a face or voice (usually by 6-8 weeks).', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
        ],
        activities: [
          MilestoneActivity(title: 'Skin-to-Skin Time', description: 'Hold baby against your bare chest as much as possible.', emoji: '🤱', steps: ['Remove baby\'s clothing except nappy.', 'Hold against your bare chest.', 'Cover with a blanket. Aim for 1+ hour daily.']),
          MilestoneActivity(title: 'Responsive Feeding', description: 'Feed on demand and make eye contact during feeds.', emoji: '💗', steps: ['Watch for hunger cues before crying starts.', 'Make eye contact during feeding.', 'Talk softly to baby while feeding.']),
        ],
        signsToLookFor: [
          MilestoneSign(title: 'Prefers your face over strangers', description: 'Shows early social bonding.', isPositive: true),
          MilestoneSign(title: 'Calms to your voice or touch', description: 'Secure attachment forming.', isPositive: true),
        ],
        whenToWorry: [
          MilestoneWarning(title: 'No eye contact by 6-8 weeks', description: 'If baby consistently avoids eye contact, mention to your doctor.', emoji: '👁️'),
          MilestoneWarning(title: 'Cannot be consoled', description: 'If baby is inconsolable for extended periods, rule out medical causes.', emoji: '😢'),
        ],
        commonConcerns: [
          CommonConcern(question: 'Can I spoil a newborn by holding them too much?', answer: 'No. You cannot spoil a newborn. Responding promptly to their needs builds secure attachment, which leads to more independent children later.'),
          CommonConcern(question: 'When will my baby smile at me?', answer: 'The first social smile usually appears between 6-8 weeks. Before that, smiles are reflexive. The first real smile in response to your face is a major milestone!'),
        ],
        parentTips: [
          'You cannot hold a newborn too much.',
          'Respond to cries promptly — it builds trust, not dependency.',
          'Skin-to-skin contact regulates baby\'s temperature, heart rate, and stress hormones.',
        ],
      );

    case MilestoneCategory.feedingSleep:
      return CategoryGuidance(
        category: cat, ageBandIndex: band,
        aboutText: 'Feeding and sleep are the central activities of a newborn\'s life. Newborns feed 8-12 times per day and sleep 16-18 hours. There is no schedule yet — follow baby\'s cues.',
        milestones: [
          MilestoneItem(id: 'nb_fs_1_$band', title: 'Feeds 8-12 times per 24 hours', description: 'Frequent feeding is normal and necessary.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'nb_fs_2_$band', title: 'Shows hunger cues before crying', description: 'Rooting, sucking fists, turning head.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'nb_fs_3_$band', title: 'Has periods of alert wakefulness', description: 'Awake and calm between feeds.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'nb_fs_4_$band', title: 'Regains birth weight by 2 weeks', description: 'Normal weight gain after initial loss.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
        ],
        activities: [
          MilestoneActivity(title: 'Watch for Hunger Cues', description: 'Feed before baby reaches the crying stage.', emoji: '🍼', steps: ['Watch for rooting (turning head, opening mouth).', 'Look for sucking on fists or fingers.', 'Feed when you see these cues — don\'t wait for crying.']),
          MilestoneActivity(title: 'Safe Sleep Setup', description: 'Create a safe sleep environment from day one.', emoji: '😴', steps: ['Always place baby on their back to sleep.', 'Use a firm, flat surface with no loose bedding.', 'Keep room temperature comfortable (16-20°C).']),
        ],
        signsToLookFor: [
          MilestoneSign(title: 'Gaining weight steadily', description: 'After initial loss, baby should gain 150-200g per week.', isPositive: true),
          MilestoneSign(title: '6+ wet nappies per day', description: 'Good indicator of adequate feeding.', isPositive: true),
          MilestoneSign(title: 'Feeding less than 8 times in 24 hours', description: 'May indicate feeding difficulties.', isPositive: false),
        ],
        whenToWorry: [
          MilestoneWarning(title: 'Not regaining birth weight by 2 weeks', description: 'Consult your midwife or paediatrician about feeding support.', emoji: '⚖️'),
          MilestoneWarning(title: 'Fewer than 6 wet nappies per day after day 5', description: 'May indicate dehydration or feeding issues.', emoji: '💧'),
          MilestoneWarning(title: 'Jaundice worsening after day 5', description: 'Seek medical attention promptly.', emoji: '🟡'),
        ],
        commonConcerns: [
          CommonConcern(question: 'How do I know if my baby is getting enough milk?', answer: 'Count wet nappies (6+ per day after day 5), watch for steady weight gain, and look for a satisfied, calm baby after feeds. If unsure, see a lactation consultant.'),
          CommonConcern(question: 'My baby only sleeps when held. Is that okay?', answer: 'Very normal in the newborn period. Gradually introduce putting baby down drowsy but awake after 6-8 weeks. For now, do what works.'),
          CommonConcern(question: 'When will my baby sleep longer stretches?', answer: 'Most babies start sleeping 4-5 hour stretches around 6-8 weeks, and longer stretches around 3-4 months. Every baby is different.'),
        ],
        parentTips: [
          'Feed on demand — there is no schedule in the newborn period.',
          'Always place baby on their back to sleep — every time.',
          'Cluster feeding in the evenings is normal and temporary.',
          'Sleep when baby sleeps — your rest matters too.',
        ],
      );
  }
}

// ── 2-4 Months ────────────────────────────────────────────────────────────────

CategoryGuidance _twoToFourMonthsGuidance(int band, MilestoneCategory cat) {
  final label = ageBands[band].label;
  switch (cat) {
    case MilestoneCategory.grossMotor:
      return CategoryGuidance(
        category: cat, ageBandIndex: band,
        aboutText: 'Your baby is gaining head control and beginning to push up during tummy time. They are becoming more aware of their body and starting to discover their hands.',
        milestones: [
          MilestoneItem(id: 'tm_gm_1_$band', title: 'Holds head steady when held upright', description: 'Head no longer wobbles when held sitting.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'tm_gm_2_$band', title: 'Pushes up on forearms during tummy time', description: 'Lifts chest off the floor using forearms.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'tm_gm_3_$band', title: 'Kicks legs vigorously', description: 'Strong, active leg movements when on back.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'tm_gm_4_$band', title: 'Rolls from tummy to back', description: 'May begin rolling over (usually by 4 months).', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
        ],
        activities: [
          MilestoneActivity(title: 'Supported Sitting', description: 'Hold baby in a sitting position to strengthen core.', emoji: '🧸', steps: ['Sit baby on your lap facing outward.', 'Support their trunk lightly.', 'Let them practice balancing for 1-2 minutes.']),
          MilestoneActivity(title: 'Tummy Time with Toy', description: 'Place a bright toy in front to motivate pushing up.', emoji: '🌟', steps: ['Place baby on tummy.', 'Put a toy just out of reach.', 'Encourage them to push up and look at it.']),
        ],
        signsToLookFor: [
          MilestoneSign(title: 'Head control improving week by week', description: 'Steady progress is the goal.', isPositive: true),
          MilestoneSign(title: 'Pushes up during tummy time', description: 'Building the strength for rolling and sitting.', isPositive: true),
        ],
        whenToWorry: [
          MilestoneWarning(title: 'No head control by 4 months', description: 'Head still very floppy at 4 months needs evaluation.', emoji: '⚠️'),
          MilestoneWarning(title: 'Not tolerating tummy time at all', description: 'Some resistance is normal, but complete intolerance may need assessment.', emoji: '📋'),
        ],
        commonConcerns: [
          CommonConcern(question: 'My baby rolled over once but hasn\'t done it again. Should I worry?', answer: 'No. Early rolling is often accidental. Consistent rolling usually develops between 4-6 months. Keep doing tummy time to build the strength.'),
        ],
        parentTips: [
          'Increase tummy time to 20-30 minutes spread through the day.',
          'Hold baby upright against your chest to strengthen neck muscles.',
          'Baby gyms with hanging toys encourage reaching and kicking.',
        ],
      );

    case MilestoneCategory.fineMotor:
      return CategoryGuidance(
        category: cat, ageBandIndex: band,
        aboutText: 'Baby is discovering their hands. They will stare at them, bring them to their mouth, and begin to bat at objects. The grasp reflex is fading and intentional reaching is beginning.',
        milestones: [
          MilestoneItem(id: 'tm_fm_1_$band', title: 'Stares at own hands', description: 'Fascinated by their own hands.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'tm_fm_2_$band', title: 'Bats at hanging objects', description: 'Swipes at toys on a baby gym.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'tm_fm_3_$band', title: 'Brings hands together at midline', description: 'Clasps hands together in front of body.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'tm_fm_4_$band', title: 'Grasps a rattle when placed in hand', description: 'Holds a rattle briefly.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
        ],
        activities: [
          MilestoneActivity(title: 'Baby Gym Play', description: 'Place baby under a baby gym with hanging toys.', emoji: '🎯', steps: ['Lay baby under the gym.', 'Position toys within batting range.', 'Encourage reaching by moving toys closer.']),
          MilestoneActivity(title: 'Rattle Exploration', description: 'Place a rattle in baby\'s hand and let them explore.', emoji: '🪀', steps: ['Place a light rattle in baby\'s palm.', 'Let them grip and shake it.', 'React with excitement to encourage more.']),
        ],
        signsToLookFor: [
          MilestoneSign(title: 'Hands open more often', description: 'Grasp reflex fading — intentional movement beginning.', isPositive: true),
          MilestoneSign(title: 'Reaches toward objects', description: 'Even unsuccessful reaching shows intent.', isPositive: true),
        ],
        whenToWorry: [
          MilestoneWarning(title: 'Hands still always fisted at 3 months', description: 'Persistent fisting after 3 months may need evaluation.', emoji: '✋'),
        ],
        commonConcerns: [
          CommonConcern(question: 'My baby keeps sucking their fists. Is that hunger?', answer: 'Not always. Hand-sucking is also self-soothing and exploration. Watch for other hunger cues (rooting, fussiness) to distinguish.'),
        ],
        parentTips: [
          'Dangle colourful toys just within reach to encourage grasping.',
          'Let baby feel different textures — soft, smooth, bumpy.',
          'Avoid mittens so baby can explore with their hands.',
        ],
      );

    case MilestoneCategory.language:
      return CategoryGuidance(
        category: cat, ageBandIndex: band,
        aboutText: 'This is the age of cooing and social smiling. Your baby is discovering their voice and learning that sounds get responses. Talk back to every sound they make — you\'re having their first conversations.',
        milestones: [
          MilestoneItem(id: 'tm_la_1_$band', title: 'Coos and makes vowel sounds', description: 'Produces "ooh", "aah" sounds.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'tm_la_2_$band', title: 'Laughs out loud', description: 'First real laughs, usually by 4 months.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'tm_la_3_$band', title: 'Turns toward sounds', description: 'Looks toward the source of a sound.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'tm_la_4_$band', title: 'Vocalises to get attention', description: 'Makes sounds to attract caregiver\'s attention.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
        ],
        activities: [
          MilestoneActivity(title: 'Coo Conversations', description: 'Respond to every coo with a coo back.', emoji: '💬', steps: ['When baby coos, coo back.', 'Pause and wait for their response.', 'Take turns — this is their first conversation!']),
          MilestoneActivity(title: 'Singing Games', description: 'Sing simple songs with actions.', emoji: '🎵', steps: ['Sing "Twinkle Twinkle" or "Wheels on the Bus".', 'Use exaggerated facial expressions.', 'Pause at familiar points and let baby "fill in".']),
        ],
        signsToLookFor: [
          MilestoneSign(title: 'Different sounds for different moods', description: 'Happy coos vs fussy sounds — communication is developing.', isPositive: true),
          MilestoneSign(title: 'Responds to your voice with sounds', description: 'Turn-taking in "conversation" is a great sign.', isPositive: true),
        ],
        whenToWorry: [
          MilestoneWarning(title: 'No cooing by 3 months', description: 'If baby makes no vowel sounds by 3 months, mention to your doctor.', emoji: '💬'),
          MilestoneWarning(title: 'No response to sounds', description: 'May indicate hearing issues — request a hearing test.', emoji: '👂'),
        ],
        commonConcerns: [
          CommonConcern(question: 'When will my baby say their first word?', answer: 'First words usually appear between 10-14 months. Right now, cooing and babbling are building the foundation. The more you talk to baby, the earlier words tend to come.'),
        ],
        parentTips: [
          'Coo back at your baby — it encourages more vocalisation.',
          'Read books aloud every day — even board books with one word per page.',
          'Narrate your day: "Now we\'re going to the kitchen to make lunch."',
        ],
      );

    case MilestoneCategory.cognitive:
      return CategoryGuidance(
        category: cat, ageBandIndex: band,
        aboutText: 'Your baby is becoming more alert and curious. They are beginning to anticipate events, recognise familiar faces, and show preferences. Every new experience is building their understanding of the world.',
        milestones: [
          MilestoneItem(id: 'tm_co_1_$band', title: 'Recognises familiar faces', description: 'Shows excitement when seeing known caregivers.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'tm_co_2_$band', title: 'Anticipates feeding', description: 'Shows excitement when feeding is about to happen.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'tm_co_3_$band', title: 'Tracks moving objects smoothly', description: 'Eyes follow a moving toy in a full arc.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'tm_co_4_$band', title: 'Shows interest in surroundings', description: 'Looks around and explores the environment visually.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
        ],
        activities: [
          MilestoneActivity(title: 'Mirror Play', description: 'Show baby their reflection in a baby-safe mirror.', emoji: '🪞', steps: ['Hold baby in front of a mirror.', 'Point to their reflection: "That\'s you!"', 'Make faces together in the mirror.']),
          MilestoneActivity(title: 'Cause and Effect Toys', description: 'Introduce toys that respond to baby\'s actions.', emoji: '🎯', steps: ['Give baby a toy that makes sound when shaken.', 'React with excitement when they make it work.', 'Repeat to reinforce the cause-effect connection.']),
        ],
        signsToLookFor: [
          MilestoneSign(title: 'Smiles specifically at familiar faces', description: 'Shows recognition and social cognition.', isPositive: true),
          MilestoneSign(title: 'Looks toward sound sources', description: 'Connecting sound with location — great cognitive development.', isPositive: true),
        ],
        whenToWorry: [
          MilestoneWarning(title: 'No social smile by 3 months', description: 'If baby doesn\'t smile in response to faces by 3 months, consult your doctor.', emoji: '😊'),
        ],
        commonConcerns: [
          CommonConcern(question: 'How much screen time is okay for a 2-3 month old?', answer: 'None recommended. Screens don\'t provide the interaction babies need. Human faces, voices, and real objects are far more stimulating for brain development at this age.'),
        ],
        parentTips: [
          'Your face is still the best toy.',
          'Change baby\'s environment — different rooms, outdoors, different positions.',
          'Respond consistently to baby\'s cues — predictability builds cognitive security.',
        ],
      );

    case MilestoneCategory.social:
      return CategoryGuidance(
        category: cat, ageBandIndex: band,
        aboutText: 'The social smile has arrived! Your baby is now smiling in response to your face, laughing, and showing clear preferences for familiar people. This is the beginning of their social personality.',
        milestones: [
          MilestoneItem(id: 'tm_so_1_$band', title: 'Social smile', description: 'Smiles in response to a face or voice.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'tm_so_2_$band', title: 'Enjoys social play', description: 'Smiles and engages during interactive games.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'tm_so_3_$band', title: 'Shows displeasure clearly', description: 'Cries or fusses to express discomfort or boredom.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'tm_so_4_$band', title: 'Calms with familiar caregiver', description: 'Settles more easily with known people.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
        ],
        activities: [
          MilestoneActivity(title: 'Peek-a-Boo', description: 'Simple peek-a-boo games build social anticipation.', emoji: '👀', steps: ['Cover your face with your hands.', 'Say "Where\'s Mummy/Daddy?"', 'Reveal your face with a big smile: "Peek-a-boo!"']),
          MilestoneActivity(title: 'Tickle Games', description: 'Gentle tickling encourages laughter and social engagement.', emoji: '😄', steps: ['Gently tickle baby\'s tummy or feet.', 'React to their laughter with your own.', 'Pause and let them anticipate the next tickle.']),
        ],
        signsToLookFor: [
          MilestoneSign(title: 'Smiles at familiar faces', description: 'Selective smiling shows social recognition.', isPositive: true),
          MilestoneSign(title: 'Responds differently to strangers vs family', description: 'Early social awareness developing.', isPositive: true),
        ],
        whenToWorry: [
          MilestoneWarning(title: 'No social smile by 3 months', description: 'Consult your paediatrician if no smiling in response to faces by 3 months.', emoji: '😊'),
          MilestoneWarning(title: 'Doesn\'t make eye contact', description: 'Consistent avoidance of eye contact needs evaluation.', emoji: '👁️'),
        ],
        commonConcerns: [
          CommonConcern(question: 'My baby smiles at everyone. Is that normal?', answer: 'Yes, completely normal at 2-4 months. Stranger anxiety (preferring familiar people) usually develops around 6-9 months.'),
        ],
        parentTips: [
          'Smile and talk to your baby constantly — they are learning from you.',
          'Play peek-a-boo and tickle games every day.',
          'Introduce baby to other friendly faces — grandparents, friends.',
        ],
      );

    case MilestoneCategory.feedingSleep:
      return CategoryGuidance(
        category: cat, ageBandIndex: band,
        aboutText: 'Feeding is becoming more efficient and sleep is beginning to consolidate. Many babies start sleeping longer stretches at night around 6-8 weeks. A loose routine may begin to emerge.',
        milestones: [
          MilestoneItem(id: 'tm_fs_1_$band', title: 'Feeds more efficiently', description: 'Feeds take less time as baby gets stronger.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'tm_fs_2_$band', title: 'Longer sleep stretches at night', description: 'May sleep 4-5 hours at a stretch.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'tm_fs_3_$band', title: 'More awake time during the day', description: 'Alert periods are longer and more predictable.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'tm_fs_4_$band', title: 'Shows tired cues', description: 'Yawning, eye rubbing, looking away when tired.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
        ],
        activities: [
          MilestoneActivity(title: 'Bedtime Routine', description: 'Start a simple, consistent bedtime routine.', emoji: '😴', steps: ['Bath, feed, song, sleep — in the same order each night.', 'Keep the routine to 20-30 minutes.', 'Consistency is more important than timing at this age.']),
          MilestoneActivity(title: 'Drowsy But Awake', description: 'Practice putting baby down drowsy but not fully asleep.', emoji: '🌙', steps: ['Watch for tired cues (yawning, eye rubbing).', 'Put baby down when drowsy but still awake.', 'This teaches self-settling over time.']),
        ],
        signsToLookFor: [
          MilestoneSign(title: 'Sleeping one longer stretch at night', description: 'Even 4-5 hours is great progress.', isPositive: true),
          MilestoneSign(title: 'Predictable feeding pattern emerging', description: 'Feeds becoming more spaced and regular.', isPositive: true),
        ],
        whenToWorry: [
          MilestoneWarning(title: 'Still feeding every 1-2 hours at 3 months', description: 'May indicate feeding issues or low supply — consult a lactation consultant.', emoji: '🍼'),
          MilestoneWarning(title: 'Excessive spitting up with poor weight gain', description: 'Could indicate reflux — discuss with your doctor.', emoji: '⚠️'),
        ],
        commonConcerns: [
          CommonConcern(question: 'When will my baby sleep through the night?', answer: 'Most babies don\'t consistently sleep through until 4-6 months or later. "Sleeping through" is defined as 5-6 hours, not 12. Every baby is different.'),
          CommonConcern(question: 'Should I start a schedule?', answer: 'A loose routine (not a strict schedule) can help at this age. Follow baby\'s cues but try to keep the order of activities consistent: feed, play, sleep.'),
        ],
        parentTips: [
          'Start a simple bedtime routine now — it pays off later.',
          'Watch for tired cues and put baby down before overtired.',
          'The "eat-play-sleep" cycle helps distinguish day from night.',
        ],
      );
  }
}

// ── 4-6 Months ────────────────────────────────────────────────────────────────

CategoryGuidance _fourToSixMonthsGuidance(int band, MilestoneCategory cat) {
  final label = ageBands[band].label;
  switch (cat) {
    case MilestoneCategory.grossMotor:
      return CategoryGuidance(
        category: cat, ageBandIndex: band,
        aboutText: 'Your baby is rolling, reaching, and beginning to sit with support. They are building the core strength that will lead to sitting independently and eventually crawling.',
        milestones: [
          MilestoneItem(id: 'fm_gm_1_$band', title: 'Rolls from tummy to back', description: 'Rolls over from front to back.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'fm_gm_2_$band', title: 'Rolls from back to tummy', description: 'Rolls over from back to front.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'fm_gm_3_$band', title: 'Sits with support', description: 'Sits steadily when supported.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'fm_gm_4_$band', title: 'Bears weight on legs when held standing', description: 'Pushes down with legs when held upright.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'fm_gm_5_$band', title: 'Pushes up on straight arms during tummy time', description: 'Lifts chest fully off the floor.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
        ],
        activities: [
          MilestoneActivity(title: 'Rolling Practice', description: 'Use a toy to encourage rolling in both directions.', emoji: '🪀', steps: ['Place baby on their back.', 'Hold a toy to one side.', 'Encourage them to roll toward it.']),
          MilestoneActivity(title: 'Supported Sitting', description: 'Practice sitting with minimal support.', emoji: '🧸', steps: ['Sit baby between your legs.', 'Gradually reduce support.', 'Use a Boppy pillow for independent practice.']),
        ],
        signsToLookFor: [
          MilestoneSign(title: 'Rolling in both directions', description: 'Rolling both ways shows good bilateral development.', isPositive: true),
          MilestoneSign(title: 'Strong push-up during tummy time', description: 'Building the strength for crawling.', isPositive: true),
        ],
        whenToWorry: [
          MilestoneWarning(title: 'Not rolling by 6 months', description: 'If baby isn\'t rolling in either direction by 6 months, consult your doctor.', emoji: '⚠️'),
          MilestoneWarning(title: 'Very stiff or very floppy muscle tone', description: 'Either extreme may need physiotherapy assessment.', emoji: '📋'),
        ],
        commonConcerns: [
          CommonConcern(question: 'My baby rolled off the bed. What should I do?', answer: 'Check for signs of injury (unusual crying, not moving a limb, vomiting). If concerned, seek medical attention. Going forward, never leave baby unattended on elevated surfaces.'),
        ],
        parentTips: [
          'Give baby lots of floor time — it\'s the gym for their development.',
          'Tummy time is still important even when baby can roll.',
          'Baby-proof your floor — rolling babies move faster than you expect.',
        ],
      );

    case MilestoneCategory.fineMotor:
      return CategoryGuidance(
        category: cat, ageBandIndex: band,
        aboutText: 'Baby is now reaching intentionally and grasping objects with both hands. They are exploring everything with their mouth — this is normal and important for sensory development.',
        milestones: [
          MilestoneItem(id: 'fm_fm_1_$band', title: 'Reaches for and grasps objects', description: 'Intentionally reaches toward and grabs toys.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'fm_fm_2_$band', title: 'Transfers objects hand to hand', description: 'Passes a toy from one hand to the other.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'fm_fm_3_$band', title: 'Brings objects to mouth', description: 'Moves held objects toward mouth to explore.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'fm_fm_4_$band', title: 'Rakes objects toward self', description: 'Uses whole hand to rake objects closer.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
        ],
        activities: [
          MilestoneActivity(title: 'Texture Exploration', description: 'Offer objects with different textures to explore.', emoji: '🎨', steps: ['Offer a soft toy, a smooth block, a crinkle toy.', 'Let baby feel and mouth each one.', 'Name the textures: "soft", "smooth", "crinkly".']),
          MilestoneActivity(title: 'Two-Handed Play', description: 'Encourage using both hands together.', emoji: '🤝', steps: ['Give baby a toy that requires two hands.', 'Demonstrate holding with both hands.', 'Clap baby\'s hands together gently.']),
        ],
        signsToLookFor: [
          MilestoneSign(title: 'Reaches with both arms', description: 'Bilateral reaching shows good coordination.', isPositive: true),
          MilestoneSign(title: 'Mouths everything', description: 'Normal and important for sensory development.', isPositive: true),
        ],
        whenToWorry: [
          MilestoneWarning(title: 'Not reaching for objects by 5 months', description: 'If baby shows no interest in reaching for toys, mention to your doctor.', emoji: '✋'),
          MilestoneWarning(title: 'Only uses one hand', description: 'Strong hand preference before 12 months may need evaluation.', emoji: '⚠️'),
        ],
        commonConcerns: [
          CommonConcern(question: 'My baby puts everything in their mouth. Is that safe?', answer: 'Mouthing is normal and important for sensory development. Ensure all objects are larger than a toilet roll tube (choking hazard check) and clean. Avoid small parts.'),
        ],
        parentTips: [
          'Offer a variety of safe objects to explore.',
          'Let baby feel different textures — it builds sensory pathways.',
          'Ensure all toys are clean and large enough to be safe.',
        ],
      );

    case MilestoneCategory.language:
      return CategoryGuidance(
        category: cat, ageBandIndex: band,
        aboutText: 'Babbling is beginning! Your baby is experimenting with consonant sounds and discovering the joy of making noise. They are also becoming better at understanding your tone and expressions.',
        milestones: [
          MilestoneItem(id: 'fm_la_1_$band', title: 'Babbles with consonants', description: 'Makes "ba", "da", "ga" sounds.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'fm_la_2_$band', title: 'Laughs and squeals', description: 'Produces laughter and high-pitched squeals.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'fm_la_3_$band', title: 'Responds to own name', description: 'Turns or reacts when their name is called.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'fm_la_4_$band', title: 'Varies volume and pitch', description: 'Makes loud and soft sounds, high and low.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
        ],
        activities: [
          MilestoneActivity(title: 'Name Game', description: 'Call baby\'s name from different positions.', emoji: '📣', steps: ['Call baby\'s name from in front.', 'Then from the side.', 'Celebrate when they turn toward you.']),
          MilestoneActivity(title: 'Sound Imitation', description: 'Copy baby\'s sounds back to them.', emoji: '🎵', steps: ['When baby makes a sound, copy it exactly.', 'Pause and wait for their response.', 'Add a new sound and see if they copy you.']),
        ],
        signsToLookFor: [
          MilestoneSign(title: 'Babbling with consonants', description: 'Consonant babbling is a key language milestone.', isPositive: true),
          MilestoneSign(title: 'Responds to name', description: 'Shows auditory processing and social awareness.', isPositive: true),
        ],
        whenToWorry: [
          MilestoneWarning(title: 'No babbling by 6 months', description: 'If baby makes no consonant sounds by 6 months, consult your doctor.', emoji: '💬'),
          MilestoneWarning(title: 'Doesn\'t respond to name by 6 months', description: 'May indicate hearing or developmental concerns.', emoji: '👂'),
        ],
        commonConcerns: [
          CommonConcern(question: 'My baby babbles a lot but I can\'t understand any of it. Is that normal?', answer: 'Completely normal. Babbling is practice — baby is learning to control their mouth and voice. Real words come later, usually around 10-14 months.'),
        ],
        parentTips: [
          'Use baby\'s name often during daily routines.',
          'Respond to every babble — it teaches communication is two-way.',
          'Read books with simple, repetitive text.',
        ],
      );

    case MilestoneCategory.cognitive:
      return CategoryGuidance(
        category: cat, ageBandIndex: band,
        aboutText: 'Your baby is beginning to understand cause and effect, and is showing curiosity about how things work. They are also developing object permanence — understanding that things exist even when out of sight.',
        milestones: [
          MilestoneItem(id: 'fm_co_1_$band', title: 'Explores objects with hands and mouth', description: 'Examines toys by touching and mouthing.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'fm_co_2_$band', title: 'Understands cause and effect', description: 'Repeats actions that produce interesting results.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'fm_co_3_$band', title: 'Looks for dropped objects', description: 'Looks down when an object is dropped.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'fm_co_4_$band', title: 'Shows curiosity about new objects', description: 'Examines new toys with interest.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
        ],
        activities: [
          MilestoneActivity(title: 'Drop and Find', description: 'Drop objects and watch baby look for them.', emoji: '🎯', steps: ['Hold a toy in front of baby.', 'Drop it slowly while baby watches.', 'Ask "Where did it go?" and help them find it.']),
          MilestoneActivity(title: 'Cause and Effect Toys', description: 'Toys that respond to baby\'s actions.', emoji: '🔔', steps: ['Give baby a toy that makes sound when shaken.', 'React with excitement when they make it work.', 'Repeat to reinforce the connection.']),
        ],
        signsToLookFor: [
          MilestoneSign(title: 'Repeats actions that get a reaction', description: 'Understanding cause and effect — a key cognitive milestone.', isPositive: true),
          MilestoneSign(title: 'Looks for dropped objects', description: 'Early object permanence developing.', isPositive: true),
        ],
        whenToWorry: [
          MilestoneWarning(title: 'No interest in toys or objects by 5 months', description: 'If baby shows no curiosity about objects, mention to your doctor.', emoji: '🧸'),
        ],
        commonConcerns: [
          CommonConcern(question: 'How do I know if my baby is smart?', answer: 'All babies develop at their own pace. Curiosity, engagement, and responsiveness are better indicators than hitting milestones early. Focus on interaction, not comparison.'),
        ],
        parentTips: [
          'Give toys that make sounds when pressed or shaken.',
          'Play "drop and find" games to build object permanence.',
          'Rotate toys to keep things interesting.',
        ],
      );

    case MilestoneCategory.social:
      return CategoryGuidance(
        category: cat, ageBandIndex: band,
        aboutText: 'Your baby is becoming more social and interactive. They are beginning to show preferences, express emotions more clearly, and engage in longer social exchanges.',
        milestones: [
          MilestoneItem(id: 'fm_so_1_$band', title: 'Recognises familiar faces', description: 'Shows excitement when seeing known caregivers.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'fm_so_2_$band', title: 'Enjoys social play', description: 'Smiles and engages during interactive games.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'fm_so_3_$band', title: 'Shows displeasure clearly', description: 'Cries or fusses to express discomfort or boredom.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'fm_so_4_$band', title: 'Mirrors facial expressions', description: 'Copies your expressions — smiling, frowning.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
        ],
        activities: [
          MilestoneActivity(title: 'Expression Mirroring', description: 'Make exaggerated expressions and watch baby copy.', emoji: '😊', steps: ['Make a big smile.', 'Stick out your tongue.', 'Open your mouth wide. Watch baby copy!']),
          MilestoneActivity(title: 'Social Games', description: 'Play simple interactive games.', emoji: '🎮', steps: ['Play "This Little Piggy" with baby\'s toes.', 'Play "Round and Round the Garden".', 'Repeat the same games — familiarity brings joy.']),
        ],
        signsToLookFor: [
          MilestoneSign(title: 'Smiles at familiar faces', description: 'Selective smiling shows social recognition.', isPositive: true),
          MilestoneSign(title: 'Mirrors your expressions', description: 'Social mirroring is a key developmental sign.', isPositive: true),
        ],
        whenToWorry: [
          MilestoneWarning(title: 'No social smiling by 4 months', description: 'Consult your paediatrician.', emoji: '😊'),
          MilestoneWarning(title: 'Doesn\'t respond to social interaction', description: 'If baby seems uninterested in people, mention to your doctor.', emoji: '👁️'),
        ],
        commonConcerns: [
          CommonConcern(question: 'My baby cries when anyone other than me holds them. Is that normal?', answer: 'Stranger anxiety typically peaks at 6-9 months but can start earlier. It\'s a sign of healthy attachment. Gradually introduce other caregivers while you\'re present.'),
        ],
        parentTips: [
          'Play face-to-face games every day.',
          'Introduce baby to other friendly faces regularly.',
          'Respond to baby\'s emotional cues — it builds emotional intelligence.',
        ],
      );

    case MilestoneCategory.feedingSleep:
      return CategoryGuidance(
        category: cat, ageBandIndex: band,
        aboutText: 'Many babies are ready to start solid foods around 6 months. Sleep is consolidating for most babies, with longer night stretches. A consistent routine is becoming more important.',
        milestones: [
          MilestoneItem(id: 'fm_fs_1_$band', title: 'Shows interest in food', description: 'Watches others eat, reaches for food.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'fm_fs_2_$band', title: 'Sits with support for feeding', description: 'Can sit supported in a high chair.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'fm_fs_3_$band', title: 'Sleeps 2-3 naps per day', description: 'Predictable nap pattern emerging.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'fm_fs_4_$band', title: 'Longer night sleep stretches', description: 'May sleep 6-8 hours at a stretch.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
        ],
        activities: [
          MilestoneActivity(title: 'Solid Food Introduction', description: 'Start with single-ingredient purees around 6 months.', emoji: '🥕', steps: ['Start with iron-rich foods: pureed meat, lentils, fortified cereal.', 'Offer 1-2 teaspoons once a day.', 'Wait 3-5 days before introducing a new food.']),
          MilestoneActivity(title: 'Sleep Routine Consistency', description: 'Keep bedtime routine consistent every night.', emoji: '🌙', steps: ['Same time, same order every night.', 'Bath, feed, book, song, sleep.', 'Aim for bedtime between 6:30-8pm.']),
        ],
        signsToLookFor: [
          MilestoneSign(title: 'Can sit with support', description: 'Needed before starting solids.', isPositive: true),
          MilestoneSign(title: 'Shows interest in food', description: 'Key readiness sign for starting solids.', isPositive: true),
          MilestoneSign(title: 'Tongue thrust reflex fading', description: 'Stops pushing food out with tongue.', isPositive: true),
        ],
        whenToWorry: [
          MilestoneWarning(title: 'No interest in food at 6 months', description: 'If baby shows no interest in food by 6 months, discuss with your doctor.', emoji: '🍽️'),
          MilestoneWarning(title: 'Gagging excessively on purees', description: 'Some gagging is normal, but excessive gagging may need assessment.', emoji: '⚠️'),
        ],
        commonConcerns: [
          CommonConcern(question: 'When should I start solid foods?', answer: 'Around 6 months, when baby can sit with support, shows interest in food, and the tongue thrust reflex has faded. Not before 4 months. Breast milk or formula remains the main nutrition until 12 months.'),
          CommonConcern(question: 'Should I do purees or baby-led weaning?', answer: 'Both are valid approaches. Purees are traditional and easy to control. Baby-led weaning (soft finger foods) promotes self-feeding skills. Many families do a combination.'),
        ],
        parentTips: [
          'Start solids around 6 months — not before 4 months.',
          'Iron-rich foods are the priority at first.',
          'Breast milk or formula is still the main nutrition until 12 months.',
          'Offer water in a cup with meals from 6 months.',
        ],
      );
  }
}

// ── 6-9 Months ────────────────────────────────────────────────────────────────

CategoryGuidance _sixToNineMonthsGuidance(int band, MilestoneCategory cat) {
  final label = ageBands[band].label;
  switch (cat) {
    case MilestoneCategory.grossMotor:
      return CategoryGuidance(
        category: cat, ageBandIndex: band,
        aboutText: 'Your baby is sitting independently, beginning to crawl, and pulling up to stand. This is a period of rapid physical development — give them as much floor time as possible.',
        milestones: [
          MilestoneItem(id: 'sn_gm_1', title: 'Sits without support', description: 'Sits steadily without using hands for support.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'sn_gm_2', title: 'Rolls over in both directions', description: 'Rolls from tummy to back and back to tummy.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'sn_gm_3', title: 'Crawls on hands and knees', description: 'Moves forward or backward on all fours.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'sn_gm_4', title: 'Pulls up to stand', description: 'Uses furniture to pull to standing.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'sn_gm_5', title: 'Stands holding on', description: 'Stands while holding onto furniture.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
        ],
        activities: [
          MilestoneActivity(title: 'Toy Chase', description: 'Place a toy just out of reach to motivate crawling.', emoji: '🎯', steps: ['Place a favourite toy just ahead.', 'Encourage baby to move toward it.', 'Celebrate when they reach it!']),
          MilestoneActivity(title: 'Pull-Up Practice', description: 'Encourage pulling up using furniture.', emoji: '🛋️', steps: ['Place baby next to a sturdy sofa.', 'Put a toy on the sofa seat.', 'Encourage them to pull up to reach it.']),
        ],
        signsToLookFor: [
          MilestoneSign(title: 'Sitting independently', description: 'Hands-free sitting shows good core strength.', isPositive: true),
          MilestoneSign(title: 'Moving toward objects', description: 'Any form of locomotion — rolling, commando crawling, crawling.', isPositive: true),
        ],
        whenToWorry: [
          MilestoneWarning(title: 'Not sitting independently by 9 months', description: 'Consult your doctor if baby can\'t sit without support by 9 months.', emoji: '⚠️'),
          MilestoneWarning(title: 'Not moving toward objects by 9 months', description: 'Any form of locomotion should be present by 9 months.', emoji: '📋'),
        ],
        commonConcerns: [
          CommonConcern(question: 'My baby skipped crawling and went straight to walking. Is that okay?', answer: 'Yes. Some babies skip crawling entirely. While crawling has developmental benefits, it\'s not a required milestone. Walking without crawling is normal.'),
          CommonConcern(question: 'Should I use a baby walker?', answer: 'Baby walkers are not recommended. They can delay walking, cause accidents, and don\'t provide the developmental benefits of floor play. Use a push toy instead.'),
        ],
        parentTips: [
          'Baby-proof your home now — crawling babies are fast!',
          'Give lots of floor time — it\'s the best gym.',
          'Avoid baby walkers — they delay development.',
        ],
      );

    case MilestoneCategory.fineMotor:
      return CategoryGuidance(
        category: cat, ageBandIndex: band,
        aboutText: 'The pincer grasp is developing — baby is beginning to pick up small objects with thumb and forefinger. They are also learning to bang, shake, and drop objects intentionally.',
        milestones: [
          MilestoneItem(id: 'sn_fm_1', title: 'Transfers objects hand to hand', description: 'Passes a toy from one hand to the other.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'sn_fm_2', title: 'Bangs objects together', description: 'Deliberately bangs two objects together.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'sn_fm_3', title: 'Pincer grasp developing', description: 'Picks up small objects with thumb and forefinger.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'sn_fm_4', title: 'Points with index finger', description: 'Uses index finger to point at objects.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
        ],
        activities: [
          MilestoneActivity(title: 'Pincer Practice', description: 'Offer small safe foods to practice the pincer grasp.', emoji: '🫐', steps: ['Place soft puffs or small pieces of banana on the tray.', 'Let baby try to pick them up.', 'Celebrate every attempt!']),
          MilestoneActivity(title: 'Container Play', description: 'Put objects in and take them out of a container.', emoji: '🪣', steps: ['Give baby a cup and some large blocks.', 'Demonstrate putting a block in.', 'Let baby try — in and out is great fine motor practice.']),
        ],
        signsToLookFor: [
          MilestoneSign(title: 'Pincer grasp emerging', description: 'Using thumb and forefinger to pick up small objects.', isPositive: true),
          MilestoneSign(title: 'Pointing with index finger', description: 'Pointing is a key communication and cognitive milestone.', isPositive: true),
        ],
        whenToWorry: [
          MilestoneWarning(title: 'No pincer grasp by 12 months', description: 'If baby is still using whole-hand grasp only by 12 months, mention to your doctor.', emoji: '✋'),
        ],
        commonConcerns: [
          CommonConcern(question: 'My baby drops everything on purpose. Is that normal?', answer: 'Yes! Dropping is intentional and a sign of developing cause-and-effect understanding. It\'s also great fine motor practice. It\'s annoying but developmentally appropriate!'),
        ],
        parentTips: [
          'Offer soft puffs or small safe foods to practice pincer grasp.',
          'Give baby a cup and blocks to practice in-and-out.',
          'Point at things and name them — baby will start pointing too.',
        ],
      );

    case MilestoneCategory.language:
      return CategoryGuidance(
        category: cat, ageBandIndex: band,
        aboutText: 'Babbling is becoming more complex and speech-like. Baby is beginning to understand simple words and may say their first word soon. Pointing is emerging as a key communication tool.',
        milestones: [
          MilestoneItem(id: 'sn_la_1', title: 'Babbles with varied consonants', description: 'Uses "ba", "da", "ma", "ga" in strings.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'sn_la_2', title: 'Responds to name', description: 'Turns when their name is called.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'sn_la_3', title: 'Understands "no"', description: 'Pauses or reacts when told "no".', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'sn_la_4', title: 'Imitates sounds', description: 'Copies sounds and gestures you make.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
        ],
        activities: [
          MilestoneActivity(title: 'Name Everything', description: 'Point to and name objects throughout the day.', emoji: '📚', steps: ['Point to objects: "That\'s a cup."', 'Use simple, clear words.', 'Repeat the same words consistently.']),
          MilestoneActivity(title: 'Wave and Clap', description: 'Teach simple gestures with words.', emoji: '👋', steps: ['Wave and say "bye-bye" every time someone leaves.', 'Clap and say "clap clap" during play.', 'Celebrate when baby imitates.']),
        ],
        signsToLookFor: [
          MilestoneSign(title: 'Babbling sounds like speech', description: 'Varied consonants and intonation patterns.', isPositive: true),
          MilestoneSign(title: 'Responds to name consistently', description: 'Shows auditory processing and social awareness.', isPositive: true),
        ],
        whenToWorry: [
          MilestoneWarning(title: 'No babbling by 9 months', description: 'If baby makes no consonant sounds by 9 months, consult your doctor.', emoji: '💬'),
          MilestoneWarning(title: 'Doesn\'t respond to name by 9 months', description: 'May indicate hearing or developmental concerns.', emoji: '👂'),
        ],
        commonConcerns: [
          CommonConcern(question: 'My baby says "dada" but not "mama". Should I be offended?', answer: 'Not at all! "D" sounds are easier to produce than "M" sounds. "Dada" often comes first regardless of who the primary caregiver is. "Mama" will follow.'),
        ],
        parentTips: [
          'Narrate everything you do throughout the day.',
          'Read books every day — even the same book repeatedly.',
          'Respond to every babble and gesture.',
        ],
      );

    case MilestoneCategory.cognitive:
      return CategoryGuidance(
        category: cat, ageBandIndex: band,
        aboutText: 'Object permanence is developing — baby now understands that things exist even when out of sight. They are also beginning to understand simple cause and effect and showing problem-solving behaviour.',
        milestones: [
          MilestoneItem(id: 'sn_co_1', title: 'Object permanence', description: 'Looks for hidden objects.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'sn_co_2', title: 'Explores objects in different ways', description: 'Shakes, bangs, throws, drops objects.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'sn_co_3', title: 'Imitates actions', description: 'Copies simple actions like clapping.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'sn_co_4', title: 'Understands simple instructions', description: 'Responds to "give me" or "come here".', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
        ],
        activities: [
          MilestoneActivity(title: 'Hide and Seek with Toys', description: 'Hide a toy under a cloth and let baby find it.', emoji: '🔍', steps: ['Show baby a toy.', 'Cover it with a cloth while they watch.', 'Ask "Where did it go?" and let them find it.']),
          MilestoneActivity(title: 'Imitation Games', description: 'Do simple actions and encourage baby to copy.', emoji: '🎭', steps: ['Clap your hands.', 'Wave.', 'Bang on a drum. Wait for baby to copy.']),
        ],
        signsToLookFor: [
          MilestoneSign(title: 'Searches for hidden objects', description: 'Object permanence is a key cognitive milestone.', isPositive: true),
          MilestoneSign(title: 'Imitates actions', description: 'Imitation is how babies learn.', isPositive: true),
        ],
        whenToWorry: [
          MilestoneWarning(title: 'No imitation of actions by 9 months', description: 'If baby doesn\'t copy simple actions, mention to your doctor.', emoji: '🎭'),
        ],
        commonConcerns: [
          CommonConcern(question: 'My baby cries when I leave the room. Is that separation anxiety?', answer: 'Yes, and it\'s a sign of healthy attachment and developing object permanence. They now know you exist when you\'re gone, and they want you back! It typically peaks at 9-18 months.'),
        ],
        parentTips: [
          'Play hide-and-seek with toys to build object permanence.',
          'Give simple one-step instructions and celebrate when baby follows them.',
          'Imitate baby\'s actions — they love it and it teaches turn-taking.',
        ],
      );

    case MilestoneCategory.social:
      return CategoryGuidance(
        category: cat, ageBandIndex: band,
        aboutText: 'Stranger anxiety is peaking and separation anxiety is developing — both signs of healthy attachment. Baby is also becoming more expressive and beginning to show a range of emotions.',
        milestones: [
          MilestoneItem(id: 'sn_so_1', title: 'Shows stranger anxiety', description: 'May cry or cling when unfamiliar people approach.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'sn_so_2', title: 'Plays peek-a-boo', description: 'Enjoys and anticipates peek-a-boo games.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'sn_so_3', title: 'Waves bye-bye', description: 'Waves hand in response to "bye-bye".', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'sn_so_4', title: 'Shows affection to familiar people', description: 'Reaches for, hugs, or cuddles caregivers.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
        ],
        activities: [
          MilestoneActivity(title: 'Peek-a-Boo', description: 'Play peek-a-boo to build social anticipation.', emoji: '👀', steps: ['Cover your face.', 'Say "Where\'s Mummy?"', 'Reveal with "Peek-a-boo!" Repeat!']),
          MilestoneActivity(title: 'Goodbye Ritual', description: 'Create a consistent goodbye routine.', emoji: '👋', steps: ['Wave and say "bye-bye" every time someone leaves.', 'Keep goodbyes brief and cheerful.', 'Always come back — this builds trust.']),
        ],
        signsToLookFor: [
          MilestoneSign(title: 'Stranger anxiety present', description: 'Shows healthy attachment to primary caregivers.', isPositive: true),
          MilestoneSign(title: 'Waves bye-bye', description: 'Social gesture showing communication development.', isPositive: true),
        ],
        whenToWorry: [
          MilestoneWarning(title: 'No stranger anxiety at all', description: 'Complete absence of stranger anxiety may indicate attachment concerns.', emoji: '👥'),
          MilestoneWarning(title: 'Doesn\'t show affection to caregivers', description: 'If baby shows no preference for familiar people, mention to your doctor.', emoji: '💗'),
        ],
        commonConcerns: [
          CommonConcern(question: 'My baby screams when I leave the room. How do I handle separation anxiety?', answer: 'Keep goodbyes brief and cheerful. Always say goodbye — don\'t sneak away. Come back consistently. Practice short separations. It typically improves by 18-24 months.'),
        ],
        parentTips: [
          'Play peek-a-boo daily — it teaches object permanence too.',
          'Keep goodbyes brief and cheerful.',
          'Always come back when you say you will — it builds trust.',
        ],
      );

    case MilestoneCategory.feedingSleep:
      return CategoryGuidance(
        category: cat, ageBandIndex: band,
        aboutText: 'Solid foods are well established and baby is exploring a wider variety of textures and flavours. Sleep may be disrupted by developmental leaps, teething, and separation anxiety.',
        milestones: [
          MilestoneItem(id: 'sn_fs_1', title: 'Eating a variety of pureed foods', description: 'Accepts different flavours and textures.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'sn_fs_2', title: 'Moving toward mashed/lumpy textures', description: 'Progressing from smooth purees.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'sn_fs_3', title: 'Drinking from a cup with help', description: 'Beginning to use a sippy or open cup.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'sn_fs_4', title: 'Sleeping 2 naps per day', description: 'Morning and afternoon nap pattern.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
        ],
        activities: [
          MilestoneActivity(title: 'Texture Progression', description: 'Gradually increase food texture.', emoji: '🥕', steps: ['Start with smooth purees.', 'Progress to mashed with small lumps.', 'Introduce soft finger foods around 7-8 months.']),
          MilestoneActivity(title: 'Cup Introduction', description: 'Introduce a sippy or open cup with water.', emoji: '🥤', steps: ['Offer a small amount of water in a cup at mealtimes.', 'Help baby hold and tip the cup.', 'Expect mess — it\'s part of learning!']),
        ],
        signsToLookFor: [
          MilestoneSign(title: 'Accepting a variety of foods', description: 'Exposure to many flavours now reduces fussiness later.', isPositive: true),
          MilestoneSign(title: 'Self-feeding attempts', description: 'Grabbing the spoon or picking up finger foods.', isPositive: true),
        ],
        whenToWorry: [
          MilestoneWarning(title: 'Refusing all solid foods at 8 months', description: 'If baby consistently refuses all solids, consult your doctor.', emoji: '🍽️'),
          MilestoneWarning(title: 'Choking frequently', description: 'Gagging is normal, choking is not. Ensure foods are appropriate texture.', emoji: '⚠️'),
        ],
        commonConcerns: [
          CommonConcern(question: 'My baby wakes up multiple times at night again. Why?', answer: 'Sleep regressions are common at 6, 8-10, and 12 months. They\'re caused by developmental leaps, teething, and separation anxiety. They are temporary. Maintain your routine.'),
          CommonConcern(question: 'How much solid food should my baby eat?', answer: 'At 6-9 months, solids are complementary to milk. Aim for 2-3 small meals per day. Breast milk or formula is still the main nutrition. Don\'t stress about quantities.'),
        ],
        parentTips: [
          'Offer a variety of flavours — exposure now prevents fussiness later.',
          'Let baby self-feed with finger foods — it\'s messy but important.',
          'Maintain sleep routine during regressions — consistency is key.',
        ],
      );
  }
}

// ── 9-12 Months ───────────────────────────────────────────────────────────────

CategoryGuidance _nineToTwelveMonthsGuidance(int band, MilestoneCategory cat) {
  final label = ageBands[band].label;
  switch (cat) {
    case MilestoneCategory.grossMotor:
      return CategoryGuidance(
        category: cat, ageBandIndex: band,
        aboutText: 'Your baby is cruising along furniture, may be taking first steps, and is becoming increasingly mobile. This is an exciting and exhausting time — baby-proofing is essential.',
        milestones: [
          MilestoneItem(id: 'nm_gm_1', title: 'Cruises along furniture', description: 'Walks sideways holding onto furniture.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'nm_gm_2', title: 'Stands alone briefly', description: 'Stands without support for a few seconds.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'nm_gm_3', title: 'Takes first steps', description: 'May take 1-2 independent steps.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'nm_gm_4', title: 'Stoops and recovers', description: 'Bends down to pick up object and stands back up.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
        ],
        activities: [
          MilestoneActivity(title: 'Furniture Cruising', description: 'Arrange furniture close together to encourage cruising.', emoji: '🛋️', steps: ['Place two pieces of furniture close together.', 'Put a toy at the far end.', 'Encourage baby to cruise along to reach it.']),
          MilestoneActivity(title: 'Push Toy Walking', description: 'Use a push toy to encourage independent steps.', emoji: '🚗', steps: ['Hold a push toy steady while baby grabs it.', 'Let them push it forward.', 'Walk alongside for safety.']),
        ],
        signsToLookFor: [
          MilestoneSign(title: 'Cruising confidently', description: 'Building the balance needed for walking.', isPositive: true),
          MilestoneSign(title: 'Letting go briefly', description: 'Momentary standing without support is great progress.', isPositive: true),
        ],
        whenToWorry: [
          MilestoneWarning(title: 'Not pulling to stand by 12 months', description: 'Consult your doctor if baby isn\'t pulling up by 12 months.', emoji: '⚠️'),
          MilestoneWarning(title: 'Walking on tiptoes consistently', description: 'Occasional tiptoeing is fine; consistent tiptoeing may need evaluation.', emoji: '📋'),
        ],
        commonConcerns: [
          CommonConcern(question: 'When will my baby walk?', answer: 'Most babies take first steps between 9-12 months and walk independently by 15 months. Walking at 18 months is still within normal range. Don\'t rush it.'),
          CommonConcern(question: 'Should I use a baby walker?', answer: 'No. Baby walkers are not recommended by paediatricians. They can delay walking, cause accidents, and don\'t provide developmental benefits. Use a push toy instead.'),
        ],
        parentTips: [
          'Arrange furniture close together to encourage cruising.',
          'Let baby go barefoot indoors — it helps balance and foot development.',
          'Avoid baby walkers — use push toys instead.',
        ],
      );

    case MilestoneCategory.fineMotor:
      return CategoryGuidance(
        category: cat, ageBandIndex: band,
        aboutText: 'The pincer grasp is now well established. Baby is pointing, clapping, and beginning to use tools like spoons. They are also learning to release objects intentionally.',
        milestones: [
          MilestoneItem(id: 'nm_fm_1', title: 'Pincer grasp well established', description: 'Picks up small objects with thumb and forefinger.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'nm_fm_2', title: 'Puts objects into containers', description: 'Drops objects into a cup or box intentionally.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'nm_fm_3', title: 'Claps hands together', description: 'Brings hands together to clap.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'nm_fm_4', title: 'Attempts to use spoon', description: 'Tries to scoop food with a spoon.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
        ],
        activities: [
          MilestoneActivity(title: 'In and Out Play', description: 'Practice putting objects in and taking them out.', emoji: '🪣', steps: ['Give baby a container and some large blocks.', 'Demonstrate putting a block in.', 'Let baby try — celebrate every success.']),
          MilestoneActivity(title: 'Spoon Practice', description: 'Let baby practice with a spoon at mealtimes.', emoji: '🥄', steps: ['Give baby their own spoon at mealtimes.', 'Load it for them initially.', 'Let them try to bring it to their mouth.']),
        ],
        signsToLookFor: [
          MilestoneSign(title: 'Pincer grasp for small objects', description: 'Precise finger control developing well.', isPositive: true),
          MilestoneSign(title: 'Intentional release of objects', description: 'Letting go on purpose is a fine motor milestone.', isPositive: true),
        ],
        whenToWorry: [
          MilestoneWarning(title: 'No pincer grasp by 12 months', description: 'If baby is still using whole-hand grasp only, mention to your doctor.', emoji: '✋'),
        ],
        commonConcerns: [
          CommonConcern(question: 'My baby throws food off the high chair. How do I stop it?', answer: 'Throwing food is developmentally normal at this age — it\'s cause-and-effect learning. Stay calm, say "food stays on the tray", and end the meal if it continues. It will pass.'),
        ],
        parentTips: [
          'Give baby their own spoon at mealtimes — expect mess.',
          'Offer finger foods to practice pincer grasp.',
          'Stack cups and blocks are great fine motor toys.',
        ],
      );

    case MilestoneCategory.language:
      return CategoryGuidance(
        category: cat, ageBandIndex: band,
        aboutText: 'First words are arriving! Baby understands far more than they can say. They are using gestures, pointing, and a few words to communicate. Every word you say is still building their vocabulary.',
        milestones: [
          MilestoneItem(id: 'nm_la_1', title: 'Says 1-3 words with meaning', description: 'Uses "mama", "dada", or another word meaningfully.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'nm_la_2', title: 'Understands simple instructions', description: 'Follows "give me", "come here", "no".', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'nm_la_3', title: 'Uses gestures to communicate', description: 'Points, waves, raises arms to be picked up.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'nm_la_4', title: 'Imitates words', description: 'Tries to copy simple words or sounds.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
        ],
        activities: [
          MilestoneActivity(title: 'Point and Name', description: 'Point at everything and name it.', emoji: '👆', steps: ['Point to objects: "That\'s a dog."', 'Use simple, clear words.', 'Wait for baby to point — respond with the name.']),
          MilestoneActivity(title: 'Simple Instructions', description: 'Give one-step instructions and celebrate compliance.', emoji: '🎯', steps: ['Say "Give me the ball" and hold out your hand.', 'Help baby comply if needed.', 'Celebrate with praise when they do it.']),
        ],
        signsToLookFor: [
          MilestoneSign(title: 'Using words with meaning', description: 'Even one consistent word is a major milestone.', isPositive: true),
          MilestoneSign(title: 'Pointing to communicate', description: 'Pointing is a key pre-language communication skill.', isPositive: true),
        ],
        whenToWorry: [
          MilestoneWarning(title: 'No words by 12 months', description: 'If baby has no words by 12 months, request a speech and language evaluation.', emoji: '💬'),
          MilestoneWarning(title: 'No pointing or gestures by 12 months', description: 'Absence of pointing is a key red flag — consult your doctor.', emoji: '👆'),
          MilestoneWarning(title: 'Loss of previously acquired words', description: 'Any regression in language needs immediate evaluation.', emoji: '⚠️'),
        ],
        commonConcerns: [
          CommonConcern(question: 'My baby understands everything but won\'t talk. Is that normal?', answer: 'Yes, receptive language (understanding) always develops ahead of expressive language (speaking). As long as baby is understanding and using gestures, speech will follow. If no words by 15 months, seek evaluation.'),
        ],
        parentTips: [
          'Read books every day — point to pictures and name them.',
          'Respond to every gesture and attempt at communication.',
          'Limit screen time — face-to-face interaction builds language.',
        ],
      );

    case MilestoneCategory.cognitive:
      return CategoryGuidance(
        category: cat, ageBandIndex: band,
        aboutText: 'Your baby is a little scientist — testing, experimenting, and problem-solving. They understand object permanence, follow simple instructions, and are beginning simple pretend play.',
        milestones: [
          MilestoneItem(id: 'nm_co_1', title: 'Finds hidden objects', description: 'Searches for a toy hidden under a cloth.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'nm_co_2', title: 'Imitates actions', description: 'Copies clapping, waving, banging.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'nm_co_3', title: 'Explores objects in multiple ways', description: 'Shakes, bangs, throws, drops to learn.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'nm_co_4', title: 'Simple pretend play beginning', description: 'Pretends to drink from empty cup.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
        ],
        activities: [
          MilestoneActivity(title: 'Advanced Hide and Seek', description: 'Hide objects in multiple locations.', emoji: '🔍', steps: ['Hide a toy under one of two cloths.', 'Ask "Where is it?"', 'Let baby search and find it.']),
          MilestoneActivity(title: 'Pretend Play', description: 'Introduce simple pretend play.', emoji: '🎭', steps: ['Pretend to drink from an empty cup.', 'Offer it to baby.', 'Celebrate when they pretend too.']),
        ],
        signsToLookFor: [
          MilestoneSign(title: 'Searching for hidden objects', description: 'Full object permanence established.', isPositive: true),
          MilestoneSign(title: 'Beginning pretend play', description: 'Early symbolic thinking developing.', isPositive: true),
        ],
        whenToWorry: [
          MilestoneWarning(title: 'No imitation of actions by 12 months', description: 'If baby doesn\'t copy simple actions, consult your doctor.', emoji: '🎭'),
        ],
        commonConcerns: [
          CommonConcern(question: 'My baby is into everything. How do I keep them safe?', answer: 'Baby-proof thoroughly: cover outlets, secure furniture, remove choking hazards, gate stairs. Create a safe "yes" environment where baby can explore freely.'),
        ],
        parentTips: [
          'Create a safe space where baby can explore freely.',
          'Simple puzzles and shape sorters are great cognitive toys.',
          'Narrate what baby is doing: "You\'re putting the block in!"',
        ],
      );

    case MilestoneCategory.social:
      return CategoryGuidance(
        category: cat, ageBandIndex: band,
        aboutText: 'Baby is showing a clear personality and strong preferences. They are beginning to test limits, show empathy, and engage in simple social games. This is the foundation of emotional intelligence.',
        milestones: [
          MilestoneItem(id: 'nm_so_1', title: 'Shows separation anxiety', description: 'Cries or protests when caregiver leaves.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'nm_so_2', title: 'Plays simple interactive games', description: 'Enjoys pat-a-cake, clapping games.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'nm_so_3', title: 'Shows preferences for people and toys', description: 'Has clear favourite people and objects.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'nm_so_4', title: 'Offers objects to others', description: 'Holds out toys to share.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
        ],
        activities: [
          MilestoneActivity(title: 'Pat-a-Cake', description: 'Play pat-a-cake and clapping games.', emoji: '👏', steps: ['Clap baby\'s hands together saying "pat-a-cake".', 'Do it consistently so baby anticipates it.', 'Let baby initiate the game.']),
          MilestoneActivity(title: 'Sharing Games', description: 'Practice giving and taking objects.', emoji: '🎁', steps: ['Hold out your hand: "Can I have it?"', 'Take the toy and say "thank you".', 'Give it back: "Here you go." Repeat.']),
        ],
        signsToLookFor: [
          MilestoneSign(title: 'Offering objects to share', description: 'Early social sharing behaviour.', isPositive: true),
          MilestoneSign(title: 'Showing empathy', description: 'Reacts to others\' emotions — comforts when someone cries.', isPositive: true),
        ],
        whenToWorry: [
          MilestoneWarning(title: 'No interest in social games by 12 months', description: 'If baby doesn\'t engage in simple interactive games, mention to your doctor.', emoji: '🎮'),
        ],
        commonConcerns: [
          CommonConcern(question: 'My baby hits and bites. Is that normal?', answer: 'Yes, at this age. Baby doesn\'t have the language to express frustration, so they use physical actions. Stay calm, say "no hitting", redirect. It will improve as language develops.'),
        ],
        parentTips: [
          'Play interactive games every day.',
          'Model sharing and taking turns.',
          'Name emotions: "You\'re frustrated. I understand."',
        ],
      );

    case MilestoneCategory.feedingSleep:
      return CategoryGuidance(
        category: cat, ageBandIndex: band,
        aboutText: 'Baby is transitioning to family foods and developing self-feeding skills. Sleep may be disrupted by the 9-month and 12-month sleep regressions. One nap transition may begin toward the end of this period.',
        milestones: [
          MilestoneItem(id: 'nm_fs_1', title: 'Eating soft finger foods', description: 'Picks up and eats soft pieces of food.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'nm_fs_2', title: 'Drinking from sippy cup', description: 'Uses a sippy or straw cup independently.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'nm_fs_3', title: 'Eating 3 meals per day', description: 'Established meal pattern with family.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'nm_fs_4', title: 'Sleeping 11-14 hours total', description: 'Night sleep plus 1-2 naps.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
        ],
        activities: [
          MilestoneActivity(title: 'Family Meals', description: 'Include baby in family mealtimes.', emoji: '🍽️', steps: ['Sit baby at the table with the family.', 'Offer modified versions of family food.', 'Let baby see and imitate family eating.']),
          MilestoneActivity(title: 'Self-Feeding Practice', description: 'Encourage self-feeding with finger foods.', emoji: '🫐', steps: ['Offer soft finger foods at every meal.', 'Let baby feed themselves — expect mess.', 'Offer a loaded spoon for them to bring to mouth.']),
        ],
        signsToLookFor: [
          MilestoneSign(title: 'Self-feeding with finger foods', description: 'Independence at mealtimes developing.', isPositive: true),
          MilestoneSign(title: 'Eating a variety of textures', description: 'Accepting lumpy and soft solid foods.', isPositive: true),
        ],
        whenToWorry: [
          MilestoneWarning(title: 'Refusing all textured foods at 12 months', description: 'If baby only accepts smooth purees at 12 months, seek feeding therapy advice.', emoji: '🍽️'),
          MilestoneWarning(title: 'Not drinking from a cup by 12 months', description: 'Begin transitioning away from bottles by 12 months.', emoji: '🥤'),
        ],
        commonConcerns: [
          CommonConcern(question: 'When should I stop breastfeeding?', answer: 'WHO recommends breastfeeding until at least 2 years. The right time to stop is when both mother and baby are ready. There is no medical reason to stop at 12 months if both are happy.'),
          CommonConcern(question: 'My baby only wants milk and refuses food. What do I do?', answer: 'Reduce milk feeds slightly to increase appetite for solids. Offer solids before milk. Make mealtimes positive and pressure-free. If concerned, consult your doctor.'),
        ],
        parentTips: [
          'Include baby in family mealtimes — they learn by watching.',
          'Offer a variety of foods even if rejected — it takes 10-15 exposures.',
          'Begin transitioning from bottle to cup by 12 months.',
        ],
      );
  }
}

// ── 1-2 Years ─────────────────────────────────────────────────────────────────

CategoryGuidance _oneToTwoYearsGuidance(int band, MilestoneCategory cat) {
  final label = ageBands[band].label;
  switch (cat) {
    case MilestoneCategory.grossMotor:
      return CategoryGuidance(
        category: cat, ageBandIndex: band,
        aboutText: 'Your toddler is walking, climbing, and running. Falls are frequent and normal. Give them safe spaces to explore and climb — it builds confidence and coordination.',
        milestones: [
          MilestoneItem(id: 'oy_gm_1_$band', title: 'Walks independently', description: 'Takes steps without holding onto anything.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'oy_gm_2_$band', title: 'Climbs onto furniture', description: 'Climbs onto low chairs or sofas.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'oy_gm_3_$band', title: 'Runs (though may fall)', description: 'Moves quickly but may stumble.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'oy_gm_4_$band', title: 'Kicks a ball', description: 'Kicks a large ball forward.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'oy_gm_5_$band', title: 'Walks up stairs with help', description: 'Climbs stairs holding a hand or rail.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
        ],
        activities: [
          MilestoneActivity(title: 'Ball Play', description: 'Roll and kick balls to build coordination.', emoji: '⚽', steps: ['Roll a large soft ball toward toddler.', 'Encourage them to kick it back.', 'Gradually increase distance.']),
          MilestoneActivity(title: 'Obstacle Course', description: 'Create a simple indoor obstacle course.', emoji: '🏃', steps: ['Use cushions, tunnels, and low steps.', 'Demonstrate going through the course.', 'Cheer toddler through each obstacle.']),
        ],
        signsToLookFor: [
          MilestoneSign(title: 'Walking independently by 15 months', description: 'Walking at 18 months is still within normal range.', isPositive: true),
          MilestoneSign(title: 'Climbing and exploring', description: 'Shows confidence and coordination developing.', isPositive: true),
        ],
        whenToWorry: [
          MilestoneWarning(title: 'Not walking by 18 months', description: 'If not walking independently by 18 months, consult your doctor.', emoji: '⚠️'),
          MilestoneWarning(title: 'Frequent falls after 18 months', description: 'Some falling is normal, but excessive falling may need physiotherapy assessment.', emoji: '📋'),
        ],
        commonConcerns: [
          CommonConcern(question: 'My toddler walks on their tiptoes. Should I worry?', answer: 'Occasional tiptoeing is normal. Consistent tiptoeing after 2 years, especially with other developmental concerns, should be evaluated.'),
        ],
        parentTips: [
          'Let toddler walk as much as possible — limit pushchair use.',
          'Provide safe climbing opportunities — low climbing frames, cushion piles.',
          'Barefoot walking on different surfaces builds balance.',
        ],
      );

    case MilestoneCategory.fineMotor:
      return CategoryGuidance(
        category: cat, ageBandIndex: band,
        aboutText: 'Toddler is stacking, scribbling, and beginning to use tools. Fine motor skills are developing rapidly as they explore art, building, and self-care activities.',
        milestones: [
          MilestoneItem(id: 'oy_fm_1_$band', title: 'Stacks 2-4 blocks', description: 'Places blocks on top of each other.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'oy_fm_2_$band', title: 'Scribbles with crayon', description: 'Makes marks on paper with a crayon.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'oy_fm_3_$band', title: 'Turns pages of a board book', description: 'Flips thick pages of a book.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'oy_fm_4_$band', title: 'Uses spoon with spilling', description: 'Attempts to feed self with a spoon.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
        ],
        activities: [
          MilestoneActivity(title: 'Block Tower', description: 'Build towers together and knock them down.', emoji: '🏗️', steps: ['Stack 2-3 blocks.', 'Let toddler knock them down.', 'Encourage them to build their own tower.']),
          MilestoneActivity(title: 'Scribble Art', description: 'Provide chunky crayons and large paper.', emoji: '🖍️', steps: ['Give chunky crayons and large paper.', 'Demonstrate scribbling.', 'Let toddler scribble freely — no right or wrong.']),
        ],
        signsToLookFor: [
          MilestoneSign(title: 'Stacking blocks', description: 'Shows hand-eye coordination and spatial awareness.', isPositive: true),
          MilestoneSign(title: 'Scribbling intentionally', description: 'Early mark-making is pre-writing development.', isPositive: true),
        ],
        whenToWorry: [
          MilestoneWarning(title: 'Not scribbling by 18 months', description: 'If toddler shows no interest in mark-making, mention to your doctor.', emoji: '✏️'),
        ],
        commonConcerns: [
          CommonConcern(question: 'Should my toddler be using their right or left hand?', answer: 'Hand preference usually establishes between 18 months and 3 years. Don\'t force a preference. If toddler strongly favours one hand before 18 months, mention to your doctor.'),
        ],
        parentTips: [
          'Provide chunky crayons and large paper for scribbling.',
          'Let toddler help with self-care: putting on shoes, washing hands.',
          'Simple puzzles and shape sorters are great fine motor toys.',
        ],
      );

    case MilestoneCategory.language:
      return CategoryGuidance(
        category: cat, ageBandIndex: band,
        aboutText: 'Vocabulary is exploding. Toddler is combining words, asking questions, and beginning to tell simple stories. The more you talk, read, and sing, the faster language develops.',
        milestones: [
          MilestoneItem(id: 'oy_la_1_$band', title: 'Uses 10-50 words', description: 'Growing vocabulary of real words.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'oy_la_2_$band', title: 'Combines 2 words', description: 'Says "more milk", "daddy go", "big dog".', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'oy_la_3_$band', title: 'Points to body parts when named', description: 'Touches nose, eyes, ears when asked.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'oy_la_4_$band', title: 'Follows 2-step instructions', description: 'Carries out two-part commands.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
        ],
        activities: [
          MilestoneActivity(title: 'Body Parts Game', description: 'Play "Where is your nose?" games.', emoji: '👃', steps: ['Ask "Where is your nose?" and point to yours.', 'Help toddler point to theirs.', 'Progress to eyes, ears, tummy, toes.']),
          MilestoneActivity(title: 'Two-Step Instructions', description: 'Give simple two-step instructions.', emoji: '🎯', steps: ['Say "Get the ball and put it in the box."', 'Help if needed.', 'Celebrate when they complete both steps.']),
        ],
        signsToLookFor: [
          MilestoneSign(title: '50+ words by 24 months', description: 'Vocabulary of 50 words by age 2 is a key milestone.', isPositive: true),
          MilestoneSign(title: 'Two-word combinations by 24 months', description: '"More milk", "daddy go" — combining words is a major step.', isPositive: true),
        ],
        whenToWorry: [
          MilestoneWarning(title: 'Fewer than 50 words by 24 months', description: 'Request a speech and language evaluation.', emoji: '💬'),
          MilestoneWarning(title: 'No two-word combinations by 24 months', description: 'Key milestone — consult your doctor if not present.', emoji: '🗣️'),
          MilestoneWarning(title: 'Loss of previously acquired words', description: 'Any regression needs immediate evaluation.', emoji: '⚠️'),
        ],
        commonConcerns: [
          CommonConcern(question: 'My toddler uses their own language that only I understand. Is that normal?', answer: 'Yes. At 18 months, 25% of speech should be understandable to strangers. By 24 months, 50%. By 36 months, 75%. If significantly below these, seek speech therapy.'),
          CommonConcern(question: 'Does screen time affect language development?', answer: 'Yes. Screen time displaces face-to-face interaction, which is essential for language. Limit to 1 hour per day of high-quality content for 18-24 month olds, with a caregiver watching together.'),
        ],
        parentTips: [
          'Read books every day — it\'s the single best thing for language.',
          'Expand on what toddler says: they say "dog", you say "yes, big brown dog!"',
          'Limit screen time — face-to-face interaction builds language.',
        ],
      );

    case MilestoneCategory.cognitive:
      return CategoryGuidance(
        category: cat, ageBandIndex: band,
        aboutText: 'Toddler is engaging in pretend play, sorting, and beginning to understand concepts like "more", "all gone", and "mine". Their memory is developing and they are beginning to problem-solve.',
        milestones: [
          MilestoneItem(id: 'oy_co_1_$band', title: 'Simple pretend play', description: 'Pretends to feed a doll or talk on a toy phone.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'oy_co_2_$band', title: 'Sorts shapes and colours', description: 'Begins to match shapes or group by colour.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'oy_co_3_$band', title: 'Completes simple puzzles', description: 'Places pieces in a 2-3 piece puzzle.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'oy_co_4_$band', title: 'Points to pictures in books', description: 'Identifies and points to named pictures.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
        ],
        activities: [
          MilestoneActivity(title: 'Pretend Play', description: 'Set up simple pretend play scenarios.', emoji: '🎭', steps: ['Offer a doll and pretend food.', 'Demonstrate feeding the doll.', 'Let toddler take over the play.']),
          MilestoneActivity(title: 'Shape Sorter', description: 'Use a shape sorter to build cognitive skills.', emoji: '🔷', steps: ['Show toddler how to match shapes.', 'Let them try independently.', 'Celebrate every success.']),
        ],
        signsToLookFor: [
          MilestoneSign(title: 'Engaging in pretend play', description: 'Symbolic thinking is developing.', isPositive: true),
          MilestoneSign(title: 'Completing simple puzzles', description: 'Problem-solving and spatial awareness.', isPositive: true),
        ],
        whenToWorry: [
          MilestoneWarning(title: 'No pretend play by 18 months', description: 'Absence of pretend play may need evaluation.', emoji: '🎭'),
        ],
        commonConcerns: [
          CommonConcern(question: 'My toddler has tantrums every day. Is that normal?', answer: 'Yes. Tantrums peak between 18 months and 3 years. Toddlers have big emotions but limited language and self-regulation. Stay calm, validate feelings, and set consistent limits.'),
        ],
        parentTips: [
          'Provide open-ended toys: blocks, play dough, dolls.',
          'Ask questions: "What does the cow say?"',
          'Let toddler help with simple tasks — it builds confidence.',
        ],
      );

    case MilestoneCategory.social:
      return CategoryGuidance(
        category: cat, ageBandIndex: band,
        aboutText: 'Toddler is asserting independence, testing limits, and beginning to play alongside other children. Tantrums are normal and a sign of healthy emotional development.',
        milestones: [
          MilestoneItem(id: 'oy_so_1_$band', title: 'Shows affection to familiar people', description: 'Hugs, kisses, or cuddles caregivers.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'oy_so_2_$band', title: 'Plays alongside other children', description: 'Parallel play — plays near but not yet with others.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'oy_so_3_$band', title: 'Shows defiance', description: 'Says "no" and asserts independence.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'oy_so_4_$band', title: 'Imitates adult activities', description: 'Pretends to talk on phone, sweep, or cook.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
        ],
        activities: [
          MilestoneActivity(title: 'Playdates', description: 'Arrange playdates with other toddlers.', emoji: '👫', steps: ['Arrange a playdate with 1-2 other toddlers.', 'Supervise but don\'t direct play.', 'Parallel play is normal — don\'t force sharing.']),
          MilestoneActivity(title: 'Household Helper', description: 'Let toddler help with simple chores.', emoji: '🧹', steps: ['Give toddler a small broom or cloth.', 'Let them "help" sweep or wipe.', 'Praise their contribution.']),
        ],
        signsToLookFor: [
          MilestoneSign(title: 'Showing affection', description: 'Secure attachment and emotional development.', isPositive: true),
          MilestoneSign(title: 'Parallel play with other children', description: 'Normal social development at this age.', isPositive: true),
        ],
        whenToWorry: [
          MilestoneWarning(title: 'No interest in other children by 2 years', description: 'Complete disinterest in other children may need evaluation.', emoji: '👥'),
          MilestoneWarning(title: 'Extreme tantrums that can\'t be calmed', description: 'If tantrums are very frequent and intense, discuss with your doctor.', emoji: '😢'),
        ],
        commonConcerns: [
          CommonConcern(question: 'My toddler hits other children. What should I do?', answer: 'Stay calm, intervene immediately, say "no hitting", and redirect. Don\'t hit back to "show them how it feels". Consistent, calm responses work best. It will improve with language development.'),
        ],
        parentTips: [
          'Validate emotions: "I know you\'re angry. It\'s okay to be angry."',
          'Set consistent, simple limits.',
          'Parallel play is normal — don\'t force sharing yet.',
        ],
      );

    case MilestoneCategory.feedingSleep:
      return CategoryGuidance(
        category: cat, ageBandIndex: band,
        aboutText: 'Toddler is eating family foods and transitioning to one nap. Fussy eating is very common and normal at this age. Sleep needs are changing as the afternoon nap consolidates.',
        milestones: [
          MilestoneItem(id: 'oy_fs_1_$band', title: 'Eating family foods', description: 'Eating modified versions of family meals.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'oy_fs_2_$band', title: 'Using fork and spoon', description: 'Attempts to use utensils independently.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'oy_fs_3_$band', title: 'Transitioning to one nap', description: 'Moving from 2 naps to 1 afternoon nap.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'oy_fs_4_$band', title: 'Sleeping 11-14 hours total', description: 'Night sleep plus one afternoon nap.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
        ],
        activities: [
          MilestoneActivity(title: 'Family Meals Together', description: 'Eat together as a family as often as possible.', emoji: '🍽️', steps: ['Sit together at the table.', 'Offer toddler the same food as the family.', 'No pressure to eat — exposure is the goal.']),
          MilestoneActivity(title: 'Utensil Practice', description: 'Provide child-sized fork and spoon at every meal.', emoji: '🥄', steps: ['Give toddler their own fork and spoon.', 'Load the spoon for them initially.', 'Gradually let them load it themselves.']),
        ],
        signsToLookFor: [
          MilestoneSign(title: 'Eating a variety of foods', description: 'Exposure to many foods now prevents fussiness later.', isPositive: true),
          MilestoneSign(title: 'Using utensils independently', description: 'Self-feeding skills developing well.', isPositive: true),
        ],
        whenToWorry: [
          MilestoneWarning(title: 'Eating fewer than 20 different foods', description: 'Very limited diet may indicate feeding difficulties — seek advice.', emoji: '🍽️'),
          MilestoneWarning(title: 'Gagging or vomiting at mealtimes', description: 'May indicate sensory feeding issues — consult your doctor.', emoji: '⚠️'),
        ],
        commonConcerns: [
          CommonConcern(question: 'My toddler only eats 5 foods. Is that normal?', answer: 'Food neophobia (fear of new foods) peaks between 18 months and 3 years. Keep offering variety without pressure. It takes 10-15 exposures before a new food is accepted. Seek help if diet is very restricted.'),
          CommonConcern(question: 'When should my toddler drop the afternoon nap?', answer: 'Most toddlers transition to one nap between 15-18 months. Signs: taking a long time to fall asleep at nap time, or nap interfering with bedtime. The transition can take 4-6 weeks.'),
        ],
        parentTips: [
          'Offer new foods alongside accepted foods — no pressure.',
          'Let toddler help prepare food — they\'re more likely to eat it.',
          'Keep mealtimes positive and pressure-free.',
        ],
      );
  }
}

// ── 2-3 Years ─────────────────────────────────────────────────────────────────

CategoryGuidance _twoToThreeYearsGuidance(int band, MilestoneCategory cat) {
  final label = ageBands[band].label;
  switch (cat) {
    case MilestoneCategory.grossMotor:
      return CategoryGuidance(
        category: cat, ageBandIndex: band,
        aboutText: 'Your toddler is running, jumping, and climbing with increasing confidence. Balance and coordination are improving rapidly. Active outdoor play is essential.',
        milestones: [
          MilestoneItem(id: 'tw_gm_1_$band', title: 'Runs confidently', description: 'Runs without falling frequently.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'tw_gm_2_$band', title: 'Jumps with both feet', description: 'Jumps off the ground with both feet.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'tw_gm_3_$band', title: 'Climbs playground equipment', description: 'Climbs ladders and frames with confidence.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'tw_gm_4_$band', title: 'Pedals a tricycle', description: 'Pedals and steers a tricycle.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'tw_gm_5_$band', title: 'Walks up and down stairs alternating feet', description: 'Uses alternating feet on stairs.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
        ],
        activities: [
          MilestoneActivity(title: 'Jumping Practice', description: 'Practice jumping from low heights.', emoji: '🦘', steps: ['Stand on a low step together.', 'Jump off holding hands.', 'Progress to jumping independently.']),
          MilestoneActivity(title: 'Outdoor Active Play', description: 'Daily outdoor play on playground equipment.', emoji: '🛝', steps: ['Visit a playground daily if possible.', 'Let child lead their own play.', 'Supervise but don\'t over-direct.']),
        ],
        signsToLookFor: [
          MilestoneSign(title: 'Running without falling', description: 'Balance and coordination well developed.', isPositive: true),
          MilestoneSign(title: 'Jumping with both feet', description: 'Bilateral coordination milestone.', isPositive: true),
        ],
        whenToWorry: [
          MilestoneWarning(title: 'Not running by 2.5 years', description: 'Consult your doctor if child isn\'t running by 2.5 years.', emoji: '⚠️'),
          MilestoneWarning(title: 'Frequent unexplained falls', description: 'May indicate balance or coordination issues.', emoji: '📋'),
        ],
        commonConcerns: [
          CommonConcern(question: 'How much physical activity does my 2-year-old need?', answer: 'At least 3 hours of physical activity spread throughout the day, including 1 hour of energetic play. Limit sitting for more than 1 hour at a time.'),
        ],
        parentTips: [
          'Daily outdoor play is essential — rain or shine.',
          'Let child take safe risks — it builds confidence.',
          'Limit screen time to 1 hour per day.',
        ],
      );

    case MilestoneCategory.fineMotor:
      return CategoryGuidance(
        category: cat, ageBandIndex: band,
        aboutText: 'Fine motor skills are becoming more precise. Child is drawing, cutting, and dressing themselves. These skills are building the foundation for writing.',
        milestones: [
          MilestoneItem(id: 'tw_fm_1_$band', title: 'Draws circles and lines', description: 'Makes intentional circular and straight marks.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'tw_fm_2_$band', title: 'Stacks 6+ blocks', description: 'Builds tall towers.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'tw_fm_3_$band', title: 'Uses scissors with help', description: 'Snips paper with child scissors.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'tw_fm_4_$band', title: 'Dresses with minimal help', description: 'Puts on and removes simple clothing.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
        ],
        activities: [
          MilestoneActivity(title: 'Drawing Practice', description: 'Provide crayons and paper for free drawing.', emoji: '🖍️', steps: ['Demonstrate drawing a circle.', 'Let child try.', 'Name what they draw — even if it\'s abstract.']),
          MilestoneActivity(title: 'Dressing Practice', description: 'Allow extra time for child to dress themselves.', emoji: '👕', steps: ['Lay out simple clothing.', 'Let child try to put it on.', 'Help only when asked.']),
        ],
        signsToLookFor: [
          MilestoneSign(title: 'Drawing intentional shapes', description: 'Pre-writing skills developing.', isPositive: true),
          MilestoneSign(title: 'Attempting to dress independently', description: 'Self-care skills and fine motor developing together.', isPositive: true),
        ],
        whenToWorry: [
          MilestoneWarning(title: 'Not drawing any shapes by 3 years', description: 'If child makes no intentional marks, mention to your doctor.', emoji: '✏️'),
        ],
        commonConcerns: [
          CommonConcern(question: 'My child holds their crayon in a fist. Should I correct them?', answer: 'Fist grip is normal until about 3-4 years. Gradually model a tripod grip but don\'t force it. Provide chunky crayons which naturally encourage better grip.'),
        ],
        parentTips: [
          'Provide play dough — it\'s excellent for hand strength.',
          'Let child help with self-care: buttons, zips, shoes.',
          'Finger painting builds fine motor and sensory skills.',
        ],
      );

    case MilestoneCategory.language:
      return CategoryGuidance(
        category: cat, ageBandIndex: band,
        aboutText: 'Language is exploding. Child is using sentences, asking "why", and beginning to tell stories. Vocabulary grows by 5-10 new words per day at this stage.',
        milestones: [
          MilestoneItem(id: 'tw_la_1_$band', title: 'Uses 3-4 word sentences', description: 'Combines multiple words in sentences.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'tw_la_2_$band', title: 'Asks "what" and "where" questions', description: 'Uses question words.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'tw_la_3_$band', title: 'Strangers understand 50-75% of speech', description: 'Speech becoming clearer.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'tw_la_4_$band', title: 'Uses pronouns (I, me, you)', description: 'Begins using personal pronouns.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
        ],
        activities: [
          MilestoneActivity(title: 'Story Time', description: 'Read books and ask questions about the story.', emoji: '📚', steps: ['Read a picture book together.', 'Ask "What is the dog doing?"', 'Let child tell you what happens next.']),
          MilestoneActivity(title: 'Question Games', description: 'Ask open-ended questions throughout the day.', emoji: '❓', steps: ['Ask "What did you do today?"', 'Ask "Why do you think that happened?"', 'Listen and expand on their answers.']),
        ],
        signsToLookFor: [
          MilestoneSign(title: 'Using sentences of 3+ words', description: 'Sentence structure developing well.', isPositive: true),
          MilestoneSign(title: 'Asking questions', description: 'Curiosity and language developing together.', isPositive: true),
        ],
        whenToWorry: [
          MilestoneWarning(title: 'Not using sentences by 2.5 years', description: 'Request a speech and language evaluation.', emoji: '💬'),
          MilestoneWarning(title: 'Strangers can\'t understand speech at 3 years', description: '75% of speech should be understandable to strangers by age 3.', emoji: '🗣️'),
        ],
        commonConcerns: [
          CommonConcern(question: 'My child stutters. Should I be worried?', answer: 'Stuttering is common between 2-5 years as language develops faster than speech motor skills. Don\'t finish their sentences or tell them to slow down. If it persists beyond 6 months or causes distress, seek speech therapy.'),
        ],
        parentTips: [
          'Read books every day — it\'s the best language activity.',
          'Answer every "why" question — curiosity drives learning.',
          'Expand on what child says: they say "dog run", you say "yes, the big dog is running fast!"',
        ],
      );

    case MilestoneCategory.cognitive:
      return CategoryGuidance(
        category: cat, ageBandIndex: band,
        aboutText: 'Child is engaging in complex pretend play, understanding concepts like "same" and "different", and beginning to understand time. Their memory and attention span are growing.',
        milestones: [
          MilestoneItem(id: 'tw_co_1_$band', title: 'Complex pretend play', description: 'Acts out scenarios with dolls or toys.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'tw_co_2_$band', title: 'Matches colours and shapes', description: 'Sorts objects by colour and shape.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'tw_co_3_$band', title: 'Counts to 3-5', description: 'Counts objects with one-to-one correspondence.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'tw_co_4_$band', title: 'Understands "same" and "different"', description: 'Can identify matching and non-matching objects.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
        ],
        activities: [
          MilestoneActivity(title: 'Sorting Games', description: 'Sort objects by colour, shape, or size.', emoji: '🔷', steps: ['Gather objects of different colours.', 'Sort them into groups together.', 'Name the colours as you sort.']),
          MilestoneActivity(title: 'Counting Practice', description: 'Count objects throughout the day.', emoji: '🔢', steps: ['Count stairs as you climb them.', 'Count grapes before eating.', 'Count toys as you put them away.']),
        ],
        signsToLookFor: [
          MilestoneSign(title: 'Engaging in complex pretend play', description: 'Symbolic thinking and creativity developing.', isPositive: true),
          MilestoneSign(title: 'Counting with understanding', description: 'One-to-one correspondence is a key maths foundation.', isPositive: true),
        ],
        whenToWorry: [
          MilestoneWarning(title: 'No pretend play by 2.5 years', description: 'Absence of pretend play needs evaluation.', emoji: '🎭'),
        ],
        commonConcerns: [
          CommonConcern(question: 'Should I be teaching my 2-year-old to read?', answer: 'Focus on pre-literacy skills: reading together, rhyming, singing, and talking. Formal reading instruction is not appropriate at this age. Play is the best learning.'),
        ],
        parentTips: [
          'Provide open-ended toys: blocks, play dough, dress-up clothes.',
          'Count everything in daily life.',
          'Ask "why" and "what if" questions to build thinking skills.',
        ],
      );

    case MilestoneCategory.social:
      return CategoryGuidance(
        category: cat, ageBandIndex: band,
        aboutText: 'Child is beginning to play cooperatively with other children, developing friendships, and learning to manage emotions. Tantrums are decreasing as language improves.',
        milestones: [
          MilestoneItem(id: 'tw_so_1_$band', title: 'Plays cooperatively with other children', description: 'Takes turns and plays together.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'tw_so_2_$band', title: 'Shows empathy', description: 'Comforts others who are upset.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'tw_so_3_$band', title: 'Separates from parents more easily', description: 'Manages separation at nursery or with carers.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'tw_so_4_$band', title: 'Understands simple rules', description: 'Follows simple rules in games.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
        ],
        activities: [
          MilestoneActivity(title: 'Turn-Taking Games', description: 'Play simple board games or turn-taking activities.', emoji: '🎲', steps: ['Play a simple game like rolling a ball back and forth.', 'Say "my turn, your turn" clearly.', 'Praise turn-taking: "Great sharing!"']),
          MilestoneActivity(title: 'Emotion Coaching', description: 'Name and validate emotions.', emoji: '💗', steps: ['When child is upset: "I can see you\'re angry."', '"It\'s okay to feel angry."', '"Let\'s take some deep breaths together."']),
        ],
        signsToLookFor: [
          MilestoneSign(title: 'Playing cooperatively', description: 'Moving from parallel to cooperative play.', isPositive: true),
          MilestoneSign(title: 'Showing empathy', description: 'Emotional intelligence developing.', isPositive: true),
        ],
        whenToWorry: [
          MilestoneWarning(title: 'No cooperative play by 3 years', description: 'If child can\'t play with other children at all, mention to your doctor.', emoji: '👥'),
          MilestoneWarning(title: 'Extreme aggression toward other children', description: 'Some aggression is normal; extreme or persistent aggression needs support.', emoji: '⚠️'),
        ],
        commonConcerns: [
          CommonConcern(question: 'My child doesn\'t want to share. Is that normal?', answer: 'Yes. True sharing (understanding another\'s perspective) develops around 3-4 years. Before that, "sharing" is really just taking turns. Teach turn-taking rather than forcing sharing.'),
        ],
        parentTips: [
          'Name emotions throughout the day.',
          'Model empathy: "That person looks sad. I wonder how they feel."',
          'Arrange regular playdates with the same children.',
        ],
      );

    case MilestoneCategory.feedingSleep:
      return CategoryGuidance(
        category: cat, ageBandIndex: band,
        aboutText: 'Child is eating family foods independently and sleeping 11-13 hours including one afternoon nap. Toilet training typically begins in this period.',
        milestones: [
          MilestoneItem(id: 'tw_fs_1_$band', title: 'Eating independently with utensils', description: 'Uses fork and spoon with minimal spilling.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'tw_fs_2_$band', title: 'Showing toilet training readiness', description: 'Aware of wet/dirty nappy, interested in toilet.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'tw_fs_3_$band', title: 'Sleeping 11-13 hours total', description: 'Night sleep plus one afternoon nap.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'tw_fs_4_$band', title: 'Falling asleep independently', description: 'Settles to sleep without caregiver present.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
        ],
        activities: [
          MilestoneActivity(title: 'Toilet Training Introduction', description: 'Introduce the potty when child shows readiness signs.', emoji: '🚽', steps: ['Get a child-sized potty.', 'Let child sit on it clothed first.', 'Read books about using the toilet together.']),
          MilestoneActivity(title: 'Bedtime Routine', description: 'Maintain a consistent, calming bedtime routine.', emoji: '🌙', steps: ['Bath, pyjamas, teeth, book, sleep.', 'Keep it to 30-45 minutes.', 'Same time every night.']),
        ],
        signsToLookFor: [
          MilestoneSign(title: 'Toilet training readiness signs', description: 'Aware of bodily functions, interested in toilet, can follow instructions.', isPositive: true),
          MilestoneSign(title: 'Settling to sleep independently', description: 'Self-regulation skills developing.', isPositive: true),
        ],
        whenToWorry: [
          MilestoneWarning(title: 'No toilet training readiness by 3 years', description: 'If no signs of readiness by 3 years, discuss with your doctor.', emoji: '🚽'),
          MilestoneWarning(title: 'Significant sleep difficulties', description: 'If sleep problems are affecting family functioning, seek support.', emoji: '😴'),
        ],
        commonConcerns: [
          CommonConcern(question: 'When should I start toilet training?', answer: 'When child shows readiness signs: aware of wet/dirty nappy, interested in toilet, can follow simple instructions, can pull pants up and down. Most children are ready between 2-3 years. Don\'t rush it.'),
          CommonConcern(question: 'My child still needs a nap at 3 years. Is that normal?', answer: 'Yes. Many children nap until 3-4 years. Don\'t drop the nap until child consistently resists it and can manage the afternoon without it.'),
        ],
        parentTips: [
          'Wait for toilet training readiness — forcing it causes setbacks.',
          'Praise every success on the potty.',
          'Maintain consistent sleep routine even on weekends.',
        ],
      );
  }
}

// ── 3-5 Years ─────────────────────────────────────────────────────────────────

CategoryGuidance _threeToFiveYearsGuidance(int band, MilestoneCategory cat) {
  final label = ageBands[band].label;
  switch (cat) {
    case MilestoneCategory.grossMotor:
      return CategoryGuidance(
        category: cat, ageBandIndex: band,
        aboutText: 'Your child is hopping, skipping, and catching balls. Balance and coordination are becoming more refined. This is a great age for structured physical activities like swimming, gymnastics, or dance.',
        milestones: [
          MilestoneItem(id: 'th_gm_1_$band', title: 'Hops on one foot', description: 'Balances and hops on one foot.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'th_gm_2_$band', title: 'Catches a large ball', description: 'Catches a ball thrown from short distance.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'th_gm_3_$band', title: 'Skips', description: 'Skips with alternating feet.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'th_gm_4_$band', title: 'Rides a balance bike or tricycle', description: 'Steers and pedals confidently.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
        ],
        activities: [
          MilestoneActivity(title: 'Ball Games', description: 'Practice throwing and catching.', emoji: '⚽', steps: ['Start with a large soft ball.', 'Throw gently from close range.', 'Gradually increase distance as skills improve.']),
          MilestoneActivity(title: 'Hopping Practice', description: 'Practice hopping on each foot.', emoji: '🦘', steps: ['Hold child\'s hand and hop together.', 'Count hops: "1, 2, 3!"', 'Let child try independently.']),
        ],
        signsToLookFor: [
          MilestoneSign(title: 'Hopping on one foot', description: 'Balance and coordination well developed.', isPositive: true),
          MilestoneSign(title: 'Catching a ball', description: 'Eye-hand coordination developing well.', isPositive: true),
        ],
        whenToWorry: [
          MilestoneWarning(title: 'Not hopping by 4 years', description: 'If child can\'t hop on one foot by 4 years, mention to your doctor.', emoji: '⚠️'),
          MilestoneWarning(title: 'Very poor balance or coordination', description: 'May indicate developmental coordination disorder — seek assessment.', emoji: '📋'),
        ],
        commonConcerns: [
          CommonConcern(question: 'When should my child learn to ride a bike?', answer: 'Most children learn to ride a balance bike at 2-3 years and a pedal bike (without stabilisers) at 4-6 years. Start with a balance bike — it\'s the fastest route to pedal biking.'),
        ],
        parentTips: [
          'Enrol in swimming lessons — a vital safety skill.',
          'Active outdoor play every day.',
          'Structured activities like gymnastics or dance build coordination.',
        ],
      );

    case MilestoneCategory.fineMotor:
      return CategoryGuidance(
        category: cat, ageBandIndex: band,
        aboutText: 'Fine motor skills are becoming school-ready. Child is drawing recognisable shapes and people, cutting with scissors, and beginning to write letters.',
        milestones: [
          MilestoneItem(id: 'th_fm_1_$band', title: 'Draws a person with 3+ parts', description: 'Draws a recognisable person with head, body, limbs.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'th_fm_2_$band', title: 'Cuts along a line with scissors', description: 'Cuts paper following a straight line.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'th_fm_3_$band', title: 'Copies letters and numbers', description: 'Copies simple letters and numbers.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'th_fm_4_$band', title: 'Buttons and zips clothing', description: 'Manages buttons and zips independently.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
        ],
        activities: [
          MilestoneActivity(title: 'Drawing People', description: 'Encourage drawing people and naming the parts.', emoji: '🎨', steps: ['Ask child to draw a person.', 'Ask "Where is the nose? The arms?"', 'Add details together.']),
          MilestoneActivity(title: 'Scissor Practice', description: 'Practice cutting with child-safe scissors.', emoji: '✂️', steps: ['Draw lines on paper.', 'Show child how to cut along the line.', 'Progress to cutting out simple shapes.']),
        ],
        signsToLookFor: [
          MilestoneSign(title: 'Drawing recognisable figures', description: 'Pre-writing and representational drawing developing.', isPositive: true),
          MilestoneSign(title: 'Correct pencil grip', description: 'Tripod grip established.', isPositive: true),
        ],
        whenToWorry: [
          MilestoneWarning(title: 'Not drawing any recognisable shapes by 4 years', description: 'May indicate fine motor delay — seek occupational therapy assessment.', emoji: '✏️'),
          MilestoneWarning(title: 'Can\'t use scissors at all by 4 years', description: 'Scissor skills are a school-readiness indicator.', emoji: '✂️'),
        ],
        commonConcerns: [
          CommonConcern(question: 'My child writes letters backwards. Is that dyslexia?', answer: 'Letter reversals are completely normal until age 7-8. Most children reverse letters as they learn to write. True dyslexia is diagnosed much later and involves more than letter reversals.'),
        ],
        parentTips: [
          'Provide play dough, threading beads, and puzzles.',
          'Let child help with cooking — stirring, pouring, rolling.',
          'Encourage drawing and colouring every day.',
        ],
      );

    case MilestoneCategory.language:
      return CategoryGuidance(
        category: cat, ageBandIndex: band,
        aboutText: 'Child is using complex sentences, telling stories, and asking endless questions. Vocabulary is growing rapidly. This is a critical period for literacy foundations.',
        milestones: [
          MilestoneItem(id: 'th_la_1_$band', title: 'Uses complex sentences', description: 'Uses sentences of 5+ words with grammar.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'th_la_2_$band', title: 'Tells simple stories', description: 'Recounts events in sequence.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'th_la_3_$band', title: 'Strangers understand most speech', description: '75-100% of speech understandable.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'th_la_4_$band', title: 'Knows name, age, and address', description: 'Can state personal information.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
        ],
        activities: [
          MilestoneActivity(title: 'Story Telling', description: 'Encourage child to tell stories about their day.', emoji: '📖', steps: ['Ask "What happened at nursery today?"', 'Listen without interrupting.', 'Ask follow-up questions: "And then what happened?"']),
          MilestoneActivity(title: 'Rhyming Games', description: 'Play rhyming games to build phonological awareness.', emoji: '🎵', steps: ['Say a word: "cat".', 'Ask "What rhymes with cat?"', 'Take turns making rhyming words.']),
        ],
        signsToLookFor: [
          MilestoneSign(title: 'Telling coherent stories', description: 'Narrative language is a key school-readiness skill.', isPositive: true),
          MilestoneSign(title: 'Speech mostly clear to strangers', description: 'Articulation developing well.', isPositive: true),
        ],
        whenToWorry: [
          MilestoneWarning(title: 'Speech not understood by strangers at 4 years', description: 'Request a speech and language evaluation.', emoji: '🗣️'),
          MilestoneWarning(title: 'Stuttering persisting beyond 6 months', description: 'Seek speech therapy if stuttering is causing distress or persisting.', emoji: '💬'),
        ],
        commonConcerns: [
          CommonConcern(question: 'My child asks "why" constantly. How do I handle it?', answer: 'Answer every "why" — it\'s how they learn. If you don\'t know, say "I don\'t know, let\'s find out together." This models curiosity and intellectual honesty.'),
        ],
        parentTips: [
          'Read together every day — it\'s the best school preparation.',
          'Play rhyming and word games.',
          'Answer every question — curiosity is precious.',
        ],
      );

    case MilestoneCategory.cognitive:
      return CategoryGuidance(
        category: cat, ageBandIndex: band,
        aboutText: 'Child is developing logical thinking, understanding time concepts, and beginning to read. They can follow multi-step instructions and are developing early maths and literacy skills.',
        milestones: [
          MilestoneItem(id: 'th_co_1_$band', title: 'Counts to 10 with understanding', description: 'Counts objects with one-to-one correspondence.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'th_co_2_$band', title: 'Recognises letters of own name', description: 'Identifies letters in their name.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'th_co_3_$band', title: 'Understands yesterday/today/tomorrow', description: 'Basic time concepts.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'th_co_4_$band', title: 'Follows 3-step instructions', description: 'Carries out three-part commands.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
        ],
        activities: [
          MilestoneActivity(title: 'Name Writing', description: 'Practice writing child\'s name.', emoji: '✏️', steps: ['Write child\'s name in large letters.', 'Let them trace it.', 'Progress to copying it independently.']),
          MilestoneActivity(title: 'Counting Games', description: 'Count objects in everyday situations.', emoji: '🔢', steps: ['Count stairs, grapes, toys.', 'Play board games with dice.', 'Count money in a piggy bank.']),
        ],
        signsToLookFor: [
          MilestoneSign(title: 'Counting with understanding', description: 'One-to-one correspondence established.', isPositive: true),
          MilestoneSign(title: 'Recognising own name in print', description: 'Early literacy developing.', isPositive: true),
        ],
        whenToWorry: [
          MilestoneWarning(title: 'Not counting to 5 by 4 years', description: 'May indicate maths learning difficulties — seek assessment.', emoji: '🔢'),
        ],
        commonConcerns: [
          CommonConcern(question: 'Should my child know how to read before starting school?', answer: 'No. School teaches reading. Pre-literacy skills (letter recognition, phonological awareness, love of books) are what matter. Focus on reading together, not formal instruction.'),
        ],
        parentTips: [
          'Play board games — they teach counting, turn-taking, and rules.',
          'Cook together — it\'s maths and science in action.',
          'Visit the library regularly.',
        ],
      );

    case MilestoneCategory.social:
      return CategoryGuidance(
        category: cat, ageBandIndex: band,
        aboutText: 'Child is forming real friendships, understanding rules, and developing a sense of fairness. They are also beginning to understand other people\'s perspectives.',
        milestones: [
          MilestoneItem(id: 'th_so_1_$band', title: 'Has preferred friends', description: 'Shows preference for specific children.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'th_so_2_$band', title: 'Understands rules of games', description: 'Follows rules in simple games.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'th_so_3_$band', title: 'Shows concern for others', description: 'Notices and responds to others\' feelings.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'th_so_4_$band', title: 'Manages transitions better', description: 'Copes with changes in routine more easily.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
        ],
        activities: [
          MilestoneActivity(title: 'Board Games', description: 'Play simple board games to learn rules and turn-taking.', emoji: '🎲', steps: ['Choose a simple game like Snakes and Ladders.', 'Explain the rules clearly.', 'Model good sportsmanship — winning and losing gracefully.']),
          MilestoneActivity(title: 'Emotion Stories', description: 'Read books about emotions and discuss them.', emoji: '📚', steps: ['Choose a book with emotional themes.', 'Ask "How do you think they feel?"', '"What would you do in that situation?"']),
        ],
        signsToLookFor: [
          MilestoneSign(title: 'Forming friendships', description: 'Social bonds developing beyond family.', isPositive: true),
          MilestoneSign(title: 'Understanding fairness', description: 'Moral development beginning.', isPositive: true),
        ],
        whenToWorry: [
          MilestoneWarning(title: 'No friendships by 4 years', description: 'If child has no interest in other children, mention to your doctor.', emoji: '👥'),
          MilestoneWarning(title: 'Extreme difficulty with transitions', description: 'May indicate anxiety or sensory processing issues.', emoji: '⚠️'),
        ],
        commonConcerns: [
          CommonConcern(question: 'My child is being bullied at nursery. What should I do?', answer: 'Talk to the nursery staff immediately. Teach child to say "stop, I don\'t like that" and to tell an adult. Build their confidence at home. Monitor closely.'),
        ],
        parentTips: [
          'Arrange regular playdates with the same children.',
          'Model conflict resolution: "Let\'s find a solution that works for both of you."',
          'Praise kindness and empathy specifically.',
        ],
      );

    case MilestoneCategory.feedingSleep:
      return CategoryGuidance(
        category: cat, ageBandIndex: band,
        aboutText: 'Child is eating independently and most are toilet trained. The afternoon nap is dropping for most children. Sleep needs are 10-13 hours per night.',
        milestones: [
          MilestoneItem(id: 'th_fs_1_$band', title: 'Toilet trained day and night', description: 'Dry during the day and mostly at night.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'th_fs_2_$band', title: 'Eating independently', description: 'Uses fork, spoon, and knife with minimal help.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'th_fs_3_$band', title: 'Sleeping 10-13 hours at night', description: 'Consolidated night sleep without nap.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'th_fs_4_$band', title: 'Eating a wide variety of foods', description: 'Accepts most family foods.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
        ],
        activities: [
          MilestoneActivity(title: 'Cooking Together', description: 'Involve child in simple cooking tasks.', emoji: '👨‍🍳', steps: ['Let child wash vegetables.', 'Let them stir, pour, and mix.', 'Name ingredients and talk about nutrition.']),
          MilestoneActivity(title: 'Bedtime Wind-Down', description: 'Create a calming pre-sleep routine.', emoji: '🌙', steps: ['No screens 1 hour before bed.', 'Bath, pyjamas, teeth, book.', 'Lights out at consistent time.']),
        ],
        signsToLookFor: [
          MilestoneSign(title: 'Daytime toilet training complete', description: 'Usually achieved by 3-4 years.', isPositive: true),
          MilestoneSign(title: 'Eating a variety of foods', description: 'Food acceptance improving from toddler years.', isPositive: true),
        ],
        whenToWorry: [
          MilestoneWarning(title: 'Not daytime toilet trained by 4 years', description: 'Consult your doctor if daytime accidents are frequent after 4 years.', emoji: '🚽'),
          MilestoneWarning(title: 'Significant sleep difficulties', description: 'Persistent sleep problems affecting daytime functioning need support.', emoji: '😴'),
        ],
        commonConcerns: [
          CommonConcern(question: 'My child still wets the bed at 4 years. Is that normal?', answer: 'Yes. Nighttime dryness develops later than daytime — often not until 5-7 years. Bedwetting at 4 is completely normal. Lift child before you go to bed and use a waterproof mattress cover.'),
        ],
        parentTips: [
          'Involve child in meal preparation — they\'re more likely to eat it.',
          'No screens at mealtimes — family conversation is important.',
          'Consistent bedtime is the most important sleep factor.',
        ],
      );
  }
}

// ── 5-6 Years ─────────────────────────────────────────────────────────────────

CategoryGuidance _fiveToSixYearsGuidance(int band, MilestoneCategory cat) {
  final label = ageBands[band].label;
  switch (cat) {
    case MilestoneCategory.grossMotor:
      return CategoryGuidance(
        category: cat, ageBandIndex: band,
        aboutText: 'Your child has well-developed gross motor skills and is ready for team sports and structured physical activities. Balance, coordination, and strength are all well established.',
        milestones: [
          MilestoneItem(id: 'fv_gm_1', title: 'Rides a bike without stabilisers', description: 'Balances and pedals independently.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'fv_gm_2', title: 'Skips and hops confidently', description: 'Skips with rhythm and hops on each foot.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'fv_gm_3', title: 'Throws and catches with accuracy', description: 'Throws and catches a ball with aim.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'fv_gm_4', title: 'Participates in team games', description: 'Understands and follows rules of team games.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
        ],
        activities: [
          MilestoneActivity(title: 'Bike Riding', description: 'Practice riding without stabilisers.', emoji: '🚲', steps: ['Remove stabilisers and lower the seat.', 'Hold the back of the seat and run alongside.', 'Gradually let go for longer periods.']),
          MilestoneActivity(title: 'Team Sports', description: 'Introduce simple team sports.', emoji: '⚽', steps: ['Join a local football, cricket, or swimming club.', 'Focus on fun, not competition.', 'Praise effort, not just results.']),
        ],
        signsToLookFor: [
          MilestoneSign(title: 'Riding a bike independently', description: 'Balance and coordination fully developed.', isPositive: true),
          MilestoneSign(title: 'Participating in team games', description: 'Social and physical skills combining.', isPositive: true),
        ],
        whenToWorry: [
          MilestoneWarning(title: 'Very poor coordination affecting daily activities', description: 'May indicate developmental coordination disorder — seek assessment.', emoji: '📋'),
        ],
        commonConcerns: [
          CommonConcern(question: 'How much physical activity does a 5-6 year old need?', answer: 'At least 60 minutes of moderate to vigorous physical activity every day. This can include active play, sports, swimming, or cycling. Limit sitting for more than 2 hours at a time.'),
        ],
        parentTips: [
          'Enrol in a sport or physical activity they enjoy.',
          'Active travel to school (walking, cycling) counts.',
          'Limit screen time to 2 hours per day.',
        ],
      );

    case MilestoneCategory.fineMotor:
      return CategoryGuidance(
        category: cat, ageBandIndex: band,
        aboutText: 'Fine motor skills are school-ready. Child is writing, drawing detailed pictures, and managing all self-care tasks independently.',
        milestones: [
          MilestoneItem(id: 'fv_fm_1', title: 'Writes own name', description: 'Writes first name legibly.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'fv_fm_2', title: 'Draws detailed pictures', description: 'Draws people, houses, and scenes with detail.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'fv_fm_3', title: 'Manages all clothing fasteners', description: 'Buttons, zips, and ties shoes.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'fv_fm_4', title: 'Cuts complex shapes with scissors', description: 'Cuts curves and complex shapes.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
        ],
        activities: [
          MilestoneActivity(title: 'Name Writing Practice', description: 'Practice writing name daily.', emoji: '✏️', steps: ['Write name on a whiteboard.', 'Let child copy it.', 'Progress to writing from memory.']),
          MilestoneActivity(title: 'Shoelace Tying', description: 'Teach shoelace tying step by step.', emoji: '👟', steps: ['Use a large practice lace board.', 'Teach one step at a time.', 'Practise daily — it takes weeks.']),
        ],
        signsToLookFor: [
          MilestoneSign(title: 'Writing name legibly', description: 'School-readiness fine motor milestone.', isPositive: true),
          MilestoneSign(title: 'Managing all self-care independently', description: 'Fine motor and independence well developed.', isPositive: true),
        ],
        whenToWorry: [
          MilestoneWarning(title: 'Can\'t write own name by 6 years', description: 'May indicate fine motor delay — seek occupational therapy.', emoji: '✏️'),
          MilestoneWarning(title: 'Very poor pencil grip', description: 'Incorrect grip at this age may need OT support.', emoji: '✋'),
        ],
        commonConcerns: [
          CommonConcern(question: 'My child can\'t tie their shoelaces. Is that a problem?', answer: 'Shoelace tying is typically mastered between 5-7 years. It requires complex fine motor coordination. Use velcro shoes in the meantime and practise with a lace board.'),
        ],
        parentTips: [
          'Practise writing name daily — short sessions work best.',
          'Provide art supplies for free creative expression.',
          'Let child manage their own clothing — allow extra time.',
        ],
      );

    case MilestoneCategory.language:
      return CategoryGuidance(
        category: cat, ageBandIndex: band,
        aboutText: 'Child is beginning to read and write. They use complex grammar, tell detailed stories, and can hold conversations with adults. Vocabulary is growing rapidly through reading.',
        milestones: [
          MilestoneItem(id: 'fv_la_1', title: 'Beginning to read simple words', description: 'Decodes simple CVC words.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'fv_la_2', title: 'Uses complex grammar', description: 'Uses past tense, plurals, and pronouns correctly.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'fv_la_3', title: 'Tells detailed stories', description: 'Recounts events with beginning, middle, and end.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'fv_la_4', title: 'Vocabulary of 2000+ words', description: 'Large and growing vocabulary.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
        ],
        activities: [
          MilestoneActivity(title: 'Reading Together', description: 'Read together every day.', emoji: '📚', steps: ['Read a book together every day.', 'Let child read simple words they know.', 'Discuss the story: "What do you think will happen?"']),
          MilestoneActivity(title: 'Word Games', description: 'Play word games to build vocabulary.', emoji: '🔤', steps: ['Play "I Spy" with letter sounds.', 'Play rhyming games.', 'Play "20 Questions" to build vocabulary.']),
        ],
        signsToLookFor: [
          MilestoneSign(title: 'Beginning to decode words', description: 'Early reading skills developing.', isPositive: true),
          MilestoneSign(title: 'Using complex sentences', description: 'Grammar and vocabulary well developed.', isPositive: true),
        ],
        whenToWorry: [
          MilestoneWarning(title: 'No interest in letters or reading by 6 years', description: 'May indicate dyslexia or learning difficulties — seek assessment.', emoji: '📖'),
          MilestoneWarning(title: 'Speech still unclear to strangers at 6 years', description: 'Request a speech and language evaluation.', emoji: '🗣️'),
        ],
        commonConcerns: [
          CommonConcern(question: 'My child is struggling to read. Could it be dyslexia?', answer: 'Dyslexia affects 10% of children. Signs include difficulty with phonics, letter reversals beyond age 7, slow reading, and difficulty with rhyming. Request an assessment from school or an educational psychologist.'),
        ],
        parentTips: [
          'Read together every day — it\'s the most important thing.',
          'Visit the library regularly.',
          'Make reading fun — let child choose books they enjoy.',
        ],
      );

    case MilestoneCategory.cognitive:
      return CategoryGuidance(
        category: cat, ageBandIndex: band,
        aboutText: 'Child is developing logical thinking, understanding cause and effect, and beginning formal learning. They can plan, problem-solve, and think about their own thinking.',
        milestones: [
          MilestoneItem(id: 'fv_co_1', title: 'Counts to 20 and beyond', description: 'Counts and understands numbers to 20+.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'fv_co_2', title: 'Understands simple addition', description: 'Can add small numbers with objects.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'fv_co_3', title: 'Understands time concepts', description: 'Understands days of week, morning/afternoon.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'fv_co_4', title: 'Plans and carries out multi-step tasks', description: 'Can plan and complete a project.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
        ],
        activities: [
          MilestoneActivity(title: 'Maths in Daily Life', description: 'Use everyday situations for maths.', emoji: '🔢', steps: ['Count money in a piggy bank.', 'Measure ingredients when cooking.', 'Count steps, cars, birds.']),
          MilestoneActivity(title: 'Simple Projects', description: 'Let child plan and complete a simple project.', emoji: '🎨', steps: ['Suggest making a card for someone.', 'Let child plan what to include.', 'Support but don\'t take over.']),
        ],
        signsToLookFor: [
          MilestoneSign(title: 'Understanding simple addition', description: 'Early maths concepts developing.', isPositive: true),
          MilestoneSign(title: 'Planning multi-step tasks', description: 'Executive function developing.', isPositive: true),
        ],
        whenToWorry: [
          MilestoneWarning(title: 'Not counting to 10 by 6 years', description: 'May indicate maths learning difficulties — seek assessment.', emoji: '🔢'),
        ],
        commonConcerns: [
          CommonConcern(question: 'Should I be doing extra academic work at home?', answer: 'Focus on reading together, maths in daily life, and creative play. Formal academic work at home can create anxiety. School will teach the curriculum — your job is to make learning enjoyable.'),
        ],
        parentTips: [
          'Maths is everywhere — use daily life to teach it.',
          'Encourage curiosity: "I wonder why..."',
          'Let child make decisions and experience consequences.',
        ],
      );

    case MilestoneCategory.social:
      return CategoryGuidance(
        category: cat, ageBandIndex: band,
        aboutText: 'Child has well-developed social skills and is ready for school. They can manage emotions, resolve conflicts, and form meaningful friendships.',
        milestones: [
          MilestoneItem(id: 'fv_so_1', title: 'Has close friendships', description: 'Has 1-2 close friends.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'fv_so_2', title: 'Resolves conflicts verbally', description: 'Uses words to resolve disagreements.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'fv_so_3', title: 'Manages emotions in most situations', description: 'Regulates emotions with occasional support.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'fv_so_4', title: 'Understands others\' perspectives', description: 'Can consider how others feel.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
        ],
        activities: [
          MilestoneActivity(title: 'Conflict Resolution Practice', description: 'Role-play conflict resolution scenarios.', emoji: '🤝', steps: ['Role-play a disagreement scenario.', 'Ask "What could you say instead of hitting?"', 'Practise the words together.']),
          MilestoneActivity(title: 'Perspective Taking', description: 'Discuss how others might feel.', emoji: '💗', steps: ['Read a book with a conflict.', 'Ask "How do you think they feel?"', '"What would you do in their place?"']),
        ],
        signsToLookFor: [
          MilestoneSign(title: 'Close friendships forming', description: 'Meaningful social bonds developing.', isPositive: true),
          MilestoneSign(title: 'Resolving conflicts verbally', description: 'Emotional regulation and language combining.', isPositive: true),
        ],
        whenToWorry: [
          MilestoneWarning(title: 'No friendships at school age', description: 'Persistent social isolation needs evaluation.', emoji: '👥'),
          MilestoneWarning(title: 'Extreme emotional dysregulation', description: 'If child can\'t manage emotions in most situations, seek support.', emoji: '😢'),
        ],
        commonConcerns: [
          CommonConcern(question: 'My child is very shy. Should I be worried?', answer: 'Shyness is a personality trait, not a problem. Help shy children by preparing them for new situations, not forcing interaction, and praising brave behaviour. If shyness is causing significant distress, seek support.'),
        ],
        parentTips: [
          'Model conflict resolution in your own relationships.',
          'Praise specific social behaviours: "I loved how you shared your toy."',
          'Prepare child for school transitions — visit the school beforehand.',
        ],
      );

    case MilestoneCategory.feedingSleep:
      return CategoryGuidance(
        category: cat, ageBandIndex: band,
        aboutText: 'Child is fully independent with eating and sleeping. School routines are establishing consistent sleep and meal patterns. Healthy habits formed now last a lifetime.',
        milestones: [
          MilestoneItem(id: 'fv_fs_1', title: 'Eating independently with good manners', description: 'Uses utensils correctly, sits at table.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'fv_fs_2', title: 'Sleeping 10-11 hours at night', description: 'Consolidated night sleep, no nap needed.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'fv_fs_3', title: 'Eating a wide variety of foods', description: 'Accepts most family foods without fuss.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
          MilestoneItem(id: 'fv_fs_4', title: 'Manages own bedtime routine', description: 'Completes bedtime routine with minimal prompting.', category: cat, status: MilestoneStatus.notStarted, ageRange: label),
        ],
        activities: [
          MilestoneActivity(title: 'Family Meals', description: 'Eat together as a family as often as possible.', emoji: '🍽️', steps: ['Sit together without screens.', 'Talk about the day.', 'Model healthy eating habits.']),
          MilestoneActivity(title: 'Bedtime Responsibility', description: 'Let child manage their own bedtime routine.', emoji: '🌙', steps: ['Create a visual bedtime checklist.', 'Let child tick off each step.', 'Praise independence.']),
        ],
        signsToLookFor: [
          MilestoneSign(title: 'Eating a variety of foods', description: 'Healthy eating habits establishing.', isPositive: true),
          MilestoneSign(title: 'Managing bedtime routine independently', description: 'Self-regulation and independence well developed.', isPositive: true),
        ],
        whenToWorry: [
          MilestoneWarning(title: 'Very restricted diet at 6 years', description: 'If child eats fewer than 20 foods, seek feeding therapy.', emoji: '🍽️'),
          MilestoneWarning(title: 'Significant sleep difficulties affecting school', description: 'Persistent sleep problems need medical evaluation.', emoji: '😴'),
        ],
        commonConcerns: [
          CommonConcern(question: 'My child won\'t eat vegetables. What should I do?', answer: 'Keep offering without pressure. Involve child in choosing and preparing vegetables. Try different preparations — raw vs cooked, different sauces. It can take 15-20 exposures. Don\'t make it a battle.'),
        ],
        parentTips: [
          'Family meals together are the most important nutrition habit.',
          'Consistent bedtime is the most important sleep factor.',
          'Model healthy eating — children eat what they see adults eat.',
        ],
      );
  }
}
