import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';
import 'package:v_i_b/services/functions.dart';

class SortPage extends StatelessWidget {
  final Web3Client ethClient;

  const SortPage({
    Key? key,
    required this.ethClient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sorted Bikes'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: sortBikesByAverageScore(ethClient),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data != null) {
            final bikes = snapshot.data!;
            return ListView.builder(
              itemCount: bikes.length,
              itemBuilder: (context, index) {
                final bike = bikes[index];
                return ListTile(
                  title: Text(bike['name']),
                  subtitle: Text(
                      'Engine: ${bike['engineCC']}\nMileage: ${bike['milage']}\nAccident Number: ${bike['accidentNum']}\nRating: ${bike['ratings']}\nAnti-Brake: ${bike['antiBrake']}'),
                );
              },
            );
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}
