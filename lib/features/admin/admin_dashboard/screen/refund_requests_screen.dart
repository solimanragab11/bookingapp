import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/core/widgets/background.dart';
import 'package:hanzbthalk/core/widgets/snackbar_utils.dart';
import 'package:intl/intl.dart';

class RefundRequestsScreen extends StatefulWidget {
  const RefundRequestsScreen({super.key});

  @override
  State<RefundRequestsScreen> createState() => _RefundRequestsScreenState();
}

class _RefundRequestsScreenState extends State<RefundRequestsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _updateRequestStatus(String docId, String status) async {
    try {
      await _firestore.collection('refund_requests').doc(docId).update({
        'status': status,
        'processedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        SnackBarUtils.showSuccess(context, 'status_updated_successfully');
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtils.showError(context, 'Failed to update status: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          BackGround(h: size.height, w: size.width),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildRequestsList(isPendingOnly: true),
                      _buildRequestsList(isPendingOnly: false),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 10),
          Text(
            context.tr('refund_requests_title', defaultValue: 'Refund Requests'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: ColorManager.egyptianEarth,
          borderRadius: BorderRadius.circular(15),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60,
        tabs: [
          Tab(text: context.tr('pending', defaultValue: 'Pending')),
          Tab(text: context.tr('all_requests', defaultValue: 'All Requests')),
        ],
      ),
    );
  }

  Widget _buildRequestsList({required bool isPendingOnly}) {
    Query query = _firestore.collection('refund_requests').orderBy('createdAt', descending: true);
    if (isPendingOnly) {
      query = query.where('status', isEqualTo: 'pending');
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: ColorManager.wasabi));
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.redAccent),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Center(
            child: Text(
              context.tr('no_refund_requests', defaultValue: 'No refund requests found.'),
              style: const TextStyle(color: Colors.white54, fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          itemCount: docs.length,
          padding: const EdgeInsets.all(20),
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            return _buildRequestCard(doc.id, data);
          },
        );
      },
    );
  }

  Widget _buildRequestCard(String docId, Map<String, dynamic> data) {
    final status = data['status'] ?? 'pending';
    final amountPaid = (data['amountPaidOnline'] ?? 0.0).toDouble();
    final refundAmount = (data['expectedRefund'] ?? 0.0).toDouble();
    final timeSlots = data['timeSlots'] as Map<dynamic, dynamic>? ?? {};

    // Format Timestamp
    String dateStr = '';
    if (data['createdAt'] != null && data['createdAt'] is Timestamp) {
      final dateTime = (data['createdAt'] as Timestamp).toDate();
      dateStr = DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: ColorManager.cardSurface.withOpacity(0.35),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: status == 'pending'
              ? Colors.orangeAccent.withOpacity(0.25)
              : status == 'approved'
                  ? ColorManager.emeraldGreen.withOpacity(0.25)
                  : Colors.redAccent.withOpacity(0.25),
          width: 1.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'ID: ${docId.substring(0, 8).toUpperCase()}',
                        style: const TextStyle(color: Colors.white54, fontSize: 12, fontFamily: 'Roboto'),
                      ),
                    ),
                    _buildStatusBadge(status),
                  ],
                ),
                const Divider(color: Colors.white12, height: 20),
                FutureBuilder<DocumentSnapshot>(
                  future: _firestore.collection('users').doc(data['userId']).get(),
                  builder: (context, userSnapshot) {
                    String username = 'Loading...';
                    String phone = '';
                    if (userSnapshot.hasData && userSnapshot.data?.exists == true) {
                      final uData = userSnapshot.data?.data() as Map<String, dynamic>?;
                      if (uData != null) {
                        username = uData['username'] ?? 'N/A';
                        phone = uData['phoneNumber'] ?? '';
                      }
                    } else if (userSnapshot.hasError) {
                      username = 'Error loading user';
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow(Icons.person, context.tr('username', defaultValue: 'User'), username),
                        if (phone.isNotEmpty)
                          _buildDetailRow(Icons.phone, context.tr('phoneNumber', defaultValue: 'Phone'), phone),
                      ],
                    );
                  },
                ),
                FutureBuilder<DocumentSnapshot>(
                  future: _firestore.collection('subplaces').doc(data['subPlaceId']).get(),
                  builder: (context, subSnapshot) {
                    String subName = 'Loading...';
                    if (subSnapshot.hasData && subSnapshot.data?.exists == true) {
                      final sData = subSnapshot.data?.data() as Map<String, dynamic>?;
                      subName = sData?['name'] ?? data['subPlaceId'] ?? 'N/A';
                    }
                    return _buildDetailRow(Icons.business, context.tr('place', defaultValue: 'Field'), subName);
                  },
                ),
                if (timeSlots.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: ColorManager.egyptianEarth),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${timeSlots.keys.first}: ${timeSlots.values.first.join(', ')}',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
                if (dateStr.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _buildDetailRow(Icons.access_time, context.tr('requested_at', defaultValue: 'Requested At'), dateStr),
                ],
                const Divider(color: Colors.white12, height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${context.tr('paid', defaultValue: 'Paid')}: ${amountPaid.toStringAsFixed(0)} EGP',
                          style: const TextStyle(color: Colors.white60, fontSize: 11),
                        ),
                        Text(
                          '${context.tr('expectedRefund', defaultValue: 'Refund')}: ${refundAmount.toStringAsFixed(0)} EGP',
                          style: const TextStyle(color: ColorManager.wasabi, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    if (status == 'pending')
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent),
                            tooltip: context.tr('reject', defaultValue: 'Reject'),
                            onPressed: () => _updateRequestStatus(docId, 'rejected'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorManager.emeraldGreen,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            onPressed: () => _updateRequestStatus(docId, 'approved'),
                            child: Text(
                              context.tr('approve', defaultValue: 'Approve'),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 14, color: ColorManager.egyptianEarth),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(color: Colors.white60, fontSize: 12)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;

    switch (status) {
      case 'approved':
        color = ColorManager.emeraldGreen;
        text = context.tr('approved', defaultValue: 'Approved');
        break;
      case 'rejected':
        color = Colors.redAccent;
        text = context.tr('rejected', defaultValue: 'Rejected');
        break;
      default:
        color = Colors.orangeAccent;
        text = context.tr('pending', defaultValue: 'Pending');
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
