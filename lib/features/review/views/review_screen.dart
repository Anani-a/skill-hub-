import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../booking/models/booking_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../shared/providers/mock_state_providers.dart';
import '../../../core/router/nav_helpers.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  final String bookingId;

  const ReviewScreen({
    super.key,
    required this.bookingId,
  });

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  final TextEditingController _reviewController = TextEditingController();
  int _selectedRating = 5;
  final Set<String> _selectedCompliments = {'On Time', 'Professional'};

  final List<Map<String, String>> _complimentsList = [
    {'en': 'On Time', 'am': 'በሰዓቱ የደረሰ', 'emoji': '⏱️'},
    {'en': 'Professional', 'am': 'ሙያዊ', 'emoji': '👔'},
    {'en': 'Fair Price', 'am': 'ተመጣጣኝ ዋጋ', 'emoji': '💰'},
    {'en': 'Great Work', 'am': 'ጥሩ ሥራ', 'emoji': '✨'},
    {'en': 'Friendly', 'am': 'ትህትና ያለው', 'emoji': '🤝'},
    {'en': 'Clean & Tidy', 'am': 'ንጹህ አሠራር', 'emoji': '🧹'},
  ];

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _submitReview(AppLocalizations l10n) {
    final activeRole = ref.read(currentRoleProvider);
    // 1. Mark status complete in state provider
    ref.read(bookingsListProvider.notifier).updateBookingStatus(widget.bookingId, BookingStatus.completed);

    // 2. Redirect to booking page
    if (activeRole == 'provider') {
      ProviderNavHelper.go(context, ref, tab: 1);
    } else {
      CustomerNavHelper.go(context, ref, tab: 1);
    }

    // 3. Show confirmation feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.locale.languageCode == 'am'
              ? 'ለአስተያየትዎ እናመሰግናለን! ⭐'
              : 'Thank you for your rating & review! ⭐',
        ),
        backgroundColor: AppTheme.statusSuccess,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeLang = ref.watch(languageProvider);
    final l10n = AppLocalizations(Locale(activeLang));
    final bookings = ref.watch(bookingsListProvider);

    final booking = bookings.firstWhere(
      (b) => b.id == widget.bookingId,
      orElse: () => bookings.isNotEmpty ? bookings.first : mockBookingFallbackReview,
    );

    return Scaffold(
      backgroundColor: AppTheme.bgBase,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () {
            final activeRole = ref.read(currentRoleProvider);
            if (context.canPop()) {
              context.pop();
            } else if (activeRole == 'provider') {
              ProviderNavHelper.go(context, ref, tab: 1);
            } else {
              CustomerNavHelper.go(context, ref, tab: 1);
            }
          },
        ),
        title: Text(
          activeLang == 'am' ? 'አስተያየት እና ደረጃ' : 'Review & Rating',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // ── Top Purple Hero Profile Card ─────────────────────────────
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primaryLight],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 26),
              child: Column(
                children: [
                  Container(
                    width: 78,
                    height: 78,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(booking.providerEmoji, style: const TextStyle(fontSize: 38)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        booking.providerName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.verified_rounded, color: Colors.white, size: 18),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      booking.serviceType,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Interactive Rating Box ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.bgSurface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.outlineLighter),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.05),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          activeLang == 'am' ? 'ባለሙያውን እንዴት ገመገሙት?' : 'How was your experience?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          activeLang == 'am' ? 'ደረጃ ለመስጠት ኮከቦቹን ይጫኑ' : 'Tap a star to rate the provider',
                          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            final star = index + 1;
                            final isSelected = star <= _selectedRating;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedRating = star),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                child: Icon(
                                  isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                                  size: 44,
                                  color: isSelected ? const Color(0xFFF59E0B) : const Color(0xFFD1C4E9),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryContainer,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.outlineLight),
                          ),
                          child: Text(
                            _getRatingDescription(_selectedRating, activeLang),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Compliments / Positive Tags ─────────────────────────
                  Text(
                    activeLang == 'am' ? 'ምን ወደዱት?' : 'What did you like best?',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _complimentsList.map((c) {
                      final isSelected = _selectedCompliments.contains(c['en']);
                      final label = activeLang == 'am' ? c['am']! : c['en']!;
                      final emoji = c['emoji']!;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedCompliments.remove(c['en']);
                            } else {
                              _selectedCompliments.add(c['en']!);
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.primaryContainer : AppTheme.bgSurface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? AppTheme.primary : AppTheme.outlineLighter,
                              width: isSelected ? 1.5 : 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(emoji, style: const TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              Text(
                                label,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // ── Feedback Comment Box ────────────────────────────────
                  Text(
                    activeLang == 'am' ? 'ተጨማሪ አስተያየት (በምርጫ)' : 'Detailed Feedback (Optional)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.bgSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.outlineLighter),
                    ),
                    child: TextField(
                      controller: _reviewController,
                      maxLines: 4,
                      style: TextStyle(fontSize: 14, color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        hintText: activeLang == 'am'
                            ? 'ስለ አገልግሎት አሰጣጡ፣ ጥራቱ እና ፍጥነቱ አስተያየት ይፃፉ...'
                            : 'Write a few words about the quality, timeliness, and experience...',
                        hintStyle: TextStyle(color: AppTheme.textSecondary.withValues(alpha: 0.6), fontSize: 13),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Submit Button ───────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => _submitReview(l10n),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shadowColor: AppTheme.primary.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.send_rounded, size: 18, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            activeLang == 'am' ? 'አስተያየት ላክ' : 'Submit Review',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingDescription(int rating, String lang) {
    switch (rating) {
      case 1:
        return lang == 'am' ? 'በጣም መጥፎ (1 ኮከብ)' : 'Very Poor (1 Star)';
      case 2:
        return lang == 'am' ? 'መጥፎ (2 ኮከቦች)' : 'Poor (2 Stars)';
      case 3:
        return lang == 'am' ? 'መካከለኛ (3 ኮከቦች)' : 'Average (3 Stars)';
      case 4:
        return lang == 'am' ? 'ጥሩ (4 ኮከቦች)' : 'Good (4 Stars)';
      case 5:
      default:
        return lang == 'am' ? 'በጣም ምርጥ! (5 ኮከቦች)' : 'Outstanding! (5 Stars)';
    }
  }
}

// Fallback booking object in case lookup fails
final mockBookingFallbackReview = BookingModel(
  id: 'fallback',
  providerId: 'unknown',
  providerName: 'Sara Tadesse',
  providerEmoji: '👩‍🔧',
  serviceType: 'Home Cleaning',
  dateTime: DateTime.now(),
  status: BookingStatus.completed,
  priceEtb: 280.0,
  description: 'Deep house cleaning service completed with satisfaction.',
  isEscrowHeld: false,
);
