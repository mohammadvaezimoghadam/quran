import 'package:flutter/material.dart';

/// A smart wrapper that enables native partial text selection (Telegram style).
/// When [isSelectable] is true, a long press inside this widget will trigger
/// Flutter's native text selection handles for highlighting specific words.
/// It intelligently overrides the native context menu to ONLY show 'Copy' 
/// and 'Select All' to keep the UI clean and focused on reading.
class SmartSelectionArea extends StatefulWidget {
  final Widget child;
  final bool isSelectable;
  final VoidCallback? onTap;

  /// Tracks if ANY text is currently selected globally across the app.
  static bool hasGlobalSelection = false;

  const SmartSelectionArea({
    super.key,
    required this.child,
    this.isSelectable = false,
    this.onTap,
  });

  @override
  State<SmartSelectionArea> createState() => _SmartSelectionAreaState();
}

class _SmartSelectionAreaState extends State<SmartSelectionArea> {
  DateTime? _downTime;
  Offset _downPosition = Offset.zero;

  @override
  Widget build(BuildContext context) {
    if (!widget.isSelectable) {
      return widget.child;
    }

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (e) {
        _downTime = DateTime.now();
        _downPosition = e.position;
      },
      onPointerMove: (e) {
        if ((e.position - _downPosition).distance > 10) {
          _downTime = null; // Invalidate on move/scroll
        }
      },
      onPointerUp: (e) {
        if (_downTime != null && widget.onTap != null) {
          final duration = DateTime.now().difference(_downTime!);
          if (duration.inMilliseconds < 350) {
            widget.onTap!(); // Trigger tap logic
          }
        }
      },
      child: SelectionArea(
        onSelectionChanged: (content) {
          SmartSelectionArea.hasGlobalSelection = content != null && content.plainText.isNotEmpty;
        },
        contextMenuBuilder: (context, selectableRegionState) {
          final List<ContextMenuButtonItem> buttonItems = [];
          
          for (final item in selectableRegionState.contextMenuButtonItems) {
            if (item.type == ContextMenuButtonType.copy) {
              buttonItems.add(ContextMenuButtonItem(
                onPressed: item.onPressed,
                type: ContextMenuButtonType.copy,
                label: 'کپی',
              ));
            } else if (item.type == ContextMenuButtonType.selectAll) {
              buttonItems.add(ContextMenuButtonItem(
                onPressed: item.onPressed,
                type: ContextMenuButtonType.selectAll,
                label: 'انتخاب همه',
              ));
            }
          }

          return AdaptiveTextSelectionToolbar.buttonItems(
            anchors: selectableRegionState.contextMenuAnchors,
            buttonItems: buttonItems,
          );
        },
        child: widget.child,
      ),
    );
  }
}
