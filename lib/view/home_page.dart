import 'package:app/model/user.dart';
import 'package:app/view/news_page.dart';
import 'package:app/view/map_page.dart';
import 'package:app/view/profile_page.dart';
import 'package:app/view/register_donation_page.dart';
import 'package:flutter/material.dart';
import 'components/nav_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/repository/user_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final User? firebaseUser = FirebaseAuth.instance.currentUser;

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildHomeScreen(UserModel userModel) {
    final displayName = userModel.name.isNotEmpty ? userModel.name : "Usuário";

    return Padding(
      padding: const EdgeInsets.all(28.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.eco,
            size: 90,
            color: Colors.green.shade700,
          ),
          const SizedBox(height: 28),
          Text(
            "Bem-vindo, $displayName! 👋",
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          const Text(
            "No GreenDrop você pode realizar descartes de lixos eletrônicos, "
            "acompanhar notícias, encontrar pontos de apoio no mapa "
            "e acessar seu perfil com todas as suas informações.",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 20,
            runSpacing: 20,
            children: [
              _shortcut(
                icon: Icons.location_on,
                label: "Mapa",
                onTap: () => _onNavTap(1),
              ),
              _shortcut(
                icon: Icons.newspaper,
                label: "Notícias",
                onTap: () => _onNavTap(2),
              ),
              _shortcut(
                icon: Icons.volunteer_activism,
                label: "Doações",
                onTap: () => _onNavTap(3),
              ),
              _shortcut(
                icon: Icons.person,
                label: "Perfil",
                onTap: () => _onNavTap(4),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _shortcut({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 34, color: Colors.green.shade800),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.green.shade900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (firebaseUser == null) {
      return const Scaffold(
        body: Center(child: Text("Usuário não autenticado")),
      );
    }

    return FutureBuilder<UserModel?>(
      future: UserRepository(firestore: FirebaseFirestore.instance)
          .getUserByUid(firebaseUser!.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final userModel = snapshot.data!;
        print("Perfil do usuario: ${userModel.accessProfile}");
        final List<Widget> pages = [
          _buildHomeScreen(userModel),
          MapPage(),
          const NewsPage(),
          DonationPage(user: userModel),
          ProfilePage(uid: firebaseUser!.uid),
        ];

        return Scaffold(
          body: pages[_selectedIndex],
          bottomNavigationBar: CustomBottomNavBar(
            selectedIndex: _selectedIndex,
            onTap: _onNavTap,
          ),
        );
      },
    );
  }
}
