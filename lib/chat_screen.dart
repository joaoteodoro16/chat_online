import 'package:chat_online/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'chat_message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  User? _currentyUser;
  final GlobalKey<ScaffoldState> _scaffolfKey = GlobalKey<ScaffoldState>();
  bool _isLoading =false;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((firebaseUser) {
      setState((){
        _currentyUser = firebaseUser;
      });
    });
  }

  Future<User?> _getUser() async {
    if (_currentyUser != null) return _currentyUser;
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignIn.clientId,
          accessToken: googleSignInAuthentication.accessToken);

      final UserCredential authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = authResult.user;

      return user;
    } catch (e) {
      print(e);
    }
  }

  void _sendMessage({String? texto, File? imageFile}) async {
    //pega usuário atual
    final User? user = await _getUser();

    if (user == null) {
      _scaffolfKey.currentState?.showSnackBar(SnackBar(
          content: Text("Não foi possível fazer o login. Tente novamente!")));
    }

    Map<String, dynamic> data = {
      "uid": user?.uid,
      "senderName": user?.displayName,
      "senderPhotoUrl": user?.photoURL,
      "time": Timestamp.now(),
    };

    if (imageFile != null) {
      UploadTask task = FirebaseStorage.instance
          .ref()
          .child(DateTime.now().microsecondsSinceEpoch.toString())
          .putFile(imageFile);

      setState((){
        _isLoading = true;
      });

      TaskSnapshot taskSnapshot = await task;
      String url = await taskSnapshot.ref.getDownloadURL();
      data['imgUrl'] = url;

      setState((){
        _isLoading = false;
      });

    }
    if (texto != null) {
      data['text'] = texto;
    }
    FirebaseFirestore.instance.collection("mensagens").add(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffolfKey,
      appBar: AppBar(
        title: Text(_currentyUser != null
            ? 'Olá, ${_currentyUser?.displayName}'
            : 'Chat app'),
        elevation: 0,
        actions: [
          _currentyUser != null
              ? IconButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    googleSignIn.signOut();
                    _scaffolfKey.currentState?.showSnackBar(SnackBar(
                        content: Text("Você saiu com sucesso!")));
                  },
                  icon: Icon(Icons.exit_to_app))
              : Container(),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('mensagens').orderBy('time')
                  .snapshots(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  default:
                    List<DocumentSnapshot> documents =
                        snapshot.data!.docs.reversed.toList();
                    return ListView.builder(
                      itemBuilder: (context, index) {
                        return ChatMessage(
                            (documents[index].data() as Map<String, dynamic>),
                            (documents[index].data()as Map<String, dynamic>)['uid'] == _currentyUser?.uid);
                      },
                      itemCount: documents.length,
                      reverse: true,
                    );
                }
              },
            ),
          ),
          _isLoading ? LinearProgressIndicator() : Container(),
          TextCompose(_sendMessage),
        ],
      ),
    );
  }
}
