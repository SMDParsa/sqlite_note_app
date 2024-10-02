import 'package:flutter/material.dart';
import 'package:note_app/helpers/sql_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoteScreen extends StatefulWidget {
  int noteID;
  double textSize;
  NoteScreen({super.key, required this.noteID, required this.textSize});

  @override
  State<NoteScreen> createState() => _NoteScreenState(noteID, textSize);
}

class _NoteScreenState extends State<NoteScreen> {
  int noteID;
  double textSize;
  _NoteScreenState(this.noteID, this.textSize);

  final List<Color> _colorsLight = [
    const Color.fromRGBO(250, 227, 227, 1),
    const Color.fromRGBO(222, 255, 232, 1),
    const Color.fromRGBO(229, 223, 255, 1)
  ];

  final List<Color> _colorsDark = [
    const Color.fromRGBO(37, 16, 16, 1),
    const Color.fromRGBO(15, 46, 19, 1),
    const Color.fromRGBO(14, 11, 43, 1)
  ];

  List<Map<String, dynamic>> noteItem = [];

  bool _isDarkMode = false;

  void _getNote() async {
    final data = await SQLHelper.getNoteById(noteID);
    setState(() {
      noteItem = data;
    });
  }

  Future<void> _loadThemePrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      _isDarkMode = prefs.getBool('is_darkmode') ?? false;
    });
  }

  Future<void> _updateNote(int id, int color) async {
    await SQLHelper.updateNote(
        id, _titleController.text, _descriptionController.text, color);
    _getNote();
  }

  Future<void> _deleteNote(int id) async {
    await SQLHelper.deleteNote(id);
    Navigator.of(context).pop();
  }

  Future<void> _addRemFav(int id, int favorite) async {
    await SQLHelper.addRemoveFavorite(id, favorite);
    _getNote();
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  int selectedColor = 0;

  String? titleEmptyErrorText;

  @override
  void initState() {
    super.initState();
    _loadThemePrefs();
    _getNote();
  }

  _showForm(int id) async {
    _titleController.text = noteItem.isNotEmpty ? noteItem[0]['title'] : '';
    _descriptionController.text =
        noteItem.isNotEmpty ? noteItem[0]['description'] : '';

    showDialog(
        context: context,
        builder: (context) => StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                title: Text(id == null ? 'New Note' : 'Update Note'),
                content: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                          label: const Text('Title'),
                          errorText: titleEmptyErrorText),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: _descriptionController,
                      keyboardType: TextInputType.multiline,
                      minLines: 1,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        label: Text('Description'),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedColor = 0;
                            });
                          },
                          child: Container(
                            height: 30,
                            width: 30,
                            padding: const EdgeInsets.all(2),
                            color: _isDarkMode ? Colors.black : Colors.white,
                            child: Container(
                              color: _isDarkMode
                                  ? _colorsDark[0]
                                  : _colorsLight[0],
                              child: selectedColor == 0
                                  ? const Icon(Icons.check)
                                  : null,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedColor = 1;
                            });
                          },
                          child: Container(
                            height: 30,
                            width: 30,
                            padding: const EdgeInsets.all(2),
                            color: _isDarkMode ? Colors.black : Colors.white,
                            child: Container(
                              color: _isDarkMode
                                  ? _colorsDark[1]
                                  : _colorsLight[1],
                              child: selectedColor == 1
                                  ? const Icon(Icons.check)
                                  : null,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedColor = 2;
                            });
                          },
                          child: Container(
                            height: 30,
                            width: 30,
                            padding: const EdgeInsets.all(2),
                            color: _isDarkMode ? Colors.black : Colors.white,
                            child: Container(
                              color: _isDarkMode
                                  ? _colorsDark[2]
                                  : _colorsLight[2],
                              child: selectedColor == 2
                                  ? const Icon(Icons.check)
                                  : null,
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        ElevatedButton(
                            onPressed: () async {
                              if (_titleController.text.isNotEmpty) {
                                setState(() {
                                  titleEmptyErrorText = null;
                                });

                                await _updateNote(id, selectedColor);

                                _titleController.text = '';
                                _descriptionController.text = '';

                                Navigator.of(context).pop();
                              } else {
                                setState(() {
                                  titleEmptyErrorText =
                                      'At least title is required!';
                                });
                              }
                            },
                            child: const Text('Update')),
                        id != null
                            ? IconButton(
                                onPressed: () async {
                                  await _deleteNote(id);
                                  Navigator.of(context).pop();
                                },
                                icon: const Icon(Icons.delete))
                            : const Icon(null),
                        /* DropdownMenu(
                        initialSelection: 0,
                        onSelected: (value) {
                          setState(() {
                            selectedColor = value!;
                          });
                        },
                        dropdownMenuEntries: const [
                          DropdownMenuEntry(value: 0, label: "Red"),
                          DropdownMenuEntry(value: 1, label: "Green"),
                          DropdownMenuEntry(value: 2, label: "Blue"),
                        ],
                      ) */
                      ],
                    )
                  ],
                ),
              );
            }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: _isDarkMode
              ? _colorsDark[noteItem.isNotEmpty ? noteItem[0]['color'] : 0]
              : _colorsLight[noteItem.isNotEmpty ? noteItem[0]['color'] : 0],
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                noteItem.isNotEmpty ? noteItem[0]['title'] : 'Loading...',
                style: TextStyle(
                    fontSize: textSize + 5, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  IconButton(
                      onPressed: () => _showForm(noteID),
                      icon: const Icon(Icons.edit)),
                  IconButton(
                      onPressed: () {
                        if (noteItem.isNotEmpty
                            ? noteItem[0]['favorite'] == 0
                            : false) {
                          _addRemFav(noteID, 1);
                        } else {
                          _addRemFav(noteID, 0);
                        }
                      },
                      icon: Icon(noteItem.isNotEmpty
                          ? noteItem[0]['favorite'] == 0
                              ? Icons.favorite_border
                              : Icons.favorite
                          : null)),
                ],
              )
            ],
          )),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: _isDarkMode
            ? _colorsDark[noteItem.isNotEmpty ? noteItem[0]['color'] : 0]
            : _colorsLight[noteItem.isNotEmpty ? noteItem[0]['color'] : 0],
        padding: const EdgeInsets.all(15),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Text(
                noteItem.isNotEmpty
                    ? noteItem[0]['description']
                    : 'Loading Note...',
                style: TextStyle(fontSize: textSize),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
