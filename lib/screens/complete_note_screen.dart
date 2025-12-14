import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import '../db/app_database.dart';
import '../theme/theme_management.dart';
import 'package:flutter_highlight/themes/atom-one-light.dart';

class CompleteNoteScreen extends StatefulWidget {
  final Note note;

  const CompleteNoteScreen({super.key, required this.note});

  @override
  State<CompleteNoteScreen> createState() => _CompleteNoteScreenState();
}

class _CompleteNoteScreenState extends State<CompleteNoteScreen> {
  bool get isDartCode {
    final text = widget.note.content.trim();
    return text.contains("void main") ||
        text.contains("class ") ||
        text.contains("import 'package:") ||
        text.contains("=>") ||
        text.contains(";"); // simple detection
  }

  void copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.note.content));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Code copied to clipboard ✅")));
  }

  String formatDartCode(String code) {
    // Remove leading/trailing spaces from each line
    final lines = code.split('\n').map((line) => line.trimRight()).toList();

    // Remove empty lines at the start and end
    while (lines.isNotEmpty && lines.first.isEmpty) lines.removeAt(0);
    while (lines.isNotEmpty && lines.last.isEmpty) lines.removeLast();

    // Optional: replace multiple empty lines inside with a single empty line
    final formatted = <String>[];
    bool lastWasEmpty = false;

    for (var line in lines) {
      if (line.trim().isEmpty) {
        if (!lastWasEmpty) {
          formatted.add('');
          lastWasEmpty = true;
        }
      } else {
        formatted.add(line);
        lastWasEmpty = false;
      }
    }

    return formatted.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.note.title,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: themeProvider.primaryColor, width: 1.5),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: isDartCode
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.copy, color: Colors.blue),
                        tooltip: "Copy Code",
                        onPressed: copyToClipboard,
                      ),
                    ],
                  ),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: InteractiveViewer(
                        maxScale: 5.0,
                        minScale: 1.0,
                        panEnabled: true,

                        child: HighlightView(
                          formatDartCode(widget.note.content),
                          language: 'dart',
                          theme: atomOneLightTheme,
                          padding: const EdgeInsets.all(12),
                          textStyle: const TextStyle(
                            fontFamily: 'Inconsolata',
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
                  : InteractiveViewer(
                maxScale: 5.0,
                minScale: 1.0,
                panEnabled: true,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    widget.note.content,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
