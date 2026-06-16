import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:hanzbthalk/core/models/offer_model.dart';

import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/core/widgets/background.dart';
import 'package:hanzbthalk/features/admin/offer/offer_list/logic/offers_cubit.dart';
import 'package:hanzbthalk/features/admin/offer/offer_mngm/screen/offer_mngmnt_screen.dart';

class OffersListPage extends StatelessWidget {
  const OffersListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // توفير الكيوبيت للشاشة واستدعاء العروض أول ما الصفحة تفتح
    return BlocProvider(
      create: (context) => OffersCubit()..fetchOffers(),
      child: const _OffersListContent(),
    );
  }
}

class _OffersListContent extends StatelessWidget {
  const _OffersListContent();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Active Offers',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: ColorManager.wasabi,
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          BackGround(h: size.height, w: size.width),
          SafeArea(
            child: BlocBuilder<OffersCubit, OffersState>(
              builder: (context, state) {
                // حالة التحميل
                if (state is OffersLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: ColorManager.wasabi,
                    ),
                  );
                }
                // حالة وجود خطأ
                else if (state is OffersError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                // حالة النجاح في جلب الداتا
                else if (state is OffersLoaded) {
                  final offers = state.offers;

                  // لو مفيش عروض
                  if (offers.isEmpty) {
                    return const Center(
                      child: Text(
                        "No active offers found",
                        style: TextStyle(
                          color: ColorManager.cardSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }

                  // عرض الداتا بناءً على نوع الشاشة (تابلت أو موبايل)
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.04,
                      vertical: 16,
                    ),
                    child: isTablet
                        ? GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  mainAxisExtent:
                                      160, // الارتفاع المناسب لكارت الموديل الجديد
                                ),
                            itemCount: offers.length,
                            itemBuilder: (context, index) =>
                                _buildOfferCard(context, offers[index]),
                          )
                        : ListView.builder(
                            itemCount: offers.length,
                            itemBuilder: (context, index) =>
                                _buildOfferCard(context, offers[index]),
                          ),
                  );
                }

                // الحالة المبدئية
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ColorManager.wasabi,
        foregroundColor: Colors.white,
        onPressed: () {
          final offersCubit = context.read<OffersCubit>();

          Navigator.push(
            context,
            MaterialPageRoute(
              // 2. بنبعته للشاشة الجديدة باستخدام BlocProvider.value
              builder: (context) => BlocProvider.value(
                value: offersCubit,
                child: const OfferFormPage(),
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // 🛠️ فصل كارت العرض باستخدام الموديل Offer
  Widget _buildOfferCard(BuildContext context, OfferModel offer) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final toDate = dateFormat.format(offer.validUntil);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: ColorManager.emeraldGreen.withOpacity(0.3),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          offer.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Text(
              offer.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: ColorManager.wasabi.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "${offer.discountPercentage.toStringAsFixed(0)}% OFF", // عشان يشيل الأصفار الزيادة لو رقم صحيح
                    style: const TextStyle(
                      color: ColorManager.egyptianEarth,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  "Valid until: $toDate",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: ColorManager.egyptianEarth,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OfferFormPage(offerData: offer),
            ),
          );
        },
      ),
    );
  }
}
