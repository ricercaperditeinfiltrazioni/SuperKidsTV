// lib/providers/channel_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/channel.dart';
import '../models/profile.dart';

class ChannelProvider extends ChangeNotifier {
  List<Channel> _allChannels = List.from(defaultChannels);

  Timer? _sleepTimer;
  int _sleepTimerMinutes = 0;
  int _remainingSeconds = 0;
  bool _timerExpired = false;

  List<Channel> get allChannels => _allChannels;
  int get sleepTimerMinutes => _sleepTimerMinutes;
  int get remainingSeconds => _remainingSeconds;
  bool get timerExpired => _timerExpired;

  List<Channel> channelsForProfile(ProfileType type) {
    switch (type) {
      case ProfileType.baby:
        return _allChannels.where((c) => c.availableForBaby).toList();
      case ProfileType.kid:
        return _allChannels.where((c) => c.availableForKid).toList();
      case ProfileType.parent:
        return _allChannels;
    }
  }

  void addChannel(Channel channel) {
    _allChannels.add(channel);
    _saveChannels();
    notifyListeners();
  }

  void removeChannel(String channelId) {
    _allChannels.removeWhere((c) => c.id == channelId);
    _saveChannels();
    notifyListeners();
  }

  void setSleepTimer(int minutes) {
    _sleepTimer?.cancel();
    _timerExpired = false;
    _sleepTimerMinutes = minutes;

    if (minutes == 0) {
      _remainingSeconds = 0;
      notifyListeners();
      return;
    }

    _remainingSeconds = minutes * 60;
    notifyListeners();

    _sleepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 0) {
        _timerExpired = true;
        timer.cancel();
        notifyListeners();
      } else {
        _remainingSeconds--;
        notifyListeners();
      }
    });
  }

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimerMinutes = 0;
    _remainingSeconds = 0;
    _timerExpired = false;
    notifyListeners();
  }

  void resetTimerExpired() {
    _timerExpired = false;
    notifyListeners();
  }

  String get timerDisplay {
    if (_remainingSeconds <= 0) return '';
    final m = _remainingSeconds ~/ 60;
    final s = _remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _saveChannels() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('channels_count', _allChannels.length);
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    super.dispose();
  }
}
