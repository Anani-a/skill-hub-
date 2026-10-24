import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/mock_state_providers.dart' as shared_state;
import '../models/booking_model.dart';

class BookingDetailsScreen extends ConsumerStatefulWidget {
  final String bookingId;
  const BookingDetailsScreen({super.key, required this.bookingId});

  @override
  ConsumerState<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends ConsumerState<BookingDetailsScreen> {
  bool _isPlayingAudio = false;

  @override
  Widget build(BuildContext context) {
    final activeLang = ref.watch(shared_state.languageProvider);
    final activeRole = ref.watch(shared_state.currentRoleProvider);
    final booking = ref.watch(shared_state.bookingByIdProvider(widget.bookingId));

    if (booking == null) {
      return Scaffold(
        backgroundColor: AppTheme.bgBase,
        appBar: AppBar(
          backgroundColor: AppTheme.bgBase,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF512DA8)),
            onPressed: () => context.pop(),
          ),
          title: Text(
            activeLang == 'am' ? 'የጥያቄ ዝርዝር' : 'Request Details',
            style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_off_rounded, size: 56, color: Color(0xFFD1C4E9)),
              const SizedBox(height: 12),
              Text(
                activeLang == 'am' ? 'ይቅርታ፣ የጥያቄው ዝርዝር አልተገኘም።' : 'Request details not found.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    // Status color, label, icon
    final Color statusColor;
    final String statusLabel;
    final IconData statusIcon;
    switch (booking.status) {
      case BookingStatus.pending:
        statusColor = const Color(0xFFFF9800);
        statusLabel = activeLang == 'am' ? 'በመጠበቅ ላይ' : 'Awaiting Acceptance';
        statusIcon = Icons.hourglass_empty_rounded;
        break;
      case BookingStatus.accepted:
        statusColor = const Color(0xFF26A69A);
        statusLabel = activeLang == 'am' ? 'ተቀብሏል' : 'Accepted';
        statusIcon = Icons.check_circle_rounded;
        break;
      case BookingStatus.inService:
        statusColor = const Color(0xFF512DA8);
        statusLabel = activeLang == 'am' ? 'በስራ ላይ' : 'In Service';
        statusIcon = Icons.build_circle_rounded;
        break;
      case BookingStatus.completed:
        statusColor = const Color(0xFF2E7D32);
        statusLabel = activeLang == 'am' ? 'ተጠናቋል' : 'Completed';
        statusIcon = Icons.task_alt_rounded;
        break;
      case BookingStatus.cancelled:
        statusColor = AppTheme.error;
        statusLabel = activeLang == 'am' ? 'ተሰርዟል' : 'Cancelled';
        statusIcon = Icons.cancel_rounded;
        break;
      case BookingStatus.disputed:
        statusColor = AppTheme.error;
        statusLabel = activeLang == 'am' ? 'ተከራክሯል' : 'Disputed';
        statusIcon = Icons.gavel_rounded;
        break;
      case BookingStatus.draft:
        statusColor = AppTheme.textTertiary;
        statusLabel = activeLang == 'am' ? 'ረቂቅ' : 'Draft';
        statusIcon = Icons.edit_note_rounded;
        break;
    }

    final isCustomer = activeRole != 'provider';

    return Scaffold(
      backgroundColor: AppTheme.bgBase,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 24),
          onPressed: () => context.pop(),
        ),
        title: Text(
          activeLang == 'am' ? 'የጥያቄ ዝርዝር' : 'Request Details',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(statusIcon, color: Colors.white, size: 13),
                const SizedBox(width: 4),
                Text(
                  statusLabel,
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Purple gradient header background
          Container(
            height: 220,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF512DA8), Color(0xFF7E57C2)],
              ),
            ),
          ),

          SafeArea(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Hero banner inside gradient
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.assignment_rounded, color: Colors.white, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.serviceType,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(statusIcon, color: statusColor, size: 11),
                                      const SizedBox(width: 4),
                                      Text(
                                        statusLabel,
                                        style: TextStyle(
                                          color: statusColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (booking.voiceNotePath != null) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.mic_rounded, color: Colors.white, size: 11),
                                        SizedBox(width: 4),
                                        Text(
                                          'Voice',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${booking.priceEtb.toInt()}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'ETB',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Theme-adaptive card body
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.bgBase,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Provider card (customer view only)
                      if (isCustomer) ...[
                        _SectionLabel(
                          icon: Icons.person_pin_rounded,
                          label: activeLang == 'am' ? 'የተመረጠ ባለሙያ' : 'Requested Provider',
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.bgSurface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.outlineLighter),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF512DA8).withValues(alpha: 0.06),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppTheme.outlineLight),
                                ),
                                child: Center(
                                  child: Text(booking.providerEmoji, style: const TextStyle(fontSize: 24)),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      booking.providerName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    const Row(
                                      children: [
                                        Icon(Icons.verified_rounded, color: Color(0xFF512DA8), size: 14),
                                        SizedBox(width: 4),
                                        Text(
                                          'Verified Shuk Professional',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF512DA8),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Voice note player
                      if (booking.voiceNotePath != null) ...[
                        _SectionLabel(
                          icon: Icons.mic_rounded,
                          label: activeLang == 'am' ? 'የድምፅ መመሪያ' : 'Voice Instruction',
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () => setState(() => _isPlayingAudio = !_isPlayingAudio),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF512DA8), Color(0xFF7E57C2)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF512DA8).withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: _isPlayingAudio ? 0.35 : 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _isPlayingAudio ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _isPlayingAudio
                                            ? (activeLang == 'am' ? 'ድምፅ እየተጫወተ ነው...' : 'Playing instruction...')
                                            : (activeLang == 'am' ? 'የድምፅ ማስታወሻ' : 'Voice Note Recorded'),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        '${activeLang == 'am' ? 'ጊዜ' : 'Duration'}: ${booking.voiceNoteDurationSeconds ?? 15}s',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.white.withValues(alpha: 0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.graphic_eq_rounded, color: Colors.white70, size: 26),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Request overview
                      _SectionLabel(
                        icon: Icons.info_outline_rounded,
                        label: activeLang == 'am' ? 'የጥያቄው ዝርዝር' : 'Request Overview',
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppTheme.bgSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.outlineLighter),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF512DA8).withValues(alpha: 0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _DetailRow(
                              icon: Icons.build_rounded,
                              label: activeLang == 'am' ? 'አገልግሎት' : 'Service Type',
                              value: booking.serviceType,
                            ),
                            Divider(height: 20, thickness: 0.5, color: AppTheme.outlineLighter),
                            _DetailRow(
                              icon: Icons.calendar_today_rounded,
                              label: activeLang == 'am' ? 'የተጠየቀበት ቀን' : 'Requested Date',
                              value:
                                  '${booking.dateTime.day}/${booking.dateTime.month}/${booking.dateTime.year} · ${booking.dateTime.hour.toString().padLeft(2, '0')}:${booking.dateTime.minute.toString().padLeft(2, '0')}',
                            ),
                            Divider(height: 20, thickness: 0.5, color: AppTheme.outlineLighter),
                            _DetailRow(
                              icon: Icons.payments_rounded,
                              label: activeLang == 'am' ? 'የአገልግሎት ዋጋ' : 'Est. Price',
                              value: '${booking.priceEtb.toInt()} ETB',
                              valueColor: AppTheme.primary,
                            ),
                            Divider(height: 20, thickness: 0.5, color: AppTheme.outlineLighter),
                            _DetailRow(
                              icon: statusIcon,
                              label: activeLang == 'am' ? 'ሁኔታ' : 'Current Status',
                              value: statusLabel,
                              valueColor: statusColor,
                            ),
                            Divider(height: 20, thickness: 0.5, color: AppTheme.outlineLighter),
                            _DetailRow(
                              icon: Icons.shield_rounded,
                              label: activeLang == 'am' ? 'እስክሮው ጥበቃ' : 'Escrow Protection',
                              value: booking.isEscrowHeld
                                  ? (activeLang == 'am' ? 'የተጠበቀ ✓' : 'Secured ✓')
                                  : (activeLang == 'am' ? 'በመጠበቅ ላይ' : 'Pending'),
                              valueColor: booking.isEscrowHeld ? const Color(0xFF2E7D32) : AppTheme.textSecondary,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Problem description
                      _SectionLabel(
                        icon: Icons.description_rounded,
                        label: activeLang == 'am' ? 'የችግሩ መግለጫ' : 'Problem Description',
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppTheme.bgSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.outlineLighter),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF512DA8).withValues(alpha: 0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          booking.description.isNotEmpty
                              ? booking.description
                              : (activeLang == 'am' ? 'ዝርዝር መግለጫ አልተሰጠም' : 'No detailed description provided.'),
                          style: TextStyle(
                            color: booking.description.isNotEmpty ? AppTheme.textPrimary : AppTheme.textTertiary,
                            fontSize: 13,
                            height: 1.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Action buttons
                      if (isCustomer) ...[
                        if (booking.status == BookingStatus.pending)
                          _CancelButton(
                            activeLang: activeLang,
                            bookingId: booking.id,
                          )
                        else if (booking.status == BookingStatus.accepted ||
                            booking.status == BookingStatus.inService)
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: () => context.push('/active-service/${booking.id}'),
                              icon: const Icon(Icons.navigation_rounded, size: 20),
                              label: Text(
                                activeLang == 'am' ? 'የአገልግሎት እድገት ተከተል' : 'Track Active Service',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF512DA8),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Cancel Button (extracted widget to handle async properly) ─────────────────
class _CancelButton extends ConsumerWidget {
  final String activeLang;
  final String bookingId;
  const _CancelButton({required this.activeLang, required this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () => _handleCancel(context, ref),
        icon: const Icon(Icons.cancel_outlined, size: 20),
        label: Text(
          activeLang == 'am' ? 'ጥያቄውን ሰርዝ' : 'Cancel This Request',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.error.withValues(alpha: 0.12),
          foregroundColor: AppTheme.error,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppTheme.error.withValues(alpha: 0.4)),
          ),
        ),
      ),
    );
  }

  Future<void> _handleCancel(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final notifier = ref.read(shared_state.bookingsListProvider.notifier);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.cancel_outlined, color: AppTheme.error, size: 22),
            ),
            const SizedBox(width: 12),
            Text(
              activeLang == 'am' ? 'ጥያቄ ሰርዝ' : 'Cancel Request',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          activeLang == 'am'
              ? 'ይህን የአገልግሎት ጥያቄ መሰረዝ ይፈልጋሉ?'
              : 'Are you sure you want to cancel this service request?',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              activeLang == 'am' ? 'ይቅር' : 'Keep It',
              style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(activeLang == 'am' ? 'አዎ፣ ሰርዝ' : 'Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      notifier.cancelBooking(bookingId);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            activeLang == 'am' ? 'ጥያቄዎ ተሰርዟል' : 'Your request has been cancelled',
          ),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      router.pop();
    }
  }
}

// ── Section Label ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppTheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primary, size: 16),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ── Detail Row ────────────────────────────────────────────────────────────────
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({required this.icon, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: const Color(0xFF9575CD)),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: valueColor ?? AppTheme.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
