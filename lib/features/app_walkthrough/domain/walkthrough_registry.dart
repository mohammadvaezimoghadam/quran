import 'package:flutter/widgets.dart';
import 'walkthrough_target_id.dart';

/// Centralized registry holding active GlobalKeys for walkthrough spotlight targets.
class WalkthroughRegistry {
  static final Map<WalkthroughTargetId, GlobalKey> _keys = {};

  /// Retrieves the active GlobalKey for the given target ID, or lazily creates a fallback.
  static GlobalKey getKey(WalkthroughTargetId id) {
    return _keys.putIfAbsent(
      id,
      () => GlobalKey(debugLabel: 'walkthrough_${id.name}'),
    );
  }

  /// Registers an active key for a mounted target ID.
  static void registerKey(WalkthroughTargetId id, GlobalKey key) {
    _keys[id] = key;
  }

  /// Unregisters an active key when unmounted.
  static void unregisterKey(WalkthroughTargetId id, GlobalKey key) {
    if (_keys[id] == key) {
      _keys.remove(id);
    }
  }

  /// Checks if the target is currently rendered in the active widget tree.
  static bool isTargetMounted(WalkthroughTargetId id) {
    final key = _keys[id];
    return key?.currentContext != null;
  }

  /// Clears unused keys if necessary.
  static void clear() {
    _keys.clear();
  }
}
