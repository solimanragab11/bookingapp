// ignore_for_file: deprecated_member_use

import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';
import 'package:flutter/material.dart';

class BrandingPanel extends StatelessWidget {
  const BrandingPanel({super.key});

  Widget _buildCategoryIcon(BuildContext context, IconData icon, String label) {
    final w = MediaQuery.of(context).size.width;
    return Row(
      children: [
        Icon(
          icon,
          color: ColorManager.egyptianEarth,
          size: w * 0.07,
        ), // Converted from 28
        SizedBox(width: w * 0.03), // Converted from 12
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: w * 0.045, // Converted from 18
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Container(
      decoration: const BoxDecoration(color: ColorManager.emeraldGreen),
      padding: EdgeInsets.all(w * 0.08), // Converted from 32.0
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: w * 0.08, // Converted from 32.0
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
              children: <TextSpan>[
                const TextSpan(text: 'Hub'),
                TextSpan(
                  text: 'Book',
                  style: TextStyle(color: ColorManager.egyptianEarth),
                ),
              ],
            ),
          ),
          SizedBox(height: h * 0.02), // Converted from 16.0
          Text(
            'Discover your next experience across Cafes, Fields, and Gaming. Seamlessly connected.',
            style: TextStyle(
              color: ColorManager.wasabi,
              fontSize: w * 0.045, // Converted from 18.0
              fontWeight: FontWeight.w300,
            ),
          ),
          SizedBox(height: h * 0.05), // Converted from 40.0
          _buildCategoryIcon(context, Icons.coffee, 'Café & Study Spots'),
          SizedBox(height: h * 0.02), // Converted from 16.0
          _buildCategoryIcon(
            context,
            Icons.sports_soccer,
            'Sports & Activity Fields',
          ),
          SizedBox(height: h * 0.02), // Converted from 16.0
          _buildCategoryIcon(context, Icons.gamepad, 'Gaming & Console Time'),
          const Spacer(),
          Container(
            height: h * 0.005, // Converted from 4.0
            color: ColorManager.egyptianEarth.withOpacity(0.7),
          ),
        ],
      ),
    );
  }
}
