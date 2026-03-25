// lib/models/profile.dart
// Definisce i 3 profili: Bimba piccola, Bimba grande, Genitore

enum ProfileType { baby, kid, parent }

class Profile {
  final ProfileType type;
  final String name;
  final String emoji;
  final String backgroundColor; // colore esadecimale es. "FF6B9D"

  // Permessi specifici per profilo
  final bool canSearch;
  final bool showOnlyHorizontalVideos;
  final int minVideoDurationSeconds; // Filtro durata minima
  final bool requiresPin;

  const Profile({
    required this.type,
    required this.name,
    required this.emoji,
    required this.backgroundColor,
    required this.canSearch,
    required this.showOnlyHorizontalVideos,
    required this.minVideoDurationSeconds,
    required this.requiresPin,
  });

  // I 3 profili predefiniti dell'app
  static const baby = Profile(
    type: ProfileType.baby,
    name: 'Bimba Piccola',
    emoji: '🌸',
    backgroundColor: 'FFB3D9', // Rosa tenero
    canSearch: false,
    showOnlyHorizontalVideos: true,
    minVideoDurationSeconds: 0,
    requiresPin: false,
  );

  static const kid = Profile(
    type: ProfileType.kid,
    name: 'Bimba Grande',
    emoji: '⭐',
    backgroundColor: 'B3E5FC', // Azzurro
    canSearch: true,
    showOnlyHorizontalVideos: true,
    minVideoDurationSeconds: 60, // Solo video > 1 minuto (no Shorts)
    requiresPin: false,
  );

  static const parent = Profile(
    type: ProfileType.parent,
    name: 'Genitore',
    emoji: '🔑',
    backgroundColor: '4CAF50', // Verde
    canSearch: true,
    showOnlyHorizontalVideos: false,
    minVideoDurationSeconds: 0,
    requiresPin: true,
  );

  static List<Profile> get all => [baby, kid, parent];
}
