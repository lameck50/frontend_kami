import 'package:flutter/material.dart';
import 'package:kami_geoloc/core/constants/api_constants.dart';
import 'package:kami_geoloc/features/auth/presentation/providers/auth_provider.dart';
import 'package:kami_geoloc/features/supervisor_dashboard/domain/entities/message.dart';
import 'package:kami_geoloc/features/supervisor_dashboard/presentation/providers/supervisor_provider.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatScreen extends StatefulWidget {
  final String agentId;
  final String agentName;

  const ChatScreen({Key? key, required this.agentId, required this.agentName}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late IO.Socket socket;

  @override
  void initState() {
    super.initState();
    final supervisorProvider = Provider.of<SupervisorProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    supervisorProvider.fetchMessages(widget.agentId);

    socket = IO.io(API_BASE_URL, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'query': {'userId': authProvider.user!['id']}
    });

    socket.connect();
    socket.onConnect((_) {
      print('Chat connected');
      socket.emit('register', supervisorProvider.authProvider.user!['id']);
    });

    socket.on('receiveMessage', (data) {
      final message = Message.fromJson(data);
      supervisorProvider.addMessage(message);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    socket.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      final supervisorProvider = Provider.of<SupervisorProvider>(context, listen: false);
      final message = {
        'senderId': supervisorProvider.authProvider.user!['id'],
        'receiverId': widget.agentId,
        'content': _messageController.text,
      };
      socket.emit('sendMessage', message);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final supervisorProvider = Provider.of<SupervisorProvider>(context);
    final myId = supervisorProvider.authProvider.user!['id'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat avec ${widget.agentName}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: supervisorProvider.isFetchingMessages
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: supervisorProvider.messages.length,
                    itemBuilder: (context, index) {
                      final message = supervisorProvider.messages[index];
                      final isMe = message.senderId == myId;
                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue : Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            message.content,
                            style: TextStyle(color: isMe ? Colors.white : Colors.black),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Entrez votre message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
