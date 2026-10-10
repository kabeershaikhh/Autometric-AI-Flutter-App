import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'attachments.dart';
import 'models.dart';
import 'repository.dart';
import 'widgets.dart';

const serviceTypes = [
  'Engine oil change',
  'Oil filter',
  'Air filter',
  'Cabin filter',
  'Brake inspection',
  'Brake pads',
  'Tyre rotation',
  'Tyre change',
  'Wheel alignment',
  'Spark plugs',
  'Battery inspection',
  'Air conditioning',
  'General inspection',
];

class _Interval {
  final km = TextEditingController(), months = TextEditingController();
  void dispose() {
    km.dispose();
    months.dispose();
  }
}

class ServiceForm extends StatefulWidget {
  final MaintenanceRepository repository;
  final MaintenanceVehicle vehicle;
  final String? serviceId;
  final Map<String, dynamic>? record;
  const ServiceForm({
    super.key,
    required this.repository,
    required this.vehicle,
    this.serviceId,
    this.record,
  });
  @override
  State<ServiceForm> createState() => _ServiceFormState();
}

class _ServiceFormState extends State<ServiceForm> {
  final _form = GlobalKey<FormState>();
  final _intervals = <String, _Interval>{};
  late final TextEditingController _km, _cost, _notes, _workshop;
  final _custom = TextEditingController();
  late DateTime _date;
  Uint8List? _receipt;
  bool _busy = false, _picking = false, _removeReceipt = false, _plan = false;
  @override
  void initState() {
    super.initState();
    final record = widget.record;
    _date = record == null
        ? pakistanDay(DateTime.now())
        : dateValue(record['date']);
    _km = TextEditingController(
      text: (record?['odometer'] ?? widget.vehicle.odometer).toString(),
    );
    final paisa = record?['costPaisa'] as int?;
    _cost = TextEditingController(
      text: paisa == null
          ? ''
          : '${paisa ~/ 100}.${(paisa % 100).toString().padLeft(2, '0')}',
    );
    _notes = TextEditingController(text: record?['notes']);
    _workshop = TextEditingController(text: record?['workshop']);
    _plan = record?['plannedOnly'] == true;
    for (final type in record?['types'] as List? ?? []) {
      final rule = (record?['intervals'] as Map?)?[type] as Map?;
      final interval = _Interval();
      interval.km.text = rule?['km']?.toString() ?? '';
      interval.months.text = rule?['months']?.toString() ?? '';
      _intervals[type as String] = interval;
    }
  }

  @override
  void dispose() {
    for (final c in [_km, _cost, _notes, _workshop, _custom]) {
      c.dispose();
    }
    for (final rule in _intervals.values) {
      rule.dispose();
    }
    super.dispose();
  }

  void _toggle(String type) {
    setState(() {
      final rule = _intervals.remove(type);
      if (rule != null) {
        rule.dispose();
      } else if (_intervals.length < 10) {
        _intervals[type] = _Interval();
      }
    });
  }

  Future<void> _pick() async {
    setState(() => _picking = true);
    try {
      final bytes = await pickMaintenanceReceipt();
      if (mounted && bytes != null) {
        setState(() {
          _receipt = bytes;
          _removeReceipt = false;
        });
      }
    } catch (e) {
      if (mounted) maintenanceError(context, e);
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    if (_intervals.isEmpty) {
      maintenanceError(
        context,
        StateError('Select at least one service type.'),
      );
      return;
    }
    final km = int.parse(_km.text);
    if (_plan &&
        _intervals.values.every(
          (v) => v.km.text.trim().isEmpty && v.months.text.trim().isEmpty,
        )) {
      maintenanceError(
        context,
        StateError(
          'A schedule-only record needs at least one distance or time interval.',
        ),
      );
      return;
    }
    if (_date.isBefore(widget.vehicle.readingDate) &&
        km > widget.vehicle.odometer) {
      maintenanceError(
        context,
        StateError(
          'An older service cannot have more mileage than your latest reading.',
        ),
      );
      return;
    }
    if (_date.isAfter(widget.vehicle.readingDate) &&
        km < widget.vehicle.odometer) {
      maintenanceError(
        context,
        StateError(
          'For an older service, choose its actual earlier date. To correct the current odometer, use Update mileage.',
        ),
      );
      return;
    }
    final schedules = <MaintenanceSchedule>[];
    final intervals = <String, dynamic>{};
    for (final entry in _intervals.entries) {
      final distance = int.tryParse(entry.value.km.text);
      final months = int.tryParse(entry.value.months.text);
      intervals[entry.key] = {'km': distance, 'months': months};
      schedules.add(
        MaintenanceSchedule(
          type: entry.key,
          cycle: '',
          dueKm: distance == null ? null : km + distance,
          dueDate: months == null ? null : addMonths(_date, months),
        ),
      );
    }
    setState(() => _busy = true);
    try {
      await widget.repository.saveService(
        widget.vehicle.id,
        {
          'types': _intervals.keys.toList(),
          'date': Timestamp.fromDate(_date),
          'odometer': km,
          'costPaisa': _plan ? 0 : parsePaisa(_cost.text) ?? 0,
          'notes': _notes.text.trim(),
          'workshop': _workshop.text.trim(),
          'plannedOnly': _plan,
          'intervals': intervals,
        },
        schedules,
        serviceId: widget.serviceId,
        receipt: _receipt,
        removeReceipt: _removeReceipt,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) maintenanceError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _numeric(
    TextEditingController controller,
    String label, {
    String? suffix,
    bool optional = false,
    int max = 1000000,
  }) => MaintenanceTextField(
    controller: controller,
    keyboardType: TextInputType.number,
    label: label,
    suffix: suffix,
    validator: (v) {
      if (optional && (v == null || v.trim().isEmpty)) return null;
      final n = int.tryParse(v ?? '');
      return n == null || n < (optional ? 1 : 0) || n > max
          ? 'Enter ${optional ? 1 : 0}–$max'
          : null;
    },
  );
  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy,
    child: Scaffold(
      primary: false,
      backgroundColor: AppColors.scaffoldBg,
      appBar: maintenanceAppBar(
        context,
        widget.record == null ? 'Add service / schedule' : 'Edit service',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: MaintenanceCard(
              child: Form(
                key: _form,
                child: AbsorbPointer(
                  absorbing: _busy,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MaintenanceHeading(
                        title: widget.vehicle.name,
                        subtitle:
                            'Choose services and set a separate next-service interval for each.',
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Schedule only — not a completed service',
                        ),
                        subtitle: const Text(
                          'Use this if your previous service details are unknown.',
                        ),
                        value: _plan,
                        onChanged: (v) => setState(() => _plan = v),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: {...serviceTypes, ..._intervals.keys}
                            .map(
                              (s) => FilterChip(
                                label: Text(s),
                                selected: _intervals.containsKey(s),
                                onSelected: (_) => _toggle(s),
                                selectedColor: AppColors.primarySurface,
                                checkmarkColor: AppColors.primary,
                                side: BorderSide(
                                  color: _intervals.containsKey(s)
                                      ? AppColors.primary
                                      : AppColors.primaryBorder,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: MaintenanceTextField(
                              controller: _custom,
                              maxLength: 50,
                              label: 'Custom service type',
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filled(
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(52, 52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () {
                              final type = _custom.text.trim();
                              if (type.isNotEmpty &&
                                  !_intervals.keys.any(
                                    (s) =>
                                        s.toLowerCase() == type.toLowerCase(),
                                  )) {
                                _toggle(type);
                                _custom.clear();
                              }
                            },
                            tooltip: 'Add custom type',
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _numeric(
                        _km,
                        _plan ? 'Odometer baseline' : 'Odometer at service',
                        suffix: 'km',
                        max: 3000000,
                      ),
                      const SizedBox(height: 18),
                      DateField(
                        label: _plan
                            ? 'Schedule baseline date'
                            : 'Service date',
                        date: _date,
                        onTap: () async {
                          final picked = await pickMaintenanceDate(
                            context,
                            _date,
                          );
                          if (mounted && picked != null) {
                            setState(
                              () => _date = DateTime.utc(
                                picked.year,
                                picked.month,
                                picked.day,
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Next maintenance',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Follow your owner’s manual or mechanic’s advice. Leave both fields blank for a one-off service. If both are set, whichever comes first applies.',
                        style: TextStyle(
                          color: AppColors.textGrey,
                          height: 1.5,
                        ),
                      ),
                      for (final entry in _intervals.entries)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: MaintenanceCard(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.key,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                LayoutBuilder(
                                  builder: (_, constraints) {
                                    final fields = [
                                      _numeric(
                                        entry.value.km,
                                        'After distance',
                                        suffix: 'km',
                                        optional: true,
                                        max: 100000,
                                      ),
                                      _numeric(
                                        entry.value.months,
                                        'After time',
                                        suffix: 'months',
                                        optional: true,
                                        max: 120,
                                      ),
                                    ];
                                    return constraints.maxWidth > 440
                                        ? Row(
                                            children: [
                                              Expanded(child: fields[0]),
                                              const SizedBox(width: 12),
                                              Expanded(child: fields[1]),
                                            ],
                                          )
                                        : Column(
                                            children: [
                                              fields[0],
                                              const SizedBox(height: 12),
                                              fields[1],
                                            ],
                                          );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                      if (!_plan) ...[
                        MaintenanceTextField(
                          controller: _cost,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          label: 'Total cost (optional)',
                          suffix: 'PKR',
                          validator: (v) =>
                              v == null ||
                                  v.trim().isEmpty ||
                                  parsePaisa(v) != null
                              ? null
                              : 'Enter a valid PKR amount with up to two decimal places',
                        ),
                        const SizedBox(height: 18),
                        MaintenanceTextField(
                          controller: _workshop,
                          maxLength: 100,
                          label: 'Workshop (optional)',
                        ),
                        const SizedBox(height: 12),
                      ],
                      MaintenanceTextField(
                        controller: _notes,
                        maxLength: 1000,
                        minLines: 3,
                        maxLines: 5,
                        label: 'Notes (optional)',
                      ),
                      if (!_plan) ...[
                        OutlinedButton.icon(
                          style: maintenanceOutlineButton(),
                          onPressed: _picking ? null : _pick,
                          icon: const Icon(Icons.receipt_long_outlined),
                          label: Text(
                            _picking ? 'Compressing…' : 'Attach receipt image',
                          ),
                        ),
                        if (_receipt != null)
                          SizedBox(height: 180, child: Image.memory(_receipt!)),
                        if (_receipt != null ||
                            widget.record?['hasReceipt'] == true &&
                                !_removeReceipt)
                          OutlinedButton(
                            style: maintenanceOutlineButton(),
                            onPressed: () => setState(() {
                              _receipt = null;
                              _removeReceipt = true;
                            }),
                            child: const Text('Remove receipt'),
                          ),
                        const Text(
                          'Optional • up to 200 KB after compression. Keep the original receipt separately.',
                          style: TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      FormActions(busy: _busy || _picking, onSave: _save),
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
