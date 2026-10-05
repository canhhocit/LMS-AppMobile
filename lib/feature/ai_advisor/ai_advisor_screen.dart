import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/storage_keys.dart';
import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/ai_advisor_entity.dart';
import '../../domain/repositories/lms_repository.dart';

class AiAdvisorScreen extends StatefulWidget {
  const AiAdvisorScreen({super.key});

  @override
  State<AiAdvisorScreen> createState() => _AiAdvisorScreenState();
}

class _AiAdvisorScreenState extends State<AiAdvisorScreen> {
  final LmsRepository _repo = getIt<LmsRepository>();
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  List<ChatMessageEntity> _messages = [];
  bool _isSending = false;
  bool _isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final savedHistoryStr = prefs.getString(StorageKeys.aiChatHistory);

    List<ChatMessageEntity> loadedMsgs = [];
    if (savedHistoryStr != null && savedHistoryStr.isNotEmpty) {
      try {
        final List list = jsonDecode(savedHistoryStr);
        loadedMsgs = list.map((item) {
          return ChatMessageEntity(
            id: item['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
            text: item['text'] ?? '',
            isUser: item['isUser'] == true,
            timestamp: item['timestamp'] != null
                ? DateTime.tryParse(item['timestamp']) ?? DateTime.now()
                : DateTime.now(),
          );
        }).toList();
      } catch (_) {
        loadedMsgs = [];
      }
    }

    if (loadedMsgs.isEmpty) {
      loadedMsgs = [
        ChatMessageEntity(
          id: 'welcome-msg',
          text: 'Xin chào! Tôi là Trợ lý Cố vấn Học tập của bạn. Tôi có thể giải đáp các thắc mắc về lịch học, điểm số, môn học và học phí. Bạn cần trợ giúp gì?',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ];
    }

    if (mounted) {
      setState(() {
        _messages = loadedMsgs;
        _isLoadingHistory = false;
      });
      _scrollToBottom();
    }
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final listJson = _messages.map((m) => {
      'id': m.id,
      'text': m.text,
      'isUser': m.isUser,
      'timestamp': m.timestamp.toIso8601String(),
    }).toList();
    await prefs.setString(StorageKeys.aiChatHistory, jsonEncode(listJson));
  }

  Future<void> _clearHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xóa lịch sử trò chuyện'),
        content: const Text('Bạn có chắc chắn muốn xóa lịch sử trò chuyện với Cố vấn không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(StorageKeys.aiChatHistory);
      if (mounted) {
        setState(() {
          _messages = [
            ChatMessageEntity(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              text: 'Đã làm sạch hội thoại. Tôi có thể hỗ trợ thông tin học tập gì cho bạn?',
              isUser: false,
              timestamp: DateTime.now(),
            ),
          ];
        });
      }
    }
  }

  Future<void> _sendMessage([String? prefilledText]) async {
    final text = (prefilledText ?? _inputCtrl.text).trim();
    if (text.isEmpty || _isSending) return;

    final userMsg = ChatMessageEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
      if (prefilledText == null) _inputCtrl.clear();
      _isSending = true;
    });

    _scrollToBottom();
    await _saveHistory();

    try {
      final aiReply = await _repo.sendAiAdvisorMessage(text);
      if (mounted) {
        setState(() {
          _messages.add(aiReply);
          _isSending = false;
        });
        await _saveHistory();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessageEntity(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: 'Không thể kết nối tới dịch vụ Cố vấn học tập lúc này. Vui lòng thử lại sau!',
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isSending = false;
        });
        await _saveHistory();
      }
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cố vấn học tập'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.white),
            tooltip: 'Xóa lịch sử',
            onPressed: _clearHistory,
          ),
        ],
      ),
      body: _isLoadingHistory
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Chat conversation view
                Expanded(
                  child: ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, idx) {
                      final msg = _messages[idx];
                      return Align(
                        alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: msg.isUser ? AppColors.primary : AppColors.surfaceColor(context),
                            borderRadius: BorderRadius.circular(14),
                            border: msg.isUser ? null : Border.all(color: AppColors.borderColor(context)),
                          ),
                          child: Text(
                            msg.text,
                            style: TextStyle(
                              color: msg.isUser ? Colors.white : AppColors.textPrimaryColor(context),
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (_isSending)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: const [
                        SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                        SizedBox(width: 8),
                        Text('Cố vấn đang truy xuất dữ liệu...', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      ],
                    ),
                  ),

                // Concise Utility Suggestions (Max 4 practical queries)
                Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildSuggestionChip('Lịch học hôm nay của tôi?'),
                      _buildSuggestionChip('Điểm GPA hiện tại?'),
                      _buildSuggestionChip('Môn nào tôi đang học?'),
                      _buildSuggestionChip('Học phí còn bao nhiêu?'),
                    ],
                  ),
                ),
                const SizedBox(height: 6),

                // Input Bar
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _inputCtrl,
                          onSubmitted: (_) => _sendMessage(),
                          decoration: InputDecoration(
                            hintText: 'Hỏi Cố vấn học tập...',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: AppColors.primary,
                        radius: 22,
                        child: IconButton(
                          icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                          onPressed: () => _sendMessage(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(text, style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500)),
        backgroundColor: AppColors.primaryBackground,
        side: const BorderSide(color: AppColors.border),
        onPressed: () => _sendMessage(text),
      ),
    );
  }
}
