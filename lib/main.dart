import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Listas App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> lists = [];

  @override
  void initState() {
    super.initState();
    _loadLists();
  }

  _loadLists() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedLists = prefs.getString('lists');
    if (storedLists != null) {
      setState(() {
        lists = List<String>.from(json.decode(storedLists));
      });
    }
  }

  _saveLists() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('lists', json.encode(lists));
  }

  _addList() {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Agregar una nueva lista'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Nombre'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar',
                  style: TextStyle(color: Colors.pink.shade200)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Agregar', style: TextStyle(color: Colors.pink)),
              onPressed: () {
                setState(() {
                  lists.add(controller.text);
                  _saveLists();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _editList(int index) {
    TextEditingController controller = TextEditingController();
    controller.text = lists[index];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar Lista'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Nombre'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar',
                  style: TextStyle(color: Colors.pink.shade200)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Guardar', style: TextStyle(color: Colors.pink)),
              onPressed: () {
                setState(() {
                  lists[index] = controller.text;
                  _saveLists();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _deleteList(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar lista'),
          content: Text('¿Estás seguro de eliminar esta lista?'),
          actions: <Widget>[
            TextButton(
              child: Text('No', style: TextStyle(color: Colors.pink.shade200)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Sí', style: TextStyle(color: Colors.pink)),
              onPressed: () {
                setState(() {
                  lists.removeAt(index);
                  _saveLists();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _reorderList(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final String item = lists.removeAt(oldIndex);
      lists.insert(newIndex, item);
      _saveLists();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Listas :P', style: TextStyle(color: Colors.pink)),
        backgroundColor: Colors.purple.shade100,
      ),
      body: ReorderableListView(
        onReorder: _reorderList,
        children: [
          for (int index = 0; index < lists.length; index++)
            Dismissible(
              key: Key(lists[index]),
              onDismissed: (direction) {
                _deleteList(index);
              },
              confirmDismiss: (direction) async {
                return await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Eliminar elemento'),
                      content: Text('¿Estás seguro de eliminar esta lista?'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('No',
                              style: TextStyle(color: Colors.pink.shade200)),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                        ),
                        TextButton(
                          child:
                              Text('Sí', style: TextStyle(color: Colors.pink)),
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              background: Container(
                color: Colors.pink.shade800,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: 16.0),
                    child: Icon(Icons.delete, color: Colors.pink.shade300),
                  ),
                ),
              ),
              child: ListTile(
                title: Text(lists[index]),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SublistPage(listName: lists[index], allLists: lists),
                    ),
                  );
                },
                trailing: IconButton(
                  icon: Icon(Icons.edit, color: Colors.pink),
                  onPressed: () {
                    _editList(index);
                  },
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addList,
        tooltip: 'Agregar Lista',
        backgroundColor: Colors.pink,
        child: Icon(Icons.add),
      ),
    );
  }
}

class SublistPage extends StatefulWidget {
  final String listName;
  final List<String> allLists;

  SublistPage({required this.listName, required this.allLists});

  @override
  _SublistPageState createState() => _SublistPageState();
}

class _SublistPageState extends State<SublistPage> {
  List<String> sublist = [];

  @override
  void initState() {
    super.initState();
    _loadSublist();
  }

  _loadSublist() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedSublist = prefs.getString(widget.listName);
    if (storedSublist != null) {
      setState(() {
        sublist = List<String>.from(json.decode(storedSublist));
      });
    }
  }

  _saveSublist() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(widget.listName, json.encode(sublist));
  }

  _addSublistItem() {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Agregar Elemento'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Nombre'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar',
                  style: TextStyle(color: Colors.pink.shade200)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Agregar', style: TextStyle(color: Colors.pink)),
              onPressed: () {
                setState(() {
                  sublist.add(controller.text);
                  _saveSublist();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _editSublistItem(int index) {
    TextEditingController controller = TextEditingController();
    controller.text = sublist[index];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar Elemento'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Nombre del Elemento'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Guardar', style: TextStyle(color: Colors.pink)),
              onPressed: () {
                setState(() {
                  sublist[index] = controller.text;
                  _saveSublist();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _deleteSublistItem(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Eliminación'),
          content: Text('¿Estás seguro de eliminar este elemento?'),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Sí',
                  style: TextStyle(color: Colors.pink)), // Botón de color rosa
              onPressed: () {
                setState(() {
                  sublist.removeAt(index);
                  _saveSublist();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _reorderSublist(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final String item = sublist.removeAt(oldIndex);
      sublist.insert(newIndex, item);
      _saveSublist();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listName, style: TextStyle(color: Colors.pink)),
        backgroundColor: Colors.purple.shade100, // Título de color rosa
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Listas', style: TextStyle(color: Colors.white)),
              decoration: BoxDecoration(
                color: Colors.pink,
              ),
            ),
            ListTile(
              title: Text('Inicio'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(),
                  ),
                );
              },
            ),
            for (final list in widget.allLists)
              ListTile(
                title: Text(list),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SublistPage(
                          listName: list, allLists: widget.allLists),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
      body: ReorderableListView(
        onReorder: _reorderSublist,
        children: [
          for (int index = 0; index < sublist.length; index++)
            Dismissible(
              key: Key(sublist[index]),
              onDismissed: (direction) {
                _deleteSublistItem(index);
              },
              confirmDismiss: (direction) async {
                return await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Confirmar Eliminación'),
                      content: Text('¿Estás seguro de eliminar este elemento?'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('No'),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                        ),
                        TextButton(
                          child:
                              Text('Sí', style: TextStyle(color: Colors.pink)),
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              background: Container(
                color: Colors.pink.shade800,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: Icon(Icons.delete, color: Colors.pink.shade300),
                  ),
                ),
              ),
              child: ListTile(
                title: Text(sublist[index]),
                trailing: IconButton(
                  icon: Icon(Icons.edit, color: Colors.pink),
                  onPressed: () {
                    _editSublistItem(index);
                  },
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSublistItem,
        tooltip: 'Agregar Elemento',
        backgroundColor: Colors.pink,
        child: Icon(Icons.add),
      ),
    );
  }
}
