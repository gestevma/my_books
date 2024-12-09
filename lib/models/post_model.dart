import 'package:cloud_firestore/cloud_firestore.dart';

//Almacena los datos de un pos para un usuario concreto
class Post {
  String id;
  String userName;
  String type;
  String text;
  String? postContentText;
  String bookId;
  Timestamp createdAt;

  Post({
    required this.id,
    required this.userName,
    required this.type,
    required this.text,
    this.postContentText,
    required this.bookId,
    required this.createdAt,
  });

  //Mapea los datos devueltos por la base de datos para construir un objeto tipo post
  factory Post.fromMap(Map<String, dynamic> docData, String docId) {
    return Post(
      id: docId,
      userName: docData['userName'] ?? "",
      type: docData['type'] ?? "",
      text: docData['text'] ?? "",
      postContentText: docData['postContentText'],
      bookId: docData['bookId'] ?? [],
      createdAt: docData["created_at"] ?? "",
    );
  }
}
