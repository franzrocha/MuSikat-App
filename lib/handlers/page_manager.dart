import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:musikat_app/service_locators.dart';

final audioHandler = locator<AudioHandler>();

class PageManager {
  final isFirstSongNotifier = ValueNotifier<bool>(true);
  // final playButtonNotifier = PlayButtonNotifier();

  final currentSongTitleNotifier = ValueNotifier<String>('');
  final isLastSongNotifier = ValueNotifier<bool>(true);

  // void init() {
  //   listenToPlaybackState();
  // }

  void play() {}

  void pause() {}

  void seek(Duration position) => audioHandler.seek(position);

  void previous() {}

  void next() {}

  void repeat() {}

  void add() {}

  void remove() {}

//   void listenToPlaybackState() {
//     audioHandler.playbackState.listen((playbackState) {
//       final isPlaying = playbackState.playing;
//       final processingState = playbackState.processingState;
//       if (processingState == AudioProcessingState.loading ||
//           processingState == AudioProcessingState.buffering) {
//         playButtonNotifier.value = ButtonState.loading;
//       } else if (!isPlaying) {
//         playButtonNotifier.value = ButtonState.paused;
//       } else if (processingState != AudioProcessingState.completed) {
//         playButtonNotifier.value = ButtonState.playing;
//       } else {
//         audioHandler.seek(Duration.zero);
//         audioHandler.pause();
//       }

//       // Update the playback position UI
//     });
//   }
//   void listenToCurrentPosition() {
//   AudioService.position.listen((position) {
//     final oldState = progressNotifier.value;
//     progressNotifier.value = ProgressBarState(
//       current: position,
//       buffered: oldState.buffered,
//       total: oldState.total,
//     );
//   });
// }
// void listenToBufferedPosition() {
//   audioHandler.playbackState.listen((playbackState) {
//     final oldState = progressNotifier.value;
//     progressNotifier.value = ProgressBarState(
//       current: oldState.current,
//       buffered: playbackState.bufferedPosition,
//       total: oldState.total,
//     );
//   });
// }
}
