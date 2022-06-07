import 'package:chat_online/chat_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  //Necessário para o Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
  
  // FirebaseFirestore.instance.collection('mensagens').doc().set({
  //   'texto': "Tudo bem?",
  //   'from': "João",
  //   'read': false,
  // });

  //Ler dados apenas uma vez
  // QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('mensagens').get();
  // snapshot.docs.forEach((d) {
  //   print(d.data());
  //   d.reference.updateData({"lido":false});
  // });

  //Ler um dado específico
  // DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection('mensagens').doc("MWOLCYzPi8SI0qBgXV2b").get();
  // print(documentSnapshot.data());

  //Obter atualizações em tempo real
  // FirebaseFirestore.instance.collection('mensagens').snapshots().listen((dado) {
  //   //print(dado.docs[0].data());
  //   dado.docs.forEach((d) {
  //     print(d.data());
  //   });
  // });

  //Ler atualizações de um doc specifico
  // FirebaseFirestore.instance.collection("mensagens").doc("MWOLCYzPi8SI0qBgXV2b").snapshots().listen((dado) {
  //   print(dado.data());
  // });
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        iconTheme: IconThemeData(
          color: Colors.blue
        )
      ),
      home: ChatScreen()
    );
  }
}