import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../db/app_database.dart';
import '../theme/theme_management.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AppDatabase db = AppDatabase();

  List<Color> customColor = [
    Colors.amber,
    Colors.blue,
    Colors.green,
    Colors.red,
  ];

  Color selectedColor = Colors.amber; // default selected theme color

  bool isContainerPressed = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeProvider.primaryColor,
        title: const Text(
          "Settings",
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Theme Info",
                style: TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),

              Container(
                height: 150,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white, // Neumorphic base color
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: themeProvider.primaryColor,
                    width: 2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.white,
                      offset: Offset(-5, -5),
                      blurRadius: 10,
                    ),
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(5, 5),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.brightness_6,
                          color: themeProvider.primaryColor,
                          size: 28,
                        ),
                        SizedBox(width: 12),
                        Text(
                          "Change Theme",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: customColor.map((color) {
                        bool isSelected = themeProvider.primaryColor == color;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              themeProvider.setTheme(color);
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.7),
                                  offset: const Offset(-4, -4),
                                  blurRadius: 6,
                                ),
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  offset: const Offset(4, 4),
                                  blurRadius: 6,
                                ),
                              ],
                              border: isSelected
                                  ? Border.all(color: Colors.black, width: 2)
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  border: Border.all(
                    color: isContainerPressed
                        ? Colors.red
                        : themeProvider.primaryColor,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ⚡ Switch tile with built-in layout
                    SwitchListTile.adaptive(
                      inactiveTrackColor: Colors.grey[300],
                      activeColor: Colors.red,
                      value: isContainerPressed,
                      onChanged: (value) {
                        setState(() {
                          isContainerPressed = value;
                        });
                      },
                      secondary: Icon(
                        Icons.warning_amber_rounded,
                        color: isContainerPressed ? Colors.red : Colors.grey,
                        size: 28,
                      ),
                      title: Text(
                        "Danger Zone",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isContainerPressed ? Colors.red : Colors.grey,
                        ),
                      ),
                    ),

                    if (isContainerPressed) ...[
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
                          // Delete all notes from database
                          await db.deleteAllNotes();
                          // Close Settings and return true so HomeNoteScreen knows to refresh
                          Navigator.pop(context, true);

                          // Close Danger Zone OR show message
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("All data deleted!")),
                          );
                        },

                        icon: const Icon(Icons.restore, color: Colors.white),
                        label: const Text(
                          "Reset Data",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
