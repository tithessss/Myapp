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

  // mo Load ang saved records when the page initializes
  @override
  void initState() {
    super.initState();
    loadRecords();
  }

  // mo Load saved records gikan sa SharedPreferences
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

  // isave ang records to SharedPreferences
  void saveRecords() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> recordsList =
        customerRecords.map((record) => record.toString()).toList();
    prefs.setStringList('customerRecords', recordsList);
    // Show a notification when records are saved
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Records saved successfully'),
        duration: Duration(milliseconds: 1000), // Set the duration to 1 second
      ),
    );
  }

  // delete ug record from the list and save the updated list
  void deleteRecord(int index) async {
    setState(() {
      customerRecords.removeAt(index);
      saveRecords(); // Save the updated records list
    });
    // Show a notification that the row was deleted successfully
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Row deleted successfully'),
        duration: Duration(milliseconds: 1000), // Set the duration to 1 second
      ),
    );
  }

  //  algo para sorting base sa amount purchased higest to lowest
  void quickSort(List<CustomerRecord> arr, int low, int high) {
    if (low < high) {
      int pi = partition(arr, low, high);
      quickSort(arr, low, pi - 1);
      quickSort(arr, pi + 1, high);
    }
  }

  //partitions the array into two parts based on a pivot element.
  int partition(List<CustomerRecord> arr, int low, int high) {
    double pivot = double.parse(arr[high].amountPurchased);
    int i = (low - 1);
    for (int j = low; j < high; j++) {
      if (double.parse(arr[j].amountPurchased) > pivot) {
        i++;
        CustomerRecord temp = arr[i];
        arr[i] = arr[j];
        arr[j] = temp;
      }
    }
    CustomerRecord temp = arr[i + 1];
    arr[i + 1] = arr[high];
    arr[high] = temp;
    return i + 1;
  }

  void sortRecords() {
    setState(() {
      quickSort(customerRecords, 0, customerRecords.length - 1);
    });
  }

  // kani para sa Add a new record to the list
  void addRecord(String name, String contact, String purchased, String amount) {
    setState(() {
      customerRecords.add(CustomerRecord(
        customerName: name,
        contactNumber: contact,
        purchased: purchased,
        amountPurchased: amount,
      ));
      sortRecords(); // Sort the records based on amount purchased
      saveRecords(); // Save and update the records list
      loadRecords(); // Reload the records from SharedPreferences to reflect the addition of the new record
    });
  }

  // kani kay Build the input fields dialog for adding a new record
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

  // Validate the input fields before adding a record
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
      double.parse(amount); // Check if the amount is a valid double
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

  // kani kay for Building the input fields dialog for editing a record
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
                    // Update the record with the new values
                    customerRecords[index].customerName = nameController.text;
                    customerRecords[index].contactNumber =
                        contactController.text;
                    customerRecords[index].purchased = purchasedController.text;
                    customerRecords[index].amountPurchased =
                        amountController.text;
                    // isort the records after editing
                    sortRecords();
                    // isave the updated records list
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
    final Color selectedColor = Colors.white; // Change to your desired color
    final bool isDarkBackground = selectedColor.computeLuminance() < 0.5;
    textColor =
        isDarkBackground ? Colors.white : Colors.black; // Update text color

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        centerTitle: true,
        title: Text(
          'Customers Records',
          style: TextStyle(
            color: textColor, // Adjust text color based on background
          ),
        ),
      ),
      backgroundColor: selectedColor,
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal, // Enable horizontal scrolling
        child: SingleChildScrollView(
          child: DataTable(
            columnSpacing: 16.0, // Increase column spacing
            dividerThickness: 1.0,
            columns: [
              DataColumn(
                label: Text(
                  'Customer Name',
                  style: TextStyle(
                    color: textColor, // Adjust text color based on background
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Contact Number',
                  style: TextStyle(
                    color: textColor, // Adjust text color based on background
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Purchased',
                  style: TextStyle(
                    color: textColor, // Adjust text color based on background
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Amount Purchased',
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
                            showEditRecordDialog(
                                index); // Call the edit dialog with the index of the record
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
          showAddRecordDialog(); // mo show ug input fields dialog for adding a new record
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

  //kani para mo create ug customerrecord object from string presentation
  static CustomerRecord fromString(String recordString) {
    List<String> values = recordString.split(',');
    return CustomerRecord(
      customerName: values[0],
      contactNumber: values[1],
      purchased: values[2],
      amountPurchased: values[3],
    );
  }

  // Convert CustomerRecord object to string representation
  @override
  String toString() {
    return '$customerName,$contactNumber,$purchased,$amountPurchased';
  }
}
