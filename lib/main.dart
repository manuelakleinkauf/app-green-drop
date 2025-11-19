import 'package:app/db/firebase_options.dart';
import 'package:app/repository/user_repository.dart';
import 'package:app/viewmodel/auth_viewmodel.dart';
import 'package:app/viewmodel/current_user_provider.dart';
import 'package:app/viewmodel/donation_view_model.dart';
import 'package:app/viewmodel/map_viewmodel.dart';
import 'package:app/viewmodel/profile_viewmodel.dart';
import 'package:app/viewmodel/reward_viewmodel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'view/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final firestore = FirebaseFirestore.instance;
  final userRepository = UserRepository(firestore: firestore);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => CurrentUserProvider()),
        ChangeNotifierProvider(
          create: (_) => ProfileViewModel(repository: userRepository),
        ),
        ChangeNotifierProvider(create: (_) => DonationViewModel()),
        ChangeNotifierProvider(create: (_) => MapViewModel()),
        ChangeNotifierProvider(create: (_) => RewardViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'GreenDrop',
        theme: ThemeData(primarySwatch: Colors.green),
        home: LoginPage(),
      ),
    ),
  );
}
