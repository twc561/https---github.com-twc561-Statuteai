import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart'; // Corrected import

enum AnalysisState { loading, loaded, error }

class StatuteDetailScreen extends StatefulWidget {
  final String statuteNumber;
  const StatuteDetailScreen({super.key, required this.statuteNumber});

  @override
  _StatuteDetailScreenState createState() => _StatuteDetailScreenState();
}

class _StatuteDetailScreenState extends State<StatuteDetailScreen> {
  String _analysis = 'Loading analysis...';
  AnalysisState _state = AnalysisState.loading;
  String _errorMessage = '';
  late final GenerativeModel _model;

  @override
  void initState() {
    super.initState();
    // Initialize the Gemini model
    _model = FirebaseVertexAI.instance.generativeModel(model: 'gemini-1.5-flash');
    _fetchStatuteAnalysis();
  }

  Future<void> _fetchStatuteAnalysis() async {
    setState(() {
      _state = AnalysisState.loading;
    });

    try {
      final prompt = 'Provide a detailed analysis of Florida Statute ${widget.statuteNumber}. '
          'Include a plain English summary, a clear bulleted list of the elements of the crime (if applicable), '
          'summaries of applicable key case law, and real-world examples of how the statute is applied. '
          'Format the response clearly with headings for each section (Summary, Elements, Case Law, Examples).';

      // Generate content using the correct API
      final response = await _model.generateContent([Content.text(prompt)]);

      if (response.text != null && response.text!.isNotEmpty) {
        setState(() {
          _analysis = response.text!;
          _state = AnalysisState.loaded;
        });
      } else {
        setState(() {
          _errorMessage = 'No analysis available for this statute.';
          _state = AnalysisState.error;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching analysis: ${e.toString()}';
        _state = AnalysisState.error;
      });
      print('Error fetching analysis: $e'); // Log the error
    }
  }

  Widget _buildAnalysisCard(String title, String content) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ExpansionTile(
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        childrenPadding: const EdgeInsets.all(16.0),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(content, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              Text(_errorMessage,
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
        final sections = _parseAnalysis(_analysis);
        content = ListView(
          children: [
            Text(
              'Details for Statute: ${widget.statuteNumber}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            ...sections.entries.map((entry) => _buildAnalysisCard(entry.key, entry.value)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _launchOfficialLink(widget.statuteNumber),
              icon: const Icon(Icons.launch),
              label: const Text('View Official Text'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                textStyle: Theme.of(context).textTheme.labelLarge,
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

  Map<String, String> _parseAnalysis(String analysis) {
    final sections = <String, String>{};
    // Use a more robust splitting method based on known headings
    final knownHeadings = ["Summary", "Elements", "Case Law", "Examples"];
    String currentContent = analysis;

    // Split by known headings
    for (int i = 0; i < knownHeadings.length; i++) {
        final heading = knownHeadings[i];
        final parts = currentContent.split(RegExp(r'\s*' + heading + r'\s*:\s*', caseSensitive: false));
        if (parts.length > 1) {
            if (i > 0) {
              sections[knownHeadings[i-1]] = parts[0].trim();
            }
            currentContent = parts[1];
        }
    }
    // The remainder is the last section
    if (sections.isNotEmpty) {
      sections[knownHeadings[knownHeadings.length-1]] = currentContent.trim();
    }


    if (sections.isEmpty) {
      sections['Analysis'] = analysis;
    }

    return sections;
  }

  Future<void> _launchOfficialLink(String statuteNumber) async {
    final Uri url = Uri.parse('http://www.leg.state.fl.us/statutes/index.cfm?App_mode=Display_Statute&Search_String=&URL=0$statuteNumber.HTM');
    if (!await launchUrl(url, mode: LaunchMode.inAppWebView)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch official text for $statuteNumber')),
      );
    }
  }
}