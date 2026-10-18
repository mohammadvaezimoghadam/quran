import 'package:flutter/material.dart';

import 'package:quran/features/khatm/domain/entities/khatm_enums.dart';
import 'package:quran/features/khatm/domain/entities/khatm_session_item.dart';
import 'khatm_session_tile.dart';

/// Vertical timeline list of Khatm reading sessions.
class KhatmSessionTimeline extends StatelessWidget {
  final List<KhatmSessionItem> sessions;
  final KhatmUnitType unitType;
  final void Function(int sessionIndex, bool isCompleted) onSessionToggle;
  final void Function(int sessionIndex)? onSessionTap;

  const KhatmSessionTimeline({
    super.key,
    required this.sessions,
    required this.unitType,
    required this.onSessionToggle,
    this.onSessionTap,
  });

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24.0),
        child: Center(child: Text('جلسه‌ای تعریف نشده است')),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return KhatmSessionTile(
          session: session,
          unitType: unitType,
          isFirst: index == 0,
          isLast: index == sessions.length - 1,
          onToggle: (val) => onSessionToggle(session.sessionIndex, val),
          onSessionTap: onSessionTap != null
              ? () => onSessionTap!(session.sessionIndex)
              : null,
        );
      },
    );
  }
}
