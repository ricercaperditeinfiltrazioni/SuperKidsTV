// lib/widgets/sleep_timer_widget.dart
// Controllo timer: il genitore sceglie dopo quanti minuti si blocca l'app

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/channel_provider.dart';

class SleepTimerWidget extends StatelessWidget {
  // Opzioni rapide in minuti
  static const List<int> _presets = [0, 15, 30, 45, 60, 90];

  const SleepTimerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChannelProvider>();
    final active = provider.sleepTimerMinutes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          active == 0
              ? 'Timer disattivato'
              : 'Tempo rimanente: ${provider.timerDisplay}',
          style: GoogleFonts.nunito(
            color: active == 0 ? Colors.white60 : Colors.orangeAccent,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _presets.map((minutes) {
            final isSelected = active == minutes;
            return GestureDetector(
              onTap: () => context
                  .read<ChannelProvider>()
                  .setSleepTimer(minutes),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.orange.withOpacity(0.3)
                      : Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? Colors.orange
                        : Colors.white.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  minutes == 0 ? 'OFF' : '${minutes}min',
                  style: GoogleFonts.nunito(
                    color: isSelected ? Colors.orange : Colors.white70,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
