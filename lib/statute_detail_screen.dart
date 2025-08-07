import 'package:flutter/material.dart';
import 'package:firebase_ai/firebase_ai.dart'; // Import firebase_ai
import 'package:provider/provider.dart'; // Import provider if using for state management.
import 'package:url_launcher/url_launcher.dart';
// You might need to import your ThemeProvider if you are using it
// import 'package:your_app_name/main.dart'; // Adjust import based on your project structure

// Enum to represent the state of the analysis fetch
enum AnalysisState { loading, loaded, error }


class StatuteDetailScreen extends StatefulWidget {
  final String statuteNumber;
  const StatuteDetailScreen({super.key, required this.statuteNumber});

  @override
  _StatuteDetailScreenState createState() => _StatuteDetailScreenState();
}

class _StatuteDetailScreenState extends State<StatuteDetailScreen> {
  String _analysis = 'Loading analysis...';
  bool _isLoading = true;
  AnalysisState _state = AnalysisState.loading;
  String _errorMessage = ''; // Declare errorMessage state variable


  @override
  void initState() {
    super.initState();
    _fetchStatuteAnalysis();
  }

  Future<void> _fetchStatuteAnalysis() async {
    setState(() {
      _isLoading = true;
      _state = AnalysisState.loading;
    });

    try {
      // Construct the prompt for Gemini
      final prompt = 'Provide a detailed analysis of Florida Statute ${widget.statuteNumber}. '
          'Include a plain English summary, a clear bulleted list of the elements of the crime (if applicable), '
          'summaries of applicable key case law, and real-world examples of how the statute is applied. '
          'Format the response clearly with headings for each section (Summary, Elements, Case Law, Examples).';

      // Make the API call to Gemini
      final response = await FirebaseVertexAI.instance.generativeModel(model: 'gemini-pro').generateContent([
        Content.text(prompt),
      ]);

      // Process the response
      if (response.text != null && response.text!.isNotEmpty) {
        _analysis = response.text!;
        _state = AnalysisState.loaded;
      } else {
        _analysis = 'No analysis available for this statute.';
        _state = AnalysisState.error; // Treat no analysis as an error for now
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching analysis: ${e.toString()}';
      });
      print('Error fetching analysis: $e'); // Log the error
    } finally {
      setState(() {
        _isLoading = false;

      });
    }
  }

  // Helper function to build a card for a section of the analysis
  Widget _buildAnalysisCard(String title, String content) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ExpansionTile( // Using ExpansionTile for collapsible cards
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        childrenPadding: const EdgeInsets.all(16.0),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(content, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    // You can access the theme provider here if needed for styling
    // final themeProvider = Provider.of<ThemeProvider>(context);

    Widget content;
    switch (_state) {
      case AnalysisState.loading:
        content = const Center(child: CircularProgressIndicator());
        break;
      case AnalysisState.error:
        content = Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 50),
              const SizedBox(height: 10),
              Text(_analysis, // Display error message here
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchStatuteAnalysis,
                child: const Text('Retry'),
              ),
            ],
          ),
        );
        break;
      case AnalysisState.loaded:
        // Here we need to parse _analysis string into sections.
        // This is a basic example and might need more sophisticated parsing
        // depending on how Gemini formats the response.
        final sections = _parseAnalysis(_analysis);

        content = ListView(
          children: [
            Text(
              'Details for Statute: ${widget.statuteNumber}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            // Display sections in cards
            ...sections.entries.map((entry) => _buildAnalysisCard(entry.key, entry.value)),

            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _launchOfficialLink(widget.statuteNumber),
              icon: const Icon(Icons.launch),
              label: const Text('View Official Text'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary, // Use primary color for button
                padding: const EdgeInsets.symmetric(vertical: 12.0), // Add padding
                textStyle: Theme.of(context).textTheme.labelLarge, // Use appropriate text style
              ),
            ),
          ],
        );
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Statute ${widget.statuteNumber}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: content,
      ),
    );
  }

  // Basic function to parse the analysis string into sections
  // This will need to be more robust depending on Gemini's output format
  Map<String, String> _parseAnalysis(String analysis) {
    final sections = <String, String>{};
    final lines = analysis.split('\n');
    String? currentSection;
    StringBuffer currentContent = StringBuffer();

    for (final line in lines) {
      if (line.trim().isEmpty) continue;

      // Simple check for headings (assuming bold text or capitalized words)
      if (line.trim().startsWith('**') || line.trim().endsWith(':') || line.trim().toUpperCase() == line.trim()) {
        if (currentSection != null) {
          sections[currentSection] = currentContent.toString().trim();
          currentContent.clear();
        }
        currentSection = line.trim().replaceAll('**', '').replaceAll(':', ''); // Clean up heading
      } else {
        currentContent.writeln(line.trim());
      }
    }

    if (currentSection != null) {
      sections[currentSection] = currentContent.toString().trim();
    }

    // If no sections were found, put the whole analysis in a default section
    if (sections.isEmpty) {
      sections['Analysis'] = analysis;
    }

    return sections;
  }

  Future<void> _launchOfficialLink(String statuteNumber) async {
    // Construct the URL for the Florida Legislature's website.
    // This is a simplified URL structure and might need adjustment
    // based on the actual website's URL pattern.
    final Uri url = Uri.parse('http://www.leg.state.fl.us/statutes/index.cfm?App_mode=Display_Statute&Search_String=&URL=0$statuteNumber.HTM');
    if (!await launchUrl(url, mode: LaunchMode.inAppWebView)) {
      throw 'Could not launch $url';
    }
  }
}

