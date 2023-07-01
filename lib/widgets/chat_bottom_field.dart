// ignore_for_file: use_build_context_synchronously
import 'package:musikat_app/models/chat_message_model.dart';
import 'package:musikat_app/utils/exports.dart';

class ChatBottomField extends StatelessWidget {
  ChatBottomField({required this.chat, Key? key, required this.chatroom}) : super(key: key);

  final ChatMessage chat;
   final String chatroom;
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
            children: [editMessage(context), deleteMessage(context)],
          ),
        ),
      ),
    );
  }

  ListTile deleteMessage(BuildContext context) {
    return ListTile(
      title: Text('Delete',
          style: GoogleFonts.inter(color: Colors.white, fontSize: 16)),
      leading: const Icon(
        Icons.delete,
        color: Colors.white,
      ),
      onTap: () => {
        Navigator.of(context).pop(),
        chat.individualDeleteMessage(chatroom),
      },
    );
  }

  ListTile editMessage(BuildContext context) {
    return ListTile(
      title: Text(
        'Edit',
        style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
      ),
      leading: const Icon(Icons.edit, color: Colors.white),
      onTap: () => {
        _textController.text = chat.message,
        Navigator.of(context).pop(),
        showDialog(
          context: context,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: musikatColor4,
            child: SingleChildScrollView(
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
                                  borderRadius: BorderRadius.circular(12)),
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
          ),
        )
      },
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
          fontSize: 10,
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
          chat.individualUpdateMessage(value, chatroom);
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
