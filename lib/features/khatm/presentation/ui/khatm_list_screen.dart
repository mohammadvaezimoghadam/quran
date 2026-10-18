import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:quran/common/extensions/context_extension.dart';
import '../../../../core/routes/route_name.dart';
import '../../../../core/theme/app_typography.dart';
import '../../application/controllers/khatm_list_controller.dart';
import '../widgets/shared/khatm_list_card.dart';

/// Screen listing all personal Khatm plans with option to create a new one.
class KhatmListScreen extends ConsumerWidget {
  const KhatmListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(khatmListControllerProvider);
    final colors = context.colors;
    final colorScheme = context.colorScheme;
    final primary = colorScheme.primary;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'ختم‌های قرآن',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 16.5,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colors.cardBackground,
        leading: IconButton(
          tooltip: 'بازگشت',
          icon: Icon(
            CupertinoIcons.chevron_forward,
            size: 24,
            color: colorScheme.onSurface,
          ),
          splashRadius: 22,
          onPressed: () {
            HapticFeedback.lightImpact();
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.pop();
            }
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.8),
          child: Container(
            color: colors.cardBorder,
            height: 0.8,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.pushNamed(createKhatmWizardRoute).then((_) {
            ref.read(khatmListControllerProvider.notifier).loadPlans();
          });
        },
        backgroundColor: primary,
        elevation: 2,
        label: Text(
          'ایجاد ختم جدید',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 13.5,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () =>
              ref.read(khatmListControllerProvider.notifier).loadPlans(),
          child: _buildBody(context, ref, state),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    KhatmListState state,
  ) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.plans.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'هنوز ختمی ایجاد نکرده‌اید',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 16.5,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'می‌توانید برای جزء، حزب، سوره یا صفحه ختم‌های شخصی تعریف کنید.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 13,
                  color: theme.brightness == Brightness.dark
                      ? Colors.white60
                      : Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  context.pushNamed(createKhatmWizardRoute).then((_) {
                    ref.read(khatmListControllerProvider.notifier).loadPlans();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'ایجاد برنامه ختم جدید',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: state.plans.length,
      itemBuilder: (context, index) {
        final plan = state.plans[index];
        return KhatmListCard(
          plan: plan,
          onTap: () {
            context.pushNamed(
              khatmDetailRoute,
              pathParameters: {'id': plan.id},
            ).then((_) {
              ref.read(khatmListControllerProvider.notifier).loadPlans();
            });
          },
        );
      },
    );
  }
}
