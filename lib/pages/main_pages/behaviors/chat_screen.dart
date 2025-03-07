import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<MessageBubble> _messages = [];
  final String _apiUrl = "http://127.0.0.1:5000/api/chat";
  bool _isBotThinking = false;
  bool _isOpenAIMode = false;

  void _sendMessage([String? quickReply]) async {
    String message = quickReply ?? _controller.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add(MessageBubble(text: message, isUser: true, onOptionSelected: (String ) {  },));
      _isBotThinking = true;
    });

    if (quickReply == null) {
      _controller.clear();
    }

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'message': message}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _handleBotResponse(data);
      }
    } catch (e) {
      _showError('Connection error: $e');
    } finally {
      setState(() => _isBotThinking = false);
    }
  }

  void _handleBotResponse(Map<String, dynamic> data) {
    final type = data['type'];
    final response = data['response'];

    setState(() {
      _messages.add(MessageBubble(
        text: response,
        isUser: false,
        type: type,
        options: data['options'] != null
            ? List<String>.from(data['options'])
            : null,
        onOptionSelected: (option) => _sendMessage(option),
      ));

      if (type == 'openai') _isOpenAIMode = true;
      if (type == 'end') _resetChat();
    });
  }

  void _resetChat() {
    setState(() {
      _messages.clear();
      _isOpenAIMode = false;
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mindful Chat 🌿'),
        backgroundColor: Colors.green[700],
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _resetChat,
            color: Colors.white,
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (ctx, index) => _messages.reversed.toList()[index],
            ),
          ),
          if (_isBotThinking)
            Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(color: Colors.green),
            ),
          _buildInputSection(),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green[50],
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: _isOpenAIMode
                          ? "Type your message..."
                          : "Select an option or type...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(horizontal: 20),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green[700],
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: () => _sendMessage(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final String? type;
  final List<String>? options;
  final void Function(String)? onOptionSelected;

  const MessageBubble({
    required this.text,
    required this.isUser,
    this.type,
    this.options,
    this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment:
        isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8),
            decoration: BoxDecoration(
              color: isUser ? Colors.green[100] : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
            ),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: TextStyle(
                  color: Colors.green[900],
                  fontSize: 16,
                )),
                if (options != null && options!.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: options!.map((option) => ActionChip(
                        label: Text(option),
                        backgroundColor: Colors.green[50],
                        labelStyle: TextStyle(color: Colors.green[800]),
                        onPressed: () => onOptionSelected?.call(option),
                      )).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}