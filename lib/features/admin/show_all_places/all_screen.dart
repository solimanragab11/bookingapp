import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remaking_booking_app_trail2/features/admin/show_all_places/all_cubit.dart';
import 'package:remaking_booking_app_trail2/features/admin/show_all_places/states.dart';

class AdminSelectPlaceScreen extends StatelessWidget {
  const AdminSelectPlaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminOfferCubit()..getAllPlacesForAdmin(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("لوحة تحكم العروض - Admin"),
          centerTitle: true,
        ),
        body: BlocBuilder<AdminOfferCubit, AdminOfferState>(
          builder: (context, state) {
            // 1. حالة التحميل
            if (state is AdminOfferLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // 2. حالة الفشل
            if (state is AdminOfferFailure) {
              return Center(child: Text(state.errorMessage));
            }

            // 3. حالة عرض البيانات (النجاح)
            if (state is AdminPlacesLoaded) {
              return ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: state.places.length, // عدلتها من place لـ places
                itemBuilder: (context, index) {
                  return Card(
                    // ... باقي كود الـ Card والـ ExpansionTile بتاعك سليم تماماً
                  );
                },
              );
            }

            return const Center(child: Text("ابدأ بجلب الأماكن"));
          },
        ),
      ),
    );
  }
}
