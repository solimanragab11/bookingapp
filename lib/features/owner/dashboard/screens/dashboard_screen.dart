import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:remaking_booking_app_trail2/core/localization/app_localizations.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';
import 'package:remaking_booking_app_trail2/core/widgets/background.dart';

class OwnerDashboardScreen extends StatefulWidget {
  final String placeId;
  const OwnerDashboardScreen({super.key, required this.placeId});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  DateTimeRange? selectedRange;

  @override
  void initState() {
    super.initState();
    // افتراضياً بنعرض إحصائيات الشهر الحالي
    final now = DateTime.now();
    selectedRange = DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: now,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: ColorManager.noirDeVigne,
      appBar: AppBar(
        title: Text(context.tr('business_dashboard')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month, color: ColorManager.wasabi),
            onPressed: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2024),
                lastDate: DateTime.now(),
                // تنسيق الـ Theme بتاع الـ Picker عشان يمشي مع الأبلكيشن
                builder: (context, child) => _buildPickerTheme(child!),
              );
              if (picked != null) setState(() => selectedRange = picked);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          BackGround(h: size.height, w: size.width), // الخلفية بتاعتك
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateDisplay(),
                const SizedBox(height: 20),
                _buildMainRevenueCard(), // الكارت الكبير للإجمالي
                const SizedBox(height: 16),
                _buildStatsGrid(), // شبكة الإحصائيات (App vs Manual)
                const SizedBox(height: 16),
                _buildHoursPerformanceCard(), // كارت أداء الساعات
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Widgets المساعدة ---

  Widget _buildDateDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        "Showing data from: ${DateFormat('dd MMM').format(selectedRange!.start)} to ${DateFormat('dd MMM').format(selectedRange!.end)}",
        style: const TextStyle(color: Colors.grey, fontSize: 13),
      ),
    );
  }

  Widget _buildMainRevenueCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [ColorManager.wasabi.withOpacity(0.8), ColorManager.wasabi],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            "Total Revenue",
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "7,500 EGP",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard("App Bookings", "12", Icons.phone_iphone, Colors.blue),
        _buildStatCard("Manual Bookings", "8", Icons.edit_note, Colors.orange),
        _buildStatCard(
          "App Money",
          "4,200",
          Icons.account_balance_wallet,
          ColorManager.emeraldGreen,
        ),
        _buildStatCard("Manual Money", "3,300", Icons.payments, Colors.amber),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildHoursPerformanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Usage Performance",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Total booked hours in this period",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ColorManager.wasabi.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Column(
              children: [
                Text(
                  "140", // هنا هيتحط الـ totalHours من الـ Cubit
                  style: TextStyle(
                    color: ColorManager.wasabi,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Hrs",
                  style: TextStyle(color: ColorManager.wasabi, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickerTheme(Widget child) {
    return Theme(
      data: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: ColorManager.wasabi, // لون الدوائر المختارة
          onPrimary: Colors.black, // لون الكتابة جوه الدواير
          surface: ColorManager.noirDeVigne, // لون خلفية الكالندر
          onSurface: Colors.white, // لون أيام الأسبوع
        ),
        dialogBackgroundColor: ColorManager.noirDeVigne,
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: ColorManager.wasabi),
        ),
      ),
      child: child,
    );
  }
}
