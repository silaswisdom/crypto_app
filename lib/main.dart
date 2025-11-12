import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData.dark().copyWith(
      colorScheme: ColorScheme.dark(
        primary: Colors.deepPurpleAccent,
        secondary: Colors.cyanAccent,
      ),
      scaffoldBackgroundColor: const Color(0xFF0B1020),
      textTheme: ThemeData.dark().textTheme.apply(
            bodyColor: Colors.white70,
            displayColor: Colors.white,
          ),
    );

    return MaterialApp(
      title: 'Crypto Wallet UI',
      theme: theme,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        final cappedScale = mq.textScaleFactor.clamp(1.0, 1.2);
        return MediaQuery(
          data: mq.copyWith(textScaleFactor: cappedScale),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const HomeScreen(),
    );
  }
}
