import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextCompose extends StatefulWidget {
  TextCompose(this.sendMessage, {Key? key}) : super(key: key);
  final Function({String texto,File imageFile}) sendMessage;

  @override
  State<TextCompose> createState() => _TextComposeState();
}

class _TextComposeState extends State<TextCompose> {
  bool _isComposing = false;
  final TextEditingController _controller = TextEditingController();
  ImagePicker _picker = ImagePicker();

  void _reset() {
    setState(() {
      _isComposing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: ()async {
              final XFile? xfile = await _picker.pickImage(source: ImageSource.camera);
              File file = File(xfile!.path);

              if(file == null){
                return;
              }else{
                 widget.sendMessage(imageFile: file);
              }
            },
            icon: Icon(Icons.camera_alt),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration:
                  InputDecoration.collapsed(hintText: "Enviar uma mensagem"),
              onChanged: (texto) {
                setState((){
                  _isComposing = texto.isNotEmpty;
                });
              },
              onSubmitted: (text) {
                widget.sendMessage(texto: text);
                _controller.clear();
                _reset();
              },
            ),
          ),
          IconButton(
            onPressed: _isComposing
                ? () {
                    widget.sendMessage(texto:_controller.text);
                    _reset();
                    _controller.clear();
                  }
                : null,
            icon: Icon(Icons.send),
          )
        ],
      ),
    );
  }
}
