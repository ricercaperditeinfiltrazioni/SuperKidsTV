// lib/main.dart
// Punto di ingresso dell'app SuperKidsTV

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/profile_provider.dart';
import 'providers/channel_provider.dart';
import 'screens/profile_selector_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Orientamento verticale di default (landscape solo durante il video)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const SuperKidsTVApp());
}

class SuperKidsTVApp extends StatelessWidget {
  const SuperKidsTVApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => ChannelProvider()),
      ],
      child: MaterialApp(
        title: 'SuperKids TV',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6B48FF),
            brightness: Brightness.dark,
          ),
          textTheme: GoogleFonts.nunitoTextTheme(
            ThemeData.dark().textTheme,
          ),
        ),
        home: const ProfileSelectorScreen(),
      ),
    );
  }
}
