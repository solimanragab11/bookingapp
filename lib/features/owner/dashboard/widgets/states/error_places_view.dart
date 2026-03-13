import 'package:flutter/material.dart';

class ErrorPlacesView extends StatelessWidget {
  final String message;

  const ErrorPlacesView({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(color: Colors.redAccent),
      ),
    );
  }
}

