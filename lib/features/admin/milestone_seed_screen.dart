import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/milestone_guidance_service.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Milestone Guidance Seed Screen
// Accessible from Profile → Developer Tools (debug builds only)
// Seeds the Supabase milestone_guidance table from the local Dart library.
// ═══════════════════════════════════════════════════════════════════════════

class MilestoneSeedScreen extends StatefulWidget {
  const MilestoneSeedScreen({super.key});

  @override
  State<MilestoneSeedScreen> createState() => _MilestoneSeedScreenState();
}

class _MilestoneSeedScreenState extends State<MilestoneSeedScreen> {
  _SeedStatus _status = _SeedStatus.idle;
  String _message = '';
  int _progress = 0;
  final int _total = 19 * 6; // 19 bands × 6 categories

  Future<void> _seed() async {
    setState(() {
      _status = _SeedStatus.running;
      _message = 'Seeding...';
      _progress = 0;
    });

    try {
      // Seed band by band so we can show progress
      for (int band = 0; band < 19; band++) {
        await MilestoneGuidanceService.seedBand(band);
        if (mounted) {
          setState(() {
            _progress = (band + 1) * 6;
            _message = 'Seeded band ${band + 1} of 19...';
          });
        }
      }
      MilestoneGuidanceService.clearCache();
      if (mounted) {
        setState(() {
          _status = _SeedStatus.done;
          _message =
              'Done! $_total rows upserted to Supabase.\nThe app will now fetch content from Supabase instead of the local library.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = _SeedStatus.error;
          _message = _friendlyError(e);
        });
      }
    }
  }

  String _friendlyError(Object error) {
    final text = error.toString();
    if (text.contains('row-level security') ||
        text.contains('42501') ||
        text.contains('Forbidden')) {
      return 'Supabase blocked the seed write because milestone_guidance is protected by RLS.\n\nFor local/debug seeding, run supabase/dev_allow_milestone_guidance_seed.sql in the Supabase SQL editor, then tap Seed Now again.\n\nKeep that policy dev-only.';
    }
    return 'Error: $text';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Seed Milestone Guidance',
          style: AppTextStyles.headlineMedium,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingXL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info card
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingL),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What this does',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingS),
                  Text(
                    'Uploads all 114 milestone guidance pages (19 age bands × 6 categories) from the local Dart library to your Supabase milestone_guidance table.\n\nAfter seeding, you can edit content directly in the Supabase Table Editor — no code changes needed.',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.paddingXL),

            // Warning
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingL),
              decoration: BoxDecoration(
                color: AppColors.accentOrangeLight,
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
                border: Border.all(
                  color: AppColors.accentOrange.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.accentOrange,
                    size: 20,
                  ),
                  const SizedBox(width: AppConstants.paddingM),
                  Expanded(
                    child: Text(
                      'This uses upsert — existing rows will be overwritten. Run only once, or when you want to reset content to library defaults.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.paddingXL),

            // Progress
            if (_status == _SeedStatus.running) ...[
              Text(
                '$_progress / $_total rows',
                style: AppTextStyles.titleMedium,
              ),
              const SizedBox(height: AppConstants.paddingS),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                child: LinearProgressIndicator(
                  value: _total > 0 ? _progress / _total : 0,
                  minHeight: 8,
                  backgroundColor: AppColors.primaryLight,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.paddingM),
            ],

            // Status message
            if (_message.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingL),
                decoration: BoxDecoration(
                  color: _status == _SeedStatus.error
                      ? const Color(0xFFFFEBEE)
                      : _status == _SeedStatus.done
                      ? AppColors.accentGreenLight
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  border: Border.all(
                    color: _status == _SeedStatus.error
                        ? AppColors.error
                        : _status == _SeedStatus.done
                        ? AppColors.accentGreen
                        : AppColors.divider,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      _status == _SeedStatus.error
                          ? Icons.error_outline_rounded
                          : _status == _SeedStatus.done
                          ? Icons.check_circle_rounded
                          : Icons.info_outline_rounded,
                      color: _status == _SeedStatus.error
                          ? AppColors.error
                          : _status == _SeedStatus.done
                          ? AppColors.accentGreen
                          : AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: AppConstants.paddingM),
                    Expanded(
                      child: Text(
                        _message,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const Spacer(),

            // Seed button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _status == _SeedStatus.running ? null : _seed,
                icon: _status == _SeedStatus.running
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.upload_rounded, size: 20),
                label: Text(
                  _status == _SeedStatus.running
                      ? 'Seeding...'
                      : _status == _SeedStatus.done
                      ? 'Seed Again'
                      : 'Seed Now',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: AppConstants.paddingL),
          ],
        ),
      ),
    );
  }
}

enum _SeedStatus { idle, running, done, error }
