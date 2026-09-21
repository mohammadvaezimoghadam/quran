import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran/features/quran_reader/application/controllers/quran_reader_controller.dart';

void main() {
  group('ReaderControlsNotifier Tests', () {
    test('Initial state is not full-screen and controls are visible', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(readerControlsProvider);
      expect(state.isFullScreen, false);
      expect(state.isControlsVisible, true);
      expect(state.isControlsHidden, false);
    });

    test('toggleControls toggles visibility in full-screen mode', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(readerControlsProvider.notifier);
      notifier.updateState(isFullScreen: true, isControlsVisible: false);
      expect(container.read(readerControlsProvider).isControlsHidden, true);

      // Tapping toggles controls to visible
      notifier.toggleControls();
      expect(container.read(readerControlsProvider).isControlsVisible, true);
      expect(container.read(readerControlsProvider).isAudioBarCollapsed, false);
      expect(container.read(readerControlsProvider).isControlsHidden, false);

      // Tapping again toggles controls to hidden
      notifier.toggleControls();
      expect(container.read(readerControlsProvider).isControlsVisible, false);
      expect(container.read(readerControlsProvider).isAudioBarCollapsed, true);
      expect(container.read(readerControlsProvider).isControlsHidden, true);
    });

    test('toggleControls does nothing in normal mode, and enterFullScreen activates full-screen mode', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(readerControlsProvider.notifier);
      // In normal mode
      notifier.updateState(isFullScreen: false, isControlsVisible: true);

      // Tapping in normal mode must not force full-screen mode!
      notifier.toggleControls();
      expect(container.read(readerControlsProvider).isFullScreen, false);
      expect(container.read(readerControlsProvider).isControlsVisible, true);

      // Explicitly entering full-screen mode
      notifier.enterFullScreen();
      expect(container.read(readerControlsProvider).isFullScreen, true);
      expect(container.read(readerControlsProvider).isControlsVisible, false);
      expect(container.read(readerControlsProvider).isControlsHidden, true);
    });

    test('Exiting full-screen and reset properly deactivates full-screen mode', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(readerControlsProvider.notifier);
      notifier.updateState(isFullScreen: true, isControlsVisible: false, isAudioBarCollapsed: true);
      expect(container.read(readerControlsProvider).isFullScreen, true);

      // Exiting fullscreen restores visible controls
      notifier.updateState(isFullScreen: false, isControlsVisible: true, isAudioBarCollapsed: false);
      expect(container.read(readerControlsProvider).isFullScreen, false);
      expect(container.read(readerControlsProvider).isControlsVisible, true);
      expect(container.read(readerControlsProvider).isAudioBarCollapsed, false);

      // Reset restores initial state
      notifier.reset();
      final resetState = container.read(readerControlsProvider);
      expect(resetState.isFullScreen, false);
      expect(resetState.isControlsVisible, true);
      expect(resetState.isAudioBarCollapsed, false);
    });
  });
}
