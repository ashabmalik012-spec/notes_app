import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:notes_app/screens/setting_screen.dart';

import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../db/app_database.dart';
import '../theme/theme_management.dart';
import 'complete_note_screen.dart';

class HomeNoteScreen extends StatefulWidget {
  const HomeNoteScreen({super.key});

  @override
  State<HomeNoteScreen> createState() => _HomeNoteScreenState();
}

class _HomeNoteScreenState extends State<HomeNoteScreen> {
  bool isLongPressed = false;
  int? selectedNOteId;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  final AppDatabase db = AppDatabase();
  Note? selectedNote;
  String searchQuery = '';
  List<Note> notes = [];

  bool isLoading = true;

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() {
      isLoading = true;
    });

    final allNotes = await db.getAllNotes();

    setState(() {
      notes = allNotes;
      isLoading = false;
    });
  }

  Future<void> _saveNote() async {
    final title = titleController.text.trim();
    final content = contentController.text.trim();
    final now = DateTime.now();
    final day = DateFormat('EEEE').format(now);
    final date = DateFormat('dd MMM yyyy').format(now);

    if (title.isEmpty || content.isEmpty) return;

    if (selectedNote == null) {
      await db.insertNote(
        NotesCompanion.insert(
          title: title,
          content: content,
          day: day,
          date: date,
        ),
      );
    } else {
      await db.updateNote(selectedNote!.id, title, content, day, date);
      selectedNote = null;
    }

    await _loadNotes();
    titleController.clear();
    contentController.clear();
  }

  void openNoteDialog({Note? note}) {
    if (note != null) {
      selectedNote = note;
      titleController.text = note.title;
      contentController.text = note.content;
    } else {
      selectedNote = null;
      titleController.clear();
      contentController.clear();
    }

    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text(
            selectedNote == null ? "Add Note" : "Update Note",
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: themeProvider.primaryColor,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  label: const Text("Title"),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: themeProvider.primaryColor,
                      width: 2.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: contentController,
                cursorColor: themeProvider.primaryColor,
                keyboardType: TextInputType.multiline,
                textAlignVertical: TextAlignVertical.top,
                maxLines: 5,
                decoration: InputDecoration(
                  filled: true,
                  alignLabelWithHint: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(10),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: themeProvider.primaryColor,
                      width: 2.0,
                    ),
                  ),
                  label: const Text("Content"),
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    titleController.clear();
                    contentController.clear();
                    selectedNote = null;
                    Navigator.pop(context);
                  },
                  child: _circleButton(Icons.delete_outline, Colors.redAccent),
                ),
                GestureDetector(
                  onTap: () async {
                    await _saveNote();
                    Navigator.pop(context);
                  },
                  child: _circleButton(Icons.save_outlined, Colors.blueGrey),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _circleButton(IconData icon, Color color) {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade400,
            blurRadius: 3,
            offset: const Offset(-2, -2),
          ),
          const BoxShadow(
            color: Colors.white,
            blurRadius: 3,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Icon(icon, color: color, size: 30),
    );
  }

  Widget noteCard(Note note) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Card(
      shadowColor: themeProvider.primaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

      color: Colors.white,
      elevation: 3,
      child: InkWell(
        onTap: () {
          if (selectedNOteId != null) {
            setState(() {
              selectedNOteId = null;
            });
          } else {
            openNoteDialog(note: note);
          }
        },

        onLongPress: () {
          setState(() {
            selectedNOteId = note.id;
          });
        },

        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + Day
              Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          note.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: themeProvider.primaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      selectedNOteId == note.id
                          ? Icon(
                        Icons.check_circle,
                        color: themeProvider.primaryColor == Colors.red
                            ? Colors.blue
                            : Colors.grey,
                        size: 25,
                      )
                          : Text(
                        note.day,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    note.content,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Bottom row (Date + Delete)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    note.date,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () async {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            title: Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.red,
                                  size: 26,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Delete Note",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            content: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                                children: [
                                  const TextSpan(
                                    text: "Are you sure you want to delete ",
                                  ),
                                  TextSpan(
                                    text: note.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: themeProvider.primaryColor,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: "?\nThis action cannot be undone.",
                                  ),
                                ],
                              ),
                            ),
                            actionsPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            actions: [
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: themeProvider.primaryColor,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(
                                    color: themeProvider.primaryColor,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () async {
                                  await db.deleteNoteById(note.id);
                                  await _loadNotes();
                                  Navigator.of(context).pop();
                                },
                                child: const Text(
                                  "Delete",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final filteredNotes = notes.where((note) {
      final titleLower = note.title.toLowerCase();
      return titleLower.contains(searchQuery);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Notes App",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        backgroundColor: themeProvider.primaryColor,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.black, size: 30),
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(color: themeProvider.primaryColor, width: 1),
              ),
              color: Colors.white,
              onSelected: (value) {
                if (value == 'settings') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SettingsScreen()),
                  ).then((result) {
                    if (result == true) {
                      _loadNotes();
                    }
                  });
                } else {}
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings, color: themeProvider.primaryColor),
                      const SizedBox(width: 10),
                      const Text("Settings"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: themeProvider.primaryColor,
        onPressed: () => openNoteDialog(),
        child: const Icon(Icons.add, size: 30, color: Colors.black),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // TextField
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: selectedNOteId != null ? 250 : null,
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value.toLowerCase();
                        });
                      },
                      decoration: InputDecoration(
                        hint: Text(
                          "Search...",
                          style: TextStyle(color: themeProvider.primaryColor),
                        ),
                        suffixIcon: Icon(
                          Icons.search,
                          color: themeProvider.primaryColor,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: themeProvider.primaryColor,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: themeProvider.primaryColor,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                Row(
                  children: [
                    const SizedBox(width: 8),

                    if (selectedNOteId != null) ...[
                      // 1. Copy Icon
                      IconButton(
                        icon: Icon(
                          Icons.copy,
                          color: themeProvider.primaryColor,
                        ),
                        onPressed: () {
                          final selectedNote = notes.firstWhere(
                                (n) => n.id == selectedNOteId,
                          );

                          final noteText =
                              "📒 ${selectedNote.title}\n\n"
                              "${selectedNote.content}";

                          Clipboard.setData(ClipboardData(text: noteText));

                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(const SnackBar(content: Text("Copy")));

                          setState(() {
                            selectedNOteId = null;
                          });
                        },
                      ),

                      // 2. View Icon
                      IconButton(
                        icon: Icon(
                          Icons.visibility,
                          color: themeProvider.primaryColor,
                        ),
                        onPressed: () {
                          final selectedNote = notes.firstWhere(
                                (n) => n.id == selectedNOteId,
                          );

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CompleteNoteScreen(note: selectedNote),
                            ),
                          );

                          setState(() {
                            selectedNOteId = null;
                          });
                        },
                      ),

                      // 3. Share Icon
                      IconButton(
                        icon: Icon(
                          Icons.share,
                          color: themeProvider.primaryColor,
                        ),
                        onPressed: () {
                          final selectedNote = notes.firstWhere(
                                (n) => n.id == selectedNOteId,
                          );

                          final noteText =
                              "📒 ${selectedNote.title}\n\n"
                              "${selectedNote.content}\n\n"
                              "🗓️ ${selectedNote.date}\n\n"
                              "— Sent from Notes App 📱";

                          Share.share(noteText, subject: selectedNote.title);

                          setState(() {
                            selectedNOteId = null;
                          });
                        },
                      ),
                    ],
                  ],
                ),

                /* IconButton(
                    icon: Icon(Icons.share, color: themeProvider.primaryColor),
                    onPressed: () {
                      final selectedNote = notes.firstWhere(
                        (n) => n.id == selectedNOteId,
                      );

                      if (selectedNote != null) {
                        final noteText =
                            "📒 ${selectedNote.title}\n\n"
                            "${selectedNote.content}\n\n"
                            "🗓️ ${selectedNote.date}\n\n"
                            "— Sent from Notes App 📱";

                        Share.share(noteText, subject: selectedNote.title);

                        setState(() {
                          selectedNOteId = null; // reset after sharing
                        });
                      }
                    },
                  ),*/
              ],
            ),

            const SizedBox(height: 10),
            Expanded(
              child: isLoading
                  ? const Center(
                child: CircularProgressIndicator(),
              ) // show loader
                  : notes.isEmpty
                  ? Center(
                child: Text(
                  "No notes found",
                  style: TextStyle(
                    fontSize: 18,
                    color: themeProvider.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
                  : GridView.builder(
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 3 / 4,
                ),
                itemCount: filteredNotes.length,
                itemBuilder: (context, index) =>
                    noteCard(filteredNotes[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
