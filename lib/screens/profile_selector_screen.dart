// lib/screens/profile_selector_screen.dart
// Prima schermata: scegli il profilo (Baby, Kid, Genitore)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../models/profile.dart';
import '../providers/profile_provider.dart';
import 'home_screen.dart';

class ProfileSelectorScreen extends StatelessWidget {
  const ProfileSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Titolo app
              FadeInDown(
                child: Text(
                  '📺 SuperKids TV',
                  style: GoogleFonts.nunito(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FadeInDown(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  'Chi guarda adesso?',
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    color: Colors.white70,
                  ),
                ),
              ),
              const SizedBox(height: 60),

              // Carte profilo
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Bimba Piccola
                      FadeInLeft(
                        delay: const Duration(milliseconds: 300),
                        child: _ProfileCard(
                          profile: Profile.baby,
                          onTap: () => _selectProfile(context, Profile.baby),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Bimba Grande
                      FadeInRight(
                        delay: const Duration(milliseconds: 450),
                        child: _ProfileCard(
                          profile: Profile.kid,
                          onTap: () => _selectProfile(context, Profile.kid),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Genitore (con PIN)
                      FadeInLeft(
                        delay: const Duration(milliseconds: 600),
                        child: _ProfileCard(
                          profile: Profile.parent,
                          onTap: () => _showPinDialog(context),
                          subtitle: 'Inserisci PIN per accedere',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _selectProfile(BuildContext context, Profile profile) {
    context.read<ProfileProvider>().setProfile(profile);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  void _showPinDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _PinDialog(
        onSuccess: () {
          Navigator.of(ctx).pop();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        },
      ),
    );
  }
}

// ─── Carta Profilo ────────────────────────────────────────────
class _ProfileCard extends StatelessWidget {
  final Profile profile;
  final VoidCallback onTap;
  final String? subtitle;

  const _ProfileCard({
    required this.profile,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse('FF${profile.backgroundColor}', radix: 16));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.5), width: 2),
        ),
        child: Row(
          children: [
            // Emoji grande
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: color.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  profile.emoji,
                  style: const TextStyle(fontSize: 36),
                ),
              ),
            ),
            const SizedBox(width: 20),

            // Nome e sottotitolo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name,
                    style: GoogleFonts.nunito(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            Icon(Icons.arrow_forward_ios_rounded,
                color: color, size: 24),
          ],
        ),
      ),
    );
  }
}

// ─── Dialog PIN Genitore ─────────────────────────────────────
class _PinDialog extends StatefulWidget {
  final VoidCallback onSuccess;
  const _PinDialog({required this.onSuccess});

  @override
  State<_PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<_PinDialog> {
  final List<String> _digits = [];
  bool _error = false;
  static const int _pinLength = 4;

  void _addDigit(String d) {
    if (_digits.length >= _pinLength) return;
    setState(() {
      _digits.add(d);
      _error = false;
    });
    if (_digits.length == _pinLength) _verifyPin();
  }

  void _removeDigit() {
    if (_digits.isEmpty) return;
    setState(() => _digits.removeLast());
  }

  Future<void> _verifyPin() async {
    final pin = _digits.join();
    final ok = await context.read<ProfileProvider>().verifyParentPin(pin);
    if (ok) {
      widget.onSuccess();
    } else {
      setState(() {
        _digits.clear();
        _error = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1a1a2e),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🔑 Accesso Genitore',
                style: GoogleFonts.nunito(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
            const SizedBox(height: 8),
            Text(
              _error ? '❌ PIN errato, riprova' : 'Inserisci il PIN a 4 cifre',
              style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: _error ? Colors.redAccent : Colors.white60),
            ),
            const SizedBox(height: 24),

            // Pallini indicatori PIN
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pinLength, (i) {
                final filled = i < _digits.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled ? Colors.greenAccent : Colors.white24,
                  ),
                );
              }),
            ),
            const SizedBox(height: 28),

            // Tastierino numerico
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                ...'123456789'.split('').map((d) => _DigitButton(
                      digit: d,
                      onTap: () => _addDigit(d),
                    )),
                _DigitButton(
                    digit: '⌫',
                    onTap: _removeDigit,
                    color: Colors.orange),
                _DigitButton(digit: '0', onTap: () => _addDigit('0')),
                _DigitButton(
                    digit: '✕',
                    onTap: () => Navigator.of(context).pop(),
                    color: Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DigitButton extends StatelessWidget {
  final String digit;
  final VoidCallback onTap;
  final Color? color;

  const _DigitButton(
      {required this.digit, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: (color ?? Colors.white).withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            digit,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color ?? Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
