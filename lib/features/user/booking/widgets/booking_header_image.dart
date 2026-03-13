import 'package:flutter/material.dart';

class BookingHeaderImage extends StatelessWidget {
  final String imageUrl;
  final double height;

  const BookingHeaderImage({
    super.key,
    required this.imageUrl,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: Image.network(
        imageUrl,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}
