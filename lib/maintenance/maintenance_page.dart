import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../components/web_feature_header.dart';
import '../constants/app_colors.dart';
import 'controller.dart';
import 'models.dart';
import 'vehicle_form.dart';
import 'vehicle_details.dart';
import 'reminder_page.dart';
import 'widgets.dart';

class MaintenancePage extends StatefulWidget {
  final MaintenanceController controller;
  const MaintenancePage({super.key, required this.controller});
  @override
  State<MaintenancePage> createState() => MaintenancePageState();
}

class MaintenancePageState extends State<MaintenancePage> {
  var _navigator = GlobalKey<NavigatorState>();
  String? _account;
  bool get canGoBack => _navigator.currentState?.canPop() ?? false;
  void goBack() => _navigator.currentState?.maybePop();
  void openReminders() {
    _navigator.currentState?.popUntil((route) => route.isFirst);
    _navigator.currentState?.push(
      MaterialPageRoute(
        builder: (_) => ReminderPage(controller: widget.controller),
      ),
    );
  }

  void openVehicle(String id) {
    final repo = widget.controller.repository;
    if (repo == null || !widget.controller.vehicles.any((v) => v.id == id)) {
      return;
    }
    _navigator.currentState?.popUntil((route) => route.isFirst);
    _navigator.currentState?.push(
      MaterialPageRoute(
        builder: (_) =>
            VehicleDetails(controller: widget.controller, vehicleId: id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (_, child) {
      final account = widget.controller.repository?.uid;
      if (_account != account) {
        _account = account;
        _navigator = GlobalKey<NavigatorState>();
      }
      return Navigator(
        key: _navigator,
        onGenerateRoute: (_) => MaterialPageRoute(
          builder: (_) => _Garage(controller: widget.controller),
        ),
      );
    },
  );
}

class _Garage extends StatefulWidget {
  final MaintenanceController controller;
  const _Garage({required this.controller});
  @override
  State<_Garage> createState() => _GarageState();
}

class _GarageState extends State<_Garage> {
  bool _archived = false;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) {
      final controller = widget.controller;
      final repo = controller.repository;
      if (repo == null) {
        return const Center(child: Text('Sign in to manage your garage.'));
      }
      if (controller.loading) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.error != null) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(controller.error!, textAlign: TextAlign.center),
          ),
        );
      }
      final cars = controller.vehicles
          .where((v) => v.archived == _archived)
          .toList();
      final due = controller.reminders;
      final unread = due.where((r) => r.actionable && !r.schedule.read).length;
      final wide = kIsWeb && MediaQuery.sizeOf(context).width >= 950;
      return Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        floatingActionButton: FloatingActionButton.extended(
          elevation: 0,
          highlightElevation: 0,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => VehicleForm(repository: repo)),
          ),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add car'),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: wide ? 1000 : double.infinity,
            ),
            child: ListView(
              padding: wide
                  ? const EdgeInsets.symmetric(horizontal: 40, vertical: 32)
                  : const EdgeInsets.all(18),
              children: [
                if (wide) ...[
                  const WebFeatureHeader(
                    badge: 'Vehicle Care',
                    badgeIcon: Icons.build_rounded,
                    title: 'Your garage, under control',
                    subtitle:
                        'Track services, plan ahead and keep every car cared for.',
                    icon: Icons.build_outlined,
                  ),
                  const SizedBox(height: 28),
                ],
                Row(
                  children: [
                    _stat(
                      'Cars',
                      controller.vehicles.where((v) => !v.archived).length,
                      Icons.directions_car_outlined,
                    ),
                    const SizedBox(width: 12),
                    _stat(
                      'Due / overdue',
                      due.where((r) => r.status == DueStatus.due).length,
                      Icons.warning_amber_rounded,
                    ),
                    const SizedBox(width: 12),
                    _stat(
                      'Due soon',
                      due
                          .where(
                            (r) =>
                                r.status == DueStatus.soon ||
                                r.status == DueStatus.estimated,
                          )
                          .length,
                      Icons.schedule_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                MaintenanceCard(
                  key: const ValueKey('maintenance-reminder-card'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReminderPage(controller: controller),
                    ),
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.notifications_none_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Maintenance reminders',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$unread unread • Calendar dates and clearly labelled mileage estimates',
                              style: const TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _archived ? 'Archived cars' : 'My cars',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    OutlinedButton(
                      style: maintenanceOutlineButton(),
                      onPressed: () => setState(() => _archived = !_archived),
                      child: Text(_archived ? 'Active cars' : 'Archived'),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (cars.isEmpty)
                  MaintenanceCard(
                    child: Column(
                      children: [
                        const CarLogo(size: 72),
                        const SizedBox(height: 16),
                        Text(
                          _archived
                              ? 'No archived cars'
                              : 'Start your personal garage',
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _archived
                              ? 'Archived cars retain their service history.'
                              : 'Add a car, record a service and see what is due next.\nYour price predictions stay completely separate.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textGrey,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  )
                else
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 1100
                          ? 3
                          : constraints.maxWidth >= 680
                          ? 2
                          : 1;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: cars.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          mainAxisExtent: 245,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                        ),
                        itemBuilder: (_, index) {
                          final car = cars[index];
                          final pending = due
                              .where(
                                (r) => r.vehicle.id == car.id && r.actionable,
                              )
                              .length;
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(24),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => VehicleDetails(
                                    controller: controller,
                                    vehicleId: car.id,
                                  ),
                                ),
                              ),
                              child: MaintenanceCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                            color: AppColors.primarySurface,
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                          ),
                                          child: const CarLogo(size: 32),
                                        ),
                                        const Spacer(),
                                        const Icon(
                                          Icons.chevron_right_rounded,
                                          color: AppColors.textGrey,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      car.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${car.year} • ${car.plate.isEmpty ? car.fuel : car.plate}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: AppColors.textGrey,
                                      ),
                                    ),
                                    const Spacer(),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${numberLabel(car.odometer)} km',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textDark,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          car.archived
                                              ? 'Archived'
                                              : pending > 0
                                              ? '$pending to review'
                                              : car.schedules.isEmpty
                                              ? 'No schedule'
                                              : 'Upcoming',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: pending > 0
                                                ? AppColors.primary
                                                : AppColors.textGrey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      );
    },
  );
  Widget _stat(String label, int count, IconData icon) => Expanded(
    child: MaintenanceCard(
      padding: const EdgeInsets.all(14),
      child: SizedBox(
        height: 128 * MediaQuery.textScalerOf(context).scale(1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: icon == Icons.directions_car_outlined
                  ? const CarLogo(size: 24)
                  : Icon(icon, color: AppColors.primary, size: 24),
            ),
            const Spacer(),
            Text(
              '$count',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 32 * MediaQuery.textScalerOf(context).scale(1),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 12,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
