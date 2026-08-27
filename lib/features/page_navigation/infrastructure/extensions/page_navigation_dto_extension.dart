import '../../domain/entities/page_navigation_target.dart';
import '../dtos/page_navigation_dto.dart';

extension PageNavigationDtoMapper on PageNavigationDto {
  PageNavigationTarget toDomain() {
    return PageNavigationTarget(
      surahId: surahId,
      surahName: surahName,
      ayahNumber: ayahNumber,
    );
  }
}
