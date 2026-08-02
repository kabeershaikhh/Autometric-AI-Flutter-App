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

  void _onBrandChanged(String? newBrand) {
    setState(() {
      brand = newBrand;
      model = null; // Clear dependent fields
      variant = null;
    });
  }

  void _onModelChanged(String? newModel) {
    setState(() {
      model = newModel;
      variant = null;
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
              onModelYearChanged: (v) => setState(() => modelYear = v),
              onEngineCcChanged: (v) => setState(() => engineCc = v),
              onTransmissionChanged: (v) => setState(() => transmission = v),
              onBodyTypeChanged: (v) => setState(() => bodyType = v),
              onColorChanged: (v) => setState(() => color = v),
              onAssemblyChanged: (v) => setState(() => assembly = v),
              onCityChanged: (v) => setState(() => city = v),
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
            onModelYearChanged: (v) => setState(() => modelYear = v),
            onEngineCcChanged: (v) => setState(() => engineCc = v),
            onTransmissionChanged: (v) => setState(() => transmission = v),
            onBodyTypeChanged: (v) => setState(() => bodyType = v),
            onColorChanged: (v) => setState(() => color = v),
            onAssemblyChanged: (v) => setState(() => assembly = v),
            onCityChanged: (v) => setState(() => city = v),
          );
        },
      ),
    );
  }
}
