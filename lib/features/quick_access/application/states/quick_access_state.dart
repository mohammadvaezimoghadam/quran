import '../../domain/entities/quick_access_tool_entity.dart';

/// State of the Quick Access 4-slot bar
class QuickAccessState {
  final List<QuickAccessToolEntity?> slots;
  final bool isEditMode;
  final bool isLoading;

  const QuickAccessState({
    this.slots = const [null, null, null, null],
    this.isEditMode = false,
    this.isLoading = true,
  });

  QuickAccessState copyWith({
    List<QuickAccessToolEntity?>? slots,
    bool? isEditMode,
    bool? isLoading,
  }) {
    return QuickAccessState(
      slots: slots ?? this.slots,
      isEditMode: isEditMode ?? this.isEditMode,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
