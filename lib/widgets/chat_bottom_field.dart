// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musikat_app/models/chat_message_model.dart';
import 'package:musikat_app/utils/constants.dart';
import 'package:musikat_app/widgets/toast_msg.dart';

class ChatBottomField extends StatelessWidget {
  ChatBottomField({required this.chat, Key? key}) : super(key: key);

  final ChatMessage chat;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  'Edit',
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
                ),
                leading: const Icon(Icons.edit, color: Colors.white),
                onTap: () => {
                  _textController.text = chat.message,
                  Navigator.of(context).pop(),
                  showModalBottomSheet(
                    backgroundColor: musikatColor4,
                    context: context,
                    builder: (context) => SingleChildScrollView(
                      child: SafeArea(
                        top: false,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Edit message",
                                      style: GoogleFonts.inter(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      width: double.infinity,
                                      height: 40,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                            width: 1.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      child: editForm(),
                                    ),
                                    const SizedBox(height: 16),
                                    editButton(context),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                },
              ),
              ListTile(
                title: Text('Delete',
                    style:
                        GoogleFonts.inter(color: Colors.white, fontSize: 16)),
                leading: const Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
                onTap: () => {
                  Navigator.of(context).pop(),
                  chat.deleteMessage(),

                  // showDialog(
                  //   context: context,
                  //   builder: (BuildContext context) => Dialog(
                  //     backgroundColor: musikatColor4,
                  //     child: Padding(
                  //       padding: const EdgeInsets.all(16.0),
                  //       child: Column(
                  //         mainAxisSize: MainAxisSize.min,
                  //         children: [
                  //           Text(
                  //             "Delete",
                  //             style: GoogleFonts.inter(
                  //                 fontSize: 18,
                  //                 fontWeight: FontWeight.bold,
                  //                 color: Colors.white),
                  //           ),
                  //           const SizedBox(height: 18),
                  //           Text(
                  //             "Are you sure you want to delete this message?",
                  //             style: GoogleFonts.inter(
                  //                 fontSize: 15, color: Colors.white),
                  //           ),
                  //           const SizedBox(height: 15),
                  //           Row(
                  //             mainAxisAlignment:
                  //                 MainAxisAlignment.spaceEvenly,
                  //             crossAxisAlignment: CrossAxisAlignment.center,
                  //             children: [
                  //               Container(
                  //                 decoration: BoxDecoration(
                  //                     color: deleteColor,
                  //                     borderRadius:
                  //                         BorderRadius.circular(10)),
                  //                 child: TextButton(
                  //                   onPressed: () async {
                  //                     try {
                  //                       await chat.deleteMessage();

                  //                       Navigator.of(context).pop();
                  //                       ToastMessage.show(context,
                  //                           'Message deleted successfully');
                  //                     } catch (e) {
                  //                       ToastMessage.show(context,
                  //                           'Error deleting message');
                  //                     }
                  //                   },
                  //                   child: Text(
                  //                     "Delete",
                  //                     style: GoogleFonts.inter(
                  //                         color: Colors.white),
                  //                   ),
                  //                 ),
                  //               ),
                  //               Container(
                  //                   decoration: BoxDecoration(
                  //                     color: cancelColor,
                  //                     borderRadius:
                  //                         BorderRadius.circular(10)),
                  //                 child: TextButton(
                  //                   onPressed: () {
                  //                     Navigator.of(context).pop();
                  //                   },

                  //                   child: Text(
                  //                     "Cancel",
                  //                     style: GoogleFonts.inter(
                  //                         color: Colors.white),
                  //                   ),
                  //                 ),
                  //               ),
                  //             ],
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  TextFormField editForm() {
    return TextFormField(
      style: GoogleFonts.inter(
        color: Colors.black,
        fontSize: 14,
      ),
      textCapitalization: TextCapitalization.sentences,
      controller: _textController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Type a message....',
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          color: Colors.grey,
        ),
        isDense: true,
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        contentPadding:
            const EdgeInsets.only(left: 12, bottom: 12, top: 10, right: 12),
      ),
    );
  }

  Container editButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: musikatColor, borderRadius: BorderRadius.circular(10)),
      child: TextButton(
        onPressed: () {
          String value = _textController.text.trim();
          if (value.isEmpty) {
            ToastMessage.show(context, 'Message cannot be empty');
            return;
          }
          String previousMessage = chat.message;
          if (value == previousMessage) {
            ToastMessage.show(context, 'Message is the same as before');
            return;
          }
          chat.updateMessage(value);
          Navigator.of(context).pop();
        },
        child: Text(
          'Save',
          style: GoogleFonts.inter(
              color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
