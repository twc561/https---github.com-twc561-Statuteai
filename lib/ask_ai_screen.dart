import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart'; // Corrected import

class AskAIScreen extends StatefulWidget {
  const AskAIScreen({super.key});
  @override
  _AskAIScreenState createState() => _AskAIScreenState();
}

enum MessageType { user, ai }

class ChatMessage {
  final String text;
  final MessageType type;
  ChatMessage({required this.text, required this.type});
}

class _AskAIScreenState extends State<AskAIScreen> {
  final TextEditingController _questionController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  late final GenerativeModel _model;

  @override
  void initState() {
    super.initState();
    // Initialize the Gemini model
    _model = FirebaseVertexAI.instance.generativeModel(model: 'gemini-1.5-flash');
  }

  Future<void> _askAI() async {
    final userQuestion = _questionController.text.trim();
    if (userQuestion.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: userQuestion, type: MessageType.user));
      _isLoading = true;
    });

    _questionController.clear();

    try {
      // Generate content using the correct API
      final response = await _model.generateContent([Content.text(userQuestion)]);
      final aiAnswer = response.text ?? "Could not get a response from the AI.";

      setState(() {
        _messages.add(ChatMessage(text: aiAnswer, type: MessageType.ai));
      });
    } on PlatformException catch (e) {
      setState(() {
        _messages.add(ChatMessage(
            text: "Error: ${e.message ?? 'An unexpected platform error occurred.'}\n\nPlease try again.",
            type: MessageType.ai));
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
            text: "An unexpected error occurred: ${e.toString()}\n\nPlease try again.",
            type: MessageType.ai));
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              final bool isUser = message.type == MessageType.user;
              return Align(
                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.all(10.0),
                  margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: isUser ? Colors.blue[100] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: SelectableText(
                    message.text,
                    style: GoogleFonts.openSans(fontSize: 16, color: isUser ? Colors.black87 : Colors.black),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(right: 8.0), // Corrected Padding usage
                  child: CircularProgressIndicator(),
                ),
              Expanded(
                child: TextField(
                  controller: _questionController,
                  decoration: InputDecoration(
                    hintText: _isLoading ? "Waiting for response..." : "Ask a question...",
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                  ),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  enabled: !_isLoading,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (value) {
                    if (!_isLoading) {
                      _askAI();
                    }
                  },
                  style: GoogleFonts.openSans(fontSize: 16),
                ),
              ),
              const SizedBox(width: 8.0),
              ElevatedButton(
                onPressed: _isLoading ? null : _askAI,
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(15),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                child: const Icon(Icons.send, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }
}