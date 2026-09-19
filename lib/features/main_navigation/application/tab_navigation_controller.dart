import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State of the Tab Navigation with Deduplicated MRU History Stack
class TabNavigationState {
  final int currentIndex;
  final List<int> history;

  const TabNavigationState({
    required this.currentIndex,
    required this.history,
  });

  TabNavigationState copyWith({
    int? currentIndex,
    List<int>? history,
  }) {
    return TabNavigationState(
      currentIndex: currentIndex ?? this.currentIndex,
      history: history ?? this.history,
    );
  }
}

/// Global ValueNotifier for scroll-to-top events triggered when active tab is re-tapped
final tabScrollToTopNotifier = ValueNotifier<int?>(null);

/// Controller for Managing Tab Switching, Deduplicated History Stack, and Back Navigation
class TabNavigationController extends Notifier<TabNavigationState> {
  @override
  TabNavigationState build() {
    return const TabNavigationState(currentIndex: 0, history: [0]);
  }

  /// Switches to [index].
  /// If already at [index], triggers scroll-to-top.
  /// If navigating to a new tab, deduplicates history by moving [index] to the top of stack.
  void switchTab(int index) {
    if (index == state.currentIndex) {
      // Re-tapped active tab -> Trigger Scroll-to-Top
      tabScrollToTopNotifier.value = null; // reset
      tabScrollToTopNotifier.value = index;
      return;
    }

    final newHistory = List<int>.from(state.history);
    // Remove if already present in history to prevent loops
    newHistory.remove(index);
    // Push as the most recently visited tab
    newHistory.add(index);

    state = state.copyWith(
      currentIndex: index,
      history: newHistory,
    );
  }

  /// Handles Back button press.
  /// Returns `false` if the back navigation was handled internally by navigating back
  /// through tab history. Returns `true` if at root (Home) and app may exit.
  bool handleBackPress() {
    if (state.history.length > 1) {
      final newHistory = List<int>.from(state.history);
      // Pop the currently active tab from history
      newHistory.removeLast();
      // The previous tab in history becomes active
      final previousTab = newHistory.last;

      state = state.copyWith(
        currentIndex: previousTab,
        history: newHistory,
      );
      return false; // Handled internally
    }

    // If history length is 1 but we are not on Home (tab 0), return to Home
    if (state.currentIndex != 0) {
      state = state.copyWith(
        currentIndex: 0,
        history: [0],
      );
      return false; // Handled internally
    }

    // At root Home tab -> allow system back (app exit)
    return true;
  }
}

final tabNavigationControllerProvider =
    NotifierProvider<TabNavigationController, TabNavigationState>(
  TabNavigationController.new,
);
