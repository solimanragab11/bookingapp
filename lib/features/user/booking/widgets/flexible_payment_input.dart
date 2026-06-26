import 'package:flutter/material.dart';
import 'package:hanzbthalk/core/localization/localization_extension.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'points_slider_section.dart';
import 'quick_action_button.dart';

class FlexiblePaymentInput extends StatefulWidget {
  final double currentFinalPrice;
  final double originalTotalPrice;
  final double minDeposit;
  final double paidAmount;
  final int userPoints;
  final int selectedPoints;
  final bool isOfferEnabled;
  final int noShowCount;
  final int penaltyBookingsLeft;

  final ValueChanged<bool> onOfferToggle;
  final ValueChanged<double> onPointsChanged;
  final ValueChanged<double> onAmountEntered;
  final VoidCallback onMinDepositTap;
  final VoidCallback onHalfPriceTap;
  final VoidCallback onFullPriceTap;

  const FlexiblePaymentInput({
    super.key,
    required this.currentFinalPrice,
    required this.originalTotalPrice,
    required this.paidAmount,
    required this.userPoints,
    required this.selectedPoints,
    required this.isOfferEnabled,
    required this.onOfferToggle,
    required this.onPointsChanged,
    required this.onAmountEntered,
    required this.onMinDepositTap,
    required this.onHalfPriceTap,
    required this.onFullPriceTap,
    required this.minDeposit,
    this.noShowCount = 0,
    this.penaltyBookingsLeft = 0,
  });

  @override
  State<FlexiblePaymentInput> createState() => _FlexiblePaymentInputState();
}

class _FlexiblePaymentInputState extends State<FlexiblePaymentInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    // بنخلي القيمة الابتدائية هي اللي جاية من الـ state
    _controller = TextEditingController(
      text: widget.paidAmount > 0 ? widget.paidAmount.toStringAsFixed(0) : '',
    );
  }

  // دي أهم حتة: لما الـ Widget "تترسم" تاني بقيم جديدة من الـ Cubit
  @override
  void didUpdateWidget(covariant FlexiblePaymentInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // لو الـ paidAmount اتغيرت من برا (بسبب زرار مثلاً)، بنحدث الـ controller
    if (widget.paidAmount != oldWidget.paidAmount) {
      String newText = widget.paidAmount > 0
          ? widget.paidAmount.toStringAsFixed(0)
          : '';
      if (_controller.text != newText) {
        _controller.text = newText;
        // عشان نخلي الكرسر في الآخر دايماً
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remainingAmount = widget.currentFinalPrice - widget.paidAmount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorManager.cardSurface.withOpacity(0.4),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: ColorManager.emeraldGreen.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.userPoints > 0)
            PointsSliderSection(
              userPoints: widget.userPoints,
              isOfferEnabled: widget.isOfferEnabled,
              selectedPoints: widget.selectedPoints,
              maxPointsLimit: widget.userPoints > 25
                  ? 25.0
                  : widget.userPoints.toDouble(),
              onToggleChanged: (val) => widget.onOfferToggle(val),
              onSliderChanged: widget.onPointsChanged,
            ),

          const SizedBox(height: 20),
          
          if (widget.penaltyBookingsLeft > 0) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "حسابك مقيد (مستوى 3): يجب دفع كامل المبلغ الإضافي شاملاً غرامة عدم الحضور أونلاين لتأكيد الحجز.\n"
                      "Account Restricted (Level 3): Full online payment + 50 EGP penalty is required.",
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
          ] else if (widget.noShowCount == 1) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orangeAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orangeAccent.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.orangeAccent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "تم إضافة غرامة عدم الحضور بقيمة 50 جنيه مصري لمبلغ الدفع.\n"
                      "A 50 EGP penalty fine has been added to your payment bounds.",
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
          ],

          Text(
            context.tr('selectPaymentAmount'),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),

          if (widget.penaltyBookingsLeft == 0) ...[
            Row(
              children: [
                QuickActionButton(
                  label: context.tr('minDeposit'),
                  isSelected: widget.paidAmount == widget.minDeposit,
                  onTap: widget.onMinDepositTap,
                  amount: widget.minDeposit,
                ),
                const SizedBox(width: 6),
                QuickActionButton(
                  label: context.tr('halfAmount'),
                  isSelected: widget.paidAmount == widget.currentFinalPrice / 2,
                  onTap: widget.onHalfPriceTap,
                  amount: widget.currentFinalPrice / 2,
                ),
                const SizedBox(width: 6),
                QuickActionButton(
                  label: context.tr('fullPrice'),
                  isSelected: widget.paidAmount == widget.currentFinalPrice,
                  onTap: widget.onFullPriceTap,
                  amount: widget.currentFinalPrice,
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            enabled: widget.penaltyBookingsLeft == 0,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: widget.penaltyBookingsLeft > 0 ? "المبلغ المطلوب دفعه / Required Amount" : context.tr('customAmount'),
              labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
              suffixText: context.tr('egp'),
              suffixStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: ColorManager.emeraldGreen.withOpacity(0.4)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: ColorManager.egyptianEarth),
              ),
            ),
            onChanged: (v) {
              widget.onAmountEntered(double.tryParse(v) ?? 0);
            },
          ),

          const Divider(height: 30, color: Colors.white12),

          _buildSummaryRow(
            context.tr('originalTotal'),
            "${widget.originalTotalPrice.toStringAsFixed(0)} ${context.tr('egp')}",
          ),

          if (widget.noShowCount == 1 || widget.penaltyBookingsLeft > 0)
            _buildSummaryRow(
              "غرامة عدم الحضور / Penalty Fine",
              "+ 50 ${context.tr('egp')}",
              color: Colors.redAccent,
            ),

          if (widget.isOfferEnabled && widget.selectedPoints > 0)
            _buildSummaryRow(
              "${context.tr('offerDiscount')} (${widget.selectedPoints}%):",
              "- ${(widget.originalTotalPrice - (widget.currentFinalPrice - (widget.noShowCount == 1 || widget.penaltyBookingsLeft > 0 ? 50.0 : 0.0))).toStringAsFixed(0)} ${context.tr('egp')}",
              color: Colors.green,
            ),

          _buildSummaryRow(
            context.tr('requiredNow'),
            "${widget.currentFinalPrice.toStringAsFixed(0)} ${context.tr('egp')}",
            isBold: true,
          ),
          _buildSummaryRow(
            context.tr('willBepaid'),
            "${widget.paidAmount.toStringAsFixed(0)} ${context.tr('egp')}",
            isBold: true,
          ),

          _buildSummaryRow(
            context.tr('remainingForField'),
            "${remainingAmount.toStringAsFixed(0)} ${context.tr('egp')}",
            color: remainingAmount > 0 ? ColorManager.egyptianEarth : ColorManager.wasabi,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7))),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color ?? Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
