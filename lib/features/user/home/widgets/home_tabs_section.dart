import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/core/widgets/tab_widget.dart';
import 'package:hanzbthalk/features/user/home/cubit/home_cubit.dart';
import 'package:hanzbthalk/features/user/home/cubit/home_stats.dart';

class HomeTabsSection extends StatelessWidget {
  const HomeTabsSection({super.key, required this.currentTab});
  final String currentTab;
  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return BlocBuilder<HomeCubit, HomeStats>(
      buildWhen: (prev, curr) => curr is HomeLoaded,
      builder: (context, state) {
        String currentTab = (state is HomeLoaded)
            ? state.selectedTab
            : "nearby";

        return Row(
          children: [
            Expanded(
              child: TabWidget(
                width: w,
                height: h,
                tabName: context.tr('nearby'),
                isSelected: currentTab == "nearby",
                ontap: () => context.read<HomeCubit>().selectTab("nearby"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TabWidget(
                width: w,
                height: h,
                tabName: context.tr('offers'),
                isSelected: currentTab == "offers",
                ontap: () => context.read<HomeCubit>().selectTab("offers"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TabWidget(
                width: w,
                height: h,
                tabName: context.tr('lowestprice'),
                isSelected: currentTab == "lowestprice",
                ontap: () => context.read<HomeCubit>().selectTab("lowestprice"),
              ),
            ),
          ],
        );
      },
    );
  }
}
