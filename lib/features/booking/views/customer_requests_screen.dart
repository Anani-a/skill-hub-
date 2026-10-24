import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/mock_state_providers.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../models/booking_model.dart';

class CustomerRequestsScreen extends ConsumerStatefulWidget {
  final bool isShell;
  const CustomerRequestsScreen({super.key, this.isShell = false});

  @override
  ConsumerState<CustomerRequestsScreen> createState() => _CustomerRequestsScreenState();
}

class _CustomerRequestsScreenState extends ConsumerState<CustomerRequestsScreen> {
  String _selectedFilter = 'All'; // All, Voice Notes, Direct
  String? _playingVoiceBookingId;

  @override
  Widget build(BuildContext context) {
    final activeLang = ref.watch(languageProvider);
    final activeRole = ref.watch(currentRoleProvider);
    final allBookings = ref.watch(bookingsListProvider);

    // Filter strictly for pending customer requests awaiting provider acceptance
    final pendingRequests = allBookings.where((b) => b.status == BookingStatus.pending || b.status == BookingStatus.draft).toList();

    final filteredRequests = pendingRequests.where((b) {
      if (_selectedFilter == 'Voice Notes') {
        return b.voiceNotePath != null;
      }
      if (_selectedFilter == 'Direct') {
        return b.voiceNotePath == null;
      }
      return true; // 'All'
    }).toList();

    final voiceCount = pendingRequests.where((b) => b.voiceNotePath != null).length;
    final directCount = pendingRequests.where((b) => b.voiceNotePath == null).length;

    return Scaffold(
      backgroundColor: AppTheme.bgBase,
      appBar: AppBar(
        backgroundColor: AppTheme.bgSurface,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.primaryLight.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.assignment_rounded, color: AppTheme.primaryLight, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activeLang == 'am' ? 'የጥያቄ ደብተር' : 'Request Book',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    activeLang == 'am' ? 'በመጠበቅ ላይ ያሉ የአገልግሎት ጥያቄዎች' : 'Pending requests awaiting acceptance',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Info Banner
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryLight.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: AppTheme.primaryLight, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    activeLang == 'am'
                        ? 'ባለሙያው ጥያቄዎን ሲቀበል ወደ "Bookings" ገጽ ይመለሳል።'
                        : 'Once accepted by a provider, your request automatically moves to the "Bookings" tab.',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.primaryLight,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildFilterChip('All', activeLang == 'am' ? 'ሁሉም ጥያቄዎች' : 'All Requests', pendingRequests.length),
                const SizedBox(width: 8),
                _buildFilterChip('Voice Notes', activeLang == 'am' ? 'የድምፅ ጥያቄ' : 'Voice Requests', voiceCount),
                const SizedBox(width: 8),
                _buildFilterChip('Direct', activeLang == 'am' ? 'ቀጥታ ጥያቄ' : 'Direct Bookings', directCount),
              ],
            ),
          ),

          // Request List
          Expanded(
            child: filteredRequests.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_outline_rounded, size: 56, color: AppTheme.textTertiary),
                        const SizedBox(height: 12),
                        Text(
                          activeLang == 'am' ? 'ምንም በመጠበቅ ላይ ያለ ጥያቄ የለም' : 'No pending requests',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          activeLang == 'am'
                              ? 'ተቀባይነት ያገኙ ትዕዛዞች በ "Bookings" ገጽ ላይ ይገኛሉ'
                              : 'Accepted bookings can be tracked in your Bookings tab',
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),

                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    itemCount: filteredRequests.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final booking = filteredRequests[index];
                      return RepaintBoundary(
                        child: _buildPendingRequestCard(booking, activeLang),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: widget.isShell
          ? null
          : ShukBottomNavBar(
              currentIndex: 2, // MIDDLE TAB!
              activeRole: activeRole,
              activeLang: activeLang,
            ),
    );
  }

  Widget _buildFilterChip(String key, String label, int count) {
    final isActive = _selectedFilter == key;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primary : AppTheme.bgElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppTheme.primary : AppTheme.outlineLighter,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : AppTheme.textSecondary,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isActive ? Colors.white.withValues(alpha: 0.2) : AppTheme.bgContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.white : AppTheme.textTertiary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingRequestCard(BookingModel booking, String activeLang) {
    final isPlayingThis = _playingVoiceBookingId == booking.id;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.statusWarning.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Service Type + Pending Tag
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.serviceType,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '#${booking.id} • Requested for ${_formatDateTime(booking.dateTime)}',
                      style: TextStyle(fontSize: 11, color: AppTheme.textTertiary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.statusWarning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.statusWarning.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppTheme.statusWarning,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'AWAITING ACCEPTANCE',
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppTheme.statusWarning),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Provider info
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(booking.providerEmoji, style: const TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Requested Provider: ${booking.providerName}',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textPrimary),
                    ),
                    Text(
                      'Estimated Price: ${booking.priceEtb.toStringAsFixed(0)} ETB',
                      style: TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Voice Note Banner if present
          if (booking.voiceNotePath != null) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                setState(() {
                  _playingVoiceBookingId = isPlayingThis ? null : booking.id;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.primaryLight.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPlayingThis ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                      color: AppTheme.primaryLight,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isPlayingThis ? 'Playing voice instruction...' : 'Voice instruction attached',
                        style: const TextStyle(fontSize: 11, color: AppTheme.primaryLight, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${booking.voiceNoteDurationSeconds ?? 15}s 🎙️',
                      style: const TextStyle(fontSize: 10, color: AppTheme.primaryLight),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Description Snippet
          if (booking.description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              booking.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.3),
            ),
          ],

          const SizedBox(height: 14),

          // Bottom Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/booking-details/${booking.id}'),
                  icon: const Icon(Icons.info_outline_rounded, size: 14),
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(activeLang == 'am' ? 'ዝርዝር እይ' : 'View Details', style: const TextStyle(fontSize: 11)),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textSecondary,
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
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
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary),
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
                    if (!mounted) return;
                    if (confirm == true) {
                      ref.read(bookingsListProvider.notifier).cancelBooking(booking.id);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            activeLang == 'am'
                                ? 'ጥያቄዎ ተሰርዟል'
                                : 'Your request has been cancelled',
                          ),
                          backgroundColor: AppTheme.error,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.cancel_outlined, size: 14),
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(activeLang == 'am' ? 'ጥያቄ ሰርዝ' : 'Cancel Request', style: const TextStyle(fontSize: 11)),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.error.withValues(alpha: 0.15),
                    foregroundColor: AppTheme.error,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
      return 'Today, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
