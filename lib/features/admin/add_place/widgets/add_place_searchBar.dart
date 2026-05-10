import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remaking_booking_app_trail2/core/localization/app_localizations.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';
import 'package:remaking_booking_app_trail2/features/admin/add_place/logic/add_place_cubit.dart';
import 'package:remaking_booking_app_trail2/features/admin/add_place/logic/add_place_state.dart';

class AddPlaceSearchBar extends StatefulWidget {
  const AddPlaceSearchBar({super.key});

  @override
  State<AddPlaceSearchBar> createState() => _AddPlaceSearchBarState();
}

class _AddPlaceSearchBarState extends State<AddPlaceSearchBar> {
  // Owned here — not passed in — so cancel can fully control it.
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  void _onTextChanged(String value) {
    context.read<AddPlaceCubit>().searchOwner(value);
  }

  void _onOwnerSelected(AddPlaceState state, int index) {
    final owner = state.searchResults[index];
    context.read<AddPlaceCubit>().selectOwner(owner);

    // Manually set text without triggering onChanged → no unwanted search call.
    _controller
      ..text = owner.phoneNumber
      ..selection = TextSelection.collapsed(offset: owner.phoneNumber.length);

    _focusNode.unfocus();
  }

  void _onCancel() {
    // 1. Clear cubit state (owner + search results).
    context.read<AddPlaceCubit>().cancelSelection();

    // 2. Clear the text field without triggering onChanged.
    //    removeListener trick: temporarily detach, mutate, re-attach.
    _controller.removeListener(_listenerPlaceholder);
    _controller.clear();

    // 3. Unfocus keyboard.
    _focusNode.unfocus();
  }

  // Placeholder — we use the onChanged callback approach, not a listener,
  // but we still need this no-op for the removeListener call above.
  void _listenerPlaceholder() {}

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
      child: BlocBuilder<AddPlaceCubit, AddPlaceState>(
        builder: (context, state) {
          final hasOwner = state.selectedOwner != null;
          final hasResults = state.searchResults.isNotEmpty;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── 1. Search field ──────────────────────────────────────────
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: hasOwner
                        ? ColorManager.wasabi.withOpacity(0.6)
                        : hasResults
                        ? ColorManager.wasabi
                        : Colors.white12,
                    width: hasOwner || hasResults ? 1.5 : 1,
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  // Lock field while an owner is selected
                  readOnly: hasOwner,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: TextStyle(
                    color: hasOwner
                        ? ColorManager.wasabi
                        : ColorManager.egyptianEarth,
                  ),
                  decoration: InputDecoration(
                    hintText: hasOwner ? '' : context.tr('Searching ..'),
                    hintStyle: const TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                    prefixIcon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        hasOwner ? Icons.person_pin : Icons.search,
                        key: ValueKey(hasOwner),
                        color: ColorManager.wasabi,
                      ),
                    ),
                    // Show clear/cancel button only when owner is selected
                    suffixIcon: hasOwner
                        ? IconButton(
                            icon: const Icon(
                              Icons.cancel,
                              color: Colors.redAccent,
                            ),
                            tooltip: 'Remove owner',
                            onPressed: _onCancel,
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 4,
                    ),
                  ),
                  onChanged: _onTextChanged,
                ),
              ),

              // ── 2. Owner selected chip (below the field) ─────────────────
              if (hasOwner) ...[
                const SizedBox(height: 8),
                _SelectedOwnerBanner(
                  name: state.selectedOwner!.username,
                  phone: state.selectedOwner!.phoneNumber,
                  onCancel: _onCancel,
                ),
              ],

              // ── 3. Search results dropdown ───────────────────────────────
              if (hasResults && !hasOwner) ...[
                const SizedBox(height: 4),
                _SearchResultsList(
                  results: state.searchResults,
                  onSelect: (index) => _onOwnerSelected(state, index),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

// ─── Selected owner banner ─────────────────────────────────────────────────────

class _SelectedOwnerBanner extends StatelessWidget {
  final String name;
  final String phone;
  final VoidCallback onCancel;

  const _SelectedOwnerBanner({
    required this.name,
    required this.phone,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: ColorManager.wasabi.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorManager.wasabi.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: ColorManager.wasabi, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: ColorManager.wasabi,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  phone,
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),
          // Cancel button
          GestureDetector(
            onTap: onCancel,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.close, color: Colors.redAccent, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    context.tr('cancel'),
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Search results list ───────────────────────────────────────────────────────

class _SearchResultsList extends StatelessWidget {
  final List results; // List<UserModel>
  final ValueChanged<int> onSelect;

  const _SearchResultsList({required this.results, required this.onSelect});

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
