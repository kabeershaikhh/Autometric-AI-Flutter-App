import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../components/decorated_header.dart';
import '../constants/app_colors.dart';
import 'controller.dart';
import 'models.dart';
import 'repository.dart';
import 'reminder_page.dart';
import 'service_form.dart';
import 'vehicle_form.dart';
import 'attachments.dart';
import 'widgets.dart';

class VehicleDetails extends StatefulWidget {
  final MaintenanceController controller;
  final String vehicleId;
  const VehicleDetails({
    super.key,
    required this.controller,
    required this.vehicleId,
  });
  @override
  State<VehicleDetails> createState() => _VehicleDetailsState();
}

class _VehicleDetailsState extends State<VehicleDetails> {
  final _history = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
  bool _loading = false, _more = true, _busy = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool reset = false}) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
      if (reset) {
        _history.clear();
        _more = true;
      }
    });
    try {
      var query = widget.controller.repository!.vehicles
          .doc(widget.vehicleId)
          .collection('serviceRecords')
          .orderBy('date', descending: true)
          .limit(20);
      if (_history.isNotEmpty) query = query.startAfterDocument(_history.last);
      final page = await query.get();
      if (mounted) {
        setState(() {
          _history.addAll(page.docs);
          _more = page.docs.length == 20;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Unable to load service history. Try again.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _service(
    MaintenanceVehicle car, {
    QueryDocumentSnapshot<Map<String, dynamic>>? record,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ServiceForm(
          repository: widget.controller.repository!,
          vehicle: car,
          serviceId: record?.id,
          record: record?.data(),
        ),
      ),
    );
    if (mounted) _load(reset: true);
  }

  Future<void> _action(MaintenanceVehicle car, String action) async {
    final repo = widget.controller.repository!;
    if (action == 'edit') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VehicleForm(repository: repo, vehicle: car),
        ),
      );
      return;
    }
    final delete = action == 'delete';
    if (!await maintenanceConfirm(
          context,
          delete
              ? 'Delete car?'
              : car.archived
              ? 'Restore car?'
              : 'Archive car?',
          delete
              ? 'This permanently deletes this car, its services, readings and images. This cannot be undone.'
              : car.archived
              ? 'Restore this car and its maintenance reminders?'
              : 'Keep service history but stop reminders for this car?',
        ) ||
        !mounted) {
      return;
    }
    setState(() => _busy = true);
    try {
      if (delete) {
        await repo.deleteVehicle(car.id);
        if (mounted) Navigator.pop(context);
      } else {
        await repo.archive(car);
      }
    } catch (e) {
      if (mounted) maintenanceError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _carMenu(MaintenanceVehicle car) => PopupMenuButton<String>(
    tooltip: 'Car options',
    enabled: !_busy,
    icon: const Icon(Icons.more_vert_rounded, color: AppColors.primary),
    onSelected: (action) => _action(car, action),
    itemBuilder: (_) => [
      const PopupMenuItem(value: 'edit', child: Text('Edit car')),
      PopupMenuItem(
        value: 'archive',
        child: Text(car.archived ? 'Restore car' : 'Archive car'),
      ),
      const PopupMenuItem(value: 'delete', child: Text('Delete car')),
    ],
  );

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) {
      final controller = widget.controller;
      final repo = controller.repository;
      final matches = controller.vehicles.where(
        (v) => v.id == widget.vehicleId,
      );
      if (repo == null || matches.isEmpty) {
        return Scaffold(
          primary: false,
          appBar: maintenanceAppBar(context, 'Vehicle details'),
          body: const Center(child: Text('This car is no longer available.')),
        );
      }
      final car = matches.first;
      final due = controller.reminders
          .where((r) => r.vehicle.id == car.id)
          .toList();
      return PopScope(
        canPop: !_busy,
        child: Scaffold(
          primary: false,
          backgroundColor: AppColors.scaffoldBg,
          appBar: maintenanceAppBar(context, 'Vehicle details'),
          body: AbsorbPointer(
            absorbing: _busy,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (_busy) const LinearProgressIndicator(),
                MaintenanceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.primarySurface,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const CarLogo(size: 32),
                          ),
                          const Spacer(),
                          _carMenu(car),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        car.name,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _info(
                            'License plate',
                            car.plate.isEmpty ? 'Not provided' : car.plate,
                          ),
                          _info('Model year', '${car.year}'),
                          _info('Fuel', car.fuel),
                          _info('Odometer', '${numberLabel(car.odometer)} km'),
                          _info('Last reading', dateLabel(car.readingDate)),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 12,
                        runSpacing: 10,
                        children: [
                          OutlinedButton.icon(
                            style: maintenanceOutlineButton(),
                            onPressed: car.archived
                                ? null
                                : () => updateMileageDialog(context, repo, car),
                            icon: const Icon(Icons.speed_rounded),
                            label: const Text('Update mileage'),
                          ),
                          FilledButton.icon(
                            onPressed: car.archived
                                ? null
                                : () => _service(car),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              minimumSize: const Size(0, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Add service / schedule'),
                          ),
                        ],
                      ),
                      if (car.archived)
                        const Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: Text(
                            'Archived • restore this car to resume maintenance.',
                            style: TextStyle(color: AppColors.textGrey),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Upcoming maintenance',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                if (due.isEmpty)
                  const MaintenanceCard(
                    child: Text(
                      'No active schedules. Add a service and choose its next interval.',
                      style: TextStyle(color: AppColors.textGrey),
                    ),
                  ),
                for (final item in due)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: DueCard(
                      key: ValueKey(item.key),
                      due: item,
                      controller: controller,
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Service history',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Refresh history',
                      onPressed: _loading ? null : () => _load(reset: true),
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                  ],
                ),
                if (_error != null)
                  TextButton(onPressed: () => _load(), child: Text(_error!)),
                if (_history.isEmpty && !_loading && _error == null)
                  const MaintenanceCard(
                    child: Text(
                      'Your service records will appear here.',
                      style: TextStyle(color: AppColors.textGrey),
                    ),
                  ),
                for (final record in _history)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: MaintenanceCard(
                      padding: const EdgeInsets.all(16),
                      child: _historyCard(car, record),
                    ),
                  ),
                if (_loading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                if (_more && !_loading && _history.isNotEmpty)
                  TextButton(
                    onPressed: _load,
                    child: const Text('Load 20 more'),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      );
    },
  );
  Widget _historyCard(
    MaintenanceVehicle car,
    QueryDocumentSnapshot<Map<String, dynamic>> record,
  ) {
    final data = record.data();
    final plan = data['plannedOnly'] == true;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                (data['types'] as List).join(' • '),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Edit record',
              onPressed: car.archived
                  ? null
                  : () => _service(car, record: record),
              icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
            ),
          ],
        ),
        Text(
          '${plan ? 'Schedule baseline' : 'Completed'} • ${dateLabel(dateValue(data['date']))} • ${numberLabel(data['odometer'] as int)} km',
          style: const TextStyle(color: AppColors.textGrey),
        ),
        if (!plan)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              costLabel(data['costPaisa'] as int),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        if ((data['workshop'] as String? ?? '').isNotEmpty)
          Text(
            data['workshop'] as String,
            style: const TextStyle(color: AppColors.textGrey),
          ),
        if ((data['notes'] as String? ?? '').isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              data['notes'] as String,
              style: const TextStyle(color: AppColors.textLight),
            ),
          ),
        if (data['hasReceipt'] == true)
          TextButton.icon(
            onPressed: () => showDialog(
              context: context,
              builder: (_) => Dialog(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: AttachmentImage(
                          repository: widget.controller.repository!,
                          vehicleId: car.id,
                          attachmentId: 'receipt_${record.id}',
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.of(context, rootNavigator: true).pop(),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            icon: const Icon(Icons.receipt_long_outlined),
            label: const Text('View receipt'),
          ),
      ],
    );
  }

  Widget _info(String label, String value) => Container(
    width: 128,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.primarySurface,
      border: Border.all(color: AppColors.primaryBorder),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.primary, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

Future<void> updateMileageDialog(
  BuildContext context,
  MaintenanceRepository repository,
  MaintenanceVehicle car,
) async {
  final km = TextEditingController(text: '${car.odometer}');
  final form = GlobalKey<FormState>();
  var date = pakistanDay(DateTime.now());
  var correction = false;
  var busy = false;
  try {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, update) => PopScope(
          canPop: !busy,
          child: Dialog(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const DecoratedHeader(
                      title: 'Update mileage',
                      icon: Icons.speed_rounded,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: form,
                        child: AbsorbPointer(
                          absorbing: busy,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              MaintenanceTextField(
                                controller: km,
                                keyboardType: TextInputType.number,
                                label: 'Confirmed odometer',
                                suffix: 'km',
                                validator: (v) {
                                  final value = int.tryParse(v ?? '');
                                  return value == null ||
                                          value < 0 ||
                                          value > 3000000
                                      ? 'Enter 0–3,000,000 km'
                                      : null;
                                },
                              ),
                              const SizedBox(height: 16),
                              DateField(
                                label: 'Reading date',
                                date: date,
                                onTap: () async {
                                  final picked = await pickMaintenanceDate(
                                    ctx,
                                    date,
                                  );
                                  if (ctx.mounted && picked != null) {
                                    update(
                                      () => date = DateTime.utc(
                                        picked.year,
                                        picked.month,
                                        picked.day,
                                      ),
                                    );
                                  }
                                },
                              ),
                              CheckboxListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text(
                                  'Odometer correction / replacement',
                                ),
                                subtitle: const Text(
                                  'Allows a lower reading and resets the driving-rate estimate. Existing service thresholds must be reviewed.',
                                ),
                                value: correction,
                                onChanged: (v) => update(() => correction = v!),
                              ),
                              const SizedBox(height: 16),
                              FormActions(
                                busy: busy,
                                onSave: () async {
                                  if (!form.currentState!.validate()) return;
                                  update(() => busy = true);
                                  try {
                                    await repository.updateMileage(
                                      car.id,
                                      int.parse(km.text),
                                      date,
                                      correction: correction,
                                    );
                                    if (ctx.mounted) Navigator.pop(ctx);
                                  } catch (e) {
                                    if (ctx.mounted) {
                                      maintenanceError(ctx, e);
                                      update(() => busy = false);
                                    }
                                  }
                                },
                              ),
                            ],
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
      ),
    );
  } finally {
    km.dispose();
  }
}
