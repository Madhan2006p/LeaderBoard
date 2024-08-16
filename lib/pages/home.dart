import 'package:flutter/widgets.dart';
import 'package:v_i_b/pages/vechicalinfo.dart';
import 'package:v_i_b/services/functions.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart'; // Import the HTTP package
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Client? httpClient;
  Web3Client? ethClient;
  TextEditingController controller = TextEditingController();
  String infura_url =
      "https://sepolia.infura.io/v3/1644a5b2aa5340d5b09b0b755f2cd4e3";
  @override
  void initState() {
    httpClient = Client();
    ethClient = Web3Client(infura_url, httpClient!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter The Details'),
      ),
      body: Container(
        padding: EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: controller,
              decoration:
                  InputDecoration(filled: true, hintText: 'Enter the Vin-Pin'),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                  onPressed: ()async {
                    if (controller.text.length > 0) {
                      startCalc(controller.text, ethClient!);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Vechicalinfo(
                                  ethClient: ethClient!,
                                  userName: controller.text)));
                    }
                  },
                  child: Text('Start the calclation')),
            )
          ],
        ),
      ),
    );
  }
}
