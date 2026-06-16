import 'package:flutter/material.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';

class SearchResultsList extends StatelessWidget {
  final List results; // List<UserModel>
  final ValueChanged<int> onSelect;

  const SearchResultsList({
    super.key,
    required this.results,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 220),
      decoration: BoxDecoration(
        color: ColorManager.noirDeVigne.withOpacity(0.95),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: ColorManager.wasabi.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: results.length,
          separatorBuilder: (_, __) => const Divider(
            height: 1,
            color: Colors.white10,
            indent: 16,
            endIndent: 16,
          ),
          itemBuilder: (context, index) {
            final owner = results[index];
            return InkWell(
              onTap: () => onSelect(index),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: ColorManager.wasabi.withOpacity(0.15),
                      child: Text(
                        owner.username.isNotEmpty
                            ? owner.username[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: ColorManager.wasabi,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            owner.username,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            owner.phoneNumber,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.white30,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
