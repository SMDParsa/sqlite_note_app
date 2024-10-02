import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:note_app/helpers/sql_helper.dart';
import 'package:note_app/screens/fav_notes_screen.dart';
import 'package:note_app/screens/note_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main(List<String> args) {
  runApp(const NoteApp());
}

class NoteApp extends StatefulWidget {
  const NoteApp({super.key});

  @override
  State<NoteApp> createState() => _NoteAppState();
}

class _NoteAppState extends State<NoteApp> {
  bool _isDarkMode = false;

  Future<void> _loadThemePrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      _isDarkMode = prefs.getBool('is_darkmode') ?? false;
    });
  }

  Future<void> _toggleDarkMode(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_darkmode', value);

    setState(() {
      _isDarkMode = value;
    });
  }

  @override
  void initState() {
    super.initState();

    _loadThemePrefs();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: NotesScreen(
        toggleDarkMode: _toggleDarkMode,
        isDarkMode: _isDarkMode,
      ),
    );
  }
}

class NotesScreen extends StatefulWidget {
  bool? isDarkMode = false;
  final Function(bool) toggleDarkMode;

  NotesScreen({super.key, this.isDarkMode, required this.toggleDarkMode});

  @override
  State<NotesScreen> createState() =>
      _NotesScreenState(toggleDarkMode: toggleDarkMode);
}

class _NotesScreenState extends State<NotesScreen> {
  List<Map<String, dynamic>> _noteList = [];

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

  int selectedColor = 0;

  void _refreshNotes() async {
    final data = await SQLHelper.getNotes();
    setState(() {
      _noteList = data;
    });
  }

  String? _userName;
  bool _isDarkMode = false;
  Function(bool) toggleDarkMode;

  _NotesScreenState({required this.toggleDarkMode});

  Future<void> _loadThemePrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      _isDarkMode = prefs.getBool('is_darkmode') ?? false;
    });
  }

  Future<void> _toggleDarkMode(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_darkmode', value);

    setState(() {
      _isDarkMode = value;
    });
  }

  Future<void> _getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('user_name')) {
      setState(() {
        _userName = prefs.getString('user_name') ?? "Please Login";
      });
    } else {
      setState(() {
        _userName = "Please Login";
      });
    }
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  double textSize = 12;

  String? titleEmptyErrorText;

  Future<void> _addNote(int color) async {
    await SQLHelper.createNote(
        _titleController.text, _descriptionController.text, color);
    _refreshNotes();
  }

  Future<void> _updateNote(int id, int color) async {
    await SQLHelper.updateNote(
        id, _titleController.text, _descriptionController.text, color);
    _refreshNotes();
  }

  Future<void> _deleteNote(int id) async {
    await SQLHelper.deleteNote(id);
    _refreshNotes();
  }

  Future<void> _addRemFav(int id, int favorite) async {
    await SQLHelper.addRemoveFavorite(id, favorite);
    _refreshNotes();
  }

  _showForm(int? id) async {
    if (id != null) {
      final existingNote =
          _noteList.firstWhere((element) => element['id'] == id);
      _titleController.text = existingNote['title'];
      _descriptionController.text = existingNote['description'];
    } else {
      _titleController.text = '';
      _descriptionController.text = '';
    }

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
                      maxLines: 2,
                      minLines: 1,
                      keyboardType: TextInputType.multiline,
                      decoration:
                          const InputDecoration(label: Text('Description')),
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

                                if (id == null) {
                                  await _addNote(selectedColor);
                                }
                                if (id != null) {
                                  await _updateNote(id, selectedColor);
                                }

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
                            child: Text(
                                id == null ? 'Create New Note' : 'Update')),
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
  void initState() {
    super.initState();
    _getUserInfo();
    _loadThemePrefs();

    _refreshNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 10,
          title: const Text('Note App'),
          actions: [
            IconButton(
                onPressed: () {
                  showSearch(
                    context: context,
                    delegate: CustomSearchDelegate(_noteList, textSize),
                  );
                },
                icon: const Icon(Icons.search))
          ],
        ),
        drawer: Drawer(
          child: Column(
            children: [
              SizedBox(
                  height: 150,
                  child: DrawerHeader(
                      child: Center(
                          child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _userName != null
                            ? _userName!.toUpperCase()
                            : 'Please login',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text('${_noteList.length} notes 😲')
                    ],
                  )))),
              SwitchListTile(
                  subtitle: const Text('Turn on or off night mode'),
                  title: const Text('Night Mode'),
                  value: _isDarkMode,
                  onChanged: (vale) {
                    setState(() {
                      toggleDarkMode(vale);
                      _isDarkMode = vale;
                    });
                  }),
              ListTile(
                title: const Text('Favorite Notes'),
                leading: const Icon(Icons.favorite),
                subtitle: const Text('Display list of favorite notes'),
                onTap: () async {
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              FavNotesScreen(textSize: textSize)));

                  setState(() {
                    _refreshNotes();
                  });
                },
              ),
              const Divider(),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      child: Text(
                        'Font Size: ${textSize.toInt()}',
                        style: TextStyle(
                            fontSize: textSize, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Slider(
                    min: 12,
                    max: 30,
                    value: textSize,
                    onChanged: (value) {
                      setState(() {
                        textSize = value;
                      });
                    },
                  ),
                ],
              )
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showForm(null),
          child: const Icon(Icons.add),
        ),
        body: _noteList.isEmpty
            ? const Center(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '😢',
                    style: TextStyle(fontSize: 40),
                  ),
                  Text(
                    textAlign: TextAlign.center,
                    'You did not make any note\nPlease make some!',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ],
              ))
            : MasonryGridView.count(
                crossAxisCount: textSize >= 25
                    ? 1
                    : textSize >= 15
                        ? 2
                        : textSize >= 12
                            ? 3
                            : 4,
                itemCount: _noteList.length,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                padding: const EdgeInsets.all(8),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NoteScreen(
                                  noteID: _noteList[index]['id'],
                                  textSize: textSize)));
                      setState(() {
                        _refreshNotes();
                      });
                    },
                    onLongPress: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            /*  backgroundColor: _isDarkMode
                              ? Color.fromRGBO(
                                  redDark, greenDark, blueDark, 1)
                              : Color.fromRGBO(
                                  redLight, greenLight, blueLight, 1), */
                            title: const Text('Delete Note'),
                            content: const Text(
                                'Are you sure you want to delete this note?'),
                            actions: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      _deleteNote(_noteList[index]['id']);
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Yes'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('No'),
                                  ),
                                ],
                              )
                            ],
                            icon: const Icon(Icons.delete),
                          );
                        },
                      );
                    },
                    child: Card(
                        color: _isDarkMode
                            ? _colorsDark[_noteList[index]['color']]
                            : _colorsLight[_noteList[index]['color']],
                        child: Container(
                            padding: const EdgeInsets.all(10),
                            child: Stack(children: [
                              Column(
                                children: [
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            _noteList[index]['title'],
                                            style: TextStyle(
                                                fontSize: textSize + 5,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        IconButton(
                                            onPressed: () {
                                              if (_noteList[index]
                                                      ['favorite'] ==
                                                  0) {
                                                _addRemFav(
                                                    _noteList[index]['id'], 1);
                                              } else {
                                                _addRemFav(
                                                    _noteList[index]['id'], 0);
                                              }
                                            },
                                            icon: Icon(
                                              _noteList[index]['favorite'] == 0
                                                  ? Icons.favorite_border
                                                  : Icons.favorite,
                                              size: 20,
                                            )),
                                      ]),
                                  const Divider(
                                    color: Colors.black38,
                                  ),
                                  SizedBox(
                                    width: double.infinity,
                                    child: Text(
                                      _noteList[index]['description'].length >
                                              100
                                          ? '${_noteList[index]['description'].substring(0, 100)}\n see more...'
                                          : _noteList[index]['description'],
                                      style: TextStyle(fontSize: textSize),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  SizedBox(
                                    width: double.infinity,
                                    child: Text(
                                      _noteList[index]['date'],
                                      style: TextStyle(
                                          color: _isDarkMode == true
                                              ? Colors.white.withOpacity(0.5)
                                              : Colors.black.withOpacity(0.5)),
                                    ),
                                  )
                                ],
                              ),
                            ]))),
                  );
                }));
  }
}

class CustomSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> noteList;
  final double textSize;
  CustomSearchDelegate(this.noteList, this.textSize);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = '';
          },
          icon: const Icon(Icons.clear))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          close(context, null);
        },
        icon: const Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    List<String> matchQuery = [];
    List<String> noteIds = [];

    for (int i = 0; i < noteList.length; i++) {
      if (noteList[i]['title'].toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(noteList[i]['title']);
        noteIds.add(noteList[i]['id'].toString());
      }

      if (noteList[i]['description']
          .toLowerCase()
          .contains(query.toLowerCase())) {
        matchQuery.add(noteList[i]['description']);
        noteIds.add(noteList[i]['id'].toString());
      }
    }

    return ListView.builder(
        itemCount: matchQuery.length,
        itemBuilder: (context, index) {
          var result = matchQuery[index];
          return ListTile(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => NoteScreen(
                    noteID: int.parse(noteIds[index]), textSize: textSize),
              ));
            },
            title: Text(result, style: TextStyle(fontSize: textSize)),
          );
        });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> matchQuery = [];

    List<String> noteIds = [];

    for (int i = 0; i < noteList.length; i++) {
      if (noteList[i]['title'].toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(noteList[i]['title']);
        noteIds.add(noteList[i]['id'].toString());
      }

      if (noteList[i]['description']
          .toLowerCase()
          .contains(query.toLowerCase())) {
        matchQuery.add(noteList[i]['description']);
        noteIds.add(noteList[i]['id'].toString());
      }
    }

    return ListView.builder(
        itemCount: matchQuery.length,
        itemBuilder: (context, index) {
          var result = matchQuery[index];

          return ListTile(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => NoteScreen(
                    noteID: int.parse(noteIds[index]), textSize: textSize),
              ));
            },
            title: Text(
              result,
              style: TextStyle(fontSize: textSize),
            ),
          );
        });
  }
}
