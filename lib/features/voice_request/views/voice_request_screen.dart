import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../shared/providers/mock_state_providers.dart';
import '../../booking/models/booking_model.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../core/router/nav_helpers.dart';

class VoiceRequestScreen extends ConsumerStatefulWidget {
  const VoiceRequestScreen({super.key});

  @override
  ConsumerState<VoiceRequestScreen> createState() => _VoiceRequestScreenState();
}

class _VoiceRequestScreenState extends ConsumerState<VoiceRequestScreen>
    with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  bool _hasRecording = false;
  int _secondsRecorded = 0;
  bool _isPlayingPreview = false;
  String _selectedCategory = 'General';

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _startMockRecording() {
    setState(() {
      _isRecording = true;
      _secondsRecorded = 0;
      _hasRecording = false;
    });
    _pulseController.repeat(reverse: true);

    // Simulate active recording timer ticking
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || !_isRecording) return false;
      setState(() {
        _secondsRecorded++;
      });
      return _secondsRecorded < 30; // cap at 30s
    });
  }

  void _stopMockRecording() {
    _pulseController.stop();
    _pulseController.reset();
    setState(() {
      _isRecording = false;
      _hasRecording = true;
    });
  }

  void _togglePreviewPlay() {
    if (_isPlayingPreview) {
      setState(() {
        _isPlayingPreview = false;
      });
    } else {
      setState(() {
        _isPlayingPreview = true;
      });
      Future.delayed(Duration(seconds: _secondsRecorded == 0 ? 5 : _secondsRecorded), () {
        if (mounted) {
          setState(() {
            _isPlayingPreview = false;
          });
        }
      });
    }
  }

  void _submitVoiceRequest(AppLocalizations l10n) {
    if (!_hasRecording) return;

    final categoryTitle = _selectedCategory == 'General'
        ? 'Voice Service Request'
        : '$_selectedCategory Voice Request';

    final newBooking = BookingModel(
      id: 'b_${DateTime.now().millisecondsSinceEpoch}',
      providerId: 'p1',
      providerName: 'Bekele Zewde',
      providerEmoji: '👨‍🔧',
      serviceType: categoryTitle,
      dateTime: DateTime.now().add(const Duration(hours: 2)),
      status: BookingStatus.pending,
      priceEtb: 450,
      description: 'Voice-based $_selectedCategory request with audio instructions attached.',
      isEscrowHeld: false,
      voiceNotePath: 'custom_voice_request.ogg',
      voiceNoteDurationSeconds: _secondsRecorded == 0 ? 12 : _secondsRecorded,
    );

    ref.read(bookingsListProvider.notifier).addBooking(newBooking);

    CustomerNavHelper.go(context, ref, tab: 2);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.locale.languageCode == 'am'
              ? 'የድምፅ አገልግሎት ጥያቄዎ በተሳካ ሁኔታ ተልኳል!'
              : 'Voice service request submitted successfully!',
        ),
        backgroundColor: AppTheme.statusSuccess,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeLang = ref.watch(languageProvider);
    final l10n = AppLocalizations(Locale(activeLang));

    final categories = [
      {'key': 'General', 'labelAm': 'አጠቃላይ', 'labelEn': 'General', 'icon': Icons.apps_rounded},
      {'key': 'Electrical', 'labelAm': 'ኤሌክትሪክ', 'labelEn': 'Electrical', 'icon': Icons.bolt_rounded},
      {'key': 'Plumbing', 'labelAm': 'ቧንቧ', 'labelEn': 'Plumbing', 'icon': Icons.plumbing_rounded},
      {'key': 'Cleaning', 'labelAm': 'ማጽዳት', 'labelEn': 'Cleaning', 'icon': Icons.cleaning_services_rounded},
      {'key': 'Tutoring', 'labelAm': 'ትምህርት', 'labelEn': 'Tutoring', 'icon': Icons.school_rounded},
    ];

    return Scaffold(
      backgroundColor: AppTheme.bgBase,
      appBar: AppBar(
        backgroundColor: AppTheme.bgBase,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary, size: 20),
          onPressed: () => CustomerNavHelper.go(context, ref, tab: 0),
        ),
        title: Text(
          activeLang == 'am' ? 'በድምፅ ማዘዣ' : 'Voice Service Request',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            children: [
              // ── Guide Card Banner ──────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.bgSurface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.outlineLighter),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.mic_rounded,
                        color: AppTheme.primary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activeLang == 'am' ? 'የሚፈልጉትን በድምፅ ይናገሩ' : 'Speak Your Request',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            activeLang == 'am'
                                ? 'ችግርዎን በድምፅ ይግለጹ (ምሳሌ፦ "ቦሌ ውስጥ የኤሌክትሪክ ጥገና እፈልጋለሁ")'
                                : 'Describe your problem clearly. We\'ll auto-match top providers for you.',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Category Selector Pills ──────────────────────────────────
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  activeLang == 'am' ? 'አማራጭ፡ ምድብ ይምረጡ' : 'Optional: Select Service Category',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final isSelected = _selectedCategory == cat['key'];
                    final label = activeLang == 'am' ? cat['labelAm'] as String : cat['labelEn'] as String;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = cat['key'] as String;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primary : AppTheme.bgSurface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? AppTheme.primary : AppTheme.outlineLighter,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              cat['icon'] as IconData,
                              size: 16,
                              color: isSelected ? Colors.white : AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? Colors.white : AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const Spacer(),

              // ── Middle Visualizer & Recording Display ───────────────────
              if (_isRecording) ...[
                Column(
                  children: [
                    // Timer display
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppTheme.statusError,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '00:${_secondsRecorded.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primary,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Waveform Bars Animation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(12, (index) {
                        final heights = [18.0, 34.0, 48.0, 26.0, 56.0, 38.0, 60.0, 30.0, 50.0, 22.0, 42.0, 20.0];
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 5,
                          height: heights[(index + _secondsRecorded) % heights.length],
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.secondary,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      activeLang == 'am' ? 'እየተቀዳ ነው... ለመጨረስ አዝራሩን ይልቀቁ' : 'Recording... Release button when finished',
                      style: TextStyle(
                        color: AppTheme.statusError,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ] else if (_hasRecording) ...[
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.bgSurface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
                        boxShadow: AppTheme.shadowSmall,
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: _togglePreviewPlay,
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppTheme.primary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primary.withValues(alpha: 0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _isPlayingPreview ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  activeLang == 'am' ? 'የተቀዳውን ድምፅ አዳምጥ' : 'Listen to Preview',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Duration: 00:${_secondsRecorded == 0 ? 12 : _secondsRecorded.toString().padLeft(2, '0')}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.graphic_eq_rounded, color: AppTheme.secondary, size: 24),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _hasRecording = false;
                          _secondsRecorded = 0;
                        });
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: Text(
                        activeLang == 'am' ? 'ድጋሚ መቅዳት' : 'Record Again',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textSecondary,
                        side: BorderSide(color: AppTheme.outlineLight),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Idle mic button state
                Column(
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryContainer.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2), width: 2),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.mic_none_rounded,
                          size: 56,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      activeLang == 'am' ? 'ለመቅዳት አዝራሩን ተጭነው ይያዙ' : 'Press & Hold the mic button below',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],

              const Spacer(),

              // ── Recording Trigger or Submit Action Button ─────────────────
              if (!_hasRecording)
                GestureDetector(
                  onLongPressStart: (_) => _startMockRecording(),
                  onLongPressEnd: (_) => _stopMockRecording(),
                  onTap: () {
                    if (!_isRecording) {
                      _startMockRecording();
                    } else {
                      _stopMockRecording();
                    }
                  },
                  child: ScaleTransition(
                    scale: _isRecording ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: _isRecording ? AppTheme.statusError : AppTheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_isRecording ? AppTheme.statusError : AppTheme.primary).withValues(alpha: 0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                          size: 38,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                )
              else
                GradientButton(
                  text: activeLang == 'am' ? 'የድምፅ ጥያቄውን ላክ' : 'Send Voice Request',
                  onPressed: () => _submitVoiceRequest(l10n),
                  width: double.infinity,
                  height: 52,
                  icon: Icons.send_rounded,
                  textColor: Colors.white,
                ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
