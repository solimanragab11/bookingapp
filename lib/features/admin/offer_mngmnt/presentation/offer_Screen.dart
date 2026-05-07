import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remaking_booking_app_trail2/features/admin/offer_mngmnt/logic/offer_cubit.dart';
import 'package:remaking_booking_app_trail2/features/admin/offer_mngmnt/logic/offer_states.dart';

class ActivateOfferScreen extends StatefulWidget {
  final String placeId;
  final String subPlaceId;
  const ActivateOfferScreen({
    super.key,
    required this.placeId,
    required this.subPlaceId,
  });

  @override
  State<ActivateOfferScreen> createState() => _ActivateOfferScreenState();
}

class _ActivateOfferScreenState extends State<ActivateOfferScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _discountController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OwnerOfferCubit(),
      child: BlocConsumer<OwnerOfferCubit, OwnerOfferState>(
        listener: (context, state) {
          if (state is OwnerOfferSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("تم تفعيل العرض بنجاح!")),
            );
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: const Text("تفعيل عرض جديد")),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: "عنوان العرض (مثلاً: خصم الويك إند)",
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _descController,
                    decoration: const InputDecoration(labelText: "الوصف"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _discountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "نسبة الخصم (مثلاً: 20)",
                      suffixText: "%",
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    title: const Text("صالح حتى:"),
                    subtitle: Text("${_selectedDate.toLocal()}".split(' ')[0]),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null)
                        setState(() => _selectedDate = picked);
                    },
                  ),
                  const SizedBox(height: 30),
                  state is OwnerOfferLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: () {
                            context.read<OwnerOfferCubit>().submitOffer(
                              placeId: widget.placeId,
                              subPlaceId: widget.subPlaceId,
                              title: _titleController.text,
                              desc: _descController.text,
                              discount: double.parse(_discountController.text),
                              expiry: _selectedDate,
                            );
                          },
                          child: const Text("تفعيل العرض الآن"),
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
