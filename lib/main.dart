import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'movie.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
      ),
      home: MovieList(),
    );
  }
}

class MovieList extends StatefulWidget {
  @override
  _MovieListState createState() => _MovieListState();
}

enum SortCriteria { alphabetically, id }

class _MovieListState extends State<MovieList> {
  List<MovieInfo> items = [];
  bool isLoading = true;
  final TextEditingController _controller = TextEditingController();
  SortCriteria _sortCriteria = SortCriteria.alphabetically;

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    try {
      final response = await http.get(Uri.parse('https://freetestapi.com/api/v1/movies'));

      if (response.statusCode == 200) {
        final List<dynamic> itemJson = json.decode(response.body);
        setState(() {
          items = itemJson.map((json) => MovieInfo.fromJson(json)).toList();
          isLoading = false;
          _sortItems();
        });
      } else {
        throw Exception('Failed to load items');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to load items: $e'),
      ));
    }
  }

  void _addItem() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        int newId = (items.isNotEmpty) ? items.map((item) => item.id).reduce((a, b) => a > b ? a : b) + 1 : 1;
        items.add(MovieInfo(name: text, id: newId));
        _controller.clear();
        _sortItems();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please enter a valid item name.'),
      ));
    }
  }

  void _removeItem(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this item?'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  items.removeAt(index);
                  _sortItems();
                });
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _sortItems() {
    setState(() {
      if (_sortCriteria == SortCriteria.alphabetically) {
        items.sort((a, b) => a.name.compareTo(b.name));
      } else {
        items.sort((a, b) => a.id.compareTo(b.id));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Flutter App'),
        backgroundColor: Colors.yellow,
        elevation: 4.0,
        toolbarHeight: 80.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30.0)),
        ),
        actions: [
          DropdownButton<SortCriteria>(
            value: _sortCriteria,
            icon: Icon(Icons.sort),
            onChanged: (SortCriteria? newValue) {
              setState(() {
                _sortCriteria = newValue!;
                _sortItems();
              });
            },
            items: [
              DropdownMenuItem(
                value: SortCriteria.alphabetically,
                child: Text('Sort Alphabetically'),
              ),
              DropdownMenuItem(
                value: SortCriteria.id,
                child: Text('Sort by ID'),
              ),
            ],
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(8.0),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.only(bottom: 10.0),
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.yellow[100],
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: ListTile(
                    title: Text(items[index].name),
                    trailing: CircleAvatar(
                      backgroundColor: Colors.red[200],
                      child: IconButton(
                        icon: Icon(Icons.delete, color: Colors.black),
                        onPressed: () => _removeItem(index),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Add a new item',
                    ),
                  ),
                ),
                CircleAvatar(
                  backgroundColor: Colors.green[200],
                  child: IconButton(
                    icon: Icon(Icons.add, color: Colors.black),
                    onPressed: _addItem,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
