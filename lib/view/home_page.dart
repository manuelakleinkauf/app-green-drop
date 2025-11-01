import 'package:app/view/news_page.dart';
import 'package:app/view/map_page.dart';
import 'package:app/view/profile_page.dart';
import 'package:app/view/register_donation_page.dart';
import 'package:flutter/material.dart';
import 'components/nav_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final User? user = FirebaseAuth.instance.currentUser;

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const Center(child: Text('Página Inicial')),
      MapPage(),
      const NewsPage(),
      DonationPage(),
      user != null
          ? ProfilePage(uid: user!.uid)
          : const Center(child: Text('Usuário não logado')),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
