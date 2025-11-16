import 'package:flutter/material.dart';
import 'dart:async';
import '../models/store.dart';

class ARNavigationPage extends StatefulWidget {
  final Store targetStore;
  
  const ARNavigationPage({
    Key? key,
    required this.targetStore,
  }) : super(key: key);

  @override
  State<ARNavigationPage> createState() => _ARNavigationPageState();
}

class _ARNavigationPageState extends State<ARNavigationPage> {
  bool _showSettings = false;
  bool _digitalHumanEnabled = true;
  bool _isVoiceMode = true;
  bool _showViewfinder = false;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // 显示取景框2秒
  void _showViewfinderTemporarily() {
    setState(() {
      _showViewfinder = true;
    });
    
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showViewfinder = false;
        });
      }
    });
    
    // TODO: 后续在Unity中调用摄像头拍照
    print('拍照功能 - 将照片发送给Unity进行分析');
  }

  // 切换输入模式
  void _toggleInputMode() {
    setState(() {
      _isVoiceMode = !_isVoiceMode;
      if (!_isVoiceMode) {
        // 切换到文字模式时，显示键盘
        Future.delayed(const Duration(milliseconds: 100), () {
          _focusNode.requestFocus();
        });
      } else {
        // 切换到语音模式时，隐藏键盘
        _focusNode.unfocus();
      }
    });
  }

  // 发送文字消息
  void _sendTextMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    
    // TODO: 将文字信息发送给Unity
    print('发送文字给Unity: $text');
    
    // 清空输入框
    _textController.clear();
  }

  // 语音输入
  void _handleVoiceInput() {
    // TODO: 后续在Unity中调用麦克风
    print('语音输入 - 将语音传递给Unity');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF87CEEB),
              Color(0xFF2E86AB),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // AR界面占位区域（中间部分）
              Center(
                child: Container(
                  // Unity的AR界面将在这里渲染
                  child: _buildARPlaceholder(),
                ),
              ),
              
              // 取景框（点击获取位置后显示）
              if (_showViewfinder)
                _buildViewfinder(),
              
              // 左上角返回键
              _buildBackButton(),
              
              // 右上角设置按钮
              _buildSettingsButton(),
              
              // 设置弹窗
              if (_showSettings)
                _buildSettingsDialog(),
              
              // 获取位置按钮
              _buildLocationButton(),
              
              // 底部对话栏
              _buildChatBar(),
            ],
          ),
        ),
      ),
    );
  }

  // AR界面占位
  Widget _buildARPlaceholder() {
    return Container(
      alignment: Alignment.center,
      child: Text(
        'Unity AR界面将在此处渲染',
        style: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontSize: 16,
        ),
      ),
    );
  }

  // 取景框
  Widget _buildViewfinder() {
    return Align(
      alignment: Alignment(0, -0.25),  
      child: SizedBox(
        width: 200,
        height: 200,
        child: CustomPaint(
          painter: ViewfinderPainter(),
        ),
      ),
    );
  }

  // 左上角返回键
  Widget _buildBackButton() {
    return Positioned(
      left: 16,
      top: 16,
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_back,
            color: Colors.black87,
            size: 24,
          ),
        ),
      ),
    );
  }

  // 右上角设置按钮
  Widget _buildSettingsButton() {
    return Positioned(
      right: 16,
      top: 16,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _showSettings = !_showSettings;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.settings,
            color: Colors.black87,
            size: 24,
          ),
        ),
      ),
    );
  }

  // 设置弹窗
  Widget _buildSettingsDialog() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showSettings = false;
        });
      },
      child: Container(
        color: Colors.transparent,
        child: Stack(
          children: [
            Positioned(
              right: 60, 
              top: 20,
              child: GestureDetector(
                onTap: () {}, // 阻止点击弹窗内部时关闭
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,  
                  children: [
                    // 弹窗主体
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            '开启数字人',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 0),
                          Transform.scale(
                            scale: 0.75,
                            child: Switch(
                              value: _digitalHumanEnabled,
                              activeColor: Colors.green,
                              onChanged: (value) {
                                setState(() {
                                  _digitalHumanEnabled = value;
                                });
                                // TODO: 将设置传递给Unity
                                print('数字人开关状态: $value');
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 小三角指示器
                    Padding(
                      padding: const EdgeInsets.only(top: 10), 
                      child: CustomPaint(
                        painter: TrianglePainter(),
                        size: const Size(6, 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 获取位置按钮
  Widget _buildLocationButton() {
    return Positioned(
      bottom: 210,
      left: 0,
      right: 0,
      child: Center(
        child: GestureDetector(
          onTap: _showViewfinderTemporarily,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  '获取位置',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.refresh,
                  color: Colors.white,
                  size: 15,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 底部对话栏
  Widget _buildChatBar() {
    return Positioned(
      bottom: 5,
      left: 5,
      right: 5,
      child: Container(
        padding: EdgeInsets.only(
          left: 12,
          right: 12,
          bottom: 12,
          top: 12,
        ),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.7),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 左侧切换按钮（键盘/语音）
            GestureDetector(
              onTap: _toggleInputMode,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _isVoiceMode ? Icons.keyboard : Icons.mic,
                  color: Colors.black87,
                  size: 24,
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // 中间输入框
            Expanded(
              child: _isVoiceMode
                  ? _buildVoiceInputButton()
                  : _buildTextInputField(),
            ),
            
            const SizedBox(width: 12),
            
            // 右侧发送按钮（仅文字模式显示）
            if (!_isVoiceMode)
              GestureDetector(
                onTap: _sendTextMessage,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '发送',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 语音输入按钮
  Widget _buildVoiceInputButton() {
    return GestureDetector(
      onTapDown: (_) => _handleVoiceInput(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: const Center(
          child: Text(
            '按住 说话',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  // 文字输入框
  Widget _buildTextInputField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: _textController,
        focusNode: _focusNode,
        style: const TextStyle(fontSize: 14),
        decoration: const InputDecoration(
          hintText: '想聊点什么？',
          hintStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
        onSubmitted: (_) => _sendTextMessage(),
      ),
    );
  }
}

// 取景框绘制器
class ViewfinderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    const cornerLength = 30.0;

    // 左上角
    canvas.drawLine(
      const Offset(0, 0),
      const Offset(cornerLength, 0),
      paint,
    );
    canvas.drawLine(
      const Offset(0, 0),
      const Offset(0, cornerLength),
      paint,
    );

    // 右上角
    canvas.drawLine(
      Offset(size.width - cornerLength, 0),
      Offset(size.width, 0),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width, cornerLength),
      paint,
    );

    // 左下角
    canvas.drawLine(
      Offset(0, size.height - cornerLength),
      Offset(0, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height),
      Offset(cornerLength, size.height),
      paint,
    );

    // 右下角
    canvas.drawLine(
      Offset(size.width, size.height - cornerLength),
      Offset(size.width, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - cornerLength, size.height),
      Offset(size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 小三角指示器绘制器
class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    // 绘制指向右边的小三角
    path.moveTo(0, size.height / 2 - 6); // 顶点
    path.lineTo(size.width, size.height / 2); // 右边尖端
    path.lineTo(0, size.height / 2 + 6); // 底部顶点
    path.close();

    canvas.drawPath(path, paint);

    // 添加阴影效果
    canvas.drawShadow(
      path,
      Colors.black.withOpacity(0.2),
      2.0,
      false,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}