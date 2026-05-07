import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:remaking_booking_app_trail2/core/db/auth_service.dart';
import 'package:remaking_booking_app_trail2/core/models/booking_id_model.dart';
import 'package:remaking_booking_app_trail2/core/models/booking_model.dart';
import 'package:remaking_booking_app_trail2/core/models/dashboard_states_model.dart';
import 'package:remaking_booking_app_trail2/core/models/offer.dart';
import 'package:remaking_booking_app_trail2/core/models/place.dart';
import 'package:path/path.dart' as p;
import 'package:remaking_booking_app_trail2/core/models/user_model.dart'; // بنستخدمه عشان نجيب الـ extension (jpg/png)

class FirestoreOwnerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirestoreOwnerService(this._authService);
  final AuthService _authService;
  final _storage = FirebaseStorage.instance;

  // إضافة مكان جديد
  Future<void> addPlace(PlaceModel place) async {
    await _firestore.collection('places').doc(place.id).set(place.toJson());
  }

  // جلب الأماكن الخاصة بـ Owner معين
  Future<List<PlaceModel>> getPlacesByOwner() async {
    // ملحوظة لعمي السولي: هنا بنستخدم الـ ownerId اللي جوه الـ PlaceModel model
    final ownerId = await _authService.getCurrentUserId();

    QuerySnapshot querySnapshot = await _firestore
        .collection('places')
        .where('ownerId', isEqualTo: ownerId)
        .get();

    return querySnapshot.docs
        .map((doc) => PlaceModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // حذف مكان بكل صوره بدون المساس بالحجوزات
  Future<void> deletePlaceWithImages({
    required String placeId,
    required String ownerId,
  }) async {
    // بنفترض إن الصور محفوظة في مسار منسق حسب الـ ownerId والـ placeId
    final placeDocRef = _firestore.collection('places').doc(placeId);

    // 1) هنجلب بيانات المكان عشان نعرف روابط الصور
    final placeSnapshot = await placeDocRef.get();
    if (!placeSnapshot.exists) {
      return;
    }
    final data = placeSnapshot.data() as Map<String, dynamic>;

    // 2) نجمع كل روابط الصور (المكان + الملاعب الفرعية) مع دعم Map/List
    final List<String> allImageUrls = [];

    // images ممكن تبقى List أو Map أو String
    final dynamic imagesField = data['images'];
    if (imagesField is List) {
      for (final item in imagesField) {
        if (item is String && item.isNotEmpty) {
          allImageUrls.add(item);
        }
      }
    } else if (imagesField is Map) {
      for (final value in imagesField.values) {
        if (value is String && value.isNotEmpty) {
          allImageUrls.add(value);
        }
      }
    } else if (imagesField is String && imagesField.isNotEmpty) {
      allImageUrls.add(imagesField);
    }

    // subPlaces ممكن تبقى List أو Map
    final dynamic subPlacesField = data['subPlaces'];
    if (subPlacesField is List) {
      for (final sp in subPlacesField) {
        if (sp is Map<String, dynamic>) {
          final img = sp['imageUrl'];
          if (img is String && img.isNotEmpty) {
            allImageUrls.add(img);
          }
        }
      }
    } else if (subPlacesField is Map) {
      for (final sp in subPlacesField.values) {
        if (sp is Map<String, dynamic>) {
          final img = sp['imageUrl'];
          if (img is String && img.isNotEmpty) {
            allImageUrls.add(img);
          }
        }
      }
    }

    // 3) نحذف أي Sub-Collections معروفه (مثلاً subPlaces كـ Sub-Collection)
    final batch = _firestore.batch();

    // نحاول نمسح Sub-Collection باسم "subPlaces" لو موجودة
    final subPlacesCollection = placeDocRef.collection('subPlaces');
    final subPlacesSnapshot = await subPlacesCollection.get();
    for (final doc in subPlacesSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // 4) نحذف الدوكيومنت نفسه ضمن الـ Batch
    batch.delete(placeDocRef);
    await batch.commit();

    // 5) بعد نجاح حذف الداتا، نحذف الصور من Firebase Storage (مالهاش علاقة بالحجوزات)
    for (final url in allImageUrls) {
      try {
        final ref = _storage.refFromURL(url);
        await ref.delete();
      } catch (_) {
        // لو صورة مش موجودة أو فيه خطأ في الحذف، بنطنش عشان منوقعش العملية كلها
      }
    }
  }

  Future<void> updateSubPlaceDetails(
    String placeId,
    String subPlaceId,
    Map<String, dynamic> details,
  ) async {
    final DocumentReference placeRef = _firestore
        .collection('places')
        .doc(placeId);
    await _firestore.runTransaction((transaction) async {
      final DocumentSnapshot placeSnapshot = await transaction.get(placeRef);
      if (!placeSnapshot.exists) throw Exception('Place not found!');

      final placeData = placeSnapshot.data() as Map<String, dynamic>;
      List<dynamic> subPlacesData = placeData['subPlaces'] ?? [];
      final index = subPlacesData.indexWhere((sp) => sp['id'] == subPlaceId);

      if (index != -1) {
        subPlacesData[index].addAll(details);
        transaction.update(placeRef, {'subPlaces': subPlacesData});
      }
    });
  }

  static downscaleImage(File imageFile) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final String targetPath = p.join(
        tempDir.path,
        "compressed_${DateTime.now().millisecondsSinceEpoch}.jpg",
      );

      // التعديل هنا: بنستخدم XFile ونتأكد من المسار
      var result = await FlutterImageCompress.compressAndGetFile(
        imageFile.path, // مسار الملف الأصلي
        targetPath,
        quality: 70,
        minWidth: 800,
        minHeight: 800,
        format: CompressFormat.jpeg, // حدد الفورمات صراحة
      );

      return result;
    } catch (e) {
      // هنا هيطبعلك السبب الحقيقي لو لسه فيه مشكلة
      debugPrint("Error during DownScaling: $e");
      return null;
    }
  }

  static Future<String?> uploadADownscaledImage(File imageFile) async {
    try {
      var downScaledImage = await downscaleImage(imageFile);

      File fileToUpload = File(downScaledImage.path);
      String fileName = p.basename(fileToUpload.path);

      Reference storageRef = FirebaseStorage.instance.ref().child(
        'uploads/bookings/$fileName',
      );

      // الرفع
      UploadTask uploadTask = storageRef.putFile(fileToUpload);
      TaskSnapshot snapshot = await uploadTask;

      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      // هنا هيطبعلك السبب الحقيقي لو لسه فيه مشكلة
      debugPrint("Error during upload: $e");
      return null;
    }
  }

  // 1. جلب كل أماكن صاحب المكان ده بس
  Stream<List<PlaceModel>> getOwnerPlaces() async* {
    final ownerId = await _authService.getCurrentUserId();
    yield* _firestore
        .collection('places')
        .where('ownerId', isEqualTo: ownerId)
        .snapshots() // دي اللي بتخليها Stream
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PlaceModel.fromJson(doc.data()))
              .toList(),
        );
  }

  // 2. حساب التحليلات لكل مكان (Live Analysis)
  Future<Map<String, dynamic>> getPlaceAnalysis(String placeId) async {
    // جلب كل الحجوزات الناجحة للمكان ده
    final querySnapshot = await _firestore
        .collection('bookings')
        .where('placeId', isEqualTo: placeId)
        .where('status', isEqualTo: 'confirmed') // الحجوزات المؤكدة بس
        .get();

    double totalRevenue = 0;
    int totalBookings = querySnapshot.docs.length;

    for (var doc in querySnapshot.docs) {
      totalRevenue += (doc.data()['price'] ?? 0).toDouble();
    }

    return {'revenue': totalRevenue, 'bookingsCount': totalBookings};
  }

  // عملية الإلغاء: نرجع الساعة للمتاح
  Future<void> cancelTimeSlot({
    required String placeId,
    required int subPlaceIndex,
    required String day,
    required String timeSlot,
  }) async {
    final docRef = _firestore.collection('places').doc(placeId);

    await docRef.update({
      'subPlaces.$subPlaceIndex.bookedTimeSlots.$day': FieldValue.arrayRemove([
        timeSlot,
      ]),
      'subPlaces.$subPlaceIndex.freeTimeSlots.$day': FieldValue.arrayUnion([
        timeSlot,
      ]),
    });
  }

  Future<void> bookSlots({
    required String placeId,
    required String subPlaceId,
    required Map<String, List<String>> selectedSlots,
    required String userId,
    required String orderId,
  }) async {
    final DocumentReference placeRef = _firestore
        .collection('places')
        .doc(placeId);

    return await _firestore.runTransaction((transaction) async {
      DocumentSnapshot placeSnapshot = await transaction.get(placeRef);

      if (!placeSnapshot.exists) {
        throw Exception('المكان غير موجود!');
      }

      final placeData = placeSnapshot.data() as Map<String, dynamic>;
      List<dynamic> subPlacesData = List.from(placeData['subPlaces'] ?? []);

      final subPlaceIndex = subPlacesData.indexWhere(
        (sp) => sp['id'] == subPlaceId,
      );
      if (subPlaceIndex == -1) {
        throw Exception('الملعب أو القسم غير موجود!');
      }

      final subPlaceData = subPlacesData[subPlaceIndex];

      // --- التعديل هنا: تحويل البيانات للهيكل الجديد ---
      Map<String, List<String>> freeTimeSlots = _parseSlots(
        subPlaceData['freeTimeSlots'],
      );

      // تحويل الـ List القادمة من Firestore لموديلات
      List<BookingIdModel> bookedTimeSlots =
          (subPlaceData['bookedTimeSlots'] as List? ?? [])
              .map(
                (item) => BookingIdModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();

      // التأكد إن كل المواعيد المطلوبة لسه "متاحة"
      for (var entry in selectedSlots.entries) {
        String day = entry.key;
        for (String slot in entry.value) {
          bool isFree = freeTimeSlots[day]?.contains(slot) ?? false;

          // التحقق: هل الساعة دي موجودة في أي حجز قديم؟
          bool isAlreadyBooked = bookedTimeSlots.any(
            (b) => b.slots[day]?.contains(slot) ?? false,
          );

          if (!isFree || isAlreadyBooked) {
            throw Exception(
              'للأسف، الساعة $slot في يوم $day طارت وحجزها حد تاني!',
            );
          }
        }
      }
      final UserModel user =
          await _authService.getUserById(userId) as UserModel;
      // تنفيذ الحجز: نقل المواعيد
      // بنعمل موديل جديد للحجز الحالي
      BookingIdModel newBooking = BookingIdModel(
        bookingId: orderId,
        slots: selectedSlots,
        bookedBy: 'owner',
        bookername: user.username,
      );

      for (var entry in selectedSlots.entries) {
        String day = entry.key;
        for (String slot in entry.value) {
          freeTimeSlots[day]?.remove(slot);
        }
      }

      // إضافة الحجز الجديد للقائمة
      bookedTimeSlots.add(newBooking);

      // تحديث البيانات في Firestore
      subPlacesData[subPlaceIndex]['freeTimeSlots'] = freeTimeSlots;
      // تحويل لستة الموديلات لـ JSON
      subPlacesData[subPlaceIndex]['bookedTimeSlots'] = bookedTimeSlots
          .map((e) => e.toJson())
          .toList();

      transaction.update(placeRef, {'subPlaces': subPlacesData});
    });
  }

  // ميثود مساعدة لتحويل البيانات القادمة من Firestore لشكل Map سليم
  Map<String, List<String>> _parseSlots(dynamic data) {
    if (data == null) return {};
    return (data as Map<String, dynamic>).map(
      (key, value) => MapEntry(key, List<String>.from(value)),
    );
  }

  // 4. إلغاء حجز
  Future<void> deleteBooking(String bookingId) async {
    await _firestore.collection('bookings').doc(bookingId).delete();
  }

  Future<String?> getBookingIdByDetails({
    required String placeId,
    required String subPlaceId,
    required String dayKey,
    required List<String> selectedSlots,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;

      // بنبحث في كولكشن الـ bookings
      // لازم الفلتر يتطابق مع الـ place والـ subPlace
      final querySnapshot = await firestore
          .collection('bookings')
          .where('placeId', isEqualTo: placeId)
          .where('subPlaceId', isEqualTo: subPlaceId)
          .get();

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final Map<String, dynamic> timeSlots = data['timeSlots'] ?? {};

        // بنشوف هل اليوم ده موجود في الحجز ده؟
        if (timeSlots.containsKey(dayKey)) {
          List<dynamic> slotsInDoc = timeSlots[dayKey];

          // بنقارن الساعات اللي اليوزر اختارها بالساعات اللي في الدوكومنت
          // لو الساعات اللي اخترناها هي جزء من الحجز ده أو هي هي
          bool isMatch = selectedSlots.every(
            (slot) => slotsInDoc.contains(slot),
          );

          if (isMatch) {
            return doc.id; // لقينا الـ ID المطلوب
          }
        }
      }
      return null; // ملقيناش حجز متطابق
    } catch (e) {
      debugPrint("Error fetching booking ID: $e");
      return null;
    }
  }

  // inside owner_service.dart

  Future<bool> cancelBookingTransaction({
    required String placeId,
    required int subPlaceIndex,
    required String dayKey,
    required List<String> slotsToCancel,
  }) async {
    try {
      // تحديد وقت أقصى للعملية (15 ثانية) عشان الـ UI ميفضلش معلق لو النت فصل
      return await _firestore
          .runTransaction((transaction) async {
            DocumentReference placeRef = _firestore
                .collection('places')
                .doc(placeId);
            DocumentSnapshot placeDoc = await transaction.get(placeRef);

            if (!placeDoc.exists) return false;

            Map<String, dynamic> placeData =
                placeDoc.data() as Map<String, dynamic>;
            List<dynamic> subPlaces = List.from(placeData['subPlaces']);
            Map<String, dynamic> targetSubPlace = Map.from(
              subPlaces[subPlaceIndex],
            );

            // --- تعديل المتاح (Free Slots) ---
            Map<String, dynamic> freeSlots = Map.from(
              targetSubPlace['freeTimeSlots'] ?? {},
            );
            List<dynamic> currentDayFreeSlots = List.from(
              freeSlots[dayKey] ?? [],
            );

            // نتاكد إننا مش بنضيف ساعات موجودة أصلاً عشان ميبقاش فيه تكرار
            for (var slot in slotsToCancel) {
              if (!currentDayFreeSlots.contains(slot)) {
                currentDayFreeSlots.add(slot);
              }
            }
            freeSlots[dayKey] = currentDayFreeSlots;
            targetSubPlace['freeTimeSlots'] = freeSlots;

            // --- تعديل المحجوز (Booked Slots) والبحث عن المستند ---
            List<dynamic> bookedSlots = List.from(
              targetSubPlace['bookedTimeSlots'] ?? [],
            );
            String? foundBookingId;

            bookedSlots.removeWhere((bookingMap) {
              var slotsInMap = bookingMap['slots']?[dayKey];
              if (slotsInMap is List) {
                bool matches = slotsInMap.any(
                  (slot) => slotsToCancel.contains(slot),
                );
                if (matches) foundBookingId = bookingMap['bookingId'];
                return matches;
              }
              return false;
            });

            targetSubPlace['bookedTimeSlots'] = bookedSlots;
            subPlaces[subPlaceIndex] = targetSubPlace;

            // --- تحديث مستند الحجز الأصلي ---
            if (foundBookingId != null) {
              DocumentReference bookingRef = _firestore
                  .collection('bookings')
                  .doc(foundBookingId!);
              DocumentSnapshot bookingDoc = await transaction.get(bookingRef);

              if (bookingDoc.exists) {
                Map<String, dynamic> bData =
                    bookingDoc.data() as Map<String, dynamic>;
                Map<String, dynamic> timeSlots = Map.from(
                  bData['timeSlots'] ?? {},
                );
                List<dynamic> daySlots = List.from(timeSlots[dayKey] ?? []);

                daySlots.removeWhere((s) => slotsToCancel.contains(s));

                if (daySlots.isEmpty) {
                  timeSlots.remove(dayKey);
                } else {
                  timeSlots[dayKey] = daySlots;
                }

                if (timeSlots.isEmpty) {
                  transaction.delete(bookingRef);
                } else {
                  transaction.update(bookingRef, {'timeSlots': timeSlots});
                }
              }
            }

            // التحديث النهائي للمكان
            transaction.update(placeRef, {'subPlaces': subPlaces});
            return true;
          })
          .timeout(
            const Duration(seconds: 15),
          ); // لو عدى 15 ثانية، ارمي Exception وفك الـ Loading
    } catch (e) {
      print("خطأ في الإلغاء: $e");
      return false;
    }
  }

  Future<void> activateOffer({
    required String placeId,
    required String subPlaceId,
    required Offer offer,
  }) async {
    final docRef = FirebaseFirestore.instance.collection('places').doc(placeId);

    // هنجيب الداتا الحالية عشان نحدث الـ SubPlace المعين جوه اللستة
    final doc = await docRef.get();
    if (doc.exists) {
      List subPlaces = doc.data()?['subPlaces'] ?? [];
      int index = subPlaces.indexWhere((s) => s['id'] == subPlaceId);

      if (index != -1) {
        // تحديث حقل العرض و الـ isOffer
        subPlaces[index]['offer'] = offer.toJson();
        subPlaces[index]['isOffer'] = true;

        await docRef.update({'subPlaces': subPlaces});
      }
    }
  }

  Future<List<PlaceModel>> getAllPlaces() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('places')
        .get();
    return snapshot.docs.map((doc) => PlaceModel.fromJson(doc.data())).toList();
  }

  Future<void> addBooking(BookingModel booking) async {
    try {
      await _firestore
          .collection('bookings')
          .doc(booking.id)
          .set(booking.toJson());
    } catch (e) {
      debugPrint('Error adding bossoking: $e');
      rethrow;
    }
  }

  Future<String?> getUserIdByPhoneNumber(String phoneNumber) async {
    try {
      // بنعمل Query على كولكشن الـ users وبندور على الحقل اللي فيه رقم التليفون
      final querySnapshot = await _firestore
          .collection('users')
          .where(
            'phoneNumber',
            isEqualTo: phoneNumber,
          ) // تأكد إن اسم الحقل في فيربيز 'phone'
          .limit(1) // بنكتفي بأول نتيجة تطلع
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // بنرجع الـ Document ID اللي هو الـ UID بتاع المستخدم
        return querySnapshot.docs.first.id;
      } else {
        // لو مفيش مستخدم بالرقم ده
        return null;
      }
    } catch (e) {
      // في حالة حدوث خطأ في الاتصال أو غيره
      debugPrint("Error fetching userId: $e");
      return null;
    }
  }

  // ميثود بتراقب مكان واحد فقط لحظة بلحظة
  Stream<PlaceModel> listenToPlaceById(String placeId) {
    return _firestore
        .collection('places')
        .doc(placeId)
        .snapshots()
        .map((doc) => PlaceModel.fromJson(doc.data() as Map<String, dynamic>));
  }

  Future<DashboardStats> calculateDashboardStats(String placeId) async {
    final snapshot = await _firestore
        .collection('bookings')
        .where('placeId', isEqualTo: placeId)
        .get();

    double appRevenue = 0;
    double manualRevenue = 0;
    int appCount = 0;
    int manualCount = 0;
    int totalHours = 0;

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final String bookedBy = data['bookedBy'] ?? 'user';
      final double totalPrice = (data['totalPrice'] ?? 0).toDouble();

      // حساب الساعات من الـ timeSlots Map
      final Map<String, dynamic> timeSlots = data['timeSlots'] ?? {};
      int hoursInThisBooking = 0;
      timeSlots.forEach((key, value) {
        if (value is List) hoursInThisBooking += value.length;
      });

      totalHours += hoursInThisBooking;

      if (bookedBy == 'owner') {
        manualCount++;
        manualRevenue += totalPrice;
      } else {
        appCount++;
        appRevenue += totalPrice;
      }
    }

    return DashboardStats(
      totalAppRevenue: appRevenue,
      totalManualRevenue: manualRevenue,
      appReservationsCount: appCount,
      manualReservationsCount: manualCount,
      totalBookedHours: totalHours,
    );
  }
}
