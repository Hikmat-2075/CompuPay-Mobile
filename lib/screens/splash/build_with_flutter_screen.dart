import 'package:flutter/material.dart';

class BuildWithFlutterScreen extends StatelessWidget {
  const BuildWithFlutterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: FlutterLogo(size: 100)),
          SizedBox(height: 8),
          Text("Build with Flutter", style: TextTheme.of(context).titleLarge),
          Text("By The Flutter Way"),
        ],
      ),
    );
  }
}
