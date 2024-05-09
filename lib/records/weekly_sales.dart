import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:LuckyEgg/color_provider.dart';

class WeeklySalesPage extends StatefulWidget {
  const WeeklySalesPage({Key? key}) : super(key: key);

  @override
  _WeeklyExpensesPageState createState() => _WeeklyExpensesPageState();
}

class _WeeklyExpensesPageState extends State<WeeklySalesPage> {
  late List<List<List<String>>> weeklySalesList =
      []; // Initialize weeklySalesList
  int? editingTableIndex;
  int? editingRowIndex;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final Color selectedColor =
        Provider.of<ColorProvider>(context).selectedColor;
    final bool isDarkBackground = selectedColor.computeLuminance() < 0.5;
    final Color textColor = isDarkBackground ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        centerTitle: true,
        title: const Text('Weekly sales Records'),
      ),
      backgroundColor: selectedColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Weekly sales Tables',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: weeklySalesList.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      _buildDataTable(weeklySalesList[index], textColor, index),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _showDeleteConfirmationDialog(index);
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _addTable,
              child: const Text('Add Table'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable(
      List<List<String>> weeklySales, Color textColor, int tableIndex) {
    double totalAmount = _calculateTotalAmount(weeklySales);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text('Day', style: TextStyle(color: textColor))),
          DataColumn(label: Text('Date', style: TextStyle(color: textColor))),
          DataColumn(
              label: Text('Quantity', style: TextStyle(color: textColor))),
          DataColumn(label: Text('Amount', style: TextStyle(color: textColor))),
          DataColumn(
              label: Text('Actions', style: TextStyle(color: textColor))),
        ],
        rows: [
          ...weeklySales.asMap().entries.map(
                (entry) => DataRow(
                  cells: [
                    DataCell(Text(_getDayName(entry.key),
                        style: TextStyle(color: textColor))),
                    DataCell(
                      _buildEditableCell(
                          editingTableIndex == tableIndex &&
                              editingRowIndex == entry.key,
                          entry.value[1], (value) {
                        setState(() {
                          weeklySales[entry.key][1] = value;
                        });
                      }, textColor),
                    ),
                    DataCell(
                      _buildEditableCell(
                          editingTableIndex == tableIndex &&
                              editingRowIndex == entry.key,
                          entry.value[2], (value) {
                        setState(() {
                          weeklySales[entry.key][2] = value;
                        });
                      }, textColor),
                    ),
                    DataCell(
                      _buildEditableCell(
                          editingTableIndex == tableIndex &&
                              editingRowIndex == entry.key,
                          entry.value[3], (value) {
                        setState(() {
                          weeklySales[entry.key][3] = value;
                        });
                      }, textColor),
                    ),
                    DataCell(
                      Row(
                        children: [
                          if (editingRowIndex != entry.key)
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _editRow(tableIndex, entry.key);
                              },
                            ),
                          if (editingRowIndex == entry.key)
                            IconButton(
                              icon: const Icon(Icons.save),
                              onPressed: () async {
                                bool saved =
                                    await _saveRow(tableIndex, entry.key);
                                if (saved) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Saved')),
                                  );
                                }
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          DataRow(
            cells: [
              DataCell(Text('Total',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: textColor))),
              DataCell(Text('')),
              DataCell(Text('')),
              DataCell(Text(totalAmount.toStringAsFixed(2),
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: textColor))),
              DataCell(Text('')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditableCell(
      bool enabled, String value, Function(String) onChanged, Color textColor) {
    return enabled
        ? TextField(
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: value,
              border: InputBorder.none,
              hintStyle: TextStyle(color: textColor),
            ),
            style: TextStyle(color: textColor),
          )
        : Text(value, style: TextStyle(color: textColor));
  }

  String _getDayName(int index) {
    final days = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ];
    return days[index];
  }

  void _addTable() {
    setState(() {
      weeklySalesList.add(_initializeWeeklySales());
    });
    _saveData(); // Save data when a new table is added
  }

  List<List<String>> _initializeWeeklySales() {
    List<List<String>> initialData = [];
    // Add initial row for each day of the week
    for (int i = 0; i < 7; i++) {
      initialData.add(['', '', '', '']);
    }
    return initialData;
  }

  void _editRow(int tableIndex, int rowIndex) {
    setState(() {
      editingTableIndex = tableIndex;
      editingRowIndex = rowIndex;
    });
  }

  Future<bool> _saveRow(int tableIndex, int rowIndex) async {
    setState(() {
      editingTableIndex = null;
      editingRowIndex = null;
    });
    return await _saveData(); // Save data when a row is saved
  }

  Future<bool> _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int numberOfTables = weeklySalesList.length;
    await prefs.setInt(
        'numberOfTables', numberOfTables); // Save number of tables
    for (int i = 0; i < numberOfTables; i++) {
      List<String> dataToSave =
          weeklySalesList[i].map((row) => row.join(',')).toList();
      await prefs.setStringList('weeklySales$i', dataToSave);
    }
    return true;
  }

  void _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int numberOfTables = prefs.getInt('numberOfTables') ?? 0;
    List<List<List<String>>> loadedData = [];
    for (int i = 0; i < numberOfTables; i++) {
      List<String>? savedData = prefs.getStringList('weeklySales$i');
      if (savedData != null) {
        loadedData.add(savedData.map((row) => row.split(',')).toList());
      }
    }
    if (loadedData.isNotEmpty) {
      setState(() {
        weeklySalesList = loadedData;
      });
    } else {
      setState(() {
        weeklySalesList = [_initializeWeeklySales()];
      });
    }
  }

  void _showDeleteConfirmationDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Table'),
          content: Text('Are you sure you want to delete this table?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    ).then((confirmed) {
      if (confirmed != null && confirmed) {
        _deleteTable(index);
      }
    });
  }

  void _deleteTable(int index) {
    setState(() {
      weeklySalesList.removeAt(index);
    });
    _saveData(); // Save data when a table is deleted
  }

  double _calculateTotalAmount(List<List<String>> weeklySales) {
    return weeklySales.fold<double>(
        0,
        (total, entry) =>
            total +
            (double.tryParse(entry[3]) ??
                0)); // This part attempts to parse the fourth element
  }
}

void main() {
  runApp(MaterialApp(
    home: ChangeNotifierProvider(
      create: (context) => ColorProvider(),
      child: WeeklySalesPage(),
    ),
    theme: ThemeData.light(),
    darkTheme: ThemeData.dark(),
    themeMode: ThemeMode.system,
  ));
}
