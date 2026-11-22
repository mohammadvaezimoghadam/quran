import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran/common/constants/app_constants.dart';
import 'package:quran/core/services/audio/audio_url_helper.dart';
import 'package:quran/features/quran_reader/infrastructure/datasources/reciter_catalog.dart';
import 'package:quran/features/tafsir_manager/infrastructure/datasources/tafsir_catalog.dart';
import 'package:quran/features/translation_manager/infrastructure/datasources/translation_catalog.dart';
import 'package:quran/features/translation_manager/infrastructure/datasources/translation_remote_datasource.dart';

class _FakeHttpClientAdapter implements HttpClientAdapter {
  _FakeHttpClientAdapter(this._responder);

  final ResponseBody Function(RequestOptions options) _responder;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return _responder(options);
  }
}

void main() {
  const s3Base = 'https://quran-tafakor-audio.s3.ir-central1.arvanstorage.ir';

  group('ArvanCloud S3 Catalogs & URL Helpers', () {
    test('AppConstants.everyAyahAudioBaseUrl points to ArvanCloud S3', () {
      expect(AppConstants.everyAyahAudioBaseUrl, equals(s3Base));
      expect(
        AudioUrlHelper.buildAyahUrl(
          subfolder: 'Nabil_Rifa3i_48kbps',
          surahNumber: 27,
          ayahNumber: 93,
        ),
        equals('$s3Base/Nabil_Rifa3i_48kbps/027093.mp3'),
      );
      expect(
        AudioUrlHelper.buildAyahUrl(
          subfolder: 'translations/besim_korkut_ajet_po_ajet',
          surahNumber: 1,
          ayahNumber: 1,
        ),
        equals('$s3Base/translations/besim_korkut_ajet_po_ajet/001001.mp3'),
      );
    });

    test('ReciterCatalog has 46 complete reciters without Mustafa Ismail', () {
      expect(ReciterCatalog.allReciters.length, equals(46));
      expect(
        ReciterCatalog.allReciters.any(
          (r) => r.identifier == 'mustafa_ismail_48kbps',
        ),
        isFalse,
      );
      expect(
        ReciterCatalog.allReciters.any(
          (r) => r.identifier == 'nabil_rifa3i_48kbps',
        ),
        isTrue,
      );
    });

    test('TranslationCatalog has 14 Persian translations hosted on S3', () {
      expect(TranslationCatalog.allTranslations.length, equals(14));
      for (final t in TranslationCatalog.allTranslations) {
        expect(
          t.sourceUrl,
          equals('$s3Base/text_translations/${t.id}.json'),
        );
      }
    });

    test('TafsirCatalog has 3 tafsirs hosted on S3', () {
      expect(TafsirCatalog.allTafsirs.length, equals(3));
      for (final tafsir in TafsirCatalog.allTafsirs) {
        expect(tafsir.sourceUrl, startsWith('$s3Base/tafsirs/'));
        expect(tafsir.sourceUrl, endsWith('.tar.xz'));
      }
    });
  });

  group('TranslationRemoteDataSource S3 payload parsing', () {
    test('parses AlQuranCloud schema served from S3 URL', () async {
      final dio = Dio();
      dio.httpClientAdapter = _FakeHttpClientAdapter(
        (_) => ResponseBody.fromString(
          jsonEncode({
            'data': {
              'surahs': [
                {
                  'number': 1,
                  'ayahs': [
                    {'numberInSurah': 1, 'text': 'به نام خدا'},
                  ],
                },
              ],
            },
          }),
          200,
          headers: {
            Headers.contentTypeHeader: ['application/json; charset=utf-8'],
          },
        ),
      );

      final ds = TranslationRemoteDataSource(dio);
      final res = await ds.fetchTranslation(
        '$s3Base/text_translations/fa.makarem.json',
      );
      expect(res, equals({'1_1': 'به نام خدا'}));
    });

    test('parses FawazAhmed0 schema even when Content-Type is text/plain', () async {
      final dio = Dio();
      dio.httpClientAdapter = _FakeHttpClientAdapter(
        (_) => ResponseBody.fromString(
          jsonEncode({
            'quran': [
              {'chapter': 112, 'verse': 1, 'text': 'بگو او خدای یکتاست'},
            ],
          }),
          200,
          headers: {
            Headers.contentTypeHeader: ['text/plain; charset=utf-8'],
          },
        ),
      );

      final ds = TranslationRemoteDataSource(dio);
      final res = await ds.fetchTranslation(
        '$s3Base/text_translations/fa.ghomshei.json',
      );
      expect(res, equals({'112_1': 'بگو او خدای یکتاست'}));
    });

    test('throws FormatException for unsupported JSON schema', () async {
      final dio = Dio();
      dio.httpClientAdapter = _FakeHttpClientAdapter(
        (_) => ResponseBody.fromString(
          jsonEncode({'unexpected': true}),
          200,
          headers: {
            Headers.contentTypeHeader: ['application/json; charset=utf-8'],
          },
        ),
      );

      final ds = TranslationRemoteDataSource(dio);
      expect(
        () => ds.fetchTranslation('$s3Base/text_translations/bad.json'),
        throwsFormatException,
      );
    });
  });
}

