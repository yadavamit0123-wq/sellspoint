import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:eClassify/data/cubits/chat/chat_message_cubit.dart';
import 'package:eClassify/ui/screens/chat/widgets/message_composing_widgets/components/attachment_preview.dart';
import 'package:eClassify/ui/screens/chat/widgets/message_composing_widgets/message_audio_button.dart';
import 'package:eClassify/ui/screens/chat/widgets/message_composing_widgets/message_audio_input.dart';
import 'package:eClassify/ui/screens/chat/widgets/message_composing_widgets/message_input_field.dart';
import 'package:eClassify/ui/screens/chat/widgets/message_composing_widgets/message_send_button.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/utils/file_picker_utility.dart';
import 'package:eClassify/utils/log.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';

class MessageComposer extends StatefulWidget {
  const MessageComposer({super.key});

  @override
  State<MessageComposer> createState() => _MessageComposerState();
}

class _MessageComposerState extends State<MessageComposer> {
  final TextEditingController _controller = TextEditingController();

  // Recording states
  final ValueNotifier<bool> _isRecording = ValueNotifier(false);
  final ValueNotifier<bool> _isLocked = ValueNotifier(false);
  final ValueNotifier<Offset> _gestureOffset = ValueNotifier(Offset.zero);
  final ValueNotifier<Duration> _recordingDuration = ValueNotifier(
    Duration.zero,
  );

  // Attachment states
  final ValueNotifier<File?> _stagedFile = ValueNotifier(null);

  late final AudioRecorder _recorder = AudioRecorder();
  Timer? _timer;

  @override
  void dispose() {
    _controller.dispose();
    _isRecording.dispose();
    _isLocked.dispose();
    _gestureOffset.dispose();
    _recordingDuration.dispose();
    _stagedFile.dispose();
    _recorder.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _recordingDuration.value = Duration.zero;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _recordingDuration.value += const Duration(seconds: 1);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<bool> _handleRecordingStart() async {
    try {
      if (await _recorder.hasPermission(request: false)) {
        final tempDir = await getTemporaryDirectory();
        final path = '${tempDir.path}/${const Uuid().v4()}.m4a';

        await _recorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: path,
        );

        _isRecording.value = true;
        _isLocked.value = false;
        _gestureOffset.value = Offset.zero;
        _startTimer();
        return true;
      }
    } catch (e, st) {
      log('${e.toString()} $st');
      Log.error('Failed to start recording', e, st);
    }
    _recorder.hasPermission(request: true);
    return false;
  }

  void _handleRecordingEnd(bool cancelled, bool locked) async {
    if (locked) {
      _isLocked.value = true;
      // Timer continues running
      return;
    }

    final path = await _recorder.stop();

    _isRecording.value = false;
    _isLocked.value = false;
    _stopTimer();

    if (path != null) {
      if (cancelled) {
        final file = File(path);
        if (file.existsSync()) file.deleteSync();
      } else {
        if (mounted) {
          context.read<ChatMessageCubit>().sendMessage(audio: File(path));
        }
      }
    }
  }

  void _handleDiscard() async {
    final path = await _recorder.stop();
    _isRecording.value = false;
    _isLocked.value = false;
    _stopTimer();

    if (path != null) {
      final file = File(path);
      if (file.existsSync()) file.deleteSync();
    }
    debugPrint("Recording Discarded");
  }

  void _pickAttachment() async {
    final files = await FilePickerUtility.pick(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['jpeg', 'jpg', 'png'],
    );

    if (files != null && files.isNotEmpty) {
      _stagedFile.value = files.first;
    }
  }

  void _handleSend() {
    final isRecording = _isRecording.value;
    final isLocked = _isLocked.value;

    if (isRecording && isLocked) {
      _handleRecordingEnd(false, false);
      return;
    }

    final text = _controller.text.trim();
    final file = _stagedFile.value;

    if (text.isNotEmpty || file != null) {
      context.read<ChatMessageCubit>().sendMessage(
        text: text.isNotEmpty ? text : null,
        attachment: file,
      );
      _controller.clear();
      _stagedFile.value = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_isRecording, _isLocked, _stagedFile]),
      builder: (context, _) {
        final isRecording = _isRecording.value;
        final isLocked = _isLocked.value;
        final stagedFile = _stagedFile.value;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (stagedFile != null && !isRecording)
              AttachmentPreview(
                file: stagedFile,
                onRemove: () => _stagedFile.value = null,
              ),
            Row(
              spacing: 10,
              children: [
                Expanded(
                  child: _MessageInputBody(
                    controller: _controller,
                    isRecording: isRecording,
                    isLocked: isLocked,
                    recordingDuration: _recordingDuration,
                    gestureOffset: _gestureOffset,
                    onDiscard: _handleDiscard,
                    onAttach: _pickAttachment,
                    onSubmitted: (_) => _handleSend(),
                  ),
                ),
                _buildActionButtons(isRecording, isLocked),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButtons(bool isRecording, bool isLocked) {
    return ListenableBuilder(
      listenable: Listenable.merge([_controller, _stagedFile]),
      builder: (context, child) {
        final hasContent =
            _controller.text.trim().isNotEmpty ||
            _stagedFile.value != null ||
            (isRecording && isLocked);

        if (hasContent) {
          return MessageSendButton(onSend: _handleSend);
        }

        return MessageAudioButton(
          onRecordStart: _handleRecordingStart,
          onRecordEnd: _handleRecordingEnd,
          onOffsetUpdate: (offset) {
            _gestureOffset.value = offset;
          },
        );
      },
    );
  }
}

class _MessageInputBody extends StatelessWidget {
  const _MessageInputBody({
    required this.gestureOffset,
    required this.onDiscard,
    required this.onAttach,
    required this.onSubmitted,
    required this.controller,
    required this.isRecording,
    required this.isLocked,
    required this.recordingDuration,
  });

  final TextEditingController controller;
  final bool isRecording;
  final bool isLocked;
  final ValueNotifier<Duration> recordingDuration;
  final ValueNotifier<Offset> gestureOffset;
  final VoidCallback onDiscard;
  final VoidCallback onAttach;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 50),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colorScheme.backgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: context.colorScheme.outline),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Builder(
            builder: (context) {
              if (isRecording) {
                return ListenableBuilder(
                  listenable: Listenable.merge([
                    recordingDuration,
                    gestureOffset,
                  ]),
                  builder: (context, _) {
                    return MessageAudioInput(
                      duration: recordingDuration.value,
                      offset: gestureOffset.value,
                      isLocked: isLocked,
                      onDiscard: onDiscard,
                    );
                  },
                );
              }
              return MessageInputField(
                controller: controller,
                onAttach: onAttach,
                onSubmitted: onSubmitted,
              );
            },
          ),
        ),
      ),
    );
  }
}
