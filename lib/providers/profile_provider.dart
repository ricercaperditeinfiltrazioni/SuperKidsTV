// lib/providers/profile_provider.dart
// Gestisce il profilo attivo e la verifica del PIN genitore

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/profile.dart';

class ProfileProvider extends ChangeNotifier {
  Profile? _activeProfile;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _pinKey = 'parent_pin';
  static const String _defaultPin = '1234'; // PIN iniziale — cambialo subito!

  Profile? get activeProfile => _activeProfile;
  bool get isParent => _activeProfile?.type == ProfileType.parent;
  bool get isBaby => _activeProfile?.type == ProfileType.baby;
  bool get isKid => _activeProfile?.type == ProfileType.kid;

  // Imposta il profilo attivo (baby o kid — nessun PIN richiesto)
  void setProfile(Profile profile) {
    if (profile.type == ProfileType.parent) return; // Usa verifyParentPin
    _activeProfile = profile;
    notifyListeners();
  }

  // Verifica PIN e attiva profilo genitore
  Future<bool> verifyParentPin(String enteredPin) async {
    final savedPin = await _storage.read(key: _pinKey) ?? _defaultPin;
    if (enteredPin == savedPin) {
      _activeProfile = Profile.parent;
      notifyListeners();
      return true;
    }
    return false;
  }

  // Cambia PIN (solo dal profilo genitore)
  Future<bool> changePin(String oldPin, String newPin) async {
    final isValid = await verifyParentPin(oldPin);
    if (isValid && newPin.length >= 4) {
      await _storage.write(key: _pinKey, value: newPin);
      return true;
    }
    return false;
  }

  // Esci dal profilo (torna alla schermata selezione)
  void logout() {
    _activeProfile = null;
    notifyListeners();
  }

  // --- Permessi per il profilo attivo ---

  bool get canSearch => _activeProfile?.canSearch ?? false;

  bool get canSeeShorts => isParent; // Solo il genitore vede tutto

  int get minDuration => _activeProfile?.minVideoDurationSeconds ?? 0;

  bool isVideoAllowed(int durationSeconds, bool isVertical) {
    if (isParent) return true;
    if (isVertical && !isParent) return false; // Niente Shorts/verticali
    if (durationSeconds < minDuration) return false;
    return true;
  }
}
