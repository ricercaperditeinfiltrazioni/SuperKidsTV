// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/profile.dart';
import '../providers/profile_provider.dart';
import '../providers/channel_provider.dart';
import '../widgets/channel_card.dart';
import 'profile_selector_screen.dart';
import 'parent_screen.dart';
import 'player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final channelProvider = context.watch<ChannelProvider>();
    final profile = profileProvider.activeProfile!;

    if (channelProvider.timerExpired) {
      return _TimerExpiredScreen(onDismiss: () {
        channelProvider.resetTimerExpired();
        profileProvider.logout();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ProfileSelectorScreen()),
        );
      });
    }

    final channels = channelProvider.channelsForProfile(profile.type);
    final color = Color(int.parse('FF${profile.backgroundColor}', radix: 16));

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1a1a2e), Color(0xFF0f3460)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: color.withOpacity(0.2), shape: BoxShape.circle),
                      child: Text(profile.emoji, style: const TextStyle(fontSize: 24)),
                    ),
                    const SizedBox(width: 12),
                    Text(profile.name,
                        style: GoogleFonts.nunito(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    const Spacer(),
                    if (channelProvider.sleepTimerMinutes > 0) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.timer, color: Colors.orange, size: 16),
                            const SizedBox(width: 4),
                            Text(channelProvider.timerDisplay,
                                style: GoogleFonts.nunito(
                                    color: Colors.orange, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (profileProvider.isParent)
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white70),
                        onPressed: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const ParentScreen())),
                      ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white70),
                      onPressed: () {
                        profileProvider.logout();
                        Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (_) => const ProfileSelectorScreen()));
                      },
                    ),
                  ],
                ),
              ),

              // Barra ricerca (solo Kid e Genitore)
              if (profileProvider.canSearch)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    onChanged: (v) => setState(() {}),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Cerca video...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      prefixIcon: const Icon(Icons.search, color: Colors.white38),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.08),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none),
                    ),
                  ),
                ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('📺 I tuoi canali',
                      style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70)),
                ),
              ),

              // Griglia canali
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: profileProvider.isBaby ? 2 : 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: channels.length,
                  itemBuilder: (context, index) {
                    final channel = channels[index];
                    return ChannelCard(
                      channel: channel,
                      isBabyMode: profileProvider.isBaby,
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => PlayerScreen(channel: channel))),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimerExpiredScreen extends StatelessWidget {
  final VoidCallback onDismiss;
  const _TimerExpiredScreen({required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('😴', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 24),
            Text('È ora di riposare!',
                style: GoogleFonts.nunito(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white)),
            const SizedBox(height: 12),
            Text('Il tempo TV è finito per oggi.',
                style: GoogleFonts.nunito(fontSize: 18, color: Colors.white60)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: onDismiss,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.1),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: Text('Torna ai profili',
                  style: GoogleFonts.nunito(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
