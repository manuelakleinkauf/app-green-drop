import 'package:app/view/news_page.dart';
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
  final user = FirebaseAuth.instance.currentUser;

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Lista de páginas para exibir
  final List<Widget> _pages = [
    Center(child: Text('Página Inicial')),
    Center(child: Text('Negócios ou Comunidade')),
    NewsPage(),
    Center(child: Text('Perfil')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
