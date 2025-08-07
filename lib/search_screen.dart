import 'package:flutter/material.dart';
import 'package:myapp/statute_detail_screen.dart';

/// Represents a single Florida Statute with its number and title.
class Statute {
  /// The official number of the statute.
  final String number;
  /// The title or brief description of the statute.
  final String title;

  Statute({required this.number, required this.title});
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  /// Controller for the search input field.
  final TextEditingController _searchController = TextEditingController();
  /// A mock list of all Florida Statutes for demonstration purposes.
  /// In a real application, this would likely come from an external data source.
  final List<Statute> _allStatutes = [
    Statute(number: "790.23", title: "Felon in possession of firearm"),
    Statute(number: "812.014", title: "Theft"), // Mock data for various statutes
    Statute(number: "810.02", title: "Burglary"),
    Statute(number: "316.193", title: "Driving under the influence"),
    Statute(number: "901.15", title: "Arrest by officer pursuant to warrant; extradition"),
    Statute(number: "901.151", title: "Stop and frisk law"),
  ];
  // List to hold statutes filtered based on the search query.
  List<Statute> _filteredStatutes = [];
  /// Text to display if there's an error with the search input.
  String? _errorText;

  /// Filters the list of statutes based on the provided query string.
  /// Updates [_filteredStatutes] and [_errorText] accordingly.
  void _performSearch(String query) {
    setState(() { // Update the UI based on the search results.
      if (query.isEmpty) {
        // If the query is empty, show no results.
        _filteredStatutes = [];
      } else {
        // Filter statutes where the number or title contains the query (case-insensitive).
        final validCharacters = RegExp(r'^[a-zA-Z0-9.\s]*$');
        if (!validCharacters.hasMatch(query)) {
          _filteredStatutes = [];
          _errorText = 'Invalid characters in search query.';
          return;
        }
        _errorText = null; // Clear error if input is valid
        _filteredStatutes = _allStatutes.where((statute) {
          return statute.number.contains(query.toLowerCase()) ||
              statute.title.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  @override
  void initState() {
    super.initState();
    // Perform initial search when the screen is created.
    _performSearch(_searchController.text); // Perform initial search with an empty query to show no results initially.
  }

  @override
  @override
  void dispose() {
    // Dispose the search controller when the widget is removed to prevent memory leaks.
    _searchController.dispose();
    super.dispose();
  }

  @override
  // Builds the UI for the search screen.
 Widget build(BuildContext context) {
    return Padding(
      // Add padding around the search screen content.
      // Consistent padding helps with overall layout.
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          // Search input field.
          Card(
            elevation: _errorText != null ? 0.0 : 2.0, // No elevation if there's an error
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: _errorText != null
                  ? const BorderSide(color: Colors.red, width: 1.0) // Red border for error
                  : BorderSide.none,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: _errorText ?? 'Search Florida Statutes...', // Show error text or hint
                  prefixIcon: const Icon(Icons.search),
                  border: InputBorder.none, // Remove default border
                  errorText: _errorText, // Display error text below the field
                  // Setting errorStyle fontSize to 0 hides the default error text widget space
                  errorStyle: const TextStyle(fontSize: 0), // Hide the default error text space
                ),
                onChanged: _performSearch, // Update search results as the user types.
                onSubmitted: _performSearch, // Also update search results when the user submits (e.g., presses enter).
              ),

            ),
          ),
          const SizedBox(height: 16.0),
          if (_errorText != null) // Display error message below the search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                _errorText!,
                style: TextStyle(color: Colors.red, fontSize: 14.0),
              ),
            ),
          if (_errorText == null) // Only display results if there's no error
            Expanded(
              // Expanded widget to make the ListView take available space.
              // ListView to display the filtered search results.
              // keyboardDismissBehavior ensures the keyboard hides when the user scrolls the results.
              child: ListView.builder(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag, // Dismiss keyboard on scroll
                itemCount: _filteredStatutes.length,
                // Builds each list item for the search results.
                itemBuilder: (context, index) {
                  // Get the current statute to display.
                  final statute = _filteredStatutes[index];
                  // Display each statute in a Card with a tappable ListTile.
                  return Card(
                    elevation: 1.0, // Slightly less elevation for list items
                    margin: const EdgeInsets.symmetric(vertical: 4.0), // Add vertical margin between cards
                    child: ListTile(
                      title: Text(statute.number,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)), // Make statute number bold
                      // Display the statute title as a subtitle.
                      subtitle: Text(statute.title,
                          style: Theme.of(context).textTheme.bodyMedium),
                      onTap: () {
                        // Navigate to the detailed statute analysis screen when tapped.
                        // Pass the statute number to the detail screen.
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StatuteDetailScreen(statuteNumber: statute.number),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}