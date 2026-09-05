import 'package:freezed_annotation/freezed_annotation.dart';

part 'moezzin.freezed.dart';

/// Model representing an Adhan reciter (moezzin).
@freezed
abstract class Moezzin with _$Moezzin {
  const factory Moezzin({
    /// Unique identifier for the moezzin
    required String id,

    /// Persian display name (e.g., 'راغب مصطفی غلوش')
    required String nameFa,

    /// Asset name prefix (e.g. 'adhan_ghalvash') 
    /// Used for default bundled audio or saved filename.
    required String assetPath,

    /// Direct URL to download the mp3 file
    required String downloadUrl,
  }) = _Moezzin;
}


