import 'package:flutter/material.dart';

import '../../components/home_drawer.dart';
import '../../components/web_sidebar.dart';
import '../../constants/app_colors.dart';
import '../../servers/user_service.dart';

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
      return const Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final brands = (widget.options['brands'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [];
    
    final modelsByBrand = widget.options['models_by_brand'] as Map<String, dynamic>? ?? {};
    final modelsList = (widget.brand != null && modelsByBrand.containsKey(widget.brand)) 
        ? (modelsByBrand[widget.brand] as List<dynamic>).map((e) => e as String).toList() 
        : <String>[];

    final variantsByBrandModel = widget.options['variants_by_brand_model'] as Map<String, dynamic>? ?? {};
    final brandModelKey = "${widget.brand}_${widget.model}";
    final variantsList = (widget.model != null && variantsByBrandModel.containsKey(brandModelKey))
        ? (variantsByBrandModel[brandModelKey] as List<dynamic>).map((e) => e as String).toList()
        : <String>[];

    final years = (widget.options['model_years'] as List<dynamic>?)?.map((e) => e as int).toList() ?? [];
    final engines = (widget.options['engine_capacities'] as List<dynamic>?)?.map((e) => e as int).toList() ?? [];
    final transmissions = (widget.options['transmissions'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [];
    final bodyTypes = (widget.options['body_types'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [];
    final colors = (widget.options['colors'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [];
    final assemblies = (widget.options['assemblies'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [];
    final cities = (widget.options['cities'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [];

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
          WebSidebar(
            selectedIndex: 1, // Focus on "Predict Price" logically if index matches
            onItemTap: (index) {
              if (index == 0) {
                Navigator.pop(context); // Go back to Home
              }
            },
            onLogout: widget.onLogout,
            onProfileTap: _openProfileDrawer,
            photoBase64: widget.photoBase64,
          ),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 800),
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              "Car Specifications",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Enter the details of the car to get an accurate market value prediction.",
                              style: TextStyle(color: AppColors.textLight, fontSize: 14),
                            ),
                            const SizedBox(height: 32),

                            Row(
                              children: [
                                Expanded(child: _buildDropdown<String>('Brand', brands, widget.brand, widget.onBrandChanged)),
                                const SizedBox(width: 24),
                                Expanded(child: _buildDropdown<String>('Model', modelsList, widget.model, widget.onModelChanged, disabled: widget.brand == null)),
                                const SizedBox(width: 24),
                                Expanded(child: _buildDropdown<String>('Variant', variantsList, widget.variant, widget.onVariantChanged, disabled: widget.model == null)),
                              ],
                            ),
                            const SizedBox(height: 24),
                            
                            Row(
                              children: [
                                Expanded(child: _buildDropdown<int>('Year', years, widget.modelYear, widget.onModelYearChanged)),
                                const SizedBox(width: 24),
                                Expanded(child: _buildDropdown<int>('Engine CC', engines, widget.engineCc, widget.onEngineCcChanged)),
                                const SizedBox(width: 24),
                                Expanded(child: _buildDropdown<String>('Transmission', transmissions, widget.transmission, widget.onTransmissionChanged)),
                              ],
                            ),
                            const SizedBox(height: 24),

                            Row(
                              children: [
                                Expanded(child: _buildDropdown<String>('Assembly', assemblies, widget.assembly, widget.onAssemblyChanged)),
                                const SizedBox(width: 24),
                                Expanded(child: _buildDropdown<String>('Body Type', bodyTypes, widget.bodyType, widget.onBodyTypeChanged)),
                                const SizedBox(width: 24),
                                Expanded(child: _buildDropdown<String>('Color', colors, widget.color, widget.onColorChanged)),
                              ],
                            ),
                            const SizedBox(height: 24),

                            Row(
                              children: [
                                Expanded(child: _buildDropdown<String>('City', cities, widget.city, widget.onCityChanged)),
                                const SizedBox(width: 24),
                                Expanded(
                                  child: TextFormField(
                                    controller: widget.mileageController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Mileage (km)',
                                      filled: true,
                                      fillColor: AppColors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Colors.grey.shade300),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Colors.grey.shade300),
                                      ),
                                      prefixIcon: const Icon(Icons.speed, color: AppColors.primary),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 48),

                            SizedBox(
                              width: double.infinity,
                              height: 58,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF7C4DFF),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  elevation: 8,
                                ),
                                onPressed: widget.isPredicting ? null : widget.onPredict,
                                child: widget.isPredicting
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2),
                                      )
                                    : const Text(
                                        'Get Prediction',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
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

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Predict Price",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.scaffoldBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none,
              color: AppColors.textDark,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>(
    String label, 
    List<T> items, 
    T? selectedValue, 
    ValueChanged<T?> onChanged, {
    bool disabled = false,
  }) {
    return DropdownButtonFormField<T>(
      isExpanded: true,
      value: (items.contains(selectedValue)) ? selectedValue : null,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: disabled ? Colors.grey.shade100 : AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      items: disabled 
          ? [] 
          : items.map((item) => DropdownMenuItem<T>(
              value: item,
              child: Text(
                item.toString(),
                overflow: TextOverflow.ellipsis,
              ),
            )).toList(),
      onChanged: disabled ? null : onChanged,
    );
  }
}
