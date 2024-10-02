import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:note_app/helpers/sql_helper.dart';
import 'package:note_app/screens/note_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavNotesScreen extends StatefulWidget {
  double textSize;
  FavNotesScreen({
    super.key,
    required this.textSize,
  });

  @override
  State<FavNotesScreen> createState() =>
      _FavNotesScreenState(textSize: textSize);
}

class _FavNotesScreenState extends State<FavNotesScreen> {
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
    final data = await SQLHelper.getFavorites();
    setState(() {
      _noteList = data;
    });
  }

  void _refreshFavNotes(String text) async {
    final data = await SQLHelper.getNote(text);
    setState(() {
      _noteList = data;
    });
  }

  bool _isDarkMode = false;

  Future<void> _loadThemePrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      _isDarkMode = prefs.getBool('is_darkmode') ?? false;
    });
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  String searchValue = '';

  bool searchVisible = false;

  bool titleVisible = true;
  double textSize;
  _FavNotesScreenState({required this.textSize});

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
                      decoration: const InputDecoration(label: Text('Title')),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: _descriptionController,
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
                              if (id == null) {
                                await _addNote(selectedColor);
                              }
                              if (id != null) {
                                await _updateNote(id, selectedColor);
                              }

                              _titleController.text = '';
                              _descriptionController.text = '';

                              Navigator.of(context).pop();
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
    _loadThemePrefs();

    if (searchValue.isEmpty) {
      _refreshNotes();
    } else {
      _refreshFavNotes(searchValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 10,
          title: const Text('Favorites'),
          actions: [
            IconButton(
                onPressed: () {
                  setState(() {
                    showSearch(
                      context: context,
                      delegate: CustomSearchDelegate(_noteList, textSize),
                    );
                  });
                },
                icon: const Icon(Icons.search))
          ],
        ),
        body: _noteList.isEmpty
            ? const Center(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '😂',
                    style: TextStyle(fontSize: 40),
                  ),
                  Text(
                    textAlign: TextAlign.center,
                    'You don\'t have any favorite note!\nPlease add some notes into favorite!',
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
                      /* _showForm(_noteList[index]['id']); */
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NoteScreen(
                                    noteID: _noteList[index]['id'],
                                    textSize: textSize,
                                  )));
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
                                    onPressed: () async {
                                      await _deleteNote(_noteList[index]['id']);
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
