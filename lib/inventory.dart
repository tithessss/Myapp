import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({Key? key}) : super(key: key);

  @override
  _InventoryPageState createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  late List<Map<String, dynamic>> _inventoryList = [];
  final TextEditingController _feedNameController = TextEditingController();
  final TextEditingController _sackController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadInventory();
  }

  Future<void> _loadInventory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? inventoryData = prefs.getStringList('inventory');
    if (inventoryData != null) {
      setState(() {
        _inventoryList = inventoryData
            .map((item) => json.decode(item))
            .cast<Map<String, dynamic>>()
            .toList();
      });
    }
  }

  Future<void> _saveInventory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> encodedList =
        _inventoryList.map((item) => json.encode(item)).toList();
    await prefs.setStringList('inventory', encodedList);
  }

  void _addInventoryItem() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Inventory Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _feedNameController,
                decoration: InputDecoration(labelText: 'Feed Name'),
              ),
              TextField(
                controller: _sackController,
                decoration: InputDecoration(labelText: 'Number of Sacks'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _durationController,
                decoration: InputDecoration(labelText: 'Duration (days)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final String feedName = _feedNameController.text;
                final int sacks = int.tryParse(_sackController.text) ?? 0;
                final int duration =
                    int.tryParse(_durationController.text) ?? 0;
                if (feedName.isNotEmpty && sacks > 0 && duration > 0) {
                  setState(() {
                    _inventoryList.add({
                      'name': feedName,
                      'sacks': sacks,
                      'duration': duration,
                    });
                  });
                  _saveInventory();
                  _clearInputFields();
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter valid input')),
                  );
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _clearInputFields() {
    _feedNameController.clear();
    _sackController.clear();
    _durationController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inventory'),
        backgroundColor: Colors.grey,
      ),
      body: Container(
        color: Colors.white,
        child: ListView.builder(
          itemCount: _inventoryList.length,
          itemBuilder: (context, index) {
            final item = _inventoryList[index];
            return ListTile(
              title: Text(item['name']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sacks: ${item['sacks']}'),
                  Text('Duration: ${item['duration']}'),
                ],
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => _deleteInventoryItem(index),
                color: Colors.red,
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addInventoryItem,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _deleteInventoryItem(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Inventory Item'),
          content: Text('Are you sure you want to delete this item?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _inventoryList.removeAt(index);
                });
                _saveInventory();
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
