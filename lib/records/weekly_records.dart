import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:LuckyEgg/color_provider.dart';

class WeeklyExpensesPage extends StatefulWidget {
  const WeeklyExpensesPage({Key? key}) : super(key: key);

  @override
  _WeeklyExpensesPageState createState() => _WeeklyExpensesPageState();
}

class _WeeklyExpensesPageState extends State<WeeklyExpensesPage> {
  // Declare the list of weekly expenses.
  late List<List<List<String>>> weeklyExpensesList = [];
  int? editingTableIndex;
  int? editingRowIndex;

  @override
  void initState() {
    super.initState();
    // Load data from SharedPreferences when the widget initializes.
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    // Get the selected color from the ColorProvider using Provider.of.
    final Color selectedColor =
        Provider.of<ColorProvider>(context).selectedColor;
    // Check if the background color is dark or light to determine text color.
    final bool isDarkBackground = selectedColor.computeLuminance() < 0.5;
    final Color textColor = isDarkBackground ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        centerTitle: true,
        title: const Text('Weekly Expenses Records'),
      ),
      backgroundColor: selectedColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Weekly Expenses Tables',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: weeklyExpensesList.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      _buildDataTable(
                          weeklyExpensesList[index], textColor, index),
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

  // Widget to build the DataTable for weekly expenses.
  Widget _buildDataTable(
      List<List<String>> weeklyExpenses, Color textColor, int tableIndex) {
    double totalCost = _calculateTotalCost(weeklyExpenses);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text('Day', style: TextStyle(color: textColor))),
          DataColumn(label: Text('Date', style: TextStyle(color: textColor))),
          DataColumn(label: Text('Reason', style: TextStyle(color: textColor))),
          DataColumn(label: Text('Cost', style: TextStyle(color: textColor))),
          DataColumn(
              label: Text('Actions', style: TextStyle(color: textColor))),
        ],
        rows: [
          ...weeklyExpenses.asMap().entries.map(
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
                          weeklyExpenses[entry.key][1] = value;
                        });
                      }, textColor),
                    ),
                    DataCell(
                      _buildEditableCell(
                          editingTableIndex == tableIndex &&
                              editingRowIndex == entry.key,
                          entry.value[2], (value) {
                        setState(() {
                          weeklyExpenses[entry.key][2] = value;
                        });
                      }, textColor),
                    ),
                    DataCell(
                      _buildEditableCell(
                          editingTableIndex == tableIndex &&
                              editingRowIndex == entry.key,
                          entry.value[3], (value) {
                        setState(() {
                          weeklyExpenses[entry.key][3] = value;
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
              DataCell(Text(totalCost.toStringAsFixed(2),
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: textColor))),
              DataCell(Text('')),
            ],
          ),
        ],
      ),
    );
  }

  // Widget to build an editable cell in the DataTable.
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

  // Function to get the day name from the index.
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

  // Function to add a new table of weekly expenses.
  void _addTable() {
    setState(() {
      weeklyExpensesList.add(_initializeWeeklyExpenses());
    });
    _saveData(); // Save data when a new table is added
  }

  // Function to initialize a new table of weekly expenses.
  List<List<String>> _initializeWeeklyExpenses() {
    List<List<String>> initialData = [];
    // Add initial row for each day of the week
    for (int i = 0; i < 7; i++) {
      initialData.add(['', '', '', '']);
    }
    return initialData;
  }

  // Function to edit a row in the DataTable.
  void _editRow(int tableIndex, int rowIndex) {
    setState(() {
      editingTableIndex = tableIndex;
      editingRowIndex = rowIndex;
    });
  }

  // Function to save a row in the DataTable.
  Future<bool> _saveRow(int tableIndex, int rowIndex) async {
    setState(() {
      editingTableIndex = null;
      editingRowIndex = null;
    });
    return await _saveData(); // Save data when a row is saved
  }

  // Function to save all data to SharedPreferences.
  Future<bool> _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int numberOfTables = weeklyExpensesList.length;
    await prefs.setInt(
        'numberOfTables', numberOfTables); // Save number of tables

    for (int i = 0; i < numberOfTables; i++) {
      List<String> dataToSave =
          weeklyExpensesList[i].map((row) => row.join(',')).toList();
      await prefs.setStringList('weeklyExpenses$i', dataToSave);
    }
    return true;
  }

  // Function to load data from SharedPreferences.
  void _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int numberOfTables = prefs.getInt('numberOfTables') ?? 0;
    List<List<List<String>>> loadedData = [];
    for (int i = 0; i < numberOfTables; i++) {
      List<String>? savedData = prefs.getStringList('weeklyExpenses$i');
      if (savedData != null) {
        loadedData.add(savedData.map((row) => row.split(',')).toList());
      }
    }
    if (loadedData.isNotEmpty) {
      setState(() {
        weeklyExpensesList = loadedData;
      });
    } else {
      setState(() {
        weeklyExpensesList = [_initializeWeeklyExpenses()];
      });
    }
  }

  // Function to show a delete confirmation dialog.
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

  // Function to delete a table of weekly expenses.
  void _deleteTable(int index) {
    setState(() {
      weeklyExpensesList.removeAt(index);
    });
    _saveData(); // Save data when a table is deleted
  }

  // Function para mo calculate sa total cost of weekly expenses.
  double _calculateTotalCost(List<List<String>> weeklyExpenses) {
    // Sum up the cost from each row in the weekly expenses.
    return weeklyExpenses.fold<double>(0,(total, entry) =>total +(double.tryParse(entry[3]) ??0)); // Attempt to parse the fourth element
  }
}

void main() {
  runApp(MaterialApp(
    home: ChangeNotifierProvider(
      create: (context) => ColorProvider(),
      child: WeeklyExpensesPage(),
    ),
    theme: ThemeData.light(),
    darkTheme: ThemeData.dark(),
    themeMode: ThemeMode.system,
  ));
}
