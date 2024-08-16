import 'package:flutter/services.dart';
import 'package:v_i_b/utils/constants.dart';
import 'package:web3dart/web3dart.dart';

Future<DeployedContract> loadContract() async {
  try {
    String abi = await rootBundle.loadString('assets/abi.json');
    String contractAddress = '0x1c91347f2A44538ce62453BEBd9Aa907C662b4bD';
    final contract = DeployedContract(
      ContractAbi.fromJson(abi, 'BikeRecord'),
      EthereumAddress.fromHex(contractAddress),
    );
    return contract;
  } catch (e) {
    print('Error loading contract: $e');
    rethrow;
  }
}

Future<String> callFunction(
    String funcName, List<dynamic> args, Web3Client ethClient, String privateKey) async {
  try {
    EthPrivateKey credentials = EthPrivateKey.fromHex(privateKey);
    DeployedContract contract = await loadContract();
    final ethFunction = contract.function(funcName);
    final result = await ethClient.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: ethFunction,
        parameters: args,
      ),
      chainId: null, // Or provide the correct chain ID
      fetchChainIdFromNetworkId: true,
    );
    return result;
  } catch (e) {
    print('Error calling function: $e');
    rethrow;
  }
}

Future<String> startCalc(String name, Web3Client ethClient) async {
  try {
    var response = await callFunction('startCalc', [name], ethClient, onwer_private_key);
    print('Calculation started successfully');
    return response;
  } catch (e) {
    print('Error starting calculation: $e');
    rethrow;
  }
}

Future<String> addBikeRecord(
    String name,
    int engine,
    int mileage,
    int accNum,
    int rating,
    bool ans,
    Web3Client ethClient,
    String privateKey,
    ) async {
  try {
    var response = await callFunction(
      'addBikeRecord',
      [
        name,
        BigInt.from(engine),
        BigInt.from(mileage),
        BigInt.from(accNum),
        BigInt.from(rating),
        ans,
      ],
      ethClient,
      privateKey,
    );
    print('Bike record added successfully');
    return response;
  } catch (e) {
    print('Error adding bike record: $e');
    rethrow;
  }
}

Future<BigInt> getBikeCount(Web3Client ethClient) async {
  try {
    final result = await ask('getBikeCount', [], ethClient);
    return result[0] as BigInt;
  } catch (e) {
    print('Error fetching bike count: $e');
    return BigInt.zero; // Fallback value
  }
}


Future<List<Map<String, dynamic>>> getAllBikes(Web3Client ethClient) async {
  try {
    // Fetch the raw result from the blockchain
    List<dynamic> result = await ask('getAllBikes', [], ethClient);

    // The actual data is in the first element of the result
    List<dynamic> bikesData = result[0];

    // List to hold parsed bikes
    List<Map<String, dynamic>> bikes = [];

    // Iterate over each bike in the data
    for (var bike in bikesData) {
      bikes.add({
        'recordId': (bike[0] as BigInt).toInt(), // Convert BigInt to int
        'name': bike[1] as String, // Ensure string conversion
        'engineCC': (bike[2] as BigInt).toInt(), // Convert BigInt to int
        'milage': (bike[3] as BigInt).toInt(), // Convert BigInt to int
        'accidentNum': (bike[4] as BigInt).toInt(), // Convert BigInt to int
        'ratings': (bike[5] as BigInt).toInt(), // Convert BigInt to int
        'antiBrake': bike[6] == true, // Convert to boolean
      });
    }
    return bikes;
  } catch (e) {
    print('Error fetching all bikes: $e');
    return [];
  }
}

Future<List<Map<String, dynamic>>> sortBikesByAverageScore(Web3Client ethClient) async {
  try {
    List<dynamic> result = await ask('sortBikesByAverageScore', [], ethClient);

    // Debugging: Print the result to inspect its structure
    print('Result from sortBikesByAverageScore: $result');

    // Check if the result is not empty and has at least one element
    if (result.isNotEmpty && result[0] is List) {
      List<dynamic> bikesData = result[0];

      // Convert the dynamic list to a list of maps
      List<Map<String, dynamic>> bikes = bikesData.map((bike) {
        // Ensure the bike data structure is correct
        if (bike is List && bike.length >= 7) {
          return {
            'recordId': (bike[0] as BigInt).toInt(),
            'name': bike[1] as String,
            'engineCC': (bike[2] as BigInt).toInt(),
            'milage': (bike[3] as BigInt).toInt(),
            'accidentNum': (bike[4] as BigInt).toInt(),
            'ratings': (bike[5] as BigInt).toInt(),
            'antiBrake': bike[6] as bool,
          };
        } else {
          print('Unexpected bike structure: $bike');
          return {
            'recordId': 0,
            'name': 'Unknown',
            'engineCC': 0,
            'milage': 0,
            'accidentNum': 0,
            'ratings': 0,
            'antiBrake': false,
          };
        }
      }).toList();

      return bikes;
    } else {
      print('Unexpected result structure: $result');
      return [];
    }
  } catch (e) {
    print('Error sorting bikes: $e');
    return [];
  }
}

Future<void> sendMessage(
    String message, Web3Client ethClient, String privateKey) async {
  final recipient = 'YOUR_ETHEREUM_ADDRESS';
  final credentials = EthPrivateKey.fromHex(privateKey);
  final contract = await loadContract();
  final ethFunction = contract.function('sendMessage');

  await ethClient.sendTransaction(
    credentials,
    Transaction.callContract(
      contract: contract,
      function: ethFunction,
      parameters: [recipient, message, BigInt.from(DateTime.now().millisecondsSinceEpoch)],
    ),
    chainId: null, // Or provide the correct chain ID
    fetchChainIdFromNetworkId: true,
  );
}

Future<List<Map<String, dynamic>>> getMessages(
    Web3Client ethClient) async {
  final recipient = 'YOUR_ETHEREUM_ADDRESS';
  final contract = await loadContract();
  final ethFunction = contract.function('getMessages');

  final result = await ethClient.call(
    contract: contract,
    function: ethFunction,
    params: [recipient],
  );

  List<Map<String, dynamic>> messages = [];
  for (var message in result[0]) {
    messages.add({
      'sender': message[0] as String,
      'recipient': message[1] as String,
      'text': message[2] as String,
      'timestamp': (message[3] as BigInt).toInt(),
    });
  }
  return messages;
}
Future<List<dynamic>> ask(
    String funcName, List<dynamic> args, Web3Client ethClient) async {
  try {
    final contract = await loadContract();
    final ethFunction = contract.function(funcName);
    final result = await ethClient.call(
      contract: contract,
      function: ethFunction,
      params: args,
    );
    return result;
  } catch (e) {
    print('Error calling contract function: $e');
    rethrow;
  }
}
