import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:care_talk/core/constants/app_colors.dart';
import 'package:care_talk/core/constants/app_dimens.dart';
import 'package:care_talk/core/router/app_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class PatientChatScreen extends StatefulWidget {
  const PatientChatScreen({super.key});

  @override
  State<PatientChatScreen> createState() => _PatientChatScreenState();
}

class _PatientChatScreenState extends State<PatientChatScreen> {
  late TextEditingController _msgController;
  late List<Map<String, dynamic>> _messages;
  late List<Map<String, dynamic>> _historySessions;
  bool _isBotTyping = false;
  int _activeSessionIndex = -1;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _msgController = TextEditingController();
    _messages = _getInitialMessage();
    _historySessions = [
      {
        'title': 'Đau nửa đầu và chóng mặt',
        'time': '15 phút trước',
        'messages': [
          {'isBot': true, 'text': 'Chào bạn, tôi là CareTalk. Tôi có thể giúp gì cho bạn hôm nay?', 'type': 'text'},
          {'isBot': false, 'text': 'Tôi bị đau nửa đầu và chóng mặt', 'type': 'text'},
          {'isBot': true, 'text': 'Tôi đã ghi nhận. Bạn bị lâu chưa?', 'type': 'text'},
        ]
      },
      {
        'title': 'Sốt nhẹ và ho khan',
        'time': 'Hôm qua',
        'messages': [
          {'isBot': true, 'text': 'Chào bạn, tôi là CareTalk...', 'type': 'text'},
          {'isBot': false, 'text': 'Tôi bị sốt nhẹ', 'type': 'text'},
        ]
      },
    ];
  }

  List<Map<String, dynamic>> _getInitialMessage() {
    return [
      {
        'isBot': true,
        'text': 'Chào bạn, tôi là CareTalk.\nTôi có thể giúp gì cho bạn hôm nay?',
        'type': 'text',
      }
    ];
  }

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'isBot': false, 'text': text, 'type': 'text'});
      _msgController.clear();
      
      // Tạo bản ghi lịch sử ngay khi hỏi câu đầu tiên
      if (_activeSessionIndex == -1) {
        final title = text.length > 25 ? '${text.substring(0, 25)}...' : text;
        _historySessions.insert(0, {
          'title': title,
          'time': 'Vừa xong',
          'messages': List<Map<String, dynamic>>.from(_messages),
        });
        _activeSessionIndex = 0;
      } else {
        // Cập nhật tin nhắn vào session hiện tại
        _historySessions[_activeSessionIndex]['messages'] = List<Map<String, dynamic>>.from(_messages);
      }
      
      _isBotTyping = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _isBotTyping = false;
        _messages.add({
          'isBot': true,
          'text': 'Tôi đã ghi nhận triệu chứng của bạn. Dựa trên phân tích AI, tôi có một bản đánh giá sức khỏe sơ bộ cho bạn.',
          'type': 'text',
        });

        String severity = 'low';
        if (text.toLowerCase().contains('đau ngực') || text.toLowerCase().contains('khó thở')) {
          severity = 'emergency';
        } else if (text.toLowerCase().contains('đau') || text.toLowerCase().contains('sốt')) {
          severity = 'moderate';
        }

        _messages.add({
          'isBot': true,
          'type': 'assessment',
          'severity': severity,
        });

        // Cập nhật lại lịch sử sau khi bot trả lời
        if (_activeSessionIndex != -1) {
          _historySessions[_activeSessionIndex]['messages'] = List<Map<String, dynamic>>.from(_messages);
        }
      });
    });
  }

  void _startNewChat() {
    setState(() {
      _messages = _getInitialMessage();
      _activeSessionIndex = -1;
    });
    Navigator.pop(context);
  }

  void _loadSession(int index) {
    setState(() {
      _activeSessionIndex = index;
      _messages = List<Map<String, dynamic>>.from(_historySessions[index]['messages']);
    });
    Navigator.pop(context);
  }

  Future<void> _pickImage() async {
    // Yêu cầu quyền truy cập thư viện ảnh
    var status = await Permission.photos.request();
    
    if (status.isDenied) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng cấp quyền truy cập ảnh để sử dụng tính năng này')),
      );
      return;
    }

    if (status.isPermanentlyDenied) {
      openAppSettings();
      return;
    }

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _messages.add({
          'isBot': false,
          'type': 'image',
          'imagePath': image.path,
        });
        
        // Cập nhật lịch sử
        if (_activeSessionIndex == -1) {
          _historySessions.insert(0, {
            'title': 'Gửi một hình ảnh',
            'time': 'Vừa xong',
            'messages': List<Map<String, dynamic>>.from(_messages),
          });
          _activeSessionIndex = 0;
        } else {
          _historySessions[_activeSessionIndex]['messages'] = List<Map<String, dynamic>>.from(_messages);
        }
        
        _isBotTyping = true;
      });

      // Giả lập bot phản hồi sau khi nhận ảnh
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() {
          _isBotTyping = false;
          _messages.add({
            'isBot': true,
            'text': 'Tôi đã nhận được hình ảnh của bạn. Trông có vẻ như một tình trạng da liễu thông thường, nhưng tôi cần thêm một vài thông tin...',
            'type': 'text',
          });
          _historySessions[_activeSessionIndex]['messages'] = List<Map<String, dynamic>>.from(_messages);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: AppColors.primary),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'CareTalk',
          style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 22),
        ),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(
                  'https://ui-avatars.com/api/?name=User&background=random'),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: AppColors.primary),
              child: Center(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.medical_services_rounded,
                          color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Lịch sử tư vấn',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _historySessions.length,
                itemBuilder: (context, index) {
                  final session = _historySessions[index];
                  return _buildHistoryItem(
                    index,
                    session['title'] ?? '',
                    session['time'] ?? '',
                    Icons.history_rounded,
                    isActive: _activeSessionIndex == index,
                  );
                },
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.add_circle_outline, color: AppColors.primary),
              title: const Text('Cuộc hội thoại mới', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: _startNewChat,
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Cài đặt'),
              onTap: () {},
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppDimens.lg),
              itemCount: _messages.length + (_isBotTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return _buildTypingIndicator();
                }
                final msg = _messages[index];
                
                // Nếu là tin nhắn đầu tiên của bot và chưa có hội thoại, hiện UI chào mừng
                if (index == 0 && _messages.length == 1 && msg['isBot'] == true) {
                  return _buildWelcomeScene();
                }
                
                if (msg['type'] == 'assessment') {
                  return _buildAssessmentCard(msg['severity'] ?? 'low');
                }
                return _buildChatBubble(msg);
              },
            ),
          ),
          


          _buildInputSection(),
        ],
      ),
    );
  }

  Widget _buildChatBubble(Map<String, dynamic> msg) {
    final isBot = msg['isBot'] as bool? ?? true;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isBot) ...[
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isBot ? Colors.white : AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isBot ? 4 : 16),
                  bottomRight: Radius.circular(isBot ? 16 : 4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: msg['type'] == 'image'
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(msg['imagePath']),
                      width: 200,
                      fit: BoxFit.cover,
                    ),
                  )
                : Text(
                    msg['text'] ?? '',
                    style: TextStyle(
                      color: isBot ? Colors.black87 : Colors.white,
                      fontSize: 14,
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentCard(String severity) {
    Color cardColor;
    String title;
    IconData icon;

    switch (severity) {
      case 'emergency':
        cardColor = const Color(0xFFB71C1C);
        title = 'CẢNH BÁO KHẨN CẤP';
        icon = Icons.warning_rounded;
        break;
      case 'moderate':
        cardColor = const Color(0xFF1976D2);
        title = 'PHÂN TÍCH TRIỆU CHỨNG';
        icon = Icons.info_rounded;
        break;
      default:
        cardColor = const Color(0xFF43A047);
        title = 'NGUY CƠ THẤP';
        icon = Icons.check_circle_rounded;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: cardColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: cardColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: cardColor,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Hệ thống AI đã phân tích các triệu chứng của bạn và đưa ra đánh giá chi tiết.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.push('${AppRouter.symptomAssessmentPath}?severity=$severity');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: cardColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Xem đánh giá sức khỏe'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(Icons.smart_toy_rounded, color: AppColors.primary, size: 20),
          SizedBox(width: 8),
          Text('CareTalk đang phân tích...',
              style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _buildChip(String label) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        _msgController.text = label;
        _sendMessage();
      },
      backgroundColor: Colors.white,
      labelStyle: const TextStyle(color: AppColors.primary, fontSize: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.image_outlined, color: AppColors.primary, size: 28),
            onPressed: _pickImage,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFE9EBF1), // Màu xám nhạt như ảnh
                borderRadius: BorderRadius.circular(28),
              ),
              child: TextField(
                controller: _msgController,
                maxLines: null,
                minLines: 1,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  hintText: 'Nhập tin nhắn ..',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                  filled: false,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeScene() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        // Bot Icon
        Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            color: Color(0xFF1E56C1),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 32),
        ),
        const SizedBox(height: 20),
        
        // Greeting Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chào bạn, tôi là\nCareTalk.',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1A1A1A),
                  height: 1.2,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Tôi có thể giúp gì cho bạn hôm nay?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        
        // Suggestion Chips
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildActionChip('Tôi bị đau đầu'),
            _buildActionChip('Tôi bị sốt'),
            _buildActionChip('Tôi bị đau bụng'),
          ],
        ),
        const SizedBox(height: 40),
        
        // Tip Card
        _buildTipCard(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildActionChip(String label) {
    return InkWell(
      onTap: () {
        _msgController.text = label;
        _sendMessage();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF2E66E7),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildTipCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7), // Màu nền xám nhạt của Card Mẹo nhỏ
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lightbulb_outline_rounded, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mẹo nhỏ',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E56C1),
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Bạn có thể chụp ảnh vùng da bị tổn thương hoặc đơn thuốc cũ để tôi có thêm dữ liệu hỗ trợ bạn tốt hơn.',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(int index, String title, String time, IconData icon, {bool isActive = false}) {
    return ListTile(
      leading: Icon(icon, color: isActive ? AppColors.primary : Colors.grey, size: 20),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          color: isActive ? AppColors.primary : Colors.black87,
        ),
      ),
      subtitle: Text(time, style: const TextStyle(fontSize: 12)),
      onTap: () => _loadSession(index),
      selected: isActive,
      selectedTileColor: AppColors.primary.withOpacity(0.05),
    );
  }
}
