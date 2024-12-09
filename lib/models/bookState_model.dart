import 'package:cloud_firestore/cloud_firestore.dart';

//Mapea los datos del estado de un libro para un usuario
class BookState {
  String id;
  String state;
  String userName;
  String bookId;
  Timestamp createdAt;

  BookState({
    required this.id,
    required this.state,
    required this.userName,
    required this.bookId,
    required this.createdAt,
  });

  //Mapea el resultado devuelto por la base de datos al objeto BookState
  factory BookState.fromMap(Map<String, dynamic> docData, String docId) {
    return BookState(
      id: docId,
      state: docData['state'],
      userName: docData['userName'],
      bookId: docData['bookId'],
      createdAt: docData['created_at'],
    );
  }
}
