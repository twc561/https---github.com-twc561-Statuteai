import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:myapp/ask_ai_screen.dart';
import 'package:myapp/search_screen.dart';

// Import firebase_options.dart once you have configured Firebase
// import 'firebase_options.dart';

void main() async {
  // Ensure that Flutter widgets are initialized before running the app.
  // This is required for Firebase initialization.
  WidgetsFlutterBinding.ensureInitialized();
  // Uncomment and replace with your Firebase options once configured
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  runApp(
    ChangeNotifierProvider(
    create: (context) => ThemeProvider(),
 child: const MyApp(), // Create an instance of the ThemeProvider to manage the theme state.
    ),
 );
}

  @override
  Widget build(BuildContext context) {
    // Define a primary seed color for the theme.
    const Color primarySeedColor = Colors.blue;
    // Get the theme provider to control the theme mode.
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Define a common TextTheme
    final TextTheme appTextTheme = TextTheme( 
      displayLarge: GoogleFonts.oswald(fontSize: 57, fontWeight: FontWeight.bold),
      titleLarge: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.w500),
      bodyMedium: GoogleFonts.openSans(fontSize: 14),
    );

    // Light Theme
    final ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: primarySeedColor,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.oswald(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );

    // Dark Theme
    final ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.oswald(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer, // Using primaryContainer from the generated color scheme
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );

    // Consume the ThemeProvider to update the MaterialApp theme.
    return MaterialApp(
      title: 'Florida Statutes AI Field Guide',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.themeMode,
      home: const MyHomePage(),
    );
  }
}
/// ThemeProvider class to manage the theme state
class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system; // Default to system theme

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setSystemTheme() {
    _themeMode = ThemeMode.system;
    notifyListeners();
  }
}

/// MyHomePage is the main screen with a BottomNavigationBar.
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

/// State for the MyHomePage widget.
class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  // List of screens to be displayed based on the selected index in the bottom navigation bar.
  // The order corresponds to the BottomNavigationBarItem order.
  final List<Widget> _screens = <Widget>[
    SearchScreen(), // Use the actual SearchScreen widget
    AskAIScreen(), // Use the actual AskAIScreen widget
    RecentsScreen(), // Include the RecentsScreen
  ];


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    // Access the ThemeProvider to control theme switching from the AppBar.
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);


    return Scaffold(
      appBar: AppBar(
        title: const Text('Florida Statutes AI Field Guide'),
        actions: [
          // Button to toggle between light and dark themes.
          IconButton(
            icon: Icon(themeProvider.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: themeProvider.toggleTheme,
            tooltip: 'Toggle Theme',
          ),
          // Button to set the theme mode back to system preference.
          IconButton(
            icon: const Icon(Icons.auto_mode),
            onPressed: themeProvider.setSystemTheme,
            tooltip: 'Set system theme',
          ),
        ],

      ),
      body: Center(
        child: _screens.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            // Icon and label for the Search tab.
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            // Icon and label for the Ask AI tab.
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Ask AI',
          ),
          BottomNavigationBarItem(
            // Icon and label for the Recents tab.
            icon: Icon(Icons.history),
            label: 'Recents',
          ),
        ],
        currentIndex: _selectedIndex,
        // Use the primary color from the current theme for the selected item.
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: _onItemTapped,
      ),
    );
  }
}

/// Placeholder screen for the Recents tab.
class RecentsScreen extends StatelessWidget {
  const RecentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Recents Screen - Coming Soon!'));
  }

