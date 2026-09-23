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

  String _aiName = 'Hikari AI';
  List<ChatMessageEntity> _messages = [];
  bool _isSending = false;
  bool _isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    _loadAiConfigAndHistory();
  }

  Future<void> _loadAiConfigAndHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(StorageKeys.aiName) ?? 'Hikari AI';
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
          text: 'Xin chào! Tôi là $name – Trợ lý AI Học tập cá nhân của bạn. Tôi đã được cấu hình theo đúng phong cách và mục tiêu của bạn. Bạn cần tư vấn điều gì hôm nay?',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ];
    }

    if (mounted) {
      setState(() {
        _aiName = name;
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
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Xóa lịch sử chat'),
          content: Text('Bạn có chắc chắn muốn xóa toàn bộ lịch sử trò chuyện với $_aiName không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove(StorageKeys.aiChatHistory);
                if (mounted) {
                  Navigator.pop(dialogCtx);
                  setState(() {
                    _messages = [
                      ChatMessageEntity(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        text: 'Đã làm sạch lịch sử trò chuyện! Xin chào, $_aiName có thể trợ giúp gì cho bạn hôm nay?',
                        isUser: false,
                        timestamp: DateTime.now(),
                      ),
                    ];
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã xóa toàn bộ lịch sử chat thành công!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              child: const Text('Xóa', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendMessage() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty || _isSending) return;

    final userMsg = ChatMessageEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
      _inputCtrl.clear();
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
            text: 'Xin lỗi, không thể kết nối tới dịch vụ AI Trợ lý lúc này. Vui lòng thử lại sau!',
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
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.smart_toy_outlined, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_aiName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  const Text('Live Personalized Assistant', style: TextStyle(fontSize: 10, color: Colors.white70)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            tooltip: 'Xóa lịch sử chat',
            onPressed: _clearHistory,
          ),
        ],
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoadingHistory
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
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
                            color: msg.isUser ? AppColors.primary : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: msg.isUser ? null : Border.all(color: Colors.grey.shade300),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            msg.text,
                            style: TextStyle(
                              color: msg.isUser ? Colors.white : Colors.black87,
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
                      children: [
                        const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                        const SizedBox(width: 8),
                        Text('$_aiName đang suy nghĩ...', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                // Quick suggestion chips
                Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildPromptChip('Lộ trình cải thiện GPA?'),
                      _buildPromptChip('Kinh nghiệm học môn khó?'),
                      _buildPromptChip('Kiểm tra nguy cơ học tập?'),
                      _buildPromptChip('Bí quyết quản lý thời gian?'),
                    ],
                  ),
                ),
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
                            hintText: 'Nhập thắc mắc hoặc câu hỏi cho $_aiName...',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white, size: 20),
                          onPressed: _sendMessage,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildPromptChip(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(text, style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.primary.withOpacity(0.08),
        side: BorderSide(color: AppColors.primary.withOpacity(0.2)),
        onPressed: () {
          _inputCtrl.text = text;
          _sendMessage();
        },
      ),
    );
  }
}

