import '../dtos/moezzin_dto.dart';

class MoezzinCatalog {
  static const String _basePrayTimesShia = 'http://praytimes.org/audio/adhan/Shia';
  static const String _basePrayTimesSunni = 'http://praytimes.org/audio/adhan/Sunni';

  static final List<MoezzinDto> allMoezzins = [
    const MoezzinDto(
      id: 'ghalvash',
      nameFa: 'راغب مصطفی غلوش',
      assetPath: 'adhan_ghalvash',
      downloadUrl: '$_basePrayTimesSunni/Abdul-Basit.mp3',
    ),
    const MoezzinDto(
      id: 'moazzenzadeh',
      nameFa: 'رحیم مؤذن‌زاده اردبیلی',
      assetPath: 'adhan_moazzenzadeh',
      downloadUrl: '$_basePrayTimesShia/Aghati.mp3',
    ),
    const MoezzinDto(
      id: 'aghati',
      nameFa: 'محمد آقاتی',
      assetPath: 'adhan_aghati',
      downloadUrl: '$_basePrayTimesShia/Aghati.mp3',
    ),
    const MoezzinDto(
      id: 'sobhi',
      nameFa: 'حسینعلی صبحی',
      assetPath: 'adhan_sobhi',
      downloadUrl: '$_basePrayTimesShia/Sobhdel.mp3',
    ),
    const MoezzinDto(
      id: 'mousavi_ghahar',
      nameFa: 'قاسم موسوی قهار',
      assetPath: 'adhan_mousavi_ghahar',
      downloadUrl: '$_basePrayTimesShia/Sobhdel.mp3',
    ),
    const MoezzinDto(
      id: 'omidvar',
      nameFa: 'عطاءالله امیدوار',
      assetPath: 'adhan_omidvar',
      downloadUrl: '$_basePrayTimesShia/Aghati.mp3',
    ),
    const MoezzinDto(
      id: 'toukhi',
      nameFa: 'محمد طوخی',
      assetPath: 'adhan_toukhi',
      downloadUrl: '$_basePrayTimesShia/Sobhdel.mp3',
    ),
    const MoezzinDto(
      id: 'abdulbasit',
      nameFa: 'محمود عبدالباسط',
      assetPath: 'adhan_abdulbasit',
      downloadUrl: '$_basePrayTimesSunni/Abdul-Basit.mp3',
    ),
  ];
}
