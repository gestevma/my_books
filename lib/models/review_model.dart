import 'package:cloud_firestore/cloud_firestore.dart';

//Almacena los datos de una reseña de un usuario concreto
class Review {
  String id;
  String userName;
  String bookId;
  String text;
  Timestamp createdAt;

  Review({
    required this.id,
    required this.userName,
    required this.bookId,
    required this.text,
    required this.createdAt,
  });

  //Mapea los datos devueltos por la base de datos hacia un objeto tipo review
  factory Review.fromMap(Map<String, dynamic> docData, String docId) {
    return Review(
      id: docId,
      userName: docData['userName'] ?? "",
      bookId: docData['bookId'] ?? "",
      text: docData['text'] ?? "",
      createdAt: docData['created_at'] ?? Timestamp.fromDate(DateTime.now()),
    );
  }
}
