import 'package:flutter/material.dart';
import '../../components/predict_dropdown.dart';
import '../../components/predict_mileage_input.dart';
import '../../constants/app_colors.dart';

/// Refactored, beautified Android / Mobile Predict Layout.
class AndroidPredictLayout extends StatelessWidget {
  final bool isLoadingOptions;
  final Map<String, dynamic> options;
  final bool isPredicting;
  final String? predictionResult;
  final VoidCallback onPredict;

  // Bindings
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
  final TextEditingController mileageController;

  // Callbacks
  final ValueChanged<String?> onBrandChanged;
  final ValueChanged<String?> onModelChanged;
  final ValueChanged<String?> onVariantChanged;
  final ValueChanged<int?> onModelYearChanged;
  final ValueChanged<int?> onEngineCcChanged;
  final ValueChanged<String?> onTransmissionChanged;
  final ValueChanged<String?> onBodyTypeChanged;
  final ValueChanged<String?> onColorChanged;
  final ValueChanged<String?> onAssemblyChanged;
  final ValueChanged<String?> onCityChanged;

  // Constraint-filtered lists
  final List<int> filteredYears;
  final List<int> filteredEngines;
  final List<String> filteredTransmissions;
  final List<String> filteredAssemblies;
  final bool isBodyTypeLocked;

  const AndroidPredictLayout({
    super.key,
    required this.isLoadingOptions,
    required this.options,
    required this.isPredicting,
    this.predictionResult,
    required this.onPredict,
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
    required this.mileageController,
    required this.onBrandChanged,
    required this.onModelChanged,
    required this.onVariantChanged,
    required this.onModelYearChanged,
    required this.onEngineCcChanged,
    required this.onTransmissionChanged,
    required this.onBodyTypeChanged,
    required this.onColorChanged,
    required this.onAssemblyChanged,
    required this.onCityChanged,
    required this.filteredYears,
    required this.filteredEngines,
    required this.filteredTransmissions,
    required this.filteredAssemblies,
    required this.isBodyTypeLocked,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoadingOptions) {
      return Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final brands = (options['brands'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [];

    final modelsByBrand =
        options['models_by_brand'] as Map<String, dynamic>? ?? {};
    final modelsList = (brand != null && modelsByBrand.containsKey(brand))
        ? (modelsByBrand[brand] as List<dynamic>)
            .map((e) => e as String)
            .toList()
        : <String>[];

    final variantsByBrandModel =
        options['variants_by_brand_model'] as Map<String, dynamic>? ?? {};
    final brandModelKey = "${brand}_$model";
    final variantsList =
        (model != null && variantsByBrandModel.containsKey(brandModelKey))
            ? (variantsByBrandModel[brandModelKey] as List<dynamic>)
                .map((e) => e as String)
                .toList()
            : <String>[];

    final years = filteredYears;
    final engines = filteredEngines;
    final transmissions = filteredTransmissions;
    final bodyTypes = bodyType != null
        ? <String>[bodyType!]
        : ((options['body_types'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            []);
    final colors = (options['colors'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [];
    final assemblies = filteredAssemblies;
    final cities = (options['cities'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [];

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── TOP HEADER GRADIENT BANNER ──
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: AppColors.headerGradient,
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -40,
                      right: -30,
                      child: const _PredictCircle(140),
                    ),
                    Positioned(
                      bottom: -30,
                      left: -20,
                      child: const _PredictCircle(100),
                    ),
                    Positioned(
                      bottom: -40,
                      right: 75,
                      child: const _PredictCircle(90),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 56, 20, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              InkWell(
                                onTap: () => Navigator.pop(context),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back_rounded,
                                    color: AppColors.white,
                                    size: 22,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              const Text(
                                "Predict Car Price",
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.auto_awesome,
                                        size: 14, color: Colors.amber),
                                    SizedBox(width: 4),
                                    Text(
                                      "AI Powered",
                                      style: TextStyle(
                                        color: AppColors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Provide accurate details below to estimate current market value.",
                            style: TextStyle(
                              color: AppColors.white.withValues(alpha: 0.85),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── FORM CONTAINER ──
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── SECTION 1: VEHICLE IDENTITY CARD ──
                  _SectionCard(
                    title: "Vehicle Identity",
                    icon: Icons.directions_car_filled_rounded,
                    children: [
                      PredictDropdown<String>(
                        label: 'Brand',
                        items: brands,
                        selectedValue: brand,
                        onChanged: onBrandChanged,
                        icon: Icons.directions_car_outlined,
                      ),
                      const SizedBox(height: 14),
                      PredictDropdown<String>(
                        label: 'Model',
                        items: modelsList,
                        selectedValue: model,
                        onChanged: onModelChanged,
                        disabled: brand == null,
                        icon: Icons.grid_view_rounded,
                      ),
                      const SizedBox(height: 14),
                      PredictDropdown<String>(
                        label: 'Variant',
                        items: variantsList,
                        selectedValue: variant,
                        onChanged: onVariantChanged,
                        disabled: model == null,
                        icon: Icons.label_outlined,
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // ── SECTION 2: PERFORMANCE & SPECS ──
                  _SectionCard(
                    title: "Performance & Specifications",
                    icon: Icons.tune_rounded,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: PredictDropdown<int>(
                              label: 'Year',
                              items: years,
                              selectedValue: modelYear,
                              onChanged: onModelYearChanged,
                              icon: Icons.calendar_today_rounded,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: PredictDropdown<int>(
                              label: 'Engine CC',
                              items: engines,
                              selectedValue: engineCc,
                              onChanged: onEngineCcChanged,
                              icon: Icons.offline_bolt_outlined,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: PredictDropdown<String>(
                              label: 'Transmission',
                              items: transmissions,
                              selectedValue: transmission,
                              onChanged: onTransmissionChanged,
                              icon: Icons.settings_suggest_rounded,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: PredictDropdown<String>(
                              label: 'Assembly',
                              items: assemblies,
                              selectedValue: assembly,
                              onChanged: onAssemblyChanged,
                              icon: Icons.build_outlined,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // ── SECTION 3: CONDITION & LOCATION ──
                  _SectionCard(
                    title: "Body & Location",
                    icon: Icons.location_on_rounded,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: PredictDropdown<String>(
                              label: 'Body Type',
                              items: bodyTypes,
                              selectedValue: bodyType,
                              onChanged: onBodyTypeChanged,
                              disabled: model == null,
                              icon: Icons.time_to_leave_rounded,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: PredictDropdown<String>(
                              label: 'Color',
                              items: colors,
                              selectedValue: color,
                              onChanged: onColorChanged,
                              icon: Icons.palette_outlined,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      PredictDropdown<String>(
                        label: 'City',
                        items: cities,
                        selectedValue: city,
                        onChanged: onCityChanged,
                        icon: Icons.location_city_rounded,
                      ),
                      const SizedBox(height: 14),
                      PredictMileageInput(
                        controller: mileageController,
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ── GET PREDICTION CTA BUTTON ──
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: isPredicting ? null : onPredict,
                      child: isPredicting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: AppColors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.analytics_rounded,
                                    color: AppColors.white, size: 22),
                                SizedBox(width: 10),
                                Text(
                                  'Calculate Market Price',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper card container for grouping form sections
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _PredictCircle extends StatelessWidget {
  final double size;
  const _PredictCircle(this.size);

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
