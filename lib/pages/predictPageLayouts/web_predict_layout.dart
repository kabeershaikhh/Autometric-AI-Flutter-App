import 'package:flutter/material.dart';
import '../../components/predict_dropdown.dart';
import '../../components/predict_mileage_input.dart';
import '../../components/home_drawer.dart';
import '../../components/web_sidebar.dart';
import '../../constants/app_colors.dart';
import '../../servers/user_service.dart';

/// Refactored, beautified Web Predict Layout with reusable components and section cards.
class WebPredictLayout extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String? photoBase64;
  final UserService userService;
  final VoidCallback onLogout;
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

  const WebPredictLayout({
    super.key,
    required this.userName,
    required this.userEmail,
    this.photoBase64,
    required this.userService,
    required this.onLogout,
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
  State<WebPredictLayout> createState() => _WebPredictLayoutState();
}

class _WebPredictLayoutState extends State<WebPredictLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openProfileDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoadingOptions) {
      return Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final brands = (widget.options['brands'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [];

    final modelsByBrand =
        widget.options['models_by_brand'] as Map<String, dynamic>? ?? {};
    final modelsList = (widget.brand != null &&
            modelsByBrand.containsKey(widget.brand))
        ? (modelsByBrand[widget.brand] as List<dynamic>)
            .map((e) => e as String)
            .toList()
        : <String>[];

    final variantsByBrandModel =
        widget.options['variants_by_brand_model'] as Map<String, dynamic>? ?? {};
    final brandModelKey = "${widget.brand}_${widget.model}";
    final variantsList = (widget.model != null &&
            variantsByBrandModel.containsKey(brandModelKey))
        ? (variantsByBrandModel[brandModelKey] as List<dynamic>)
            .map((e) => e as String)
            .toList()
        : <String>[];

    final years = widget.filteredYears;
    final engines = widget.filteredEngines;
    final transmissions = widget.filteredTransmissions;
    final bodyTypes = (widget.options['body_types'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [];
    final colors = (widget.options['colors'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [];
    final assemblies = widget.filteredAssemblies;
    final cities = (widget.options['cities'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [];

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.scaffoldBg,
      endDrawer: HomeDrawer(
        onLogout: () {
          Navigator.pop(context);
          widget.onLogout();
        },
        userName: widget.userName,
        userEmail: widget.userEmail,
        photoBase64: widget.photoBase64,
        userService: widget.userService,
      ),
      body: Row(
        children: [
          // ── LEFT SIDEBAR ──
          WebSidebar(
            selectedIndex: 1, // Highlight "Predict Price"
            onItemTap: (index) {
              if (index == 0) {
                Navigator.pop(context); // Return to Home
              } else if (index == 2 || index == 3) {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Feature is currently not available"),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            onLogout: widget.onLogout,
            onProfileTap: _openProfileDrawer,
            photoBase64: widget.photoBase64,
          ),

          // ── MAIN CONTENT AREA ──
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 32),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 920),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // ── PAGE HEADER CARD ──
                            Container(
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                gradient: AppColors.headerGradient,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.25),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  // Corner decorative circles touching true outer purple edges
                                  Positioned(
                                    top: -40,
                                    right: -30,
                                    child: const _WebPredictCircle(150),
                                  ),
                                  Positioned(
                                    bottom: -35,
                                    left: -30,
                                    child: const _WebPredictCircle(120),
                                  ),
                                  Positioned(
                                    bottom: -40,
                                    right: 110,
                                    child: const _WebPredictCircle(95),
                                  ),
                                  // Content with inner padding
                                  Padding(
                                    padding: const EdgeInsets.all(28),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                            horizontal: 10,
                                                            vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.white
                                                          .withValues(alpha: 0.2),
                                                      borderRadius:
                                                          BorderRadius.circular(20),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: const [
                                                        Icon(Icons.auto_awesome,
                                                            size: 14,
                                                            color: Colors.amber),
                                                        SizedBox(width: 6),
                                                        Text(
                                                          "AI Market Valuation",
                                                          style: TextStyle(
                                                            color: AppColors.white,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              const Text(
                                                "Predict Vehicle Market Price",
                                                style: TextStyle(
                                                  fontSize: 26,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.white,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                "Enter specification parameters to generate accurate price estimates using Machine Learning models.",
                                                style: TextStyle(
                                                  color: AppColors.white
                                                      .withValues(alpha: 0.85),
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 24),
                                        Container(
                                          width: 64,
                                          height: 64,
                                          decoration: BoxDecoration(
                                            color: AppColors.white
                                                .withValues(alpha: 0.15),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.analytics_rounded,
                                            color: AppColors.white,
                                            size: 36,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 28),

                            // ── SECTION 1: VEHICLE IDENTITY ──
                            _WebSectionCard(
                              title: "Vehicle Identity",
                              icon: Icons.directions_car_filled_rounded,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: PredictDropdown<String>(
                                        label: 'Brand',
                                        items: brands,
                                        selectedValue: widget.brand,
                                        onChanged: widget.onBrandChanged,
                                        icon: Icons.directions_car_outlined,
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: PredictDropdown<String>(
                                        label: 'Model',
                                        items: modelsList,
                                        selectedValue: widget.model,
                                        onChanged: widget.onModelChanged,
                                        disabled: widget.brand == null,
                                        icon: Icons.grid_view_rounded,
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: PredictDropdown<String>(
                                        label: 'Variant',
                                        items: variantsList,
                                        selectedValue: widget.variant,
                                        onChanged: widget.onVariantChanged,
                                        disabled: widget.model == null,
                                        icon: Icons.label_outlined,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // ── SECTION 2: TECHNICAL SPECS ──
                            _WebSectionCard(
                              title: "Technical Specifications",
                              icon: Icons.tune_rounded,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: PredictDropdown<int>(
                                        label: 'Model Year',
                                        items: years,
                                        selectedValue: widget.modelYear,
                                        onChanged: widget.onModelYearChanged,
                                        icon: Icons.calendar_today_rounded,
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: PredictDropdown<int>(
                                        label: 'Engine CC',
                                        items: engines,
                                        selectedValue: widget.engineCc,
                                        onChanged: widget.onEngineCcChanged,
                                        icon: Icons.offline_bolt_outlined,
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: PredictDropdown<String>(
                                        label: 'Transmission',
                                        items: transmissions,
                                        selectedValue: widget.transmission,
                                        onChanged: widget.onTransmissionChanged,
                                        icon: Icons.settings_suggest_rounded,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                      child: PredictDropdown<String>(
                                        label: 'Assembly',
                                        items: assemblies,
                                        selectedValue: widget.assembly,
                                        onChanged: widget.onAssemblyChanged,
                                        icon: Icons.build_outlined,
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: PredictDropdown<String>(
                                        label: 'Body Type',
                                        items: bodyTypes,
                                        selectedValue: widget.bodyType,
                                        onChanged: widget.onBodyTypeChanged,
                                        disabled: widget.isBodyTypeLocked,
                                        icon: Icons.time_to_leave_rounded,
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: PredictDropdown<String>(
                                        label: 'Color',
                                        items: colors,
                                        selectedValue: widget.color,
                                        onChanged: widget.onColorChanged,
                                        icon: Icons.palette_outlined,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // ── SECTION 3: LOCATION & CONDITION ──
                            _WebSectionCard(
                              title: "Location & Mileage",
                              icon: Icons.location_on_rounded,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: PredictDropdown<String>(
                                        label: 'City',
                                        items: cities,
                                        selectedValue: widget.city,
                                        onChanged: widget.onCityChanged,
                                        icon: Icons.location_city_rounded,
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: PredictMileageInput(
                                        controller: widget.mileageController,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 32),

                            // ── CTA SUBMIT BUTTON ──
                            Container(
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.35),
                                    blurRadius: 18,
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
                                onPressed: widget.isPredicting
                                    ? null
                                    : widget.onPredict,
                                child: widget.isPredicting
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: AppColors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Icon(Icons.analytics_rounded,
                                              color: AppColors.white, size: 22),
                                          SizedBox(width: 10),
                                          Text(
                                            'Calculate Market Value',
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),

                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Top app bar for Web Layout
  Widget _buildTopBar() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Row(
            children: [
              Text(
                "Home",
                style: TextStyle(color: AppColors.textGrey, fontSize: 14),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.chevron_right,
                    size: 16, color: AppColors.textGrey),
              ),
              const Text(
                "Predict Price",
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none_rounded,
                    color: AppColors.textDark),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: _openProfileDrawer,
                borderRadius: BorderRadius.circular(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primarySurface,
                      child: Text(
                        widget.userName.isNotEmpty
                            ? widget.userName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      widget.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down,
                        color: AppColors.textGrey),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Section container for Web Layout
class _WebSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _WebSectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}

class _WebPredictCircle extends StatelessWidget {
  final double size;
  const _WebPredictCircle(this.size);

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
