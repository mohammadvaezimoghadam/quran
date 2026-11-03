import 'package:flutter/widgets.dart';
import '../domain/walkthrough_registry.dart';
import '../domain/walkthrough_target_id.dart';

/// Lightweight wrapper attaching a centralized walkthrough key to any target widget.
/// Zero overhead, zero styling modifications, 100% encapsulated.
///
/// Uses dynamic instance GlobalKeys registered with [WalkthroughRegistry] to guarantee
/// that identical target IDs in different subtrees (e.g. mobile vs web view) NEVER
/// cause "Duplicate GlobalKeys detected in widget tree" assertions.
class WalkthroughAnchor extends StatefulWidget {
  final WalkthroughTargetId id;
  final Widget child;
  final bool enabled;

  const WalkthroughAnchor({
    super.key,
    required this.id,
    required this.child,
    this.enabled = true,
  });

  @override
  State<WalkthroughAnchor> createState() => _WalkthroughAnchorState();
}

class _WalkthroughAnchorState extends State<WalkthroughAnchor> {
  late final GlobalKey _key = GlobalKey(debugLabel: 'walkthrough_${widget.id.name}');

  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      WalkthroughRegistry.registerKey(widget.id, _key);
    }
  }

  @override
  void didUpdateWidget(WalkthroughAnchor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id || oldWidget.enabled != widget.enabled) {
      if (oldWidget.enabled) {
        WalkthroughRegistry.unregisterKey(oldWidget.id, _key);
      }
      if (widget.enabled) {
        WalkthroughRegistry.registerKey(widget.id, _key);
      }
    }
  }

  @override
  void dispose() {
    if (widget.enabled) {
      WalkthroughRegistry.unregisterKey(widget.id, _key);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    return KeyedSubtree(
      key: _key,
      child: widget.child,
    );
  }
}
