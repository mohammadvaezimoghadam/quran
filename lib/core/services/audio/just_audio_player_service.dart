import 'dart:async';

import 'package:just_audio/just_audio.dart';

import 'audio_error_parser.dart';
import 'audio_player_state.dart';
import 'i_audio_player_service.dart';

class JustAudioPlayerService implements IAudioPlayerService {
  final AudioPlayer _audioPlayer;
  final StreamController<AudioPlayerState> _stateController =
      StreamController<AudioPlayerState>.broadcast();
  AudioPlayerState _state = AudioPlayerState.initial();

  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;

  bool _isInternalTransition = false;

  /// Generation counter to cancel stale retry loops when a new play() is invoked.
  int _playGeneration = 0;

  /// Maximum time to wait for a network audio source to load before timing out.
  static const Duration _loadTimeout = Duration(seconds: 12);

  /// Maximum number of retry attempts for transient network failures.
  static const int _maxRetries = 2;

  /// Delay between retry attempts (doubles each retry for exponential backoff).
  static const Duration _retryBaseDelay = Duration(milliseconds: 800);

  JustAudioPlayerService({AudioPlayer? audioPlayer})
      : _audioPlayer = audioPlayer ?? AudioPlayer() {
    _initListeners();
  }

  void _initListeners() {
    _playerStateSubscription = _audioPlayer.playerStateStream.listen(
      (playerState) {
        final processingState = playerState.processingState;
        final isPlaying = playerState.playing;

        // Skip emitting stopped state during internal track transitions
        if (processingState == ProcessingState.idle && _isInternalTransition) {
          return;
        }

        AudioStatus status;
        if (processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering) {
          status = AudioStatus.loading;
        } else if (processingState == ProcessingState.completed) {
          status = AudioStatus.completed;
        } else if (processingState == ProcessingState.idle) {
          status = AudioStatus.stopped;
        } else if (isPlaying) {
          status = AudioStatus.playing;
        } else {
          status = AudioStatus.paused;
        }

        _updateState(_state.copyWith(status: status));
      },
      onError: (Object e, StackTrace s) {
        _updateState(
          _state.copyWith(
            status: AudioStatus.error,
            errorMessage: AudioErrorParser.parseError(e),
          ),
        );
      },
    );

    _positionSubscription = _audioPlayer.positionStream.listen((position) {
      _updateState(_state.copyWith(position: position));
    });

    _durationSubscription = _audioPlayer.durationStream.listen((duration) {
      _updateState(_state.copyWith(duration: duration ?? Duration.zero));
    });
  }

  void _updateState(AudioPlayerState newState) {
    _state = newState;
    if (!_stateController.isClosed) {
      _stateController.add(_state);
    }
  }

  @override
  AudioPlayerState get currentState => _state;

  @override
  Stream<AudioPlayerState> get stateStream => _stateController.stream;

  @override
  Future<void> play(String url) async {
    // Increment generation so any in-flight retry loop from a previous play() exits silently.
    final generation = ++_playGeneration;

    _updateState(
      _state.copyWith(
        status: AudioStatus.loading,
        currentUrl: url,
        errorMessage: null,
      ),
    );

    _isInternalTransition = true;
    try {
      // Pause (NOT stop) current playback to keep ExoPlayer instance alive.
      // stop() causes ExoPlayer to Release → Android kills foreground notification.
      // pause() keeps the native player alive so setUrl() just swaps the source.
      if (_audioPlayer.playing) {
        await _audioPlayer.pause();
      }

      // Brief delay for native MediaCodec to settle before loading new source
      await Future.delayed(const Duration(milliseconds: 20));

      // Bail out if a newer play() was called during stop/delay
      if (_playGeneration != generation) return;

      // Retry loop for transient network failures
      for (int attempt = 0; attempt <= _maxRetries; attempt++) {
        // Check before each attempt — a newer play() supersedes this one
        if (_playGeneration != generation) return;

        try {
          await _audioPlayer.setUrl(url).timeout(
            _loadTimeout,
            onTimeout: () {
              throw TimeoutException(
                'سرور صوت پاسخ نمی‌دهد. لطفاً اتصال اینترنت خود را بررسی کنید.',
                _loadTimeout,
              );
            },
          );

          // Bail out if superseded while waiting for setUrl
          if (_playGeneration != generation) return;

          // Reset position to start of new track (pause keeps old position)
          await _audioPlayer.seek(Duration.zero);

          // Successful load — start playback
          await _audioPlayer.play();
          return; // Exit retry loop on success
        } catch (e) {
          if (_playGeneration != generation) return;

          final errorStr = e.toString().toLowerCase();
          if (errorStr.contains('interrupted') || errorStr.contains('abort')) {
            return;
          }

          final isLastAttempt = attempt == _maxRetries;
          final isRetryable = _isRetryableError(e);

          if (isLastAttempt || !isRetryable) {
            if (_playGeneration == generation) {
              _updateState(
                _state.copyWith(
                  status: AudioStatus.error,
                  errorMessage: AudioErrorParser.parseError(e),
                ),
              );
            }
            return;
          }

          await Future.delayed(Duration(seconds: 1 << attempt));
        }
      }
    } finally {
      if (_playGeneration == generation) {
        _isInternalTransition = false;
      }
    }
  }

  /// Determines if an error is transient and worth retrying.
  bool _isRetryableError(dynamic error) {
    final msg = error.toString().toLowerCase();
    // Retry on network issues and timeouts; do NOT retry on 404 or format errors.
    if (msg.contains('404') || msg.contains('not found')) return false;
    if (msg.contains('format') || msg.contains('codec')) return false;
    return msg.contains('socket') ||
        msg.contains('connection') ||
        msg.contains('timeout') ||
        msg.contains('timed out') ||
        msg.contains('handshake') ||
        msg.contains('network') ||
        msg.contains('failed to connect') ||
        msg.contains('failed host lookup') ||
        msg.contains('dns') ||
        msg.contains('reset') ||
        error is TimeoutException;
  }

  @override
  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  @override
  Future<void> resume() async {
    await _audioPlayer.play();
  }

  @override
  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  @override
  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  @override
  Future<void> setSpeed(double speed) async {
    await _audioPlayer.setSpeed(speed);
    _updateState(_state.copyWith(speed: speed));
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _stateController.close();
    _audioPlayer.dispose();
  }
}
