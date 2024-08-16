import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';
import 'package:v_i_b/services/functions.dart';

class ChatPage extends StatefulWidget {
  final Web3Client ethClient;

  const ChatPage({Key? key, required this.ethClient}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController messageController = TextEditingController();
  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final messagesList = await getMessages(widget.ethClient);
    setState(() {
      messages = messagesList;
    });
  }

  Future<void> _sendMessage() async {
    final message = messageController.text;
    final privateKey = 'YOUR_PRIVATE_KEY'; // Ensure this is set correctly

    await sendMessage(message, widget.ethClient, privateKey);
    _loadMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: messageController,
              decoration: InputDecoration(labelText: 'Message'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _sendMessage,
              child: Text('Send'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return ListTile(
                    title: Text(message['text']),
                    subtitle: Text('From: ${message['sender']}'),
                    trailing: Text(
                      DateTime.fromMillisecondsSinceEpoch(message['timestamp'] * 1000)
                          .toLocal()
                          .toString(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
