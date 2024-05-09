import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:LuckyEgg/color_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EggProductionPage extends StatefulWidget {
  const EggProductionPage({Key? key});

  @override
  _EggProductionPageState createState() => _EggProductionPageState();
}

class _EggProductionPageState extends State<EggProductionPage> {
  List<EggProductionRecord> eggProductionRecords = [];
  int? editingIndex; // Track the index of the row being edited
  late Color textColor; // Text color variable

  // Load saved records when the page initializes
  @override
  void initState() {
    super.initState();
    loadRecords();
  }

  // Load saved records from SharedPreferences
  void loadRecords() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? recordsList = prefs.getStringList('eggProductionRecords');
    if (recordsList != null) {
      setState(() {
        eggProductionRecords = recordsList
            .map((recordString) => EggProductionRecord.fromString(recordString))
            .toList();
      });
    }
  }

  // Save records to SharedPreferences
  void saveRecords() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> recordsList =
        eggProductionRecords.map((record) => record.toString()).toList();
    prefs.setStringList('eggProductionRecords', recordsList);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Records saved successfully'),
        duration: Duration(milliseconds: 1000), // Set the duration to 1 second
      ),
    );
  }

  // Delete a record from the list and save the updated list
  void deleteRecord(int index) async {
    setState(() {
      eggProductionRecords.removeAt(index);
      saveRecords(); // Save the updated records list
    });
    // Show a notification that the row was deleted successfully with a shorter duration
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Row deleted successfully'),
        duration: Duration(milliseconds: 1000), // Set the duration to 1 second
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color selectedColor =
        Provider.of<ColorProvider>(context).selectedColor;
    final bool isDarkBackground = selectedColor.computeLuminance() < 0.5;
    textColor =
        isDarkBackground ? Colors.white : Colors.black; // Update text color

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        centerTitle: true,
        title: Text(
          'Egg Production Records',
          style: TextStyle(
            color: textColor, // Adjust text color based on background
          ),
        ),
      ),
      backgroundColor: selectedColor,
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            dividerThickness: 1.0, // Add divider thickness
            columns: [
              DataColumn(
                label: Text(
                  'Month',
                  style: TextStyle(
                    color: textColor, // Adjust text color based on background
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Date',
                  style: TextStyle(
                    color: textColor, // Adjust text color based on background
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Breed',
                  style: TextStyle(
                    color: textColor, // Adjust text color based on background
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Good',
                  style: TextStyle(
                    color: textColor, // Adjust text color based on background
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Bad',
                  style: TextStyle(
                    color: textColor, // Adjust text color based on background
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Actions',
                  style: TextStyle(
                    color: textColor, // Adjust text color based on background
                  ),
                ),
              ),
            ],
            rows: List.generate(
              eggProductionRecords.length,
              (index) => DataRow(
                cells: [
                  DataCell(
                    editingIndex == index
                        ? TextFormField(
                            initialValue: eggProductionRecords[index].month,
                            onChanged: (value) {
                              setState(() {
                                eggProductionRecords[index].month = value;
                              });
                            },
                            style: TextStyle(
                              color: textColor,
                            ),
                          )
                        : Text(
                            eggProductionRecords[index].month,
                            style: TextStyle(
                              color: textColor,
                            ),
                          ),
                  ),
                  DataCell(
                    editingIndex == index
                        ? TextFormField(
                            initialValue: eggProductionRecords[index].date,
                            onChanged: (value) {
                              setState(() {
                                eggProductionRecords[index].date = value;
                              });
                            },
                            style: TextStyle(
                              color: textColor,
                            ),
                          )
                        : Text(
                            eggProductionRecords[index].date,
                            style: TextStyle(
                              color: textColor,
                            ),
                          ),
                  ),
                  DataCell(
                    editingIndex == index
                        ? TextFormField(
                            initialValue: eggProductionRecords[index].breed,
                            onChanged: (value) {
                              setState(() {
                                eggProductionRecords[index].breed = value;
                              });
                            },
                            style: TextStyle(
                              color: textColor,
                            ),
                          )
                        : Text(
                            eggProductionRecords[index].breed,
                            style: TextStyle(
                              color: textColor,
                            ),
                          ),
                  ),
                  DataCell(
                    editingIndex == index
                        ? TextFormField(
                            initialValue: eggProductionRecords[index].good,
                            onChanged: (value) {
                              setState(() {
                                eggProductionRecords[index].good = value;
                              });
                            },
                            style: TextStyle(
                              color: textColor,
                            ),
                          )
                        : Text(
                            eggProductionRecords[index].good,
                            style: TextStyle(
                              color: textColor,
                            ),
                          ),
                  ),
                  DataCell(
                    editingIndex == index
                        ? TextFormField(
                            initialValue: eggProductionRecords[index].bad,
                            onChanged: (value) {
                              setState(() {
                                eggProductionRecords[index].bad = value;
                              });
                            },
                            style: TextStyle(
                              color: textColor,
                            ),
                          )
                        : Text(
                            eggProductionRecords[index].bad,
                            style: TextStyle(
                              color: textColor,
                            ),
                          ),
                  ),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            setState(() {
                              editingIndex = index;
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            deleteRecord(index);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  eggProductionRecords.add(EggProductionRecord());
                });
              },
              child: const Text('Add Row'),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                saveRecords();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class EggProductionRecord {
  String month = '';
  String date = '';
  String breed = '';
  String good = '';
  String bad = '';

  EggProductionRecord({
    this.month = '',
    this.date = '',
    this.breed = '',
    this.good = '',
    this.bad = '',
  });

  // Create EggProductionRecord object from string representation
  static EggProductionRecord fromString(String recordString) {
    List<String> values = recordString.split(',');
    return EggProductionRecord(
      month: values[0],
      date: values[1],
      breed: values[2],
      good: values[3],
      bad: values[4],
    );
  }

  // Convert EggProductionRecord object to string representation
  @override
  String toString() {
    return '$month,$date,$breed,$good,$bad';
  }
}
