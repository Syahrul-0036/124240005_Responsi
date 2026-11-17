import 'package:flutter/material.dart';

import '../services/session_service.dart';
// ignore: unused_import
import 'wishlist_screen.dart';
import 'home_screen.dart';
import 'login.dart';

// Menampung tab utama dan memastikan sesi dicek sebelum konten ditampilkan.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  int _refreshKey = 0;
  String? _username;
  bool _isCheckingSession = true;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  // MainScreen tidak menampilkan tab jika pengguna membuka rute tanpa sesi.
  Future<void> _checkSession() async {
    final username = await SessionService.getUsername();
    if (!mounted) return;
    if (username == null) {
      await Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
        (route) => false,
      );
      return;
    }
    setState(() {
      _username = username;
      _isCheckingSession = false;
    });
  }

  // Setiap perpindahan tab meminta layar membaca ulang favorit dari penyimpanan.
  void _selectTab(int index) {
    setState(() {
      _selectedIndex = index;
      _refreshKey++;
    });
  }

  // Logout menghapus sesi lalu menutup seluruh rute halaman utama.
  Future<void> _logout() async {
    await SessionService.clearLogin();
    if (!mounted) return;
    await Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingSession) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final pages = [
      HomeScreen(refreshKey: _refreshKey),
      WishlistScreen(refreshKey: _refreshKey),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Halo, ${_username ?? ''}'),
        actions: [
          IconButton(
            tooltip: 'Keluar',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _selectTab,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            label: 'Favorite',
          ),
          NavigationDestination(
            icon: Icon(Icons.movie_outlined),
            label: 'Episode',
          ),
        ],
      ),
    );
  }
}
