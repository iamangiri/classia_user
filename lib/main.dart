import 'package:classia_amc/routes/route.dart';
import 'package:classia_amc/screen/profile/learn_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart'; // Import provider package



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserPoints()), // Add your provider here
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812), // Reference design size (e.g., iPhone X)
        minTextAdapt: true, // Adapt font sizes to screen size
        splitScreenMode: true, // Support split-screen or foldable devices
        builder: (context, child) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Jockey Trading',
            routerConfig: router,
          );
        },
      ),
    );
  }
}