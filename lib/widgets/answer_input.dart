import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 答え入力ウィジェット
class AnswerInput extends StatefulWidget {
  const AnswerInput({
    super.key,
    required this.onAnswerSubmitted,
    this.onAnswerChanged,
  });

  final Function(int) onAnswerSubmitted;
  final Function(int?)? onAnswerChanged;

  @override
  State<AnswerInput> createState() => _AnswerInputState();
}

class _AnswerInputState extends State<AnswerInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // 自動的にフォーカスを当てる
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      constraints: const BoxConstraints(maxWidth: 200),
      child: Column(
        children: [
          // 入力フィールド
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.outline,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3), // 最大3桁
              ],
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineLarge?.copyWith(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: '?',
                hintStyle: theme.textTheme.headlineLarge?.copyWith(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
              ),
              onChanged: (value) {
                final intValue = int.tryParse(value);
                widget.onAnswerChanged?.call(intValue);
              },
              onSubmitted: (value) {
                _submitAnswer();
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 送信ボタン
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitAnswer,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check),
                  const SizedBox(width: 8),
                  Text(
                    'こたえる',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // ヒントテキスト
          Text(
            '数字を入力して「こたえる」を押してください',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _submitAnswer() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      _showError('答えを入力してください');
      return;
    }

    final answer = int.tryParse(text);
    if (answer == null) {
      _showError('正しい数字を入力してください');
      return;
    }

    if (answer < 0) {
      _showError('正の数を入力してください');
      return;
    }

    widget.onAnswerSubmitted(answer);
    _controller.clear();
    _focusNode.requestFocus(); // 次の問題のためにフォーカスを保持
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}