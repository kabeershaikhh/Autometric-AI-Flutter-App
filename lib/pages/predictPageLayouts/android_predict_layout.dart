import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

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
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          title: const Text('Predict Car Price'),
        ),
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    // Dynamic Lists based on dependent dropdowns
    final brands = (options['brands'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [];
    
    final modelsByBrand = options['models_by_brand'] as Map<String, dynamic>? ?? {};
    final modelsList = (brand != null && modelsByBrand.containsKey(brand)) 
        ? (modelsByBrand[brand] as List<dynamic>).map((e) => e as String).toList() 
        : <String>[];

    final variantsByBrandModel = options['variants_by_brand_model'] as Map<String, dynamic>? ?? {};
    final brandModelKey = "${brand}_$model";
    final variantsList = (model != null && variantsByBrandModel.containsKey(brandModelKey))
        ? (variantsByBrandModel[brandModelKey] as List<dynamic>).map((e) => e as String).toList()
        : <String>[];

    final years = filteredYears;
    final engines = filteredEngines;
    final transmissions = filteredTransmissions;
    final bodyTypes = (options['body_types'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [];
    final colors = (options['colors'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [];
    final assemblies = filteredAssemblies;
    final cities = (options['cities'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [];

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Custom Header
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: AppColors.headerGradient,
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -20,
                      right: -10,
                      child: _PredictCircle(80),
                    ),
                    Positioned(
                      bottom: -20,
                      left: -10,
                      child: _PredictCircle(80),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.arrow_back,
                                color: AppColors.white,
                                size: 22,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Text(
                            "Predict Price",
                            style: TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
            const Text(
              "Car Specifications",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Enter the details of the car to get an accurate market value prediction.",
              style: TextStyle(color: AppColors.textLight, fontSize: 14),
            ),
            const SizedBox(height: 24),

            _buildDropdown<String>('Brand', brands, brand, onBrandChanged),
            const SizedBox(height: 16),
            _buildDropdown<String>('Model', modelsList, model, onModelChanged, disabled: brand == null),
            const SizedBox(height: 16),
            _buildDropdown<String>('Variant', variantsList, variant, onVariantChanged, disabled: model == null),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(child: _buildDropdown<int>('Year', years, modelYear, onModelYearChanged)),
                const SizedBox(width: 16),
                Expanded(child: _buildDropdown<int>('Engine CC', engines, engineCc, onEngineCcChanged)),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(child: _buildDropdown<String>('Transmission', transmissions, transmission, onTransmissionChanged)),
                const SizedBox(width: 16),
                Expanded(child: _buildDropdown<String>('Assembly', assemblies, assembly, onAssemblyChanged)),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(child: _buildDropdown<String>('Body Type', bodyTypes, bodyType, onBodyTypeChanged, disabled: isBodyTypeLocked)),
                const SizedBox(width: 16),
                Expanded(child: _buildDropdown<String>('Color', colors, color, onColorChanged)),
              ],
            ),
            const SizedBox(height: 16),

            _buildDropdown<String>('City', cities, city, onCityChanged),
            const SizedBox(height: 16),

            TextFormField(
              controller: mileageController,
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
            const SizedBox(height: 32),

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
                  onPressed: isPredicting ? null : onPredict,
                  child: isPredicting
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
            const SizedBox(height: 40),
          ],
        ),
      ),
    ],
  ),
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
      items: items.map((item) => DropdownMenuItem<T>(
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
        color: AppColors.white.withValues(alpha: 0.1),
      ),
    );
  }
}
