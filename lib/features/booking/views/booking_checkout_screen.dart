import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../home/providers/home_provider.dart';
import '../../home/models/provider_model.dart';
import '../models/booking_model.dart';
import '../../../shared/providers/mock_state_providers.dart' show languageProvider, bookingsListProvider;
import '../../../core/router/nav_helpers.dart';

class BookingCheckoutScreen extends ConsumerStatefulWidget {
  final String? providerId;

  const BookingCheckoutScreen({
    super.key,
    this.providerId,
  });

  @override
  ConsumerState<BookingCheckoutScreen> createState() =>
      _BookingCheckoutScreenState();
}

class _BookingCheckoutScreenState extends ConsumerState<BookingCheckoutScreen> {
  DateTime _currentCalendarMonth = DateTime.now();
  DateTime? _selectedDate;
  String _selectedTime = '10:30 AM';

  final List<Map<String, String>> _availableSlots = [
    {'period': 'Morning', 'time': '09:00 AM'},
    {'period': 'Morning', 'time': '10:30 AM'},
    {'period': 'Lunch', 'time': '12:00 PM'},
    {'period': 'Afternoon', 'time': '02:30 PM'},
    {'period': 'Afternoon', 'time': '04:00 PM'},
    {'period': 'Evening', 'time': '06:00 PM'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  // ── Helper to retrieve provider avatar URLs ────────────────────────────────
  String _getProviderAvatar(String? id) {
    switch (id) {
      case 'p1':
        return 'https://images.unsplash.com/photo-1540569014015-19a7be504e3a?w=120&fit=crop&q=80';
      case 'p2':
        return 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=120&fit=crop&q=80';
      case 'p3':
        return 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=120&fit=crop&q=80';
      default:
        return 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=120&fit=crop&q=80';
    }
  }

  // ── Calendar Days CalculationMON to SUN grid ───────────────────────────────
  List<DateTime> _generateCalendarDays() {
    final year = _currentCalendarMonth.year;
    final month = _currentCalendarMonth.month;
    
    final firstDay = DateTime(year, month, 1);
    final firstWeekday = firstDay.weekday; // 1 = Mon, 7 = Sun
    
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final List<DateTime> days = [];
    
    // Padding start of the grid (previous month days)
    final prevMonthLastDay = DateTime(year, month, 0).day;
    final int daysBefore = firstWeekday - 1;
    for (int i = daysBefore - 1; i >= 0; i--) {
      days.add(DateTime(year, month - 1, prevMonthLastDay - i));
    }
    
    // Current month days
    for (int i = 1; i <= daysInMonth; i++) {
      days.add(DateTime(year, month, i));
    }
    
    // Padding end of the grid (next month days) to pad to multiple of 7
    final int totalCells = ((days.length / 7).ceil()) * 7;
    final int daysAfter = totalCells - days.length;
    for (int i = 1; i <= daysAfter; i++) {
      days.add(DateTime(year, month + 1, i));
    }
    
    return days;
  }

  // ── Confirm Booking & Add to List ──────────────────────────────────────────
  void _confirmBooking(ProviderModel provider) {
    final activeLang = ref.read(languageProvider);
    final serviceRate = provider.hourlyRateEtb.toDouble();

    final newBooking = BookingModel(
      id: 'b${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      providerId: provider.id,
      providerName: provider.name,
      providerEmoji: provider.emoji,
      serviceType: provider.specialty,
      dateTime: _selectedDate ?? DateTime.now(),
      status: BookingStatus.pending,
      priceEtb: serviceRate,
      description: activeLang == 'am'
          ? 'የእርስዎ እቃ እና አገልግሎት ስለሚያስፈልጉት ዝርዝር እባክዎን ይጨምሩ።'
          : 'Customer request is pending. Please review the service requirements and confirm.',
      isEscrowHeld: false,
    );

    ref.read(bookingsListProvider.notifier).addBooking(newBooking);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          activeLang == 'am'
              ? 'ትዕዛዝ በተሳካ ሁኔታ ተይዟል!'
              : 'Booking confirmed successfully!',
        ),
        backgroundColor: AppTheme.success,
      ),
    );

    CustomerNavHelper.go(context, ref, tab: 2);
  }

  @override
  Widget build(BuildContext context) {
    final activeLang = ref.watch(languageProvider);

    // Retrieve provider information
    final rawProvider = ref.watch(providerByIdProvider(widget.providerId ?? ''));
    final displayProvider = rawProvider ?? ProviderModel(
      id: 'default',
      name: 'Marcus V. Sterling',
      emoji: '👨‍💼',
      specialty: 'Premium Interior Consultant',
      specialtyAmharic: 'ፕሪሚየም የውስጥ ዲዛይን አማካሪ',
      rating: 4.9,
      distanceKm: 2.4,
      jobsCount: 124,
      hourlyRateEtb: 240,
      isOnline: true,
      verificationStatus: VerificationStatus.verified,
      bio: 'Expert consultant specializing in interior and premium home organization.',
      skills: ['Consulting', 'Design', 'Space planning'],
    );

    final serviceFee = displayProvider.hourlyRateEtb.toDouble();
    const processingFee = 12.50;
    final totalPayment = serviceFee + processingFee;

    return Scaffold(
      backgroundColor: AppTheme.bgBase,
      appBar: AppBar(
        backgroundColor: AppTheme.bgBase,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF512DA8), size: 24),
          onPressed: () => context.pop(),
        ),
        title: Text(
          activeLang == 'am' ? 'ቀጠሮ ማስተካከያ' : 'Schedule Service',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFF3EEFF),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD1C4E9), width: 1.5),
            ),
            child: const Icon(Icons.person_outline_rounded, size: 18, color: Color(0xFF512DA8)),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Title Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF512DA8),
                    Color(0xFF7E57C2),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF512DA8).withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          activeLang == 'am' ? 'ደረጃ 1 ከ 2' : 'STEP 1 OF 2',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    activeLang == 'am' ? 'አገልግሎትዎን ያቅዱ' : 'Schedule Your Service',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    activeLang == 'am'
                        ? 'ቀጠሮዎን ለማጠናቀቅ የሚመርጡትን ቀን እና ሰዓት ይምረጡ።'
                        : 'Select your preferred date and time to finalize your appointment.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── 1. Select Date Section ───────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.bgSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.outlineLighter),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [
                  // Select Date & Prev/Next Arrows Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_month_rounded, color: Color(0xFF512DA8), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('MMMM yyyy').format(_currentCalendarMonth),
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF512DA8),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _currentCalendarMonth = DateTime(
                                  _currentCalendarMonth.year,
                                  _currentCalendarMonth.month - 1,
                                );
                              });
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3EEFF),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFD1C4E9)),
                              ),
                              child: const Icon(Icons.chevron_left_rounded, size: 20, color: Color(0xFF512DA8)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _currentCalendarMonth = DateTime(
                                  _currentCalendarMonth.year,
                                  _currentCalendarMonth.month + 1,
                                );
                              });
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3EEFF),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFD1C4E9)),
                              ),
                              child: const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFF512DA8)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Calendar Grid Days
                  _buildCalendarGrid(),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── 2. Available Slots Section ───────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.bgSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.outlineLighter),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: _buildSlotsSection(),
            ),
            const SizedBox(height: 24),

            // ── 3. Booking Summary Section ───────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.bgSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.outlineLighter),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.assignment_outlined, color: Color(0xFF512DA8), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        activeLang == 'am' ? 'የትዕዛዝ ማጠቃለያ' : 'Booking Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Provider Details Card
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF512DA8).withValues(alpha: 0.3), width: 1.5),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            _getProviderAvatar(displayProvider.id),
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 56,
                              height: 56,
                              color: const Color(0xFFF3EEFF),
                              child: const Icon(Icons.person, color: Color(0xFF512DA8)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayProvider.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              activeLang == 'am' ? displayProvider.specialtyAmharic : displayProvider.specialty,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF512DA8),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, color: Color(0xFFFF9800), size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  '${displayProvider.rating} (${displayProvider.jobsCount} ${activeLang == 'am' ? 'ገምጋሚዎች' : 'reviews'})',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32, thickness: 1),

                  // Service & Price row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'SERVICE',
                              style: TextStyle(
                                color: Color(0xFF512DA8),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              activeLang == 'am' ? displayProvider.specialtyAmharic : displayProvider.specialty,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${serviceFee.toInt()} ETB',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF512DA8),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32, thickness: 1),

                  // Schedule rows (Date, Time, Location)
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFF512DA8)),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate != null
                            ? DateFormat('MMMM dd, yyyy').format(_selectedDate!)
                            : 'Select a date',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 16, color: Color(0xFF512DA8)),
                      const SizedBox(width: 12),
                      Text(
                        '$_selectedTime (90 mins)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 16, color: Color(0xFF512DA8)),
                      const SizedBox(width: 12),
                      Text(
                        'Bole District, Addis Ababa',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Cost breakdown table
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F7FC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.outlineLighter),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              activeLang == 'am' ? 'የአገልግሎት ዋጋ' : 'Service Fee',
                              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                            ),
                            Text(
                              '${serviceFee.toInt()} ETB',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              activeLang == 'am' ? 'የአገልግሎት ክፍያ' : 'Processing',
                              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                            ),
                            Text(
                              '${processingFee.toStringAsFixed(2)} ETB',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                            ),
                          ],
                        ),
                        const Divider(height: 24, thickness: 1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              activeLang == 'am' ? 'ጠቅላላ ክፍያ' : 'Total Payment',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                            ),
                            Text(
                              '${totalPayment.toStringAsFixed(2)} ETB',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF512DA8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Confirm button (Rich Purple Primary Action)
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => _confirmBooking(displayProvider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF512DA8),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        shadowColor: const Color(0xFF512DA8).withValues(alpha: 0.4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            activeLang == 'am' ? 'ትዕዛዝ ያረጋግጡ' : 'Confirm Booking',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Caption below button
                  Center(
                    child: Text(
                      activeLang == 'am' ? 'ባለሙያው እስኪቀበል ድረስ ምንም ክፍያ አይጠየቁም' : 'No charge until the provider accepts.',
                      style: TextStyle(fontSize: 11, color: AppTheme.textTertiary, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Footer (Vetted talent & secure pay badges)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.security_outlined, size: 14, color: AppTheme.textTertiary),
                const SizedBox(width: 4),
                Text(
                  activeLang == 'am' ? 'የተጠበቀ ክፍያ' : 'SECURE PAY',
                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: AppTheme.textTertiary, letterSpacing: 0.5),
                ),
                const SizedBox(width: 20),
                Icon(Icons.verified_outlined, size: 14, color: AppTheme.textTertiary),
                const SizedBox(width: 4),
                Text(
                  activeLang == 'am' ? 'የተረጋገጡ ባለሙያዎች' : 'VETTED TALENT',
                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: AppTheme.textTertiary, letterSpacing: 0.5),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Calendar Month Grid Builder ────────────────────────────────────────────
  Widget _buildCalendarGrid() {
    final calendarDays = _generateCalendarDays();
    final currentMonth = _currentCalendarMonth.month;

    return Column(
      children: [
        // Weekday header abbreviations
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'].map((day) {
            return SizedBox(
              width: 32,
              child: Center(
                child: Text(
                  day,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF512DA8),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        // Days numbers
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: calendarDays.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 10,
            crossAxisSpacing: 8,
            childAspectRatio: 1.0,
          ),
          itemBuilder: (context, index) {
            final day = calendarDays[index];
            final isCurrentMonth = day.month == currentMonth;
            final isSelected = _selectedDate != null &&
                _selectedDate!.year == day.year &&
                _selectedDate!.month == day.month &&
                _selectedDate!.day == day.day;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDate = day;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF512DA8)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF512DA8).withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    day.day.toString(),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : (isCurrentMonth ? AppTheme.textPrimary : AppTheme.textTertiary),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ── Available Slots Grid Builder ───────────────────────────────────────────
  Widget _buildSlotsSection() {
    final activeLang = ref.watch(languageProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.access_time_filled_rounded, color: Color(0xFF512DA8), size: 20),
            const SizedBox(width: 8),
            Text(
              activeLang == 'am' ? 'የሚገኙ ሰዓቶች' : 'Available Slots',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _availableSlots.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.3,
          ),
          itemBuilder: (context, index) {
            final slot = _availableSlots[index];
            final isSelected = _selectedTime == slot['time'];

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTime = slot['time']!;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF512DA8) : AppTheme.bgSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF512DA8)
                        : AppTheme.outlineLight,
                    width: 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF512DA8).withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activeLang == 'am' 
                          ? (slot['period'] == 'Morning' ? 'ጠዋት' : slot['period'] == 'Lunch' ? 'ምሳ' : slot['period'] == 'Afternoon' ? 'ከሰዓት' : 'ማታ')
                          : slot['period']!,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? Colors.white.withValues(alpha: 0.8) : AppTheme.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      slot['time']!,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
