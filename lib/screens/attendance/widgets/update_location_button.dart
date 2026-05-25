import 'package:flutter/material.dart';

class UpdateLocationButton extends StatelessWidget {
  final VoidCallback onPressed;

  const UpdateLocationButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          child: const Text("Update My Location"),
        ),
      ),
    );
  }
}