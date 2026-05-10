import 'package:flutter/material.dart';
import 'package:remaking_booking_app_trail2/core/localization/app_localizations.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';

class AdminStatsGrid extends StatelessWidget {
  final bool isTablet;
  final Map<String, dynamic> stats;

  const AdminStatsGrid({
    super.key,
    required this.isTablet,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      // تحويل عدد الأعمدة بناءً على نوع الجهاز
      crossAxisCount: isTablet ? 4 : 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      // الـ Ratio ده بيضمن إن الكروت متبقاش طويلة زيادة ولا قصيرة فتضرب
      childAspectRatio: isTablet ? 1.4 : 1.1,
      children: [
        _StatCard(
          title: context.tr("Places"),
          value: stats['placesCount']?.toString() ?? "0",
          icon: Icons.location_on_rounded,
          color: Colors.blueAccent,
        ),
        _StatCard(
          title: context.tr("Users"),
          value: stats['usersCount']?.toString() ?? "0",
          icon: Icons.people_alt_rounded,
          color: Colors.orangeAccent,
        ),
        _StatCard(
          title: context.tr("Offers"),
          // هنا عملنا Localization للكلمة والعدد مع بعض
          value: "${stats['offersCount'] ?? 0} ${context.tr('Active')}",
          icon: Icons.local_offer_rounded,
          color: Colors.purpleAccent,
        ),
        _StatCard(
          title: context.tr("Income"),
          // عرض العملة بشكل محلي
          value: "${stats['income'] ?? 0} ${context.tr('EGP')}",
          icon: Icons.monetization_on_rounded,
          color: ColorManager.wasabi,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        // لون مستوحى من الهوية البصرية بتاعتك مع شفافية فخمة
        color: ColorManager.egyptianEarth.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // أيقونة خلفيتها دائرية خفيفة بتدي شكل "Premium"
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 10),
          // FittedBox هو أهم قطعة عشان الـ Responsiveness
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
