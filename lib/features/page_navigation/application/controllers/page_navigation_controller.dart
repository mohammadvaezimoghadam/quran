import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../page_navigation_service.dart';
import '../states/page_navigation_state.dart';

final pageNavigationControllerProvider = NotifierProvider<PageNavigationController, PageNavigationState>(() {
  return PageNavigationController();
});

class PageNavigationController extends Notifier<PageNavigationState> {
  @override
  PageNavigationState build() {
    return const PageNavigationState();
  }

  Future<void> processPageNumber(int pageNumber) async {
    state = state.copyWith(isLoading: true, errorMessage: null, target: null);
    
    final service = ref.read(pageNavigationServiceProvider);
    final result = await service.getTargetByPageNumber(pageNumber);

    result.when(
      (target) {
        state = state.copyWith(isLoading: false, target: target);
      },
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
    );
  }

  Future<void> processQrData(String qrData) async {
    state = state.copyWith(isLoading: true, errorMessage: null, target: null);
    
    final service = ref.read(pageNavigationServiceProvider);
    final result = await service.getTargetFromQrData(qrData);

    result.when(
      (target) {
        state = state.copyWith(isLoading: false, target: target);
      },
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
    );
  }

  void resetState() {
    state = const PageNavigationState();
  }
}
