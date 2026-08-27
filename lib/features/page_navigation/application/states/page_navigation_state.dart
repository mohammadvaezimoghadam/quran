import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/page_navigation_target.dart';

part 'page_navigation_state.freezed.dart';

@freezed
abstract class PageNavigationState with _$PageNavigationState {
  const factory PageNavigationState({
    @Default(false) bool isLoading,
    String? errorMessage,
    PageNavigationTarget? target,
  }) = _PageNavigationState;
}
