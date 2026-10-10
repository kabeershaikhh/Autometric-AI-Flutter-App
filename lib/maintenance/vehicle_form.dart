import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'models.dart';
import 'repository.dart';
import 'widgets.dart';

class VehicleForm extends StatefulWidget {
  final MaintenanceRepository repository;
  final MaintenanceVehicle? vehicle;
  const VehicleForm({super.key, required this.repository, this.vehicle});
  @override
  State<VehicleForm> createState() => _VehicleFormState();
}

class _VehicleFormState extends State<VehicleForm> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _make, _model, _year, _plate, _km, _weekly;
  late DateTime _date;
  late String _fuel;
  bool _busy = false;
  @override
  void initState() {
    super.initState();
    final v = widget.vehicle;
    _make = TextEditingController(text: v?.manufacturer);
    _model = TextEditingController(text: v?.model);
    _year = TextEditingController(text: v?.year.toString());
    _plate = TextEditingController(text: v?.plate);
    _km = TextEditingController(text: v?.odometer.toString());
    _weekly = TextEditingController(text: v?.weeklyKm?.toString());
    _fuel = v?.fuel ?? 'Petrol';
    _date = v?.readingDate ?? pakistanDay(DateTime.now());
  }

  @override
  void dispose() {
    for (final c in [_make, _model, _year, _plate, _km, _weekly]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    if (widget.vehicle != null && _date.isBefore(widget.vehicle!.readingDate)) {
      maintenanceError(
        context,
        StateError('Reading date cannot precede the latest reading.'),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      await widget.repository.saveVehicle({
        'manufacturer': _make.text.trim(),
        'model': _model.text.trim(),
        'year': int.parse(_year.text),
        'plate': _plate.text.trim(),
        'fuel': _fuel,
        'odometer': int.parse(_km.text),
        'readingDate': Timestamp.fromDate(_date),
        'weeklyKm': _weekly.text.trim().isEmpty
            ? null
            : double.parse(_weekly.text),
      }, existing: widget.vehicle);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) maintenanceError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool numeric = false,
    String? Function(String?)? validator,
    String? suffix,
    int max = 60,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: MaintenanceTextField(
      controller: controller,
      maxLength: max,
      keyboardType: numeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      label: label,
      suffix: suffix,
      validator:
          validator ?? (v) => v == null || v.trim().isEmpty ? 'Required' : null,
    ),
  );
  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy,
    child: Scaffold(
      primary: false,
      backgroundColor: AppColors.scaffoldBg,
      appBar: maintenanceAppBar(
        context,
        widget.vehicle == null ? 'Add car' : 'Edit car',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: MaintenanceCard(
              child: Form(
                key: _form,
                child: AbsorbPointer(
                  absorbing: _busy,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const MaintenanceHeading(
                        title: 'Your car, your garage',
                        subtitle:
                            'Independent from price predictions. All mileage is in kilometres.',
                      ),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const CarLogo(size: 32),
                      ),
                      const SizedBox(height: 24),
                      _field(_make, 'Manufacturer', suffix: null),
                      _field(_model, 'Model / variant'),
                      _field(
                        _year,
                        'Model year',
                        numeric: true,
                        max: 4,
                        validator: (v) {
                          final year = int.tryParse(v ?? '');
                          return year == null ||
                                  year < 1950 ||
                                  year > pakistanDay(DateTime.now()).year + 1
                              ? 'Enter a valid model year'
                              : null;
                        },
                      ),
                      _field(
                        _plate,
                        'License plate (optional)',
                        max: 24,
                        validator: (_) => null,
                      ),
                      DropdownButtonFormField<String>(
                        value: _fuel,
                        decoration: maintenanceInput('Fuel / powertrain'),
                        items:
                            [
                                  'Petrol',
                                  'Diesel',
                                  'Hybrid',
                                  'Electric',
                                  'CNG',
                                  'Other',
                                ]
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s),
                                  ),
                                )
                                .toList(),
                        onChanged: (v) => setState(() => _fuel = v!),
                      ),
                      const SizedBox(height: 18),
                      _field(
                        _km,
                        'Current odometer',
                        numeric: true,
                        suffix: 'km',
                        max: 7,
                        validator: (v) {
                          final km = int.tryParse(v ?? '');
                          return km == null || km < 0 || km > 3000000
                              ? 'Enter 0–3,000,000 km'
                              : null;
                        },
                      ),
                      DateField(
                        label: 'Odometer reading date',
                        date: _date,
                        onTap: () async {
                          final date = await pickMaintenanceDate(
                            context,
                            _date,
                          );
                          if (mounted && date != null) {
                            setState(
                              () => _date = DateTime.utc(
                                date.year,
                                date.month,
                                date.day,
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 18),
                      _field(
                        _weekly,
                        'Usual driving per week (optional)',
                        numeric: true,
                        suffix: 'km/week',
                        max: 8,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return null;
                          final km = double.tryParse(v);
                          return km == null ||
                                  !km.isFinite ||
                                  km <= 0 ||
                                  km > 10000
                              ? 'Enter 1–10,000 km or leave blank'
                              : null;
                        },
                      ),
                      const Text(
                        'Driving estimates help forecast service dates. They never replace your confirmed odometer.',
                        style: TextStyle(
                          color: AppColors.textGrey,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      FormActions(busy: _busy, onSave: _save),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
