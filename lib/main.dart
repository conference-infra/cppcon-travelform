import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'invitation.dart';
import 'visa.dart';


void main() {
  usePathUrlStrategy();
  runApp(const TravelFormApp());
}

class TravelFormApp extends StatelessWidget {
  const TravelFormApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CppCon Travel Forms',
      theme: ThemeData.dark(useMaterial3: true),
      routes: {
        '/': (context) => const Invitation(),
        '/visa': (context) => const Visa(),
      },
    );
  }
}