import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import 'package:stress_management/constants/colors.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class TypingIndicator extends StatefulWidget {
  @override
  _TypingIndicatorState createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentDots = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentDots = (_currentDots + 1) % 4;
        });
        _controller.reset();
        _controller.forward();
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.0),
          topRight: Radius.circular(12.0),
          bottomRight: Radius.circular(12.0),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Typing" + "." * _currentDots,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> messages = [
    {
      "text": "Hello! How are you feeling today?",
      "options": [
        "I'm feeling great!",
        "I'm feeling okay, just neutral.",
        "I'm feeling a little stressed today."
      ]
    }
  ];
  bool enableTextField = false;
  bool isLoading = false;
  bool isImageLarge = true;
  TextEditingController _controller = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool isTyping = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 1.0, end: 0.3).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _showTypingIndicatorAndAddMessage(Map<String, dynamic> message, {int typingDuration = 2}) async {
    setState(() {
      isTyping = true;
    });

    await Future.delayed(Duration(seconds: typingDuration));

    setState(() {
      isTyping = false;
      messages.add(message);
    });
  }

  void _handleResponse(String response) async {
    if (isImageLarge) {
      _animationController.forward();
      setState(() {
        isImageLarge = false;
      });
    }

    setState(() {
      messages.add({"text": response, "isUser": true});
    });

    if (response == "I'm feeling great!") {
      await _showTypingIndicatorAndAddMessage({
        "text": "That's wonderful to hear! Keep up the positive energy!\n\nIs there anything else you'd like to talk about, or shall we wrap up?",
        "options": [
          "Yes, let's wrap it up. Thank you!",
          "No, I still have something to talk about."
        ]
      });
    } else if (response == "I'm feeling okay, just neutral.") {
      await _showTypingIndicatorAndAddMessage({
        "text": "Neutral can be peaceful. Is there anything I can do to help make your day even better?\n\nIf you'd like to chat more, I'm here! Otherwise, we can wrap up.",
        "options": [
          "Yes, let's wrap it up. Thank you!",
          "No, I still have something to talk about."
        ]
      });
    } else if (response == "I'm feeling a little stressed today.") {
      await _showTypingIndicatorAndAddMessage({
        "text": "I hear you. Stress can sneak up on us sometimes. Would you like to talk about it?",
        "options": [
          "No, I think I'm good for now.",
          "Yes, I'd like to talk about it."
        ]
      });
    } else if (response == "Yes, I'd like to talk about it." ||
        response == "No, I still have something to talk about.") {
      await _showTypingIndicatorAndAddMessage({
        "text": "Sure! What's been on your mind?",
      });
      enableTextField = true;
    }
  }

  Future<void> _sendMessageToAPI(String message) async {
    setState(() {
      messages.add({"text": message, "isUser": true});
      isTyping = true;
      isLoading = true;
    });

    // LangFlow API endpoint
    final apiUrl =
        "https://api.langflow.astra.datastax.com/lf/4ac4002e-d027-4f4d-9aec-6c9f31cf8377/api/v1/run/5d198fe5-06dd-4658-bfab-0ac8ba18e90e?stream=false";

    //tokenAstraCS = oKfWmWBXOWibrpZEBDGkcHBB:7ef70e360f832659d71c5b6a61345d8072cb417108cd8c72a66151618b826d34
    final headers = {
      "Authorization":
      "Bearer AstraCSAstraCS:<token>", // Replace with your token
      "Content-Type": "application/json",
    };

    final body = jsonEncode({
      "input_value": message,
      "output_type": "chat",
      "input_type": "chat",
      "tweaks": {
        "ChatInput-fKs21": {},
        "Prompt-eDgZg": {},
        "ChatOutput-j3uHn": {},
        "GoogleGenerativeAIModel-K5A6S": {}
      },
    });

    try {
      print("Sending request to API...");
      print("API URL: $apiUrl");
      print("Headers: $headers");
      print("Body: $body");

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: body,
      );

      print("Status Code: ${response.statusCode}");
      print("Response Headers: ${response.headers}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final output = data["outputs"][0]["outputs"][0]["results"]["message"]["text"] as String?;

        if (output != null) {
          // Add a small delay to simulate natural typing
          await Future.delayed(Duration(seconds: 1));
          setState(() {
            isTyping = false;
            isLoading = false;
            messages.add({"text": output, "isUser": false});
          });
        } else {
          setState(() {
            isTyping = false;
            isLoading = false;
            messages.add({"text": "Error: No output from API", "isUser": false});
          });
        }
      } else {
        setState(() {
          isTyping = false;
          isLoading = false;
          messages.add({
            "text": "Error: ${response.statusCode} - ${response.body}",
            "isUser": false
          });
        });
      }
    } catch (e) {
      print("Error occurred: $e");
      setState(() {
        isTyping = false;
        isLoading = false;
        messages.add({"text": "Error: $e", "isUser": false});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat with Mochi"),
        backgroundColor: AppColors.secondary,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            opacity: 0.3,
            image: AssetImage("assets/bg_logo.png"),
            fit: BoxFit.contain,
          ),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Container(
                      height: MediaQuery.of(context).size.height * (0.4 * _animation.value),
                      width: MediaQuery.of(context).size.width * _animation.value,
                      child: Image.asset(
                        'assets/home/panda.png',
                        fit: BoxFit.contain,
                      ),
                    );
                  },
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.only(top: 12.0, left: 12.0, right: 12.0, bottom: 100.0),
                    itemCount: messages.length + (isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == messages.length && isTyping) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: TypingIndicator(),
                        );
                      }

                      final message = messages[index];
                      final text = message["text"] as String?;
                      final isUser = message["isUser"] as bool? ?? false;

                      if (text == null) {
                        return SizedBox.shrink();
                      }

                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                          padding: EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: isUser ? Color(0xFF1a237e) : Colors.grey[800],
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12.0),
                              topRight: Radius.circular(12.0),
                              bottomLeft: isUser ? Radius.circular(12.0) : Radius.zero,
                              bottomRight: isUser ? Radius.zero : Radius.circular(12.0),
                            ),
                          ),
                          child: Text(
                            text,
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (enableTextField)
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Type your message...",
                              hintStyle: TextStyle(color: Colors.grey),
                              filled: true,
                              fillColor: Colors.grey[900],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        IconButton(
                          icon: Icon(Icons.send, color: AppColors.secondary),
                          onPressed: () {
                            if (_controller.text.isNotEmpty) {
                              _sendMessageToAPI(_controller.text);
                              _controller.clear();
                            }
                          },
                        )
                      ],
                    ),
                  ),
              ],
            ),
            if (messages.isNotEmpty && messages.last.containsKey("options"))
              Positioned(
                bottom: enableTextField ? 80 : 20,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 12.0),
                      child: Text(
                        "Select an option:",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 12.0),
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        alignment: WrapAlignment.center,
                        children: (messages.last["options"] as List<String>).map((option) {
                          return ElevatedButton(
                            onPressed: () => _handleResponse(option),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(option, style: TextStyle(fontSize: 16)),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}