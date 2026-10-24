import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/mock_state_providers.dart';
import '../providers/provider_onboarding_provider.dart';

class AvailabilityScreen extends ConsumerWidget {
  const AvailabilityScreen({super.key});

  void _showEditHoursSheet(
    BuildContext context,
    WidgetRef ref,
    String day,
    String currentHours,
    String activeLang,
  ) {
    String selectedHours = currentHours;
    final customCtrl = TextEditingController(
      text: currentHours == 'Closed' ? '08:00 AM - 05:00 PM' : currentHours,
    );

    final List<String> presetOptions = [
      '08:00 AM - 06:00 PM',
      '08:00 AM - 05:00 PM',
      '09:00 AM - 05:00 PM',
      '09:00 AM - 04:00 PM',
      '10:00 AM - 07:00 PM',
      'Closed',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bgBottomSheet,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
                left: 24,
                right: 24,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Icon(Icons.access_time_rounded, color: AppTheme.primary, size: 24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          activeLang == 'am'
                              ? '$day የሥራ ሰዓት ያስተካክሉ'
                              : 'Edit Working Hours for $day',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Quick presets label
                  Text(
                    activeLang == 'am' ? 'የተለመዱ የሥራ ሰዓቶች ይምረጡ' : 'Select standard schedule',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: presetOptions.map((opt) {
                      final isSelected = selectedHours == opt;
                      final isClosedOpt = opt == 'Closed';
                      return ChoiceChip(
                        label: Text(
                          isClosedOpt && activeLang == 'am' ? 'ዝግ ነው' : opt,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? AppTheme.textWhite
                                : (isClosedOpt ? AppTheme.error : AppTheme.textPrimary),
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: isClosedOpt ? AppTheme.error : AppTheme.primary,
                        backgroundColor: AppTheme.bgBase,
                        side: BorderSide(
                          color: isSelected
                              ? (isClosedOpt ? AppTheme.error : AppTheme.primary)
                              : AppTheme.border,
                        ),
                        onSelected: (val) {
                          if (val) {
                            setState(() {
                              selectedHours = opt;
                              if (opt != 'Closed') customCtrl.text = opt;
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 18),

                  // Custom Schedule Input
                  if (selectedHours != 'Closed') ...[
                    Text(
                      activeLang == 'am' ? 'የእርስዎን ሰዓት ያስገቡ' : 'Custom Schedule Text',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: customCtrl,
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                      onChanged: (val) {
                        setState(() {
                          selectedHours = val.trim();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'e.g. 08:30 AM - 05:30 PM',
                        hintStyle: TextStyle(color: AppTheme.inputPlaceholder),
                        filled: true,
                        fillColor: AppTheme.inputBg,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppTheme.inputBorderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppTheme.inputFocusColor, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.primaryDark, AppTheme.primary],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          final finalVal = selectedHours.trim().isEmpty
                              ? '08:00 AM - 06:00 PM'
                              : selectedHours.trim();
                          ref.read(providerOnboardingProvider.notifier).updateWorkingHours(day, finalVal);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                activeLang == 'am'
                                    ? '$day የሥራ ሰዓት ተስተካክሏል!'
                                    : '$day schedule updated to $finalVal!',
                              ),
                              backgroundColor: AppTheme.success,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          activeLang == 'am' ? 'ሰዓቱን አስቀምጥ' : 'Save Schedule',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textWhite,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeLang = ref.watch(languageProvider);
    final state = ref.watch(providerOnboardingProvider);
    final notifier = ref.read(providerOnboardingProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.bgBase,
      appBar: AppBar(
        backgroundColor: AppTheme.bgSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          activeLang == 'am' ? '5. ተገኝነት' : '5. Availability',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activeLang == 'am' ? 'ተገኝነት' : 'Availability',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      activeLang == 'am'
                          ? 'የሥራ ሁኔታዎን እና የሥራ ሰዓቶችን ያስተካክሉ።'
                          : 'Set your working status and hours.',
                      style: TextStyle(fontSize: 13, color: AppTheme.textCaption),
                    ),
                    const SizedBox(height: 20),

                    // I am Available Switch Card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.bgCard,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppTheme.primaryContainer, width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  activeLang == 'am' ? 'አሁን ዝግጁ ነኝ' : 'I am Available',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  state.isAvailable
                                      ? (activeLang == 'am' ? 'ደንበኞች ማግኘት ይችላሉ' : 'Customers can find you')
                                      : (activeLang == 'am' ? 'ለደንበኞች አይታይም' : 'Hidden from customers'),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: state.isAvailable ? AppTheme.success : AppTheme.textCaption,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: state.isAvailable,
                            activeColor: AppTheme.textWhite,
                            activeTrackColor: AppTheme.primary,
                            inactiveThumbColor: AppTheme.textHint,
                            inactiveTrackColor: AppTheme.border,
                            onChanged: (val) => notifier.toggleAvailable(val),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Working Hours Header
                    Text(
                      activeLang == 'am' ? 'የሥራ ሰዓቶች (ለማስተካከል ይጫኑ)' : 'Working Hours (Tap to edit)',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Days Working Hours List
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.bgCard,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppTheme.primaryContainer, width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: state.workingHours.entries.map((entry) {
                          final isLast = entry.key == 'Sunday';
                          final isClosed = entry.value == 'Closed';
                          return Column(
                            children: [
                              InkWell(
                                onTap: () => _showEditHoursSheet(
                                  context,
                                  ref,
                                  entry.key,
                                  entry.value,
                                  activeLang,
                                ),
                                borderRadius: BorderRadius.vertical(
                                  top: entry.key == 'Monday' ? const Radius.circular(18) : Radius.zero,
                                  bottom: isLast ? const Radius.circular(18) : Radius.zero,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  child: Row(
                                    children: [
                                      Text(
                                        entry.key,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        isClosed
                                            ? (activeLang == 'am' ? 'ዝግ ነው' : 'Closed')
                                            : entry.value,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: isClosed ? AppTheme.error : AppTheme.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.edit_calendar_rounded,
                                        color: AppTheme.primary,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (!isLast)
                                Divider(
                                  height: 1,
                                  indent: 16,
                                  endIndent: 16,
                                  color: AppTheme.divider,
                                ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Vacation Mode Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppTheme.bgCard,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppTheme.primaryContainer, width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  activeLang == 'am' ? 'የዕረፍት ሁኔታ' : 'Vacation Mode',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  activeLang == 'am'
                                      ? 'አዳዲስ ጥያቄዎችን ለማቆም የዕረፍት ሁኔታን ያብሩ።'
                                      : 'Turn on vacation mode to pause new bookings.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textCaption,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: state.isVacationMode,
                            activeColor: AppTheme.textWhite,
                            activeTrackColor: AppTheme.secondary,
                            inactiveThumbColor: AppTheme.textHint,
                            inactiveTrackColor: AppTheme.border,
                            onChanged: (val) => notifier.toggleVacationMode(val),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom Action Button: Save Changes
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.bgSurface,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryDark, AppTheme.primary, AppTheme.primaryLight],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      context.push('/provider-onboarding-service-area');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      activeLang == 'am' ? 'ለወጦችን አስቀምጥ' : 'Save Changes',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textWhite,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
