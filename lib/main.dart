import 'package:classia_amc/routes/route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // Reference design size (e.g., iPhone X)
      minTextAdapt: true, // Adapt font sizes to screen size
      splitScreenMode: true, // Support split-screen or foldable devices
      builder: (context, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Flutter App',
          routerConfig: router,
        );
      },
    );
  }
}
