import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/features/admin/add_place/logic/add_place_cubit.dart';
import 'package:hanzbthalk/features/admin/add_place/logic/add_place_state.dart';
// استيراد الـ Widgets الجديدة
import 'selected_owner_banner.dart';
import 'search_results_list.dart';

class AddPlaceSearchBar extends StatefulWidget {
  const AddPlaceSearchBar({super.key});

  @override
  State<AddPlaceSearchBar> createState() => _AddPlaceSearchBarState();
}

class _AddPlaceSearchBarState extends State<AddPlaceSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Auto-fill الـ Owner لو كنا في Edit Mode
    final currentCubitState = context.read<AddPlaceCubit>().state;
    if (currentCubitState.selectedOwner != null) {
      _controller.text = currentCubitState.selectedOwner!.phoneNumber;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel(); // مهم جداً تقفله هنا عشان ميعملش Memory Leak
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged(String value) {
    // لو فيه تايمر شغال من الحرف اللي فات.. كنسله فوراً
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // ابدأ تايمر جديد
    _debounce = Timer(const Duration(milliseconds: 500), () {
      // الكود اللي جوه هنا مش هيتنفذ غير لما الأدمن يثبت إيده عن الكتابة لمدة 500ms
      debugPrint("Firebase Search Called for: $value");
      context.read<AddPlaceCubit>().searchOwner(value);
    });
  }

  void _onOwnerSelected(AddPlaceState state, int index) {
    final owner = state.searchResults[index];
    context.read<AddPlaceCubit>().selectOwner(owner);

    _controller
      ..text = owner.phoneNumber
      ..selection = TextSelection.collapsed(offset: owner.phoneNumber.length);

    _focusNode.unfocus();
  }

  void _onCancel() {
    context.read<AddPlaceCubit>().cancelSelection();
    _controller.removeListener(() {});
    _controller.clear();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
      child: BlocBuilder<AddPlaceCubit, AddPlaceState>(
        builder: (context, state) {
          final hasOwner = state.selectedOwner != null;
          final hasResults = state.searchResults.isNotEmpty;

          if (hasOwner && _controller.text.isEmpty) {
            _controller.text = state.selectedOwner!.phoneNumber;
          }

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

              // ── 2. Owner selected banner ─────────────────
              if (hasOwner) ...[
                const SizedBox(height: 8),
                SelectedOwnerBanner(
                  name: state.selectedOwner!.username,
                  phone: state.selectedOwner!.phoneNumber,
                  onCancel: _onCancel,
                ),
              ],

              // ── 3. Search results dropdown ───────────────────────────────
              if (hasResults && !hasOwner) ...[
                const SizedBox(height: 4),
                SearchResultsList(
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
