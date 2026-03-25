// lib/models/channel.dart
// Rappresenta un canale (YouTube, RaiPlay, Mediaset, IPTV)

enum ChannelType { youtube, raiplay, mediaset, iptv }

class Channel {
  final String id;
  final String name;
  final String logoAsset;       // Path icona locale: "assets/channels/rai1.png"
  final ChannelType type;
  final String sourceUrl;       // URL canale YouTube, playlist m3u8, ecc.

  // Profili che possono vedere questo canale
  final bool availableForBaby;
  final bool availableForKid;

  const Channel({
    required this.id,
    required this.name,
    required this.logoAsset,
    required this.type,
    required this.sourceUrl,
    required this.availableForBaby,
    required this.availableForKid,
  });
}

// ============================================================
// CANALI PREDEFINITI — Il genitore può modificarli dal pannello
// ============================================================
// NOTA: sostituisci i sourceUrl con i link reali che preferisci.
// Per i canali YouTube usa l'URL del canale (es. youtube.com/c/NomeCanale)
// Per RaiPlay usa l'URL della sezione bambini di RaiPlay
// Per IPTV usa l'URL del file .m3u8

final List<Channel> defaultChannels = [

  // --- Canali per la Bimba Piccola (baby + kid) ---
  Channel(
    id: 'rai_yoyo',
    name: 'Rai Yoyo',
    logoAsset: 'assets/channels/rai_yoyo.png',
    type: ChannelType.raiplay,
    sourceUrl: 'https://www.raiplay.it/dirette/raiyoyo',
    availableForBaby: true,
    availableForKid: true,
  ),
  Channel(
    id: 'rai_gulp',
    name: 'Rai Gulp',
    logoAsset: 'assets/channels/rai_gulp.png',
    type: ChannelType.raiplay,
    sourceUrl: 'https://www.raiplay.it/dirette/raigulp',
    availableForBaby: false, // Più adatto ai bambini grandi
    availableForKid: true,
  ),
  Channel(
    id: 'cartoonito',
    name: 'Cartoonito',
    logoAsset: 'assets/channels/cartoonito.png',
    type: ChannelType.iptv,
    // Sostituisci con il link m3u8 del tuo provider IPTV
    sourceUrl: 'https://example.com/cartoonito.m3u8',
    availableForBaby: true,
    availableForKid: true,
  ),
  Channel(
    id: 'boomerang',
    name: 'Boomerang',
    logoAsset: 'assets/channels/boomerang.png',
    type: ChannelType.iptv,
    sourceUrl: 'https://example.com/boomerang.m3u8',
    availableForBaby: false,
    availableForKid: true,
  ),

  // --- Canale YouTube (senza pubblicità grazie a youtube_explode_dart) ---
  Channel(
    id: 'super_youtube',
    name: 'Super! (YouTube)',
    logoAsset: 'assets/channels/super.png',
    type: ChannelType.youtube,
    // ID canale YouTube — il genitore può cambiarlo dal pannello
    sourceUrl: 'https://www.youtube.com/@SuperCanale',
    availableForBaby: true,
    availableForKid: true,
  ),
];
