import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_model.dart';

class ChatNotifier extends StateNotifier<AsyncValue<List<MessageModel>>> {
  ChatNotifier() : super(const AsyncValue.data([])) {
    _initializeMockMessages();
  }

  void _initializeMockMessages() {
    final messages = MessageModel.mockMessages;
    state = AsyncValue.data(messages);
  }

  /// Send a new message
  Future<void> sendMessage({
    required String senderName,
    required SenderRole senderRole,
    required String content,
    required MessageType type,
    int? voiceDurationSeconds,
  }) async {
    state = const AsyncValue.loading();
    // Simulate network delay for sending
    await Future.delayed(const Duration(milliseconds: 500));

    final newMessage = MessageModel(
      id: 'm_${DateTime.now().millisecondsSinceEpoch}',
      senderName: senderName,
      senderRole: senderRole,
      content: content,
      type: type,
      timestamp: DateTime.now(),
      voiceDurationSeconds: voiceDurationSeconds,
      isRead: true,
    );

    final currentMessages = state.maybeWhen(
      data: (List<MessageModel> messages) => messages,
      orElse: () => <MessageModel>[],
    );

    state = AsyncValue.data([...currentMessages, newMessage]);
  }

  /// Mark message as read
  Future<void> markMessageAsRead(String messageId) async {
    final currentMessages = state.maybeWhen(
      data: (List<MessageModel> messages) => messages,
      orElse: () => <MessageModel>[],
    );

    final updatedMessages = currentMessages.map((msg) {
      if (msg.id == messageId && !msg.isRead) {
        return MessageModel(
          id: msg.id,
          senderName: msg.senderName,
          senderRole: msg.senderRole,
          content: msg.content,
          type: msg.type,
          timestamp: msg.timestamp,
          voiceDurationSeconds: msg.voiceDurationSeconds,
          isRead: true,
        );
      }
      return msg;
    }).toList();

    state = AsyncValue.data(updatedMessages);
  }

  /// Mark all messages as read
  Future<void> markAllAsRead() async {
    final currentMessages = state.maybeWhen(
      data: (List<MessageModel> messages) => messages,
      orElse: () => <MessageModel>[],
    );

    final updatedMessages = currentMessages.map((msg) {
      return MessageModel(
        id: msg.id,
        senderName: msg.senderName,
        senderRole: msg.senderRole,
        content: msg.content,
        type: msg.type,
        timestamp: msg.timestamp,
        voiceDurationSeconds: msg.voiceDurationSeconds,
        isRead: true,
      );
    }).toList();

    state = AsyncValue.data(updatedMessages);
  }

  /// Get unread message count
  int getUnreadCount() {
    return state.maybeWhen(
      data: (List<MessageModel> messages) => messages.where((msg) => !msg.isRead).length,
      orElse: () => 0,
    );
  }

  /// Get messages from a specific sender
  List<MessageModel> getMessagesBySender(String senderName) {
    return state.maybeWhen(
      data: (List<MessageModel> messages) =>
          messages.where((msg) => msg.senderName == senderName).toList(),
      orElse: () => <MessageModel>[],
    );
  }

  /// Get recent messages (last n messages)
  List<MessageModel> getRecentMessages({int limit = 50}) {
    return state.maybeWhen(
      data: (List<MessageModel> messages) {
        final sorted = List<MessageModel>.from(messages)
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return sorted.take(limit).toList();
      },
      orElse: () => <MessageModel>[],
    );
  }
}

// Global chat provider
final chatProvider =
    StateNotifierProvider<ChatNotifier, AsyncValue<List<MessageModel>>>((ref) {
  return ChatNotifier();
});

// Derived provider for unread message count
final unreadCountProvider = Provider<int>((ref) {
  final chat = ref.watch(chatProvider);
  return chat.maybeWhen(
    data: (List<MessageModel> messages) => messages.where((msg) => !msg.isRead).length,
    orElse: () => 0,
  );
});

// Derived provider for recent messages
final recentMessagesProvider = Provider<List<MessageModel>>((ref) {
  final chat = ref.watch(chatProvider);
  return chat.maybeWhen(
    data: (List<MessageModel> messages) {
      final sorted = List<MessageModel>.from(messages)
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return sorted.take(50).toList();
    },
    orElse: () => <MessageModel>[],
  );
});

// Derived provider for messages from customer
final customerMessagesProvider = Provider<List<MessageModel>>((ref) {
  final chat = ref.watch(chatProvider);
  return chat.maybeWhen(
    data: (List<MessageModel> messages) =>
        messages.where((msg) => msg.senderRole == SenderRole.customer).toList(),
    orElse: () => <MessageModel>[],
  );
});

// Derived provider for messages from provider
final providerMessagesProvider = Provider<List<MessageModel>>((ref) {
  final chat = ref.watch(chatProvider);
  return chat.maybeWhen(
    data: (List<MessageModel> messages) =>
        messages.where((msg) => msg.senderRole == SenderRole.provider).toList(),
    orElse: () => <MessageModel>[],
  );
});
