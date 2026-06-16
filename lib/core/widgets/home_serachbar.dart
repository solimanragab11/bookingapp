import 'package:flutter/material.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({
    super.key,
    this.onChanged,
    this.isLoading = false,
    this.onFilterPressed,
    this.isFilterActive = false,
  });
  final ValueChanged<String>? onChanged;
  final bool isLoading;
  final VoidCallback? onFilterPressed;
  final bool isFilterActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        cursorColor: ColorManager.egyptianEarth,
        decoration: InputDecoration(
          hintText: context.tr('search'),
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
          prefixIcon: const Icon(Icons.search, color: ColorManager.wasabi),
          suffixIcon: isLoading
              ? const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      valueColor: AlwaysStoppedAnimation<Color>(ColorManager.egyptianEarth),
                    ),
                  ),
                )
              : onFilterPressed != null
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.tune_rounded,
                            color: isFilterActive
                                ? ColorManager.egyptianEarth
                                : ColorManager.wasabi,
                          ),
                          onPressed: onFilterPressed,
                        ),
                        if (isFilterActive)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: ColorManager.egyptianEarth,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    )
                  : null,
          filled: true,
          fillColor: ColorManager.cardSurface,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: ColorManager.emeraldGreen, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: ColorManager.egyptianEarth, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}
