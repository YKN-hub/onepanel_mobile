import 'package:flutter/material.dart';

class RefreshIconButton extends StatelessWidget {
  final VoidCallback onPressed;

  const RefreshIconButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.refresh),
      onPressed: onPressed,
    );
  }
}
