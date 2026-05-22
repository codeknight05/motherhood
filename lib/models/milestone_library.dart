import 'milestone_model.dart';

// ── Library entry point ───────────────────────────────────────────────────────

List<CategoryGuidance> guidanceForAgeBand(int bandIndex) =>
    MilestoneCategory.values.map((cat) => _g(bandIndex, cat)).toList();

CategoryGuidance guidanceForCategory(int bandIndex, MilestoneCategory cat) =>
    _g(bandIndex, cat);

CategoryGuidance enrichGuidance(
  CategoryGuidance guidance,
  Map<String, (MilestoneStatus, String?)> supabaseStatuses,
) {
  final updated = guidance.milestones.map((m) {
    final key = '${m.category.name.toLowerCase()}:${m.title.toLowerCase()}';
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

CategoryGuidance _g(int band, MilestoneCategory cat) {
  switch (band) {
    case 0:
      return _week1(cat);
    case 1:
      return _week2(cat);
    case 2:
      return _week3(cat);
    case 3:
      return _week4(cat);
    case 4:
      return _weeks5to6(cat);
    case 5:
      return _weeks7to8(cat);
    case 6:
      return _month3(cat);
    case 7:
      return _month4(cat);
    case 8:
      return _month5(cat);
    case 9:
      return _month6(cat);
    case 10:
      return _months6to9(cat);
    case 11:
      return _months9to12(cat);
    case 12:
      return _months12to18(cat);
    case 13:
      return _months18to24(cat);
    case 14:
      return _years2to2half(cat);
    case 15:
      return _years2halfto3(cat);
    case 16:
      return _years3to4(cat);
    case 17:
      return _years4to5(cat);
    case 18:
      return _years5to6(cat);
    default:
      return _months6to9(cat);
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

MilestoneItem _m(
  String id,
  String title,
  String desc,
  MilestoneCategory cat,
  String ageRange,
) => MilestoneItem(
  id: id,
  title: title,
  description: desc,
  category: cat,
  status: MilestoneStatus.notStarted,
  ageRange: ageRange,
);

MilestoneActivity _a(
  String title,
  String desc,
  String emoji,
  List<String> steps,
) => MilestoneActivity(
  title: title,
  description: desc,
  emoji: emoji,
  steps: steps,
);

MilestoneSign _pos(String title, String desc) =>
    MilestoneSign(title: title, description: desc, isPositive: true);

MilestoneSign _watch(String title, String desc) =>
    MilestoneSign(title: title, description: desc, isPositive: false);

MilestoneWarning _warn(String title, String desc) =>
    MilestoneWarning(title: title, description: desc, emoji: '⚠️');

CommonConcern _concern(String q, String a) =>
    CommonConcern(question: q, answer: a);

// ── Week 1 ────────────────────────────────────────────────────────────────────

CategoryGuidance _week1(MilestoneCategory cat) {
  const label = '0-1 Weeks';
  switch (cat) {
    case MilestoneCategory.grossMotor:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 0,
        aboutText:
            'Your baby\'s movements are mostly automatic reflexes. Muscle control is still developing.',
        milestones: [
          _m(
            'w1_gm1',
            'Moves arms and legs randomly',
            'Spontaneous limb movements.',
            cat,
            label,
          ),
          _m(
            'w1_gm2',
            'Turns head side to side briefly',
            'Moves head left and right.',
            cat,
            label,
          ),
          _m(
            'w1_gm3',
            'Strong startle (Moro) reflex',
            'Spreads arms when startled.',
            cat,
            label,
          ),
          _m(
            'w1_gm4',
            'Pulls arms and legs inward',
            'Flexes limbs toward body.',
            cat,
            label,
          ),
        ],
        activities: [
          _a(
            'Gentle tummy time on parent\'s chest',
            'Place baby chest-to-chest for brief tummy time.',
            '🤱',
            [
              'Lie back slightly.',
              'Place baby on your chest.',
              'Support their head gently.',
            ],
          ),
          _a(
            'Skin-to-skin contact',
            'Hold baby against bare skin as much as possible.',
            '💗',
            [
              'Remove baby\'s clothing except nappy.',
              'Hold against your bare chest.',
              'Cover with a blanket.',
            ],
          ),
          _a(
            'Slow rocking and cuddling',
            'Gentle rocking soothes and stimulates vestibular development.',
            '🌙',
            [
              'Hold baby securely.',
              'Rock slowly side to side.',
              'Hum or sing softly.',
            ],
          ),
        ],
        signsToLookFor: [
          _pos(
            'Active movement on both sides',
            'Equal movement of both arms and legs.',
          ),
          _pos(
            'Stretching after waking',
            'Natural stretching shows healthy muscle tone.',
          ),
          _pos(
            'Reflexive kicking',
            'Strong leg kicks indicate healthy development.',
          ),
          _watch('Very little movement', 'May indicate low muscle tone.'),
          _watch(
            'Moves one side much less',
            'Asymmetric movement needs evaluation.',
          ),
        ],
        whenToWorry: [
          _warn(
            'Very little movement',
            'Contact doctor if baby shows very little spontaneous movement.',
          ),
          _warn(
            'Extreme stiffness or floppiness',
            'Either extreme may indicate a neurological concern.',
          ),
          _warn(
            'Moves one side much less',
            'Asymmetric movement should be evaluated.',
          ),
        ],
        commonConcerns: [
          _concern(
            'Is sneezing normal in newborns?',
            'Yes. Newborns sneeze frequently to clear their nasal passages. It does not mean they have a cold.',
          ),
          _concern(
            'Are hiccups normal?',
            'Yes. Hiccups are very common in newborns and are not uncomfortable for them.',
          ),
          _concern(
            'Is irregular breathing normal?',
            'Newborns breathe irregularly with occasional pauses. Contact your doctor if pauses last more than 20 seconds.',
          ),
        ],
        parentTips: [
          'Week 1 is mainly about feeding, bonding, recovery, and adjustment.',
          'You do not need to "teach" milestones yet — comfort and connection are enough.',
          'Every baby develops at their own pace.',
        ],
      );
    case MilestoneCategory.fineMotor:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 0,
        aboutText: 'Hand movements are reflexive, not intentional yet.',
        milestones: [
          _m(
            'w1_fm1',
            'Hands mostly clenched',
            'Fists are normal in newborns.',
            cat,
            label,
          ),
          _m(
            'w1_fm2',
            'Grasps finger reflexively',
            'Grips when finger placed in palm.',
            cat,
            label,
          ),
          _m(
            'w1_fm3',
            'Brings hands near face occasionally',
            'Hands move toward face.',
            cat,
            label,
          ),
        ],
        activities: [
          _a(
            'Let baby hold your finger',
            'Place your finger in baby\'s palm to stimulate grasp reflex.',
            '🤝',
            [
              'Offer your finger to baby\'s palm.',
              'Let them grip naturally.',
              'Gently wiggle to stimulate.',
            ],
          ),
          _a(
            'Gentle hand touch and massage',
            'Soft touch stimulates sensory development.',
            '✋',
            [
              'Gently stroke baby\'s hands.',
              'Open fingers softly.',
              'Massage palms in circles.',
            ],
          ),
        ],
        signsToLookFor: [
          _pos('Brief gripping reflex', 'Strong grasp reflex is healthy.'),
          _pos(
            'Opens hands occasionally during sleep',
            'Hands relax during deep sleep.',
          ),
          _watch(
            'No grasp reflex',
            'Absence of grasp reflex needs evaluation.',
          ),
          _watch(
            'Hands always tightly clenched',
            'Persistent tight fists after 3 months needs review.',
          ),
        ],
        whenToWorry: [
          _warn(
            'No grasp reflex',
            'Contact doctor if baby does not grip when finger placed in palm.',
          ),
          _warn(
            'No movement in one arm/hand',
            'Asymmetric arm movement needs evaluation.',
          ),
        ],
        commonConcerns: [
          _concern(
            'My baby\'s hands are always fisted. Is that normal?',
            'Yes, completely normal in the first 2-3 months. The grasp reflex keeps hands closed. They will open more as the reflex fades.',
          ),
        ],
        parentTips: [
          'Avoid mittens when possible so baby can feel and explore with their hands.',
          'Let baby grip your finger during feeds — it\'s bonding and stimulation.',
        ],
      );
    case MilestoneCategory.language:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 0,
        aboutText: 'Crying is your baby\'s primary communication method.',
        milestones: [
          _m(
            'w1_la1',
            'Cries to express hunger/discomfort',
            'Crying is the main communication tool.',
            cat,
            label,
          ),
          _m(
            'w1_la2',
            'Startles to loud sounds',
            'Reacts to sudden loud noises.',
            cat,
            label,
          ),
          _m(
            'w1_la3',
            'Calms to familiar voices',
            'Settles when hearing known voices.',
            cat,
            label,
          ),
        ],
        activities: [
          _a(
            'Talk softly during feeding/changing',
            'Narrate what you are doing.',
            '💬',
            [
              'Describe your actions: "Now I\'m changing your nappy."',
              'Use a warm, calm voice.',
              'Pause and wait — even newborns respond to pauses.',
            ],
          ),
          _a(
            'Sing lullabies',
            'Singing helps baby learn rhythm and language patterns.',
            '🎵',
            [
              'Choose 2-3 simple songs.',
              'Sing them consistently at sleep time.',
              'Baby will begin to recognise and calm to them.',
            ],
          ),
          _a(
            'Respond to cries calmly',
            'Prompt responses build trust and security.',
            '🤱',
            [
              'Respond to cries within a few minutes.',
              'Use a calm, soothing voice.',
              'Try different soothing methods.',
            ],
          ),
        ],
        signsToLookFor: [
          _pos('Reacts to sound', 'Startles or stills when hearing sounds.'),
          _pos(
            'Quiets when comforted',
            'Settles with familiar voice or touch.',
          ),
          _watch(
            'No response to loud sounds',
            'May indicate hearing concerns.',
          ),
          _watch('Very weak cry', 'Weak cry may need medical evaluation.'),
        ],
        whenToWorry: [
          _warn(
            'Very weak cry',
            'Contact doctor if cry is consistently very weak.',
          ),
          _warn(
            'No response to loud sounds',
            'Could indicate hearing issues — request a hearing test.',
          ),
        ],
        commonConcerns: [
          _concern(
            'Should I talk to my newborn even though they don\'t understand?',
            'Absolutely yes. Every word you say builds neural connections. Babies who are talked to more have significantly larger vocabularies by age 2.',
          ),
        ],
        parentTips: [
          'Talk to your baby constantly — narrate your day.',
          'Respond to every sound baby makes — it teaches them communication is two-way.',
          'Read aloud even to a newborn — the rhythm and tone matter.',
        ],
      );
    case MilestoneCategory.cognitive:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 0,
        aboutText:
            'Your baby is beginning to process light, sound, touch, and voices.',
        milestones: [
          _m(
            'w1_co1',
            'Focuses briefly on faces',
            'Can see and focus on faces at close range.',
            cat,
            label,
          ),
          _m(
            'w1_co2',
            'Prefers high-contrast patterns',
            'Shows more interest in black and white patterns.',
            cat,
            label,
          ),
          _m(
            'w1_co3',
            'Recognises caregiver smell/voice',
            'Calms to familiar smell and voice.',
            cat,
            label,
          ),
        ],
        activities: [
          _a(
            'Face-to-face interaction',
            'Hold your face 20-30cm from baby and make slow expressions.',
            '😊',
            [
              'Get close to baby\'s face.',
              'Smile slowly and hold the expression.',
              'Stick out your tongue — baby may imitate!',
            ],
          ),
          _a(
            'Black-and-white visual cards',
            'Show high-contrast patterns to stimulate visual development.',
            '🖤',
            [
              'Hold a high-contrast card 20-30cm away.',
              'Move it slowly side to side.',
              'Watch baby\'s eyes track it.',
            ],
          ),
          _a(
            'Gentle eye contact',
            'Sustained eye contact builds connection and visual development.',
            '👁️',
            [
              'Hold baby at face level.',
              'Make eye contact gently.',
              'Smile and talk softly.',
            ],
          ),
        ],
        signsToLookFor: [
          _pos(
            'Brief visual attention',
            'Stares at faces or high-contrast objects.',
          ),
          _pos(
            'Turns toward familiar voices',
            'Shows recognition of known voices.',
          ),
          _watch('No visual response at all', 'May indicate visual concerns.'),
          _watch(
            'Extremely difficult to wake',
            'Excessive sleepiness may need evaluation.',
          ),
        ],
        whenToWorry: [
          _warn(
            'No visual response at all',
            'Contact doctor if baby shows no response to faces or light.',
          ),
          _warn(
            'Extremely difficult to wake',
            'Difficulty waking for feeds needs medical attention.',
          ),
        ],
        commonConcerns: [
          _concern(
            'My baby stares at the ceiling fan. Is that normal?',
            'Yes! Ceiling fans are high-contrast moving objects — exactly what newborn eyes are drawn to. It\'s great visual stimulation.',
          ),
          _concern(
            'When will my baby recognise me?',
            'Babies recognise their mother\'s face within days of birth. By 2-3 months they will smile specifically at familiar faces.',
          ),
        ],
        parentTips: [
          'Your face is the best toy for a newborn.',
          'Black and white books and cards are great for visual stimulation.',
          'Vary your facial expressions slowly — baby is studying you.',
        ],
      );
    case MilestoneCategory.social:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 0,
        aboutText: 'Bonding and attachment begin immediately after birth.',
        milestones: [
          _m(
            'w1_so1',
            'Calms when held',
            'Settles when picked up and comforted.',
            cat,
            label,
          ),
          _m(
            'w1_so2',
            'Enjoys warmth and closeness',
            'Responds positively to being held.',
            cat,
            label,
          ),
          _m(
            'w1_so3',
            'Begins bonding through touch and voice',
            'Recognises and responds to primary caregiver.',
            cat,
            label,
          ),
        ],
        activities: [
          _a(
            'Skin-to-skin time',
            'Hold baby against your bare chest as much as possible.',
            '🤱',
            [
              'Remove baby\'s clothing except nappy.',
              'Hold against your bare chest.',
              'Cover with a blanket. Aim for 1+ hour daily.',
            ],
          ),
          _a(
            'Holding and cuddling',
            'You cannot hold a newborn too much.',
            '💗',
            [
              'Hold baby in different positions.',
              'Let baby hear your heartbeat.',
              'Respond promptly to cries.',
            ],
          ),
          _a(
            'Calm soothing voice',
            'Your voice is the most powerful soothing tool.',
            '🎵',
            [
              'Speak softly and calmly.',
              'Use baby\'s name often.',
              'Hum or sing during care routines.',
            ],
          ),
        ],
        signsToLookFor: [
          _pos(
            'Settles when comforted',
            'Calms with holding or familiar voice.',
          ),
          _pos(
            'Relaxed during close contact',
            'Body relaxes when held skin-to-skin.',
          ),
          _watch(
            'Baby seems constantly difficult to soothe',
            'Persistent inconsolability may need evaluation.',
          ),
          _watch(
            'Rarely responds to touch or voice',
            'Limited response to comfort needs review.',
          ),
        ],
        whenToWorry: [
          _warn(
            'Baby seems constantly difficult to soothe',
            'If baby is inconsolable for extended periods, rule out medical causes.',
          ),
          _warn(
            'Rarely responds to touch or voice',
            'Contact doctor if baby shows no response to comfort.',
          ),
        ],
        commonConcerns: [
          _concern(
            'Can I spoil a newborn by holding them too much?',
            'No. You cannot spoil a newborn. Responding promptly to their needs builds secure attachment, which leads to more independent children later.',
          ),
          _concern(
            'When will my baby smile at me?',
            'The first social smile usually appears between 6-8 weeks. Before that, smiles are reflexive.',
          ),
        ],
        parentTips: [
          'You cannot hold a newborn too much.',
          'Respond to cries promptly — it builds trust, not dependency.',
          'Skin-to-skin contact regulates baby\'s temperature, heart rate, and stress hormones.',
        ],
      );
    case MilestoneCategory.feedingSleep:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 0,
        aboutText:
            'Your baby is learning feeding patterns and adjusting sleep cycles.',
        milestones: [
          _m(
            'w1_fs1',
            'Feeds every 2–3 hours',
            'Frequent feeding is normal and necessary.',
            cat,
            label,
          ),
          _m(
            'w1_fs2',
            'Sleeps 14–17 hours daily',
            'Most of the day is spent sleeping.',
            cat,
            label,
          ),
          _m(
            'w1_fs3',
            'Wakes frequently for feeding',
            'Night waking for feeds is expected.',
            cat,
            label,
          ),
          _m(
            'w1_fs4',
            'Shows hunger cues before crying',
            'Rooting, sucking fists, turning head.',
            cat,
            label,
          ),
        ],
        activities: [
          _a('Feed on demand', 'Feed whenever baby shows hunger cues.', '🍼', [
            'Watch for rooting (turning head, opening mouth).',
            'Look for sucking on fists or fingers.',
            'Feed when you see these cues — don\'t wait for crying.',
          ]),
          _a(
            'Burp after feeds',
            'Burping reduces discomfort from swallowed air.',
            '🤱',
            [
              'Hold baby upright against your shoulder.',
              'Gently pat or rub their back.',
              'Wait 5-10 minutes after feeding.',
            ],
          ),
          _a(
            'Track wet diapers',
            'Wet diapers confirm adequate feeding.',
            '📊',
            [
              'Aim for 6+ wet diapers per day after day 5.',
              'Note colour and frequency.',
              'Share with your midwife or doctor.',
            ],
          ),
        ],
        signsToLookFor: [
          _pos(
            'Regular feeding interest',
            'Shows hunger cues every 2-3 hours.',
          ),
          _pos(
            'Several wet diapers daily',
            'Good indicator of adequate feeding.',
          ),
          _pos('Periods of alertness', 'Brief awake periods between feeds.'),
          _watch(
            'Feeding less than 8 times in 24 hours',
            'May indicate feeding difficulties.',
          ),
          _watch(
            'Fewer than 6 wet diapers after day 5',
            'May indicate dehydration.',
          ),
        ],
        whenToWorry: [
          _warn(
            'Not regaining birth weight by 2 weeks',
            'Consult your midwife or paediatrician about feeding support.',
          ),
          _warn(
            'Fewer than 6 wet diapers per day after day 5',
            'May indicate dehydration or feeding issues.',
          ),
          _warn(
            'Jaundice worsening after day 5',
            'Seek medical attention promptly.',
          ),
        ],
        commonConcerns: [
          _concern(
            'How do I know if my baby is getting enough milk?',
            'Count wet nappies (6+ per day after day 5), watch for steady weight gain, and look for a satisfied, calm baby after feeds.',
          ),
          _concern(
            'My baby only sleeps when held. Is that okay?',
            'Very normal in the newborn period. Gradually introduce putting baby down drowsy but awake after 6-8 weeks.',
          ),
          _concern(
            'When will my baby sleep longer stretches?',
            'Most babies start sleeping 4-5 hour stretches around 6-8 weeks. Every baby is different.',
          ),
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

// ── Week 2 ────────────────────────────────────────────────────────────────────

CategoryGuidance _week2(MilestoneCategory cat) {
  const label = '1-2 Weeks';
  switch (cat) {
    case MilestoneCategory.grossMotor:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 1,
        aboutText:
            'Your baby is beginning to stretch more and move a little more smoothly.',
        milestones: [
          _m(
            'w2_gm1',
            'Slightly smoother arm and leg movements',
            'Movements becoming less jerky.',
            cat,
            label,
          ),
          _m(
            'w2_gm2',
            'Briefly lifts head during tummy time or chest holding',
            'Short head lifts beginning.',
            cat,
            label,
          ),
          _m(
            'w2_gm3',
            'More active kicking and stretching',
            'Increased spontaneous movement.',
            cat,
            label,
          ),
        ],
        activities: [
          _a(
            'Short tummy time sessions',
            'Place baby on tummy for 1-2 minutes after nappy changes.',
            '🍼',
            [
              'Lay baby on a firm flat surface.',
              'Get down to their level.',
              'Start with 1 minute and increase gradually.',
            ],
          ),
          _a(
            'Skin-to-skin holding',
            'Chest-to-chest contact supports development.',
            '💗',
            [
              'Hold baby against bare chest.',
              'Cover with a blanket.',
              'Aim for 1+ hour daily.',
            ],
          ),
          _a(
            'Gentle movement and cuddling',
            'Slow rocking stimulates vestibular development.',
            '🌙',
            ['Hold baby securely.', 'Rock slowly.', 'Hum or sing softly.'],
          ),
        ],
        signsToLookFor: [
          _pos(
            'Moves both sides of body equally',
            'Symmetric movement is healthy.',
          ),
          _pos(
            'Brief head movement during tummy time',
            'Even a second of lifting counts.',
          ),
          _pos(
            'Strong reflexive kicking',
            'Active legs show healthy muscle tone.',
          ),
          _watch(
            'Very floppy or stiff body',
            'Either extreme may need evaluation.',
          ),
          _watch(
            'Uses one side much less',
            'Asymmetric movement needs review.',
          ),
        ],
        whenToWorry: [
          _warn(
            'Very floppy or stiff body',
            'Contact doctor if muscle tone seems abnormal.',
          ),
          _warn(
            'Very little movement',
            'Minimal spontaneous movement needs evaluation.',
          ),
          _warn(
            'Uses one side much less',
            'Asymmetric movement should be assessed.',
          ),
        ],
        commonConcerns: [
          _concern(
            'Is cluster feeding normal in week 2?',
            'Yes. Cluster feeding (feeding very frequently for several hours) is normal and helps establish milk supply.',
          ),
          _concern(
            'My baby has day/night confusion. What can I do?',
            'Keep daytime bright and active, nighttime calm and dim. This helps reset their circadian rhythm over 2-4 weeks.',
          ),
        ],
        parentTips: [
          'Week 2 is still a huge adjustment period for both baby and parents.',
          'Your baby mainly needs feeding, warmth, comfort, closeness, and responsive care.',
          'Small everyday interactions help development naturally.',
        ],
      );
    case MilestoneCategory.fineMotor:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 1,
        aboutText:
            'Hands remain mostly reflexive, but your baby may briefly relax their fists.',
        milestones: [
          _m(
            'w2_fm1',
            'Opens hands occasionally',
            'Fists begin to relax briefly.',
            cat,
            label,
          ),
          _m(
            'w2_fm2',
            'Grips finger reflexively',
            'Grasps when finger placed in palm.',
            cat,
            label,
          ),
          _m(
            'w2_fm3',
            'Brings hands near face',
            'Hands move toward mouth and face.',
            cat,
            label,
          ),
        ],
        activities: [
          _a(
            'Let baby hold your finger',
            'Stimulates grasp reflex and bonding.',
            '🤝',
            [
              'Offer your finger to baby\'s palm.',
              'Let them grip naturally.',
              'Gently wiggle to stimulate.',
            ],
          ),
          _a(
            'Gentle hand massage',
            'Soft touch stimulates sensory pathways.',
            '✋',
            [
              'Gently stroke baby\'s hands.',
              'Open fingers softly.',
              'Massage palms in circles.',
            ],
          ),
          _a(
            'Soft touch play',
            'Different textures stimulate sensory development.',
            '🧸',
            [
              'Use a soft cloth on baby\'s hands.',
              'Let them feel different textures.',
              'Describe what they are feeling.',
            ],
          ),
        ],
        signsToLookFor: [
          _pos(
            'Brief hand opening',
            'Hands relax occasionally — healthy sign.',
          ),
          _pos('Reflexive gripping', 'Strong grasp reflex present.'),
          _pos('Hands moving near mouth', 'Hand-to-mouth movement developing.'),
          _watch(
            'No grasp reflex',
            'Absence of grasp reflex needs evaluation.',
          ),
          _watch(
            'Hands always tightly clenched',
            'Persistent tight fists after 3 months needs review.',
          ),
        ],
        whenToWorry: [
          _warn(
            'No grasp reflex',
            'Contact doctor if baby does not grip when finger placed in palm.',
          ),
          _warn(
            'No movement in one hand/arm',
            'Asymmetric arm movement needs evaluation.',
          ),
        ],
        commonConcerns: [
          _concern(
            'My baby keeps sucking their fists. Is that hunger?',
            'Not always. Hand-sucking is also self-soothing and exploration. Watch for other hunger cues to distinguish.',
          ),
        ],
        parentTips: [
          'Avoid mittens so baby can explore with their hands.',
          'Let baby grip your finger during feeds — it\'s bonding and stimulation.',
        ],
      );
    case MilestoneCategory.language:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 1,
        aboutText:
            'Your baby is becoming more familiar with voices and sounds.',
        milestones: [
          _m(
            'w2_la1',
            'Cries differently for different needs',
            'Different cries for hunger vs discomfort.',
            cat,
            label,
          ),
          _m(
            'w2_la2',
            'Startles to loud sounds',
            'Reacts to sudden loud noises.',
            cat,
            label,
          ),
          _m(
            'w2_la3',
            'Calms with familiar voices',
            'Settles when hearing known voices.',
            cat,
            label,
          ),
        ],
        activities: [
          _a(
            'Talk softly during feeds',
            'Narrate feeding and care routines.',
            '💬',
            [
              'Describe what you are doing.',
              'Use a warm, calm voice.',
              'Pause and wait for baby\'s response.',
            ],
          ),
          _a(
            'Sing lullabies',
            'Consistent songs build familiarity and calm.',
            '🎵',
            [
              'Choose 2-3 simple songs.',
              'Sing at sleep time consistently.',
              'Baby will begin to recognise them.',
            ],
          ),
          _a('Respond calmly to cries', 'Prompt responses build trust.', '🤱', [
            'Respond within a few minutes.',
            'Use a calm, soothing voice.',
            'Try different soothing methods.',
          ]),
        ],
        signsToLookFor: [
          _pos(
            'Reacts to sudden sounds',
            'Startles or stills when hearing sounds.',
          ),
          _pos(
            'Quiets when hearing caregiver voice',
            'Recognises and responds to familiar voice.',
          ),
          _watch(
            'No response to loud sounds',
            'May indicate hearing concerns.',
          ),
          _watch(
            'Constant inconsolable crying',
            'Persistent crying may need medical evaluation.',
          ),
        ],
        whenToWorry: [
          _warn(
            'No response to loud sounds',
            'Could indicate hearing issues — request a hearing test.',
          ),
          _warn(
            'Very weak cry',
            'Consistently weak cry needs medical evaluation.',
          ),
          _warn(
            'Constant inconsolable crying',
            'Persistent inconsolability may indicate colic or medical issue.',
          ),
        ],
        commonConcerns: [
          _concern(
            'How do I tell the difference between hunger and pain cries?',
            'Hunger cries are rhythmic and build gradually. Pain cries are sudden, high-pitched, and intense. You will learn your baby\'s cues over time.',
          ),
        ],
        parentTips: [
          'Talk to your baby constantly — narrate your day.',
          'Respond to every sound baby makes — it teaches them communication is two-way.',
        ],
      );
    case MilestoneCategory.cognitive:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 1,
        aboutText: 'Your baby is slowly becoming more aware of surroundings.',
        milestones: [
          _m(
            'w2_co1',
            'Watches faces briefly',
            'Focuses on faces at close range.',
            cat,
            label,
          ),
          _m(
            'w2_co2',
            'Notices bright light and movement',
            'Responds to visual stimulation.',
            cat,
            label,
          ),
          _m(
            'w2_co3',
            'Prefers high-contrast patterns',
            'Shows interest in black and white.',
            cat,
            label,
          ),
        ],
        activities:
            [
              _a(
                'Face-to-face interaction',
                'Hold your face 20-30cm from baby.',
                '😊',
                [
                  'Get close to baby\'s face.',
                  'Smile slowly.',
                  'Make gentle expressions.',
                ],
              ),
              _a(
                'Show black-and-white cards',
                'High-contrast patterns stimulate visual development.',
                '🖤',
                [
                  'Hold card 20-30cm away.',
                  'Move it slowly.',
                  'Watch baby\'s eyes track it.',
                ],
              ),
              _a(
                'Gentle eye contact',
                'Sustained eye contact builds connection.',
                '👁️',
                [
                  'Hold baby at face level.',
                  'Make eye contact gently.',
                  'Smile and talk softly.',
                ],
              ),
            ],
        signsToLookFor: [
          _pos('Brief focus on faces', 'Stares at faces at close range.'),
          _pos(
            'Tracks movement slightly',
            'Eyes follow slow movement briefly.',
          ),
          _watch('No visual attention', 'May indicate visual concerns.'),
          _watch(
            'Extremely difficult to wake',
            'Excessive sleepiness may need evaluation.',
          ),
        ],
        whenToWorry: [
          _warn(
            'No visual attention',
            'Contact doctor if baby shows no response to faces or light.',
          ),
          _warn(
            'No reaction to surroundings',
            'Lack of any environmental awareness needs evaluation.',
          ),
        ],
        commonConcerns: [
          _concern(
            'My baby\'s eyes cross sometimes. Is that normal?',
            'Occasional eye crossing is normal in the first 2-3 months. Persistent crossing after 3 months needs evaluation.',
          ),
        ],
        parentTips: [
          'Your face is still the best toy.',
          'Change baby\'s environment — different rooms, outdoors, different positions.',
        ],
      );
    case MilestoneCategory.social:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 1,
        aboutText: 'Your baby continues building trust and attachment.',
        milestones: [
          _m(
            'w2_so1',
            'Calms when held',
            'Settles when picked up and comforted.',
            cat,
            label,
          ),
          _m(
            'w2_so2',
            'Enjoys warmth and closeness',
            'Responds positively to being held.',
            cat,
            label,
          ),
          _m(
            'w2_so3',
            'Begins recognising caregiver voice and smell',
            'Shows preference for primary caregiver.',
            cat,
            label,
          ),
        ],
        activities: [
          _a(
            'Skin-to-skin contact',
            'Hold baby against bare skin as much as possible.',
            '🤱',
            [
              'Remove baby\'s clothing except nappy.',
              'Hold against your bare chest.',
              'Cover with a blanket.',
            ],
          ),
          _a(
            'Holding and cuddling',
            'You cannot hold a newborn too much.',
            '💗',
            [
              'Hold baby in different positions.',
              'Let baby hear your heartbeat.',
              'Respond promptly to cries.',
            ],
          ),
          _a('Gentle soothing', 'Consistent soothing builds security.', '🌙', [
            'Use a calm voice.',
            'Try gentle rocking.',
            'Offer skin-to-skin if distressed.',
          ]),
        ],
        signsToLookFor: [
          _pos(
            'Settles when comforted',
            'Calms with holding or familiar voice.',
          ),
          _pos('Relaxed during cuddling', 'Body relaxes when held.'),
          _watch(
            'Rarely calms when comforted',
            'Persistent difficulty settling needs evaluation.',
          ),
          _watch(
            'No response to touch or voice',
            'Limited response to comfort needs review.',
          ),
        ],
        whenToWorry: [
          _warn(
            'Rarely calms when comforted',
            'If baby is consistently inconsolable, rule out medical causes.',
          ),
          _warn(
            'No response to touch or voice',
            'Contact doctor if baby shows no response to comfort.',
          ),
        ],
        commonConcerns: [
          _concern(
            'Is it normal to feel overwhelmed in week 2?',
            'Completely normal. Week 2 is often harder than week 1 as the adrenaline wears off. Reach out for support — you are not alone.',
          ),
        ],
        parentTips: [
          'You cannot hold a newborn too much.',
          'Respond to cries promptly — it builds trust, not dependency.',
          'Small everyday interactions are already helping your baby grow and feel safe.',
        ],
      );
    case MilestoneCategory.feedingSleep:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 1,
        aboutText:
            'Feeding and sleeping patterns are still irregular but may begin feeling slightly more predictable.',
        milestones: [
          _m(
            'w2_fs1',
            'Feeds every 2–3 hours',
            'Frequent feeding continues.',
            cat,
            label,
          ),
          _m(
            'w2_fs2',
            'Sleeps most of the day',
            'Newborns sleep 14-17 hours daily.',
            cat,
            label,
          ),
          _m(
            'w2_fs3',
            'May have slightly longer awake periods',
            'Brief alert periods between feeds.',
            cat,
            label,
          ),
        ],
        activities: [
          _a('Feed on demand', 'Feed whenever baby shows hunger cues.', '🍼', [
            'Watch for rooting and sucking cues.',
            'Feed before crying starts.',
            'Let baby feed until satisfied.',
          ]),
          _a(
            'Burp after feeding',
            'Reduces discomfort from swallowed air.',
            '🤱',
            [
              'Hold baby upright.',
              'Gently pat or rub back.',
              'Wait 5-10 minutes after feeding.',
            ],
          ),
          _a(
            'Create calm sleep environment',
            'Consistent sleep environment helps regulation.',
            '😴',
            [
              'Keep room temperature comfortable.',
              'Use white noise if helpful.',
              'Keep nighttime calm and dim.',
            ],
          ),
        ],
        signsToLookFor: [
          _pos('Regular wet diapers', '6+ wet diapers per day after day 5.'),
          _pos('Feeding interest', 'Shows hunger cues regularly.'),
          _pos('Wakes for feeds', 'Wakes independently when hungry.'),
          _watch(
            'Poor feeding',
            'Difficulty latching or feeding needs support.',
          ),
          _watch('Fewer wet diapers', 'May indicate inadequate feeding.'),
        ],
        whenToWorry: [
          _warn(
            'Poor feeding',
            'Contact lactation consultant or doctor if feeding is difficult.',
          ),
          _warn(
            'Fewer wet diapers',
            'Fewer than 6 wet diapers after day 5 needs evaluation.',
          ),
          _warn(
            'Excessive sleepiness',
            'Difficulty waking for feeds needs medical attention.',
          ),
        ],
        commonConcerns: [
          _concern(
            'Is gas normal in week 2?',
            'Yes. Newborns swallow air during feeding and have immature digestive systems. Burping after feeds and gentle tummy massage can help.',
          ),
          _concern(
            'My baby has day/night confusion. What can I do?',
            'Keep daytime bright and active, nighttime calm and dim. This helps reset their circadian rhythm over 2-4 weeks.',
          ),
        ],
        parentTips: [
          'Feed on demand — there is no schedule yet.',
          'Always place baby on their back to sleep.',
          'Cluster feeding is normal and temporary.',
        ],
      );
  }
}

// ── Week 3 ────────────────────────────────────────────────────────────────────

CategoryGuidance _week3(MilestoneCategory cat) {
  const label = '2-3 Weeks';
  switch (cat) {
    case MilestoneCategory.grossMotor:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 2,
        aboutText:
            'Your baby\'s body movements are becoming a little smoother and more active.',
        milestones: [
          _m(
            'w3_gm1',
            'Better head turning side to side',
            'More controlled head movement.',
            cat,
            label,
          ),
          _m(
            'w3_gm2',
            'More stretching and kicking',
            'Increased spontaneous movement.',
            cat,
            label,
          ),
          _m(
            'w3_gm3',
            'Brief head lifting during tummy time',
            'Short head lifts beginning.',
            cat,
            label,
          ),
          _m(
            'w3_gm4',
            'Increased arm and leg movement',
            'More active limb movement.',
            cat,
            label,
          ),
        ],
        activities: [
          _a(
            'Short tummy time sessions',
            '1-2 minutes after nappy changes.',
            '🍼',
            [
              'Lay baby on firm surface.',
              'Get down to their level.',
              'Increase time gradually.',
            ],
          ),
          _a(
            'Chest-to-chest holding',
            'Supports head control development.',
            '🤱',
            [
              'Hold baby chest-to-chest.',
              'Support their head.',
              'Talk softly.',
            ],
          ),
          _a('Gentle movement play', 'Slow rocking and movement.', '🌙', [
            'Hold baby securely.',
            'Rock slowly.',
            'Hum softly.',
          ]),
        ],
        signsToLookFor: [
          _pos('Moves both sides equally', 'Symmetric movement is healthy.'),
          _pos('Stronger kicking motions', 'Active legs show healthy tone.'),
          _watch('Very little movement', 'May indicate low muscle tone.'),
          _watch(
            'Extreme stiffness or floppiness',
            'Either extreme needs evaluation.',
          ),
        ],
        whenToWorry: [
          _warn(
            'Very little movement',
            'Contact doctor if very little spontaneous movement.',
          ),
          _warn(
            'Extreme stiffness or floppiness',
            'Either extreme may indicate neurological concern.',
          ),
          _warn(
            'Moves one side much less',
            'Asymmetric movement should be assessed.',
          ),
        ],
        commonConcerns: [
          _concern(
            'Is evening fussiness normal in week 3?',
            'Yes. Many babies have a fussy period in the evening (often called "the witching hour"). It typically peaks around 6 weeks and improves by 3-4 months.',
          ),
        ],
        parentTips: [
          'Week 3 can feel tiring and emotional for many parents.',
          'Your baby still mainly needs feeding, closeness, comfort, responsive care, and rest.',
          'Small everyday interactions are already helping your baby grow and feel safe.',
        ],
      );
    case MilestoneCategory.fineMotor:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 2,
        aboutText:
            'Your baby is beginning to explore hand movements more often.',
        milestones: [
          _m(
            'w3_fm1',
            'Brings hands near mouth',
            'Hand-to-mouth movement developing.',
            cat,
            label,
          ),
          _m(
            'w3_fm2',
            'Opens hands briefly',
            'Fists begin to relax.',
            cat,
            label,
          ),
          _m(
            'w3_fm3',
            'Reflexive grasp continues',
            'Grasps when finger placed in palm.',
            cat,
            label,
          ),
          _m(
            'w3_fm4',
            'Hands move around face more frequently',
            'Increased hand-face movement.',
            cat,
            label,
          ),
        ],
        activities: [
          _a('Let baby grasp your finger', 'Stimulates grasp reflex.', '🤝', [
            'Offer finger to palm.',
            'Let them grip naturally.',
            'Gently wiggle.',
          ]),
          _a(
            'Gentle hand touch and massage',
            'Stimulates sensory pathways.',
            '✋',
            [
              'Stroke baby\'s hands gently.',
              'Open fingers softly.',
              'Massage palms.',
            ],
          ),
          _a(
            'Soft sensory textures',
            'Different textures stimulate development.',
            '🧸',
            [
              'Use soft cloth on hands.',
              'Let them feel textures.',
              'Describe what they feel.',
            ],
          ),
        ],
        signsToLookFor: [
          _pos('Reflexive gripping', 'Strong grasp reflex present.'),
          _pos('Hand movement toward mouth', 'Hand-to-mouth developing.'),
          _pos('Occasional relaxed hands', 'Hands relax briefly.'),
          _watch('No grasp reflex', 'Absence needs evaluation.'),
          _watch(
            'Hands always tightly clenched',
            'Persistent tight fists needs review.',
          ),
        ],
        whenToWorry: [
          _warn(
            'No grasp reflex',
            'Contact doctor if no grip when finger placed in palm.',
          ),
          _warn(
            'No arm/hand movement',
            'Asymmetric movement needs evaluation.',
          ),
        ],
        commonConcerns: [
          _concern(
            'My baby scratches their face. What should I do?',
            'Keep nails trimmed short with baby nail scissors or a file. You can also file them while baby sleeps.',
          ),
        ],
        parentTips: [
          'Avoid mittens so baby can explore with their hands.',
          'Let baby grip your finger during feeds.',
        ],
      );
    case MilestoneCategory.language:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 2,
        aboutText:
            'Your baby is becoming more familiar with voices and sounds.',
        milestones: [
          _m(
            'w3_la1',
            'Cries differently for different needs',
            'Different cries for hunger vs discomfort.',
            cat,
            label,
          ),
          _m(
            'w3_la2',
            'Quiets to familiar voices',
            'Settles when hearing known voices.',
            cat,
            label,
          ),
          _m(
            'w3_la3',
            'May make small cooing sounds',
            'First vowel-like sounds beginning.',
            cat,
            label,
          ),
          _m(
            'w3_la4',
            'Startles to loud noises',
            'Reacts to sudden sounds.',
            cat,
            label,
          ),
        ],
        activities: [
          _a('Talk during feeding/changing', 'Narrate care routines.', '💬', [
            'Describe what you are doing.',
            'Use a warm voice.',
            'Pause and wait.',
          ]),
          _a('Sing lullabies', 'Consistent songs build familiarity.', '🎵', [
            'Choose 2-3 simple songs.',
            'Sing at sleep time.',
            'Baby will recognise them.',
          ]),
          _a(
            'Respond calmly to crying',
            'Prompt responses build trust.',
            '🤱',
            [
              'Respond within a few minutes.',
              'Use a calm voice.',
              'Try different soothing methods.',
            ],
          ),
        ],
        signsToLookFor: [
          _pos('Reacts to sound', 'Startles or stills when hearing sounds.'),
          _pos(
            'Calms when hearing caregiver voice',
            'Recognises familiar voice.',
          ),
          _pos(
            'Watches your mouth while speaking',
            'Shows interest in communication.',
          ),
          _watch(
            'No response to loud sounds',
            'May indicate hearing concerns.',
          ),
          _watch('No reaction to voices', 'Limited response needs review.'),
        ],
        whenToWorry: [
          _warn('No response to loud sounds', 'Could indicate hearing issues.'),
          _warn('Very weak cry', 'Consistently weak cry needs evaluation.'),
        ],
        commonConcerns: [
          _concern(
            'When will my baby start cooing?',
            'Most babies begin cooing between 6-8 weeks. Some start as early as 3-4 weeks. Every baby is different.',
          ),
        ],
        parentTips: [
          'Talk to your baby constantly.',
          'Respond to every sound baby makes.',
          'Read aloud even to a newborn.',
        ],
      );
    case MilestoneCategory.cognitive:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 2,
        aboutText: 'Your baby is slowly becoming more aware of surroundings.',
        milestones: [
          _m(
            'w3_co1',
            'Watches faces longer',
            'Increased visual attention to faces.',
            cat,
            label,
          ),
          _m(
            'w3_co2',
            'Briefly tracks movement',
            'Eyes follow slow movement.',
            cat,
            label,
          ),
          _m(
            'w3_co3',
            'Notices bright lights and patterns',
            'Responds to visual stimulation.',
            cat,
            label,
          ),
          _m(
            'w3_co4',
            'Becomes more alert during awake periods',
            'Longer alert windows.',
            cat,
            label,
          ),
        ],
        activities: [
          _a('Face-to-face interaction', 'Hold face 20-30cm from baby.', '😊', [
            'Get close to baby\'s face.',
            'Smile slowly.',
            'Make gentle expressions.',
          ]),
          _a(
            'High-contrast visual cards',
            'Stimulate visual development.',
            '🖤',
            [
              'Hold card 20-30cm away.',
              'Move it slowly.',
              'Watch baby\'s eyes.',
            ],
          ),
          _a(
            'Gentle eye contact',
            'Builds connection and visual development.',
            '👁️',
            [
              'Hold baby at face level.',
              'Make eye contact.',
              'Smile and talk softly.',
            ],
          ),
        ],
        signsToLookFor: [
          _pos('Brief visual focus', 'Stares at faces or objects.'),
          _pos('Tracks nearby movement slightly', 'Eyes follow slow movement.'),
          _pos('Watches faces during interaction', 'Shows social interest.'),
          _watch('No visual attention', 'May indicate visual concerns.'),
          _watch(
            'No reaction to surroundings',
            'Lack of awareness needs evaluation.',
          ),
        ],
        whenToWorry: [
          _warn(
            'No visual attention',
            'Contact doctor if no response to faces or light.',
          ),
          _warn(
            'Extremely difficult to wake',
            'Difficulty waking for feeds needs attention.',
          ),
        ],
        commonConcerns: [
          _concern(
            'My baby seems more alert at night. Is that normal?',
            'Yes. Day/night confusion is very common in the first 4-6 weeks. Keep daytime bright and active, nighttime calm and dim.',
          ),
        ],
        parentTips: [
          'Your face is still the best toy.',
          'Change baby\'s environment regularly.',
          'Respond consistently to baby\'s cues.',
        ],
      );
    case MilestoneCategory.social:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 2,
        aboutText:
            'Your baby is continuing to build emotional attachment and trust.',
        milestones: [
          _m(
            'w3_so1',
            'Calms when held',
            'Settles when picked up.',
            cat,
            label,
          ),
          _m(
            'w3_so2',
            'Enjoys closeness and cuddling',
            'Responds positively to being held.',
            cat,
            label,
          ),
          _m(
            'w3_so3',
            'May appear more relaxed with familiar caregivers',
            'Shows preference for known people.',
            cat,
            label,
          ),
          _m(
            'w3_so4',
            'Starts showing quiet alert engagement',
            'Brief periods of calm alertness.',
            cat,
            label,
          ),
        ],
        activities: [
          _a('Skin-to-skin contact', 'Hold baby against bare skin.', '🤱', [
            'Remove baby\'s clothing except nappy.',
            'Hold against bare chest.',
            'Cover with a blanket.',
          ]),
          _a('Cuddling', 'Consistent holding builds security.', '💗', [
            'Hold baby in different positions.',
            'Let baby hear your heartbeat.',
            'Respond promptly to cries.',
          ]),
          _a(
            'Gentle soothing and rocking',
            'Calm soothing builds trust.',
            '🌙',
            [
              'Use a calm voice.',
              'Try gentle rocking.',
              'Offer skin-to-skin if distressed.',
            ],
          ),
        ],
        signsToLookFor: [
          _pos('Settles when comforted', 'Calms with holding or voice.'),
          _pos('Relaxed during holding', 'Body relaxes when held.'),
          _pos('Watches caregiver face calmly', 'Shows social interest.'),
          _watch(
            'Rarely calms when comforted',
            'Persistent difficulty settling needs evaluation.',
          ),
          _watch(
            'No response to touch or voice',
            'Limited response needs review.',
          ),
        ],
        whenToWorry: [
          _warn(
            'Rarely calms when comforted',
            'If consistently inconsolable, rule out medical causes.',
          ),
          _warn(
            'No response to touch or voice',
            'Contact doctor if no response to comfort.',
          ),
        ],
        commonConcerns: [
          _concern(
            'I feel like I don\'t know what my baby wants. Is that normal?',
            'Completely normal. Learning your baby\'s cues takes time. Most parents feel more confident by 6-8 weeks.',
          ),
        ],
        parentTips: [
          'You cannot hold a newborn too much.',
          'Respond to cries promptly.',
          'Small everyday interactions are already helping your baby grow and feel safe.',
        ],
      );
    case MilestoneCategory.feedingSleep:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 2,
        aboutText:
            'Feeding and sleep patterns are still developing, but some babies may begin showing slightly more predictable routines.',
        milestones: [
          _m(
            'w3_fs1',
            'Feeds every 2–3 hours',
            'Frequent feeding continues.',
            cat,
            label,
          ),
          _m(
            'w3_fs2',
            'Cluster feeding still common',
            'Frequent feeds in the evening.',
            cat,
            label,
          ),
          _m(
            'w3_fs3',
            'Sleeps most of the day',
            '14-17 hours daily.',
            cat,
            label,
          ),
          _m(
            'w3_fs4',
            'Slightly longer awake windows',
            'Brief alert periods between feeds.',
            cat,
            label,
          ),
        ],
        activities: [
          _a('Feed on demand', 'Feed whenever baby shows hunger cues.', '🍼', [
            'Watch for rooting and sucking cues.',
            'Feed before crying starts.',
            'Let baby feed until satisfied.',
          ]),
          _a(
            'Burp after feeds',
            'Reduces discomfort from swallowed air.',
            '🤱',
            [
              'Hold baby upright.',
              'Gently pat or rub back.',
              'Wait 5-10 minutes.',
            ],
          ),
          _a(
            'Keep nighttime calm and dim',
            'Helps establish day/night difference.',
            '😴',
            [
              'Keep nighttime feeds quiet.',
              'Avoid bright lights at night.',
              'Keep interaction minimal at night.',
            ],
          ),
        ],
        signsToLookFor: [
          _pos('Regular wet diapers', '6+ wet diapers per day.'),
          _pos('Feeding interest', 'Shows hunger cues regularly.'),
          _pos('Wakes for feeds', 'Wakes independently when hungry.'),
          _pos('Calm periods after feeding', 'Settles after feeds.'),
          _watch('Poor feeding', 'Difficulty feeding needs support.'),
          _watch('Fewer wet diapers', 'May indicate inadequate feeding.'),
        ],
        whenToWorry: [
          _warn('Poor feeding', 'Contact lactation consultant or doctor.'),
          _warn(
            'Fewer wet diapers',
            'Fewer than 6 wet diapers needs evaluation.',
          ),
          _warn(
            'Excessive sleepiness',
            'Difficulty waking for feeds needs attention.',
          ),
        ],
        commonConcerns: [
          _concern(
            'Is gas normal in week 3?',
            'Yes. Newborns have immature digestive systems. Burping after feeds and gentle tummy massage can help.',
          ),
          _concern(
            'My baby has hiccups constantly. Is that normal?',
            'Yes. Hiccups are very common in newborns and are not uncomfortable for them.',
          ),
        ],
        parentTips: [
          'Feed on demand — there is no schedule yet.',
          'Always place baby on their back to sleep.',
          'Cluster feeding is normal and temporary.',
        ],
      );
  }
}

// ── Week 4 ────────────────────────────────────────────────────────────────────

CategoryGuidance _week4(MilestoneCategory cat) {
  const label = '3-4 Weeks';
  switch (cat) {
    case MilestoneCategory.grossMotor:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 3,
        aboutText:
            'Your baby is gradually building neck and upper body strength.',
        milestones: [
          _m(
            'w4_gm1',
            'Briefly lifts head during tummy time',
            'Short head lifts during tummy time.',
            cat,
            label,
          ),
          _m(
            'w4_gm2',
            'Turns head side to side more smoothly',
            'More controlled head movement.',
            cat,
            label,
          ),
          _m(
            'w4_gm3',
            'More active stretching and kicking',
            'Increased spontaneous movement.',
            cat,
            label,
          ),
          _m(
            'w4_gm4',
            'Smoother arm and leg movements',
            'Less jerky movements.',
            cat,
            label,
          ),
        ],
        activities: [
          _a('Daily tummy time', 'Increase to 2-3 minutes per session.', '🍼', [
            'Lay baby on firm surface.',
            'Get down to their level.',
            'Increase time gradually.',
          ]),
          _a('Chest-to-chest holding', 'Supports head control.', '🤱', [
            'Hold baby chest-to-chest.',
            'Support their head.',
            'Talk softly.',
          ]),
          _a('Gentle bicycle leg movements', 'Stimulates leg strength.', '🚲', [
            'Lay baby on back.',
            'Gently cycle their legs.',
            'Repeat 5-10 times.',
          ]),
          _a(
            'Face tracking during interaction',
            'Encourages visual tracking.',
            '😊',
            [
              'Hold face 20-30cm away.',
              'Move slowly side to side.',
              'Watch baby\'s eyes follow.',
            ],
          ),
        ],
        signsToLookFor: [
          _pos('Brief head lifting', 'Even a second of lifting counts.'),
          _pos(
            'Active movement on both sides',
            'Symmetric movement is healthy.',
          ),
          _pos(
            'Strong kicking and stretching',
            'Active legs show healthy tone.',
          ),
          _watch(
            'Very floppy or stiff body',
            'Either extreme needs evaluation.',
          ),
          _watch('Little movement', 'Minimal movement needs review.'),
        ],
        whenToWorry: [
          _warn(
            'Very floppy or stiff body',
            'Contact doctor if muscle tone seems abnormal.',
          ),
          _warn(
            'Little movement',
            'Minimal spontaneous movement needs evaluation.',
          ),
          _warn(
            'Moves one side much less',
            'Asymmetric movement should be assessed.',
          ),
        ],
        commonConcerns: [
          _concern(
            'My baby has baby acne. Is that normal?',
            'Yes. Baby acne typically appears around 2-4 weeks and clears on its own by 3-4 months. No treatment needed — just gentle cleansing.',
          ),
        ],
        parentTips: [
          'Your baby is still very new to the world.',
          'At this stage, the most important things are feeding, comfort, closeness, rest, and responsive care.',
          'You and your baby are learning together every day.',
        ],
      );
    case MilestoneCategory.fineMotor:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 3,
        aboutText: 'Your baby is becoming more aware of hands and touch.',
        milestones: [
          _m(
            'w4_fm1',
            'Opens hands more often',
            'Fists relax more frequently.',
            cat,
            label,
          ),
          _m(
            'w4_fm2',
            'Brings hands near mouth',
            'Hand-to-mouth movement developing.',
            cat,
            label,
          ),
          _m(
            'w4_fm3',
            'Reflexive grasp still present',
            'Grasps when finger placed in palm.',
            cat,
            label,
          ),
          _m(
            'w4_fm4',
            'Begins batting at nearby objects accidentally',
            'Accidental swiping at objects.',
            cat,
            label,
          ),
        ],
        activities: [
          _a('Finger grasp play', 'Stimulates grasp reflex.', '🤝', [
            'Offer finger to palm.',
            'Let them grip naturally.',
            'Gently wiggle.',
          ]),
          _a(
            'Gentle sensory touch',
            'Different textures stimulate development.',
            '✋',
            [
              'Use soft cloth on hands.',
              'Let them feel textures.',
              'Describe what they feel.',
            ],
          ),
          _a(
            'Soft rattles or textured toys',
            'Introduce simple sensory toys.',
            '🪀',
            [
              'Place rattle in baby\'s hand.',
              'Let them feel the texture.',
              'React with excitement.',
            ],
          ),
        ],
        signsToLookFor: [
          _pos('Brief relaxed hands', 'Hands relax occasionally.'),
          _pos('Grasp reflex', 'Strong grasp reflex present.'),
          _pos(
            'Hand movement toward face',
            'Hand-to-face movement developing.',
          ),
          _watch('No grasp reflex', 'Absence needs evaluation.'),
          _watch(
            'No arm or hand movement',
            'Asymmetric movement needs evaluation.',
          ),
        ],
        whenToWorry: [
          _warn(
            'No grasp reflex',
            'Contact doctor if no grip when finger placed in palm.',
          ),
          _warn(
            'No arm or hand movement',
            'Asymmetric movement needs evaluation.',
          ),
        ],
        commonConcerns: [
          _concern(
            'My baby keeps hitting themselves in the face. Is that normal?',
            'Yes. Newborns have limited motor control and often accidentally hit their own face. This is normal and improves as motor control develops.',
          ),
        ],
        parentTips: [
          'Avoid mittens so baby can explore with their hands.',
          'Let baby grip your finger during feeds.',
        ],
      );
    case MilestoneCategory.language:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 3,
        aboutText:
            'Your baby is beginning early communication through sounds and facial expressions.',
        milestones: [
          _m(
            'w4_la1',
            'Cries differently for needs',
            'Different cries for different needs.',
            cat,
            label,
          ),
          _m(
            'w4_la2',
            'May make small cooing sounds',
            'First vowel-like sounds.',
            cat,
            label,
          ),
          _m(
            'w4_la3',
            'Responds to familiar voices',
            'Calms or turns toward known voices.',
            cat,
            label,
          ),
          _m(
            'w4_la4',
            'Startles to loud noises',
            'Reacts to sudden sounds.',
            cat,
            label,
          ),
        ],
        activities: [
          _a(
            'Talk during feeds and diaper changes',
            'Narrate care routines.',
            '💬',
            [
              'Describe what you are doing.',
              'Use a warm voice.',
              'Pause and wait.',
            ],
          ),
          _a('Sing lullabies', 'Consistent songs build familiarity.', '🎵', [
            'Choose 2-3 simple songs.',
            'Sing at sleep time.',
            'Baby will recognise them.',
          ]),
          _a(
            'Smile while speaking to baby',
            'Facial expressions teach communication.',
            '😊',
            ['Make eye contact.', 'Smile and talk.', 'Exaggerate expressions.'],
          ),
        ],
        signsToLookFor: [
          _pos('Reacts to sounds', 'Startles or stills when hearing sounds.'),
          _pos(
            'Watches caregiver face while speaking',
            'Shows interest in communication.',
          ),
          _pos(
            'Quiets to familiar voices',
            'Recognises and responds to known voices.',
          ),
          _watch('No sound response', 'May indicate hearing concerns.'),
          _watch('Weak cry', 'Consistently weak cry needs evaluation.'),
        ],
        whenToWorry: [
          _warn('No sound response', 'Could indicate hearing issues.'),
          _warn('Weak cry', 'Consistently weak cry needs medical evaluation.'),
        ],
        commonConcerns: [
          _concern(
            'When will my baby start smiling?',
            'The first social smile usually appears between 6-8 weeks. Before that, smiles are reflexive.',
          ),
        ],
        parentTips: [
          'Talk to your baby constantly.',
          'Respond to every sound baby makes.',
          'Read aloud even to a newborn.',
        ],
      );
    case MilestoneCategory.cognitive:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 3,
        aboutText:
            'Your baby is becoming more alert and interested in surroundings.',
        milestones: [
          _m(
            'w4_co1',
            'Watches faces carefully',
            'Increased visual attention to faces.',
            cat,
            label,
          ),
          _m(
            'w4_co2',
            'Briefly tracks moving objects',
            'Eyes follow slow movement.',
            cat,
            label,
          ),
          _m(
            'w4_co3',
            'Notices lights and patterns',
            'Responds to visual stimulation.',
            cat,
            label,
          ),
          _m(
            'w4_co4',
            'More alert during awake periods',
            'Longer alert windows.',
            cat,
            label,
          ),
        ],
        activities: [
          _a('Face-to-face interaction', 'Hold face 20-30cm from baby.', '😊', [
            'Get close to baby\'s face.',
            'Smile slowly.',
            'Make gentle expressions.',
          ]),
          _a('Black-and-white cards', 'Stimulate visual development.', '🖤', [
            'Hold card 20-30cm away.',
            'Move it slowly.',
            'Watch baby\'s eyes.',
          ]),
          _a(
            'Gentle eye contact play',
            'Builds connection and visual development.',
            '👁️',
            [
              'Hold baby at face level.',
              'Make eye contact.',
              'Smile and talk softly.',
            ],
          ),
        ],
        signsToLookFor: [
          _pos('Visual focus on faces', 'Stares at faces at close range.'),
          _pos('Brief tracking movements', 'Eyes follow slow movement.'),
          _pos('Increased alertness', 'Longer awake and alert periods.'),
          _watch('No visual attention', 'May indicate visual concerns.'),
          _watch(
            'Extremely difficult to wake',
            'Excessive sleepiness needs evaluation.',
          ),
        ],
        whenToWorry: [
          _warn(
            'No visual attention',
            'Contact doctor if no response to faces or light.',
          ),
          _warn(
            'No response to surroundings',
            'Lack of any environmental awareness needs evaluation.',
          ),
        ],
        commonConcerns: [
          _concern(
            'How much screen time is okay for a 1-month-old?',
            'None recommended. Screens don\'t provide the interaction babies need. Human faces, voices, and real objects are far more stimulating.',
          ),
        ],
        parentTips: [
          'Your face is still the best toy.',
          'Change baby\'s environment regularly.',
          'Respond consistently to baby\'s cues.',
        ],
      );
    case MilestoneCategory.social:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 3,
        aboutText:
            'Attachment and emotional bonding continue growing strongly.',
        milestones: [
          _m(
            'w4_so1',
            'Calms when comforted',
            'Settles when picked up and comforted.',
            cat,
            label,
          ),
          _m(
            'w4_so2',
            'Enjoys cuddling and closeness',
            'Responds positively to being held.',
            cat,
            label,
          ),
          _m(
            'w4_so3',
            'Begins early social engagement',
            'Brief periods of calm alertness with caregiver.',
            cat,
            label,
          ),
          _m(
            'w4_so4',
            'Watches caregiver faces calmly',
            'Shows social interest.',
            cat,
            label,
          ),
        ],
        activities: [
          _a('Skin-to-skin contact', 'Hold baby against bare skin.', '🤱', [
            'Remove baby\'s clothing except nappy.',
            'Hold against bare chest.',
            'Cover with a blanket.',
          ]),
          _a('Cuddling', 'Consistent holding builds security.', '💗', [
            'Hold baby in different positions.',
            'Let baby hear your heartbeat.',
            'Respond promptly to cries.',
          ]),
          _a(
            'Calm soothing voice',
            'Your voice is the most powerful soothing tool.',
            '🎵',
            [
              'Speak softly and calmly.',
              'Use baby\'s name often.',
              'Hum or sing during care routines.',
            ],
          ),
          _a(
            'Gentle smiling interaction',
            'Facial expressions teach social connection.',
            '😊',
            ['Make eye contact.', 'Smile and talk.', 'Exaggerate expressions.'],
          ),
        ],
        signsToLookFor: [
          _pos('Settles when held', 'Calms with holding or voice.'),
          _pos('Appears relaxed with caregivers', 'Body relaxes when held.'),
          _pos('Quiet alert engagement', 'Brief periods of calm alertness.'),
          _watch(
            'Rarely calms when comforted',
            'Persistent difficulty settling needs evaluation.',
          ),
          _watch(
            'No response to touch or voice',
            'Limited response needs review.',
          ),
        ],
        whenToWorry: [
          _warn(
            'Rarely calms when comforted',
            'If consistently inconsolable, rule out medical causes.',
          ),
          _warn(
            'No response to touch or voice',
            'Contact doctor if no response to comfort.',
          ),
        ],
        commonConcerns: [
          _concern(
            'I don\'t feel bonded with my baby yet. Is that normal?',
            'Yes. Bonding is a process, not an instant event. It develops over weeks and months. If you feel persistently disconnected, speak to your doctor about postnatal support.',
          ),
        ],
        parentTips: [
          'You cannot hold a newborn too much.',
          'Respond to cries promptly.',
          'You and your baby are learning together every day.',
        ],
      );
    case MilestoneCategory.feedingSleep:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 3,
        aboutText:
            'Feeding patterns remain frequent, but some babies may begin developing slightly more predictable routines.',
        milestones: [
          _m(
            'w4_fs1',
            'Feeds every 2–3 hours',
            'Frequent feeding continues.',
            cat,
            label,
          ),
          _m(
            'w4_fs2',
            'Cluster feeding may continue',
            'Frequent feeds in the evening.',
            cat,
            label,
          ),
          _m(
            'w4_fs3',
            'Sleeps 14–17 hours daily',
            'Most of the day is spent sleeping.',
            cat,
            label,
          ),
          _m(
            'w4_fs4',
            'Slightly longer awake windows',
            'Brief alert periods between feeds.',
            cat,
            label,
          ),
        ],
        activities: [
          _a('Feed on demand', 'Feed whenever baby shows hunger cues.', '🍼', [
            'Watch for rooting and sucking cues.',
            'Feed before crying starts.',
            'Let baby feed until satisfied.',
          ]),
          _a(
            'Burp after feeding',
            'Reduces discomfort from swallowed air.',
            '🤱',
            [
              'Hold baby upright.',
              'Gently pat or rub back.',
              'Wait 5-10 minutes.',
            ],
          ),
          _a(
            'Calm bedtime environment',
            'Consistent environment helps regulation.',
            '😴',
            [
              'Keep room temperature comfortable.',
              'Use white noise if helpful.',
              'Keep nighttime calm and dim.',
            ],
          ),
          _a('Watch hunger cues', 'Feed before crying starts.', '👀', [
            'Watch for rooting.',
            'Look for sucking on fists.',
            'Feed when you see these cues.',
          ]),
        ],
        signsToLookFor: [
          _pos('Regular wet diapers', '6+ wet diapers per day.'),
          _pos('Feeding interest', 'Shows hunger cues regularly.'),
          _pos('Calm after feeding', 'Settles after feeds.'),
          _pos('Wakes independently for feeds', 'Wakes when hungry.'),
          _watch('Poor feeding', 'Difficulty feeding needs support.'),
          _watch('Fewer wet diapers', 'May indicate inadequate feeding.'),
        ],
        whenToWorry: [
          _warn('Poor feeding', 'Contact lactation consultant or doctor.'),
          _warn(
            'Fewer wet diapers',
            'Fewer than 6 wet diapers needs evaluation.',
          ),
          _warn(
            'Excessive sleepiness',
            'Difficulty waking for feeds needs attention.',
          ),
        ],
        commonConcerns: [
          _concern(
            'Is spit-up normal?',
            'Yes. Most babies spit up regularly. As long as baby is gaining weight and not in distress, it is normal. Contact your doctor if spit-up is forceful or very frequent.',
          ),
          _concern(
            'My baby has gas. What can I do?',
            'Burp after every feed, try different feeding positions, and gentle tummy massage in a clockwise direction can help.',
          ),
        ],
        parentTips: [
          'Feed on demand — there is no schedule yet.',
          'Always place baby on their back to sleep.',
          'You do not need to create a perfect routine yet.',
        ],
      );
  }
}

// ── Weeks 5–6 ─────────────────────────────────────────────────────────────────

CategoryGuidance _weeks5to6(MilestoneCategory cat) {
  const label = '4-6 Weeks';
  switch (cat) {
    case MilestoneCategory.grossMotor:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 4,
        aboutText:
            'Your baby\'s neck, shoulder, and upper body muscles are becoming stronger. Movements may look smoother and more controlled.',
        milestones: [
          _m(
            'w56_gm1',
            'Holds head slightly steadier',
            'Head control improving.',
            cat,
            label,
          ),
          _m(
            'w56_gm2',
            'Pushes briefly during tummy time',
            'Brief push-up attempts.',
            cat,
            label,
          ),
          _m(
            'w56_gm3',
            'Stronger kicking and stretching',
            'More active limb movement.',
            cat,
            label,
          ),
          _m(
            'w56_gm4',
            'More active arm and leg movements',
            'Increased spontaneous movement.',
            cat,
            label,
          ),
          _m(
            'w56_gm5',
            'Better head turning side to side',
            'More controlled head movement.',
            cat,
            label,
          ),
        ],
        activities: [
          _a('Daily tummy time', 'Increase to 3-5 minutes per session.', '🍼', [
            'Lay baby on firm surface.',
            'Get down to their level.',
            'Increase time gradually.',
          ]),
          _a(
            'Bicycle leg exercises',
            'Stimulates leg strength and digestion.',
            '🚲',
            [
              'Lay baby on back.',
              'Gently cycle their legs.',
              'Repeat 5-10 times twice a day.',
            ],
          ),
          _a(
            'Chest-to-chest holding',
            'Supports head control development.',
            '🤱',
            [
              'Hold baby chest-to-chest.',
              'Support their head.',
              'Talk softly.',
            ],
          ),
          _a(
            'Encourage visual tracking with faces/toys',
            'Builds neck strength and visual development.',
            '😊',
            [
              'Hold face 20-30cm away.',
              'Move slowly side to side.',
              'Watch baby\'s eyes follow.',
            ],
          ),
        ],
        signsToLookFor: [
          _pos('Active body movement', 'Spontaneous movement on both sides.'),
          _pos(
            'Brief head control during tummy time',
            'Even a few seconds counts.',
          ),
          _pos(
            'Pushes legs against surfaces',
            'Strong leg push shows healthy tone.',
          ),
          _pos('Moves both sides equally', 'Symmetric movement is healthy.'),
          _watch(
            'Very floppy or stiff body',
            'Either extreme needs evaluation.',
          ),
          _watch(
            'No head lifting attempts',
            'No progress in head control needs review.',
          ),
        ],
        whenToWorry: [
          _warn(
            'Very floppy or stiff body',
            'Contact doctor if muscle tone seems abnormal.',
          ),
          _warn(
            'Very little movement',
            'Minimal spontaneous movement needs evaluation.',
          ),
          _warn(
            'No head lifting attempts',
            'No progress in head control needs assessment.',
          ),
          _warn(
            'Uses one side much less',
            'Asymmetric movement should be assessed.',
          ),
        ],
        commonConcerns: [
          _concern(
            'Is it normal for my baby to hate tummy time?',
            'Yes. Many babies dislike tummy time at first. Try tummy time on your chest, use a rolled towel under their chest, or do it right after a nappy change. Keep sessions short and positive.',
          ),
          _concern(
            'My baby has a growth spurt. What should I expect?',
            'Growth spurts often happen around 3 weeks, 6 weeks, 3 months, and 6 months. Baby may feed more frequently and be fussier for a few days.',
          ),
        ],
        parentTips: [
          'Your baby is learning to eat, sleep, move, communicate, and feel safe in the world.',
          'You do not need to create a perfect routine right now.',
          'Love, comfort, feeding, eye contact, and responsive care are already helping your baby grow beautifully.',
        ],
      );
    case MilestoneCategory.fineMotor:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 4,
        aboutText:
            'Your baby is becoming more aware of hands and beginning early reaching movements.',
        milestones: [
          _m(
            'w56_fm1',
            'Opens hands more often',
            'Fists relax more frequently.',
            cat,
            label,
          ),
          _m(
            'w56_fm2',
            'Hands move toward mouth',
            'Hand-to-mouth movement developing.',
            cat,
            label,
          ),
          _m(
            'w56_fm3',
            'Brief accidental swiping at objects',
            'Accidental contact with nearby objects.',
            cat,
            label,
          ),
          _m(
            'w56_fm4',
            'Reflexive grasp continues',
            'Grasps when finger placed in palm.',
            cat,
            label,
          ),
          _m(
            'w56_fm5',
            'Watches hands moving',
            'Visual attention to own hands.',
            cat,
            label,
          ),
        ],
        activities: [
          _a(
            'Finger grasp games',
            'Stimulates grasp reflex and bonding.',
            '🤝',
            [
              'Offer finger to palm.',
              'Let them grip naturally.',
              'Gently wiggle.',
            ],
          ),
          _a('Soft sensory toys', 'Introduce simple sensory objects.', '🧸', [
            'Place rattle in baby\'s hand.',
            'Let them feel the texture.',
            'React with excitement.',
          ]),
          _a('Gentle hand massage', 'Stimulates sensory pathways.', '✋', [
            'Stroke baby\'s hands gently.',
            'Open fingers softly.',
            'Massage palms.',
          ]),
          _a(
            'Textured fabrics/play',
            'Different textures stimulate development.',
            '🎨',
            [
              'Use soft cloth on hands.',
              'Let them feel textures.',
              'Describe what they feel.',
            ],
          ),
        ],
        signsToLookFor: [
          _pos('Brief relaxed fists', 'Hands relax occasionally.'),
          _pos('Hand movement near face', 'Hand-to-face movement developing.'),
          _pos('Reflexive gripping', 'Strong grasp reflex present.'),
          _pos(
            'Attempts to swipe at nearby objects',
            'Early reaching behaviour.',
          ),
          _watch(
            'No arm or hand movement',
            'Asymmetric movement needs evaluation.',
          ),
          _watch(
            'Persistent tight fists',
            'Hands always clenched after 3 months needs review.',
          ),
        ],
        whenToWorry: [
          _warn(
            'No arm or hand movement',
            'Asymmetric movement needs evaluation.',
          ),
          _warn(
            'No grasp reflex',
            'Contact doctor if no grip when finger placed in palm.',
          ),
          _warn(
            'Persistent tight fists',
            'Hands always clenched after 3 months needs review.',
          ),
          _warn(
            'Unequal movement between hands',
            'Strong hand preference before 12 months needs evaluation.',
          ),
        ],
        commonConcerns: [
          _concern(
            'My baby drools a lot. Is that normal?',
            'Yes. Increased drooling is normal from around 6-8 weeks as salivary glands develop. It increases further during teething.',
          ),
        ],
        parentTips: [
          'Avoid mittens so baby can explore with their hands.',
          'Dangle colourful toys just within reach to encourage grasping.',
          'Let baby feel different textures — it builds sensory pathways.',
        ],
      );
    case MilestoneCategory.language:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 4,
        aboutText:
            'Your baby is becoming more vocal and responsive to sounds and voices.',
        milestones: [
          _m(
            'w56_la1',
            'Small cooing sounds',
            'First vowel-like sounds.',
            cat,
            label,
          ),
          _m(
            'w56_la2',
            'Different cries for different needs',
            'Hunger cry vs discomfort cry.',
            cat,
            label,
          ),
          _m(
            'w56_la3',
            'Reacts to familiar voices',
            'Calms or turns toward known voices.',
            cat,
            label,
          ),
          _m(
            'w56_la4',
            'Watches faces during conversation',
            'Shows interest in communication.',
            cat,
            label,
          ),
          _m(
            'w56_la5',
            'May make happy sounds',
            'Contented vocalisations.',
            cat,
            label,
          ),
        ],
        activities:
            [
              _a(
                'Talk during feeds and diaper changes',
                'Narrate care routines.',
                '💬',
                [
                  'Describe what you are doing.',
                  'Use a warm voice.',
                  'Pause and wait for baby\'s response.',
                ],
              ),
              _a(
                'Sing songs and lullabies',
                'Singing helps baby learn rhythm and language.',
                '🎵',
                [
                  'Choose 2-3 simple songs.',
                  'Sing consistently.',
                  'Baby will begin to recognise them.',
                ],
              ),
              _a(
                'Mimic baby sounds',
                'Copying sounds teaches turn-taking.',
                '🗣️',
                [
                  'When baby coos, coo back.',
                  'Pause and wait for their response.',
                  'Take turns — this is their first conversation!',
                ],
              ),
              _a(
                'Read simple books aloud',
                'Reading builds language foundations.',
                '📚',
                [
                  'Choose simple board books.',
                  'Point to pictures and name them.',
                  'Use an expressive voice.',
                ],
              ),
            ],
        signsToLookFor: [
          _pos('Reacts to sound', 'Startles or stills when hearing sounds.'),
          _pos(
            'Quiets when hearing caregiver voice',
            'Recognises and responds to familiar voice.',
          ),
          _pos('Watches mouth movements', 'Shows interest in communication.'),
          _pos('Vocalises during awake time', 'Makes sounds when alert.'),
          _watch(
            'No response to loud sounds',
            'May indicate hearing concerns.',
          ),
          _watch('No vocal sounds', 'Absence of any sounds needs evaluation.'),
        ],
        whenToWorry: [
          _warn(
            'No response to loud sounds',
            'Could indicate hearing issues — request a hearing test.',
          ),
          _warn('Weak cry', 'Consistently weak cry needs medical evaluation.'),
          _warn(
            'No vocal sounds',
            'Absence of any vocalisations needs evaluation.',
          ),
          _warn(
            'No reaction to voices',
            'Limited response to voices needs review.',
          ),
        ],
        commonConcerns: [
          _concern(
            'When will my baby laugh?',
            'Most babies laugh for the first time between 3-4 months. Cooing and happy sounds come first, usually around 6-8 weeks.',
          ),
        ],
        parentTips: [
          'Coo back at your baby — it encourages more vocalisation.',
          'Read books every day — even board books with one word per page.',
          'Narrate your day: "Now we\'re going to the kitchen to make lunch."',
        ],
      );
    case MilestoneCategory.cognitive:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 4,
        aboutText:
            'Your baby is becoming more alert and curious about surroundings.',
        milestones: [
          _m(
            'w56_co1',
            'Watches faces carefully',
            'Increased visual attention to faces.',
            cat,
            label,
          ),
          _m(
            'w56_co2',
            'Tracks moving objects more smoothly',
            'Eyes follow slow movement.',
            cat,
            label,
          ),
          _m(
            'w56_co3',
            'Notices lights, colors, and movement',
            'Responds to visual stimulation.',
            cat,
            label,
          ),
          _m(
            'w56_co4',
            'Longer awake and alert periods',
            'Increased alert time.',
            cat,
            label,
          ),
          _m(
            'w56_co5',
            'Recognises familiar caregivers',
            'Shows preference for known people.',
            cat,
            label,
          ),
        ],
        activities: [
          _a('Face-to-face play', 'Hold face 20-30cm from baby.', '😊', [
            'Get close to baby\'s face.',
            'Smile slowly.',
            'Make gentle expressions.',
          ]),
          _a('Mirror play', 'Show baby their reflection.', '🪞', [
            'Hold baby in front of a mirror.',
            'Point to their reflection.',
            'Make faces together.',
          ]),
          _a(
            'Black-and-white or colorful toys',
            'Stimulate visual development.',
            '🖤',
            [
              'Hold toy 20-30cm away.',
              'Move it slowly.',
              'Watch baby\'s eyes track it.',
            ],
          ),
          _a('Slow visual tracking games', 'Encourage eye tracking.', '👁️', [
            'Hold a toy in front of baby.',
            'Move it slowly side to side.',
            'Watch baby\'s eyes follow.',
          ]),
        ],
        signsToLookFor: [
          _pos('Brief visual tracking', 'Eyes follow slow movement.'),
          _pos('Focuses on caregiver faces', 'Shows social recognition.'),
          _pos('Interested in surroundings', 'Looks around when alert.'),
          _pos('Longer quiet alert periods', 'Increased awake and alert time.'),
          _watch('No visual engagement', 'May indicate visual concerns.'),
          _watch(
            'Extremely difficult to wake',
            'Excessive sleepiness needs evaluation.',
          ),
        ],
        whenToWorry: [
          _warn(
            'No visual engagement',
            'Contact doctor if no response to faces or light.',
          ),
          _warn(
            'Difficult to wake',
            'Difficulty waking for feeds needs medical attention.',
          ),
          _warn(
            'No interest in surroundings',
            'Lack of any environmental awareness needs evaluation.',
          ),
        ],
        commonConcerns: [
          _concern(
            'How much screen time is okay for a 6-week-old?',
            'None recommended. Screens don\'t provide the interaction babies need. Human faces, voices, and real objects are far more stimulating for brain development.',
          ),
        ],
        parentTips: [
          'Your face is still the best toy.',
          'Change baby\'s environment — different rooms, outdoors, different positions.',
          'Respond consistently to baby\'s cues — predictability builds cognitive security.',
        ],
      );
    case MilestoneCategory.social:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 4,
        aboutText:
            'Your baby is beginning stronger emotional bonding and early social interaction.',
        milestones: [
          _m(
            'w56_so1',
            'Enjoys cuddling and closeness',
            'Responds positively to being held.',
            cat,
            label,
          ),
          _m(
            'w56_so2',
            'Calms when comforted',
            'Settles when picked up and comforted.',
            cat,
            label,
          ),
          _m(
            'w56_so3',
            'Watches caregiver faces carefully',
            'Shows social interest.',
            cat,
            label,
          ),
          _m(
            'w56_so4',
            'Early social smiles may begin',
            'First smiles in response to faces.',
            cat,
            label,
          ),
          _m(
            'w56_so5',
            'Appears more engaged during interaction',
            'Increased social responsiveness.',
            cat,
            label,
          ),
        ],
        activities: [
          _a('Skin-to-skin contact', 'Hold baby against bare skin.', '🤱', [
            'Remove baby\'s clothing except nappy.',
            'Hold against bare chest.',
            'Cover with a blanket.',
          ]),
          _a(
            'Smiling interaction',
            'Smile and talk to encourage social smiling.',
            '😊',
            [
              'Make eye contact.',
              'Smile and talk.',
              'Wait for baby\'s response.',
            ],
          ),
          _a(
            'Gentle talking and cuddling',
            'Consistent interaction builds attachment.',
            '💗',
            ['Hold baby close.', 'Talk softly.', 'Respond to baby\'s sounds.'],
          ),
          _a(
            'Calm soothing routines',
            'Consistent routines build security.',
            '🌙',
            [
              'Use a calm voice.',
              'Try gentle rocking.',
              'Offer skin-to-skin if distressed.',
            ],
          ),
        ],
        signsToLookFor: [
          _pos('Settles when held', 'Calms with holding or voice.'),
          _pos('Enjoys face-to-face interaction', 'Shows social interest.'),
          _pos('Relaxed during comforting', 'Body relaxes when held.'),
          _pos('Quiet alert engagement', 'Brief periods of calm alertness.'),
          _watch(
            'Rarely calms when comforted',
            'Persistent difficulty settling needs evaluation.',
          ),
          _watch(
            'No engagement with caregivers',
            'Limited social response needs review.',
          ),
        ],
        whenToWorry: [
          _warn(
            'Rarely calms when comforted',
            'If consistently inconsolable, rule out medical causes.',
          ),
          _warn(
            'No response to touch or voice',
            'Contact doctor if no response to comfort.',
          ),
          _warn(
            'No engagement with caregivers',
            'Limited social response needs evaluation.',
          ),
        ],
        commonConcerns: [
          _concern(
            'My baby smiles at everyone. Is that normal?',
            'Yes, completely normal at 6-8 weeks. Stranger anxiety (preferring familiar people) usually develops around 6-9 months.',
          ),
        ],
        parentTips: [
          'Smile and talk to your baby constantly — they are learning from you.',
          'Play peek-a-boo and tickle games every day.',
          'Introduce baby to other friendly faces — grandparents, friends.',
        ],
      );
    case MilestoneCategory.feedingSleep:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 4,
        aboutText:
            'Feeding is becoming more efficient and sleep is beginning to consolidate. Many babies start sleeping longer stretches at night around 6-8 weeks.',
        milestones: [
          _m(
            'w56_fs1',
            'Feeds every 2–3 hours',
            'Frequent feeding continues.',
            cat,
            label,
          ),
          _m(
            'w56_fs2',
            'Cluster feeding still common',
            'Frequent feeds in the evening.',
            cat,
            label,
          ),
          _m(
            'w56_fs3',
            'Slightly longer awake windows',
            'Brief alert periods between feeds.',
            cat,
            label,
          ),
          _m(
            'w56_fs4',
            'May begin slightly longer nighttime sleep stretches',
            'Some babies sleep 4-5 hours.',
            cat,
            label,
          ),
          _m(
            'w56_fs5',
            'Shows tired cues',
            'Yawning, eye rubbing, looking away.',
            cat,
            label,
          ),
        ],
        activities: [
          _a(
            'Begin gentle bedtime routine',
            'Start a simple, consistent bedtime routine.',
            '😴',
            [
              'Bath, feed, song, sleep — in the same order each night.',
              'Keep the routine to 20-30 minutes.',
              'Consistency is more important than timing at this age.',
            ],
          ),
          _a(
            'Drowsy but awake',
            'Practice putting baby down drowsy but not fully asleep.',
            '🌙',
            [
              'Watch for tired cues (yawning, eye rubbing).',
              'Put baby down when drowsy but still awake.',
              'This teaches self-settling over time.',
            ],
          ),
          _a('Feed on demand', 'Feed whenever baby shows hunger cues.', '🍼', [
            'Watch for rooting and sucking cues.',
            'Feed before crying starts.',
            'Let baby feed until satisfied.',
          ]),
          _a(
            'Burp after feeds',
            'Reduces discomfort from swallowed air.',
            '🤱',
            [
              'Hold baby upright.',
              'Gently pat or rub back.',
              'Wait 5-10 minutes.',
            ],
          ),
        ],
        signsToLookFor: [
          _pos(
            'Sleeping one longer stretch at night',
            'Even 4-5 hours is great progress.',
          ),
          _pos(
            'Predictable feeding pattern emerging',
            'Feeds becoming more spaced and regular.',
          ),
          _watch(
            'Still feeding every 1-2 hours at 8 weeks',
            'May indicate feeding issues or low supply.',
          ),
          _watch(
            'Excessive spitting up with poor weight gain',
            'Could indicate reflux.',
          ),
        ],
        whenToWorry: [
          _warn(
            'Still feeding every 1-2 hours at 8 weeks',
            'May indicate feeding issues — consult a lactation consultant.',
          ),
          _warn(
            'Excessive spitting up with poor weight gain',
            'Could indicate reflux — discuss with your doctor.',
          ),
          _warn(
            'Fewer wet diapers',
            'Fewer than 6 wet diapers needs evaluation.',
          ),
        ],
        commonConcerns: [
          _concern(
            'When will my baby sleep through the night?',
            'Most babies don\'t consistently sleep through until 4-6 months or later. "Sleeping through" is defined as 5-6 hours, not 12. Every baby is different.',
          ),
          _concern(
            'Should I start a schedule?',
            'A loose routine (not a strict schedule) can help at this age. Follow baby\'s cues but try to keep the order of activities consistent: feed, play, sleep.',
          ),
        ],
        parentTips: [
          'Start a simple bedtime routine now — it pays off later.',
          'Watch for tired cues and put baby down before overtired.',
          'The "eat-play-sleep" cycle helps distinguish day from night.',
        ],
      );
  }
}

// ── Weeks 7–8 ─────────────────────────────────────────────────────────────────

CategoryGuidance _weeks7to8(MilestoneCategory cat) {
  const label = '6-8 Weeks';
  switch (cat) {
    case MilestoneCategory.grossMotor:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 5,
        aboutText:
            'Your baby\'s neck, shoulder, and core muscles are getting stronger, helping with better movement control.',
        milestones: [
          _m(
            'w78_gm1',
            'Holds head up longer during tummy time',
            'Improved head control.',
            cat,
            label,
          ),
          _m(
            'w78_gm2',
            'Stronger kicking and stretching',
            'More active limb movement.',
            cat,
            label,
          ),
          _m(
            'w78_gm3',
            'Pushes up briefly on forearms',
            'Early push-up attempts.',
            cat,
            label,
          ),
          _m(
            'w78_gm4',
            'Smoother body movements',
            'Less jerky, more controlled.',
            cat,
            label,
          ),
          _m(
            'w78_gm5',
            'Turns head toward sounds or faces',
            'Head turning improving.',
            cat,
            label,
          ),
        ],
        activities: [
          _a(
            'Daily tummy time several times a day',
            'Increase to 5-10 minutes per session.',
            '🍼',
            [
              'Lay baby on firm surface.',
              'Get down to their level.',
              'Increase time gradually.',
            ],
          ),
          _a(
            'Encourage reaching toward toys',
            'Place toys just within reach.',
            '🎯',
            [
              'Dangle a toy above baby.',
              'Move it slowly.',
              'Celebrate when baby reaches.',
            ],
          ),
          _a('Bicycle leg exercises', 'Stimulates leg strength.', '🚲', [
            'Lay baby on back.',
            'Gently cycle their legs.',
            'Repeat 5-10 times.',
          ]),
          _a(
            'Floor play on safe mat',
            'Give baby space to move freely.',
            '🧸',
            [
              'Place baby on a soft mat.',
              'Surround with safe toys.',
              'Let baby explore freely.',
            ],
          ),
        ],
        signsToLookFor: [
          _pos(
            'Better head control',
            'Head stays up longer during tummy time.',
          ),
          _pos(
            'Pushes legs against surfaces',
            'Strong leg push shows healthy tone.',
          ),
          _pos(
            'Active arm and leg movement',
            'Spontaneous movement on both sides.',
          ),
          _pos('Moves both sides equally', 'Symmetric movement is healthy.'),
          _watch(
            'Very floppy or stiff body',
            'Either extreme needs evaluation.',
          ),
          _watch(
            'Strong preference for one side only',
            'Asymmetric movement needs assessment.',
          ),
        ],
        whenToWorry: [
          _warn(
            'Very floppy or stiff body',
            'Contact doctor if muscle tone seems abnormal.',
          ),
          _warn(
            'Very little movement',
            'Minimal spontaneous movement needs evaluation.',
          ),
          _warn(
            'No head lifting attempts',
            'No progress in head control needs assessment.',
          ),
          _warn(
            'Strong preference for one side only',
            'Asymmetric movement should be assessed.',
          ),
        ],
        commonConcerns: [
          _concern(
            'My baby rolled over once but hasn\'t done it again. Should I worry?',
            'No. Early rolling is often accidental. Consistent rolling usually develops between 4-6 months. Keep doing tummy time to build the strength.',
          ),
          _concern(
            'How much tummy time does my 7-8 week old need?',
            'Aim for 20-30 minutes total per day, spread across several sessions. Always supervise tummy time.',
          ),
        ],
        parentTips: [
          'Simple everyday moments like smiling, talking, cuddling, feeding, and eye contact are helping your baby feel safe, loved, and emotionally connected.',
          'Daily tummy time is the most important physical activity at this age.',
        ],
      );
    case MilestoneCategory.fineMotor:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 5,
        aboutText:
            'Your baby is becoming more aware of hands and beginning early reaching movements.',
        milestones: [
          _m(
            'w78_fm1',
            'Opens hands frequently',
            'Fists relax more often.',
            cat,
            label,
          ),
          _m(
            'w78_fm2',
            'Watches hands moving',
            'Visual attention to own hands.',
            cat,
            label,
          ),
          _m(
            'w78_fm3',
            'Swipes accidentally at toys',
            'Early reaching behaviour.',
            cat,
            label,
          ),
          _m(
            'w78_fm4',
            'Brings hands toward mouth',
            'Hand-to-mouth movement.',
            cat,
            label,
          ),
          _m(
            'w78_fm5',
            'Grasps objects briefly when placed in hand',
            'Brief intentional holding.',
            cat,
            label,
          ),
        ],
        activities: [
          _a('Soft rattles', 'Introduce simple sensory toys.', '🪀', [
            'Place rattle in baby\'s hand.',
            'Let them feel the texture.',
            'React with excitement.',
          ]),
          _a(
            'Sensory toys',
            'Different textures stimulate development.',
            '🧸',
            [
              'Offer toys with different textures.',
              'Let baby explore by touching.',
              'Name the textures.',
            ],
          ),
          _a(
            'Gentle finger play',
            'Stimulates grasp and sensory development.',
            '✋',
            [
              'Offer finger to palm.',
              'Let them grip naturally.',
              'Gently wiggle.',
            ],
          ),
          _a(
            'Hanging toys during supervised play',
            'Encourages reaching and swiping.',
            '🎯',
            [
              'Hang toys within reach.',
              'Let baby swipe at them.',
              'Celebrate contact.',
            ],
          ),
        ],
        signsToLookFor: [
          _pos('Hand movement toward objects', 'Early reaching behaviour.'),
          _pos('Relaxed hands during awake time', 'Fists relax when alert.'),
          _pos('Brief gripping of toys', 'Holds objects briefly.'),
          _watch('No hand movement', 'Asymmetric movement needs evaluation.'),
          _watch(
            'Persistent tight fists',
            'Hands always clenched needs review.',
          ),
          _watch('No grasp reflex', 'Absence needs evaluation.'),
          _watch(
            'Unequal arm movement',
            'Strong hand preference before 12 months needs evaluation.',
          ),
        ],
        whenToWorry: [
          _warn('No hand movement', 'Asymmetric movement needs evaluation.'),
          _warn(
            'Persistent tight fists',
            'Hands always clenched after 3 months needs review.',
          ),
          _warn(
            'No grasp reflex',
            'Contact doctor if no grip when finger placed in palm.',
          ),
        ],
        commonConcerns: [
          _concern(
            'My baby bats at things but misses. Is that normal?',
            'Yes. Eye-hand coordination takes time to develop. Accidental contact is the first step — intentional reaching comes later around 3-4 months.',
          ),
        ],
        parentTips: [
          'Dangle colourful toys just within reach to encourage grasping.',
          'Let baby feel different textures — it builds sensory pathways.',
          'Avoid mittens so baby can explore with their hands.',
        ],
      );
    case MilestoneCategory.language:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 5,
        aboutText:
            'Your baby is becoming more vocal and responsive to social interaction.',
        milestones: [
          _m(
            'w78_la1',
            'More cooing sounds',
            'Increased vowel-like vocalisations.',
            cat,
            label,
          ),
          _m(
            'w78_la2',
            'Responds to familiar voices',
            'Calms or turns toward known voices.',
            cat,
            label,
          ),
          _m(
            'w78_la3',
            'Makes happy sounds',
            'Contented vocalisations.',
            cat,
            label,
          ),
          _m(
            'w78_la4',
            'Quiets when spoken to',
            'Settles when hearing familiar voice.',
            cat,
            label,
          ),
          _m(
            'w78_la5',
            'Different cries for different needs',
            'Hunger cry vs discomfort cry.',
            cat,
            label,
          ),
        ],
        activities: [
          _a(
            'Talk during routines',
            'Narrate feeding, changing, and bathing.',
            '💬',
            [
              'Describe what you are doing.',
              'Use a warm voice.',
              'Pause and wait for baby\'s response.',
            ],
          ),
          _a(
            'Mimic baby sounds',
            'Copying sounds teaches turn-taking.',
            '🗣️',
            ['When baby coos, coo back.', 'Pause and wait.', 'Take turns.'],
          ),
          _a(
            'Read simple books',
            'Reading builds language foundations.',
            '📚',
            [
              'Choose simple board books.',
              'Point to pictures.',
              'Use an expressive voice.',
            ],
          ),
          _a(
            'Sing songs and rhymes',
            'Singing helps baby learn rhythm and language.',
            '🎵',
            [
              'Choose 2-3 simple songs.',
              'Sing consistently.',
              'Use actions with songs.',
            ],
          ),
        ],
        signsToLookFor: [
          _pos('Responds to voices', 'Calms or turns toward familiar voice.'),
          _pos('Vocalises during interaction', 'Makes sounds when engaged.'),
          _pos(
            'Watches faces while listening',
            'Shows interest in communication.',
          ),
          _watch('No response to sound', 'May indicate hearing concerns.'),
          _watch('Very weak cry', 'Consistently weak cry needs evaluation.'),
          _watch(
            'No vocal sounds',
            'Absence of any vocalisations needs evaluation.',
          ),
          _watch(
            'No reaction to voices',
            'Limited response to voices needs review.',
          ),
        ],
        whenToWorry: [
          _warn(
            'No response to sound',
            'Could indicate hearing issues — request a hearing test.',
          ),
          _warn(
            'Very weak cry',
            'Consistently weak cry needs medical evaluation.',
          ),
          _warn(
            'No vocal sounds',
            'Absence of any vocalisations needs evaluation.',
          ),
        ],
        commonConcerns: [
          _concern(
            'My baby makes a lot of noise but no real words. Is that normal?',
            'Completely normal. Cooing and babbling are the foundation of language. Real words come much later, usually around 10-14 months.',
          ),
        ],
        parentTips: [
          'Coo back at your baby — it encourages more vocalisation.',
          'Read books every day.',
          'Narrate your day constantly.',
        ],
      );
    case MilestoneCategory.cognitive:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 5,
        aboutText:
            'Your baby is becoming more alert and curious about surroundings.',
        milestones: [
          _m(
            'w78_co1',
            'Tracks moving objects more smoothly',
            'Eyes follow slow movement.',
            cat,
            label,
          ),
          _m(
            'w78_co2',
            'Watches faces carefully',
            'Increased visual attention to faces.',
            cat,
            label,
          ),
          _m(
            'w78_co3',
            'Notices lights, colors, and movements',
            'Responds to visual stimulation.',
            cat,
            label,
          ),
          _m(
            'w78_co4',
            'Longer awake and alert periods',
            'Increased alert time.',
            cat,
            label,
          ),
          _m(
            'w78_co5',
            'Recognises familiar caregivers',
            'Shows preference for known people.',
            cat,
            label,
          ),
        ],
        activities: [
          _a('Face-to-face play', 'Hold face 20-30cm from baby.', '😊', [
            'Get close to baby\'s face.',
            'Smile slowly.',
            'Make gentle expressions.',
          ]),
          _a('Mirror play', 'Show baby their reflection.', '🪞', [
            'Hold baby in front of a mirror.',
            'Point to their reflection.',
            'Make faces together.',
          ]),
          _a(
            'Black-and-white or colorful toys',
            'Stimulate visual development.',
            '🖤',
            [
              'Hold toy 20-30cm away.',
              'Move it slowly.',
              'Watch baby\'s eyes track it.',
            ],
          ),
          _a('Slow-moving toys', 'Encourage visual tracking.', '🎯', [
            'Hold a toy in front of baby.',
            'Move it slowly side to side.',
            'Watch baby\'s eyes follow.',
          ]),
        ],
        signsToLookFor: [
          _pos('Follows movement with eyes', 'Eyes track slow movement.'),
          _pos('Focuses on caregiver faces', 'Shows social recognition.'),
          _pos('Interested in surroundings', 'Looks around when alert.'),
          _watch('No visual engagement', 'May indicate visual concerns.'),
          _watch('Difficult to wake', 'Excessive sleepiness needs evaluation.'),
          _watch(
            'No interest in surroundings',
            'Lack of awareness needs evaluation.',
          ),
        ],
        whenToWorry: [
          _warn(
            'No visual engagement',
            'Contact doctor if no response to faces or light.',
          ),
          _warn(
            'Difficult to wake',
            'Difficulty waking for feeds needs medical attention.',
          ),
          _warn(
            'No interest in surroundings',
            'Lack of any environmental awareness needs evaluation.',
          ),
        ],
        commonConcerns: [
          _concern(
            'My baby stares at lights. Is that okay?',
            'Yes. Babies are naturally drawn to light sources. It\'s normal visual exploration. Just avoid very bright direct light.',
          ),
        ],
        parentTips: [
          'Your face is still the best toy.',
          'Change baby\'s environment regularly.',
          'Respond consistently to baby\'s cues.',
        ],
      );
    case MilestoneCategory.social:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 5,
        aboutText:
            'Your baby is becoming more socially engaged and emotionally expressive.',
        milestones: [
          _m(
            'w78_so1',
            'Social smiling becomes more frequent',
            'Smiles in response to faces.',
            cat,
            label,
          ),
          _m(
            'w78_so2',
            'Enjoys interaction and eye contact',
            'Shows pleasure during social play.',
            cat,
            label,
          ),
          _m(
            'w78_so3',
            'Calms when comforted',
            'Settles when picked up and comforted.',
            cat,
            label,
          ),
          _m(
            'w78_so4',
            'May show excitement during play',
            'Increased engagement during interaction.',
            cat,
            label,
          ),
          _m(
            'w78_so5',
            'Watches caregivers closely',
            'Shows strong social interest.',
            cat,
            label,
          ),
        ],
        activities: [
          _a(
            'Smiling interaction',
            'Smile and talk to encourage social smiling.',
            '😊',
            [
              'Make eye contact.',
              'Smile and talk.',
              'Wait for baby\'s response.',
            ],
          ),
          _a(
            'Skin-to-skin cuddles',
            'Consistent holding builds attachment.',
            '🤱',
            [
              'Hold baby against bare chest.',
              'Let baby hear your heartbeat.',
              'Talk softly.',
            ],
          ),
          _a(
            'Gentle talking and singing',
            'Consistent interaction builds connection.',
            '🎵',
            [
              'Talk during all care routines.',
              'Sing simple songs.',
              'Use baby\'s name often.',
            ],
          ),
          _a(
            'Face games and expressions',
            'Teach social connection through faces.',
            '😄',
            [
              'Make exaggerated expressions.',
              'Stick out your tongue.',
              'Watch baby copy.',
            ],
          ),
        ],
        signsToLookFor: [
          _pos(
            'Smiles during interaction',
            'Social smile in response to faces.',
          ),
          _pos(
            'Enjoys face-to-face play',
            'Shows pleasure during social interaction.',
          ),
          _pos(
            'Calms when held or spoken to',
            'Settles with familiar voice or touch.',
          ),
          _watch(
            'Rarely responds to interaction',
            'Limited social response needs evaluation.',
          ),
          _watch(
            'No eye contact',
            'Consistent avoidance of eye contact needs evaluation.',
          ),
          _watch(
            'No calming with comfort',
            'Persistent inconsolability needs review.',
          ),
        ],
        whenToWorry: [
          _warn(
            'Rarely responds to interaction',
            'Limited social response needs evaluation.',
          ),
          _warn(
            'No eye contact',
            'Consistent avoidance of eye contact needs evaluation.',
          ),
          _warn(
            'No calming with comfort',
            'If consistently inconsolable, rule out medical causes.',
          ),
        ],
        commonConcerns: [
          _concern(
            'My baby smiles in their sleep. Is that a real smile?',
            'Sleep smiles are reflexive, not social. The first real social smile (in response to your face) usually appears between 6-8 weeks.',
          ),
        ],
        parentTips: [
          'Smile and talk to your baby constantly.',
          'Play peek-a-boo and tickle games every day.',
          'Simple everyday moments like smiling, talking, cuddling, feeding, and eye contact are helping your baby feel safe, loved, and emotionally connected.',
        ],
      );
    case MilestoneCategory.feedingSleep:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 5,
        aboutText:
            'Sleep and feeding rhythms may begin feeling slightly more predictable for some babies.',
        milestones: [
          _m(
            'w78_fs1',
            'Feeds every 2–4 hours',
            'Feeding intervals may be lengthening.',
            cat,
            label,
          ),
          _m(
            'w78_fs2',
            'Longer awake windows',
            'More alert time between feeds.',
            cat,
            label,
          ),
          _m(
            'w78_fs3',
            'May sleep slightly longer at night',
            'Some babies sleep 4-5 hour stretches.',
            cat,
            label,
          ),
          _m(
            'w78_fs4',
            'Still wakes often for feeding',
            'Night waking for feeds continues.',
            cat,
            label,
          ),
          _m(
            'w78_fs5',
            'Cluster feeding may continue',
            'Frequent feeds in the evening.',
            cat,
            label,
          ),
        ],
        activities: [
          _a('Feed on demand', 'Feed whenever baby shows hunger cues.', '🍼', [
            'Watch for rooting and sucking cues.',
            'Feed before crying starts.',
            'Let baby feed until satisfied.',
          ]),
          _a(
            'Burp after feeds',
            'Reduces discomfort from swallowed air.',
            '🤱',
            [
              'Hold baby upright.',
              'Gently pat or rub back.',
              'Wait 5-10 minutes.',
            ],
          ),
          _a(
            'Gentle bedtime routine',
            'Start a simple, consistent bedtime routine.',
            '😴',
            [
              'Bath, feed, song, sleep — in the same order.',
              'Keep it to 20-30 minutes.',
              'Same time every night.',
            ],
          ),
          _a(
            'Calm nighttime environment',
            'Keep nighttime feeds quiet and dim.',
            '🌙',
            [
              'Avoid bright lights at night.',
              'Keep interaction minimal.',
              'Use a calm voice.',
            ],
          ),
        ],
        signsToLookFor: [
          _pos('Regular wet diapers', '6+ wet diapers per day.'),
          _pos('Feeding interest', 'Shows hunger cues regularly.'),
          _pos('Calm after feeding', 'Settles after feeds.'),
          _pos(
            'Alert periods during daytime',
            'More awake time during the day.',
          ),
          _watch('Poor feeding', 'Difficulty feeding needs support.'),
          _watch(
            'Persistent vomiting',
            'Forceful or very frequent vomiting needs evaluation.',
          ),
          _watch(
            'Extreme sleepiness',
            'Difficulty waking for feeds needs attention.',
          ),
        ],
        whenToWorry: [
          _warn('Poor feeding', 'Contact lactation consultant or doctor.'),
          _warn(
            'Fewer wet diapers',
            'Fewer than 6 wet diapers needs evaluation.',
          ),
          _warn(
            'Persistent vomiting',
            'Forceful or very frequent vomiting needs medical evaluation.',
          ),
          _warn(
            'Extreme sleepiness',
            'Difficulty waking for feeds needs attention.',
          ),
          _warn('Difficulty waking for feeds', 'Needs medical attention.'),
        ],
        commonConcerns: [
          _concern(
            'My baby wakes every 2 hours at night. Is that normal?',
            'Yes. Many babies wake every 2-3 hours at night until 3-4 months. This is biologically normal. It will improve gradually.',
          ),
          _concern(
            'Should I wake my baby to feed at night?',
            'If baby is gaining weight well, you generally don\'t need to wake them after 6-8 weeks. Ask your health visitor or doctor for personalised advice.',
          ),
        ],
        parentTips: [
          'Start a simple bedtime routine now — it pays off later.',
          'Watch for tired cues and put baby down before overtired.',
          'The "eat-play-sleep" cycle helps distinguish day from night.',
        ],
      );
  }
}

// ── Month 3 (12–16 weeks) ─────────────────────────────────────────────────────

CategoryGuidance _month3(MilestoneCategory cat) {
  const label = '2-3 Months';
  switch (cat) {
    case MilestoneCategory.grossMotor:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 6,
        aboutText:
            'Your baby\'s neck, shoulder, and upper body muscles are getting stronger, allowing better movement and head control.',
        milestones: [
          _m(
            'm3_gm1',
            'Holds head up steadily for short periods',
            'Good head control developing.',
            cat,
            label,
          ),
          _m(
            'm3_gm2',
            'Pushes up on forearms during tummy time',
            'Lifts chest off the floor.',
            cat,
            label,
          ),
          _m(
            'm3_gm3',
            'Strong kicking movements',
            'Active leg movement.',
            cat,
            label,
          ),
          _m(
            'm3_gm4',
            'Turns head toward sounds or faces',
            'Head turning improving.',
            cat,
            label,
          ),
          _m(
            'm3_gm5',
            'Improved body control',
            'More controlled overall movement.',
            cat,
            label,
          ),
        ],
        activities: [
          _a(
            'Daily tummy time',
            'Increase to 20-30 minutes spread through the day.',
            '🍼',
            [
              'Lay baby on firm surface.',
              'Get down to their level.',
              'Increase time gradually.',
            ],
          ),
          _a(
            'Floor play on soft mat',
            'Give baby space to move freely.',
            '🧸',
            [
              'Place baby on a soft mat.',
              'Surround with safe toys.',
              'Let baby explore freely.',
            ],
          ),
          _a(
            'Encourage reaching for toys',
            'Place toys just within reach.',
            '🎯',
            [
              'Dangle a toy above baby.',
              'Move it slowly.',
              'Celebrate when baby reaches.',
            ],
          ),
          _a('Gentle movement games', 'Stimulate body awareness.', '🚲', [
            'Lay baby on back.',
            'Gently cycle their legs.',
            'Repeat 5-10 times.',
          ]),
        ],
        signsToLookFor: [
          _pos(
            'Better head control',
            'Head stays up longer during tummy time.',
          ),
          _pos(
            'Pushes legs against surfaces',
            'Strong leg push shows healthy tone.',
          ),
          _pos(
            'Active arm and leg movement',
            'Spontaneous movement on both sides.',
          ),
          _pos(
            'Lifts chest slightly during tummy time',
            'Building strength for rolling.',
          ),
          _watch(
            'No head control improvement',
            'No progress in head control needs review.',
          ),
          _watch(
            'Very stiff or floppy body',
            'Either extreme needs evaluation.',
          ),
        ],
        whenToWorry: [
          _warn(
            'No head control improvement',
            'Contact doctor if no progress in head control.',
          ),
          _warn(
            'Very stiff or floppy body',
            'Either extreme may indicate a concern.',
          ),
          _warn(
            'Very little movement',
            'Minimal spontaneous movement needs evaluation.',
          ),
          _warn(
            'Uses one side much less',
            'Asymmetric movement should be assessed.',
          ),
        ],
        commonConcerns: [
          _concern(
            'My baby has short naps. Is that normal?',
            'Yes. Short naps (30-45 minutes) are very common in the first 3-4 months. Nap consolidation usually improves around 4-6 months.',
          ),
          _concern(
            'Is a sleep regression normal at 3 months?',
            'Yes. Many babies experience a sleep regression around 3-4 months as their sleep cycles mature. It is temporary.',
          ),
        ],
        parentTips: [
          'Your baby is learning through eye contact, touch, movement, sounds, and everyday interaction.',
          'Simple moments like talking, smiling, cuddling, and responding to your baby are helping their brain and emotional development every single day.',
        ],
      );
    case MilestoneCategory.fineMotor:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 6,
        aboutText:
            'Your baby is becoming more aware of hands and beginning early intentional hand movements.',
        milestones: [
          _m(
            'm3_fm1',
            'Opens hands often',
            'Fists relax frequently.',
            cat,
            label,
          ),
          _m(
            'm3_fm2',
            'Watches hands moving',
            'Visual attention to own hands.',
            cat,
            label,
          ),
          _m(
            'm3_fm3',
            'Grasps toys briefly',
            'Holds objects for a short time.',
            cat,
            label,
          ),
          _m(
            'm3_fm4',
            'Swipes at hanging toys',
            'Early reaching behaviour.',
            cat,
            label,
          ),
          _m(
            'm3_fm5',
            'Brings hands to mouth',
            'Hand-to-mouth movement.',
            cat,
            label,
          ),
        ],
        activities: [
          _a('Soft rattles', 'Introduce simple sensory toys.', '🪀', [
            'Place rattle in baby\'s hand.',
            'Let them feel the texture.',
            'React with excitement.',
          ]),
          _a('Hanging toys', 'Encourage reaching and swiping.', '🎯', [
            'Hang toys within reach.',
            'Let baby swipe at them.',
            'Celebrate contact.',
          ]),
          _a(
            'Sensory textures',
            'Different textures stimulate development.',
            '🧸',
            [
              'Offer toys with different textures.',
              'Let baby explore by touching.',
              'Name the textures.',
            ],
          ),
          _a(
            'Finger play games',
            'Stimulates grasp and sensory development.',
            '✋',
            [
              'Offer finger to palm.',
              'Let them grip naturally.',
              'Gently wiggle.',
            ],
          ),
        ],
        signsToLookFor: [
          _pos('Reaching toward toys', 'Early intentional reaching.'),
          _pos('Brief grasping', 'Holds objects briefly.'),
          _pos('Hand-to-mouth movement', 'Brings hands toward mouth.'),
          _pos('Relaxed hands during awake time', 'Fists relax when alert.'),
          _watch('No hand movement', 'Asymmetric movement needs evaluation.'),
          _watch(
            'Persistent tight fists',
            'Hands always clenched needs review.',
          ),
          _watch('No grasp reflex', 'Absence needs evaluation.'),
          _watch(
            'Unequal hand movement',
            'Strong hand preference before 12 months needs evaluation.',
          ),
        ],
        whenToWorry: [
          _warn('No hand movement', 'Asymmetric movement needs evaluation.'),
          _warn(
            'Persistent tight fists',
            'Hands always clenched after 3 months needs review.',
          ),
          _warn(
            'No grasp reflex',
            'Contact doctor if no grip when finger placed in palm.',
          ),
        ],
        commonConcerns: [
          _concern(
            'My baby chews on their hands constantly. Is that hunger?',
            'Not always. Hand-chewing is also self-soothing and exploration. Watch for other hunger cues to distinguish. It also increases during teething.',
          ),
        ],
        parentTips: [
          'Dangle colourful toys just within reach to encourage grasping.',
          'Let baby feel different textures — it builds sensory pathways.',
          'Avoid mittens so baby can explore with their hands.',
        ],
      );
    case MilestoneCategory.language:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 6,
        aboutText:
            'Your baby is becoming more vocal and responsive to interaction.',
        milestones: [
          _m(
            'm3_la1',
            'Coos and gurgles',
            'Increased vowel-like vocalisations.',
            cat,
            label,
          ),
          _m(
            'm3_la2',
            'Makes happy sounds',
            'Contented vocalisations.',
            cat,
            label,
          ),
          _m(
            'm3_la3',
            'Responds to familiar voices',
            'Calms or turns toward known voices.',
            cat,
            label,
          ),
          _m(
            'm3_la4',
            'Quiets when spoken to',
            'Settles when hearing familiar voice.',
            cat,
            label,
          ),
          _m(
            'm3_la5',
            'Different cries for different needs',
            'Hunger cry vs discomfort cry.',
            cat,
            label,
          ),
        ],
        activities: [
          _a(
            'Talk during routines',
            'Narrate feeding, changing, and bathing.',
            '💬',
            [
              'Describe what you are doing.',
              'Use a warm voice.',
              'Pause and wait for baby\'s response.',
            ],
          ),
          _a(
            'Read simple books',
            'Reading builds language foundations.',
            '📚',
            [
              'Choose simple board books.',
              'Point to pictures.',
              'Use an expressive voice.',
            ],
          ),
          _a(
            'Mimic baby sounds',
            'Copying sounds teaches turn-taking.',
            '🗣️',
            ['When baby coos, coo back.', 'Pause and wait.', 'Take turns.'],
          ),
          _a(
            'Sing songs and rhymes',
            'Singing helps baby learn rhythm and language.',
            '🎵',
            [
              'Choose 2-3 simple songs.',
              'Sing consistently.',
              'Use actions with songs.',
            ],
          ),
        ],
        signsToLookFor: [
          _pos('Vocal sounds during interaction', 'Makes sounds when engaged.'),
          _pos(
            'Watches faces while listening',
            'Shows interest in communication.',
          ),
          _pos('Responds to voices', 'Calms or turns toward familiar voice.'),
          _watch('No sound response', 'May indicate hearing concerns.'),
          _watch('Very weak cry', 'Consistently weak cry needs evaluation.'),
          _watch(
            'No vocal sounds',
            'Absence of any vocalisations needs evaluation.',
          ),
          _watch(
            'No reaction to voices',
            'Limited response to voices needs review.',
          ),
        ],
        whenToWorry: [
          _warn(
            'No sound response',
            'Could indicate hearing issues — request a hearing test.',
          ),
          _warn(
            'Very weak cry',
            'Consistently weak cry needs medical evaluation.',
          ),
          _warn(
            'No vocal sounds',
            'Absence of any vocalisations needs evaluation.',
          ),
        ],
        commonConcerns: [
          _concern(
            'When will my baby start babbling?',
            'Babbling with consonants (ba, da, ma) usually begins around 4-6 months. Cooing and gurgling come first.',
          ),
        ],
        parentTips: [
          'Coo back at your baby — it encourages more vocalisation.',
          'Read books every day.',
          'Narrate your day constantly.',
        ],
      );
    case MilestoneCategory.cognitive:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 6,
        aboutText:
            'Your baby is becoming more curious and aware of surroundings.',
        milestones: [
          _m(
            'm3_co1',
            'Tracks moving objects smoothly',
            'Eyes follow slow movement.',
            cat,
            label,
          ),
          _m(
            'm3_co2',
            'Watches faces carefully',
            'Increased visual attention to faces.',
            cat,
            label,
          ),
          _m(
            'm3_co3',
            'Recognises familiar caregivers',
            'Shows preference for known people.',
            cat,
            label,
          ),
          _m(
            'm3_co4',
            'Interested in lights, colors, and movement',
            'Responds to visual stimulation.',
            cat,
            label,
          ),
          _m(
            'm3_co5',
            'Longer alert periods',
            'Increased awake and alert time.',
            cat,
            label,
          ),
        ],
        activities: [
          _a('Mirror play', 'Show baby their reflection.', '🪞', [
            'Hold baby in front of a mirror.',
            'Point to their reflection.',
            'Make faces together.',
          ]),
          _a('Visual tracking games', 'Encourage eye tracking.', '👁️', [
            'Hold a toy in front of baby.',
            'Move it slowly side to side.',
            'Watch baby\'s eyes follow.',
          ]),
          _a(
            'High-contrast or colorful toys',
            'Stimulate visual development.',
            '🖤',
            [
              'Hold toy 20-30cm away.',
              'Move it slowly.',
              'Watch baby\'s eyes track it.',
            ],
          ),
          _a('Face-to-face play', 'Hold face 20-30cm from baby.', '😊', [
            'Get close to baby\'s face.',
            'Smile slowly.',
            'Make gentle expressions.',
          ]),
        ],
        signsToLookFor: [
          _pos('Follows moving objects', 'Eyes track slow movement.'),
          _pos('Focuses on faces', 'Shows social recognition.'),
          _pos(
            'Shows curiosity about surroundings',
            'Looks around when alert.',
          ),
          _watch('No visual tracking', 'May indicate visual concerns.'),
          _watch(
            'No interest in surroundings',
            'Lack of awareness needs evaluation.',
          ),
          _watch('Difficult to wake', 'Excessive sleepiness needs evaluation.'),
          _watch(
            'No eye contact',
            'Consistent avoidance of eye contact needs evaluation.',
          ),
        ],
        whenToWorry: [
          _warn(
            'No visual tracking',
            'Contact doctor if no response to faces or light.',
          ),
          _warn(
            'No interest in surroundings',
            'Lack of any environmental awareness needs evaluation.',
          ),
          _warn(
            'No eye contact',
            'Consistent avoidance of eye contact needs evaluation.',
          ),
        ],
        commonConcerns: [
          _concern(
            'How much screen time is okay for a 3-month-old?',
            'None recommended. Screens don\'t provide the interaction babies need. Human faces, voices, and real objects are far more stimulating for brain development.',
          ),
        ],
        parentTips: [
          'Your baby is learning through eye contact, touch, movement, sounds, and everyday interaction.',
          'Simple moments like talking, smiling, cuddling, and responding to your baby are helping their brain and emotional development every single day.',
        ],
      );
    case MilestoneCategory.social:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 6,
        aboutText:
            'Your baby is becoming more socially connected and emotionally expressive.',
        milestones: [
          _m(
            'm3_so1',
            'Social smiling becomes frequent',
            'Smiles in response to faces.',
            cat,
            label,
          ),
          _m(
            'm3_so2',
            'Enjoys face-to-face interaction',
            'Shows pleasure during social play.',
            cat,
            label,
          ),
          _m(
            'm3_so3',
            'Calms when comforted',
            'Settles when picked up and comforted.',
            cat,
            label,
          ),
          _m(
            'm3_so4',
            'Shows excitement during play',
            'Increased engagement during interaction.',
            cat,
            label,
          ),
          _m(
            'm3_so5',
            'Watches caregivers closely',
            'Shows strong social interest.',
            cat,
            label,
          ),
        ],
        activities: [
          _a(
            'Smiling games',
            'Smile and talk to encourage social smiling.',
            '😊',
            [
              'Make eye contact.',
              'Smile and talk.',
              'Wait for baby\'s response.',
            ],
          ),
          _a(
            'Gentle talking and singing',
            'Consistent interaction builds connection.',
            '🎵',
            [
              'Talk during all care routines.',
              'Sing simple songs.',
              'Use baby\'s name often.',
            ],
          ),
          _a(
            'Skin-to-skin cuddles',
            'Consistent holding builds attachment.',
            '🤱',
            [
              'Hold baby against bare chest.',
              'Let baby hear your heartbeat.',
              'Talk softly.',
            ],
          ),
          _a(
            'Playful facial expressions',
            'Teach social connection through faces.',
            '😄',
            [
              'Make exaggerated expressions.',
              'Stick out your tongue.',
              'Watch baby copy.',
            ],
          ),
        ],
        signsToLookFor: [
          _pos(
            'Smiles during interaction',
            'Social smile in response to faces.',
          ),
          _pos(
            'Enjoys eye contact',
            'Shows pleasure during social interaction.',
          ),
          _pos(
            'Calms when held or spoken to',
            'Settles with familiar voice or touch.',
          ),
          _watch(
            'Rarely responds to interaction',
            'Limited social response needs evaluation.',
          ),
          _watch(
            'No smiling',
            'Absence of social smile by 3 months needs evaluation.',
          ),
          _watch(
            'No eye contact',
            'Consistent avoidance of eye contact needs evaluation.',
          ),
          _watch(
            'No calming with comfort',
            'Persistent inconsolability needs review.',
          ),
        ],
        whenToWorry: [
          _warn(
            'Rarely responds to interaction',
            'Limited social response needs evaluation.',
          ),
          _warn(
            'No smiling',
            'Absence of social smile by 3 months needs evaluation.',
          ),
          _warn(
            'No eye contact',
            'Consistent avoidance of eye contact needs evaluation.',
          ),
        ],
        commonConcerns: [
          _concern(
            'My baby cries when I put them down. Is that normal?',
            'Yes. Babies this age need closeness and contact. Gradually introduce short periods of independent play as baby gets older.',
          ),
        ],
        parentTips: [
          'Smile and talk to your baby constantly.',
          'Play peek-a-boo and tickle games every day.',
          'Simple everyday moments like talking, smiling, cuddling, and responding to your baby are helping their brain and emotional development every single day.',
        ],
      );
    case MilestoneCategory.feedingSleep:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 6,
        aboutText:
            'Some babies begin developing slightly more predictable feeding and sleeping rhythms.',
        milestones: [
          _m(
            'm3_fs1',
            'Feeds every 3–4 hours',
            'Feeding intervals may be lengthening.',
            cat,
            label,
          ),
          _m(
            'm3_fs2',
            'Longer awake windows',
            'More alert time between feeds.',
            cat,
            label,
          ),
          _m(
            'm3_fs3',
            'May sleep longer stretches at night',
            'Some babies sleep 5-6 hours.',
            cat,
            label,
          ),
          _m(
            'm3_fs4',
            'More active daytime periods',
            'Increased awake time during the day.',
            cat,
            label,
          ),
        ],
        activities: [
          _a('Feed on demand', 'Feed whenever baby shows hunger cues.', '🍼', [
            'Watch for rooting and sucking cues.',
            'Feed before crying starts.',
            'Let baby feed until satisfied.',
          ]),
          _a(
            'Gentle bedtime routine',
            'Consistent routine helps sleep.',
            '😴',
            [
              'Bath, feed, song, sleep — in the same order.',
              'Keep it to 20-30 minutes.',
              'Same time every night.',
            ],
          ),
          _a(
            'Burp after feeding',
            'Reduces discomfort from swallowed air.',
            '🤱',
            [
              'Hold baby upright.',
              'Gently pat or rub back.',
              'Wait 5-10 minutes.',
            ],
          ),
          _a(
            'Calm nighttime environment',
            'Keep nighttime feeds quiet and dim.',
            '🌙',
            [
              'Avoid bright lights at night.',
              'Keep interaction minimal.',
              'Use a calm voice.',
            ],
          ),
        ],
        signsToLookFor: [
          _pos('Regular wet diapers', '6+ wet diapers per day.'),
          _pos('Feeding interest', 'Shows hunger cues regularly.'),
          _pos('Calm after feeding', 'Settles after feeds.'),
          _pos('Active alert periods', 'More awake time during the day.'),
          _watch('Poor feeding', 'Difficulty feeding needs support.'),
          _watch(
            'Persistent vomiting',
            'Forceful or very frequent vomiting needs evaluation.',
          ),
          _watch('Fewer wet diapers', 'May indicate inadequate feeding.'),
          _watch('Difficulty waking for feeds', 'Needs medical attention.'),
          _watch(
            'Excessive sleepiness',
            'Difficulty waking for feeds needs attention.',
          ),
        ],
        whenToWorry: [
          _warn('Poor feeding', 'Contact lactation consultant or doctor.'),
          _warn(
            'Persistent vomiting',
            'Forceful or very frequent vomiting needs medical evaluation.',
          ),
          _warn(
            'Fewer wet diapers',
            'Fewer than 6 wet diapers needs evaluation.',
          ),
          _warn('Difficulty waking for feeds', 'Needs medical attention.'),
        ],
        commonConcerns: [
          _concern(
            'My baby has short naps. Is that normal?',
            'Yes. Short naps (30-45 minutes) are very common in the first 3-4 months. Nap consolidation usually improves around 4-6 months.',
          ),
          _concern(
            'Is a sleep regression normal at 3 months?',
            'Yes. Many babies experience a sleep regression around 3-4 months as their sleep cycles mature. It is temporary.',
          ),
          _concern(
            'My baby is drooling a lot and chewing their hands. Is that teething?',
            'Increased drooling and hand-chewing are common from 3 months due to developing salivary glands. Teething usually starts between 4-7 months.',
          ),
        ],
        parentTips: [
          'Start a simple bedtime routine now — it pays off later.',
          'Watch for tired cues and put baby down before overtired.',
          'The "eat-play-sleep" cycle helps distinguish day from night.',
        ],
      );
  }
}

// ── Month 4 (16–20 weeks) ─────────────────────────────────────────────────────

CategoryGuidance _month4(MilestoneCategory cat) {
  const label = '3-4 Months';
  switch (cat) {
    case MilestoneCategory.grossMotor:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 7,
        aboutText:
            'Your baby\'s muscles are getting stronger, helping with better head control and more purposeful body movement.',
        milestones: [
          _m(
            'm4_gm1',
            'Holds head steady without support',
            'Good head control established.',
            cat,
            label,
          ),
          _m(
            'm4_gm2',
            'Pushes up strongly during tummy time',
            'Lifts chest fully off the floor.',
            cat,
            label,
          ),
          _m(
            'm4_gm3',
            'Rolls from tummy to back (some babies)',
            'Early rolling beginning.',
            cat,
            label,
          ),
          _m(
            'm4_gm4',
            'Kicks energetically',
            'Strong leg movement.',
            cat,
            label,
          ),
          _m(
            'm4_gm5',
            'Bears some weight on legs when supported',
            'Pushes down with legs when held upright.',
            cat,
            label,
          ),
        ],
        activities: [
          _a(
            'Daily tummy time',
            'Increase to 20-30 minutes spread through the day.',
            '🍼',
            [
              'Lay baby on firm surface.',
              'Get down to their level.',
              'Increase time gradually.',
            ],
          ),
          _a('Floor play', 'Give baby space to move freely.', '🧸', [
            'Place baby on a soft mat.',
            'Surround with safe toys.',
            'Let baby explore freely.',
          ]),
          _a(
            'Assisted sitting support',
            'Practice sitting with minimal support.',
            '🪑',
            [
              'Sit baby between your legs.',
              'Gradually reduce support.',
              'Use a Boppy pillow for independent practice.',
            ],
          ),
          _a(
            'Encourage reaching for toys',
            'Place toys just within reach.',
            '🎯',
            [
              'Dangle a toy above baby.',
              'Move it slowly.',
              'Celebrate when baby reaches.',
            ],
          ),
        ],
        signsToLookFor: [
          _pos('Good head control', 'Head stays up without wobbling.'),
          _pos(
            'Pushes chest up during tummy time',
            'Building strength for rolling.',
          ),
          _pos(
            'Strong kicking and arm movement',
            'Active limb movement on both sides.',
          ),
          _pos('Attempts rolling movements', 'Early rolling behaviour.'),
          _watch(
            'Poor head control',
            'Head still very floppy at 4 months needs evaluation.',
          ),
          _watch(
            'Very stiff or floppy body',
            'Either extreme needs evaluation.',
          ),
          _watch('Very little movement', 'Minimal movement needs review.'),
          _watch(
            'Strong preference for one side only',
            'Asymmetric movement needs assessment.',
          ),
        ],
        whenToWorry: [
          _warn(
            'Poor head control',
            'Head still very floppy at 4 months needs evaluation.',
          ),
          _warn(
            'Very stiff or floppy body',
            'Either extreme may indicate a concern.',
          ),
          _warn(
            'Very little movement',
            'Minimal spontaneous movement needs evaluation.',
          ),
          _warn(
            'Strong preference for one side only',
            'Asymmetric movement should be assessed.',
          ),
        ],
        commonConcerns: [
          _concern(
            'My baby rolled over once but hasn\'t done it again. Should I worry?',
            'No. Early rolling is often accidental. Consistent rolling usually develops between 4-6 months. Keep doing tummy time to build the strength.',
          ),
          _concern(
            'Is a sleep regression normal at 4 months?',
            'Yes. The 4-month sleep regression is very common and happens as baby\'s sleep cycles mature. It is temporary but can last 2-6 weeks.',
          ),
        ],
        parentTips: [
          'Your baby is learning rapidly through movement, touch, sounds, faces, play, and connection.',
          'Simple everyday moments like talking, cuddling, tummy time, and smiling help your baby\'s brain and emotional development grow beautifully.',
        ],
      );
    case MilestoneCategory.fineMotor:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 7,
        aboutText: 'Your baby is beginning to use hands more intentionally.',
        milestones: [
          _m(
            'm4_fm1',
            'Reaches toward toys',
            'Intentional reaching toward objects.',
            cat,
            label,
          ),
          _m(
            'm4_fm2',
            'Grasps objects briefly',
            'Holds objects for a short time.',
            cat,
            label,
          ),
          _m(
            'm4_fm3',
            'Brings toys/hands to mouth',
            'Hand-to-mouth movement.',
            cat,
            label,
          ),
          _m(
            'm4_fm4',
            'Swipes at hanging toys',
            'Early reaching behaviour.',
            cat,
            label,
          ),
          _m(
            'm4_fm5',
            'Watches hands closely',
            'Visual attention to own hands.',
            cat,
            label,
          ),
        ],
        activities: [
          _a('Soft rattles', 'Introduce simple sensory toys.', '🪀', [
            'Place rattle in baby\'s hand.',
            'Let them feel the texture.',
            'React with excitement.',
          ]),
          _a('Hanging toys', 'Encourage reaching and swiping.', '🎯', [
            'Hang toys within reach.',
            'Let baby swipe at them.',
            'Celebrate contact.',
          ]),
          _a(
            'Textured toys',
            'Different textures stimulate development.',
            '🧸',
            [
              'Offer toys with different textures.',
              'Let baby explore by touching.',
              'Name the textures.',
            ],
          ),
          _a('Hand-to-hand play', 'Encourage using both hands.', '🤝', [
            'Give baby a toy that requires two hands.',
            'Demonstrate holding with both hands.',
            'Clap baby\'s hands together gently.',
          ]),
        ],
        signsToLookFor: [
          _pos('Reaching toward objects', 'Intentional reaching behaviour.'),
          _pos('Holding toys briefly', 'Grasps and holds objects.'),
          _pos('Bringing hands to mouth', 'Hand-to-mouth movement.'),
          _pos('Active hand exploration', 'Uses hands to explore objects.'),
          _watch(
            'No reaching attempts',
            'No interest in reaching for toys needs evaluation.',
          ),
          _watch(
            'Persistent tight fists',
            'Hands always clenched needs review.',
          ),
          _watch(
            'Unequal arm movement',
            'Strong hand preference before 12 months needs evaluation.',
          ),
          _watch(
            'Very limited hand activity',
            'Minimal hand use needs evaluation.',
          ),
        ],
        whenToWorry: [
          _warn(
            'No reaching attempts',
            'If baby shows no interest in reaching for toys, mention to your doctor.',
          ),
          _warn(
            'Persistent tight fists',
            'Hands always clenched after 3 months needs review.',
          ),
          _warn(
            'Unequal arm movement',
            'Strong hand preference before 12 months needs evaluation.',
          ),
        ],
        commonConcerns: [
          _concern(
            'My baby drops everything. Is that normal?',
            'Yes. Babies this age are learning to grasp and release. Dropping is part of the learning process.',
          ),
        ],
        parentTips: [
          'Dangle colourful toys just within reach to encourage grasping.',
          'Let baby feel different textures — it builds sensory pathways.',
          'Offer a variety of safe objects to explore.',
        ],
      );
    case MilestoneCategory.language:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 7,
        aboutText: 'Your baby is becoming more vocal and interactive.',
        milestones: [
          _m(
            'm4_la1',
            'Laughs or squeals',
            'First laughs and excited sounds.',
            cat,
            label,
          ),
          _m(
            'm4_la2',
            'Coos frequently',
            'Increased vowel-like vocalisations.',
            cat,
            label,
          ),
          _m(
            'm4_la3',
            'Responds to voices',
            'Calms or turns toward familiar voices.',
            cat,
            label,
          ),
          _m(
            'm4_la4',
            'Makes sounds during interaction',
            'Vocalises when engaged.',
            cat,
            label,
          ),
          _m(
            'm4_la5',
            'Expresses excitement vocally',
            'Happy sounds during play.',
            cat,
            label,
          ),
        ],
        activities: [
          _a('Talk frequently', 'Narrate everything you do.', '💬', [
            'Describe what you are doing.',
            'Use a warm voice.',
            'Pause and wait for baby\'s response.',
          ]),
          _a(
            'Sing songs',
            'Singing helps baby learn rhythm and language.',
            '🎵',
            [
              'Choose 2-3 simple songs.',
              'Sing consistently.',
              'Use actions with songs.',
            ],
          ),
          _a(
            'Read colorful books',
            'Reading builds language foundations.',
            '📚',
            [
              'Choose simple board books.',
              'Point to pictures.',
              'Use an expressive voice.',
            ],
          ),
          _a(
            'Mimic baby sounds',
            'Copying sounds teaches turn-taking.',
            '🗣️',
            ['When baby coos, coo back.', 'Pause and wait.', 'Take turns.'],
          ),
        ],
        signsToLookFor: [
          _pos(
            'Smiles and vocalises during interaction',
            'Social communication developing.',
          ),
          _pos(
            'Responds to familiar voices',
            'Recognises and responds to known voices.',
          ),
          _pos('Makes different sounds', 'Varied vocalisations.'),
          _watch('No sound response', 'May indicate hearing concerns.'),
          _watch(
            'No vocal sounds',
            'Absence of any vocalisations needs evaluation.',
          ),
          _watch('Very weak cry', 'Consistently weak cry needs evaluation.'),
          _watch(
            'No reaction to voices',
            'Limited response to voices needs review.',
          ),
        ],
        whenToWorry: [
          _warn(
            'No sound response',
            'Could indicate hearing issues — request a hearing test.',
          ),
          _warn(
            'No vocal sounds',
            'Absence of any vocalisations needs evaluation.',
          ),
          _warn(
            'Very weak cry',
            'Consistently weak cry needs medical evaluation.',
          ),
        ],
        commonConcerns: [
          _concern(
            'When will my baby start babbling?',
            'Babbling with consonants (ba, da, ma) usually begins around 4-6 months. Cooing and gurgling come first.',
          ),
        ],
        parentTips: [
          'Talk to your baby constantly — narrate your day.',
          'Respond to every babble and gesture.',
          'Read books every day.',
        ],
      );
    case MilestoneCategory.cognitive:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 7,
        aboutText:
            'Your baby is becoming more curious and aware of surroundings.',
        milestones: [
          _m(
            'm4_co1',
            'Tracks moving objects smoothly',
            'Eyes follow slow movement.',
            cat,
            label,
          ),
          _m(
            'm4_co2',
            'Watches faces carefully',
            'Increased visual attention to faces.',
            cat,
            label,
          ),
          _m(
            'm4_co3',
            'Explores surroundings visually',
            'Looks around when alert.',
            cat,
            label,
          ),
          _m(
            'm4_co4',
            'Recognises familiar people',
            'Shows preference for known people.',
            cat,
            label,
          ),
          _m(
            'm4_co5',
            'Shows curiosity about toys',
            'Interested in objects.',
            cat,
            label,
          ),
        ],
        activities: [
          _a('Mirror play', 'Show baby their reflection.', '🪞', [
            'Hold baby in front of a mirror.',
            'Point to their reflection.',
            'Make faces together.',
          ]),
          _a('Visual tracking games', 'Encourage eye tracking.', '👁️', [
            'Hold a toy in front of baby.',
            'Move it slowly side to side.',
            'Watch baby\'s eyes follow.',
          ]),
          _a('Peek-a-boo', 'Builds object permanence.', '👀', [
            'Cover your face.',
            'Say "Where\'s Mummy?"',
            'Reveal with "Peek-a-boo!"',
          ]),
          _a('Bright colorful toys', 'Stimulate visual development.', '🎨', [
            'Offer toys with bright colours.',
            'Let baby explore visually.',
            'Name the colours.',
          ]),
        ],
        signsToLookFor: [
          _pos('Follows movement with eyes', 'Eyes track slow movement.'),
          _pos('Interested in surroundings', 'Looks around when alert.'),
          _pos('Focuses on toys and faces', 'Shows visual interest.'),
          _watch('No visual tracking', 'May indicate visual concerns.'),
          _watch(
            'No interest in surroundings',
            'Lack of awareness needs evaluation.',
          ),
          _watch(
            'No eye contact',
            'Consistent avoidance of eye contact needs evaluation.',
          ),
          _watch('Difficult to engage', 'Limited engagement needs review.'),
        ],
        whenToWorry: [
          _warn(
            'No visual tracking',
            'Contact doctor if no response to faces or light.',
          ),
          _warn(
            'No interest in surroundings',
            'Lack of any environmental awareness needs evaluation.',
          ),
          _warn(
            'No eye contact',
            'Consistent avoidance of eye contact needs evaluation.',
          ),
        ],
        commonConcerns: [
          _concern(
            'My baby is distracted during feeds. Is that normal?',
            'Yes. As babies become more aware of their surroundings, they get distracted during feeds. Try feeding in a quiet, dim room.',
          ),
        ],
        parentTips: [
          'Your baby is learning rapidly through movement, touch, sounds, faces, play, and connection.',
          'Simple everyday moments like talking, cuddling, tummy time, and smiling help your baby\'s brain and emotional development grow beautifully.',
        ],
      );
    case MilestoneCategory.social:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 7,
        aboutText: 'Your baby is becoming much more socially expressive.',
        milestones: [
          _m(
            'm4_so1',
            'Smiles socially often',
            'Frequent social smiling.',
            cat,
            label,
          ),
          _m(
            'm4_so2',
            'Laughs during play',
            'First laughs in response to interaction.',
            cat,
            label,
          ),
          _m(
            'm4_so3',
            'Enjoys interaction',
            'Shows pleasure during social play.',
            cat,
            label,
          ),
          _m(
            'm4_so4',
            'Recognises familiar caregivers',
            'Shows preference for known people.',
            cat,
            label,
          ),
          _m(
            'm4_so5',
            'Shows excitement during attention',
            'Increased engagement during interaction.',
            cat,
            label,
          ),
        ],
        activities: [
          _a(
            'Face-to-face play',
            'Smile and talk to encourage social smiling.',
            '😊',
            [
              'Make eye contact.',
              'Smile and talk.',
              'Wait for baby\'s response.',
            ],
          ),
          _a('Smiling games', 'Encourage social smiling.', '😄', [
            'Make exaggerated expressions.',
            'Stick out your tongue.',
            'Watch baby copy.',
          ]),
          _a(
            'Gentle tickling/playful interaction',
            'Encourages laughter and social engagement.',
            '😂',
            [
              'Gently tickle baby\'s tummy or feet.',
              'React to their laughter.',
              'Pause and let them anticipate the next tickle.',
            ],
          ),
          _a(
            'Singing and talking',
            'Consistent interaction builds connection.',
            '🎵',
            [
              'Talk during all care routines.',
              'Sing simple songs.',
              'Use baby\'s name often.',
            ],
          ),
        ],
        signsToLookFor: [
          _pos(
            'Smiles during interaction',
            'Social smile in response to faces.',
          ),
          _pos('Enjoys attention', 'Shows pleasure during social interaction.'),
          _pos('Calms when comforted', 'Settles with familiar voice or touch.'),
          _pos('Watches caregiver expressions', 'Shows social interest.'),
          _watch('Rarely smiles', 'Absence of social smile needs evaluation.'),
          _watch(
            'No eye contact',
            'Consistent avoidance of eye contact needs evaluation.',
          ),
          _watch(
            'No response to interaction',
            'Limited social response needs evaluation.',
          ),
          _watch(
            'Does not calm with comfort',
            'Persistent inconsolability needs review.',
          ),
        ],
        whenToWorry: [
          _warn(
            'Rarely smiles',
            'Absence of social smile by 4 months needs evaluation.',
          ),
          _warn(
            'No eye contact',
            'Consistent avoidance of eye contact needs evaluation.',
          ),
          _warn(
            'No response to interaction',
            'Limited social response needs evaluation.',
          ),
        ],
        commonConcerns: [
          _concern(
            'My baby cries when strangers hold them. Is that normal?',
            'Stranger anxiety typically peaks at 6-9 months but can start earlier. It\'s a sign of healthy attachment.',
          ),
        ],
        parentTips: [
          'Smile and talk to your baby constantly.',
          'Play peek-a-boo and tickle games every day.',
          'Introduce baby to other friendly faces regularly.',
        ],
      );
    case MilestoneCategory.feedingSleep:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 7,
        aboutText:
            'Some babies begin developing more predictable feeding and sleeping routines.',
        milestones: [
          _m(
            'm4_fs1',
            'Feeds every 3–4 hours',
            'Feeding intervals lengthening.',
            cat,
            label,
          ),
          _m(
            'm4_fs2',
            'Longer awake windows',
            'More alert time between feeds.',
            cat,
            label,
          ),
          _m(
            'm4_fs3',
            'May sleep longer stretches at night',
            'Some babies sleep 6-8 hours.',
            cat,
            label,
          ),
          _m(
            'm4_fs4',
            'More active during daytime',
            'Increased awake time during the day.',
            cat,
            label,
          ),
        ],
        activities: [
          _a('Feed on demand', 'Feed whenever baby shows hunger cues.', '🍼', [
            'Watch for rooting and sucking cues.',
            'Feed before crying starts.',
            'Let baby feed until satisfied.',
          ]),
          _a(
            'Gentle bedtime routine',
            'Consistent routine helps sleep.',
            '😴',
            [
              'Bath, feed, song, sleep — in the same order.',
              'Keep it to 20-30 minutes.',
              'Same time every night.',
            ],
          ),
          _a(
            'Burp after feeds',
            'Reduces discomfort from swallowed air.',
            '🤱',
            [
              'Hold baby upright.',
              'Gently pat or rub back.',
              'Wait 5-10 minutes.',
            ],
          ),
          _a(
            'Daytime interaction/play',
            'Active daytime helps sleep at night.',
            '🎮',
            [
              'Engage baby during awake periods.',
              'Play on the floor.',
              'Talk and sing.',
            ],
          ),
        ],
        signsToLookFor: [
          _pos('Feeding interest', 'Shows hunger cues regularly.'),
          _pos('Regular wet diapers', '6+ wet diapers per day.'),
          _pos('Calm after feeds', 'Settles after feeding.'),
          _pos('Active awake periods', 'More alert time during the day.'),
          _watch('Poor feeding', 'Difficulty feeding needs support.'),
          _watch(
            'Persistent vomiting',
            'Forceful or very frequent vomiting needs evaluation.',
          ),
          _watch('Fewer wet diapers', 'May indicate inadequate feeding.'),
          _watch(
            'Extreme sleepiness',
            'Difficulty waking for feeds needs attention.',
          ),
          _watch('Difficulty waking', 'Needs medical attention.'),
        ],
        whenToWorry: [
          _warn('Poor feeding', 'Contact lactation consultant or doctor.'),
          _warn(
            'Persistent vomiting',
            'Forceful or very frequent vomiting needs medical evaluation.',
          ),
          _warn(
            'Fewer wet diapers',
            'Fewer than 6 wet diapers needs evaluation.',
          ),
          _warn(
            'Extreme sleepiness',
            'Difficulty waking for feeds needs attention.',
          ),
        ],
        commonConcerns: [
          _concern(
            'Is a sleep regression normal at 4 months?',
            'Yes. The 4-month sleep regression is very common and happens as baby\'s sleep cycles mature. It is temporary but can last 2-6 weeks.',
          ),
          _concern(
            'My baby is distracted during feeds. What can I do?',
            'Try feeding in a quiet, dim room. Distracted feeding is very common from 3-4 months as babies become more aware of their surroundings.',
          ),
          _concern(
            'My baby is rolling attempts and short naps. Is that normal?',
            'Yes. Rolling attempts, sleep regressions, increased drooling, hand chewing, and distracted feeding are all common at this stage.',
          ),
        ],
        parentTips: [
          'Start a simple bedtime routine now — it pays off later.',
          'Watch for tired cues and put baby down before overtired.',
          'Active daytime play helps baby sleep better at night.',
        ],
      );
  }
}

// ── Month 5 (20–24 weeks) ─────────────────────────────────────────────────────

CategoryGuidance _month5(MilestoneCategory cat) {
  const label = '4-5 Months';
  switch (cat) {
    case MilestoneCategory.grossMotor:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 8,
        aboutText:
            'Your baby\'s muscles and coordination are getting stronger, helping with more controlled movement and body balance.',
        milestones: [
          _m(
            'm5_gm1',
            'Rolls from tummy to back',
            'Rolls over from front to back.',
            cat,
            label,
          ),
          _m(
            'm5_gm2',
            'May begin rolling both directions',
            'Rolling in both directions.',
            cat,
            label,
          ),
          _m(
            'm5_gm3',
            'Pushes up strongly during tummy time',
            'Lifts chest fully off the floor.',
            cat,
            label,
          ),
          _m(
            'm5_gm4',
            'Holds head very steady',
            'Good head control established.',
            cat,
            label,
          ),
          _m(
            'm5_gm5',
            'Bears weight on legs when supported',
            'Pushes down with legs when held upright.',
            cat,
            label,
          ),
          _m(
            'm5_gm6',
            'May begin sitting briefly with support',
            'Early sitting with support.',
            cat,
            label,
          ),
        ],
        activities:
            [
              _a(
                'Daily tummy time',
                'Increase to 20-30 minutes spread through the day.',
                '🍼',
                [
                  'Lay baby on firm surface.',
                  'Get down to their level.',
                  'Increase time gradually.',
                ],
              ),
              _a(
                'Encourage rolling with toys',
                'Use a toy to encourage rolling.',
                '🪀',
                [
                  'Place baby on their back.',
                  'Hold a toy to one side.',
                  'Encourage them to roll toward it.',
                ],
              ),
              _a(
                'Assisted sitting practice',
                'Practice sitting with minimal support.',
                '🪑',
                [
                  'Sit baby between your legs.',
                  'Gradually reduce support.',
                  'Use a Boppy pillow.',
                ],
              ),
              _a(
                'Floor play with safe space',
                'Give baby space to move freely.',
                '🧸',
                [
                  'Place baby on a soft mat.',
                  'Surround with safe toys.',
                  'Let baby explore freely.',
                ],
              ),
            ],
        signsToLookFor: [
          _pos('Strong head control', 'Head stays up without wobbling.'),
          _pos('Rolling attempts', 'Early rolling behaviour.'),
          _pos(
            'Pushes chest up during tummy time',
            'Building strength for crawling.',
          ),
          _pos(
            'Active kicking and reaching',
            'Active limb movement on both sides.',
          ),
          _watch(
            'Poor head control',
            'Head still very floppy needs evaluation.',
          ),
          _watch(
            'Very stiff or floppy body',
            'Either extreme needs evaluation.',
          ),
          _watch('No rolling attempts', 'No progress in rolling needs review.'),
          _watch(
            'Uses one side much less',
            'Asymmetric movement should be assessed.',
          ),
        ],
        whenToWorry: [
          _warn(
            'Poor head control',
            'Contact doctor if head control has not improved.',
          ),
          _warn(
            'Very stiff or floppy body',
            'Either extreme may indicate a concern.',
          ),
          _warn(
            'No rolling attempts',
            'No rolling attempts by 6 months needs evaluation.',
          ),
          _warn(
            'Uses one side much less',
            'Asymmetric movement should be assessed.',
          ),
        ],
        commonConcerns: [
          _concern(
            'My baby is rolling everywhere. How do I keep them safe?',
            'Never leave baby unattended on elevated surfaces. Baby-proof your floor — rolling babies move faster than you expect.',
          ),
          _concern(
            'Is a sleep regression normal at 5 months?',
            'Yes. Sleep regressions are common at 4-6 months as baby\'s sleep cycles mature. They are temporary.',
          ),
        ],
        parentTips: [
          'Give baby lots of floor time — it\'s the gym for their development.',
          'Tummy time is still important even when baby can roll.',
          'Baby-proof your floor — rolling babies move faster than you expect.',
        ],
      );
    case MilestoneCategory.fineMotor:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 8,
        aboutText:
            'Your baby is using hands more intentionally to explore the world.',
        milestones: [
          _m(
            'm5_fm1',
            'Reaches for toys intentionally',
            'Intentional reaching toward objects.',
            cat,
            label,
          ),
          _m(
            'm5_fm2',
            'Grasps and holds objects longer',
            'Holds objects for longer periods.',
            cat,
            label,
          ),
          _m(
            'm5_fm3',
            'Transfers toys between hands (some babies)',
            'Passes toy from one hand to the other.',
            cat,
            label,
          ),
          _m(
            'm5_fm4',
            'Brings objects to mouth',
            'Hand-to-mouth movement.',
            cat,
            label,
          ),
          _m(
            'm5_fm5',
            'Explores textures with hands',
            'Uses hands to explore objects.',
            cat,
            label,
          ),
        ],
        activities: [
          _a('Soft rattles', 'Introduce simple sensory toys.', '🪀', [
            'Place rattle in baby\'s hand.',
            'Let them feel the texture.',
            'React with excitement.',
          ]),
          _a(
            'Textured toys',
            'Different textures stimulate development.',
            '🧸',
            [
              'Offer toys with different textures.',
              'Let baby explore by touching.',
              'Name the textures.',
            ],
          ),
          _a('Sensory play', 'Stimulate sensory development.', '🎨', [
            'Offer objects with different textures.',
            'Let baby feel and mouth each one.',
            'Name the textures.',
          ]),
          _a(
            'Hand-to-hand toy transfer games',
            'Encourage using both hands.',
            '🤝',
            [
              'Give baby a toy.',
              'Encourage passing it to the other hand.',
              'Celebrate success.',
            ],
          ),
        ],
        signsToLookFor: [
          _pos('Intentional reaching', 'Reaches toward objects on purpose.'),
          _pos('Holding toys briefly', 'Grasps and holds objects.'),
          _pos('Hand exploration', 'Uses hands to explore objects.'),
          _pos('Brings toys toward mouth', 'Hand-to-mouth movement.'),
          _watch(
            'No reaching attempts',
            'No interest in reaching needs evaluation.',
          ),
          _watch(
            'Persistent tight fists',
            'Hands always clenched needs review.',
          ),
          _watch(
            'Very limited hand movement',
            'Minimal hand use needs evaluation.',
          ),
          _watch(
            'Unequal use of hands',
            'Strong hand preference before 12 months needs evaluation.',
          ),
        ],
        whenToWorry: [
          _warn(
            'No reaching attempts',
            'If baby shows no interest in reaching for toys, mention to your doctor.',
          ),
          _warn(
            'Persistent tight fists',
            'Hands always clenched needs review.',
          ),
          _warn(
            'Unequal use of hands',
            'Strong hand preference before 12 months needs evaluation.',
          ),
        ],
        commonConcerns: [
          _concern(
            'My baby puts everything in their mouth. Is that safe?',
            'Mouthing is normal and important for sensory development. Ensure all objects are larger than a toilet roll tube (choking hazard check) and clean.',
          ),
        ],
        parentTips: [
          'Offer a variety of safe objects to explore.',
          'Let baby feel different textures — it builds sensory pathways.',
          'Ensure all toys are clean and large enough to be safe.',
        ],
      );
    case MilestoneCategory.language:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 8,
        aboutText:
            'Your baby is becoming more vocal, expressive, and socially responsive.',
        milestones: [
          _m(
            'm5_la1',
            'Laughs loudly',
            'Loud laughs in response to interaction.',
            cat,
            label,
          ),
          _m(
            'm5_la2',
            'Coos frequently',
            'Increased vowel-like vocalisations.',
            cat,
            label,
          ),
          _m(
            'm5_la3',
            'Squeals with excitement',
            'High-pitched excited sounds.',
            cat,
            label,
          ),
          _m(
            'm5_la4',
            'Responds to voices',
            'Calms or turns toward familiar voices.',
            cat,
            label,
          ),
          _m(
            'm5_la5',
            'Makes sounds during play',
            'Vocalises when engaged.',
            cat,
            label,
          ),
        ],
        activities: [
          _a('Talk during routines', 'Narrate everything you do.', '💬', [
            'Describe what you are doing.',
            'Use a warm voice.',
            'Pause and wait for baby\'s response.',
          ]),
          _a(
            'Sing songs',
            'Singing helps baby learn rhythm and language.',
            '🎵',
            [
              'Choose 2-3 simple songs.',
              'Sing consistently.',
              'Use actions with songs.',
            ],
          ),
          _a(
            'Read colorful books',
            'Reading builds language foundations.',
            '📚',
            [
              'Choose simple board books.',
              'Point to pictures.',
              'Use an expressive voice.',
            ],
          ),
          _a(
            'Mimic baby sounds',
            'Copying sounds teaches turn-taking.',
            '🗣️',
            ['When baby coos, coo back.', 'Pause and wait.', 'Take turns.'],
          ),
        ],
        signsToLookFor: [
          _pos('Vocalises during interaction', 'Makes sounds when engaged.'),
          _pos(
            'Responds to familiar voices',
            'Recognises and responds to known voices.',
          ),
          _pos('Laughs or squeals', 'Excited vocalisations.'),
          _pos(
            'Watches faces while listening',
            'Shows interest in communication.',
          ),
          _watch('No sound response', 'May indicate hearing concerns.'),
          _watch(
            'No vocal sounds',
            'Absence of any vocalisations needs evaluation.',
          ),
          _watch('Very weak cry', 'Consistently weak cry needs evaluation.'),
          _watch(
            'No reaction to voices',
            'Limited response to voices needs review.',
          ),
        ],
        whenToWorry: [
          _warn(
            'No sound response',
            'Could indicate hearing issues — request a hearing test.',
          ),
          _warn(
            'No vocal sounds',
            'Absence of any vocalisations needs evaluation.',
          ),
          _warn(
            'Very weak cry',
            'Consistently weak cry needs medical evaluation.',
          ),
        ],
        commonConcerns: [
          _concern(
            'When will my baby start babbling?',
            'Babbling with consonants (ba, da, ma) usually begins around 4-6 months. Cooing and gurgling come first.',
          ),
        ],
        parentTips: [
          'Talk to your baby constantly — narrate your day.',
          'Respond to every babble and gesture.',
          'Read books every day.',
        ],
      );
    case MilestoneCategory.cognitive:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 8,
        aboutText:
            'Your baby is becoming more curious, alert, and interested in cause-and-effect learning.',
        milestones: [
          _m(
            'm5_co1',
            'Watches moving objects carefully',
            'Eyes follow slow movement.',
            cat,
            label,
          ),
          _m(
            'm5_co2',
            'Explores toys visually and orally',
            'Examines toys by looking and mouthing.',
            cat,
            label,
          ),
          _m(
            'm5_co3',
            'Recognises familiar people',
            'Shows preference for known people.',
            cat,
            label,
          ),
          _m(
            'm5_co4',
            'Interested in surroundings',
            'Looks around when alert.',
            cat,
            label,
          ),
          _m(
            'm5_co5',
            'Anticipates interaction/play',
            'Shows excitement before familiar games.',
            cat,
            label,
          ),
        ],
        activities: [
          _a('Mirror play', 'Show baby their reflection.', '🪞', [
            'Hold baby in front of a mirror.',
            'Point to their reflection.',
            'Make faces together.',
          ]),
          _a('Peek-a-boo', 'Builds object permanence.', '👀', [
            'Cover your face.',
            'Say "Where\'s Mummy?"',
            'Reveal with "Peek-a-boo!"',
          ]),
          _a('Visual tracking games', 'Encourage eye tracking.', '👁️', [
            'Hold a toy in front of baby.',
            'Move it slowly side to side.',
            'Watch baby\'s eyes follow.',
          ]),
          _a('Cause-and-effect toys', 'Teach cause and effect.', '🔔', [
            'Give baby a toy that makes sound when shaken.',
            'React with excitement.',
            'Repeat to reinforce the connection.',
          ]),
        ],
        signsToLookFor: [
          _pos('Follows objects with eyes', 'Eyes track slow movement.'),
          _pos('Curious about toys', 'Shows interest in objects.'),
          _pos('Watches caregiver actions', 'Shows social interest.'),
          _pos('Alert during play', 'Engaged and curious during awake time.'),
          _watch('No visual tracking', 'May indicate visual concerns.'),
          _watch(
            'No interest in surroundings',
            'Lack of awareness needs evaluation.',
          ),
          _watch(
            'No eye contact',
            'Consistent avoidance of eye contact needs evaluation.',
          ),
          _watch('Difficult to engage', 'Limited engagement needs review.'),
        ],
        whenToWorry: [
          _warn(
            'No visual tracking',
            'Contact doctor if no response to faces or light.',
          ),
          _warn(
            'No interest in surroundings',
            'Lack of any environmental awareness needs evaluation.',
          ),
          _warn(
            'No eye contact',
            'Consistent avoidance of eye contact needs evaluation.',
          ),
        ],
        commonConcerns: [
          _concern(
            'My baby is distracted during feeds. What can I do?',
            'Try feeding in a quiet, dim room. Distracted feeding is very common from 4-5 months as babies become more aware of their surroundings.',
          ),
        ],
        parentTips: [
          'Give toys that make sounds when pressed or shaken.',
          'Play drop-and-find games to build object permanence.',
          'Rotate toys to keep things interesting.',
        ],
      );
    case MilestoneCategory.social:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 8,
        aboutText:
            'Your baby is becoming more socially connected and emotionally expressive.',
        milestones: [
          _m(
            'm5_so1',
            'Smiles socially often',
            'Frequent social smiling.',
            cat,
            label,
          ),
          _m(
            'm5_so2',
            'Laughs during play',
            'Laughs in response to interaction.',
            cat,
            label,
          ),
          _m(
            'm5_so3',
            'Enjoys attention and interaction',
            'Shows pleasure during social play.',
            cat,
            label,
          ),
          _m(
            'm5_so4',
            'Recognises familiar caregivers',
            'Shows preference for known people.',
            cat,
            label,
          ),
          _m(
            'm5_so5',
            'Shows excitement during social play',
            'Increased engagement during interaction.',
            cat,
            label,
          ),
        ],
        activities: [
          _a(
            'Face-to-face play',
            'Smile and talk to encourage social smiling.',
            '😊',
            [
              'Make eye contact.',
              'Smile and talk.',
              'Wait for baby\'s response.',
            ],
          ),
          _a('Smiling games', 'Encourage social smiling.', '😄', [
            'Make exaggerated expressions.',
            'Stick out your tongue.',
            'Watch baby copy.',
          ]),
          _a(
            'Singing and talking',
            'Consistent interaction builds connection.',
            '🎵',
            [
              'Talk during all care routines.',
              'Sing simple songs.',
              'Use baby\'s name often.',
            ],
          ),
          _a(
            'Gentle playful interaction',
            'Encourages laughter and social engagement.',
            '😂',
            [
              'Gently tickle baby\'s tummy or feet.',
              'React to their laughter.',
              'Pause and let them anticipate.',
            ],
          ),
        ],
        signsToLookFor: [
          _pos(
            'Smiles during interaction',
            'Social smile in response to faces.',
          ),
          _pos('Enjoys attention', 'Shows pleasure during social interaction.'),
          _pos('Watches caregiver expressions', 'Shows social interest.'),
          _pos('Calms when comforted', 'Settles with familiar voice or touch.'),
          _watch('Rarely smiles', 'Absence of social smile needs evaluation.'),
          _watch(
            'No eye contact',
            'Consistent avoidance of eye contact needs evaluation.',
          ),
          _watch(
            'No response to interaction',
            'Limited social response needs evaluation.',
          ),
          _watch(
            'Does not calm with comfort',
            'Persistent inconsolability needs review.',
          ),
        ],
        whenToWorry: [
          _warn(
            'Rarely smiles',
            'Absence of social smile by 5 months needs evaluation.',
          ),
          _warn(
            'No eye contact',
            'Consistent avoidance of eye contact needs evaluation.',
          ),
          _warn(
            'No response to interaction',
            'Limited social response needs evaluation.',
          ),
        ],
        commonConcerns: [
          _concern(
            'My baby cries when I leave the room. Is that separation anxiety?',
            'Yes, and it\'s a sign of healthy attachment. Separation anxiety typically peaks at 9-18 months but can start earlier.',
          ),
        ],
        parentTips: [
          'Smile and talk to your baby constantly.',
          'Play peek-a-boo and tickle games every day.',
          'Simple activities like tummy time, talking, cuddling, singing, and floor play are helping your baby grow stronger and more confident every day.',
        ],
      );
    case MilestoneCategory.feedingSleep:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 8,
        aboutText:
            'Sleep and feeding patterns may feel more predictable for some babies during this stage.',
        milestones: [
          _m(
            'm5_fs1',
            'Feeds every 3–4 hours',
            'Feeding intervals lengthening.',
            cat,
            label,
          ),
          _m(
            'm5_fs2',
            'Longer awake windows',
            'More alert time between feeds.',
            cat,
            label,
          ),
          _m(
            'm5_fs3',
            'May sleep longer stretches at night',
            'Some babies sleep 6-8 hours.',
            cat,
            label,
          ),
          _m(
            'm5_fs4',
            'Increased curiosity during feeds',
            'May be distracted during feeding.',
            cat,
            label,
          ),
          _m(
            'm5_fs5',
            'Some babies prepare for solids soon',
            'Showing interest in food.',
            cat,
            label,
          ),
        ],
        activities: [
          _a(
            'Continue feeding on demand',
            'Feed whenever baby shows hunger cues.',
            '🍼',
            [
              'Watch for rooting and sucking cues.',
              'Feed before crying starts.',
              'Let baby feed until satisfied.',
            ],
          ),
          _a(
            'Gentle bedtime routine',
            'Consistent routine helps sleep.',
            '😴',
            [
              'Bath, feed, song, sleep — in the same order.',
              'Keep it to 20-30 minutes.',
              'Same time every night.',
            ],
          ),
          _a(
            'Burp after feeding',
            'Reduces discomfort from swallowed air.',
            '🤱',
            [
              'Hold baby upright.',
              'Gently pat or rub back.',
              'Wait 5-10 minutes.',
            ],
          ),
          _a(
            'Encourage daytime play',
            'Active daytime helps sleep at night.',
            '🎮',
            [
              'Engage baby during awake periods.',
              'Play on the floor.',
              'Talk and sing.',
            ],
          ),
        ],
        signsToLookFor: [
          _pos('Feeding interest', 'Shows hunger cues regularly.'),
          _pos('Regular wet diapers', '6+ wet diapers per day.'),
          _pos('Calm after feeds', 'Settles after feeding.'),
          _pos('Active awake periods', 'More alert time during the day.'),
          _watch('Poor feeding', 'Difficulty feeding needs support.'),
          _watch(
            'Persistent vomiting',
            'Forceful or very frequent vomiting needs evaluation.',
          ),
          _watch('Fewer wet diapers', 'May indicate inadequate feeding.'),
          _watch('Difficulty waking', 'Needs medical attention.'),
          _watch(
            'Significant feeding refusal',
            'Persistent refusal needs evaluation.',
          ),
        ],
        whenToWorry: [
          _warn('Poor feeding', 'Contact lactation consultant or doctor.'),
          _warn(
            'Persistent vomiting',
            'Forceful or very frequent vomiting needs medical evaluation.',
          ),
          _warn(
            'Fewer wet diapers',
            'Fewer than 6 wet diapers needs evaluation.',
          ),
          _warn('Difficulty waking', 'Needs medical attention.'),
        ],
        commonConcerns: [
          _concern(
            'When should I start solid foods?',
            'Around 6 months, when baby can sit with support, shows interest in food, and the tongue thrust reflex has faded. Not before 4 months.',
          ),
          _concern(
            'My baby is waking more at night again. Why?',
            'Sleep regressions are common at 4-6 months. They\'re caused by developmental leaps. They are temporary. Maintain your routine.',
          ),
        ],
        parentTips: [
          'Start a simple bedtime routine now — it pays off later.',
          'Watch for tired cues and put baby down before overtired.',
          'Active daytime play helps baby sleep better at night.',
        ],
      );
  }
}

// ── Month 6 (24–28 weeks) ─────────────────────────────────────────────────────

CategoryGuidance _month6(MilestoneCategory cat) {
  const label = '5-6 Months';
  switch (cat) {
    case MilestoneCategory.grossMotor:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 9,
        aboutText:
            'Your baby\'s muscles, balance, and coordination are improving rapidly, helping with rolling, sitting, and stronger body movement.',
        milestones: [
          _m(
            'm6_gm1',
            'Rolls in both directions',
            'Rolls from tummy to back and back to tummy.',
            cat,
            label,
          ),
          _m(
            'm6_gm2',
            'Pushes up strongly during tummy time',
            'Lifts chest fully off the floor.',
            cat,
            label,
          ),
          _m(
            'm6_gm3',
            'Sits briefly with support',
            'Early sitting with support.',
            cat,
            label,
          ),
          _m(
            'm6_gm4',
            'Bears weight on legs when supported',
            'Pushes down with legs when held upright.',
            cat,
            label,
          ),
          _m(
            'm6_gm5',
            'Strong kicking and bouncing movements',
            'Active leg movement.',
            cat,
            label,
          ),
          _m(
            'm6_gm6',
            'May begin rocking on tummy',
            'Early crawling preparation.',
            cat,
            label,
          ),
        ],
        activities: [
          _a(
            'Daily tummy time',
            'Increase to 20-30 minutes spread through the day.',
            '🍼',
            [
              'Lay baby on firm surface.',
              'Get down to their level.',
              'Increase time gradually.',
            ],
          ),
          _a(
            'Encourage rolling with toys',
            'Use a toy to encourage rolling.',
            '🪀',
            [
              'Place baby on their back.',
              'Hold a toy to one side.',
              'Encourage them to roll toward it.',
            ],
          ),
          _a(
            'Assisted sitting practice',
            'Practice sitting with minimal support.',
            '🪑',
            [
              'Sit baby between your legs.',
              'Gradually reduce support.',
              'Use a Boppy pillow.',
            ],
          ),
          _a(
            'Floor play with safe open space',
            'Give baby space to move freely.',
            '🧸',
            [
              'Place baby on a soft mat.',
              'Surround with safe toys.',
              'Let baby explore freely.',
            ],
          ),
        ],
        signsToLookFor: [
          _pos('Strong head control', 'Head stays up without wobbling.'),
          _pos('Rolling attempts', 'Rolling in both directions.'),
          _pos('Pushes chest up fully', 'Building strength for crawling.'),
          _pos(
            'Active movement on both sides',
            'Symmetric movement is healthy.',
          ),
          _watch(
            'Poor head control',
            'Head still very floppy needs evaluation.',
          ),
          _watch(
            'Very stiff or floppy body',
            'Either extreme needs evaluation.',
          ),
          _watch(
            'No rolling attempts',
            'No rolling attempts by 6 months needs evaluation.',
          ),
          _watch('Very little movement', 'Minimal movement needs review.'),
          _watch(
            'Strong preference for one side only',
            'Asymmetric movement should be assessed.',
          ),
        ],
        whenToWorry: [
          _warn(
            'Not sitting independently by 9 months',
            'Consult your doctor if baby can\'t sit without support by 9 months.',
          ),
          _warn(
            'Not rolling by 6 months',
            'If baby isn\'t rolling in either direction by 6 months, consult your doctor.',
          ),
          _warn(
            'Very stiff or floppy body',
            'Either extreme may indicate a concern.',
          ),
          _warn(
            'Strong preference for one side only',
            'Asymmetric movement should be assessed.',
          ),
        ],
        commonConcerns: [
          _concern(
            'My baby rolled off the bed. What should I do?',
            'Check for signs of injury. If concerned, seek medical attention. Going forward, never leave baby unattended on elevated surfaces.',
          ),
          _concern(
            'Should I use a baby walker?',
            'Baby walkers are not recommended. They can delay walking, cause accidents, and don\'t provide developmental benefits. Use a push toy instead.',
          ),
        ],
        parentTips: [
          'Give baby lots of floor time — it\'s the best gym.',
          'Tummy time is still important even when baby can roll.',
          'Baby-proof your floor — rolling babies move faster than you expect.',
        ],
      );
    case MilestoneCategory.fineMotor:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 9,
        aboutText:
            'Your baby is becoming more intentional with hand movements and object exploration.',
        milestones: [
          _m(
            'm6_fm1',
            'Reaches for toys intentionally',
            'Intentional reaching toward objects.',
            cat,
            label,
          ),
          _m(
            'm6_fm2',
            'Grasps and holds toys well',
            'Holds objects firmly.',
            cat,
            label,
          ),
          _m(
            'm6_fm3',
            'Transfers objects between hands',
            'Passes toy from one hand to the other.',
            cat,
            label,
          ),
          _m(
            'm6_fm4',
            'Brings objects to mouth',
            'Hand-to-mouth movement.',
            cat,
            label,
          ),
          _m(
            'm6_fm5',
            'Explores textures with fingers',
            'Uses fingers to explore objects.',
            cat,
            label,
          ),
        ],
        activities: [
          _a('Soft rattles', 'Introduce simple sensory toys.', '🪀', [
            'Place rattle in baby\'s hand.',
            'Let them feel the texture.',
            'React with excitement.',
          ]),
          _a(
            'Textured toys',
            'Different textures stimulate development.',
            '🧸',
            [
              'Offer toys with different textures.',
              'Let baby explore by touching.',
              'Name the textures.',
            ],
          ),
          _a('Sensory play', 'Stimulate sensory development.', '🎨', [
            'Offer objects with different textures.',
            'Let baby feel and mouth each one.',
            'Name the textures.',
          ]),
          _a(
            'Hand-to-hand toy transfer games',
            'Encourage using both hands.',
            '🤝',
            [
              'Give baby a toy.',
              'Encourage passing it to the other hand.',
              'Celebrate success.',
            ],
          ),
        ],
        signsToLookFor: [
          _pos('Intentional reaching', 'Reaches toward objects on purpose.'),
          _pos('Holds toys briefly', 'Grasps and holds objects.'),
          _pos(
            'Transfers toys between hands',
            'Passes toy from one hand to the other.',
          ),
          _pos('Active hand exploration', 'Uses hands to explore objects.'),
          _watch(
            'No reaching attempts',
            'No interest in reaching needs evaluation.',
          ),
          _watch(
            'Persistent tight fists',
            'Hands always clenched needs review.',
          ),
          _watch(
            'Very limited hand movement',
            'Minimal hand use needs evaluation.',
          ),
          _watch(
            'Unequal hand use',
            'Strong hand preference before 12 months needs evaluation.',
          ),
        ],
        whenToWorry: [
          _warn(
            'No reaching attempts',
            'If baby shows no interest in reaching for toys, mention to your doctor.',
          ),
          _warn(
            'Persistent tight fists',
            'Hands always clenched needs review.',
          ),
          _warn(
            'Unequal hand use',
            'Strong hand preference before 12 months needs evaluation.',
          ),
        ],
        commonConcerns: [
          _concern(
            'My baby drops everything on purpose. Is that normal?',
            'Yes! Dropping is intentional and a sign of developing cause-and-effect understanding. It\'s annoying but developmentally appropriate!',
          ),
        ],
        parentTips: [
          'Offer a variety of safe objects to explore.',
          'Let baby feel different textures — it builds sensory pathways.',
          'Ensure all toys are clean and large enough to be safe.',
        ],
      );
    case MilestoneCategory.language:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 9,
        aboutText:
            'Your baby is becoming more vocal and responsive during interaction.',
        milestones: [
          _m(
            'm6_la1',
            'Babbling begins ("ba," "ma," "da" sounds)',
            'First consonant sounds.',
            cat,
            label,
          ),
          _m(
            'm6_la2',
            'Laughs loudly',
            'Loud laughs in response to interaction.',
            cat,
            label,
          ),
          _m(
            'm6_la3',
            'Responds to familiar voices',
            'Calms or turns toward known voices.',
            cat,
            label,
          ),
          _m(
            'm6_la4',
            'Squeals and excited sounds',
            'High-pitched excited vocalisations.',
            cat,
            label,
          ),
          _m(
            'm6_la5',
            'Turns toward sounds',
            'Looks toward the source of a sound.',
            cat,
            label,
          ),
        ],
        activities: [
          _a('Talk frequently', 'Narrate everything you do.', '💬', [
            'Describe what you are doing.',
            'Use a warm voice.',
            'Pause and wait for baby\'s response.',
          ]),
          _a('Read books aloud', 'Reading builds language foundations.', '📚', [
            'Choose simple board books.',
            'Point to pictures.',
            'Use an expressive voice.',
          ]),
          _a(
            'Mimic baby sounds',
            'Copying sounds teaches turn-taking.',
            '🗣️',
            [
              'When baby babbles, babble back.',
              'Pause and wait.',
              'Take turns.',
            ],
          ),
          _a(
            'Sing songs and rhymes',
            'Singing helps baby learn rhythm and language.',
            '🎵',
            [
              'Choose 2-3 simple songs.',
              'Sing consistently.',
              'Use actions with songs.',
            ],
          ),
        ],
        signsToLookFor: [
          _pos('Vocal sounds during interaction', 'Makes sounds when engaged.'),
          _pos('Responds to voices', 'Calms or turns toward familiar voice.'),
          _pos('Turns toward sound', 'Looks toward the source of a sound.'),
          _pos('Laughs or squeals', 'Excited vocalisations.'),
          _watch('No sound response', 'May indicate hearing concerns.'),
          _watch(
            'No vocal sounds',
            'Absence of any vocalisations needs evaluation.',
          ),
          _watch(
            'No reaction to voices or name',
            'Limited response needs review.',
          ),
          _watch('Very weak cry', 'Consistently weak cry needs evaluation.'),
        ],
        whenToWorry: [
          _warn(
            'No babbling by 9 months',
            'If baby makes no consonant sounds by 9 months, consult your doctor.',
          ),
          _warn(
            'No response to sound',
            'Could indicate hearing issues — request a hearing test.',
          ),
          _warn(
            'No vocal sounds',
            'Absence of any vocalisations needs evaluation.',
          ),
        ],
        commonConcerns: [
          _concern(
            'My baby babbles a lot but I can\'t understand any of it. Is that normal?',
            'Completely normal. Babbling is practice — baby is learning to control their mouth and voice. Real words come later, usually around 10-14 months.',
          ),
        ],
        parentTips: [
          'Use baby\'s name often during daily routines.',
          'Respond to every babble — it teaches communication is two-way.',
          'Read books with simple, repetitive text.',
        ],
      );
    case MilestoneCategory.cognitive:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 9,
        aboutText:
            'Your baby is becoming more curious and interested in exploring surroundings.',
        milestones: [
          _m(
            'm6_co1',
            'Watches movement carefully',
            'Eyes follow slow movement.',
            cat,
            label,
          ),
          _m(
            'm6_co2',
            'Explores toys by touching and mouthing',
            'Examines toys by touching and mouthing.',
            cat,
            label,
          ),
          _m(
            'm6_co3',
            'Recognises familiar people',
            'Shows preference for known people.',
            cat,
            label,
          ),
          _m(
            'm6_co4',
            'Interested in mirrors and faces',
            'Shows interest in reflections.',
            cat,
            label,
          ),
          _m(
            'm6_co5',
            'Begins understanding simple cause-and-effect',
            'Repeats actions that produce results.',
            cat,
            label,
          ),
        ],
        activities: [
          _a('Peek-a-boo', 'Builds object permanence.', '👀', [
            'Cover your face.',
            'Say "Where\'s Mummy?"',
            'Reveal with "Peek-a-boo!"',
          ]),
          _a('Mirror play', 'Show baby their reflection.', '🪞', [
            'Hold baby in front of a mirror.',
            'Point to their reflection.',
            'Make faces together.',
          ]),
          _a('Cause-and-effect toys', 'Teach cause and effect.', '🔔', [
            'Give baby a toy that makes sound when shaken.',
            'React with excitement.',
            'Repeat to reinforce the connection.',
          ]),
          _a('Interactive floor play', 'Encourage exploration.', '🧸', [
            'Place baby on a soft mat.',
            'Surround with safe toys.',
            'Let baby explore freely.',
          ]),
        ],
        signsToLookFor: [
          _pos('Curious about surroundings', 'Looks around when alert.'),
          _pos('Watches caregiver actions', 'Shows social interest.'),
          _pos('Tracks objects smoothly', 'Eyes follow slow movement.'),
          _pos('Interested in toys', 'Shows interest in objects.'),
          _watch('No visual tracking', 'May indicate visual concerns.'),
          _watch(
            'No interest in surroundings',
            'Lack of awareness needs evaluation.',
          ),
          _watch(
            'No eye contact',
            'Consistent avoidance of eye contact needs evaluation.',
          ),
          _watch('Difficult to engage', 'Limited engagement needs review.'),
        ],
        whenToWorry: [
          _warn(
            'No visual tracking',
            'Contact doctor if no response to faces or light.',
          ),
          _warn(
            'No interest in surroundings',
            'Lack of any environmental awareness needs evaluation.',
          ),
          _warn(
            'No eye contact',
            'Consistent avoidance of eye contact needs evaluation.',
          ),
        ],
        commonConcerns: [
          _concern(
            'My baby is into everything. How do I keep them safe?',
            'Baby-proof thoroughly: cover outlets, secure furniture, remove choking hazards, gate stairs. Create a safe "yes" environment where baby can explore freely.',
          ),
        ],
        parentTips: [
          'Give toys that make sounds when pressed or shaken.',
          'Play drop-and-find games to build object permanence.',
          'Rotate toys to keep things interesting.',
        ],
      );
    case MilestoneCategory.social:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 9,
        aboutText:
            'Your baby is becoming more socially expressive and emotionally connected.',
        milestones: [
          _m(
            'm6_so1',
            'Smiles socially often',
            'Frequent social smiling.',
            cat,
            label,
          ),
          _m(
            'm6_so2',
            'Laughs during play',
            'Laughs in response to interaction.',
            cat,
            label,
          ),
          _m(
            'm6_so3',
            'Enjoys interaction',
            'Shows pleasure during social play.',
            cat,
            label,
          ),
          _m(
            'm6_so4',
            'Recognises familiar caregivers',
            'Shows preference for known people.',
            cat,
            label,
          ),
          _m(
            'm6_so5',
            'Shows excitement during social play',
            'Increased engagement during interaction.',
            cat,
            label,
          ),
        ],
        activities: [
          _a(
            'Face-to-face play',
            'Smile and talk to encourage social smiling.',
            '😊',
            [
              'Make eye contact.',
              'Smile and talk.',
              'Wait for baby\'s response.',
            ],
          ),
          _a(
            'Singing and talking',
            'Consistent interaction builds connection.',
            '🎵',
            [
              'Talk during all care routines.',
              'Sing simple songs.',
              'Use baby\'s name often.',
            ],
          ),
          _a('Smiling games', 'Encourage social smiling.', '😄', [
            'Make exaggerated expressions.',
            'Stick out your tongue.',
            'Watch baby copy.',
          ]),
          _a('Interactive play routines', 'Build social anticipation.', '🎮', [
            'Play the same games consistently.',
            'Let baby anticipate what comes next.',
            'Celebrate their excitement.',
          ]),
        ],
        signsToLookFor: [
          _pos(
            'Smiles during interaction',
            'Social smile in response to faces.',
          ),
          _pos('Enjoys attention', 'Shows pleasure during social interaction.'),
          _pos('Watches caregiver expressions', 'Shows social interest.'),
          _pos('Calms when comforted', 'Settles with familiar voice or touch.'),
          _watch('Rarely smiles', 'Absence of social smile needs evaluation.'),
          _watch(
            'No eye contact',
            'Consistent avoidance of eye contact needs evaluation.',
          ),
          _watch(
            'No response to interaction',
            'Limited social response needs evaluation.',
          ),
          _watch(
            'Does not calm with comfort',
            'Persistent inconsolability needs review.',
          ),
        ],
        whenToWorry: [
          _warn(
            'Rarely smiles',
            'Absence of social smile by 6 months needs evaluation.',
          ),
          _warn(
            'No eye contact',
            'Consistent avoidance of eye contact needs evaluation.',
          ),
          _warn(
            'No response to interaction',
            'Limited social response needs evaluation.',
          ),
        ],
        commonConcerns: [
          _concern(
            'My baby cries when I leave the room. Is that separation anxiety?',
            'Yes, and it\'s a sign of healthy attachment. Separation anxiety typically peaks at 9-18 months but can start earlier.',
          ),
        ],
        parentTips: [
          'Smile and talk to your baby constantly.',
          'Play peek-a-boo daily — it teaches object permanence too.',
          'Simple everyday moments like talking, cuddling, floor play, singing, and responsive care continue helping your baby grow every day.',
        ],
      );
    case MilestoneCategory.feedingSleep:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 9,
        aboutText:
            'Many babies are ready to start solid foods around 6 months. Sleep is consolidating for most babies.',
        milestones: [
          _m(
            'm6_fs1',
            'Shows interest in food',
            'Watches others eat, reaches for food.',
            cat,
            label,
          ),
          _m(
            'm6_fs2',
            'Sits with support for feeding',
            'Can sit supported in a high chair.',
            cat,
            label,
          ),
          _m(
            'm6_fs3',
            'Sleeps 2-3 naps per day',
            'Predictable nap pattern emerging.',
            cat,
            label,
          ),
          _m(
            'm6_fs4',
            'Longer night sleep stretches',
            'May sleep 6-8 hours at a stretch.',
            cat,
            label,
          ),
          _m(
            'm6_fs5',
            'Milk remains primary nutrition',
            'Breast milk or formula is still main nutrition.',
            cat,
            label,
          ),
        ],
        activities: [
          _a(
            'Solid food introduction',
            'Start with single-ingredient purees around 6 months.',
            '🥕',
            [
              'Start with iron-rich foods: pureed meat, lentils, fortified cereal.',
              'Offer 1-2 teaspoons once a day.',
              'Wait 3-5 days before introducing a new food.',
            ],
          ),
          _a(
            'Sleep routine consistency',
            'Keep bedtime routine consistent every night.',
            '🌙',
            [
              'Same time, same order every night.',
              'Bath, feed, book, song, sleep.',
              'Aim for bedtime between 6:30-8pm.',
            ],
          ),
          _a(
            'Feed on demand',
            'Continue feeding whenever baby shows hunger cues.',
            '🍼',
            [
              'Watch for hunger cues.',
              'Feed before crying starts.',
              'Let baby feed until satisfied.',
            ],
          ),
          _a(
            'Burp after feeds',
            'Reduces discomfort from swallowed air.',
            '🤱',
            [
              'Hold baby upright.',
              'Gently pat or rub back.',
              'Wait 5-10 minutes.',
            ],
          ),
        ],
        signsToLookFor: [
          _pos('Can sit with support', 'Needed before starting solids.'),
          _pos(
            'Shows interest in food',
            'Key readiness sign for starting solids.',
          ),
          _pos(
            'Tongue thrust reflex fading',
            'Stops pushing food out with tongue.',
          ),
          _pos('Regular wet diapers', '6+ wet diapers per day.'),
          _watch(
            'No interest in food at 6 months',
            'If baby shows no interest in food by 6 months, discuss with your doctor.',
          ),
          _watch(
            'Gagging excessively on purees',
            'Some gagging is normal, but excessive gagging may need assessment.',
          ),
          _watch('Poor feeding', 'Difficulty feeding needs support.'),
          _watch('Fewer wet diapers', 'May indicate inadequate feeding.'),
        ],
        whenToWorry: [
          _warn(
            'No interest in food at 6 months',
            'If baby shows no interest in food by 6 months, discuss with your doctor.',
          ),
          _warn(
            'Gagging excessively on purees',
            'Some gagging is normal, but excessive gagging may need assessment.',
          ),
          _warn('Poor feeding', 'Contact lactation consultant or doctor.'),
          _warn(
            'Fewer wet diapers',
            'Fewer than 6 wet diapers needs evaluation.',
          ),
        ],
        commonConcerns: [
          _concern(
            'When should I start solid foods?',
            'Around 6 months, when baby can sit with support, shows interest in food, and the tongue thrust reflex has faded. Not before 4 months. Breast milk or formula remains the main nutrition until 12 months.',
          ),
          _concern(
            'Should I do purees or baby-led weaning?',
            'Both are valid approaches. Purees are traditional and easy to control. Baby-led weaning promotes self-feeding skills. Many families do a combination.',
          ),
          _concern(
            'My baby is rolling everywhere and sleep has gotten worse. Is that normal?',
            'Yes. Rolling everywhere, sleep regressions, increased drooling, hand chewing, teething signs, and distracted feeding are all common at this stage.',
          ),
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

// ── 6–9 Months ────────────────────────────────────────────────────────────────

CategoryGuidance _months6to9(MilestoneCategory cat) {
  const label = '6-9 Months';
  switch (cat) {
    case MilestoneCategory.grossMotor:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 10,
        aboutText:
            'Your baby is becoming more mobile, curious, playful, and socially interactive. Many babies begin sitting independently, rolling confidently, babbling more, and exploring the world actively.',
        milestones: [
          _m(
            'sn_gm1',
            'Rolls in both directions',
            'Rolls from tummy to back and back to tummy.',
            cat,
            label,
          ),
          _m(
            'sn_gm2',
            'Sits without support (many babies)',
            'Sits steadily without using hands.',
            cat,
            label,
          ),
          _m(
            'sn_gm3',
            'Pushes up strongly during tummy time',
            'Lifts chest fully off the floor.',
            cat,
            label,
          ),
          _m(
            'sn_gm4',
            'May begin crawling or rocking',
            'Early crawling preparation.',
            cat,
            label,
          ),
          _m(
            'sn_gm5',
            'Bears weight on legs when supported',
            'Pushes down with legs when held upright.',
            cat,
            label,
          ),
          _m(
            'sn_gm6',
            'Moves toward toys intentionally',
            'Purposeful movement toward objects.',
            cat,
            label,
          ),
        ],
        activities: [
          _a(
            'Floor play on safe mat',
            'Give baby space to move freely.',
            '🧸',
            [
              'Place baby on a soft mat.',
              'Surround with safe toys.',
              'Let baby explore freely.',
            ],
          ),
          _a(
            'Encourage reaching and crawling',
            'Place toys just out of reach.',
            '🎯',
            [
              'Place a favourite toy just ahead.',
              'Encourage baby to move toward it.',
              'Celebrate when they reach it!',
            ],
          ),
          _a(
            'Assisted standing play',
            'Encourage pulling up using furniture.',
            '🛋️',
            [
              'Place baby next to a sturdy sofa.',
              'Put a toy on the sofa seat.',
              'Encourage them to pull up to reach it.',
            ],
          ),
          _a(
            'Tummy time and rolling games',
            'Encourage rolling in both directions.',
            '🪀',
            [
              'Place baby on their back.',
              'Hold a toy to one side.',
              'Encourage them to roll toward it.',
            ],
          ),
        ],
        signsToLookFor: [
          _pos('Good head control', 'Head stays up without wobbling.'),
          _pos(
            'Sitting balance improving',
            'Sits with less support over time.',
          ),
          _pos(
            'Active movement on both sides',
            'Symmetric movement is healthy.',
          ),
          _pos(
            'Attempts to move toward objects',
            'Any form of locomotion is great.',
          ),
          _watch(
            'Cannot hold head steady',
            'Head still very floppy needs evaluation.',
          ),
          _watch(
            'Very floppy or stiff body',
            'Either extreme needs evaluation.',
          ),
          _watch(
            'No rolling attempts',
            'No rolling attempts by 9 months needs evaluation.',
          ),
          _watch('Very limited movement', 'Minimal movement needs review.'),
          _watch(
            'Strong preference for one side only',
            'Asymmetric movement should be assessed.',
          ),
        ],
        whenToWorry: [
          _warn(
            'Cannot sit independently by 9 months',
            'Consult your doctor if baby can\'t sit without support by 9 months.',
          ),
          _warn(
            'Not moving toward objects by 9 months',
            'Any form of locomotion should be present by 9 months.',
          ),
          _warn(
            'Very floppy or stiff body',
            'Either extreme may indicate a concern.',
          ),
          _warn(
            'Strong preference for one side only',
            'Asymmetric movement should be assessed.',
          ),
        ],
        commonConcerns: [
          _concern(
            'My baby skipped crawling and went straight to walking. Is that okay?',
            'Yes. Some babies skip crawling entirely. While crawling has developmental benefits, it\'s not a required milestone.',
          ),
          _concern(
            'Should I use a baby walker?',
            'Baby walkers are not recommended. They can delay walking, cause accidents, and don\'t provide developmental benefits. Use a push toy instead.',
          ),
        ],
        parentTips: [
          'Baby-proof your home now — crawling babies are fast!',
          'Give lots of floor time — it\'s the best gym.',
          'Avoid baby walkers — they delay development.',
          'Everyday activities like floor play, talking, cuddling, feeding, and interactive games are helping your baby build confidence, curiosity, and emotional security.',
        ],
      );
    case MilestoneCategory.fineMotor:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 10,
        aboutText:
            'Hand coordination and object exploration improve significantly during this stage.',
        milestones: [
          _m(
            'sn_fm1',
            'Reaches intentionally for toys',
            'Intentional reaching toward objects.',
            cat,
            label,
          ),
          _m(
            'sn_fm2',
            'Transfers objects between hands easily',
            'Passes toy from one hand to the other.',
            cat,
            label,
          ),
          _m(
            'sn_fm3',
            'Brings objects to mouth',
            'Hand-to-mouth movement.',
            cat,
            label,
          ),
          _m(
            'sn_fm4',
            'Explores textures with fingers',
            'Uses fingers to explore objects.',
            cat,
            label,
          ),
          _m(
            'sn_fm5',
            'Begins raking grasp',
            'Uses whole hand to rake objects closer.',
            cat,
            label,
          ),
          _m(
            'sn_fm6',
            'Bangs toys together',
            'Deliberately bangs two objects together.',
            cat,
            label,
          ),
        ],
        activities: [
          _a(
            'Sensory toys',
            'Different textures stimulate development.',
            '🧸',
            [
              'Offer toys with different textures.',
              'Let baby explore by touching.',
              'Name the textures.',
            ],
          ),
          _a('Soft blocks', 'Encourage stacking and banging.', '🏗️', [
            'Give baby soft blocks.',
            'Demonstrate stacking.',
            'Let baby knock them down.',
          ]),
          _a(
            'Texture exploration',
            'Offer objects with different textures.',
            '🎨',
            [
              'Offer a soft toy, a smooth block, a crinkle toy.',
              'Let baby feel and mouth each one.',
              'Name the textures.',
            ],
          ),
          _a(
            'Hand-to-hand transfer games',
            'Encourage using both hands.',
            '🤝',
            [
              'Give baby a toy.',
              'Encourage passing it to the other hand.',
              'Celebrate success.',
            ],
          ),
        ],
        signsToLookFor: [
          _pos('Holds toys independently', 'Grasps and holds objects.'),
          _pos(
            'Transfers objects between hands',
            'Passes toy from one hand to the other.',
          ),
          _pos(
            'Reaches accurately for nearby objects',
            'Intentional reaching behaviour.',
          ),
          _pos('Uses hands actively during play', 'Active hand exploration.'),
          _watch(
            'No reaching attempts',
            'No interest in reaching needs evaluation.',
          ),
          _watch(
            'Persistent tight fists',
            'Hands always clenched needs review.',
          ),
          _watch(
            'Very limited hand movement',
            'Minimal hand use needs evaluation.',
          ),
          _watch(
            'Unequal use of hands',
            'Strong hand preference before 12 months needs evaluation.',
          ),
        ],
        whenToWorry: [
          _warn(
            'No reaching attempts',
            'If baby shows no interest in reaching for toys, mention to your doctor.',
          ),
          _warn(
            'Persistent tight fists',
            'Hands always clenched needs review.',
          ),
          _warn(
            'Unequal use of hands',
            'Strong hand preference before 12 months needs evaluation.',
          ),
        ],
        commonConcerns: [
          _concern(
            'My baby drops everything on purpose. Is that normal?',
            'Yes! Dropping is intentional and a sign of developing cause-and-effect understanding. It\'s annoying but developmentally appropriate!',
          ),
        ],
        parentTips: [
          'Offer a variety of safe objects to explore.',
          'Let baby feel different textures — it builds sensory pathways.',
          'Point at things and name them — baby will start pointing too.',
        ],
      );
    case MilestoneCategory.language:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 10,
        aboutText: 'Your baby becomes much more vocal and socially responsive.',
        milestones: [
          _m(
            'sn_la1',
            'Babbling sounds like speech',
            'Varied consonants and intonation patterns.',
            cat,
            label,
          ),
          _m(
            'sn_la2',
            'Responds to own name',
            'Turns when their name is called.',
            cat,
            label,
          ),
          _m(
            'sn_la3',
            'Understands "no"',
            'Pauses or reacts when told "no".',
            cat,
            label,
          ),
          _m(
            'sn_la4',
            'Imitates sounds',
            'Copies sounds and gestures you make.',
            cat,
            label,
          ),
          _m(
            'sn_la5',
            'Expresses excitement vocally',
            'Happy sounds during play.',
            cat,
            label,
          ),
          _m(
            'sn_la6',
            'Turns toward familiar voices',
            'Looks toward the source of a sound.',
            cat,
            label,
          ),
        ],
        activities: [
          _a('Talk frequently', 'Narrate everything you do.', '💬', [
            'Describe what you are doing.',
            'Use a warm voice.',
            'Pause and wait for baby\'s response.',
          ]),
          _a(
            'Read colorful books',
            'Reading builds language foundations.',
            '📚',
            [
              'Choose simple board books.',
              'Point to pictures.',
              'Use an expressive voice.',
            ],
          ),
          _a(
            'Mimic baby sounds',
            'Copying sounds teaches turn-taking.',
            '🗣️',
            [
              'When baby babbles, babble back.',
              'Pause and wait.',
              'Take turns.',
            ],
          ),
          _a(
            'Sing rhymes and songs',
            'Singing helps baby learn rhythm and language.',
            '🎵',
            [
              'Choose 2-3 simple songs.',
              'Sing consistently.',
              'Use actions with songs.',
            ],
          ),
        ],
        signsToLookFor: [
          _pos(
            'Babbling with varied consonants',
            'Varied consonants and intonation.',
          ),
          _pos('Responds to name consistently', 'Turns when name is called.'),
          _pos('Turns toward sound', 'Looks toward the source of a sound.'),
          _pos(
            'Watches faces while listening',
            'Shows interest in communication.',
          ),
          _watch(
            'No babbling by 9 months',
            'If baby makes no consonant sounds by 9 months, consult your doctor.',
          ),
          _watch(
            'Doesn\'t respond to name by 9 months',
            'May indicate hearing or developmental concerns.',
          ),
          _watch('No response to sound', 'Could indicate hearing issues.'),
          _watch(
            'Very limited interaction',
            'Limited engagement needs review.',
          ),
        ],
        whenToWorry: [
          _warn(
            'No babbling by 9 months',
            'If baby makes no consonant sounds by 9 months, consult your doctor.',
          ),
          _warn(
            'Doesn\'t respond to name by 9 months',
            'May indicate hearing or developmental concerns.',
          ),
          _warn(
            'No response to sound',
            'Could indicate hearing issues — request a hearing test.',
          ),
        ],
        commonConcerns: [
          _concern(
            'My baby says "dada" but not "mama". Should I be offended?',
            'Not at all! "D" sounds are easier to produce than "M" sounds. "Dada" often comes first regardless of who the primary caregiver is.',
          ),
        ],
        parentTips: [
          'Narrate everything you do throughout the day.',
          'Read books every day — even the same book repeatedly.',
          'Respond to every babble and gesture.',
        ],
      );
    case MilestoneCategory.cognitive:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 10,
        aboutText:
            'Your baby is becoming more curious and interested in exploring surroundings and cause-and-effect learning.',
        milestones: [
          _m(
            'sn_co1',
            'Object permanence',
            'Looks for hidden objects.',
            cat,
            label,
          ),
          _m(
            'sn_co2',
            'Explores objects in different ways',
            'Shakes, bangs, throws, drops objects.',
            cat,
            label,
          ),
          _m(
            'sn_co3',
            'Imitates actions',
            'Copies simple actions like clapping.',
            cat,
            label,
          ),
          _m(
            'sn_co4',
            'Understands simple instructions',
            'Responds to "give me" or "come here".',
            cat,
            label,
          ),
          _m(
            'sn_co5',
            'Curious about surroundings',
            'Interested in everything nearby.',
            cat,
            label,
          ),
        ],
        activities: [
          _a(
            'Hide and Seek with Toys',
            'Hide a toy under a cloth and let baby find it.',
            '🔍',
            [
              'Show baby a toy.',
              'Cover it with a cloth while they watch.',
              'Ask "Where did it go?" and let them find it.',
            ],
          ),
          _a(
            'Imitation Games',
            'Do simple actions and encourage baby to copy.',
            '🎭',
            [
              'Clap your hands.',
              'Wave.',
              'Bang on a drum. Wait for baby to copy.',
            ],
          ),
          _a('Peek-a-boo', 'Builds object permanence.', '👀', [
            'Cover your face.',
            'Say "Where\'s Mummy?"',
            'Reveal with "Peek-a-boo!"',
          ]),
          _a('Cause-and-effect toys', 'Teach cause and effect.', '🔔', [
            'Give baby a toy that makes sound when shaken.',
            'React with excitement.',
            'Repeat to reinforce the connection.',
          ]),
        ],
        signsToLookFor: [
          _pos('Searches for hidden objects', 'Object permanence developing.'),
          _pos('Imitates actions', 'Imitation is how babies learn.'),
          _pos(
            'Curious about surroundings',
            'Interested in everything nearby.',
          ),
          _pos('Explores toys actively', 'Uses hands and mouth to explore.'),
          _watch(
            'No imitation of actions by 9 months',
            'If baby doesn\'t copy simple actions, mention to your doctor.',
          ),
          _watch(
            'No curiosity about surroundings',
            'Lack of awareness needs evaluation.',
          ),
          _watch(
            'No eye contact',
            'Consistent avoidance of eye contact needs evaluation.',
          ),
          _watch('No visual tracking', 'May indicate visual concerns.'),
        ],
        whenToWorry: [
          _warn(
            'No imitation of actions by 9 months',
            'If baby doesn\'t copy simple actions, mention to your doctor.',
          ),
          _warn(
            'No curiosity about surroundings',
            'Lack of any environmental awareness needs evaluation.',
          ),
          _warn(
            'No eye contact',
            'Consistent avoidance of eye contact needs evaluation.',
          ),
        ],
        commonConcerns: [
          _concern(
            'My baby cries when I leave the room. Is that separation anxiety?',
            'Yes, and it\'s a sign of healthy attachment and developing object permanence. They now know you exist when you\'re gone, and they want you back! It typically peaks at 9-18 months.',
          ),
        ],
        parentTips: [
          'Play hide-and-seek with toys to build object permanence.',
          'Give simple one-step instructions and celebrate when baby follows them.',
          'Imitate baby\'s actions — they love it and it teaches turn-taking.',
        ],
      );
    case MilestoneCategory.social:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 10,
        aboutText:
            'Your baby is becoming emotionally expressive and strongly attached to familiar caregivers.',
        milestones: [
          _m(
            'sn_so1',
            'Smiles and laughs frequently',
            'Frequent social smiling and laughing.',
            cat,
            label,
          ),
          _m(
            'sn_so2',
            'Enjoys interaction and attention',
            'Shows pleasure during social play.',
            cat,
            label,
          ),
          _m(
            'sn_so3',
            'Recognises familiar people',
            'Shows preference for known people.',
            cat,
            label,
          ),
          _m(
            'sn_so4',
            'Stranger anxiety may begin',
            'May cry or cling when unfamiliar people approach.',
            cat,
            label,
          ),
          _m(
            'sn_so5',
            'Shows excitement during play',
            'Increased engagement during interaction.',
            cat,
            label,
          ),
          _m(
            'sn_so6',
            'Offers objects to others',
            'Holds out toys to share.',
            cat,
            label,
          ),
        ],
        activities: [
          _a('Interactive games', 'Play simple interactive games.', '🎮', [
            'Play the same games consistently.',
            'Let baby anticipate what comes next.',
            'Celebrate their excitement.',
          ]),
          _a(
            'Face-to-face play',
            'Smile and talk to encourage social smiling.',
            '😊',
            [
              'Make eye contact.',
              'Smile and talk.',
              'Wait for baby\'s response.',
            ],
          ),
          _a(
            'Singing and dancing',
            'Consistent interaction builds connection.',
            '🎵',
            [
              'Talk during all care routines.',
              'Sing simple songs.',
              'Use baby\'s name often.',
            ],
          ),
          _a(
            'Comfort during separation moments',
            'Keep goodbyes brief and cheerful.',
            '💗',
            [
              'Say goodbye — don\'t sneak away.',
              'Come back consistently.',
              'Practice short separations.',
            ],
          ),
        ],
        signsToLookFor: [
          _pos(
            'Smiles during interaction',
            'Social smile in response to faces.',
          ),
          _pos(
            'Enjoys caregiver attention',
            'Shows pleasure during social interaction.',
          ),
          _pos(
            'Shows excitement during play',
            'Increased engagement during interaction.',
          ),
          _pos('Calms with comfort', 'Settles with familiar voice or touch.'),
          _watch('Rarely smiles', 'Absence of social smile needs evaluation.'),
          _watch(
            'No interaction with caregivers',
            'Limited social response needs evaluation.',
          ),
          _watch(
            'No response to comfort',
            'Persistent inconsolability needs review.',
          ),
          _watch(
            'No eye contact',
            'Consistent avoidance of eye contact needs evaluation.',
          ),
        ],
        whenToWorry: [
          _warn('Rarely smiles', 'Absence of social smile needs evaluation.'),
          _warn(
            'No interaction with caregivers',
            'Limited social response needs evaluation.',
          ),
          _warn(
            'No eye contact',
            'Consistent avoidance of eye contact needs evaluation.',
          ),
        ],
        commonConcerns: [
          _concern(
            'My baby screams when I leave the room. How do I handle separation anxiety?',
            'Keep goodbyes brief and cheerful. Always say goodbye — don\'t sneak away. Come back consistently. Practice short separations. It typically improves by 18-24 months.',
          ),
        ],
        parentTips: [
          'Play peek-a-boo daily — it teaches object permanence too.',
          'Keep goodbyes brief and cheerful.',
          'Always come back when you say you will — it builds trust.',
          'Everyday activities like floor play, talking, cuddling, feeding, and interactive games are helping your baby build confidence, curiosity, and emotional security.',
        ],
      );
    case MilestoneCategory.feedingSleep:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 10,
        aboutText:
            'Solid foods are well established and baby is exploring a wider variety of textures and flavours. Sleep may be disrupted by developmental leaps, teething, and separation anxiety.',
        milestones: [
          _m(
            'sn_fs1',
            'Eating a variety of pureed foods',
            'Accepts different flavours and textures.',
            cat,
            label,
          ),
          _m(
            'sn_fs2',
            'Moving toward mashed/lumpy textures',
            'Progressing from smooth purees.',
            cat,
            label,
          ),
          _m(
            'sn_fs3',
            'Drinking from a cup with help',
            'Beginning to use a sippy or open cup.',
            cat,
            label,
          ),
          _m(
            'sn_fs4',
            'Sleeping 2 naps per day',
            'Morning and afternoon nap pattern.',
            cat,
            label,
          ),
          _m(
            'sn_fs5',
            'Milk remains primary nutrition',
            'Breast milk or formula is still main nutrition.',
            cat,
            label,
          ),
        ],
        activities: [
          _a('Texture progression', 'Gradually increase food texture.', '🥕', [
            'Start with smooth purees.',
            'Progress to mashed with small lumps.',
            'Introduce soft finger foods around 7-8 months.',
          ]),
          _a(
            'Cup introduction',
            'Introduce a sippy or open cup with water.',
            '🥤',
            [
              'Offer a small amount of water in a cup at mealtimes.',
              'Help baby hold and tip the cup.',
              'Expect mess — it\'s part of learning!',
            ],
          ),
          _a(
            'Feed on demand',
            'Continue feeding whenever baby shows hunger cues.',
            '🍼',
            [
              'Watch for hunger cues.',
              'Feed before crying starts.',
              'Let baby feed until satisfied.',
            ],
          ),
          _a(
            'Bedtime routine',
            'Keep bedtime routine consistent every night.',
            '🌙',
            [
              'Same time, same order every night.',
              'Bath, feed, book, song, sleep.',
              'Aim for bedtime between 6:30-8pm.',
            ],
          ),
        ],
        signsToLookFor: [
          _pos(
            'Accepting a variety of foods',
            'Exposure to many flavours now reduces fussiness later.',
          ),
          _pos(
            'Self-feeding attempts',
            'Grabbing the spoon or picking up finger foods.',
          ),
          _pos('Regular wet diapers', '6+ wet diapers per day.'),
          _pos('Active awake periods', 'More alert time during the day.'),
          _watch(
            'Refusing all solid foods at 8 months',
            'If baby consistently refuses all solids, consult your doctor.',
          ),
          _watch('Choking frequently', 'Gagging is normal, choking is not.'),
          _watch('Poor feeding', 'Difficulty feeding needs support.'),
          _watch('Fewer wet diapers', 'May indicate inadequate feeding.'),
        ],
        whenToWorry: [
          _warn(
            'Refusing all solid foods at 8 months',
            'If baby consistently refuses all solids, consult your doctor.',
          ),
          _warn(
            'Choking frequently',
            'Gagging is normal, choking is not. Ensure foods are appropriate texture.',
          ),
          _warn('Poor feeding', 'Contact lactation consultant or doctor.'),
          _warn(
            'Fewer wet diapers',
            'Fewer than 6 wet diapers needs evaluation.',
          ),
        ],
        commonConcerns: [
          _concern(
            'My baby wakes up multiple times at night again. Why?',
            'Sleep regressions are common at 6, 8-10, and 12 months. They\'re caused by developmental leaps, teething, and separation anxiety. They are temporary. Maintain your routine.',
          ),
          _concern(
            'How much solid food should my baby eat?',
            'At 6-9 months, solids are complementary to milk. Aim for 2-3 small meals per day. Breast milk or formula is still the main nutrition. Don\'t stress about quantities.',
          ),
        ],
        parentTips: [
          'Offer a variety of flavours — exposure now prevents fussiness later.',
          'Let baby self-feed with finger foods — it\'s messy but important.',
          'Maintain sleep routine during regressions — consistency is key.',
        ],
      );
  }
}

// ── 9–12 Months ───────────────────────────────────────────────────────────────

CategoryGuidance _months9to12(MilestoneCategory cat) {
  const label = '9-12 Months';
  switch (cat) {
    case MilestoneCategory.grossMotor:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 11,
        aboutText:
            'Your baby is becoming more mobile, curious, interactive, and independent. Many babies begin crawling, pulling to stand, babbling more clearly, and exploring everything around them.',
        milestones: [
          _m(
            'nm_gm1',
            'Crawls or scoots',
            'Moves around the floor.',
            cat,
            label,
          ),
          _m(
            'nm_gm2',
            'Sits independently',
            'Sits steadily without support.',
            cat,
            label,
          ),
          _m(
            'nm_gm3',
            'Pulls to stand using furniture',
            'Uses furniture to pull to standing.',
            cat,
            label,
          ),
          _m(
            'nm_gm4',
            'Moves between sitting and tummy positions',
            'Changes position independently.',
            cat,
            label,
          ),
          _m(
            'nm_gm5',
            'Cruises along furniture (some babies)',
            'Walks sideways holding onto furniture.',
            cat,
            label,
          ),
          _m(
            'nm_gm6',
            'Improved balance and coordination',
            'Better overall movement control.',
            cat,
            label,
          ),
        ],
        activities: [
          _a(
            'Floor play in safe open spaces',
            'Give baby space to move freely.',
            '🧸',
            [
              'Place baby on a soft mat.',
              'Surround with safe toys.',
              'Let baby explore freely.',
            ],
          ),
          _a(
            'Encourage crawling with toys',
            'Place toys just out of reach.',
            '🎯',
            [
              'Place a favourite toy just ahead.',
              'Encourage baby to move toward it.',
              'Celebrate when they reach it!',
            ],
          ),
          _a(
            'Assisted standing play',
            'Encourage pulling up using furniture.',
            '🛋️',
            [
              'Place baby next to a sturdy sofa.',
              'Put a toy on the sofa seat.',
              'Encourage them to pull up to reach it.',
            ],
          ),
          _a(
            'Obstacle-free movement area',
            'Give baby space to explore safely.',
            '🏃',
            [
              'Clear a safe open space.',
              'Remove hazards.',
              'Let baby explore freely.',
            ],
          ),
        ],
        signsToLookFor: [
          _pos(
            'Active movement around room',
            'Crawling, scooting, or rolling to explore.',
          ),
          _pos('Pulling up attempts', 'Attempts to pull to standing.'),
          _pos('Good sitting balance', 'Sits independently without support.'),
          _pos(
            'Strong leg pushing',
            'Pushes down with legs when held upright.',
          ),
          _watch(
            'Cannot sit independently',
            'Consult your doctor if baby can\'t sit without support.',
          ),
          _watch('Very limited movement', 'Minimal movement needs review.'),
          _watch(
            'No rolling or crawling attempts',
            'No locomotion attempts needs evaluation.',
          ),
          _watch(
            'Uses one side much less',
            'Asymmetric movement should be assessed.',
          ),
        ],
        whenToWorry: [
          _warn(
            'Cannot sit independently',
            'Consult your doctor if baby can\'t sit without support.',
          ),
          _warn(
            'No attempts to move or stand',
            'Any form of locomotion should be present.',
          ),
          _warn(
            'Very stiff or floppy body',
            'Either extreme may indicate a concern.',
          ),
          _warn(
            'Uses one side much less',
            'Asymmetric movement should be assessed.',
          ),
        ],
        commonConcerns: [
          _concern(
            'When will my baby walk?',
            'Most babies take first steps between 9-12 months and walk independently by 15 months. Walking at 18 months is still within normal range.',
          ),
          _concern(
            'Should I use a baby walker?',
            'No. Baby walkers are not recommended by paediatricians. They can delay walking, cause accidents, and don\'t provide developmental benefits.',
          ),
        ],
        parentTips: [
          'Arrange furniture close together to encourage cruising.',
          'Let baby go barefoot indoors — it helps balance and foot development.',
          'Avoid baby walkers — use push toys instead.',
          'This stage can feel busy and exhausting, but your baby is building confidence, independence, and trust through everyday play, comfort, and connection.',
        ],
      );
    case MilestoneCategory.fineMotor:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 11,
        aboutText:
            'Finger control and hand coordination improve significantly during this stage.',
        milestones: [
          _m(
            'nm_fm1',
            'Picks up small objects',
            'Uses fingers to pick up small objects.',
            cat,
            label,
          ),
          _m(
            'nm_fm2',
            'Transfers toys between hands easily',
            'Passes toy from one hand to the other.',
            cat,
            label,
          ),
          _m(
            'nm_fm3',
            'Bangs objects together',
            'Deliberately bangs two objects together.',
            cat,
            label,
          ),
          _m(
            'nm_fm4',
            'Uses raking grasp',
            'Uses whole hand to rake objects closer.',
            cat,
            label,
          ),
          _m(
            'nm_fm5',
            'Begins pincer grasp (thumb + finger)',
            'Picks up small objects with thumb and forefinger.',
            cat,
            label,
          ),
          _m(
            'nm_fm6',
            'Points or reaches intentionally',
            'Uses index finger to point at objects.',
            cat,
            label,
          ),
        ],
        activities: [
          _a('Soft blocks', 'Encourage stacking and banging.', '🏗️', [
            'Give baby soft blocks.',
            'Demonstrate stacking.',
            'Let baby knock them down.',
          ]),
          _a(
            'Finger foods (age-appropriate)',
            'Practice the pincer grasp.',
            '🫐',
            [
              'Place soft puffs or small pieces of banana on the tray.',
              'Let baby try to pick them up.',
              'Celebrate every attempt!',
            ],
          ),
          _a('Stacking toys', 'Encourage stacking and problem-solving.', '🪣', [
            'Give baby stacking cups.',
            'Demonstrate stacking.',
            'Let baby try.',
          ]),
          _a('Sensory play', 'Stimulate sensory development.', '🎨', [
            'Offer objects with different textures.',
            'Let baby feel and mouth each one.',
            'Name the textures.',
          ]),
        ],
        signsToLookFor: [
          _pos('Intentional reaching', 'Reaches toward objects on purpose.'),
          _pos('Holds and transfers toys', 'Grasps and transfers objects.'),
          _pos('Finger exploration', 'Uses fingers to explore objects.'),
          _pos('Brings objects to mouth safely', 'Hand-to-mouth movement.'),
          _watch(
            'No reaching attempts',
            'No interest in reaching needs evaluation.',
          ),
          _watch('Very limited hand use', 'Minimal hand use needs evaluation.'),
          _watch(
            'Persistent tight fists',
            'Hands always clenched needs review.',
          ),
          _watch(
            'Unequal hand movement',
            'Strong hand preference before 12 months needs evaluation.',
          ),
        ],
        whenToWorry: [
          _warn(
            'No pincer grasp by 12 months',
            'If baby is still using whole-hand grasp only by 12 months, mention to your doctor.',
          ),
          _warn(
            'No reaching attempts',
            'If baby shows no interest in reaching for toys, mention to your doctor.',
          ),
          _warn(
            'Unequal hand movement',
            'Strong hand preference before 12 months needs evaluation.',
          ),
        ],
        commonConcerns: [
          _concern(
            'My baby throws food off the high chair. How do I stop it?',
            'Throwing food is developmentally normal at this age — it\'s cause-and-effect learning. Stay calm, say "food stays on the tray", and end the meal if it continues.',
          ),
        ],
        parentTips: [
          'Give baby their own spoon at mealtimes — expect mess.',
          'Offer finger foods to practice pincer grasp.',
          'Stack cups and blocks are great fine motor toys.',
        ],
      );
    case MilestoneCategory.language:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 11,
        aboutText:
            'Your baby is understanding more language and becoming more expressive socially.',
        milestones: [
          _m(
            'nm_la1',
            'Babbling with repeated sounds',
            'Uses "mama", "dada", or another word meaningfully.',
            cat,
            label,
          ),
          _m(
            'nm_la2',
            'Responds to own name',
            'Turns when their name is called.',
            cat,
            label,
          ),
          _m(
            'nm_la3',
            'Understands simple words like "no"',
            'Pauses or reacts when told "no".',
            cat,
            label,
          ),
          _m(
            'nm_la4',
            'May say first words',
            'Uses "mama", "dada", or another word meaningfully.',
            cat,
            label,
          ),
          _m(
            'nm_la5',
            'Uses gestures to communicate',
            'Points, waves, raises arms to be picked up.',
            cat,
            label,
          ),
          _m(
            'nm_la6',
            'Imitates words',
            'Tries to copy simple words or sounds.',
            cat,
            label,
          ),
        ],
        activities: [
          _a('Read books daily', 'Reading builds language foundations.', '📚', [
            'Choose simple board books.',
            'Point to pictures and name them.',
            'Use an expressive voice.',
          ]),
          _a(
            'Name objects during routines',
            'Point to and name objects throughout the day.',
            '👆',
            [
              'Point to objects: "That\'s a cup."',
              'Use simple, clear words.',
              'Repeat the same words consistently.',
            ],
          ),
          _a(
            'Sing songs and rhymes',
            'Singing helps baby learn rhythm and language.',
            '🎵',
            [
              'Choose 2-3 simple songs.',
              'Sing consistently.',
              'Use actions with songs.',
            ],
          ),
          _a(
            'Encourage imitation sounds',
            'Encourage baby to copy sounds.',
            '🗣️',
            [
              'Make a sound.',
              'Wait for baby to copy.',
              'Celebrate when they do.',
            ],
          ),
        ],
        signsToLookFor: [
          _pos(
            'Using words with meaning',
            'Even one consistent word is a major milestone.',
          ),
          _pos(
            'Pointing to communicate',
            'Pointing is a key pre-language communication skill.',
          ),
          _pos('Responds to familiar words', 'Understands simple words.'),
          _pos(
            'Uses gestures during interaction',
            'Waves, points, raises arms.',
          ),
          _watch(
            'No words by 12 months',
            'If baby has no words by 12 months, request a speech and language evaluation.',
          ),
          _watch(
            'No pointing or gestures by 12 months',
            'Absence of pointing is a key red flag.',
          ),
          _watch(
            'Loss of previously acquired words',
            'Any regression in language needs immediate evaluation.',
          ),
          _watch(
            'No response to name',
            'May indicate hearing or developmental concerns.',
          ),
        ],
        whenToWorry: [
          _warn(
            'No words by 12 months',
            'If baby has no words by 12 months, request a speech and language evaluation.',
          ),
          _warn(
            'No pointing or gestures by 12 months',
            'Absence of pointing is a key red flag — consult your doctor.',
          ),
          _warn(
            'Loss of previously acquired words',
            'Any regression in language needs immediate evaluation.',
          ),
        ],
        commonConcerns: [
          _concern(
            'My baby understands everything but won\'t talk. Is that normal?',
            'Yes, receptive language (understanding) always develops ahead of expressive language (speaking). As long as baby is understanding and using gestures, speech will follow. If no words by 15 months, seek evaluation.',
          ),
        ],
        parentTips: [
          'Read books every day — point to pictures and name them.',
          'Respond to every gesture and attempt at communication.',
          'Limit screen time — face-to-face interaction builds language.',
        ],
      );
    case MilestoneCategory.cognitive:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 11,
        aboutText:
            'Your baby is a little scientist — testing, experimenting, and problem-solving.',
        milestones: [
          _m(
            'nm_co1',
            'Finds hidden objects',
            'Searches for a toy hidden under a cloth.',
            cat,
            label,
          ),
          _m(
            'nm_co2',
            'Imitates actions',
            'Copies clapping, waving, banging.',
            cat,
            label,
          ),
          _m(
            'nm_co3',
            'Explores objects in multiple ways',
            'Shakes, bangs, throws, drops to learn.',
            cat,
            label,
          ),
          _m(
            'nm_co4',
            'Simple pretend play beginning',
            'Pretends to drink from empty cup.',
            cat,
            label,
          ),
          _m(
            'nm_co5',
            'Understands simple routines',
            'Anticipates familiar events.',
            cat,
            label,
          ),
        ],
        activities: [
          _a(
            'Advanced Hide and Seek',
            'Hide objects in multiple locations.',
            '🔍',
            [
              'Hide a toy under one of two cloths.',
              'Ask "Where is it?"',
              'Let baby search and find it.',
            ],
          ),
          _a('Pretend Play', 'Introduce simple pretend play.', '🎭', [
            'Pretend to drink from an empty cup.',
            'Offer it to baby.',
            'Celebrate when they pretend too.',
          ]),
          _a('Peek-a-boo', 'Builds object permanence.', '👀', [
            'Cover your face.',
            'Say "Where\'s Mummy?"',
            'Reveal with "Peek-a-boo!"',
          ]),
          _a('Interactive floor games', 'Encourage exploration.', '🧸', [
            'Place baby on a soft mat.',
            'Surround with safe toys.',
            'Let baby explore freely.',
          ]),
        ],
        signsToLookFor: [
          _pos(
            'Searching for hidden objects',
            'Full object permanence established.',
          ),
          _pos('Beginning pretend play', 'Early symbolic thinking developing.'),
          _pos('Imitates actions', 'Imitation is how babies learn.'),
          _pos(
            'Curious about surroundings',
            'Interested in everything nearby.',
          ),
          _watch(
            'No imitation of actions by 12 months',
            'If baby doesn\'t copy simple actions, consult your doctor.',
          ),
          _watch(
            'No curiosity about surroundings',
            'Lack of awareness needs evaluation.',
          ),
          _watch(
            'No eye contact',
            'Consistent avoidance of eye contact needs evaluation.',
          ),
          _watch('No visual tracking', 'May indicate visual concerns.'),
        ],
        whenToWorry: [
          _warn(
            'No imitation of actions by 12 months',
            'If baby doesn\'t copy simple actions, consult your doctor.',
          ),
          _warn(
            'No curiosity about surroundings',
            'Lack of any environmental awareness needs evaluation.',
          ),
          _warn(
            'No eye contact',
            'Consistent avoidance of eye contact needs evaluation.',
          ),
        ],
        commonConcerns: [
          _concern(
            'My baby is into everything. How do I keep them safe?',
            'Baby-proof thoroughly: cover outlets, secure furniture, remove choking hazards, gate stairs. Create a safe "yes" environment where baby can explore freely.',
          ),
        ],
        parentTips: [
          'Create a safe space where baby can explore freely.',
          'Simple puzzles and shape sorters are great cognitive toys.',
          'Narrate what baby is doing: "You\'re putting the block in!"',
        ],
      );
    case MilestoneCategory.social:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 11,
        aboutText:
            'Your baby is showing a clear personality and strong preferences.',
        milestones: [
          _m(
            'nm_so1',
            'Shows separation anxiety',
            'Cries or protests when caregiver leaves.',
            cat,
            label,
          ),
          _m(
            'nm_so2',
            'Plays simple interactive games',
            'Enjoys pat-a-cake, clapping games.',
            cat,
            label,
          ),
          _m(
            'nm_so3',
            'Shows preferences for people and toys',
            'Has clear favourite people and objects.',
            cat,
            label,
          ),
          _m(
            'nm_so4',
            'Offers objects to others',
            'Holds out toys to share.',
            cat,
            label,
          ),
          _m(
            'nm_so5',
            'Shows affection to familiar people',
            'Hugs, kisses, or cuddles caregivers.',
            cat,
            label,
          ),
        ],
        activities: [
          _a('Pat-a-cake', 'Play pat-a-cake and clapping games.', '👏', [
            'Clap baby\'s hands together saying "pat-a-cake".',
            'Do it consistently so baby anticipates it.',
            'Let baby initiate the game.',
          ]),
          _a('Sharing games', 'Practice giving and taking objects.', '🎁', [
            'Hold out your hand: "Can I have it?"',
            'Take the toy and say "thank you".',
            'Give it back: "Here you go." Repeat.',
          ]),
          _a('Interactive games', 'Play simple interactive games.', '🎮', [
            'Play the same games consistently.',
            'Let baby anticipate what comes next.',
            'Celebrate their excitement.',
          ]),
          _a(
            'Comfort during separation moments',
            'Keep goodbyes brief and cheerful.',
            '💗',
            [
              'Say goodbye — don\'t sneak away.',
              'Come back consistently.',
              'Practice short separations.',
            ],
          ),
        ],
        signsToLookFor: [
          _pos('Offering objects to share', 'Early social sharing behaviour.'),
          _pos('Showing affection', 'Hugs, kisses, or cuddles caregivers.'),
          _pos(
            'Enjoys interactive games',
            'Shows pleasure during social play.',
          ),
          _pos('Calms with comfort', 'Settles with familiar voice or touch.'),
          _watch(
            'No interest in social games by 12 months',
            'If baby doesn\'t engage in simple interactive games, mention to your doctor.',
          ),
          _watch('Rarely smiles', 'Absence of social smile needs evaluation.'),
          _watch(
            'No interaction with caregivers',
            'Limited social response needs evaluation.',
          ),
          _watch(
            'No eye contact',
            'Consistent avoidance of eye contact needs evaluation.',
          ),
        ],
        whenToWorry: [
          _warn(
            'No interest in social games by 12 months',
            'If baby doesn\'t engage in simple interactive games, mention to your doctor.',
          ),
          _warn(
            'No interaction with caregivers',
            'Limited social response needs evaluation.',
          ),
          _warn(
            'No eye contact',
            'Consistent avoidance of eye contact needs evaluation.',
          ),
        ],
        commonConcerns: [
          _concern(
            'My baby hits and bites. Is that normal?',
            'Yes, at this age. Baby doesn\'t have the language to express frustration, so they use physical actions. Stay calm, say "no hitting", redirect. It will improve as language develops.',
          ),
        ],
        parentTips: [
          'Play interactive games every day.',
          'Model sharing and taking turns.',
          'Name emotions: "You\'re frustrated. I understand."',
          'This stage can feel busy and exhausting, but your baby is building confidence, independence, and trust through everyday play, comfort, and connection.',
        ],
      );
    case MilestoneCategory.feedingSleep:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 11,
        aboutText:
            'Baby is transitioning to family foods and developing self-feeding skills.',
        milestones: [
          _m(
            'nm_fs1',
            'Eating soft finger foods',
            'Picks up and eats soft pieces of food.',
            cat,
            label,
          ),
          _m(
            'nm_fs2',
            'Drinking from sippy cup',
            'Uses a sippy or straw cup independently.',
            cat,
            label,
          ),
          _m(
            'nm_fs3',
            'Eating 3 meals per day',
            'Established meal pattern with family.',
            cat,
            label,
          ),
          _m(
            'nm_fs4',
            'Sleeping 11-14 hours total',
            'Night sleep plus 1-2 naps.',
            cat,
            label,
          ),
          _m(
            'nm_fs5',
            'Milk continues as primary nutrition',
            'Breast milk or formula still important.',
            cat,
            label,
          ),
        ],
        activities:
            [
              _a('Family meals', 'Include baby in family mealtimes.', '🍽️', [
                'Sit baby at the table with the family.',
                'Offer modified versions of family food.',
                'Let baby see and imitate family eating.',
              ]),
              _a(
                'Self-feeding practice',
                'Encourage self-feeding with finger foods.',
                '🫐',
                [
                  'Offer soft finger foods at every meal.',
                  'Let baby feed themselves — expect mess.',
                  'Offer a loaded spoon for them to bring to mouth.',
                ],
              ),
              _a(
                'Bedtime routine',
                'Keep bedtime routine consistent every night.',
                '🌙',
                [
                  'Same time, same order every night.',
                  'Bath, feed, book, song, sleep.',
                  'Aim for bedtime between 6:30-8pm.',
                ],
              ),
              _a(
                'Cup introduction',
                'Introduce a sippy or open cup with water.',
                '🥤',
                [
                  'Offer a small amount of water in a cup at mealtimes.',
                  'Help baby hold and tip the cup.',
                  'Expect mess — it\'s part of learning!',
                ],
              ),
            ],
        signsToLookFor: [
          _pos(
            'Self-feeding with finger foods',
            'Independence at mealtimes developing.',
          ),
          _pos(
            'Eating a variety of textures',
            'Accepting lumpy and soft solid foods.',
          ),
          _pos('Regular wet diapers', 'Good indicator of adequate feeding.'),
          _pos('Active daytime periods', 'More alert time during the day.'),
          _watch(
            'Refusing all textured foods at 12 months',
            'If baby only accepts smooth purees at 12 months, seek feeding therapy advice.',
          ),
          _watch(
            'Not drinking from a cup by 12 months',
            'Begin transitioning away from bottles by 12 months.',
          ),
          _watch('Poor feeding', 'Difficulty feeding needs support.'),
          _watch('Fewer wet diapers', 'May indicate inadequate feeding.'),
        ],
        whenToWorry: [
          _warn(
            'Refusing all textured foods at 12 months',
            'If baby only accepts smooth purees at 12 months, seek feeding therapy advice.',
          ),
          _warn(
            'Not drinking from a cup by 12 months',
            'Begin transitioning away from bottles by 12 months.',
          ),
          _warn('Poor feeding', 'Contact lactation consultant or doctor.'),
        ],
        commonConcerns: [
          _concern(
            'When should I stop breastfeeding?',
            'WHO recommends breastfeeding until at least 2 years. The right time to stop is when both mother and baby are ready. There is no medical reason to stop at 12 months if both are happy.',
          ),
          _concern(
            'My baby only wants milk and refuses food. What do I do?',
            'Reduce milk feeds slightly to increase appetite for solids. Offer solids before milk. Make mealtimes positive and pressure-free.',
          ),
        ],
        parentTips: [
          'Include baby in family mealtimes — they learn by watching.',
          'Offer a variety of foods even if rejected — it takes 10-15 exposures.',
          'Begin transitioning from bottle to cup by 12 months.',
        ],
      );
  }
}

// ── 1–1.5 Years (12–18 months) ───────────────────────────────────────────────

CategoryGuidance _months12to18(MilestoneCategory cat) {
  const label = '1-1.5 Years';
  switch (cat) {
    case MilestoneCategory.grossMotor:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 12,
        aboutText:
            'Your toddler is becoming more independent, mobile, curious, and expressive. Many toddlers begin walking, using simple words, exploring constantly, and showing strong emotional attachment.',
        milestones: [
          _m(
            'y1_gm1',
            'Walks independently',
            'Takes steps without holding onto anything.',
            cat,
            label,
          ),
          _m(
            'y1_gm2',
            'Squats to pick up toys',
            'Bends down and stands back up.',
            cat,
            label,
          ),
          _m(
            'y1_gm3',
            'Climbs onto furniture',
            'Climbs onto low chairs or sofas.',
            cat,
            label,
          ),
          _m(
            'y1_gm4',
            'Pushes/pulls toys while walking',
            'Moves toys while walking.',
            cat,
            label,
          ),
          _m(
            'y1_gm5',
            'Begins climbing stairs with support',
            'Climbs stairs holding a hand or rail.',
            cat,
            label,
          ),
          _m(
            'y1_gm6',
            'May attempt running',
            'Moves quickly but may stumble.',
            cat,
            label,
          ),
        ],
        activities:
            [
              _a('Push toys', 'Encourage walking with push toys.', '🚗', [
                'Give baby a push toy.',
                'Let them push it forward.',
                'Walk alongside for safety.',
              ]),
              _a(
                'Outdoor walking play',
                'Let toddler walk as much as possible.',
                '🚶',
                [
                  'Go for short walks outside.',
                  'Let toddler set the pace.',
                  'Point out things along the way.',
                ],
              ),
              _a('Ball rolling games', 'Build coordination.', '⚽', [
                'Roll a large soft ball toward toddler.',
                'Encourage them to kick it back.',
                'Gradually increase distance.',
              ]),
              _a(
                'Safe climbing opportunities',
                'Provide safe climbing surfaces.',
                '🛝',
                [
                  'Use low climbing frames.',
                  'Supervise closely.',
                  'Celebrate achievements.',
                ],
              ),
            ],
        signsToLookFor: [
          _pos(
            'Walking confidently',
            'Takes steps without holding onto anything.',
          ),
          _pos('Improved balance', 'Falls less frequently over time.'),
          _pos(
            'Exploring movement actively',
            'Climbs, squats, and moves freely.',
          ),
          _pos('Attempts climbing', 'Shows confidence with movement.'),
          _watch(
            'Not walking by 18 months',
            'If not walking independently by 18 months, consult your doctor.',
          ),
          _watch(
            'Very stiff or floppy movement',
            'Either extreme needs evaluation.',
          ),
          _watch(
            'Frequent falling without improvement',
            'May indicate balance or coordination issues.',
          ),
          _watch(
            'Uses one side much less',
            'Asymmetric movement needs evaluation.',
          ),
        ],
        whenToWorry: [
          _warn(
            'Not walking by 18 months',
            'If not walking independently by 18 months, consult your doctor.',
          ),
          _warn(
            'Very stiff or floppy movement',
            'Either extreme may indicate a concern.',
          ),
          _warn(
            'Frequent falling without improvement',
            'May indicate balance or coordination issues.',
          ),
        ],
        commonConcerns: [
          _concern(
            'My toddler walks on their tiptoes. Should I worry?',
            'Occasional tiptoeing is normal. Consistent tiptoeing after 2 years, especially with other developmental concerns, should be evaluated.',
          ),
        ],
        parentTips: [
          'Let toddler walk as much as possible — limit pushchair use.',
          'Provide safe climbing opportunities — low climbing frames, cushion piles.',
          'Barefoot walking on different surfaces builds balance.',
          'Simple everyday moments like talking, reading, cuddling, feeding, and playing together are helping your child build confidence, communication, independence, and emotional security every single day.',
        ],
      );
    case MilestoneCategory.fineMotor:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 12,
        aboutText:
            'Hand coordination and finger control improve significantly.',
        milestones: [
          _m(
            'y1_fm1',
            'Picks up small objects using fingers',
            'Uses fingers to pick up food and objects.',
            cat,
            label,
          ),
          _m(
            'y1_fm2',
            'Turns book pages',
            'Flips thick pages of a book.',
            cat,
            label,
          ),
          _m(
            'y1_fm3',
            'Stacks 2–3 blocks',
            'Places blocks on top of each other.',
            cat,
            label,
          ),
          _m(
            'y1_fm4',
            'Uses spoon with help',
            'Attempts to feed self with a spoon.',
            cat,
            label,
          ),
          _m(
            'y1_fm5',
            'Scribbles with crayon',
            'Makes marks on paper with a crayon.',
            cat,
            label,
          ),
          _m(
            'y1_fm6',
            'Points to objects intentionally',
            'Uses index finger to point.',
            cat,
            label,
          ),
        ],
        activities: [
          _a(
            'Block tower',
            'Build towers together and knock them down.',
            '🏗️',
            [
              'Stack 2-3 blocks.',
              'Let toddler knock them down.',
              'Encourage them to build their own tower.',
            ],
          ),
          _a('Scribble art', 'Provide chunky crayons and large paper.', '🖍️', [
            'Give chunky crayons and large paper.',
            'Demonstrate scribbling.',
            'Let toddler scribble freely.',
          ]),
          _a(
            'Finger foods and self-feeding',
            'Practice the pincer grasp.',
            '🫐',
            [
              'Offer soft finger foods at every meal.',
              'Let toddler feed themselves.',
              'Offer a loaded spoon for them to bring to mouth.',
            ],
          ),
          _a('Container filling/emptying games', 'Practice in-and-out.', '🪣', [
            'Give toddler a cup and some large blocks.',
            'Demonstrate putting a block in.',
            'Let toddler try.',
          ]),
        ],
        signsToLookFor: [
          _pos('Uses fingers to pick up food', 'Pincer grasp developing.'),
          _pos('Points to objects', 'Intentional pointing behaviour.'),
          _pos('Holds toys intentionally', 'Grasps and holds objects.'),
          _pos('Explores with hands often', 'Active hand exploration.'),
          _watch('Very limited hand use', 'Minimal hand use needs evaluation.'),
          _watch(
            'Cannot grasp small objects',
            'May indicate fine motor delay.',
          ),
          _watch(
            'Persistent tight fists',
            'Hands always clenched needs review.',
          ),
          _watch(
            'Unequal hand movement',
            'Strong hand preference before 12 months needs evaluation.',
          ),
        ],
        whenToWorry: [
          _warn('Very limited hand use', 'Minimal hand use needs evaluation.'),
          _warn(
            'Cannot grasp small objects',
            'May indicate fine motor delay — seek occupational therapy assessment.',
          ),
        ],
        commonConcerns: [
          _concern(
            'Should my toddler be using their right or left hand?',
            'Hand preference usually establishes between 18 months and 3 years. Don\'t force a preference. If toddler strongly favours one hand before 18 months, mention to your doctor.',
          ),
        ],
        parentTips: [
          'Provide chunky crayons and large paper for scribbling.',
          'Let toddler help with self-care: putting on shoes, washing hands.',
          'Simple puzzles and shape sorters are great fine motor toys.',
        ],
      );
    case MilestoneCategory.language:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 12,
        aboutText:
            'Your toddler is understanding much more language and beginning early speech development.',
        milestones: [
          _m(
            'y1_la1',
            'Says a few simple words',
            'Uses a small vocabulary of real words.',
            cat,
            label,
          ),
          _m(
            'y1_la2',
            'Understands simple instructions',
            'Follows "give me", "come here", "no".',
            cat,
            label,
          ),
          _m(
            'y1_la3',
            'Points to familiar objects',
            'Points to objects when named.',
            cat,
            label,
          ),
          _m(
            'y1_la4',
            'Uses gestures like waving or clapping',
            'Communicates with gestures.',
            cat,
            label,
          ),
          _m(
            'y1_la5',
            'Responds to own name',
            'Turns when their name is called.',
            cat,
            label,
          ),
          _m(
            'y1_la6',
            'Tries imitating sounds',
            'Attempts to copy simple words or sounds.',
            cat,
            label,
          ),
        ],
        activities: [
          _a('Read picture books', 'Point to and name pictures.', '📚', [
            'Choose simple board books.',
            'Point to pictures and name them.',
            'Ask "Where is the dog?"',
          ]),
          _a(
            'Name objects during routines',
            'Point to and name objects throughout the day.',
            '👆',
            [
              'Point to objects: "That\'s a cup."',
              'Use simple, clear words.',
              'Repeat the same words consistently.',
            ],
          ),
          _a(
            'Sing songs and rhymes',
            'Singing helps toddler learn rhythm and language.',
            '🎵',
            [
              'Choose 2-3 simple songs.',
              'Sing consistently.',
              'Use actions with songs.',
            ],
          ),
          _a(
            'Encourage imitation words',
            'Encourage toddler to copy words.',
            '🗣️',
            [
              'Say a simple word.',
              'Wait for toddler to copy.',
              'Celebrate when they do.',
            ],
          ),
        ],
        signsToLookFor: [
          _pos(
            'Responds to simple requests',
            'Understands and follows simple instructions.',
          ),
          _pos(
            'Uses gestures during interaction',
            'Waves, points, raises arms.',
          ),
          _pos(
            'Attempts vocal communication',
            'Tries to communicate with sounds or words.',
          ),
          _pos(
            'Watches faces while listening',
            'Shows interest in communication.',
          ),
          _watch(
            'No words by 18 months',
            'Request a speech and language evaluation.',
          ),
          _watch(
            'No response to name',
            'May indicate hearing or developmental concerns.',
          ),
          _watch(
            'No gestures or pointing',
            'Key milestone — consult your doctor if not present.',
          ),
          _watch(
            'Limited interaction or eye contact',
            'Limited engagement needs review.',
          ),
        ],
        whenToWorry: [
          _warn(
            'No words by 18 months',
            'Request a speech and language evaluation.',
          ),
          _warn(
            'No response to name',
            'May indicate hearing or developmental concerns.',
          ),
          _warn(
            'No gestures or pointing',
            'Key milestone — consult your doctor if not present.',
          ),
          _warn(
            'Loss of previously acquired words',
            'Any regression needs immediate evaluation.',
          ),
        ],
        commonConcerns: [
          _concern(
            'My toddler uses their own language that only I understand. Is that normal?',
            'Yes. At 18 months, 25% of speech should be understandable to strangers. By 24 months, 50%. By 36 months, 75%. If significantly below these, seek speech therapy.',
          ),
          _concern(
            'Does screen time affect language development?',
            'Yes. Screen time displaces face-to-face interaction, which is essential for language. Limit to 1 hour per day of high-quality content for 18-24 month olds, with a caregiver watching together.',
          ),
        ],
        parentTips: [
          'Read books every day — it\'s the single best thing for language.',
          'Expand on what toddler says: they say "dog", you say "yes, big brown dog!"',
          'Limit screen time — face-to-face interaction builds language.',
        ],
      );
    case MilestoneCategory.cognitive:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 12,
        aboutText:
            'Your toddler is engaging in pretend play, sorting, and beginning to understand concepts like "more", "all gone", and "mine".',
        milestones: [
          _m(
            'y1_co1',
            'Simple pretend play',
            'Pretends to feed a doll or talk on a toy phone.',
            cat,
            label,
          ),
          _m(
            'y1_co2',
            'Sorts shapes and colours',
            'Begins to match shapes or group by colour.',
            cat,
            label,
          ),
          _m(
            'y1_co3',
            'Completes simple puzzles',
            'Places pieces in a 2-3 piece puzzle.',
            cat,
            label,
          ),
          _m(
            'y1_co4',
            'Points to pictures in books',
            'Identifies and points to named pictures.',
            cat,
            label,
          ),
          _m(
            'y1_co5',
            'Copies simple actions',
            'Imitates adult activities.',
            cat,
            label,
          ),
          _m(
            'y1_co6',
            'Understands simple routines',
            'Anticipates familiar events.',
            cat,
            label,
          ),
        ],
        activities: [
          _a('Pretend play', 'Set up simple pretend play scenarios.', '🎭', [
            'Offer a doll and pretend food.',
            'Demonstrate feeding the doll.',
            'Let toddler take over the play.',
          ]),
          _a(
            'Shape sorter',
            'Use a shape sorter to build cognitive skills.',
            '🔷',
            [
              'Show toddler how to match shapes.',
              'Let them try independently.',
              'Celebrate every success.',
            ],
          ),
          _a('Simple puzzles', 'Start with 2-piece puzzles.', '🧩', [
            'Show toddler how to place pieces.',
            'Let them try independently.',
            'Celebrate every success.',
          ]),
          _a('Hide-and-find games', 'Build object permanence.', '🔍', [
            'Hide a toy under a blanket.',
            'Ask "Where did it go?"',
            'Let toddler find it.',
          ]),
        ],
        signsToLookFor: [
          _pos('Engaging in pretend play', 'Symbolic thinking is developing.'),
          _pos(
            'Completing simple puzzles',
            'Problem-solving and spatial awareness.',
          ),
          _pos(
            'Curious about surroundings',
            'Interested in everything nearby.',
          ),
          _pos('Follows routines', 'Anticipates familiar events.'),
          _watch(
            'No pretend play by 18 months',
            'Absence of pretend play may need evaluation.',
          ),
          _watch(
            'No curiosity about surroundings',
            'Lack of awareness needs evaluation.',
          ),
          _watch(
            'No imitation of actions',
            'Limited imitation needs evaluation.',
          ),
          _watch('Difficult to engage', 'Limited engagement needs review.'),
        ],
        whenToWorry: [
          _warn(
            'No pretend play by 18 months',
            'Absence of pretend play needs evaluation.',
          ),
          _warn(
            'No curiosity about surroundings',
            'Lack of any environmental awareness needs evaluation.',
          ),
        ],
        commonConcerns: [
          _concern(
            'My toddler has tantrums every day. Is that normal?',
            'Yes. Tantrums peak between 18 months and 3 years. Toddlers have big emotions but limited language and self-regulation. Stay calm, validate feelings, and set consistent limits.',
          ),
        ],
        parentTips: [
          'Provide open-ended toys: blocks, play dough, dolls.',
          'Ask questions: "What does the cow say?"',
          'Let toddler help with simple tasks — it builds confidence.',
        ],
      );
    case MilestoneCategory.social:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 12,
        aboutText:
            'Your toddler is asserting independence, testing limits, and beginning to play alongside other children.',
        milestones: [
          _m(
            'y1_so1',
            'Shows affection to familiar people',
            'Hugs, kisses, or cuddles caregivers.',
            cat,
            label,
          ),
          _m(
            'y1_so2',
            'Plays alongside other children',
            'Parallel play — plays near but not yet with others.',
            cat,
            label,
          ),
          _m(
            'y1_so3',
            'Shows defiance',
            'Says "no" and asserts independence.',
            cat,
            label,
          ),
          _m(
            'y1_so4',
            'Imitates adult activities',
            'Pretends to talk on phone, sweep, or cook.',
            cat,
            label,
          ),
          _m(
            'y1_so5',
            'Seeks comfort from caregivers',
            'Comes to caregiver when upset.',
            cat,
            label,
          ),
        ],
        activities: [
          _a('Playdates', 'Arrange playdates with other toddlers.', '👫', [
            'Arrange a playdate with 1-2 other toddlers.',
            'Supervise but don\'t direct play.',
            'Parallel play is normal — don\'t force sharing.',
          ]),
          _a('Household helper', 'Let toddler help with simple chores.', '🧹', [
            'Give toddler a small broom or cloth.',
            'Let them "help" sweep or wipe.',
            'Praise their contribution.',
          ]),
          _a('Interactive family play', 'Play together as a family.', '🎮', [
            'Play simple games together.',
            'Let toddler lead sometimes.',
            'Celebrate their ideas.',
          ]),
          _a('Emotion naming', 'Name and validate emotions.', '💗', [
            'When toddler is upset: "I can see you\'re angry."',
            '"It\'s okay to feel angry."',
            '"Let\'s take some deep breaths together."',
          ]),
        ],
        signsToLookFor: [
          _pos(
            'Showing affection',
            'Secure attachment and emotional development.',
          ),
          _pos(
            'Parallel play with other children',
            'Normal social development at this age.',
          ),
          _pos('Seeks comfort when upset', 'Healthy attachment behaviour.'),
          _pos(
            'Imitates adult activities',
            'Social learning through imitation.',
          ),
          _watch(
            'No interest in other children by 2 years',
            'Complete disinterest in other children may need evaluation.',
          ),
          _watch(
            'Extreme tantrums that can\'t be calmed',
            'If tantrums are very frequent and intense, discuss with your doctor.',
          ),
          _watch('Rarely smiles', 'Absence of social smile needs evaluation.'),
          _watch(
            'No interaction with caregivers',
            'Limited social response needs evaluation.',
          ),
        ],
        whenToWorry: [
          _warn(
            'No interest in other children by 2 years',
            'Complete disinterest in other children may need evaluation.',
          ),
          _warn(
            'Extreme tantrums that can\'t be calmed',
            'If tantrums are very frequent and intense, discuss with your doctor.',
          ),
        ],
        commonConcerns: [
          _concern(
            'My toddler hits other children. What should I do?',
            'Stay calm, intervene immediately, say "no hitting", and redirect. Don\'t hit back to "show them how it feels". Consistent, calm responses work best. It will improve with language development.',
          ),
        ],
        parentTips: [
          'Validate emotions: "I know you\'re angry. It\'s okay to be angry."',
          'Set consistent, simple limits.',
          'Parallel play is normal — don\'t force sharing yet.',
        ],
      );
    case MilestoneCategory.feedingSleep:
      return CategoryGuidance(
        category: cat,
        ageBandIndex: 12,
        aboutText:
            'Toddler is eating family foods and transitioning to one nap. Fussy eating is very common and normal at this age.',
        milestones: [
          _m(
            'y1_fs1',
            'Eating family foods',
            'Eating modified versions of family meals.',
            cat,
            label,
          ),
          _m(
            'y1_fs2',
            'Using fork and spoon',
            'Attempts to use utensils independently.',
            cat,
            label,
          ),
          _m(
            'y1_fs3',
            'Transitioning to one nap',
            'Moving from 2 naps to 1 afternoon nap.',
            cat,
            label,
          ),
          _m(
            'y1_fs4',
            'Sleeping 11-14 hours total',
            'Night sleep plus one afternoon nap.',
            cat,
            label,
          ),
          _m(
            'y1_fs5',
            'Drinking from cup independently',
            'Uses a sippy or open cup.',
            cat,
            label,
          ),
        ],
        activities: [
          _a(
            'Family meals together',
            'Eat together as a family as often as possible.',
            '🍽️',
            [
              'Sit together at the table.',
              'Offer toddler the same food as the family.',
              'No pressure to eat — exposure is the goal.',
            ],
          ),
          _a(
            'Utensil practice',
            'Provide child-sized fork and spoon at every meal.',
            '🥄',
            [
              'Give toddler their own fork and spoon.',
              'Load the spoon for them initially.',
              'Gradually let them load it themselves.',
            ],
          ),
          _a(
            'Consistent bedtime routine',
            'Keep bedtime routine consistent every night.',
            '🌙',
            [
              'Same time, same order every night.',
              'Bath, feed, book, song, sleep.',
              'Aim for bedtime between 6:30-8pm.',
            ],
          ),
          _a(
            'Healthy snack exposure',
            'Offer a variety of healthy snacks.',
            '🍎',
            [
              'Offer new foods alongside accepted foods.',
              'No pressure to eat.',
              'Celebrate any tasting.',
            ],
          ),
        ],
        signsToLookFor: [
          _pos(
            'Eating a variety of foods',
            'Exposure to many foods now prevents fussiness later.',
          ),
          _pos(
            'Using utensils independently',
            'Self-feeding skills developing.',
          ),
          _pos('Active daytime play', 'More alert time during the day.'),
          _pos(
            'Self-feeding attempts',
            'Independence at mealtimes developing.',
          ),
          _watch(
            'Eating fewer than 20 different foods',
            'Very limited diet may indicate feeding difficulties.',
          ),
          _watch(
            'Gagging or vomiting at mealtimes',
            'May indicate sensory feeding issues.',
          ),
          _watch(
            'Persistent feeding refusal',
            'Persistent refusal needs evaluation.',
          ),
          _watch('Difficulty swallowing', 'May indicate feeding difficulties.'),
        ],
        whenToWorry: [
          _warn(
            'Eating fewer than 20 different foods',
            'Very limited diet may indicate feeding difficulties — seek advice.',
          ),
          _warn(
            'Gagging or vomiting at mealtimes',
            'May indicate sensory feeding issues — consult your doctor.',
          ),
          _warn(
            'Persistent feeding refusal',
            'Persistent refusal needs evaluation.',
          ),
        ],
        commonConcerns: [
          _concern(
            'My toddler only eats 5 foods. Is that normal?',
            'Food neophobia (fear of new foods) peaks between 18 months and 3 years. Keep offering variety without pressure. It takes 10-15 exposures before a new food is accepted.',
          ),
          _concern(
            'When should my toddler drop the afternoon nap?',
            'Most toddlers transition to one nap between 15-18 months. Signs: taking a long time to fall asleep at nap time, or nap interfering with bedtime.',
          ),
        ],
        parentTips: [
          'Offer new foods alongside accepted foods — no pressure.',
          'Let toddler help prepare food — they\'re more likely to eat it.',
          'Keep mealtimes positive and pressure-free.',
        ],
      );
  }
}

// ── 18 months to 6 years ─────────────────────────────────────────────────────

CategoryGuidance _months18to24(MilestoneCategory cat) => _stage(
  bandIndex: 13,
  label: '1.5-2 Years',
  prefix: 'm18_24',
  category: cat,
  stageIntro:
      'Your toddler is becoming more independent, expressive, energetic, and curious during the 1.5-2 year stage.',
  parentReminder:
      'Everyday moments like talking, reading, cuddling, playing, and comforting help your child build confidence, communication skills, emotional security, and independence.',
  commonConcerns: [
    'Tantrums',
    'Saying "no" frequently',
    'Climbing everywhere',
    'Separation anxiety',
    'Picky eating',
    'Sleep resistance',
  ],
);

CategoryGuidance _years2to2half(MilestoneCategory cat) => _stage(
  bandIndex: 14,
  label: '2-2.5 Years',
  prefix: 'y2_2h',
  category: cat,
  stageIntro:
      'Your toddler is becoming more independent, talkative, imaginative, and energetic during the 2-2.5 year stage.',
  parentReminder:
      'Talking, reading, comforting, playing, and setting gentle boundaries help your child build confidence, communication, emotional security, and independence.',
  commonConcerns: [
    'Tantrums',
    'Strong independence',
    'Picky eating',
    'Sleep resistance',
    'Climbing everywhere',
    'Big emotions and frustration',
  ],
);

CategoryGuidance _years2halfto3(MilestoneCategory cat) => _stage(
  bandIndex: 15,
  label: '2.5-3 Years',
  prefix: 'y2h_3',
  category: cat,
  stageIntro:
      'Your toddler is becoming more imaginative, talkative, independent, and socially aware during the 2.5-3 year stage.',
  parentReminder:
      'Reading, talking, cuddling, playing, and setting calm boundaries continue helping your child build confidence, communication, emotional security, and independence.',
  commonConcerns: [
    'Big tantrums',
    'Strong independence',
    'Picky eating',
    'Sleep resistance',
    'Constant questions',
    'Difficulty sharing',
  ],
);

CategoryGuidance _years3to4(MilestoneCategory cat) => _stage(
  bandIndex: 16,
  label: '3-4 Years',
  prefix: 'y3_4',
  category: cat,
  stageIntro:
      'Your child is becoming more independent, imaginative, social, and expressive during the 3-4 year stage.',
  parentReminder:
      'Reading, talking, cuddling, playing, listening, and setting calm boundaries help your child build confidence, communication, emotional intelligence, and independence.',
  commonConcerns: [
    'Big emotions and tantrums',
    'Constant "why?" questions',
    'Picky eating',
    'Fear of darkness',
    'Difficulty sharing',
    'Strong independence',
  ],
);

CategoryGuidance _years4to5(MilestoneCategory cat) => _stage(
  bandIndex: 17,
  label: '4-5 Years',
  prefix: 'y4_5',
  category: cat,
  stageIntro:
      'Your child is becoming more confident, imaginative, social, and independent during the 4-5 year stage.',
  parentReminder:
      'Listening, reading, playing, talking, cuddling, and setting calm boundaries help your child build confidence, emotional security, communication skills, and independence.',
  commonConcerns: [
    'Big emotions',
    'Difficulty sharing',
    'Strong independence',
    'Picky eating',
    'Fear of imaginary things',
    'Testing boundaries',
  ],
);

CategoryGuidance _years5to6(MilestoneCategory cat) => _stage(
  bandIndex: 18,
  label: '5-6 Years',
  prefix: 'y5_6',
  category: cat,
  stageIntro:
      'Your child is becoming more independent, expressive, social, imaginative, and school-ready during the 5-6 year stage.',
  parentReminder:
      'Listening, reading, playing, comforting, encouraging, and setting calm boundaries help your child build confidence, communication skills, resilience, emotional security, and kindness.',
  commonConcerns: [
    'Big emotions',
    'School readiness anxiety',
    'Difficulty sharing',
    'Fear of failure',
    'Picky eating',
    'Bedtime resistance',
  ],
);

CategoryGuidance _stage({
  required int bandIndex,
  required String label,
  required String prefix,
  required MilestoneCategory category,
  required String stageIntro,
  required String parentReminder,
  required List<String> commonConcerns,
}) {
  switch (category) {
    case MilestoneCategory.grossMotor:
      return _stageGuidance(
        bandIndex,
        label,
        prefix,
        category,
        'Balance, coordination, strength, and physical confidence continue improving rapidly.',
        [
          'Runs, climbs, and explores confidently',
          'Jumps or attempts jumping',
          'Walks up and down stairs with support or independently',
          'Kicks, throws, or catches balls with improving control',
          'Enjoys active playground play',
        ],
        ['Outdoor play', 'Ball games', 'Dancing and movement songs'],
        ['Good balance and coordination', 'Enjoys active physical play'],
        [
          'Frequent falling without improvement',
          'Very stiff or floppy movement',
        ],
        stageIntro,
        parentReminder,
        commonConcerns,
      );
    case MilestoneCategory.fineMotor:
      return _stageGuidance(
        bandIndex,
        label,
        prefix,
        category,
        'Hand and finger coordination improve, supporting drawing, self-care, crafts, and early writing skills.',
        [
          'Scribbles, draws, or copies simple shapes',
          'Stacks blocks or builds structures',
          'Uses spoon, cup, crayons, or pencils with more control',
          'Turns book pages independently',
          'Attempts dressing, buttons, zips, or simple self-care',
        ],
        [
          'Coloring and drawing',
          'Building blocks',
          'Play dough or simple crafts',
        ],
        ['Uses hands actively', 'Attempts self-help tasks'],
        ['Very limited hand use', 'Unequal hand movement'],
        stageIntro,
        parentReminder,
        commonConcerns,
      );
    case MilestoneCategory.language:
      return _stageGuidance(
        bandIndex,
        label,
        prefix,
        category,
        'Language grows quickly as your child understands more and expresses needs, ideas, and feelings.',
        [
          'Uses words, phrases, or sentences to communicate',
          'Follows simple instructions',
          'Names familiar objects, people, or body parts',
          'Enjoys songs, rhymes, stories, or conversations',
          'Uses gestures or words during interaction',
        ],
        [
          'Read books daily',
          'Name objects during routines',
          'Sing songs and rhymes',
        ],
        [
          'Responds during conversation',
          'Uses words or gestures to communicate',
        ],
        ['Very limited speech', 'No response to name or conversation'],
        stageIntro,
        parentReminder,
        commonConcerns,
      );
    case MilestoneCategory.cognitive:
      return _stageGuidance(
        bandIndex,
        label,
        prefix,
        category,
        'Curiosity, imagination, routines, problem-solving, and early learning skills are developing.',
        [
          'Engages in pretend or imaginative play',
          'Understands simple routines',
          'Solves simple puzzles or matching games',
          'Copies adult actions',
          'Shows curiosity about surroundings',
        ],
        ['Pretend play', 'Simple puzzles', 'Matching and sorting games'],
        ['Curious about surroundings', 'Watches and imitates others'],
        ['No pretend play', 'Very limited engagement'],
        stageIntro,
        parentReminder,
        commonConcerns,
      );
    case MilestoneCategory.social:
      return _stageGuidance(
        bandIndex,
        label,
        prefix,
        category,
        'Your child is developing stronger emotions, independence, attachment, and early friendship skills.',
        [
          'Shows affection to familiar people',
          'Enjoys interactive play',
          'Seeks comfort from caregivers',
          'Expresses excitement, frustration, or preferences clearly',
          'Plays near or with other children',
        ],
        ['Interactive play', 'Emotion naming', 'One-on-one connection time'],
        ['Enjoys interaction', 'Seeks comfort when upset'],
        [
          'Rarely interacts with others',
          'No emotional response or eye contact',
        ],
        stageIntro,
        parentReminder,
        commonConcerns,
      );
    case MilestoneCategory.feedingSleep:
      return _stageGuidance(
        bandIndex,
        label,
        prefix,
        category,
        'Meals, appetite, independence, sleep, and daily routines continue evolving.',
        [
          'Eats family foods with growing independence',
          'Uses cup or utensils with improving skill',
          'Appetite may vary day to day',
          'Sleep routines continue developing',
          'Active daytime play supports rest',
        ],
        [
          'Shared family meals',
          'Encourage self-feeding',
          'Consistent bedtime routine',
        ],
        ['Interest in meals', 'Active daytime play'],
        [
          'Persistent feeding refusal',
          'Extreme sleep difficulties or low energy',
        ],
        stageIntro,
        parentReminder,
        commonConcerns,
      );
  }
}

CategoryGuidance _stageGuidance(
  int bandIndex,
  String label,
  String prefix,
  MilestoneCategory category,
  String aboutText,
  List<String> milestones,
  List<String> activities,
  List<String> positiveSigns,
  List<String> warnings,
  String stageIntro,
  String parentReminder,
  List<String> commonConcerns,
) {
  final catPrefix = category.name;
  return CategoryGuidance(
    category: category,
    ageBandIndex: bandIndex,
    aboutText: '$stageIntro $aboutText',
    milestones: [
      for (int i = 0; i < milestones.length; i++)
        _m(
          '${prefix}_${catPrefix}_$i',
          milestones[i],
          milestones[i],
          category,
          label,
        ),
    ],
    activities: [
      for (final title in activities)
        _a(title, 'Practice through short, playful everyday moments.', '💜', [
          'Keep it relaxed and child-led.',
          'Repeat during normal routines.',
          'Stop if your child seems tired or upset.',
        ]),
    ],
    signsToLookFor: [
      for (final sign in positiveSigns) _pos(sign, sign),
      for (final warning in warnings) _watch(warning, warning),
    ],
    whenToWorry: [
      for (final warning in warnings)
        _warn(
          warning,
          'Contact your doctor if this is persistent or concerning.',
        ),
    ],
    commonConcerns: [
      _concern(
        'What concerns are common at this stage?',
        '${commonConcerns.join(', ')} are often normal during this stage.',
      ),
      _concern(
        'How should I support development?',
        'Use simple everyday moments: play, conversation, movement, comfort, repetition, and responsive care.',
      ),
    ],
    parentTips: [
      parentReminder,
      'Every child develops at their own pace.',
      'Reach out to your paediatrician if you feel something is not right.',
    ],
  );
}
