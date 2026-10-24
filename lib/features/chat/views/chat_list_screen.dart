import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/mock_state_providers.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Mock conversation data
// ─────────────────────────────────────────────────────────────────────────────

class _ConversationItem {
  final String providerId;
  final String name;
  final String initials;
  final Color avatarColor;
  final bool isOnline;
  final bool isVerified;
  final String lastMessage;
  final String timeLabel;
  final int unreadCount;
  final bool isSentByMe;

  const _ConversationItem({
    required this.providerId,
    required this.name,
    required this.initials,
    required this.avatarColor,
    required this.isOnline,
    required this.isVerified,
    required this.lastMessage,
    required this.timeLabel,
    required this.unreadCount,
    this.isSentByMe = false,
  });
}

const _mockConversations = [
  _ConversationItem(
    providerId: 'p1',
    name: 'Bekele Tadesse',
    initials: 'BT',
    avatarColor: Color(0xFF512DA8),
    isOnline: true,
    isVerified: true,
    lastMessage: "Ok Abel, I am on my way now! I'll call you when I reach your gate.",
    timeLabel: '10:42 AM',
    unreadCount: 2,
    isSentByMe: false,
  ),
  _ConversationItem(
    providerId: 'p2',
    name: 'Hana Mekonnen',
    initials: 'HM',
    avatarColor: Color(0xFF26A69A),
    isOnline: true,
    isVerified: true,
    lastMessage: 'I sent the revised cleaning schedule and product list.',
    timeLabel: 'Yesterday',
    unreadCount: 0,
    isSentByMe: false,
  ),
  _ConversationItem(
    providerId: 'p3',
    name: 'Yonas Alemu',
    initials: 'YA',
    avatarColor: Color(0xFFE65100),
    isOnline: false,
    isVerified: false,
    lastMessage: 'Thanks for the update. I will get back to you after checking.',
    timeLabel: 'Mon',
    unreadCount: 1,
    isSentByMe: false,
  ),
  _ConversationItem(
    providerId: 'p4',
    name: 'Tewodros Girma',
    initials: 'TG',
    avatarColor: Color(0xFF1565C0),
    isOnline: true,
    isVerified: true,
    lastMessage: 'The custom math problem set is almost finished — sending tomorrow.',
    timeLabel: 'Aug 12',
    unreadCount: 0,
    isSentByMe: true,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Chat List Screen
// ─────────────────────────────────────────────────────────────────────────────

class ChatListScreen extends ConsumerStatefulWidget {
  final bool isShell;
  const ChatListScreen({super.key, this.isShell = false});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  int _filterIndex = 0;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_ConversationItem> get _filteredConversations {
    var list = _mockConversations.toList();
    if (_filterIndex == 1) {
      list = list.where((c) => c.unreadCount > 0).toList();
    }
    if (_searchQuery.isNotEmpty) {
      list = list
          .where((c) =>
              c.name.toLowerCase().contains(_searchQuery) ||
              c.lastMessage.toLowerCase().contains(_searchQuery))
          .toList();
    }
    return list;
  }

  int get _totalUnread =>
      _mockConversations.fold(0, (sum, c) => sum + c.unreadCount);

  @override
  Widget build(BuildContext context) {
    final activeLang = ref.watch(languageProvider);
    final activeRole = ref.watch(currentRoleProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    AppTheme.isDark = isDark;

    return Scaffold(
      backgroundColor: AppTheme.bgBase,
      body: Column(
        children: [
          // ── Purple Header ─────────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? const [Color(0xFF1E1435), Color(0xFF2E1C4D)]
                    : const [Color(0xFF4527A0), Color(0xFF7E57C2)],
              ),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Title row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Row(
                      children: [
                        Text(
                          activeLang == 'am' ? 'መልዕክቶች' : 'Messages',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const Spacer(),
                        // Unread badge
                        if (_totalUnread > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$_totalUnread ${activeLang == 'am' ? 'ያልተነበቡ' : 'unread'}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        const SizedBox(width: 10),
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                  ),

                  // Search bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppTheme.bgSurface,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 14),
                          Icon(Icons.search_rounded, color: AppTheme.primaryLight, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: TextStyle(fontSize: 14, color: AppTheme.textPrimary),
                              decoration: InputDecoration(
                                hintText: activeLang == 'am'
                                    ? 'ፈልግ...'
                                    : 'Search conversations...',
                                hintStyle: TextStyle(color: AppTheme.textSecondary.withValues(alpha: 0.7), fontSize: 13),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            GestureDetector(
                              onTap: () => _searchController.clear(),
                              child: const Padding(
                                padding: EdgeInsets.only(right: 12),
                                child: Icon(Icons.close_rounded, size: 18, color: Color(0xFF9575CD)),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Filter chips
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                    child: Row(
                      children: [
                        _FilterChip(
                          label: activeLang == 'am' ? 'ሁሉም' : 'All Chats',
                          isSelected: _filterIndex == 0,
                          onTap: () => setState(() => _filterIndex = 0),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: activeLang == 'am' ? 'ያልተነበቡ' : 'Unread',
                          isSelected: _filterIndex == 1,
                          badge: _totalUnread > 0 ? '$_totalUnread' : null,
                          onTap: () => setState(() => _filterIndex = 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Conversation List ──────────────────────────────────────────────
          Expanded(
            child: _filteredConversations.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.chat_bubble_outline_rounded, size: 64, color: Color(0xFFD1C4E9)),
                        const SizedBox(height: 16),
                        Text(
                          activeLang == 'am' ? 'ምንም ውይይት አልተገኘም' : 'No conversations found',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF9575CD),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          activeLang == 'am' ? 'አዲስ አቅራቢ ፈልጎ ይናገሩ' : 'Book a service to start chatting',
                          style: TextStyle(fontSize: 13, color: AppTheme.textTertiary),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _filteredConversations.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      indent: 88,
                      color: AppTheme.outlineLighter,
                    ),
                    itemBuilder: (context, index) {
                      final conv = _filteredConversations[index];
                      return _ConversationTile(
                        conversation: conv,
                        onTap: () => context.go('/chat'),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: widget.isShell
          ? null
          : ShukBottomNavBar(
              currentIndex: 3,
              activeRole: activeRole,
              activeLang: ref.watch(languageProvider),
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter Chip
// ─────────────────────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final String? badge;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.3),
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
                color: isSelected ? const Color(0xFF512DA8) : Colors.white,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF512DA8) : Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge!,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Conversation Tile
// ─────────────────────────────────────────────────────────────────────────────

class _ConversationTile extends StatelessWidget {
  final _ConversationItem conversation;
  final VoidCallback onTap;

  const _ConversationTile({required this.conversation, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final conv = conversation;
    final hasUnread = conv.unreadCount > 0;

    return InkWell(
      onTap: onTap,
      splashColor: AppTheme.primary.withValues(alpha: 0.05),
      highlightColor: AppTheme.primary.withValues(alpha: 0.03),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: conv.avatarColor,
                    shape: BoxShape.circle,
                    border: hasUnread
                        ? Border.all(color: AppTheme.primary, width: 2.5)
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: conv.avatarColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      conv.initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Online indicator
                Positioned(
                  bottom: 1,
                  right: 1,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: conv.isOnline ? const Color(0xFF4CAF50) : const Color(0xFFBDBDBD),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.bgSurface, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),

            // Name + last message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        conv.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      if (conv.isVerified) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.verified_rounded, size: 14, color: AppTheme.primary),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (conv.isSentByMe)
                        const Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Icon(Icons.done_all_rounded, size: 14, color: Color(0xFF512DA8)),
                        ),
                      Expanded(
                        child: Text(
                          conv.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: hasUnread ? const Color(0xFF512DA8) : const Color(0xFF9E9E9E),
                            fontWeight: hasUnread ? FontWeight.w500 : FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Time + unread badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  conv.timeLabel,
                  style: TextStyle(
                    fontSize: 11,
                    color: hasUnread ? const Color(0xFF512DA8) : const Color(0xFFBDBDBD),
                    fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 6),
                if (conv.unreadCount > 0)
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Color(0xFF512DA8),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${conv.unreadCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 22, height: 22),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
