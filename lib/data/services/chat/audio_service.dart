import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

enum AudioStatus { playing, paused, stopped }

class ChatAudioState {
  final String? url;
  final AudioStatus status;
  final Duration position;
  final Duration duration;

  ChatAudioState({
    this.url,
    this.status = AudioStatus.stopped,
    this.position = Duration.zero,
    this.duration = Duration.zero,
  });

  factory ChatAudioState.idle() => ChatAudioState();

  ChatAudioState copyWith({
    String? url,
    AudioStatus? status,
    Duration? position,
    Duration? duration,
  }) {
    return ChatAudioState(
      url: url ?? this.url,
      status: status ?? this.status,
      position: position ?? this.position,
      duration: duration ?? this.duration,
    );
  }
}

class AudioService {
  final AudioPlayer _player = AudioPlayer();
  final ValueNotifier<ChatAudioState> stateNotifier =
      ValueNotifier(ChatAudioState.idle());

  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _playerStateSubscription;

  AudioService() {
    _initListeners();
  }

  void _initListeners() {
    _positionSubscription = _player.onPositionChanged.listen((position) {
      stateNotifier.value = stateNotifier.value.copyWith(position: position);
    });

    _durationSubscription = _player.onDurationChanged.listen((duration) {
      stateNotifier.value = stateNotifier.value.copyWith(duration: duration);
    });

    _playerStateSubscription = _player.onPlayerStateChanged.listen((state) {
      AudioStatus status = AudioStatus.stopped;
      if (state == PlayerState.playing) status = AudioStatus.playing;
      if (state == PlayerState.paused) status = AudioStatus.paused;
      if (state == PlayerState.completed) {
        status = AudioStatus.stopped;
        _player.stop(); // Ensure it resets
        stateNotifier.value = stateNotifier.value.copyWith(
          status: status,
          position: Duration.zero,
        );
      } else {
        stateNotifier.value = stateNotifier.value.copyWith(status: status);
      }
    });
  }

  Future<void> play(String url) async {
    if (stateNotifier.value.url == url) {
      if (stateNotifier.value.status == AudioStatus.playing) {
        await _player.pause();
      } else if (stateNotifier.value.status == AudioStatus.paused) {
        await _player.resume();
      } else {
        await _player.play(UrlSource(url));
      }
    } else {
      await _player.stop();
      stateNotifier.value = ChatAudioState(url: url, status: AudioStatus.playing);
      await _player.play(UrlSource(url));
    }
  }

  Future<void> stop() async {
    await _player.stop();
    stateNotifier.value = ChatAudioState.idle();
  }

  void dispose() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _player.dispose();
    stateNotifier.dispose();
  }
}
