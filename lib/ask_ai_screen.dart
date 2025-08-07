import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart'; // Import for PlatformException
import 'package:firebase_ai/firebase_ai.dart'; // Ensure firebase_ai is imported
/// Represents the conversational AI screen for querying Florida Statutes.
class AskAIScreen extends StatefulWidget {
  const AskAIScreen({super.key});
  @override
  _AskAIScreenState createState() => _AskAIScreenState();
}


/// Defines the type of message in the conversation.
enum MessageType { user, ai }

/// Represents a single message in the conversation.
class ChatMessage {
  final String text;
  final MessageType type;
  ChatMessage({required this.text, required this.type});
}

/// State class for the AskAIScreen, managing the conversation and AI interaction.
class _AskAIScreenState extends State<AskAIScreen> {
  /// Controller for the text input field where the user types questions.
  final TextEditingController _questionController = TextEditingController();

  /// List to hold the conversation history, including both user and AI messages.
  List<ChatMessage> messages = [];

  /// State variable to indicate if an AI response is currently being loaded.
  bool _isLoading = false;

  /// Sends the user's question to the Gemini API and updates the conversation history with the response.
  Future<void> _askAI() async {
    final userQuestion = _questionController.text.trim();
    if (userQuestion.isEmpty) return; // Don't send empty messages

    setState(() {
      messages.add(ChatMessage(text: userQuestion, type: MessageType.user));
      _isLoading = true; // Show loading indicator
    });

    _questionController.clear(); // Clear input field immediately

    try {
      // Make the call to the Gemini API with the user's question.
      // Ensure "gemini-pro" is the correct model name for your setup.
      final textResponse = await FirebaseVertexAI.instance.generativeModel(model: "gemini-pro")
          .generateText(userQuestion);

      // Extract and trim the AI's response. Provide a fallback message if no response is received.
      final aiAnswer = textResponse?.trim() ?? "Could not get a response from the AI.";

      setState(() {
        // Add the AI's response to the conversation history.
        messages.add(ChatMessage(text: aiAnswer, type: MessageType.ai));
      });

    } on PlatformException catch (e) {
      // Handle specific Firebase/Platform exceptions that might occur during the API call.
      setState(() {
        // Add an error message to the conversation history for the user.
        messages.add(ChatMessage(
            text: "Error: ${e.message ?? 'An unexpected platform error occurred.'}\n\nPlease try again.",
            type: MessageType.ai));
      });
    } catch (e) {
      // Catch any other general exceptions that might occur.
      setState(() {
        // Add a generic error message to the conversation history.
        messages.add(ChatMessage(
            text: "An unexpected error occurred: ${e.toString()}\n\nPlease try again.",
            type: MessageType.ai));
      });
    } finally {
    // Hide loading indicator after response or error
    setState(() {
      _isLoading = false;
    });}
  } // Removed extra closing curly brace

  /// Cleans up the text editing controller when the widget is disposed.
  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      // Column to hold the conversation list and the input area.
      children: [
        Expanded(
          // Expanded widget to make the ListView take the available space.
          child: ListView.builder(
            // ListView.builder to efficiently display the conversation messages.
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              final bool isUser = message.type == MessageType.user; // Correctly access type
              return Align(
                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.all(10.0),
                  margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: isUser ? Colors.blue[100] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: SelectableText( // Use SelectableText to allow users to copy the text.
                    message.text,
                    style: GoogleFonts.openSans(fontSize: 16, color: isUser ? Colors.black87 : Colors.black),
                  )
                ),
              );
            },
          ),
        ),
        // Padding around the input row.
        Padding(
          padding: const EdgeInsets.all(8.0),
          // Row to hold the loading indicator, text input field, and send button.
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Loading indicator
              if (_isLoading)
                const Padding(
                ),
                  child: CircularProgressIndicator(), // Added child back to Padding
              // Input field
              Expanded(
                // Expanded to make the TextField take up most of the row space.
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
                  maxLines: null, // Allow multiple lines
                  keyboardType: TextInputType.multiline,
                  enabled: !_isLoading, // Disable input field while waiting for response.
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (value) {
                    // Send the message when the user submits (e.g., presses Enter).
                    if (!_isLoading) {
                      _askAI();
                    }
                  },
                  style: GoogleFonts.openSans(fontSize: 16),
                ),
              ), // SizedBox for spacing between input and button.
              const SizedBox(width: 8.0),
              // Send button
              ElevatedButton(
                onPressed: _isLoading ? null : _askAI, // Disable button while loading

                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(15), // Circular padding for the button.
                  backgroundColor: Theme.of(context).primaryColor, // Use primary color from theme
                ),
                child: const Icon(Icons.send, color: Colors.white,),
              ),
            ],
          ),
        ),
      ],
    );
  }
}