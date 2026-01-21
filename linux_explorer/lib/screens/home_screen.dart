import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List distros = [];

  @override
  void initState() {
    super.initState();
    loadDistros();
  }

  Future<void> loadDistros() async {
    final data =
        await rootBundle.loadString('assets/data/distros.json');
    setState(() {
      distros = json.decode(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Linux Explorer"),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: theme.toggleTheme,
          ),
        ],
      ),
      body: distros.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: distros.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemBuilder: (context, index) {
                final d = distros[index];
                return Card(
                  child: Column(
                    children: [
                      Expanded(
                        child: Image.asset(
                          d['image'],
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        d['name'],
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(d['size']),
                      const SizedBox(height: 8),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
