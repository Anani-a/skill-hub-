import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/mock_state_providers.dart';
import '../models/chat_model.dart';
import '../../../features/booking/models/booking_model.dart';
import '../../../core/router/nav_helpers.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String? bookingId;

  const ChatScreen({super.key, this.bookingId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isPlayingVoicePreview = false;
  String? _playingMsgId;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(() {
      setState(() => _hasText = _messageController.text.trim().isNotEmpty);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendTextMessage() {
    if (_messageController.text.trim().isEmpty) return;
    final text = _messageController.text.trim();
    final role = ref.read(currentRoleProvider);
    final isProvider = role == 'provider';

    ref.read(chatMessagesProvider.notifier).sendMessage(
      text,
      MessageType.text,
      senderRole: isProvider ? SenderRole.provider : SenderRole.customer,
      senderName: isProvider ? 'Bekele Tadesse' : 'Abel Abreham',
    );
    _messageController.clear();
    _scrollToBottom();

    // Simulate auto-response
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        ref.read(chatMessagesProvider.notifier).receiveMockResponse(
          isProvider
              ? 'Ok, thank you! I will be waiting.'
              : "Ok Abel, I am on my way now! I'll call you when I reach your gate.",
          isProvider ? 'Abel Abreham' : 'Bekele Tadesse',
        );
        _scrollToBottom();
      }
    });
  }

  void _sendVoiceMessage() {
    final role = ref.read(currentRoleProvider);
    final isProvider = role == 'provider';

    ref.read(chatMessagesProvider.notifier).sendMessage(
      'Voice Instruction Note',
      MessageType.voice,
      voiceDuration: 7,
      senderRole: isProvider ? SenderRole.provider : SenderRole.customer,
      senderName: isProvider ? 'Bekele Tadesse' : 'Abel Abreham',
    );
    _scrollToBottom();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.mic_rounded, color: Colors.white, size: 18),
            SizedBox(width: 10),
            Text('Voice note sent (00:07)'),
          ],
        ),
        backgroundColor: const Color(0xFF512DA8),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    // Auto response
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        ref.read(chatMessagesProvider.notifier).receiveMockResponse(
          isProvider
              ? 'Got your voice instruction. Working on it now!'
              : 'Thank you for the voice note, I listened to it clearly.',
          isProvider ? 'Abel Abreham' : 'Bekele Tadesse',
        );
        _scrollToBottom();
      }
    });
  }

  void _playSimulatedVoice(String id, int duration) {
    setState(() {
      _isPlayingVoicePreview = true;
      _playingMsgId = id;
    });
    Future.delayed(Duration(seconds: duration), () {
      if (mounted) {
        setState(() {
          _isPlayingVoicePreview = false;
          _playingMsgId = null;
        });
      }
    });
  }

  void _showCallDialog(BuildContext context, String name, String roleLabel) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _SimulatedCallDialog(name: name, roleLabel: roleLabel),
    );
  }

  void _showAttachmentModal(BuildContext context) {
    final activeLang = ref.watch(languageProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.bgSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.outlineLight,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              activeLang == 'am' ? 'አባሪ ይላኩ' : 'Send Attachment',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _AttachmentOption(
                  icon: Icons.camera_alt_rounded,
                  label: activeLang == 'am' ? 'ካሜራ' : 'Camera',
                  color: const Color(0xFFE91E63),
                  onTap: () {
                    Navigator.pop(ctx);
                    _sendMockAttachment('Photo attachment', '📸 Photo sent');
                  },
                ),
                _AttachmentOption(
                  icon: Icons.photo_library_rounded,
                  label: activeLang == 'am' ? 'ፎቶ' : 'Gallery',
                  color: const Color(0xFF7E57C2),
                  onTap: () {
                    Navigator.pop(ctx);
                    _sendMockAttachment('Image from gallery', '🖼️ Image sent');
                  },
                ),
                _AttachmentOption(
                  icon: Icons.mic_rounded,
                  label: activeLang == 'am' ? 'ድምፅ' : 'Voice Note',
                  color: const Color(0xFF26A69A),
                  onTap: () {
                    Navigator.pop(ctx);
                    _sendVoiceMessage();
                  },
                ),
                _AttachmentOption(
                  icon: Icons.location_on_rounded,
                  label: activeLang == 'am' ? 'አካባቢ' : 'Location',
                  color: const Color(0xFFFF9800),
                  onTap: () {
                    Navigator.pop(ctx);
                    _sendMockAttachment('Bole Road, Addis Ababa, Ethiopia', '📍 Location shared');
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _sendMockAttachment(String text, String snackMessage) {
    final role = ref.read(currentRoleProvider);
    final isProvider = role == 'provider';

    ref.read(chatMessagesProvider.notifier).sendMessage(
      text,
      MessageType.text,
      senderRole: isProvider ? SenderRole.provider : SenderRole.customer,
      senderName: isProvider ? 'Bekele Tadesse' : 'Abel Abreham',
    );
    _scrollToBottom();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(snackMessage),
        backgroundColor: const Color(0xFF512DA8),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeLang = ref.watch(languageProvider);
    final messages = ref.watch(chatMessagesProvider);
    final activeRole = ref.watch(currentRoleProvider);
    final isProvider = activeRole == 'provider';
    final bookings = ref.watch(bookingsListProvider);

    BookingModel? pinnedBooking;
    if (widget.bookingId == null) {
      final activeBookings = bookings.where((b) =>
          b.status == BookingStatus.accepted ||
          b.status == BookingStatus.inService ||
          b.status == BookingStatus.pending);
      if (activeBookings.isNotEmpty) pinnedBooking = activeBookings.first;
    } else {
      final matched = bookings.where((b) => b.id == widget.bookingId);
      if (matched.isNotEmpty) pinnedBooking = matched.first;
    }

    final counterpartName = isProvider ? 'Abel Abreham' : 'Bekele Tadesse';
    final counterpartInitials = isProvider ? 'AA' : 'BT';
    final counterpartColor = isProvider ? const Color(0xFF26A69A) : const Color(0xFF512DA8);
    final counterpartRole = isProvider
        ? (activeLang == 'am' ? 'ደንበኛ' : 'Customer')
        : (activeLang == 'am' ? 'ባለሙያ' : 'Service Provider');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FB),
      // ── App Bar ───────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: const Color(0xFFEDE7F6),
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF512DA8), size: 24),
          onPressed: () {
            final role = ref.read(currentRoleProvider);
            if (role == 'provider') {
              ProviderNavHelper.go(context, ref, tab: 3);
            } else {
              CustomerNavHelper.go(context, ref, tab: 3);
            }
          },
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            // Avatar
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: counterpartColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: counterpartColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      counterpartInitials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Online dot
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            // Name + status
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    counterpartName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        activeLang == 'am' ? 'ተያይዟል' : 'Online',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF4CAF50),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '· $counterpartRole',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9E9E9E),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Call button
          IconButton(
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF3EEFF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.phone_rounded, color: Color(0xFF512DA8), size: 18),
            ),
            onPressed: () => _showCallDialog(context, counterpartName, counterpartRole),
          ),
          // More Popup Menu
          PopupMenuButton<String>(
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF3EEFF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.more_vert_rounded, color: Color(0xFF512DA8), size: 18),
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: (val) {
              if (val == 'profile') {
                context.push('/provider-profile/p1');
              } else if (val == 'booking' && pinnedBooking != null) {
                context.push('/booking-details/${pinnedBooking.id}');
              } else if (val == 'clear') {
                ref.read(chatMessagesProvider.notifier).clearMessages();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(activeLang == 'am' ? 'የውይይት ታሪክ ተሰርዟል' : 'Chat history cleared'),
                    backgroundColor: const Color(0xFF512DA8),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(Icons.person_outline_rounded, color: Color(0xFF512DA8), size: 18),
                    const SizedBox(width: 10),
                    Text(activeLang == 'am' ? 'መገለጫ እይ' : 'View Profile'),
                  ],
                ),
              ),
              if (pinnedBooking != null)
                PopupMenuItem(
                  value: 'booking',
                  child: Row(
                    children: [
                      const Icon(Icons.assignment_outlined, color: Color(0xFF512DA8), size: 18),
                      const SizedBox(width: 10),
                      Text(activeLang == 'am' ? 'የትዕዛዝ ዝርዝር' : 'Booking Details'),
                    ],
                  ),
                ),
              PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                    const SizedBox(width: 10),
                    Text(activeLang == 'am' ? 'ታሪክ አፅዳ' : 'Clear Chat', style: const TextStyle(color: Colors.redAccent)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 6),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFEDE7F6)),
        ),
      ),
      body: Column(
        children: [
          // Pinned booking pill
          if (pinnedBooking != null) _PinnedBookingPill(booking: pinnedBooking, activeLang: activeLang),

          // ── Date separator ─────────────────────────────────────────────
          _DateSeparator(label: activeLang == 'am' ? 'ዛሬ' : 'Today'),

          // ── Messages ───────────────────────────────────────────────────
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Text(
                      activeLang == 'am' ? 'ምንም መልዕክት የለም' : 'No messages yet',
                      style: const TextStyle(color: Color(0xFFBBB0D0), fontSize: 13),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final m = messages[index];
                      final isMe = isProvider
                          ? m.senderRole == SenderRole.provider
                          : m.senderRole == SenderRole.customer;

                      return _ChatBubble(
                        message: m,
                        isMe: isMe,
                        isPlayingVoice: _isPlayingVoicePreview && _playingMsgId == m.id,
                        onPlayVoice: () => _playSimulatedVoice(m.id, m.voiceDurationSeconds ?? 5),
                      );
                    },
                  ),
          ),

          // ── Input Bar ─────────────────────────────────────────────────
          _MessageInputBar(
            controller: _messageController,
            hasText: _hasText,
            activeLang: activeLang,
            onSend: _sendTextMessage,
            onMic: _sendVoiceMessage,
            onAttach: () => _showAttachmentModal(context),
          ),
        ],
      ),
    );
  }
}

// ── Attachment Option Widget ──────────────────────────────────────────────────
class _AttachmentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AttachmentOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Simulated Call Dialog ────────────────────────────────────────────────────
class _SimulatedCallDialog extends StatefulWidget {
  final String name;
  final String roleLabel;
  const _SimulatedCallDialog({required this.name, required this.roleLabel});

  @override
  State<_SimulatedCallDialog> createState() => _SimulatedCallDialogState();
}

class _SimulatedCallDialogState extends State<_SimulatedCallDialog> {
  int _seconds = 0;
  Timer? _timer;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) setState(() => _seconds++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mins = (_seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (_seconds % 60).toString().padLeft(2, '0');

    return Dialog(
      backgroundColor: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pulse Avatar
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF512DA8), width: 3),
              ),
              child: CircleAvatar(
                radius: 40,
                backgroundColor: const Color(0xFF512DA8),
                child: Text(
                  widget.name.isNotEmpty ? widget.name[0] : 'U',
                  style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.name,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.roleLabel} · In Call ($mins:$secs)',
              style: const TextStyle(color: Color(0xFF26A69A), fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 32),

            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Mute
                GestureDetector(
                  onTap: () => setState(() => _isMuted = !_isMuted),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _isMuted ? Colors.white : Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                      color: _isMuted ? Colors.black : Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                // End Call
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.call_end_rounded, color: Colors.white, size: 28),
                  ),
                ),
                // Speaker
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.volume_up_rounded, color: Colors.white, size: 24),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Pinned Booking Pill ───────────────────────────────────────────────────────
class _PinnedBookingPill extends StatelessWidget {
  final BookingModel booking;
  final String activeLang;
  const _PinnedBookingPill({required this.booking, required this.activeLang});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusLabel;
    switch (booking.status) {
      case BookingStatus.pending:
        statusColor = const Color(0xFFFF9800);
        statusLabel = activeLang == 'am' ? 'በጥበቃ ላይ' : 'Pending';
        break;
      case BookingStatus.accepted:
        statusColor = const Color(0xFF26A69A);
        statusLabel = activeLang == 'am' ? 'ተቀብሏል' : 'Accepted';
        break;
      case BookingStatus.inService:
        statusColor = const Color(0xFF512DA8);
        statusLabel = activeLang == 'am' ? 'በስራ ላይ' : 'In Service';
        break;
      default:
        statusColor = const Color(0xFF9E9E9E);
        statusLabel = booking.status.name;
    }

    return GestureDetector(
      onTap: () => context.push('/booking-details/${booking.id}'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEDE7F6)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF512DA8).withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.assignment_rounded, color: Color(0xFF512DA8), size: 16),
            const SizedBox(width: 8),
            Text(
              booking.serviceType,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: statusColor.withValues(alpha: 0.3)),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF9575CD), size: 18),
          ],
        ),
      ),
    );
  }
}

// ── Date Separator ────────────────────────────────────────────────────────────
class _DateSeparator extends StatelessWidget {
  final String label;
  const _DateSeparator({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(child: Divider(color: AppTheme.outlineLighter, indent: 24, endIndent: 12)),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(child: Divider(color: AppTheme.outlineLighter, indent: 12, endIndent: 24)),
        ],
      ),
    );
  }
}

// ── Chat Bubble ───────────────────────────────────────────────────────────────
class _ChatBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final bool isPlayingVoice;
  final VoidCallback onPlayVoice;

  const _ChatBubble({
    required this.message,
    required this.isMe,
    required this.isPlayingVoice,
    required this.onPlayVoice,
  });

  @override
  Widget build(BuildContext context) {
    final m = message;
    final timeStr = '${m.timestamp.hour}:${m.timestamp.minute.toString().padLeft(2, '0')} ${m.timestamp.hour < 12 ? 'AM' : 'PM'}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe) const SizedBox(width: 4),
              // Bubble
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.72,
                ),
                child: Container(
                  padding: m.type == MessageType.voice
                      ? const EdgeInsets.symmetric(horizontal: 14, vertical: 10)
                      : const EdgeInsets.fromLTRB(16, 12, 16, 10),
                  decoration: BoxDecoration(
                    color: isMe ? AppTheme.primary : AppTheme.bgSurface,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isMe ? 18 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isMe
                            ? AppTheme.primary.withValues(alpha: 0.22)
                            : Colors.black.withValues(alpha: 0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Content
                      if (m.type == MessageType.text)
                        Text(
                          m.content,
                          style: TextStyle(
                            color: isMe ? Colors.white : AppTheme.textPrimary,
                            fontSize: 14,
                            height: 1.45,
                          ),
                        )
                      else if (m.type == MessageType.voice)
                        GestureDetector(
                          onTap: onPlayVoice,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isPlayingVoice
                                    ? Icons.pause_circle_filled_rounded
                                    : Icons.play_circle_fill_rounded,
                                color: isMe ? Colors.white : const Color(0xFF512DA8),
                                size: 32,
                              ),
                              const SizedBox(width: 8),
                              // Waveform bars
                              Row(
                                children: List.generate(14, (i) {
                                  final heights = [10.0, 16.0, 8.0, 20.0, 12.0, 18.0, 8.0, 22.0, 10.0, 16.0, 12.0, 8.0, 18.0, 10.0];
                                  return Container(
                                    width: 3,
                                    height: heights[i],
                                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                    decoration: BoxDecoration(
                                      color: isMe
                                          ? Colors.white.withValues(alpha: isPlayingVoice ? 1.0 : 0.6)
                                          : const Color(0xFF512DA8).withValues(alpha: isPlayingVoice ? 1.0 : 0.5),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  );
                                }),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '00:${(m.voiceDurationSeconds ?? 5).toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  color: isMe ? Colors.white.withValues(alpha: 0.8) : const Color(0xFF9E9E9E),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Timestamp + status
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              timeStr,
                              style: TextStyle(
                                color: isMe
                                    ? Colors.white.withValues(alpha: 0.65)
                                    : const Color(0xFFBDBDBD),
                                fontSize: 10,
                              ),
                            ),
                            if (isMe) ...[
                              const SizedBox(width: 3),
                              Icon(
                                Icons.done_all_rounded,
                                size: 14,
                                color: Colors.white.withValues(alpha: 0.65),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isMe) const SizedBox(width: 4),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Message Input Bar ─────────────────────────────────────────────────────────
class _MessageInputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool hasText;
  final String activeLang;
  final VoidCallback onSend;
  final VoidCallback onMic;
  final VoidCallback onAttach;

  const _MessageInputBar({
    required this.controller,
    required this.hasText,
    required this.activeLang,
    required this.onSend,
    required this.onMic,
    required this.onAttach,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        12,
        8,
        12,
        8 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        border: Border(top: BorderSide(color: AppTheme.outlineLighter, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Attachment / + button
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onAttach,
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFF512DA8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Clean pill input field with NO double border / NO background clipping
            Expanded(
              child: Container(
                height: 44,
                clipBehavior: Clip.antiAlias,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.bgSurface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFF512DA8), width: 1.5),
                ),
                child: TextField(
                  controller: controller,
                  maxLines: 1,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSend(),
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                  ),
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    hintText: activeLang == 'am' ? 'መልዕክት ይጻፉ...' : 'Type a message...',
                    hintStyle: TextStyle(color: AppTheme.textHint, fontSize: 13.5),
                    filled: false,
                    fillColor: Colors.transparent,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Send / Mic button
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: hasText ? onSend : onMic,
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF512DA8),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF512DA8).withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    hasText ? Icons.send_rounded : Icons.mic_rounded,
                    color: Colors.white,
                    size: 20,
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
