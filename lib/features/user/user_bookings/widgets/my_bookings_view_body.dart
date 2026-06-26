import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanzbthalk/core/localization/localization_extension.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/features/user/user_bookings/cubit/user_bookings_cubit.dart';
import 'package:hanzbthalk/features/user/user_bookings/cubit/user_bookings_status.dart';
import 'package:hanzbthalk/features/user/user_bookings/widgets/booking_card/booking_card_widget.dart';
import 'package:hanzbthalk/features/user/user_bookings/widgets/booking_card/sub_widgets/booking_time_helper.dart';
import 'package:hanzbthalk/features/user/user_bookings/widgets/refund_request_card_widget.dart';
import 'package:hanzbthalk/features/user/user_bookings/widgets/booking_card/animated_booking_card.dart';

class MyBookingsViewBody extends StatefulWidget {
  final String? targetBookingId;
  const MyBookingsViewBody({super.key, this.targetBookingId});

  @override
  State<MyBookingsViewBody> createState() => _MyBookingsViewBodyState();
}

class _MyBookingsViewBodyState extends State<MyBookingsViewBody> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _statusFilter = "all"; // all, active, attended, canceled, no_show
  String _sortBy = "default"; // default, soonest, latest, price_asc, price_desc
  bool _hasScrolled = false;

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _scrollToTarget(List<Map<String, dynamic>> bookings) {
    if (widget.targetBookingId == null || _hasScrolled) return;

    final index = bookings.indexWhere((b) => b['id'] == widget.targetBookingId);
    if (index != -1) {
      _hasScrolled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Average item height calculation (approx 195 pixels per item including bottom padding)
        const double itemHeight = 195.0;
        _scrollController.animateTo(
          index * itemHeight,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOutCubic,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return BlocBuilder<UserBookingsCubit, UserBookingsState>(
      builder: (context, state) {
        if (state is UserBookingsLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (state is UserBookingsEmpty) {
          return TabBarView(
            children: [
              _buildEmptyState(context, isRefundRequests: false),
              _buildEmptyState(context, isRefundRequests: true),
            ],
          );
        }

        if (state is UserBookingsSuccess) {
          // Trigger the scroll logic when bookings successfully load
          _scrollToTarget(state.bookings);

          // Apply filtering to bookings
          final filteredBookings = state.bookings.where((booking) {
            // 1. Search Query Filter
            if (_searchQuery.isNotEmpty) {
              final placeInfo = booking['placeInfo'] as Map<String, dynamic>?;
              final venueName = (placeInfo?['name'] as String? ?? "").toLowerCase();

              final subPlaceId = booking['subPlaceId'] as String? ?? "";
              String subPlaceName = subPlaceId;
              if (subPlaceId.contains('_')) {
                final parts = subPlaceId.split('_');
                if (parts.length > 1) {
                  subPlaceName = parts.sublist(1).join(' ').trim();
                }
              }
              subPlaceName = subPlaceName.toLowerCase();

              final query = _searchQuery.toLowerCase();
              if (!venueName.contains(query) && !subPlaceName.contains(query)) {
                return false;
              }
            }

            // 2. Status Filter
            if (_statusFilter != 'all') {
              final status = (booking['status'] as String? ?? 'active').toLowerCase();
              if (_statusFilter == 'active') {
                return status == 'active' || status == 'pending_no_show';
              } else if (_statusFilter == 'attended') {
                return status == 'attended';
              } else if (_statusFilter == 'canceled') {
                return status == 'canceled';
              } else if (_statusFilter == 'no_show') {
                return status == 'no_show';
              }
            }

            return true;
          }).toList();

          // Apply sorting to filteredBookings
          if (_sortBy != 'default') {
            filteredBookings.sort((a, b) {
              if (_sortBy == 'soonest' || _sortBy == 'latest') {
                final timeA = BookingTimeHelper.getBookingStartTime(a) ?? DateTime.fromMillisecondsSinceEpoch(0);
                final timeB = BookingTimeHelper.getBookingStartTime(b) ?? DateTime.fromMillisecondsSinceEpoch(0);
                return _sortBy == 'soonest' ? timeA.compareTo(timeB) : timeB.compareTo(timeA);
              } else if (_sortBy == 'price_asc' || _sortBy == 'price_desc') {
                final priceA = (a['totalPrice'] ?? 0).toDouble();
                final priceB = (b['totalPrice'] ?? 0).toDouble();
                return _sortBy == 'price_asc' ? priceA.compareTo(priceB) : priceB.compareTo(priceA);
              }
              return 0;
            });
          }

          return TabBarView(
            children: [
              // Tab 1: Upcoming Bookings (with Search, Status Filters & Sorting)
              Column(
                children: [
                  _buildFilterAndSearchSection(context),
                  Expanded(
                    child: filteredBookings.isEmpty
                        ? _buildEmptyState(
                            context,
                            isRefundRequests: false,
                            isSearchEmpty: true,
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: EdgeInsets.symmetric(
                              horizontal: w * 0.04,
                              vertical: 8,
                            ),
                            itemCount: filteredBookings.length,
                            itemBuilder: (context, index) {
                              final booking = filteredBookings[index];
                              
                              final isTarget = booking['id'] == widget.targetBookingId;
                              final double total = (booking['totalPrice'] ?? 0).toDouble();
                              final double paid = (booking['paidAmount'] ?? 0).toDouble();
                              final double remaining = total - paid;
                              final String status = booking['status'] ?? "N/A";
                              final startTime = BookingTimeHelper.getBookingStartTime(booking);

                              final bool isNotPaid = remaining > 0;
                              final bool isPendingOrActive = status == 'active' || status == 'pending_no_show';
                              final bool isFuture = startTime != null && startTime.isAfter(DateTime.now());

                              final bool shouldGlow = isTarget && isNotPaid && isPendingOrActive && isFuture;

                              return AnimatedBookingCard(
                                isHighlighted: shouldGlow,
                                child: BookingCardWidget(booking: booking),
                              );
                            },
                          ),
                  ),
                ],
              ),
              // Tab 2: Refund Requests
              state.refundRequests.isEmpty
                  ? _buildEmptyState(context, isRefundRequests: true)
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: w * 0.04,
                        vertical: 8,
                      ),
                      itemCount: state.refundRequests.length,
                      itemBuilder: (context, index) => RefundRequestCardWidget(
                        request: state.refundRequests[index],
                      ),
                    ),
            ],
          );
        }

        return const Center(
          child: Text(
            "Error fetching data",
            style: TextStyle(color: Colors.red),
          ),
        );
      },
    );
  }

  Widget _buildFilterAndSearchSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: ColorManager.emeraldGreen.withOpacity(0.2),
                      width: 1.0,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: context.tr('search_bookings_hint'),
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 13,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: Colors.white.withOpacity(0.5),
                        size: 20,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.close_rounded,
                                color: Colors.white60,
                                size: 18,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = "";
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: ColorManager.egyptianEarth.withOpacity(0.2),
                    width: 1.0,
                  ),
                ),
                child: PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.sort_rounded,
                    color: ColorManager.egyptianEarth,
                    size: 22,
                  ),
                  color: ColorManager.cardSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(
                      color: ColorManager.egyptianEarth.withOpacity(0.3),
                      width: 1.0,
                    ),
                  ),
                  onSelected: (val) {
                    setState(() {
                      _sortBy = val;
                    });
                  },
                  itemBuilder: (context) => [
                    _buildSortMenuItem(context, 'default', 'sort_default'),
                    _buildSortMenuItem(context, 'soonest', 'sort_soonest'),
                    _buildSortMenuItem(context, 'latest', 'sort_latest'),
                    _buildSortMenuItem(context, 'price_asc', 'sort_price_asc'),
                    _buildSortMenuItem(context, 'price_desc', 'sort_price_desc'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip(context, 'all', 'filter_all'),
                _buildFilterChip(context, 'active', 'filter_active'),
                _buildFilterChip(context, 'attended', 'filter_attended'),
                _buildFilterChip(context, 'canceled', 'filter_canceled'),
                _buildFilterChip(context, 'no_show', 'filter_no_show'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildSortMenuItem(
    BuildContext context,
    String value,
    String localizationKey,
  ) {
    final bool isSelected = _sortBy == value;
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            context.tr(localizationKey),
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
          if (isSelected)
            const Icon(
              Icons.check_rounded,
              color: ColorManager.egyptianEarth,
              size: 16,
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String filterValue,
    String localizationKey,
  ) {
    final bool isActive = _statusFilter == filterValue;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _statusFilter = filterValue;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? ColorManager.egyptianEarth.withOpacity(0.85)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive
                  ? ColorManager.egyptianEarth
                  : Colors.white.withOpacity(0.1),
            ),
          ),
          child: Center(
            child: Text(
              context.tr(localizationKey),
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white70,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required bool isRefundRequests,
    bool isSearchEmpty = false,
  }) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ColorManager.cardSurface.withOpacity(0.4),
                border: Border.all(
                  color: ColorManager.egyptianEarth.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: ColorManager.egyptianEarth.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                isSearchEmpty
                    ? Icons.search_off_rounded
                    : (isRefundRequests
                        ? Icons.receipt_long_rounded
                        : Icons.calendar_month_outlined),
                size: 56,
                color: ColorManager.egyptianEarth,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isSearchEmpty
                  ? context.tr('no_matching_bookings')
                  : (isRefundRequests
                      ? context.tr('no_refund_requests')
                      : context.tr('noBookingsFound')),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (!isSearchEmpty) ...[
              const SizedBox(height: 12),
              Text(
                isRefundRequests
                    ? context.tr('no_refund_requests_desc')
                    : context.tr('noBookingsSubtitle'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              if (!isRefundRequests)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorManager.egyptianEarth,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 36,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                    shadowColor: ColorManager.egyptianEarth.withOpacity(0.4),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    context.tr('exploreNow'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
