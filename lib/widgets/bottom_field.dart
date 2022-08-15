import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
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
        children: <Widget>[
          ListTile(
            title: const Text('Edit'),
            leading: const Icon(Icons.edit),
            onTap: () => {
              _textController.text = chat.message,
              Navigator.of(context).pop(),
              showMaterialModalBottomSheet(
                context: context,
                builder: (context) => SingleChildScrollView(
                  controller: ModalScrollController.of(context),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        height: 200,
                        child: Form(
                            key: _formKey,
                            child: Column(
                              // ignore: prefer_const_literals_to_create_immutables
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18.0),
                                  child: Text("Edit",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(18.0),
                                  child: TextFormField(
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    controller: _textController,
                                    autofocus: true,

                                    // style:
                                    //     TextStyle(fontWeight: FontWeight.bold),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter some text';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      chat.updateMessage(_textController.text);

                                      Navigator.of(context).pop();
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 30, vertical: 12),
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: Text(
                                      "Save",
                                      style:
                                          Theme.of(context).textTheme.headline6,
                                    ),
                                  ),
                                ),
                              ],
                            )),
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
    ));
  }
}