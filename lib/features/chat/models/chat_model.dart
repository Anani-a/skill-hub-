enum MessageType { text, image, voice, system }

enum SenderRole { customer, provider }

class MessageModel {
  final String id;
  final String senderName;
  final SenderRole senderRole;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final int? voiceDurationSeconds;
  final bool isRead;

  MessageModel({
    required this.id,
    required this.senderName,
    required this.senderRole,
    required this.content,
    required this.type,
    required this.timestamp,
    this.voiceDurationSeconds,
    required this.isRead,
  });

  // Mock Conversations
  static List<MessageModel> get mockMessages => [
    MessageModel(
      id: 'm1',
      senderName: 'Abel Abreham',
      senderRole: SenderRole.customer,
      content: 'Hello Bekele, are you available to look at our kitchen circuit breaker today?',
      type: MessageType.text,
      timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
      isRead: true,
    ),
    MessageModel(
      id: 'm2',
      senderName: 'Bekele Tadesse',
      senderRole: SenderRole.provider,
      content: 'Hello Abel! Yes, I am free after 2:00 PM. I can come and inspect it.',
      type: MessageType.text,
      timestamp: DateTime.now().subtract(const Duration(minutes: 40)),
      isRead: true,
    ),
    MessageModel(
      id: 'm3',
      senderName: 'Abel Abreham',
      senderRole: SenderRole.customer,
      content: 'Here is the sound the breaker makes when I turn it on. It clicks instantly.',
      type: MessageType.text,
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      isRead: true,
    ),
    MessageModel(
      id: 'm4',
      senderName: 'Abel Abreham',
      senderRole: SenderRole.customer,
      content: 'mock_kitchen_breaker_click.ogg',
      type: MessageType.voice,
      voiceDurationSeconds: 6,
      timestamp: DateTime.now().subtract(const Duration(minutes: 29)),
      isRead: true,
    ),
    MessageModel(
      id: 'm5',
      senderName: 'Bekele Tadesse',
      senderRole: SenderRole.provider,
      content: 'Understood. It sounds like a short circuit or a faulty breaker. I will bring a replacement breaker with me.',
      type: MessageType.text,
      timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
      isRead: false,
    ),
  ];
}
