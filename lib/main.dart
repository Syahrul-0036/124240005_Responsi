import 'package:flutter/material.dart';

import 'screens/login.dart';
import 'screens/main_screen.dart';
import 'services/session_service.dart';

void main() {
  runApp(const RickAndMortyApp());
}

// Widget utama menyiapkan tema dan memeriksa sesi sebelum membuka halaman.
class RickAndMortyApp extends StatelessWidget {
  const RickAndMortyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rick & Morty Character Explorer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF54A96B),
          surface: const Color(0xFFF7F9F6),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F9F6),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF7F9F6),
          foregroundColor: Color(0xFF18251B),
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        useMaterial3: true,
      ),
      home: const _SessionGate(),
    );
  }
}

// Halaman pembuka menampilkan indikator sambil membaca status login.
class _SessionGate extends StatefulWidget {
  const _SessionGate();

  @override
  State<_SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<_SessionGate> {
  late Future<String?> _usernameFuture;

  @override
  void initState() {
    super.initState();
    _usernameFuture = SessionService.getUsername();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _usernameFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return const LoginScreen();
        }
        if (snapshot.data != null) {
          return const MainScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
