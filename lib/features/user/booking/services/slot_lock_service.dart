import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class SlotLockService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Tries to lock a single slot for [durationMinutes] for [userId].
  /// Returns true if lock was successfully acquired or renewed, false otherwise.
  Future<bool> tryLockSlot({
    required String subPlaceId,
    required String slotId,
    required String userId,
    required int durationMinutes,
  }) async {
    final DocumentReference docRef = _firestore.collection('slots').doc(subPlaceId);

    try {
      return await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) {
          debugPrint("❌ SlotLockService: Slots document not found for ID: $subPlaceId");
          return false;
        }

        final data = snapshot.data() as Map<String, dynamic>;
        final lockedSlots = Map<String, dynamic>.from(data['lockedSlots'] ?? {});

        // Check if the slot is currently locked
        if (lockedSlots.containsKey(slotId)) {
          final lockInfo = Map<String, dynamic>.from(lockedSlots[slotId]);
          final expiresAt = lockInfo['expiresAt'] as Timestamp;
          final lockUserId = lockInfo['userId'] as String;

          // If locked by another user and the lock is still active (in the future)
          if (lockUserId != userId && expiresAt.toDate().isAfter(DateTime.now())) {
            debugPrint("⚠️ SlotLockService: Slot $slotId is already locked by another user ($lockUserId)");
            return false;
          }
        }

        // Lock is either free, expired, or belongs to the same user.
        // Update/acquire the lock for the specified duration.
        final lockExpiry = DateTime.now().add(Duration(minutes: durationMinutes));
        lockedSlots[slotId] = {
          'userId': userId,
          'expiresAt': Timestamp.fromDate(lockExpiry),
        };

        transaction.update(docRef, {'lockedSlots': lockedSlots});
        debugPrint("✅ SlotLockService: Successfully locked slot $slotId for user $userId for $durationMinutes mins");
        return true;
      });
    } catch (e) {
      debugPrint("❌ SlotLockService: Exception in tryLockSlot: $e");
      return false;
    }
  }

  /// Tries to lock/extend multiple slots for [durationMinutes] for [userId].
  /// Returns true if all slots were successfully locked/extended, false otherwise.
  Future<bool> tryLockSlots({
    required String subPlaceId,
    required List<String> slotIds,
    required String userId,
    required int durationMinutes,
  }) async {
    if (slotIds.isEmpty) return true;
    final DocumentReference docRef = _firestore.collection('slots').doc(subPlaceId);

    try {
      return await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) {
          debugPrint("❌ SlotLockService: Slots document not found for ID: $subPlaceId");
          return false;
        }

        final data = snapshot.data() as Map<String, dynamic>;
        final lockedSlots = Map<String, dynamic>.from(data['lockedSlots'] ?? {});
        final now = DateTime.now();

        // 1. Validate that ALL slots can be locked (none are locked by others with active locks)
        for (final slotId in slotIds) {
          if (lockedSlots.containsKey(slotId)) {
            final lockInfo = Map<String, dynamic>.from(lockedSlots[slotId]);
            final expiresAt = lockInfo['expiresAt'] as Timestamp;
            final lockUserId = lockInfo['userId'] as String;

            if (lockUserId != userId && expiresAt.toDate().isAfter(now)) {
              debugPrint("⚠️ SlotLockService: Multi-lock failed. Slot $slotId is actively locked by $lockUserId");
              return false;
            }
          }
        }

        // 2. All slots are clear to lock. Perform atomic updates for all.
        final lockExpiry = now.add(Duration(minutes: durationMinutes));
        for (final slotId in slotIds) {
          lockedSlots[slotId] = {
            'userId': userId,
            'expiresAt': Timestamp.fromDate(lockExpiry),
          };
        }

        transaction.update(docRef, {'lockedSlots': lockedSlots});
        debugPrint("✅ SlotLockService: Locked ${slotIds.length} slots for user $userId for $durationMinutes mins");
        return true;
      });
    } catch (e) {
      debugPrint("❌ SlotLockService: Exception in tryLockSlots: $e");
      return false;
    }
  }

  /// Releases a lock on a single slot if locked by the current user.
  Future<void> releaseLockSlot({
    required String subPlaceId,
    required String slotId,
    required String userId,
  }) async {
    final DocumentReference docRef = _firestore.collection('slots').doc(subPlaceId);

    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return;

        final data = snapshot.data() as Map<String, dynamic>;
        final lockedSlots = Map<String, dynamic>.from(data['lockedSlots'] ?? {});

        if (lockedSlots.containsKey(slotId)) {
          final lockInfo = Map<String, dynamic>.from(lockedSlots[slotId]);
          final lockUserId = lockInfo['userId'] as String;

          // Only release if the lock belongs to this user
          if (lockUserId == userId) {
            lockedSlots.remove(slotId);
            transaction.update(docRef, {'lockedSlots': lockedSlots});
            debugPrint("🔓 SlotLockService: Released lock on slot $slotId for user $userId");
          }
        }
      });
    } catch (e) {
      debugPrint("❌ SlotLockService: Exception in releaseLockSlot: $e");
    }
  }

  /// Releases locks on multiple slots for this user.
  Future<void> releaseLocks({
    required String subPlaceId,
    required List<String> slotIds,
    required String userId,
  }) async {
    if (slotIds.isEmpty) return;
    final DocumentReference docRef = _firestore.collection('slots').doc(subPlaceId);

    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return;

        final data = snapshot.data() as Map<String, dynamic>;
        final lockedSlots = Map<String, dynamic>.from(data['lockedSlots'] ?? {});
        bool modified = false;

        for (final slotId in slotIds) {
          if (lockedSlots.containsKey(slotId)) {
            final lockInfo = Map<String, dynamic>.from(lockedSlots[slotId]);
            final lockUserId = lockInfo['userId'] as String;

            if (lockUserId == userId) {
              lockedSlots.remove(slotId);
              modified = true;
            }
          }
        }

        if (modified) {
          transaction.update(docRef, {'lockedSlots': lockedSlots});
          debugPrint("🔓 SlotLockService: Released ${slotIds.length} locks for user $userId");
        }
      });
    } catch (e) {
      debugPrint("❌ SlotLockService: Exception in releaseLocks: $e");
    }
  }
}
