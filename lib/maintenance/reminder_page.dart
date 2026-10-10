import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'controller.dart';
import 'models.dart';
import 'vehicle_details.dart';
import 'widgets.dart';

class ReminderPage extends StatefulWidget {
  final MaintenanceController controller;
  const ReminderPage({super.key, required this.controller});
  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  bool _busy = false;
  Future<void> _enable(bool value) async {
    setState(() => _busy = true);
    try {
      final allowed = await widget.controller.enable(value);
      if (!allowed && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Notifications are blocked or unsupported. In-app reminders remain available.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) maintenanceError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _preference(int hour, int lead) async {
    setState(() => _busy = true);
    try {
      await widget.controller.savePreferences(hour, lead);
    } catch (e) {
      if (mounted) maintenanceError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) {
      final c = widget.controller;
      final due = c.reminders;
      final prefs = c.preferences;
      return Scaffold(
        primary: false,
        backgroundColor: AppColors.scaffoldBg,
        appBar: maintenanceAppBar(context, 'Reminder centre'),
        body: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  MaintenanceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const MaintenanceHeading(
                          title: 'Stay one service ahead',
                          subtitle:
                              'Review upcoming services and improve estimates with regular mileage updates.',
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            kIsWeb
                                ? 'Browser alerts while the site is open'
                                : 'Android maintenance reminders',
                          ),
                          value: prefs.enabled,
                          onChanged: _busy ? null : _enable,
                        ),
                        Text(
                          kIsWeb
                              ? 'Spark-only mode: no reminders after the website closes. Your in-app reminder centre is always available when you return.'
                              : 'Local reminders work without a server. Changes made on another device sync when this app is opened. Battery restrictions may delay delivery.',
                          style: const TextStyle(
                            color: AppColors.textGrey,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 18),
                        DropdownButtonFormField<int>(
                          isExpanded: true,
                          key: ValueKey('hour${prefs.hour}'),
                          value: prefs.hour,
                          decoration: maintenanceInput(
                            'Reminder hour • Pakistan time',
                          ),
                          items: List.generate(
                            13,
                            (i) => DropdownMenuItem(
                              value: i + 8,
                              child: Text(
                                '${i + 8}:00',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          onChanged: _busy
                              ? null
                              : (hour) => _preference(hour!, prefs.leadDays),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          isExpanded: true,
                          key: ValueKey('lead${prefs.leadDays}'),
                          value: prefs.leadDays,
                          decoration: maintenanceInput('Advance warning'),
                          items: [1, 3, 7, 14]
                              .map(
                                (n) => DropdownMenuItem(
                                  value: n,
                                  child: Text(
                                    '$n days before',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: _busy
                              ? null
                              : (days) => _preference(prefs.hour, days!),
                        ),
                        if (c.notificationError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              c.notificationError!,
                              style: const TextStyle(color: AppColors.error),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (due.isEmpty)
                    const MaintenanceCard(
                      child: Text(
                        'No active schedules yet. Add a service or schedule to a car.',
                        style: TextStyle(color: AppColors.textGrey),
                      ),
                    ),
                ]),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final reminder = due[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: DueCard(
                      key: ValueKey(reminder.key),
                      due: reminder,
                      controller: c,
                      onOpen: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VehicleDetails(
                            controller: c,
                            vehicleId: reminder.vehicle.id,
                          ),
                        ),
                      ),
                    ),
                  );
                }, childCount: due.length),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class DueCard extends StatefulWidget {
  final MaintenanceDue due;
  final MaintenanceController controller;
  final VoidCallback? onOpen;
  const DueCard({
    super.key,
    required this.due,
    required this.controller,
    this.onOpen,
  });
  @override
  State<DueCard> createState() => _DueCardState();
}

class _DueCardState extends State<DueCard> {
  bool _busy = false;
  Future<void> _change({bool? read, DateTime? snooze}) async {
    setState(() => _busy = true);
    try {
      await widget.controller.repository?.changeSchedule(
        widget.due,
        read: read,
        snooze: snooze,
      );
    } catch (e) {
      if (mounted) maintenanceError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final due = widget.due;
    final schedule = due.schedule;
    final color = due.status == DueStatus.due
        ? AppColors.error
        : due.actionable
        ? AppColors.primary
        : AppColors.success;
    return MaintenanceCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                schedule.type,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              Chip(
                label: Text(
                  due.label,
                  style: TextStyle(fontSize: 12, color: color),
                ),
                backgroundColor: color.withValues(alpha: .08),
                side: BorderSide.none,
              ),
            ],
          ),
          if (widget.onOpen != null)
            TextButton(onPressed: widget.onOpen, child: Text(due.vehicle.name)),
          if (schedule.dueKm != null)
            Text(
              'Next at ${numberLabel(schedule.dueKm!)} km • confirmed ${numberLabel(due.vehicle.odometer)} km',
              style: const TextStyle(color: AppColors.textGrey),
            ),
          if (schedule.dueDate != null)
            Text(
              'Calendar deadline: ${dateLabel(schedule.dueDate!)}',
              style: const TextStyle(color: AppColors.textGrey),
            ),
          if (due.forecast != null)
            Text(
              'Estimated mileage date: ${dateLabel(due.forecast!)}',
              style: const TextStyle(color: AppColors.textGrey),
            ),
          Text(
            'Last reading: ${dateLabel(due.vehicle.readingDate)}${due.status == DueStatus.needsReading ? ' • Update mileage for a useful forecast' : ''}',
            style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
          ),
          if (schedule.snoozedUntil != null)
            Text(
              'Alert snoozed until ${dateLabel(pakistanDay(schedule.snoozedUntil!))}; service deadline is unchanged.',
              style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
            ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                style: maintenanceOutlineButton(),
                onPressed: _busy
                    ? null
                    : () => _change(
                        read: !schedule.read,
                        snooze: schedule.snoozedUntil,
                      ),
                icon: Icon(
                  schedule.read
                      ? Icons.mark_email_unread_outlined
                      : Icons.done_rounded,
                ),
                label: Text(schedule.read ? 'Mark unread' : 'Mark read'),
              ),
              OutlinedButton.icon(
                style: maintenanceOutlineButton(),
                onPressed: _busy
                    ? null
                    : () => _change(
                        snooze: pakistanReminder(
                          pakistanDay(
                            DateTime.now(),
                          ).add(const Duration(days: 7)),
                          widget.controller.preferences.hour,
                        ),
                      ),
                icon: const Icon(Icons.snooze_rounded),
                label: const Text('Snooze 7 days'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
