// lib/screens/player_screen.dart
// Player video pulito: no ads, no commenti, no distrazioni

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/channel.dart';

class PlayerScreen extends StatefulWidget {
  final Channel channel;
  const PlayerScreen({super.key, required this.channel});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Forza orientamento landscape durante la riproduzione
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    WakelockPlus.enable(); // Schermo sempre acceso durante il video
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      switch (widget.channel.type) {
        case ChannelType.youtube:
          await _initYouTubePlayer();
          break;
        case ChannelType.iptv:
        case ChannelType.raiplay:
        case ChannelType.mediaset:
          await _initStreamPlayer(widget.channel.sourceUrl);
          break;
      }
    } catch (e) {
      setState(() {
        _error = 'Impossibile caricare il canale.\nRiprova più tardi.\n\n$e';
        _isLoading = false;
      });
    }
  }

  // ── YouTube: estrae stream HD senza pubblicità ──────────────
  Future<void> _initYouTubePlayer() async {
    final yt = YoutubeExplode();
    try {
      // Estrae l'ultimo video del canale oppure usa l'URL come video singolo
      final url = widget.channel.sourceUrl;
      String videoId;

      if (url.contains('watch?v=')) {
        videoId = url.split('watch?v=')[1].split('&')[0];
      } else if (url.contains('youtu.be/')) {
        videoId = url.split('youtu.be/')[1];
      } else {
        // È un canale — prende il primo video dalla playlist
        final channel = await yt.channels.getByUrl(url);
        final uploads = yt.channels.getUploads(channel.id);
        final video = await uploads.first;
        videoId = video.id.value;
      }

      final manifest = await yt.videos.streamsClient.getManifest(videoId);
      // Prende lo stream con la risoluzione più alta
      final streamInfo = manifest.muxed.withHighestBitrate();
      final streamUrl = streamInfo.url.toString();

      await _initStreamPlayer(streamUrl);
    } finally {
      yt.close();
    }
  }

  // ── HLS/MP4 generico (IPTV, RaiPlay, Mediaset) ─────────────
  Future<void> _initStreamPlayer(String url) async {
    _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
    await _videoController!.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoController!,
      autoPlay: true,
      looping: false,
      // Nasconde tutto ciò che non serve ai bambini
      showOptions: false,
      showControlsOnInitialize: false,
      materialProgressColors: ChewieProgressColors(
        playedColor: Colors.pinkAccent,
        handleColor: Colors.pink,
        backgroundColor: Colors.white24,
        bufferedColor: Colors.white38,
      ),
      placeholder: Container(color: Colors.black),
      errorBuilder: (context, errorMessage) => Center(
        child: Text(errorMessage,
            style: const TextStyle(color: Colors.white)),
      ),
    );

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Player ──
          if (_isLoading)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.pinkAccent),
                  SizedBox(height: 16),
                  Text('Caricamento...',
                      style: TextStyle(color: Colors.white70)),
                ],
              ),
            )
          else if (_error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(_error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.redAccent)),
              ),
            )
          else
            Chewie(controller: _chewieController!),

          // ── Pulsante chiudi (sempre visibile) ──
          Positioned(
            top: 16,
            left: 16,
            child: SafeArea(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back,
                      color: Colors.white, size: 28),
                ),
              ),
            ),
          ),

          // ── Nome canale ──
          Positioned(
            top: 16,
            right: 16,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.channel.name,
                  style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Ripristina orientamento verticale
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    WakelockPlus.disable();
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }
}
