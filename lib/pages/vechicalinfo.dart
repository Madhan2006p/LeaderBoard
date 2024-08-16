import 'package:flutter/material.dart';
import 'package:v_i_b/services/functions.dart';
import 'package:web3dart/web3dart.dart';
import 'DisplayAllPage.dart';
import 'ChatPage.dart';

class Vechicalinfo extends StatefulWidget {
  final Web3Client ethClient;
  final String userName;

  const Vechicalinfo({
    Key? key,
    required this.ethClient,
    required this.userName,
  }) : super(key: key);

  @override
  State<Vechicalinfo> createState() => _VechicalinfoState();
}

class _VechicalinfoState extends State<Vechicalinfo> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController engineController = TextEditingController();
  final TextEditingController mileageController = TextEditingController();
  final TextEditingController accNumController = TextEditingController();
  final TextEditingController ratingController = TextEditingController();
  final TextEditingController ansController = TextEditingController();

  // Function to handle the form submission
  void _addBikeRecord() async {
    try {
      String name = nameController.text;
      int engine = int.parse(engineController.text);
      int mileage = int.parse(mileageController.text);
      int accNum = int.parse(accNumController.text);
      int rating = int.parse(ratingController.text);
      bool ans = ansController.text.toLowerCase() == 'true';

      String ownerPrivateKey = '14e2645cc2dc52b5148c2de25cf73b4b9f971c827c7184e134837e93eb540355'; // Ensure this is set correctly

      // Call function to add bike record
      final response = await addBikeRecord(
        name,
        engine,
        mileage,
        accNum,
        rating,
        ans,
        widget.ethClient,
        ownerPrivateKey,
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bike record added successfully: $response')),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding bike record: $e')),
      );
    }
  }

  void _navigateToDisplayAllPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DisplayAllPage(
          ethClient: widget.ethClient,
        ),
      ),
    );
  }

  void _navigateToChatPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          ethClient: widget.ethClient,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.userName)),
    body: SingleChildScrollView(
    child: Container(
    padding: EdgeInsets.all(14),
    child: Column(
    children: [
    SizedBox(height: 20),
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
    Expanded(
    child: Column(
    children: [
    FutureBuilder<BigInt>(
    future: getBikeCount(widget.ethClient),
    builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
    return Center(child: CircularProgressIndicator());
    } else if (snapshot.hasError) {
    return Text('Error: ${snapshot.error}');
    } else if (snapshot.hasData && snapshot.data != null) {
    return Text(
    snapshot.data!.toString(),
    style: TextStyle(
    fontSize: 50,
    fontWeight: FontWeight.bold,
    ),
    );
    } else {
    return Text('No data available');
    }
    },
    ),
    Text('Total Tracter Records'),
    ],
    ),
    ),
    ],
    ),
    SizedBox(height: 20),
    TextField(
    controller: nameController,
    decoration: InputDecoration(hintText: 'Enter Fule Efficent'),
    ),
    SizedBox(height: 20),
    TextField(
    controller: engineController,
    decoration: InputDecoration(hintText: 'Enter the Engine Capacity'),
    keyboardType: TextInputType.number,
    ),
    SizedBox(height: 20),
    TextField(
    controller: mileageController,
    decoration: InputDecoration(hintText: 'Enter Engine Type'),
    keyboardType: TextInputType.number,
    ),
    SizedBox(height: 20),
    TextField(
    controller: accNumController,
    decoration: InputDecoration(hintText: 'Enter Weight'),
    keyboardType: TextInputType.number,
    ),
    SizedBox(height: 20),
    TextField(
    controller: ratingController,
    decoration: InputDecoration(hintText: 'Enter the Rating'),
    keyboardType: TextInputType.number,
    ),
    SizedBox(height: 20),
    TextField(
    controller: ansController,
    decoration: InputDecoration(hintText: 'Enter the Boolean Answer (true/false)'),
    ),
    SizedBox(height: 20),
    Row(
    children: [
    Expanded(
    child: ElevatedButton(
    onPressed: _addBikeRecord,
    child: Text('Add Company'),
    ),
    ),
    ],
    ),
    SizedBox(height: 20),
      Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _navigateToDisplayAllPage,
              child: Text('View All Bikes'),
            ),
          ),
        ],
      ),
      SizedBox(height: 20),
      Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _navigateToChatPage,
              child: Text('Go to Chat'),
            ),
          ),
        ],
      ),
    ],
    ),
    ),
    ),
    );
  }
}
