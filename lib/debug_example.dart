
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

class DebugExample extends StatefulWidget {
  const DebugExample({super.key});

  @override
  State<DebugExample> createState() => _DebugExampleState();
}

class _DebugExampleState extends State<DebugExample> {
  List<int> numbers = [1, 2, 3, 4, 5];
  int? selectedNumber;
  String message = '';

  void processNumbers() {
    developer.log('Starting number processing', name: 'debug_example');
    
    // Set a breakpoint here to inspect the numbers list
    for (int i = 0; i < numbers.length; i++) {
      int current = numbers[i];
      developer.log('Processing number: $current at index $i', name: 'debug_example');
      
      // Simulate some processing
      if (current % 2 == 0) {
        developer.log('$current is even', name: 'debug_example');
      } else {
        developer.log('$current is odd', name: 'debug_example');
      }
    }
    
    setState(() {
      message = 'Processed ${numbers.length} numbers';
    });
  }

  void demonstratePotentialBug() {
    developer.log('Demonstrating potential bug', name: 'debug_example');
    
    try {
      // This might cause an issue - good place for a breakpoint
      int index = numbers.length; // Off by one error
      int value = numbers[index]; // This will throw an exception
      
      setState(() {
        selectedNumber = value;
      });
    } catch (e, stackTrace) {
      developer.log(
        'Caught an error!',
        name: 'debug_example',
        error: e,
        stackTrace: stackTrace,
      );
      
      setState(() {
        message = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    developer.log('Building debug example widget', name: 'debug_example.ui');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Example'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Numbers: ${numbers.join(', ')}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            if (selectedNumber != null)
              Text(
                'Selected: $selectedNumber',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            const SizedBox(height: 20),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: processNumbers,
              child: const Text('Process Numbers'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: demonstratePotentialBug,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Trigger Bug (for debugging)'),
            ),
          ],
        ),
      ),
    );
  }
}
