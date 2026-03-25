// lib/widgets/channel_card.dart
// Carta canale con icona grande (baby mode) o normale

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/channel.dart';

class ChannelCard extends StatelessWidget {
  final Channel channel;
  final bool isBabyMode;
  final VoidCallback onTap;

  const ChannelCard({
    super.key,
    required this.channel,
    required this.isBabyMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(isBabyMode ? 24 : 16),
          border: Border.all(
            color: Colors.white.withOpacity(0.15),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo canale
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildLogo(),
              ),
            ),
            // Nome canale
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10, left: 8, right: 8),
                child: Text(
                  channel.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                    fontSize: isBabyMode ? 16 : 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    // Prova a usare il logo locale (assets/channels/)
    // Se non trovato, usa le emoji dei canali come fallback
    final emojis = {
      ChannelType.youtube: '▶️',
      ChannelType.raiplay: '📺',
      ChannelType.mediaset: '🎬',
      ChannelType.iptv: '📡',
    };

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          emojis[channel.type] ?? '📺',
          style: TextStyle(fontSize: isBabyMode ? 42 : 32),
        ),
      ),
    );
  }
}
