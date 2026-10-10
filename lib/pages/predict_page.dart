import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../components/prediction_result_dialog.dart';
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
  List<String> _filteredColors = [];
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
      if (!mounted) return;
      setState(() {
        options = opts;
        isLoadingOptions = false;
        // Initialize with full unfiltered lists
        _filteredYears = _getIntList('model_years');
        _filteredEngines = _getIntList('engine_capacities');
        _filteredTransmissions = _getStringList('transmissions');
        _filteredAssemblies = _getStringList('assemblies');
        _filteredColors = _getStringList('colors');
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoadingOptions = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Failed to load options. Make sure backend is connected.',
            ),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
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

  // ── Get the constraint map for current Brand_Model or Brand_Model_Variant ──
  Map<String, dynamic>? _getConstraint() {
    if (brand == null || model == null) return null;
    final constraints = options['constraints'] as Map<String, dynamic>? ?? {};

    // 1. Try variant-specific constraint key first
    if (variant != null) {
      final bmtKey = '${brand}_${model}_$variant';
      if (constraints.containsKey(bmtKey) &&
          constraints[bmtKey] is Map<String, dynamic>) {
        return constraints[bmtKey] as Map<String, dynamic>;
      }
    }

    // 2. Fallback to model-level constraint key
    final bmKey = '${brand}_$model';
    if (constraints.containsKey(bmKey) &&
        constraints[bmKey] is Map<String, dynamic>) {
      return constraints[bmKey] as Map<String, dynamic>;
    }
    return null;
  }

  // ── Apply constraints when Brand, Model, or Variant changes ──
  void _applyCarConstraints() {
    final c = _getConstraint();
    if (c == null) {
      // No constraints found — reset to full unfiltered lists
      _filteredYears = _getIntList('model_years');
      _filteredEngines = _getIntList('engine_capacities');
      _filteredTransmissions = _getStringList('transmissions');
      _filteredAssemblies = _getStringList('assemblies');
      _filteredColors = _getStringList('colors');
      _autoBodyType = null;
      _isBodyTypeLocked = false;
      return;
    }

    // 1. Safely handle body_type (auto-select without greying out)
    final rawBody = c['body_type'];
    if (rawBody is String) {
      _autoBodyType = rawBody;
      _isBodyTypeLocked = false;
      bodyType = rawBody;
    } else if (rawBody is List && rawBody.isNotEmpty) {
      if (rawBody.length == 1) {
        _autoBodyType = rawBody.first.toString();
        _isBodyTypeLocked = false;
        bodyType = _autoBodyType;
      } else {
        _autoBodyType = null;
        _isBodyTypeLocked = false;
      }
    } else {
      _autoBodyType = null;
      _isBodyTypeLocked = false;
    }

    // 2. Safely filter assembly options
    final rawAssembly = c['assembly'];
    if (rawAssembly is List && rawAssembly.isNotEmpty) {
      final assemblyList = rawAssembly.map((e) => e.toString()).toList();
      _filteredAssemblies = assemblyList;
      if (assemblyList.length == 1) {
        assembly = assemblyList.first;
      } else if (assembly != null && !assemblyList.contains(assembly)) {
        assembly = null;
      }
    } else {
      _filteredAssemblies = _getStringList('assemblies');
    }

    // 3. Safely filter years to only available years for this car
    final rawYears = c['available_years'];
    if (rawYears is List && rawYears.isNotEmpty) {
      final availableYears = rawYears.map((e) => (e as num).toInt()).toList();
      // Show in descending order (newest first)
      _filteredYears = availableYears.reversed.toList();
    } else {
      _filteredYears = _getIntList('model_years');
    }

    // Auto-select year if only 1 option available
    if (_filteredYears.length == 1) {
      modelYear = _filteredYears.first;
    } else if (modelYear != null && !_filteredYears.contains(modelYear)) {
      modelYear = null;
    }

    // 4. Safely filter colors for this car
    final rawColors = c['all_colors'];
    if (rawColors is List && rawColors.isNotEmpty) {
      final colorList = rawColors.map((e) => e.toString()).toList();
      _filteredColors = colorList;
      if (colorList.length == 1) {
        color = colorList.first;
      } else if (color != null && !colorList.contains(color)) {
        color = null;
      }
    } else {
      _filteredColors = _getStringList('colors');
    }

    // 5. Apply year-dependent constraints (engine + transmission)
    _applyYearConstraints();
  }

  // ── Apply engine/transmission constraints based on selected year ──
  void _applyYearConstraints() {
    final c = _getConstraint();
    if (c == null || modelYear == null) {
      // If no constraint or no year selected, show all engines/transmissions for this car
      if (c != null) {
        final rawEngines = c['all_engines'];
        if (rawEngines is List) {
          _filteredEngines = rawEngines.map((e) => (e as num).toInt()).toList();
        } else {
          _filteredEngines = _getIntList('engine_capacities');
        }

        final rawTrans = c['all_transmissions'];
        if (rawTrans is List) {
          _filteredTransmissions = rawTrans.map((e) => e.toString()).toList();
        } else {
          _filteredTransmissions = _getStringList('transmissions');
        }

        final rawColors = c['all_colors'];
        if (rawColors is List) {
          _filteredColors = rawColors.map((e) => e.toString()).toList();
        } else {
          _filteredColors = _getStringList('colors');
        }
      } else {
        _filteredEngines = _getIntList('engine_capacities');
        _filteredTransmissions = _getStringList('transmissions');
        _filteredColors = _getStringList('colors');
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
        final years = (r['years'] as List<dynamic>)
            .map((e) => (e as num).toInt())
            .toList();
        if (years.length == 2 && year >= years[0] && year <= years[1]) {
          matchedEngines = (r['engines'] as List<dynamic>)
              .map((e) => (e as num).toInt())
              .toList();
          break;
        }
      }
      final rawAllEngines = c['all_engines'];
      _filteredEngines =
          matchedEngines ??
          (rawAllEngines is List
              ? rawAllEngines.map((e) => (e as num).toInt()).toList()
              : _getIntList('engine_capacities'));
    }

    // Find matching transmission range for the selected year
    final transByYear = c['transmission_by_year'] as Map<String, dynamic>?;
    if (transByYear != null) {
      final ranges = transByYear['ranges'] as List<dynamic>? ?? [];
      List<String>? matchedTrans;
      for (final range in ranges) {
        final r = range as Map<String, dynamic>;
        final years = (r['years'] as List<dynamic>)
            .map((e) => (e as num).toInt())
            .toList();
        if (years.length == 2 && year >= years[0] && year <= years[1]) {
          matchedTrans = (r['transmissions'] as List<dynamic>)
              .map((e) => e.toString())
              .toList();
          break;
        }
      }
      final rawAllTrans = c['all_transmissions'];
      _filteredTransmissions =
          matchedTrans ??
          (rawAllTrans is List
              ? rawAllTrans.map((e) => e.toString()).toList()
              : _getStringList('transmissions'));
    }

    // Find matching color range for the selected year (e.g. excludes old gen colors from modern cars)
    final colorByYear = c['color_by_year'] as Map<String, dynamic>?;
    if (colorByYear != null) {
      final ranges = colorByYear['ranges'] as List<dynamic>? ?? [];
      List<String>? matchedColors;
      for (final range in ranges) {
        final r = range as Map<String, dynamic>;
        final years = (r['years'] as List<dynamic>)
            .map((e) => (e as num).toInt())
            .toList();
        if (years.length == 2 && year >= years[0] && year <= years[1]) {
          matchedColors = (r['colors'] as List<dynamic>)
              .map((e) => e.toString())
              .toList();
          break;
        }
      }
      final rawAllColors = c['all_colors'];
      _filteredColors =
          matchedColors ??
          (rawAllColors is List
              ? rawAllColors.map((e) => e.toString()).toList()
              : _getStringList('colors'));
    }

    // Auto-select if only one option available
    if (_filteredEngines.length == 1) {
      engineCc = _filteredEngines.first;
    } else if (engineCc != null && !_filteredEngines.contains(engineCc)) {
      engineCc = null;
    }

    if (_filteredTransmissions.length == 1) {
      transmission = _filteredTransmissions.first;
    } else if (transmission != null &&
        !_filteredTransmissions.contains(transmission)) {
      transmission = null;
    }

    if (color != null && !_filteredColors.contains(color)) {
      color = null;
    }

    // Reset Un-Registered if selected car year is not 2026
    if (year != 2026 && city == 'Un-Registered') {
      city = null;
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
      color = null;
      assembly = null;
      _autoBodyType = null;
      _isBodyTypeLocked = false;
      // Reset to full lists when brand changes
      _filteredYears = _getIntList('model_years');
      _filteredEngines = _getIntList('engine_capacities');
      _filteredTransmissions = _getStringList('transmissions');
      _filteredAssemblies = _getStringList('assemblies');
      _filteredColors = _getStringList('colors');
    });
  }

  void _onModelChanged(String? newModel) {
    setState(() {
      model = newModel;
      variant = null;
      modelYear = null;
      engineCc = null;
      transmission = null;

      // Auto-select variant if only 1 variant exists for this car model
      if (newModel != null && brand != null) {
        final variantsByBrandModel =
            options['variants_by_brand_model'] as Map<String, dynamic>? ?? {};
        final key = "${brand}_$newModel";
        if (variantsByBrandModel.containsKey(key)) {
          final vList = (variantsByBrandModel[key] as List<dynamic>)
              .map((e) => e.toString())
              .toList();
          if (vList.length == 1) {
            variant = vList.first;
          }
        }
      }

      // Apply constraints for the new Brand_Model / Variant
      _applyCarConstraints();
    });
  }

  void _onVariantChanged(String? newVariant) {
    setState(() {
      variant = newVariant;
      modelYear = null;
      engineCc = null;
      transmission = null;
      // Re-apply car constraints for variant-level rules
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

  static const int _absoluteMaxMileage = 999999;
  static const int _baseMileage2026 = 75000;
  static const int _yearStepDiff = 60000;

  int _getMaxMileage(int? year) {
    if (year == null) {
      final rules = options['mileage_rules'] as Map<String, dynamic>?;
      if (rules != null && rules['absolute_max'] != null) {
        return (rules['absolute_max'] as num).toInt();
      }
      return _absoluteMaxMileage;
    }
    // Check dynamic rules from backend options first
    final rules = options['mileage_rules'] as Map<String, dynamic>?;
    if (rules != null) {
      final maxByYear = rules['max_by_year'] as Map<String, dynamic>?;
      if (maxByYear != null) {
        final val = maxByYear[year.toString()];
        if (val != null) {
          return (val as num).toInt();
        }
      }
    }
    // Fallback formula: consistent step progression (+60,000/yr) capped at 999,999 km
    if (year > 2026) return _baseMileage2026;
    final val = _baseMileage2026 + (2026 - year) * _yearStepDiff;
    return val > _absoluteMaxMileage ? _absoluteMaxMileage : val;
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
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields!'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final kmNum = double.tryParse(mileageController.text.replaceAll(',', '').trim());
    final maxAllowed = _getMaxMileage(modelYear);
    if (kmNum == null || kmNum < 0 || kmNum > maxAllowed) {
      final formattedMax = maxAllowed.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Mileage must be between 0 and $formattedMax km for model year ${modelYear ?? ""}.',
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    final navigator = Navigator.of(context, rootNavigator: true);
    final loadingRoute = DialogRoute<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.48),
      builder: (_) => PopScope(
        canPop: false,
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          backgroundColor: Colors.white,
          elevation: 24,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 380),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryBorder,
                      width: 2,
                    ),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 34,
                      height: 34,
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 3.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Predicting Market Price…',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Evaluating vehicle parameters against Pakistan automotive market trends…',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    navigator.push<void>(loadingRoute);

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
        'mileage_km': double.parse(mileageController.text.replaceAll(',', '').trim()),
      };

      final stopwatch = Stopwatch()..start();
      final result = await PredictionService.predictPrice(data);

      // Keep loading animation visible for 3 seconds as requested
      final remainingMs = 3000 - stopwatch.elapsedMilliseconds;
      if (remainingMs > 0) {
        await Future.delayed(Duration(milliseconds: remainingMs));
      }

      if (navigator.mounted && loadingRoute.isActive) {
        navigator.removeRoute(loadingRoute);
      }

      if (!mounted) return;

      setState(() {
        isPredicting = false;
        predictionResult = result['formatted_price'];
      });

      if (mounted) {
        showDialog(
          context: context,
          barrierColor: Colors.black.withValues(alpha: 0.48),
          builder: (ctx) => PredictionResultDialog(
            formattedPrice: result['formatted_price'],
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
            mileageKm: mileageController.text,
            userService: widget.userService,
          ),
        );
      }
    } catch (e) {
      if (navigator.mounted && loadingRoute.isActive) {
        navigator.removeRoute(loadingRoute);
      }
      if (!mounted) return;
      setState(() {
        isPredicting = false;
      });
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Prediction failed: $e'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (kIsWeb && MediaQuery.sizeOf(context).width >= 950) {
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
              onVariantChanged: _onVariantChanged,
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
              filteredColors: _filteredColors,
              maxMileage: _getMaxMileage(modelYear),
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
            onVariantChanged: _onVariantChanged,
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
            filteredColors: _filteredColors,
            maxMileage: _getMaxMileage(modelYear),
            isBodyTypeLocked: _isBodyTypeLocked,
          );
        },
      ),
    );
  }
}
