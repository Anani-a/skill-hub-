import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/mock_state_providers.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../models/booking_model.dart';

class ProviderBookingScreen extends ConsumerStatefulWidget {
  final bool isShell;
  const ProviderBookingScreen({super.key, this.isShell = false});

  @override
  ConsumerState<ProviderBookingScreen> createState() => _ProviderBookingScreenState();
}

class _ProviderBookingScreenState extends ConsumerState<ProviderBookingScreen> {
  int _selectedTab = 0;

  // ─── 1. VIEW DETAILS — Rich Bottom Sheet ────────────────────────────────────
  void _showViewDetailsSheet(BuildContext context, BookingModel booking, String activeLang) {
    final senderName = booking.customerName ?? 'Abel Abreham';
    final senderPhone = booking.customerPhone ?? '+251 911 22 33 44';
    final senderLocation = booking.customerLocation ?? 'Bole, Addis Ababa';

    final statusLabel = switch (booking.status) {
      BookingStatus.accepted => activeLang == 'am' ? 'ተቀብሏል' : 'Accepted',
      BookingStatus.inService => activeLang == 'am' ? 'በሥራ ላይ' : 'In Service',
      BookingStatus.completed => activeLang == 'am' ? 'ተጠናቋል' : 'Completed',
      _ => booking.status.name,
    };

    final statusColor = booking.status == BookingStatus.accepted
        ? AppTheme.success
        : booking.status == BookingStatus.inService
            ? (AppTheme.isDark ? AppTheme.primaryLight : AppTheme.primary)
            : AppTheme.textSecondary;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.bgSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.outlineLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // ── Header gradient banner ──
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryLight.withValues(alpha: 0.9),
                      AppTheme.tertiary.withValues(alpha: 0.9),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppTheme.isDark ? null : [
                    BoxShadow(
                      color: AppTheme.primaryLight.withValues(alpha: 0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.build_circle_rounded, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.serviceType,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'ID: ${booking.id}',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    // Status + price chips
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            statusLabel,
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${booking.priceEtb.toInt()} ETB',
                            style: TextStyle(
                              color: AppTheme.statusWarning,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Client Info ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.bgBase,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.outlineLighter),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(child: Text('👨', style: TextStyle(fontSize: 22))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  senderName,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.verified_user_rounded, size: 14, color: AppTheme.primary),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(senderPhone, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                            Text(senderLocation, style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Service Detail Rows ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.bgBase,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.outlineLighter),
                  ),
                  child: Column(
                    children: [
                      _DetailRow(label: activeLang == 'am' ? 'አገልግሎት' : 'Service Type', value: booking.serviceType),
                      _DetailRow(
                        label: activeLang == 'am' ? 'የጥያቄ ቀን' : 'Scheduled Date',
                        value: '${booking.dateTime.day}/${booking.dateTime.month}/${booking.dateTime.year}  ${booking.dateTime.hour.toString().padLeft(2, '0')}:${booking.dateTime.minute.toString().padLeft(2, '0')}',
                      ),
                      _DetailRow(
                        label: activeLang == 'am' ? 'ዋጋ' : 'Service Price',
                        value: '${booking.priceEtb.toInt()} ETB',
                        valueColor: AppTheme.primary,
                      ),
                      _DetailRow(
                        label: activeLang == 'am' ? 'ሁኔታ' : 'Current Status',
                        value: statusLabel,
                        valueColor: statusColor,
                      ),
                      _DetailRow(
                        label: activeLang == 'am' ? 'Escrow' : 'Escrow',
                        value: booking.isEscrowHeld
                            ? (activeLang == 'am' ? '✅ ተጠብቋል' : '✅ Secured')
                            : (activeLang == 'am' ? '⏳ በመጠበቅ ላይ' : '⏳ Pending'),
                        isLast: booking.description.isEmpty,
                      ),
                      if (booking.description.isNotEmpty)
                        _DetailRow(
                          label: activeLang == 'am' ? 'መግለጫ' : 'Description',
                          value: booking.description,
                          isLast: true,
                        ),
                    ],
                  ),
                ),
              ),

              // ── Escrow badge if active ──
              if (booking.isEscrowHeld && booking.status != BookingStatus.completed) ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.success.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.shield_rounded, size: 18, color: AppTheme.success),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            activeLang == 'am'
                                ? 'ክፍያ ${booking.priceEtb.toInt()} ETB በታመነ ሂሳብ ተይዟል። ሥራ ሲጠናቀቅ ወደ ሂሳብዎ ይተላለፋል።'
                                : 'Payment of ${booking.priceEtb.toInt()} ETB is held in escrow and will be released to you upon completion.',
                            style: TextStyle(fontSize: 12, color: AppTheme.success, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // ── Close button ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      activeLang == 'am' ? 'ዝጋ' : 'Close',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── 2. START SERVICE — Prominent Success Notification Dialog ───────────────
  void _showStartServiceDialog(BuildContext context, BookingModel booking, String activeLang) {
    final senderName = booking.customerName ?? 'Abel Abreham';
    final senderPhone = booking.customerPhone ?? '+251 911 22 33 44';
    final senderLocation = booking.customerLocation ?? 'Bole, Addis Ababa';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.bgSurface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: AppTheme.isDark ? null : [
                BoxShadow(
                  color: AppTheme.success.withValues(alpha: 0.15),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated icon ring
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.success.withValues(alpha: 0.18),
                        AppTheme.success.withValues(alpha: 0.04),
                      ],
                    ),
                    border: Border.all(color: AppTheme.success.withValues(alpha: 0.35), width: 2),
                  ),
                  child: const Icon(Icons.play_circle_fill_rounded, color: AppTheme.success, size: 44),
                ),
                const SizedBox(height: 18),
                Text(
                  activeLang == 'am' ? 'አገልግሎት ለመጀመር ዝግጁ ነዎት?' : 'Ready to Start Service?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  activeLang == 'am'
                      ? 'ጀምር ሲጫኑ ደንበኛ $senderName ይነቃል — አገልግሎቱ ተጀምሯል ብሎ ያሳያቸዋል።'
                      : 'Tapping "Start" will notify $senderName that you\'ve arrived and work is in progress.',
                  style: TextStyle(fontSize: 12.5, color: AppTheme.textSecondary, height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                // Job summary card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.success.withValues(alpha: 0.18)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.build_circle_outlined, size: 15, color: AppTheme.success),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Text(booking.serviceType,
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                          ),
                          Text('${booking.priceEtb.toInt()} ETB',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.success)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.person_pin_circle_outlined, size: 14, color: AppTheme.textSecondary),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text('$senderName  •  $senderPhone',
                                style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                                overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 14, color: AppTheme.textSecondary),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(senderLocation,
                                style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                                overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.textSecondary,
                          side: BorderSide(color: AppTheme.outlineLight),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                        child: Text(activeLang == 'am' ? 'ተመለስ' : 'Cancel',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ref.read(bookingsListProvider.notifier).updateBookingStatus(booking.id, BookingStatus.inService);
                          Navigator.pop(ctx);
                          // Prominent success notification
                          _showStartedSuccessBanner(context, booking, activeLang);
                        },
                        icon: const Icon(Icons.play_arrow_rounded, size: 20),
                        label: Text(
                          activeLang == 'am' ? '▶ አገልግሎት ጀምር' : '▶ Start Now',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.success,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showStartedSuccessBanner(BuildContext context, BookingModel booking, String activeLang) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: AppTheme.success,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppTheme.isDark ? null : [
              BoxShadow(
                color: AppTheme.success.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.25), shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      activeLang == 'am' ? 'አገልግሎት ተጀምሯል!' : 'Service Started!',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      activeLang == 'am'
                          ? '${booking.serviceType} — ክፍያ ተጠብቋል'
                          : '${booking.serviceType} — Payment secured',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.shield_rounded, color: Colors.white, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  // ─── 3. FINISH & COMPLETE — Beautiful Completion Summary Sheet ──────────────
  void _showFinishServiceDialog(BuildContext context, BookingModel booking, String activeLang) {
    final senderName = booking.customerName ?? 'Abel Abreham';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.bgSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            left: 20,
            right: 20,
            top: 0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(color: AppTheme.outlineLight, borderRadius: BorderRadius.circular(2)),
              ),

              // Completion icon + title
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.primary.withValues(alpha: 0.18),
                      AppTheme.primary.withValues(alpha: 0.04),
                    ],
                  ),
                  border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3), width: 2),
                ),
                child: const Icon(Icons.task_alt_rounded, color: AppTheme.primary, size: 40),
              ),
              const SizedBox(height: 14),
              Text(
                activeLang == 'am' ? 'ሥራ ተጠናቅቋል!' : 'Complete This Job?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 6),
              Text(
                activeLang == 'am'
                    ? 'ሥራዎን ማጠናቀቅዎን ሲያረጋግጡ ደንበኛ ይነቃሉ — ክፍያ ወደ ሂሳብዎ ይለቀቃል።'
                    : 'Confirming completion notifies the client and releases the escrow payment to your account.',
                style: TextStyle(fontSize: 12.5, color: AppTheme.textSecondary, height: 1.5),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              // Completion summary card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.bgBase,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.outlineLighter),
                ),
                child: Column(
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.receipt_long_rounded, size: 18, color: AppTheme.primary),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          activeLang == 'am' ? 'የሥራ ማጠናቀቂያ ማጠቃለያ' : 'Job Completion Summary',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1),
                    const SizedBox(height: 14),
                    _SummaryRow(
                      icon: Icons.person_rounded,
                      label: activeLang == 'am' ? 'ደንበኛ' : 'Client',
                      value: senderName,
                    ),
                    const SizedBox(height: 10),
                    _SummaryRow(
                      icon: Icons.build_circle_outlined,
                      label: activeLang == 'am' ? 'አገልግሎት' : 'Service',
                      value: booking.serviceType,
                    ),
                    const SizedBox(height: 10),
                    _SummaryRow(
                      icon: Icons.calendar_today_outlined,
                      label: activeLang == 'am' ? 'ቀን' : 'Date',
                      value:
                          '${booking.dateTime.day}/${booking.dateTime.month}/${booking.dateTime.year}',
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1),
                    const SizedBox(height: 14),
                    // Earnings highlight
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          activeLang == 'am' ? 'ጠቅላላ ክፍያ' : 'Total Earnings',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                        ),
                        Text(
                          '${booking.priceEtb.toInt()} ETB',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.primary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Payment release badge
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.success.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_rounded, size: 18, color: AppTheme.success),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        activeLang == 'am'
                            ? '${booking.priceEtb.toInt()} ETB Escrow ተለቅቆ ወደ ሂሳብዎ ይተላለፋል'
                            : 'ETB ${booking.priceEtb.toInt()} escrow payment will be released to your account',
                        style: TextStyle(fontSize: 12, color: AppTheme.success, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textSecondary,
                        side: BorderSide(color: AppTheme.outlineLight),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(activeLang == 'am' ? 'ተመለስ' : 'Cancel',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ref.read(bookingsListProvider.notifier).updateBookingStatus(booking.id, BookingStatus.completed);
                        Navigator.pop(ctx);
                        // Show completion success banner
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            duration: const Duration(seconds: 4),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            content: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                              decoration: BoxDecoration(
                                color: AppTheme.primary,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: AppTheme.isDark ? null : [
                                  BoxShadow(
                                    color: AppTheme.primary.withValues(alpha: 0.35),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.25), shape: BoxShape.circle),
                                    child: const Icon(Icons.verified_rounded, color: Colors.white, size: 18),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          activeLang == 'am' ? '✅ ሥራ ተጠናቋል!' : '✅ Job Completed!',
                                          style: TextStyle(
                                              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                        Text(
                                          activeLang == 'am'
                                              ? '${booking.priceEtb.toInt()} ETB ወደ ሂሳብዎ ተለቅቋል'
                                              : '${booking.priceEtb.toInt()} ETB released to your account',
                                          style: TextStyle(color: Colors.white.withValues(alpha: 0.88), fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                        setState(() {
                          _selectedTab = 1; // Switch tab to "Done"
                        });
                      },
                      icon: const Icon(Icons.check_circle_rounded, size: 20),
                      label: Text(
                        activeLang == 'am' ? '✔ ሥራ ጨርስ' : '✔ Complete Job',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── BUILD ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final activeLang = ref.watch(languageProvider);
    final bookings = ref.watch(bookingsListProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    AppTheme.isDark = isDark;

    final providerWorkBookings = bookings
        .where((b) =>
            b.status == BookingStatus.accepted ||
            b.status == BookingStatus.inService ||
            b.status == BookingStatus.completed)
        .toList();

    final activeBookings = providerWorkBookings
        .where((b) => b.status == BookingStatus.accepted || b.status == BookingStatus.inService)
        .toList();

    final completedBookings = providerWorkBookings
        .where((b) => b.status == BookingStatus.completed)
        .toList();

    final displayedBookings = switch (_selectedTab) {
      0 => activeBookings,
      1 => completedBookings,
      _ => providerWorkBookings,
    };

    return Scaffold(
      backgroundColor: AppTheme.bgBase,
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: AppTheme.bgSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Row(
          children: [

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activeLang == 'am' ? 'የባለሙያ ትዕዛዞች' : 'Provider Work Center',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    activeLang == 'am'
                        ? '${activeBookings.length} በስራ ሂደት ላይ ያሉ'
                        : '${activeBookings.length} active service job(s)',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Tabs
            Container(
              color: AppTheme.bgSurface,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.bgBase,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.outlineLighter),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildFilterTab(
                        label: activeLang == 'am'
                            ? 'በሥራ ላይ (${activeBookings.length})'
                            : 'Active (${activeBookings.length})',
                        index: 0,
                      ),
                    ),
                    Expanded(
                      child: _buildFilterTab(
                        label: activeLang == 'am'
                            ? 'ተጠናቋል (${completedBookings.length})'
                            : 'Done (${completedBookings.length})',
                        index: 1,
                      ),
                    ),
                    Expanded(
                      child: _buildFilterTab(
                        label: activeLang == 'am'
                            ? 'ሁሉም (${providerWorkBookings.length})'
                            : 'All (${providerWorkBookings.length})',
                        index: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: displayedBookings.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: (AppTheme.isDark ? AppTheme.primaryLight : AppTheme.primary).withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.assignment_outlined, size: 44, color: AppTheme.primary),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              activeLang == 'am' ? 'ምንም የተቀበሉት ሥራ የለም' : 'No Services Found',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              activeLang == 'am'
                                  ? 'ጥያቄዎችን ከ ጥያቄዎች ገፅ ሲቀበሉ እዚህ ይታያሉ።'
                                  : 'When you accept customer requests, they will appear here.',
                              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                      itemCount: displayedBookings.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final booking = displayedBookings[index];
                        return _buildProviderWorkCard(booking, activeLang);
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: widget.isShell
          ? null
          : ShukBottomNavBar(
              currentIndex: 1,
              activeRole: 'provider',
              activeLang: activeLang,
            ),
    );
  }

  Widget _buildFilterTab({required String label, required int index}) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.bgSurface : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected && !AppTheme.isDark
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4, offset: const Offset(0, 2))]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? (AppTheme.isDark ? AppTheme.primaryLight : AppTheme.primary) : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildProviderWorkCard(BookingModel booking, String activeLang) {
    final senderName = booking.customerName ?? 'Abel Abreham';
    final senderPhone = booking.customerPhone ?? '+251 911 22 33 44';
    final senderLocation = booking.customerLocation ?? 'Bole, Addis Ababa';

    final isAccepted = booking.status == BookingStatus.accepted;
    final isInService = booking.status == BookingStatus.inService;
    final isCompleted = booking.status == BookingStatus.completed;

    final statusText = isAccepted
        ? (activeLang == 'am' ? 'ተቀብሏል' : 'Accepted')
        : isInService
            ? (activeLang == 'am' ? 'በሥራ ላይ' : 'In Service')
            : (activeLang == 'am' ? 'ተጠናቋል' : 'Completed');

    final statusBgColor = isAccepted
        ? AppTheme.success.withValues(alpha: 0.12)
        : isInService
            ? (AppTheme.isDark ? AppTheme.primaryLight : AppTheme.primary).withValues(alpha: 0.12)
            : AppTheme.outlineLighter;

    final statusTextColor = isAccepted
        ? AppTheme.success
        : isInService
            ? (AppTheme.isDark ? AppTheme.primaryLight : AppTheme.primary)
            : AppTheme.textSecondary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.outlineLighter),
        boxShadow: AppTheme.isDark ? null : [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Client Header + Status
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: const Center(child: Text('👨', style: TextStyle(fontSize: 20))),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(senderName,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.verified_user_rounded, size: 14, color: AppTheme.primary),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text('$senderLocation • $senderPhone',
                        style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusBgColor, borderRadius: BorderRadius.circular(20)),
                child: Text(statusText,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusTextColor)),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),

          // Service & Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking.serviceType,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 13, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${booking.dateTime.day}/${booking.dateTime.month}/${booking.dateTime.year} at ${booking.dateTime.hour.toString().padLeft(2, '0')}:${booking.dateTime.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                    color: (AppTheme.isDark ? AppTheme.primaryLight : AppTheme.primary).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10)),
                child: Text('${booking.priceEtb.toInt()} ETB',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.isDark ? AppTheme.primaryLight : AppTheme.primary)),
              ),
            ],
          ),

          // Escrow badge
          if (booking.isEscrowHeld && !isCompleted) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.success.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.success.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shield_rounded, size: 14, color: AppTheme.success),
                  const SizedBox(width: 6),
                  Text(
                    activeLang == 'am' ? 'ክፍያ በታመነ ሂሳብ ተይዟል' : 'Escrow Secured Payment',
                    style: TextStyle(fontSize: 11, color: AppTheme.success, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),

          // Action Buttons (Minimized & compact)
          if (isAccepted)
            Row(
              children: [
                Expanded(
                  flex: 6,
                  child: SizedBox(
                    height: 38,
                    child: ElevatedButton.icon(
                      onPressed: () => _showStartServiceDialog(context, booking, activeLang),
                      icon: const Icon(Icons.play_circle_fill_rounded, size: 16),
                      label: Text(
                        activeLang == 'am' ? 'አገልግሎት ጀምር' : 'Start Service',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.success,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 4,
                  child: SizedBox(
                    height: 38,
                    child: OutlinedButton.icon(
                      key: ValueKey('provider_chat_button_${booking.id}'),
                      onPressed: () => context.push('/chat?bookingId=${booking.id}'),
                      icon: const Icon(Icons.chat_bubble_outline_rounded, size: 15),
                      label: Text(
                        activeLang == 'am' ? 'ውይይት' : 'Chat',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primary,
                        side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.3)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 38,
                  width: 38,
                  child: OutlinedButton(
                    onPressed: () => _showViewDetailsSheet(context, booking, activeLang),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textPrimary,
                      side: BorderSide(color: AppTheme.outlineLight),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Icon(Icons.info_outline_rounded, size: 18),
                  ),
                ),
              ],
            )
          else if (isInService)
            Row(
              children: [
                Expanded(
                  flex: 6,
                  child: SizedBox(
                    height: 38,
                    child: ElevatedButton.icon(
                      onPressed: () => _showFinishServiceDialog(context, booking, activeLang),
                      icon: const Icon(Icons.check_circle_rounded, size: 16),
                      label: Text(
                        activeLang == 'am' ? 'አገልግሎት ጨርስ' : 'Finish & Complete',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 4,
                  child: SizedBox(
                    height: 38,
                    child: OutlinedButton.icon(
                      key: ValueKey('provider_chat_button_${booking.id}'),
                      onPressed: () => context.push('/chat?bookingId=${booking.id}'),
                      icon: const Icon(Icons.chat_bubble_outline_rounded, size: 15),
                      label: Text(
                        activeLang == 'am' ? 'ውይይት' : 'Chat',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primary,
                        side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.3)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 38,
                  width: 38,
                  child: OutlinedButton(
                    onPressed: () => _showViewDetailsSheet(context, booking, activeLang),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textPrimary,
                      side: BorderSide(color: AppTheme.outlineLight),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Icon(Icons.info_outline_rounded, size: 18),
                  ),
                ),
              ],
            )
          else
            SizedBox(
              height: 38,
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showViewDetailsSheet(context, booking, activeLang),
                icon: const Icon(Icons.info_outline_rounded, size: 16),
                label: Text(
                  activeLang == 'am' ? 'ዝርዝር እይ' : 'View Details',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.textPrimary,
                  side: BorderSide(color: AppTheme.outlineLight),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Helper Widgets ──────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isLast;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
          Expanded(
            flex: 3,
            child: Text(value,
                style: TextStyle(
                    color: valueColor ?? AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: AppTheme.primary),
        ),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
        const Spacer(),
        Text(value,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
      ],
    );
  }
}
