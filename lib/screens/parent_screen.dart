// lib/screens/parent_screen.dart
// Pannello controllo genitoriale: timer, PIN, gestione canali

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/channel_provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/sleep_timer_widget.dart';

class ParentScreen extends StatelessWidget {
  const ParentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '🔑 Controllo Genitoriale',
          style: GoogleFonts.nunito(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Timer di spegnimento ──
          _SectionCard(
            title: '⏱️ Timer Spegnimento',
            child: SleepTimerWidget(),
          ),
          const SizedBox(height: 16),

          // ── Cambia PIN ──
          _SectionCard(
            title: '🔐 Cambia PIN',
            child: _ChangePinSection(),
          ),
          const SizedBox(height: 16),

          // ── Info canali ──
          _SectionCard(
            title: '📺 Canali configurati',
            child: _ChannelListSection(),
          ),
          const SizedBox(height: 16),

          // ── Info ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Text(
              '💡 Per aggiungere o modificare canali, edita il file '
              'lib/models/channel.dart su GitHub e carica la nuova versione.',
              style: GoogleFonts.nunito(color: Colors.white70, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _ChangePinSection extends StatefulWidget {
  @override
  State<_ChangePinSection> createState() => _ChangePinSectionState();
}

class _ChangePinSectionState extends State<_ChangePinSection> {
  final _oldPin = TextEditingController();
  final _newPin = TextEditingController();
  String? _message;
  bool _success = false;

  Future<void> _changePin() async {
    final ok = await context
        .read<ProfileProvider>()
        .changePin(_oldPin.text, _newPin.text);
    setState(() {
      _success = ok;
      _message = ok
          ? '✅ PIN cambiato con successo!'
          : '❌ PIN vecchio errato o nuovo PIN troppo corto';
    });
    if (ok) {
      _oldPin.clear();
      _newPin.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PinField(controller: _oldPin, label: 'PIN attuale'),
        const SizedBox(height: 12),
        _PinField(controller: _newPin, label: 'Nuovo PIN (min 4 cifre)'),
        const SizedBox(height: 16),
        if (_message != null)
          Text(_message!,
              style: GoogleFonts.nunito(
                  color: _success ? Colors.greenAccent : Colors.redAccent)),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: _changePin,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.withOpacity(0.3),
          ),
          child: Text('Cambia PIN',
              style: GoogleFonts.nunito(color: Colors.white)),
        ),
      ],
    );
  }
}

class _PinField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const _PinField({required this.controller, required this.label});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: true,
      keyboardType: TextInputType.number,
      maxLength: 8,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60),
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        counterStyle: const TextStyle(color: Colors.white38),
      ),
    );
  }
}

class _ChannelListSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final channels = context.watch<ChannelProvider>().allChannels;
    return Column(
      children: channels
          .map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                          child: Text(
                        c.type == ChannelType.youtube
                            ? '▶'
                            : c.type == ChannelType.raiplay
                                ? 'R'
                                : '📡',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 18),
                      )),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.name,
                              style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                          Text(
                            '${c.availableForBaby ? "🌸 " : ""}${c.availableForKid ? "⭐" : ""}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

// Import mancante — aggiungiamo qui per comodità
import '../models/channel.dart';
