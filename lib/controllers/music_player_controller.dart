import 'package:flutter/material.dart';

class MusicPlayerController with ChangeNotifier {
  bool _isFavorite = false;
  bool get isFavorite => _isFavorite;

  String time(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return [
      if (duration.inHours > 0) hours,
      minutes,
      seconds,
    ].join(":");
  }

  void toggleFavorite() {
    _isFavorite = !_isFavorite;
    notifyListeners();
  }
}
