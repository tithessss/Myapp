import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomersRecordsPage extends StatefulWidget {
  const CustomersRecordsPage({Key? key}) : super(key: key);

  @override
  _CustomersRecordsPageState createState() => _CustomersRecordsPageState();
}

class _CustomersRecordsPageState extends State<CustomersRecordsPage> {
  List<CustomerRecord> customerRecords = [];
  late Color textColor; // Text color variable

  @override
  void initState() {
    super.initState();
    loadRecords();
  }

  void loadRecords() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? recordsList = prefs.getStringList('customerRecords');
    if (recordsList != null) {
      setState(() {
        customerRecords = recordsList
            .map((recordString) => CustomerRecord.fromString(recordString))
            .toList();
      });
    }
  }

  void saveRecords() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> recordsList =
        customerRecords.map((record) => record.toString()).toList();
    prefs.setStringList('customerRecords', recordsList);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Records saved successfully'),
        duration: Duration(milliseconds: 1000),
      ),
    );
  }

  void deleteRecord(int index) async {
    setState(() {
      customerRecords.removeAt(index);
      saveRecords();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Row deleted successfully'),
        duration: Duration(milliseconds: 1000),
      ),
    );
  }

  // Sorting algorithm to sort records based on the amount purchased (from highest to lowest)
  void sortByAmountPurchased(List<CustomerRecord> arr) {
    arr.sort((a, b) => b.amountPurchased.compareTo(a.amountPurchased));
  }

  void sortRecords() {
    setState(() {
      sortByAmountPurchased(customerRecords);
    });
  }

  void addRecord(String name, String contact, String purchased, String amount) {
    setState(() {
      customerRecords.add(CustomerRecord(
        customerName: name,
        contactNumber: contact,
        purchased: purchased,
        amountPurchased: amount,
      ));
      sortRecords();
      saveRecords();
      loadRecords();
    });
  }

  Future<void> showAddRecordDialog() async {
    TextEditingController nameController = TextEditingController();
    TextEditingController contactController = TextEditingController();
    TextEditingController purchasedController = TextEditingController();
    TextEditingController amountController = TextEditingController();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Record'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Customer Name',
                  ),
                ),
                TextField(
                  controller: contactController,
                  decoration: InputDecoration(
                    labelText: 'Contact Number',
                  ),
                ),
                TextField(
                  controller: purchasedController,
                  decoration: InputDecoration(
                    labelText: 'Purchased',
                  ),
                ),
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(
                    labelText: 'Amount Purchased',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (validateFields(amountController.text)) {
                  addRecord(
                    nameController.text,
                    contactController.text,
                    purchasedController.text,
                    amountController.text,
                  );
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  bool validateFields(String amount) {
    if (amount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Amount Purchased is required'),
          duration: Duration(milliseconds: 1500),
        ),
      );
      return false;
    }
    try {
      double.parse(amount);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid amount'),
          duration: Duration(milliseconds: 1500),
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> showEditRecordDialog(int index) async {
    TextEditingController nameController =
        TextEditingController(text: customerRecords[index].customerName);
    TextEditingController contactController =
        TextEditingController(text: customerRecords[index].contactNumber);
    TextEditingController purchasedController =
        TextEditingController(text: customerRecords[index].purchased);
    TextEditingController amountController =
        TextEditingController(text: customerRecords[index].amountPurchased);

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Record'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Customer Name',
                  ),
                ),
                TextField(
                  controller: contactController,
                  decoration: InputDecoration(
                    labelText: 'Contact Number',
                  ),
                ),
                TextField(
                  controller: purchasedController,
                  decoration: InputDecoration(
                    labelText: 'Purchased',
                  ),
                ),
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(
                    labelText: 'Amount Purchased',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (validateFields(amountController.text)) {
                  setState(() {
                    customerRecords[index].customerName = nameController.text;
                    customerRecords[index].contactNumber =
                        contactController.text;
                    customerRecords[index].purchased = purchasedController.text;
                    customerRecords[index].amountPurchased =
                        amountController.text;
                    sortRecords();
                    saveRecords();
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color selectedColor = Colors.white;
    final bool isDarkBackground = selectedColor.computeLuminance() < 0.5;
    textColor = isDarkBackground ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        centerTitle: true,
        title: Text(
          'Customers Records',
          style: TextStyle(
            color: textColor,
          ),
        ),
      ),
      backgroundColor: selectedColor,
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            columnSpacing: 16.0,
            dividerThickness: 1.0,
            columns: [
              DataColumn(
                label: Text(
                  'Customer Name',
                  style: TextStyle(
                    color: textColor,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Contact Number',
                  style: TextStyle(
                    color: textColor,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Purchased',
                  style: TextStyle(
                    color: textColor,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Amount Purchased',
                  style: TextStyle(
                    color: textColor,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Actions',
                  style: TextStyle(
                    color: textColor,
                  ),
                ),
              ),
            ],
            rows: List.generate(
              customerRecords.length,
              (index) => DataRow(
                cells: [
                  DataCell(
                    Text(
                      customerRecords[index].customerName,
                      style: TextStyle(
                        color: textColor,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      customerRecords[index].contactNumber,
                      style: TextStyle(
                        color: textColor,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      customerRecords[index].purchased,
                      style: TextStyle(
                        color: textColor,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      customerRecords[index].amountPurchased,
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
                            showEditRecordDialog(index);
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddRecordDialog();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class CustomerRecord {
  String customerName;
  String contactNumber;
  String purchased;
  String amountPurchased;

  CustomerRecord({
    required this.customerName,
    required this.contactNumber,
    required this.purchased,
    required this.amountPurchased,
  });

  static CustomerRecord fromString(String recordString) {
    List<String> values = recordString.split(',');
    return CustomerRecord(
      customerName: values[0],
      contactNumber: values[1],
      purchased: values[2],
      amountPurchased: values[3],
    );
  }

  @override
  String toString() {
    return '$customerName,$contactNumber,$purchased,$amountPurchased';
  }
}
