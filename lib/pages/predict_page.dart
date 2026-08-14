import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../servers/prediction_service.dart';
import '../servers/user_service.dart';
import 'predictPageLayouts/android_predict_layout.dart';
import 'predictPageLayouts/web_predict_layout.dart';

class PredictPage extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String? photoBase64;
  final UserService userService;
  final VoidCallback onLogout;

  const PredictPage({
    super.key,
    required this.userName,
    required this.userEmail,
    this.photoBase64,
    required this.userService,
    required this.onLogout,
  });

  @override
  State<PredictPage> createState() => _PredictPageState();
}

class _PredictPageState extends State<PredictPage> {
  bool isLoadingOptions = true;
  Map<String, dynamic> options = {};

  // Selected values
  String? brand;
  String? model;
  String? variant;
  int? modelYear;
  int? engineCc;
  String? transmission;
  String? bodyType;
  String? color;
  String? assembly;
  String? city;
  final TextEditingController mileageController = TextEditingController();

  bool isPredicting = false;
  String? predictionResult;

  // ── Constraint-aware filtered lists ──
  List<int> _filteredYears = [];
  List<int> _filteredEngines = [];
  List<String> _filteredTransmissions = [];
  List<String> _filteredAssemblies = [];
  String? _autoBodyType; // Auto-locked body type from constraints
  bool _isBodyTypeLocked = false;

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  @override
  void dispose() {
    mileageController.dispose();
    super.dispose();
  }

  Future<void> _loadOptions() async {
    try {
      final opts = await PredictionService.fetchOptions();
      setState(() {
        options = opts;
        isLoadingOptions = false;
        // Initialize with full unfiltered lists
        _filteredYears = _getIntList('model_years');
        _filteredEngines = _getIntList('engine_capacities');
        _filteredTransmissions = _getStringList('transmissions');
        _filteredAssemblies = _getStringList('assemblies');
      });
    } catch (e) {
      setState(() {
        isLoadingOptions = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load options. Make sure backend is running.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // ── Helper to extract typed lists from options ──
  List<int> _getIntList(String key) =>
      (options[key] as List<dynamic>?)?.map((e) => e as int).toList() ?? [];

  List<String> _getStringList(String key) =>
      (options[key] as List<dynamic>?)?.map((e) => e as String).toList() ?? [];

  // ── Get the constraint map for the currently selected Brand_Model ──
  Map<String, dynamic>? _getConstraint() {
    if (brand == null || model == null) return null;
    final constraints = options['constraints'] as Map<String, dynamic>? ?? {};
    final key = '${brand}_$model';
    return constraints[key] as Map<String, dynamic>?;
  }

  // ── Apply constraints when Brand or Model changes ──
  void _applyCarConstraints() {
    final c = _getConstraint();
    if (c == null) {
      // No constraints found — reset to full unfiltered lists
      _filteredYears = _getIntList('model_years');
      _filteredEngines = _getIntList('engine_capacities');
      _filteredTransmissions = _getStringList('transmissions');
      _filteredAssemblies = _getStringList('assemblies');
      _autoBodyType = null;
      _isBodyTypeLocked = false;
      return;
    }

    // 1. Auto-lock body type
    _autoBodyType = c['body_type'] as String?;
    _isBodyTypeLocked = _autoBodyType != null;
    if (_isBodyTypeLocked) {
      bodyType = _autoBodyType;
    }

    // 2. Filter assembly options
    final assemblyList = (c['assembly'] as List<dynamic>?)?.map((e) => e as String).toList();
    if (assemblyList != null && assemblyList.isNotEmpty) {
      _filteredAssemblies = assemblyList;
      if (assemblyList.length == 1) {
        assembly = assemblyList.first;
      } else if (assembly != null && !assemblyList.contains(assembly)) {
        assembly = null;
      }
    } else {
      _filteredAssemblies = _getStringList('assemblies');
    }

    // 3. Filter years to only available years for this car
    final availableYears = (c['available_years'] as List<dynamic>?)?.map((e) => e as int).toList();
    if (availableYears != null && availableYears.isNotEmpty) {
      // Show in descending order (newest first)
      _filteredYears = availableYears.reversed.toList();
    } else {
      _filteredYears = _getIntList('model_years');
    }

    // Clear year-dependent selections if year no longer valid
    if (modelYear != null && !_filteredYears.contains(modelYear)) {
      modelYear = null;
    }

    // 4. Apply year-dependent constraints (engine + transmission)
    _applyYearConstraints();
  }

  // ── Apply engine/transmission constraints based on selected year ──
  void _applyYearConstraints() {
    final c = _getConstraint();
    if (c == null || modelYear == null) {
      // If no constraint or no year selected, show all engines/transmissions for this car
      if (c != null) {
        _filteredEngines = (c['all_engines'] as List<dynamic>?)?.map((e) => e as int).toList() ?? _getIntList('engine_capacities');
        _filteredTransmissions = (c['all_transmissions'] as List<dynamic>?)?.map((e) => e as String).toList() ?? _getStringList('transmissions');
      } else {
        _filteredEngines = _getIntList('engine_capacities');
        _filteredTransmissions = _getStringList('transmissions');
      }
      return;
    }

    final year = modelYear!;

    // Find matching engine range for the selected year
    final engineByYear = c['engine_by_year'] as Map<String, dynamic>?;
    if (engineByYear != null) {
      final ranges = engineByYear['ranges'] as List<dynamic>? ?? [];
      List<int>? matchedEngines;
      for (final range in ranges) {
        final r = range as Map<String, dynamic>;
        final years = (r['years'] as List<dynamic>).map((e) => e as int).toList();
        if (years.length == 2 && year >= years[0] && year <= years[1]) {
          matchedEngines = (r['engines'] as List<dynamic>).map((e) => e as int).toList();
          break;
        }
      }
      _filteredEngines = matchedEngines ?? (c['all_engines'] as List<dynamic>?)?.map((e) => e as int).toList() ?? _getIntList('engine_capacities');
    }

    // Find matching transmission range for the selected year
    final transByYear = c['transmission_by_year'] as Map<String, dynamic>?;
    if (transByYear != null) {
      final ranges = transByYear['ranges'] as List<dynamic>? ?? [];
      List<String>? matchedTrans;
      for (final range in ranges) {
        final r = range as Map<String, dynamic>;
        final years = (r['years'] as List<dynamic>).map((e) => e as int).toList();
        if (years.length == 2 && year >= years[0] && year <= years[1]) {
          matchedTrans = (r['transmissions'] as List<dynamic>).map((e) => e as String).toList();
          break;
        }
      }
      _filteredTransmissions = matchedTrans ?? (c['all_transmissions'] as List<dynamic>?)?.map((e) => e as String).toList() ?? _getStringList('transmissions');
    }

    // Auto-select if only one option available
    if (_filteredEngines.length == 1) {
      engineCc = _filteredEngines.first;
    } else if (engineCc != null && !_filteredEngines.contains(engineCc)) {
      engineCc = null;
    }

    if (_filteredTransmissions.length == 1) {
      transmission = _filteredTransmissions.first;
    } else if (transmission != null && !_filteredTransmissions.contains(transmission)) {
      transmission = null;
    }
  }

  // ── Callbacks ──

  void _onBrandChanged(String? newBrand) {
    setState(() {
      brand = newBrand;
      model = null;
      variant = null;
      modelYear = null;
      engineCc = null;
      transmission = null;
      bodyType = null;
      assembly = null;
      _autoBodyType = null;
      _isBodyTypeLocked = false;
      // Reset to full lists when brand changes
      _filteredYears = _getIntList('model_years');
      _filteredEngines = _getIntList('engine_capacities');
      _filteredTransmissions = _getStringList('transmissions');
      _filteredAssemblies = _getStringList('assemblies');
    });
  }

  void _onModelChanged(String? newModel) {
    setState(() {
      model = newModel;
      variant = null;
      modelYear = null;
      engineCc = null;
      transmission = null;
      // Apply constraints for the new Brand_Model
      _applyCarConstraints();
    });
  }

  void _onModelYearChanged(int? newYear) {
    setState(() {
      modelYear = newYear;
      // Re-apply year-dependent constraints (engine + transmission)
      _applyYearConstraints();
    });
  }

  Future<void> _predict() async {
    if (brand == null ||
        model == null ||
        variant == null ||
        modelYear == null ||
        engineCc == null ||
        transmission == null ||
        bodyType == null ||
        color == null ||
        assembly == null ||
        city == null ||
        mileageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields!'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      isPredicting = true;
      predictionResult = null;
    });

    try {
      final data = {
        'brand': brand,
        'model': model,
        'variant': variant,
        'model_year': modelYear,
        'engine_cc': engineCc,
        'transmission': transmission,
        'body_type': bodyType,
        'color': color,
        'assembly': assembly,
        'city': city,
        'mileage_km': double.parse(mileageController.text),
      };

      final result = await PredictionService.predictPrice(data);

      setState(() {
        isPredicting = false;
        predictionResult = result['formatted_price'];
      });

      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Text('Predicted Price', textAlign: TextAlign.center),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline, color: AppColors.success, size: 64),
                const SizedBox(height: 16),
                Text(
                  result['formatted_price'],
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Awesome!'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() {
        isPredicting = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Prediction failed. $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (kIsWeb && constraints.maxWidth >= 950) {
            return WebPredictLayout(
              userName: widget.userName,
              userEmail: widget.userEmail,
              photoBase64: widget.photoBase64,
              userService: widget.userService,
              onLogout: widget.onLogout,
              isLoadingOptions: isLoadingOptions,
              options: options,
              isPredicting: isPredicting,
              predictionResult: predictionResult,
              onPredict: _predict,
              // Bindings
              brand: brand,
              model: model,
              variant: variant,
              modelYear: modelYear,
              engineCc: engineCc,
              transmission: transmission,
              bodyType: bodyType,
              color: color,
              assembly: assembly,
              city: city,
              mileageController: mileageController,
              onBrandChanged: _onBrandChanged,
              onModelChanged: _onModelChanged,
              onVariantChanged: (v) => setState(() => variant = v),
              onModelYearChanged: _onModelYearChanged,
              onEngineCcChanged: (v) => setState(() => engineCc = v),
              onTransmissionChanged: (v) => setState(() => transmission = v),
              onBodyTypeChanged: (v) => setState(() => bodyType = v),
              onColorChanged: (v) => setState(() => color = v),
              onAssemblyChanged: (v) => setState(() => assembly = v),
              onCityChanged: (v) => setState(() => city = v),
              // Constraint-filtered lists
              filteredYears: _filteredYears,
              filteredEngines: _filteredEngines,
              filteredTransmissions: _filteredTransmissions,
              filteredAssemblies: _filteredAssemblies,
              isBodyTypeLocked: _isBodyTypeLocked,
            );
          }

          return AndroidPredictLayout(
            isLoadingOptions: isLoadingOptions,
            options: options,
            isPredicting: isPredicting,
            predictionResult: predictionResult,
            onPredict: _predict,
            // Bindings
            brand: brand,
            model: model,
            variant: variant,
            modelYear: modelYear,
            engineCc: engineCc,
            transmission: transmission,
            bodyType: bodyType,
            color: color,
            assembly: assembly,
            city: city,
            mileageController: mileageController,
            onBrandChanged: _onBrandChanged,
            onModelChanged: _onModelChanged,
            onVariantChanged: (v) => setState(() => variant = v),
            onModelYearChanged: _onModelYearChanged,
            onEngineCcChanged: (v) => setState(() => engineCc = v),
            onTransmissionChanged: (v) => setState(() => transmission = v),
            onBodyTypeChanged: (v) => setState(() => bodyType = v),
            onColorChanged: (v) => setState(() => color = v),
            onAssemblyChanged: (v) => setState(() => assembly = v),
            onCityChanged: (v) => setState(() => city = v),
            // Constraint-filtered lists
            filteredYears: _filteredYears,
            filteredEngines: _filteredEngines,
            filteredTransmissions: _filteredTransmissions,
            filteredAssemblies: _filteredAssemblies,
            isBodyTypeLocked: _isBodyTypeLocked,
          );
        },
      ),
    );
  }
}
