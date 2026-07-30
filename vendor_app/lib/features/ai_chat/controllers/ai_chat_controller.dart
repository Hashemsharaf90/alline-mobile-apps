import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/features/ai_chat/domain/ai_chat_repository.dart';

class AiChatController extends ChangeNotifier {
  final AiChatRepository aiChatRepository;
  AiChatController({required this.aiChatRepository});

  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  int? _sessionId;

  List<Map<String, dynamic>> get messages => _messages;
  bool get isLoading => _isLoading;

  void startFresh() {
    _messages.clear();
    _sessionId = null;
    notifyListeners();
  }

  Future<void> send(String text) async {
    final message = text.trim();
    if (message.isEmpty || _isLoading) return;

    _messages.add({'role': 'user', 'content': message});
    _isLoading = true;
    notifyListeners();

    try {
      final data = await aiChatRepository.sendMessage(
          message: message, sessionId: _sessionId);
      final session = data['session'];
      if (session is Map && session['id'] != null) {
        _sessionId = int.tryParse(session['id'].toString());
      }
      final assistant = data['assistant_message'];
      if (assistant is Map) {
        _messages.add(Map<String, dynamic>.from(assistant));
      } else {
        _messages.add(
            {'role': 'assistant', 'content': data['answer']?.toString() ?? ''});
      }
    } catch (_) {
      _messages.add({
        'role': 'assistant',
        'status': 'local_fallback',
        'content':
            'تعذر الاتصال بالمساعد حاليا. تأكد من تسجيل الدخول والاتصال بالإنترنت ثم حاول مرة أخرى.',
      });
    }

    _isLoading = false;
    notifyListeners();
  }
}
