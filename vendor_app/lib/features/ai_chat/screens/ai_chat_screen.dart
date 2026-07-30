import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/ai_chat/controllers/ai_chat_controller.dart';
import 'package:sixvalley_vendor_app/localization/controllers/localization_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();
    Provider.of<AiChatController>(context, listen: false).send(text).then((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent + 120, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isLtr = Provider.of<LocalizationController>(context, listen: false).isLtr;
    return Scaffold(
      appBar: AppBar(
        title: Text(isLtr ? 'AI Assistant' : 'المساعد الذكي'),
        actions: [IconButton(onPressed: () => Provider.of<AiChatController>(context, listen: false).startFresh(), icon: const Icon(Icons.add_comment_outlined))],
      ),
      body: Consumer<AiChatController>(
        builder: (context, controller, _) {
          final messages = controller.messages;
          return Column(
            children: [
              Expanded(
                child: messages.isEmpty
                    ? _WelcomeView(isLtr: isLtr, onSuggestion: (text) { _messageController.text = text; _send(); })
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                        itemCount: messages.length + (controller.isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= messages.length) return _Bubble(text: isLtr ? 'Typing...' : 'يكتب الآن...', isUser: false);
                          final message = messages[index];
                          return _Bubble(text: message['content']?.toString() ?? '', isUser: message['role'] == 'user');
                        },
                      ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          minLines: 1,
                          maxLines: 4,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _send(),
                          decoration: InputDecoration(
                            hintText: isLtr ? 'Ask about products, orders, imports...' : 'اسأل عن المنتجات أو الطلبات أو الاستيراد...',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(onPressed: controller.isLoading ? null : _send, icon: const Icon(Icons.send)),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _WelcomeView extends StatelessWidget {
  final bool isLtr;
  final ValueChanged<String> onSuggestion;
  const _WelcomeView({required this.isLtr, required this.onSuggestion});

  @override
  Widget build(BuildContext context) {
    final suggestions = isLtr
        ? ['Why is my product hidden?', 'Review latest imports', 'Improve a product description']
        : ['لماذا لا يظهر منتجي؟', 'راجع آخر المنتجات المستوردة', 'حسن وصف منتج'];
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.auto_awesome, size: 52, color: Theme.of(context).primaryColor),
          const SizedBox(height: 12),
          Text(isLtr ? 'Seller AI assistant' : 'مساعد البائع الذكي', style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: suggestions.map((item) => ActionChip(label: Text(item), onPressed: () => onSuggestion(item))).toList()),
        ]),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final String text;
  final bool isUser;
  const _Bubble({required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * .82),
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isUser ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .06), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Text(text, style: TextStyle(color: isUser ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color)),
      ),
    );
  }
}
