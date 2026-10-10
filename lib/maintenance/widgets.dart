import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_colors.dart';
import '../components/decorated_header.dart';
import '../components/auth_action_button.dart';
import '../components/my_textfield.dart';
export '../components/car_logo.dart';

bool maintenanceUsesWebHeader(BuildContext context) =>
    kIsWeb && MediaQuery.sizeOf(context).width >= 950;

AppBar maintenanceAppBar(BuildContext context, String title) {
  final desktop = maintenanceUsesWebHeader(context);
  return AppBar(
    primary: false, // The persistent shell already handles the status-bar inset.
    title: Text(title),
    toolbarHeight: desktop ? 56 : 48,
    titleSpacing: desktop ? null : 0,
    leadingWidth: desktop ? null : 44,
    titleTextStyle: TextStyle(
      color: AppColors.textDark,
      fontSize: desktop ? 20 : 17,
      fontWeight: FontWeight.w600,
    ),
    iconTheme: const IconThemeData(color: AppColors.textDark, size: 22),
    backgroundColor: desktop ? Colors.white : AppColors.scaffoldBg,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
  );
}

InputDecoration maintenanceInput(
  String label, {
  String? suffix,
  String? hint,
}) => InputDecoration(
  labelText: label,
  suffixText: suffix,
  hintText: hint,
  filled: true,
  fillColor: const Color(0xFFF7F2FA),
  labelStyle: const TextStyle(color: AppColors.textLight),
  floatingLabelStyle: const TextStyle(color: AppColors.primary),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(18),
    borderSide: const BorderSide(color: AppColors.primaryBorder),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(18),
    borderSide: const BorderSide(color: AppColors.primaryBorder, width: 1.2),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(18),
    borderSide: const BorderSide(color: AppColors.primary, width: 2),
  ),
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(18),
    borderSide: const BorderSide(color: AppColors.error),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(18),
    borderSide: const BorderSide(color: AppColors.error, width: 2),
  ),
  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
);

/// Uses the app's text-field component without losing maintenance validation.
class MaintenanceTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? suffix;
  final TextInputType keyboardType;
  final FormFieldValidator<String>? validator;
  final int? maxLength, minLines;
  final int maxLines;
  const MaintenanceTextField({
    super.key,
    required this.controller,
    required this.label,
    this.suffix,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.maxLength,
    this.minLines,
    this.maxLines = 1,
  });
  @override
  Widget build(BuildContext context) => MyTextField(
    controller: controller,
    hint: label,
    icon: Icons.edit_outlined,
    useFormField: true,
    keyboardType: keyboardType,
    validator: validator,
    maxLength: maxLength,
    minLines: minLines,
    maxLines: maxLines,
    decoration: maintenanceInput(
      label,
      suffix: suffix,
    ).copyWith(counterText: ''),
  );
}

ButtonStyle maintenanceOutlineButton({Size minimumSize = const Size(0, 48)}) =>
    OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      backgroundColor: AppColors.primarySurface,
      minimumSize: minimumSize,
      side: const BorderSide(color: AppColors.primaryBorder),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    );

class MaintenanceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Gradient? gradient;
  final bool decorated;
  final VoidCallback? onTap;
  const MaintenanceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(22),
    this.gradient,
    this.decorated = false,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) => Container(
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: Colors.white,
      gradient: gradient,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: AppColors.primaryBorder.withValues(alpha: 0.65),
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: .07),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            if (decorated) ...[
              Positioned(
                top: -26,
                right: -24,
                child: IgnorePointer(
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.14),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -26,
                left: -26,
                child: IgnorePointer(
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
              ),
            ],
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    ),
  );
}

class MaintenanceHeading extends StatelessWidget {
  final String title, subtitle;
  const MaintenanceHeading({
    super.key,
    required this.title,
    required this.subtitle,
  });
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        subtitle,
        style: const TextStyle(color: AppColors.textGrey, height: 1.5),
      ),
      const SizedBox(height: 22),
    ],
  );
}

class FormActions extends StatelessWidget {
  final bool busy;
  final VoidCallback onSave;
  const FormActions({super.key, required this.busy, required this.onSave});
  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.end,
    crossAxisAlignment: WrapCrossAlignment.center,
    spacing: 12,
    runSpacing: 12,
    children: [
      OutlinedButton(
        onPressed: busy ? null : () => Navigator.pop(context),
        style: maintenanceOutlineButton(minimumSize: const Size(110, 52)),
        child: const Text('Cancel'),
      ),
      FilledButton.icon(
        onPressed: busy ? null : onSave,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 3,
          shadowColor: AppColors.primary.withValues(alpha: 0.25),
          minimumSize: const Size(170, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        icon: busy
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.check_rounded),
        label: Text(busy ? 'Saving…' : 'Save'),
      ),
    ],
  );
}

Future<bool> maintenanceConfirm(
  BuildContext context,
  String title,
  String message,
) async =>
    await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DecoratedHeader(title: title, icon: Icons.info_outline_rounded),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      AuthActionButton(
                        label: 'Confirm',
                        icon: Icons.check_rounded,
                        compact: true,
                        onPressed: () => Navigator.pop(ctx, true),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          style: TextButton.styleFrom(
                            minimumSize: const Size(0, 52),
                            backgroundColor: AppColors.primarySurface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                              side: const BorderSide(
                                color: AppColors.primaryBorder,
                              ),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ) ==
    true;

void maintenanceError(BuildContext context, Object error) {
  final message = error is StateError
      ? error.message.toString()
      : 'Unable to save. Check your connection and try again. Your form has been kept.';
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: AppColors.error),
  );
}

Future<DateTime?> pickMaintenanceDate(
  BuildContext context,
  DateTime initial, {
  bool future = false,
}) => showDatePicker(
  context: context,
  initialDate: initial,
  firstDate: DateTime(1950),
  lastDate: future
      ? DateTime(2100)
      : DateTime.now().toUtc().add(const Duration(hours: 5)),
);

class DateField extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;
  const DateField({
    super.key,
    required this.label,
    required this.date,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: InputDecorator(
      decoration: maintenanceInput(label),
      child: Row(
        children: [
          const Icon(Icons.calendar_month_outlined, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(child: Text('${date.day}/${date.month}/${date.year}')),
        ],
      ),
    ),
  );
}
