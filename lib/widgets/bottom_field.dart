import 'package:flutter/material.dart';
import 'package:musikat_app/models/chat_message_model.dart';

class BottomSheetModal extends StatelessWidget {
  BottomSheetModal({required this.chat, Key? key}) : super(key: key);

  final ChatMessage chat;
final _formKey = GlobalKey<FormState>();
final TextEditingController _textController = TextEditingController();

@override
Widget build(BuildContext context) {
  return Material(
    child: SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Edit'),
            leading: const Icon(Icons.edit),
            onTap: () => {
              _textController.text = chat.message,
              Navigator.of(context).pop(),
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Edit",
                              style: Theme.of(context).textTheme.headline6,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              textCapitalization: TextCapitalization.sentences,
                              controller: _textController,
                              autofocus: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter some text';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  chat.updateMessage(_textController.text);
                                  Navigator.of(context).pop();
                                }
                              },
                              child: Text("Save"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
            },
          ),
          ListTile(
            title: const Text('Delete'),
            leading: const Icon(Icons.delete),
            onTap: () => {
              Navigator.of(context).pop(),
              chat.deleteMessage(),
            },
          )
        ],
      ),
    ),
  );
}
}