import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../servers/user_service.dart';

/// Beautiful, rich dialog displaying predicted price, car specifications grid,
/// engaging market insights, and a Save Evaluation button to persist predictions to Firestore.
class PredictionResultDialog extends StatefulWidget {
  final String formattedPrice;
  final String? brand;
  final String? model;
  final String? variant;
  final int? modelYear;
  final int? engineCc;
  final String? transmission;
  final String? bodyType;
  final String? color;
  final String? assembly;
  final String? city;
  final String? mileageKm;
  final UserService userService;

  const PredictionResultDialog({
    super.key,
    required this.formattedPrice,
    this.brand,
    this.model,
    this.variant,
    this.modelYear,
    this.engineCc,
    this.transmission,
    this.bodyType,
    this.color,
    this.assembly,
    this.city,
    this.mileageKm,
    required this.userService,
  });

  @override
  State<PredictionResultDialog> createState() => _PredictionResultDialogState();
}

class _PredictionResultDialogState extends State<PredictionResultDialog> {
  bool _isSaving = false;
  bool _isSaved = false;

  /// Generate a dynamic, engaging message based on car parameters
  String _generateInsightMessage() {
    final year = widget.modelYear ?? 2020;
    final mileage = int.tryParse(widget.mileageKm ?? '0') ?? 0;

    if (mileage > 0 && mileage < 35000) {
      return "Low mileage gem! Cars in this condition retain premium market value.";
    } else if (year >= 2022) {
      return "Modern favorite! High demand in local markets with strong buyer interest.";
    } else if ((widget.bodyType?.toLowerCase().contains('suv') ?? false) ||
        (widget.bodyType?.toLowerCase().contains('crossover') ?? false)) {
      return "Popular utility pick! SUVs continue to hold high market stability.";
    } else {
      return "Valuation calculated using real-time market data and historical trends.";
    }
  }

  Future<void> _handleSaveEvaluation() async {
    if (_isSaving || _isSaved) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final carTitle =
          "${widget.brand ?? ''} ${widget.model ?? ''} ${widget.variant ?? ''}".trim();

      final data = {
        'carName': carTitle.isNotEmpty ? carTitle : 'Unknown Car',
        'brand': widget.brand,
        'model': widget.model,
        'variant': widget.variant,
        'modelYear': widget.modelYear,
        'engineCc': widget.engineCc,
        'transmission': widget.transmission,
        'bodyType': widget.bodyType,
        'color': widget.color,
        'assembly': widget.assembly,
        'city': widget.city,
        'mileageKm': widget.mileageKm,
        'predictedPrice': widget.formattedPrice,
      };

      await widget.userService.saveEvaluation(data);

      if (mounted) {
        setState(() {
          _isSaving = false;
          _isSaved = true;
        });

        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Evaluation saved to History! ✓"),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.primary,
            duration: Duration(seconds: 2),
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to save evaluation: $e"),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleCar = "${widget.brand ?? ''} ${widget.model ?? ''}".trim();
    final subTitleCar = "${widget.variant ?? ''} • ${widget.modelYear ?? ''}".trim();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 16,
      clipBehavior: Clip.antiAlias,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        color: AppColors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── PURPLE GRADIENT HEADER BANNER ──
            ClipRRect(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: AppColors.headerGradient,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: -30,
                      right: -20,
                      child: const _DialogCircle(120),
                    ),
                    Positioned(
                      bottom: -30,
                      left: -20,
                      child: const _DialogCircle(100),
                    ),
                    Positioned(
                      bottom: -30,
                      right: 60,
                      child: const _DialogCircle(70),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
                      child: Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppColors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.white.withValues(alpha: 0.5),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.stars_rounded,
                              color: AppColors.white,
                              size: 38,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Valuation Complete",
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            titleCar.isNotEmpty ? titleCar : "Vehicle Market Estimate",
                            style: TextStyle(
                              color: AppColors.white.withValues(alpha: 0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── BODY CONTENT ──
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // ── PRICE BOX ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primarySurface,
                            AppColors.primarySurface.withValues(alpha: 0.5),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primaryBorder,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "ESTIMATED MARKET VALUE",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: AppColors.primaryDark.withValues(alpha: 0.8),
                            ),
                          ),
                          const SizedBox(height: 6),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              widget.formattedPrice,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── SPECS SUMMARY GRID ──
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.scaffoldBg,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.directions_car_rounded,
                                  size: 16, color: AppColors.primary),
                              SizedBox(width: 6),
                              Text(
                                "Car Specifications",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 20, color: AppColors.divider),
                          Wrap(
                            spacing: 12,
                            runSpacing: 10,
                            children: [
                              if (subTitleCar.isNotEmpty)
                                _SpecChip(
                                  icon: Icons.bookmark_border_rounded,
                                  label: subTitleCar,
                                ),
                              if (widget.engineCc != null)
                                _SpecChip(
                                  icon: Icons.offline_bolt_outlined,
                                  label: "${widget.engineCc} cc",
                                ),
                              if (widget.transmission != null)
                                _SpecChip(
                                  icon: Icons.tune_rounded,
                                  label: widget.transmission!,
                                ),
                              if (widget.bodyType != null)
                                _SpecChip(
                                  icon: Icons.time_to_leave_rounded,
                                  label: widget.bodyType!,
                                ),
                              if (widget.mileageKm != null && widget.mileageKm!.isNotEmpty)
                                _SpecChip(
                                  icon: Icons.speed_rounded,
                                  label: "${widget.mileageKm} km",
                                ),
                              if (widget.city != null)
                                _SpecChip(
                                  icon: Icons.location_on_outlined,
                                  label: widget.city!,
                                ),
                              if (widget.assembly != null)
                                _SpecChip(
                                  icon: Icons.build_outlined,
                                  label: widget.assembly!,
                                ),
                              if (widget.color != null)
                                _SpecChip(
                                  icon: Icons.palette_outlined,
                                  label: widget.color!,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── DYNAMIC ENGAGEMENT MESSAGE ──
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.amber.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline_rounded,
                            color: Colors.amber.shade800,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _generateInsightMessage(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.amber.shade900,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── ACTION BUTTONS ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.primaryBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _isSaving ? null : _handleSaveEvaluation,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            )
                          : Icon(
                              _isSaved
                                  ? Icons.bookmark_added_rounded
                                  : Icons.bookmark_add_outlined,
                              size: 18,
                              color: AppColors.primary,
                            ),
                      label: Text(
                        _isSaved ? "Saved!" : "Save Evaluation",
                        style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Done",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper spec chip widget inside prediction result dialog
class _SpecChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SpecChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogCircle extends StatelessWidget {
  final double size;
  const _DialogCircle(this.size);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.white.withValues(alpha: 0.06),
      ),
    );
  }
}
