import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/core/routes/routes.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/features/language/cubit/language_cubit.dart';

class OwnerIntroPage extends StatelessWidget {
  const OwnerIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isAr = locale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: ColorManager.noirDeVigne,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          context.tr('owner_intro_title'),
          style: const TextStyle(
            color: ColorManager.creasedKhaki,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              final newLang = isAr ? 'en' : 'ar';
              context.read<LanguageCubit>().changeLanguage(newLang);
            },
            child: Text(
              isAr ? 'English' : 'العربية',
              style: const TextStyle(
                color: ColorManager.wasabi,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ColorManager.cardSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: ColorManager.emeraldGreen,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAr
                          ? "أهلاً بك في نظام شركاء هانظبطهالك"
                          : "Welcome to Hanzbthalk Partner Program",
                      style: const TextStyle(
                        color: ColorManager.creasedKhaki,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.tr('owner_intro_rules'),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Scrollable Contract Card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ColorManager.cardSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ColorManager.emeraldGreen),
                  ),
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(right: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isAr
                                ? "عقد اتفاقية تقديم الخدمات"
                                : "Service Provider Agreement Contract",
                            style: const TextStyle(
                              color: ColorManager.egyptianEarth,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(
                            color: ColorManager.emeraldGreen,
                            height: 20,
                          ),
                          Text(
                            isAr
                                ? "البند الأول: طبيعة الخدمات المقدمة من المالك ودقة التسجيل والبيانات.\n\n"
                                      "البند الثاني: يلتزم المالك بقبول وتنفيذ الحجوزات المؤكدة عبر التطبيق دون تغيير في السعر أو المواعيد المتفق عليها.\n\n"
                                      "البند الثالث: سياسة الإلغاء والاسترجاع للمستخدمين تتم وفقاً للتطبيق وتخصم الرسوم حسب التوجيهات.\n\n"
                                      "البند الرابع: تحصيل الأموال والعمولات وتسوية المستحقات يتم بشكل دوري عبر قنوات الدفع الرقمية المتوفرة.\n\n"
                                      "البند الخامس: يحظر تماماً على المالك تقديم معلومات مضللة أو صور غير حقيقية للأماكن والخدمات، وفي حال المخالفة يتم إيقاف الحساب فوراً."
                                : "Clause 1: Scope of services provided by the Owner and accuracy of registered data.\n\n"
                                      "Clause 2: The Owner is committed to accept and fulfill confirmed bookings via the app without changing the agreed price or schedule.\n\n"
                                      "Clause 3: Cancellation and refund policies for users are processed through the app and fees are deducted accordingly.\n\n"
                                      "Clause 4: Financial collection, commissions, and payouts are settled periodically through active digital payment channels.\n\n"
                                      "Clause 5: It is strictly prohibited to provide misleading information or fake photos of places and services; violation will result in immediate suspension.",
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 13,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Action Buttons
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.ownerAgreement);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorManager.egyptianEarth,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  context.tr('owner_continue'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
