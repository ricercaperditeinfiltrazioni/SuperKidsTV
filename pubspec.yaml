// lib/screens/player_screen.dart
// Player video custom — senza chewie, controlli puliti per bambini
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt_lib;
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
  VideoPlayerController? _controller;
  bool _isLoading = true;
  bool _showControls = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    WakelockPlus.enable();
    _initPlayer();
    // Nascondi i controlli dopo 3 secondi
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showControls = false);
    });
  }

  Future<void> _initPlayer() async {
    try {
      switch (widget.channel.type) {
        case ChannelType.youtube:
          await _initYouTube();
          break;
        default:
          await _initStream(widget.channel.sourceUrl);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Canale non disponibile.\n\n$e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _initYouTube() async {
    final yt = yt_lib.YoutubeExplode();
    try {
      final url = widget.channel.sourceUrl;
      String videoId;
      if (url.contains('watch?v=')) {
        videoId = url.split('watch?v=')[1].split('&')[0];
      } else if (url.contains('youtu.be/')) {
        videoId = url.split('youtu.be/')[1];
      } else {
        final channelId = yt_lib.ChannelId.fromString(url);
        final uploads = yt.channels.getUploads(channelId);
        final video = await uploads.first;
        videoId = video.id.value;
      }
      final manifest = await yt.videos.streamsClient.getManifest(videoId);
      final stream = manifest.muxed.withHighestBitrate();
      await _initStream(stream.url.toString());
    } finally {
      yt.close();
    }
  }

  Future<void> _initStream(String url) async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(url));
    await _controller!.initialize();
    _controller!.addListener(() { if (mounted) setState(() {}); });
    await _controller!.play();
    if (mounted) setState(() => _isLoading = false);
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _showControls = false);
      });
    }
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            // ── Video ──
            if (_isLoading)
              const Center(child: CircularProgressIndicator(color: Colors.pinkAccent))
            else if (_error != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(_error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 16)),
                ),
              )
            else
              Center(
                child: AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: VideoPlayer(_controller!),
                ),
              ),

            // ── Controlli sovrapposti ──
            if (_showControls && !_isLoading && _error == null) ...[
              // Sfondo scuro semi-trasparente
              Container(color: Colors.black38),

              // Pulsante indietro
              Positioned(
                top: 16, left: 16,
                child: SafeArea(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    ),
                  ),
                ),
              ),

              // Nome canale
              Positioned(
                top: 16, right: 16,
                child: SafeArea(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(widget.channel.name,
                        style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16)),
                  ),
                ),
              ),

              // Play/Pause centrale
              Center(
                child: GestureDetector(
                  onTap: () {
                    if (_controller!.value.isPlaying) {
                      _controller!.pause();
                    } else {
                      _controller!.play();
                    }
                    setState(() {});
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _controller!.value.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 56,
                    ),
                  ),
                ),
              ),

              // Barra progresso in basso
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: SafeArea(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    color: Colors.black54,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        VideoProgressIndicator(
                          _controller!,
                          allowScrubbing: true,
                          colors: const VideoProgressColors(
                            playedColor: Colors.pinkAccent,
                            bufferedColor: Colors.white38,
                            backgroundColor: Colors.white12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              _formatDuration(_controller!.value.position),
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            const Spacer(),
                            Text(
                              _formatDuration(_controller!.value.duration),
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],

            // Buffer indicator
            if (!_isLoading && _error == null &&
                _controller!.value.isBuffering)
              const Center(
                child: CircularProgressIndicator(color: Colors.white54),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    WakelockPlus.disable();
    _controller?.dispose();
    super.dispose();
  }
}
