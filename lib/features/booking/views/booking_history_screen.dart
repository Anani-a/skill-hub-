import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../shared/providers/mock_state_providers.dart' show languageProvider, currentRoleProvider, bookingsListProvider;
import '../models/booking_model.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../../shared/widgets/app_drawer.dart';

class BookingHistoryScreen extends ConsumerStatefulWidget {
  final bool isShell;
  const BookingHistoryScreen({super.key, this.isShell = false});

  @override
  ConsumerState<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends ConsumerState<BookingHistoryScreen> {
  String _activeTab = 'Upcoming';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // ── Helper to filter mock bookings based on selected tab ───────────────────
  List<BookingModel> _filteredBookings(List<BookingModel> allBookings) {
    if (_activeTab == 'Upcoming') {
      return allBookings.where((b) =>
        b.status == BookingStatus.accepted ||
        b.status == BookingStatus.inService
      ).toList();
    } else if (_activeTab == 'Past') {
      return allBookings.where((b) => b.status == BookingStatus.completed).toList();
    } else {
      return allBookings.where((b) =>
        b.status == BookingStatus.cancelled ||
        b.status == BookingStatus.disputed
      ).toList();
    }
  }

  // ── Helper to retrieve Unsplash category images dynamically ────────────────
  // ignore: unused_element
  String _getBookingImage(String serviceType) {
    final cleanType = serviceType.toLowerCase();
    if (cleanType.contains('elect')) {
      return 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=600&auto=format&fit=crop&q=80';
    } else if (cleanType.contains('clean')) {
      return 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=600&auto=format&fit=crop&q=80';
    } else if (cleanType.contains('plumb') || cleanType.contains('pipe')) {
      return 'https://images.unsplash.com/photo-1504328345606-18bbc8c9d7d1?w=600&auto=format&fit=crop&q=80';
    } else if (cleanType.contains('tutor') || cleanType.contains('school')) {
      return 'https://images.unsplash.com/photo-1524178232363-1fb2b075b655?w=600&auto=format&fit=crop&q=80';
    }
    return 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=600&auto=format&fit=crop&q=80';
  }

  // ── Helper to format category title strings ─────────────────────────────────
  // ignore: unused_element
  String _getCategoryDisplay(String serviceType) {
    final cleanType = serviceType.toLowerCase();
    if (cleanType.contains('elect')) {
      return 'ELECTRICAL WORK';
    } else if (cleanType.contains('clean')) {
      return 'CLEANING SERVICE';
    } else if (cleanType.contains('plumb') || cleanType.contains('pipe')) {
      return 'PLUMBING WORK';
    } else if (cleanType.contains('tutor') || cleanType.contains('school')) {
      return 'ACADEMIC TUTOR';
    }
    return 'GENERAL TASK';
  }

  // ── Helper for status dot colors matching mockup indicator ──────────────────
  Color _statusDotColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.draft:
        return Colors.grey;
      case BookingStatus.pending:
        return AppTheme.bookingPending;
      case BookingStatus.accepted:
        return AppTheme.bookingInProgress;
      case BookingStatus.inService:
        return AppTheme.success;
      case BookingStatus.completed:
        return AppTheme.bookingCompleted;
      case BookingStatus.cancelled:
      case BookingStatus.disputed:
        return AppTheme.error;
    }
  }

  // ── Helper for status labels ───────────────────────────────────────────────
  String _statusLabel(BookingStatus status, String activeLang) {
    if (activeLang == 'am') {
      switch (status) {
        case BookingStatus.draft:
          return 'ረቂቅ';
        case BookingStatus.pending:
          return 'በጥበቃ ላይ';
        case BookingStatus.accepted:
          return 'የተረጋገጠ';
        case BookingStatus.inService:
          return 'በሥራ ላይ';
        case BookingStatus.completed:
          return 'ተጠናቋል';
        case BookingStatus.cancelled:
          return 'የተሰረዘ';
        case BookingStatus.disputed:
          return 'አቤቱታ ያለበት';
      }
    }
    switch (status) {
      case BookingStatus.draft:
        return 'Draft';
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.accepted:
        return 'Confirmed';
      case BookingStatus.inService:
        return 'In Service';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.disputed:
        return 'Disputed';
    }
  }

  // ── Show checkout portal (same simulated gateway logic) ───────────────────
  void _showCheckoutPortal(BookingModel booking, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 30,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.get('payment'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, color: AppTheme.textTertiary),
                  )
                ],
              ),
              const SizedBox(height: 16),
              // Escrow notice banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.secondary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.security, color: AppTheme.secondary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.get('escrow_note'),
                        style: TextStyle(
                          fontSize: 10,
                          color: AppTheme.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Price Card
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      booking.serviceType,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      '${booking.priceEtb.toInt()} ETB',
                      style: const TextStyle(
                        color: AppTheme.secondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Checkout Options
              Text(
                l10n.locale.languageCode == 'am' ? 'የክፍያ አማራጭ ይምረጡ' : 'Select Payment Method',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              
              // Telebirr simulation card
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: AppTheme.bgElevated,
                  borderColor: AppTheme.secondary.withValues(alpha: 0.3),
                  onTap: () {
                    Navigator.pop(context);
                    _simulatePaymentGateway(booking, 'Telebirr', ref, l10n);
                  },
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.secondary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'tele',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.get('telebirr_pay'),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textTertiary),
                    ],
                  ),
                ),
              ),
 
              // Chapa simulation card
              GlassCard(
                padding: const EdgeInsets.all(16),
                backgroundColor: AppTheme.bgElevated,
                borderColor: AppTheme.secondary.withValues(alpha: 0.3),
                onTap: () {
                  Navigator.pop(context);
                  _simulatePaymentGateway(booking, 'Chapa', ref, l10n);
                },
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.secondary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'chapa',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.get('chapa_pay'),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textTertiary),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _simulatePaymentGateway(
    BookingModel booking,
    String portal,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.bgSurface,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppTheme.secondary),
              const SizedBox(height: 20),
              Text(
                portal == 'Telebirr'
                    ? (l10n.locale.languageCode == 'am' ? 'የቴሌብር ድረ-ገጽ በመጫን ላይ...' : 'Launching Telebirr Checkout WebView...')
                    : (l10n.locale.languageCode == 'am' ? 'የጫፓ ድረ-ገጽ በመጫን ላይ...' : 'Launching Chapa Checkout WebView...'),
                style: TextStyle(fontSize: 12, color: AppTheme.textPrimary),
              ),
            ],
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pop(context); // close loader
      
      // Update booking to IN_SERVICE and mark payment held in Escrow
      ref.read(bookingsListProvider.notifier).updateBookingStatus(booking.id, BookingStatus.inService);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.locale.languageCode == 'am'
                ? 'ክፍያ ተፈጽሟል! ገንዘብ በዋስትና ሂሳብ ተይዟል።'
                : 'Payment successful! Funds are held safely in Escrow.',
          ),
          backgroundColor: AppTheme.success,
        ),
      );
    });
  }

  // ── Show Booking Details sheet (Centralized Management Hub) ─────────────────
  void _showBookingDetailsSheet(BookingModel b, AppLocalizations l10n) {
    final activeLang = l10n.locale.languageCode;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pull Bar & Title
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.outlineLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    activeLang == 'am' ? 'የትዕዛዝ ዝርዝሮች' : 'Booking Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusDotColor(b.status).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _statusLabel(b.status, activeLang),
                      style: TextStyle(
                        color: _statusDotColor(b.status),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Booking Overview Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.bgBase,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.outlineLighter),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      icon: Icons.person_outline,
                      label: activeLang == 'am' ? 'ባለሙያ' : 'Provider',
                      value: '${b.providerEmoji} ${b.providerName}',
                    ),
                    const Divider(height: 24, thickness: 1),
                    _buildDetailRow(
                      icon: Icons.work_outline,
                      label: activeLang == 'am' ? 'አገልግሎት' : 'Service',
                      value: b.serviceType,
                    ),
                    const Divider(height: 24, thickness: 1),
                    _buildDetailRow(
                      icon: Icons.calendar_today_outlined,
                      label: activeLang == 'am' ? 'ቀን' : 'Date',
                      value: DateFormat('MMM dd, yyyy').format(b.dateTime),
                    ),
                    const Divider(height: 24, thickness: 1),
                    _buildDetailRow(
                      icon: Icons.access_time,
                      label: activeLang == 'am' ? 'ሰዓት' : 'Time',
                      value: '${DateFormat('hh:mm a').format(b.dateTime)} — ${DateFormat('hh:mm a').format(b.dateTime.add(const Duration(minutes: 90)))}',
                    ),
                    const Divider(height: 24, thickness: 1),
                    _buildDetailRow(
                      icon: Icons.payments_outlined,
                      label: activeLang == 'am' ? 'ዋጋ' : 'Total Price',
                      value: '${b.priceEtb.toInt()} ETB',
                      valueColor: AppTheme.primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Escrow Note (If active)
              if (b.isEscrowHeld || b.status == BookingStatus.inService) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.success.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock, color: AppTheme.success, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.get('escrow_note'),
                          style: const TextStyle(
                            color: AppTheme.success,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Lifecycle Actions
              if (b.status == BookingStatus.accepted)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _cancelBooking(b.id, l10n);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.error,
                          side: const BorderSide(color: AppTheme.error),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(0, 48),
                        ),
                        child: Text(activeLang == 'am' ? 'ትዕዛዝ ሰርዝ' : 'Cancel Booking'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _showCheckoutPortal(b, l10n);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(0, 48),
                        ),
                        child: Text(activeLang == 'am' ? 'ክፍያ ፈጽም' : 'Secure Pay'),
                      ),
                    ),
                  ],
                )
              else if (b.status == BookingStatus.inService)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          context.go('/dispute/${b.id}');
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.error,
                          side: const BorderSide(color: AppTheme.error),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(0, 48),
                        ),
                        child: Text(l10n.get('dispute')),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          context.go('/review/${b.id}');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(0, 48),
                        ),
                        child: Text(activeLang == 'am' ? 'ተጠናቋል' : 'Mark Completed'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.bgElevated,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.chat_bubble_outline, color: AppTheme.textPrimary),
                        onPressed: () {
                          Navigator.pop(context);
                          context.push('/chat');
                        },
                      ),
                    ),
                  ],
                )
              else if (b.status == BookingStatus.completed)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          context.push('/chat');
                        },
                        icon: const Icon(Icons.chat_bubble_outline, size: 18),
                        label: Text(activeLang == 'am' ? 'የውይይት ታሪክ' : 'Chat History'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.textPrimary,
                          side: BorderSide(color: AppTheme.outlineLight),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(0, 48),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Rebook placeholder
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(activeLang == 'am' ? 'እንደገና የመያዣ ጥያቄ ተልኳል' : 'Rebooking request sent!'),
                              backgroundColor: AppTheme.success,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(0, 48),
                        ),
                        child: Text(activeLang == 'am' ? 'እንደገና ያዝ' : 'Book Again'),
                      ),
                    ),
                  ],
                )
              else if (b.status == BookingStatus.pending)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _cancelBooking(b.id, l10n);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.error,
                      side: const BorderSide(color: AppTheme.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(activeLang == 'am' ? 'ትዕዛዝ ሰርዝ' : 'Cancel Booking'),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textSecondary,
                      side: BorderSide(color: AppTheme.outlineLight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(activeLang == 'am' ? 'ዝጋ' : 'Close'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.textSecondary),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: valueColor ?? AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  // ── Show Quick Action Sheet (3-dots options menu) ───────────────────────────
  void _showMoreOptionsBottomSheet(BookingModel b, AppLocalizations l10n) {
    final activeLang = l10n.locale.languageCode;
    final canCancel = b.status == BookingStatus.pending ||
        b.status == BookingStatus.accepted ||
        b.status == BookingStatus.draft;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.chat_bubble_outline, color: AppTheme.textPrimary),
                title: Text(activeLang == 'am' ? 'ባለሙያውን አግኝ' : 'Chat with Provider'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/chat');
                },
              ),
              ListTile(
                leading: Icon(Icons.support_agent_outlined, color: AppTheme.textPrimary),
                title: Text(activeLang == 'am' ? 'እገዛ እና ድጋፍ' : 'Contact Support'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(activeLang == 'am' ? 'ድጋፍ ሰጪ ቡድኑ በቅርቡ ያነጋግርዎታል' : 'Support team notified!'),
                      backgroundColor: AppTheme.success,
                    ),
                  );
                },
              ),
              if (canCancel) ...[
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.cancel_outlined, color: AppTheme.error),
                  title: Text(
                    activeLang == 'am' ? 'ትዕዛዝ ሰርዝ' : 'Cancel Booking',
                    style: const TextStyle(color: AppTheme.error, fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _cancelBooking(b.id, l10n);
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // ── Execute Booking Cancellation ───────────────────────────────────────────
  void _cancelBooking(String id, AppLocalizations l10n) {
    final activeLang = l10n.locale.languageCode;
    ref.read(bookingsListProvider.notifier).cancelBooking(id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          activeLang == 'am'
              ? 'ትዕዛዙ በተሳካ ሁኔታ ተሰርዟል'
              : 'Booking successfully cancelled.',
        ),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeLang = ref.watch(languageProvider);
    final l10n = AppLocalizations(Locale(activeLang));
    final activeRole = ref.watch(currentRoleProvider);

    if (activeRole == 'provider') {
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppTheme.bgBase,
        drawer: const AppDrawer(),
        appBar: AppBar(
          backgroundColor: AppTheme.bgBase,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            activeLang == 'am' ? 'የትዕዛዝ ታሪክ' : 'Bookings',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppTheme.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              activeLang == 'am'
                  ? 'ይህ ክፍል ለባለሙያ ታሪክ የለም። እባክዎን ወደ ዳሽቦርድ ይመለሱ።'
                  : 'Booking history is not available in provider mode. Please use the dashboard instead.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppTheme.textSecondary, height: 1.5),
            ),
          ),
        ),
        bottomNavigationBar: widget.isShell
            ? null
            : ShukBottomNavBar(
                currentIndex: 1,
                activeRole: activeRole,
                activeLang: activeLang,
              ),
      );
    }

    final allBookings = ref.watch(bookingsListProvider);
    final filtered = _filteredBookings(allBookings);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.bgBase,
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: AppTheme.bgBase,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Shuk',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppTheme.textPrimary,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header "Your Bookings"
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Text(
              activeLang == 'am' ? 'የእርስዎ ትዕዛዞች' : 'Your Bookings',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ),

          // Custom Tabs Pill Container
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.bgElevated,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  _TabButton(
                    label: activeLang == 'am' ? 'የሚመጡ' : 'Upcoming',
                    isSelected: _activeTab == 'Upcoming',
                    onTap: () => setState(() => _activeTab = 'Upcoming'),
                  ),
                  _TabButton(
                    label: activeLang == 'am' ? 'ያለፉ' : 'Past',
                    isSelected: _activeTab == 'Past',
                    onTap: () => setState(() => _activeTab = 'Past'),
                  ),
                  _TabButton(
                    label: activeLang == 'am' ? 'የተሰረዙ' : 'Cancelled',
                    isSelected: _activeTab == 'Cancelled',
                    onTap: () => setState(() => _activeTab = 'Cancelled'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Bookings List View
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      activeLang == 'am' ? 'ምንም ትዕዛዝ አልተገኘም' : 'No bookings found.',
                      style: TextStyle(color: AppTheme.textTertiary, fontSize: 14),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final b = filtered[index];
                      final statusColor = _statusDotColor(b.status);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: GestureDetector(
                          onTap: () => _showBookingDetailsSheet(b, l10n),
                          onLongPress: () => _showMoreOptionsBottomSheet(b, l10n),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.cardBg,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppTheme.cardBorder, width: 1),
                              boxShadow: AppTheme.shadowSmall,
                            ),
                            child: IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // ── LEFT: Date Column ───────────────────────────
                                  Container(
                                    width: 80,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary.withValues(alpha: 0.10),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(17),
                                        bottomLeft: Radius.circular(17),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          DateFormat('MMM').format(b.dateTime).toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.primary,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                        Text(
                                          DateFormat('d').format(b.dateTime),
                                          style: TextStyle(
                                            fontSize: 34,
                                            fontWeight: FontWeight.w900,
                                            color: AppTheme.primary,
                                            height: 1.1,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${DateFormat('EEE').format(b.dateTime)} · ${DateFormat('hh:mm a').format(b.dateTime)}',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // ── RIGHT: Details ──────────────────────────────
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Top row: avatar + name + status chip
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 38,
                                                height: 38,
                                                decoration: BoxDecoration(
                                                  color: AppTheme.primary,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    b.providerEmoji,
                                                    style: const TextStyle(fontSize: 20),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  b.providerName,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppTheme.textPrimary,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: statusColor,
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  _statusLabel(b.status, activeLang),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          // Middle: service type
                                          Text(
                                            b.serviceType,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.textSecondary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          // Bottom row: price + View Details button
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '${b.priceEtb.toInt()} ETB',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w900,
                                                  color: AppTheme.primary,
                                                ),
                                              ),
                                              Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [AppTheme.primary, AppTheme.primaryLight],
                                                    begin: Alignment.centerLeft,
                                                    end: Alignment.centerRight,
                                                  ),
                                                  borderRadius: BorderRadius.circular(10),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: AppTheme.primary.withValues(alpha: 0.3),
                                                      blurRadius: 8,
                                                      offset: const Offset(0, 3),
                                                    ),
                                                  ],
                                                ),
                                                child: Material(
                                                  color: Colors.transparent,
                                                  child: InkWell(
                                                    onTap: () => _showBookingDetailsSheet(b, l10n),
                                                    borderRadius: BorderRadius.circular(10),
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                                      child: Text(
                                                        activeLang == 'am' ? '\u12dd\u122d\u12dd\u122d \u12ed\u1218\u120d\u12a8\u1271' : 'View Details',
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 11,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ), // IntrinsicHeight
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: widget.isShell
          ? null
          : ShukBottomNavBar(
              currentIndex: 1,
              activeRole: activeRole,
              activeLang: activeLang,
            ),
    );
  }
}

// ── Custom Tab selector Button ───────────────────────────────────────────────
class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [AppTheme.primary, AppTheme.primaryLight],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                  : null,
              color: isSelected ? null : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ]
                  : [],
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
