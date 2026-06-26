import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hanzbthalk/core/db/auth_service.dart';
import 'package:hanzbthalk/core/models/booking_id_model.dart';
import 'package:hanzbthalk/core/models/booking_model.dart';
import 'package:hanzbthalk/core/models/dashboard_states_model.dart';
import 'package:hanzbthalk/core/models/offer_model.dart';
import 'package:hanzbthalk/core/models/place_model.dart';
import 'package:path/path.dart' as p;
import 'package:hanzbthalk/core/errors/exceptions.dart';
import 'package:hanzbthalk/core/models/user_model.dart';

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
    final user = await _authService.getCurrentUser();
    if (user == null) return [];

    final String ownerId = user.userRole == 'employee' ? (user.ownerId ?? '') : user.id;

    Query query = _firestore
        .collection('places')
        .where('ownerId', isEqualTo: ownerId);

    if (user.userRole == 'employee') {
      if (user.assignedPlaceIds.isEmpty) return [];
      query = query.where('id', whereIn: user.assignedPlaceIds);
    }

    QuerySnapshot querySnapshot = await query.get();

    return querySnapshot.docs
        .map((doc) => PlaceModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // 🌟 [تعديل] حذف مكان بكل صوره وملاعبه ومواعيده من الهيكلة الجديدة
  Future<void> deletePlaceWithImages({
    required String placeId,
    required String ownerId,
  }) async {
    final placeDocRef = _firestore.collection('places').doc(placeId);
    final placeSnapshot = await placeDocRef.get();
    if (!placeSnapshot.exists) return;

    final data = placeSnapshot.data() as Map<String, dynamic>;
    final List<String> allImageUrls = [];

    // جمع صور المكان الأساسي
    final dynamic imagesField = data['images'];
    if (imagesField is List) {
      for (final item in imagesField) {
        if (item is String && item.isNotEmpty) allImageUrls.add(item);
      }
    }

    final batch = _firestore.batch();
    final List<dynamic> subPlacesIds = data['subPlacesIds'] ?? [];

    // جلب الملاعب الفرعية لجمع صورها ومسح المواعيد المرتبطة
    for (String subId in subPlacesIds) {
      final subSnap = await _firestore.collection('subplaces').doc(subId).get();
      if (subSnap.exists) {
        final subData = subSnap.data() as Map<String, dynamic>;

        final img = subData['imageUrl'];
        if (img is String && img.isNotEmpty) allImageUrls.add(img);

        final List<dynamic> slotsIds = subData['slotsIds'] ?? [];
        for (String slotId in slotsIds) {
          batch.delete(_firestore.collection('slots').doc(slotId));
        }
        batch.delete(subSnap.reference);
      }
    }

    batch.delete(placeDocRef);
    await batch.commit();

    // حذف الصور من Storage
    for (final url in allImageUrls) {
      if (url.startsWith('http')) {
        try {
          await _storage.refFromURL(url).delete();
        } catch (_) {}
      }
    }
  }

  // 🌟 [تعديل] تحديث الملاعب الفرعية من الكولكشن المباشر بتاعها
  Future<void> updateSubPlaceDetails(
    String placeId,
    String subPlaceId,
    Map<String, dynamic> details,
  ) async {
    await _firestore.collection('subplaces').doc(subPlaceId).update(details);
  }

  // 🌟 [تعديل] تفعيل العرض على الملعب من الكولكشن المباشر
  Future<void> activateOffer({
    required String placeId,
    required String subPlaceId,
    required OfferModel offer,
  }) async {
    await _firestore.collection('subplaces').doc(subPlaceId).update({
      'offer': offer.toJson(),
      'isOffer': true,
    });
  }

  static downscaleImage(File imageFile) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final String targetPath = p.join(
        tempDir.path,
        "compressed_${DateTime.now().millisecondsSinceEpoch}.jpg",
      );

      var result = await FlutterImageCompress.compressAndGetFile(
        imageFile.path,
        targetPath,
        quality: 70,
        minWidth: 800,
        minHeight: 800,
        format: CompressFormat.jpeg,
      );
      return result;
    } catch (e) {
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
      UploadTask uploadTask = storageRef.putFile(fileToUpload);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint("Error during upload: $e");
      return null;
    }
  }

  Stream<List<PlaceModel>> getOwnerPlaces() async* {
    final user = await _authService.getCurrentUser();
    if (user == null) {
      yield [];
      return;
    }

    final String ownerId = user.userRole == 'employee' ? (user.ownerId ?? '') : user.id;

    Query query = _firestore
        .collection('places')
        .where('ownerId', isEqualTo: ownerId);

    if (user.userRole == 'employee') {
      if (user.assignedPlaceIds.isEmpty) {
        yield [];
        return;
      }
      query = query.where(FieldPath.documentId, whereIn: user.assignedPlaceIds);
    }

    yield* query.snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => PlaceModel.fromJson(doc.data() as Map<String, dynamic>))
              .toList(),
        );
  }

  Future<Map<String, dynamic>> getPlaceAnalysis(String placeId) async {
    final querySnapshot = await _firestore
        .collection('bookings')
        .where('placeId', isEqualTo: placeId)
        .where('status', isEqualTo: 'confirmed')
        .get();

    double totalRevenue = 0;
    int totalBookings = querySnapshot.docs.length;

    for (var doc in querySnapshot.docs) {
      totalRevenue += (doc.data()['price'] ?? 0).toDouble();
    }
    return {'revenue': totalRevenue, 'bookingsCount': totalBookings};
  }

  // 🌟 [تعديل] حجز المواعيد على الهيكلة الجديدة (Root Collections)
  Future<void> bookSlots({
    required String placeId,
    required String subPlaceId,
    required Map<String, List<String>> selectedSlots,
    required String userId,
    required String orderId,
  }) async {
    final String? currentUserId = await _authService.getCurrentUserId();
    debugPrint('📅 [bookSlots] START — placeId=$placeId subPlaceId=$subPlaceId userId=$userId orderId=$orderId currentUserId=$currentUserId');
    debugPrint('📅 [bookSlots] selectedSlots=$selectedSlots');

    // 1. هنجيب الـ SubPlace الأول عشان نعرف الـ Slot ID بتاعه
    final subPlaceDoc = await _firestore
        .collection('subplaces')
        .doc(subPlaceId)
        .get();

    if (!subPlaceDoc.exists) {
      debugPrint('❌ [bookSlots] SubPlace not found: $subPlaceId');
      throw const SubPlaceNotFoundException('subplace_not_found');
    }

    final List<dynamic> slotsIds = subPlaceDoc.data()?['slotsIds'] ?? [];
    debugPrint('📅 [bookSlots] slotsIds=$slotsIds');
    if (slotsIds.isEmpty) throw Exception('no_schedule_available');

    final String slotId = slotsIds.first.toString();
    final DocumentReference slotsRef = _firestore
        .collection('slots')
        .doc(slotId);
    debugPrint('📅 [bookSlots] Using slotId=$slotId');

    // ▶ جلب اسم الحاجز (null-safe: لو مش موجود نستخدم 'Guest')
    String bookerName = 'Guest';
    if (userId != 'guest_user' && userId != 'unknown_user') {
      try {
        final UserModel? userModel = await _authService.getUserById(userId);
        if (userModel != null) {
          bookerName = userModel.username;
          debugPrint('📅 [bookSlots] Booker name fetched: $bookerName');
        } else {
          debugPrint('⚠️ [bookSlots] getUserById returned null for userId=$userId — using Guest');
        }
      } catch (e) {
        debugPrint('⚠️ [bookSlots] Error fetching user name: $e — using Guest');
      }
    } else {
      debugPrint('⚠️ [bookSlots] userId is guest/unknown — skipping user lookup, using Guest');
    }

    return await _firestore.runTransaction((transaction) async {
      DocumentSnapshot slotsSnapshot = await transaction.get(slotsRef);

      if (!slotsSnapshot.exists) throw Exception('schedule_not_found');

      final slotsData = slotsSnapshot.data() as Map<String, dynamic>;
      Map<String, List<String>> freeTimeSlots = _parseSlots(
        slotsData['freeTimeSlots'],
      );
      List<BookingIdModel> bookedTimeSlots =
          (slotsData['bookedTimeSlots'] as List? ?? [])
              .map(
                (item) => BookingIdModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();

      debugPrint('📅 [bookSlots] freeTimeSlots keys: ${freeTimeSlots.keys.toList()}');

      final Map<String, dynamic> lockedSlots = Map.from(slotsData['lockedSlots'] ?? {});
      final now = DateTime.now();

      // التأكد إن كل المواعيد لسه "متاحة" وغير محجوزة مؤقتاً لمستخدم آخر
      for (var entry in selectedSlots.entries) {
        String day = entry.key;
        for (String slot in entry.value) {
          bool isFree = freeTimeSlots[day]?.contains(slot) ?? false;
          bool isAlreadyBooked = bookedTimeSlots.any(
            (b) => b.slots[day]?.contains(slot) ?? false,
          );

          // التحقق من أن الساعة غير محجوزة مؤقتاً من قبل شخص آخر
          final String slotId = '${day}_$slot';
          bool isLockedByOther = false;
          if (lockedSlots.containsKey(slotId)) {
            final lockInfo = Map<String, dynamic>.from(lockedSlots[slotId]);
            final expiresAt = lockInfo['expiresAt'] as Timestamp;
            final lockUserId = lockInfo['userId'] as String;

            if (lockUserId != userId && lockUserId != currentUserId && expiresAt.toDate().isAfter(now)) {
              isLockedByOther = true;
            }
          }

          debugPrint('📅 [bookSlots] Checking slot=$slot day=$day isFree=$isFree isAlreadyBooked=$isAlreadyBooked isLockedByOther=$isLockedByOther');

          if (!isFree || isAlreadyBooked || isLockedByOther) {
            debugPrint('❌ [bookSlots] Slot conflict: slot=$slot day=$day');
            throw const SlotAlreadyBookedException('msg_already_booked');
          }
        }
      }

      BookingIdModel newBooking = BookingIdModel(
        bookingId: orderId,
        slots: selectedSlots,
        bookedBy: 'owner',
        bookername: bookerName,
      );

      // سحب الساعات من الـ Free وإضافتها للـ Booked ومسح الأقفال الخاصة بها
      for (var entry in selectedSlots.entries) {
        String day = entry.key;
        for (String slot in entry.value) {
          freeTimeSlots[day]?.remove(slot);
          
          final String slotId = '${day}_$slot';
          lockedSlots.remove(slotId);
        }
      }
      bookedTimeSlots.add(newBooking);

      // 2. تحديث جدول المواعيد المباشر
      transaction.update(slotsRef, {
        'freeTimeSlots': freeTimeSlots,
        'bookedTimeSlots': bookedTimeSlots.map((e) => e.toJson()).toList(),
        'lockedSlots': lockedSlots,
      });
      debugPrint('✅ [bookSlots] Transaction committed successfully');
    });
  }

  Map<String, List<String>> _parseSlots(dynamic data) {
    if (data == null) return {};
    return (data as Map<String, dynamic>).map(
      (key, value) => MapEntry(key, List<String>.from(value)),
    );
  }

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
      final querySnapshot = await _firestore
          .collection('bookings')
          .where('placeId', isEqualTo: placeId)
          .where('subPlaceId', isEqualTo: subPlaceId)
          .get();

      for (var doc in querySnapshot.docs) {
        // 🌟 التعديل هنا
        final data = doc.data() as Map<String, dynamic>;
        final Map<String, dynamic> timeSlots = data['timeSlots'] ?? {};

        if (timeSlots.containsKey(dayKey)) {
          List<dynamic> slotsInDoc = timeSlots[dayKey];
          bool isMatch = selectedSlots.every(
            (slot) => slotsInDoc.contains(slot),
          );
          if (isMatch) return doc.id;
        }
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching booking ID: $e");
      return null;
    }
  }

  // 🌟 [تعديل] عملية الإلغاء الشاملة على الهيكلة الجديدة
  Future<bool> cancelBookingTransaction({
    required String placeId,
    required int subPlaceIndex,
    required String dayKey,
    required List<String> slotsToCancel,
  }) async {
    try {
      return await _firestore
          .runTransaction((transaction) async {
            // 1. الحصول على IDs الملعب والمواعيد
            final String? subPlaceId = await _getSubPlaceId(
              transaction,
              placeId,
              subPlaceIndex,
            );
            if (subPlaceId == null) return false;

            final String? slotId = await _getSlotId(transaction, subPlaceId);
            if (slotId == null) return false;

            // 2. جلب بيانات المواعيد الحالية
            final DocumentReference slotsRef = _firestore
                .collection('slots')
                .doc(slotId);
            final DocumentSnapshot slotsDoc = await transaction.get(slotsRef);
            if (!slotsDoc.exists) return false;

            final slotsData = slotsDoc.data() as Map<String, dynamic>;

            // 3. تعديل المواعيد (إرجاع للـ Free ومسح من الـ Booked)
            final updatedFreeSlots = _restoreFreeSlots(
              slotsData,
              dayKey,
              slotsToCancel,
            );
            final bookingUpdateResult = _removeBookedSlotsAndGetBookingId(
              slotsData,
              dayKey,
              slotsToCancel,
            );

            final updatedBookedSlots =
                bookingUpdateResult['updatedBookedSlots'] as List<dynamic>;
            final String? foundBookingId =
                bookingUpdateResult['foundBookingId'] as String?;

            // 4. تحديث مستند الحجز الأصلي (لو موجود)
            if (foundBookingId != null) {
              await _updateOrDeleteOriginalBooking(
                transaction,
                foundBookingId,
                dayKey,
                slotsToCancel,
              );
            }

            // 5. التحديث النهائي للمواعيد في الـ Root Collection
            transaction.update(slotsRef, {
              'freeTimeSlots': updatedFreeSlots,
              'bookedTimeSlots': updatedBookedSlots,
            });

            return true;
          })
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      debugPrint("Cancel Transaction Error: $e");
      return false;
    }
  }

  // --- Helper 1: جلب ID الملعب الفرعي ---
  Future<String?> _getSubPlaceId(
    Transaction transaction,
    String placeId,
    int subPlaceIndex,
  ) async {
    DocumentReference placeRef = _firestore.collection('places').doc(placeId);
    DocumentSnapshot placeDoc = await transaction.get(placeRef);
    if (!placeDoc.exists) return null;

    final placeData = placeDoc.data() as Map<String, dynamic>;
    List<dynamic> subPlacesIds = placeData['subPlacesIds'] ?? [];

    if (subPlaceIndex >= subPlacesIds.length) return null;
    return subPlacesIds[subPlaceIndex].toString();
  }

  // --- Helper 2: جلب ID المواعيد الخاصة بالملعب ---
  Future<String?> _getSlotId(Transaction transaction, String subPlaceId) async {
    DocumentReference subPlaceRef = _firestore
        .collection('subplaces')
        .doc(subPlaceId);
    DocumentSnapshot subPlaceDoc = await transaction.get(subPlaceRef);
    if (!subPlaceDoc.exists) return null;

    final subPlaceData = subPlaceDoc.data() as Map<String, dynamic>;
    List<dynamic> slotsIds = subPlaceData['slotsIds'] ?? [];

    if (slotsIds.isEmpty) return null;
    return slotsIds.first.toString();
  }

  // --- Helper 3: إرجاع الساعات الملغية لقائمة المتاح ---
  Map<String, dynamic> _restoreFreeSlots(
    Map<String, dynamic> slotsData,
    String dayKey,
    List<String> slotsToCancel,
  ) {
    Map<String, dynamic> freeSlots = Map.from(slotsData['freeTimeSlots'] ?? {});
    List<dynamic> currentDayFreeSlots = List.from(freeSlots[dayKey] ?? []);

    for (var slot in slotsToCancel) {
      if (!currentDayFreeSlots.contains(slot)) {
        currentDayFreeSlots.add(slot);
      }
    }
    freeSlots[dayKey] = currentDayFreeSlots;
    return freeSlots;
  }

  // --- Helper 4: مسح الساعات المحجوزة واستخراج ID الحجز الأصلي ---
  Map<String, dynamic> _removeBookedSlotsAndGetBookingId(
    Map<String, dynamic> slotsData,
    String dayKey,
    List<String> slotsToCancel,
  ) {
    List<dynamic> bookedSlots = List.from(slotsData['bookedTimeSlots'] ?? []);
    String? foundBookingId;

    bookedSlots.removeWhere((bookingMap) {
      var slotsInMap = bookingMap['slots']?[dayKey];
      if (slotsInMap is List) {
        bool matches = slotsInMap.any((slot) => slotsToCancel.contains(slot));
        if (matches) foundBookingId = bookingMap['bookingId'];
        return matches;
      }
      return false;
    });

    return {
      'updatedBookedSlots': bookedSlots,
      'foundBookingId': foundBookingId,
    };
  }

  // --- Helper 5: تحديث أو حذف وثيقة الحجز من جدول الحجوزات ---
  Future<void> _updateOrDeleteOriginalBooking(
    Transaction transaction,
    String bookingId,
    String dayKey,
    List<String> slotsToCancel,
  ) async {
    DocumentReference bookingRef = _firestore
        .collection('bookings')
        .doc(bookingId);
    DocumentSnapshot bookingDoc = await transaction.get(bookingRef);

    if (bookingDoc.exists) {
      Map<String, dynamic> bData = bookingDoc.data() as Map<String, dynamic>;
      Map<String, dynamic> timeSlots = Map.from(bData['timeSlots'] ?? {});
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
      rethrow;
    }
  }

  Future<String?> getUserIdByPhoneNumber(String phoneNumber) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) return querySnapshot.docs.first.id;
      return null;
    } catch (e) {
      debugPrint("Error fetching userId: $e");
      return null;
    }
  }

  Stream<PlaceModel> listenToPlaceById(String placeId) {
    return _firestore
        .collection('places')
        .doc(placeId)
        .snapshots()
        .map((doc) => PlaceModel.fromJson(doc.data() as Map<String, dynamic>));
  }

  // (باقي دوال الإحصائيات DashboardStats كما هي، لأنها بتعتمد على كولكشن Bookings ومفيهاش تغييرات للهيكلة)
  // ...
  Stream<DashboardStats> getDashboardStatsStream({
    required String placeId,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final String startStr =
        "${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}T00:00:00.000";
    final String endStr =
        "${endDate.year.toString().padLeft(4, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}T23:59:59.999";

    return _firestore
        .collection('bookings')
        .where('placeId', isEqualTo: placeId)
        .where('createdAt', isGreaterThanOrEqualTo: startStr)
        .where('createdAt', isLessThanOrEqualTo: endStr)
        .snapshots()
        .map((snapshot) => _calculateStatsFromSnapshot(snapshot));
  }

  Stream<DashboardStats> getAllPlacesStatsStream({
    required String ownerId,
    required DateTime startDate,
    required DateTime endDate,
  }) async* {
    final user = await _authService.getCurrentUser();
    if (user == null) {
      yield DashboardStats(
        totalAppRevenue: 0,
        totalManualRevenue: 0,
        totalAppDeposits: 0,
        appHours: 0,
        manualHours: 0,
        appCount: 0,
        manualCount: 0,
      );
      return;
    }

    final String startStr = _formatDateForQuery(startDate, isEnd: false);
    final String endStr = _formatDateForQuery(endDate, isEnd: true);

    Query query = _firestore
        .collection('bookings')
        .where('ownerId', isEqualTo: ownerId)
        .where('bookingDate', isGreaterThanOrEqualTo: startStr)
        .where('bookingDate', isLessThanOrEqualTo: endStr);

    if (user.userRole == 'employee') {
      if (user.assignedPlaceIds.isEmpty) {
        yield DashboardStats(
          totalAppRevenue: 0,
          totalManualRevenue: 0,
          totalAppDeposits: 0,
          appHours: 0,
          manualHours: 0,
          appCount: 0,
          manualCount: 0,
        );
        return;
      }
      query = query.where('placeId', whereIn: user.assignedPlaceIds);
    }

    yield* query.snapshots().map((snapshot) => _calculateStatsFromSnapshot(snapshot));
  }

  String _formatDateForQuery(DateTime date, {required bool isEnd}) {
    if (isEnd)
      return "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}T23:59:59.999";
    return "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}T00:00:00.000";
  }

  DashboardStats _calculateStatsFromSnapshot(QuerySnapshot snapshot) {
    double appRevenue = 0, manualRevenue = 0, appDeposits = 0;
    int appCount = 0, manualCount = 0, appHours = 0, manualHours = 0;

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final String bookedBy = (data['bookedBy'] ?? 'user')
          .toString()
          .toLowerCase();
      final double totalP = (data['totalPrice'] ?? 0).toDouble();
      final double paidAmt = (data['paidAmount'] ?? 0).toDouble();
      final bool isCash = data['isCash'] ?? false;

      int hoursInThisDoc = 0;
      if (data['timeSlots'] != null && data['timeSlots'] is Map) {
        final Map<String, dynamic> slots = data['timeSlots'];
        slots.forEach((day, times) {
          if (times is List) hoursInThisDoc += times.length;
        });
      }

      if (bookedBy == 'owner') {
        manualCount++;
        manualRevenue += totalP;
        manualHours += hoursInThisDoc;
      } else {
        appCount++;
        appRevenue += totalP;
        appHours += hoursInThisDoc;
        if (!isCash) appDeposits += paidAmt;
      }
    }

    return DashboardStats(
      totalAppRevenue: appRevenue,
      totalManualRevenue: manualRevenue,
      totalAppDeposits: appDeposits,
      appHours: appHours,
      manualHours: manualHours,
      appCount: appCount,
      manualCount: manualCount,
    );
  }

  Future<List<UserModel>> searchUsersByPhone(String phone) async {
    final querySnapshot = await _firestore
        .collection('users')
        .where('phoneNumber', isGreaterThanOrEqualTo: phone)
        .where('phoneNumber', isLessThanOrEqualTo: '$phone\uf8ff')
        .get();

    return querySnapshot.docs
        .map((doc) => UserModel.fromJson(doc.data() as Map<String, dynamic>))
        .where((user) => user.userRole == 'user')
        .toList();
  }

  Future<List<UserModel>> getEmployeesByOwner(String ownerId) async {
    final querySnapshot = await _firestore
        .collection('users')
        .where('ownerId', isEqualTo: ownerId)
        .where('userRole', isEqualTo: 'employee')
        .get();

    return querySnapshot.docs
        .map((doc) => UserModel.fromJson(doc.data()))
        .toList();
  }

  Future<void> updateEmployeeDetails({
    required String employeeId,
    required String? ownerId,
    required String role,
    required List<String> assignedPlaceIds,
    required Map<String, bool> permissions,
  }) async {
    await _firestore.collection('users').doc(employeeId).update({
      'userRole': role,
      'ownerId': ownerId,
      'assignedPlaceIds': assignedPlaceIds,
      'permissions': permissions,
    });

    final roleDocRef = _firestore.collection('roles').doc(employeeId);
    await roleDocRef.set({
      'role': role,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
