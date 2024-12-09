import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_books/models/bookState_model.dart';
import 'package:my_books/models/bookUsersInteractions_model.dart';
import 'package:my_books/models/book_model.dart';
import 'package:my_books/models/user_model.dart';
import 'package:my_books/utilities/generateRandomId.dart';

//Clase que realiza llamadas a la colección BookState
class BookstateProvider extends ChangeNotifier {
  //Permite obtener el estado de un libro para un usuario a partir de su id
  Future<BookState> getBookStateById(String id) async {
    //Realizamos la llamada a la base de datos, indicando que nos devuelva el documento de BooksStates con la id pasada por parámetro
    DocumentSnapshot<Map<String, dynamic>> bookStateSnapshot =
        await FirebaseFirestore.instance
            .collection('booksStates')
            .doc(id)
            .get();

    //Mapeamos el resultado de la llamada en un objeto de tipo BookState
    BookState bookStateInfo = BookState.fromMap(bookStateSnapshot.data()!, id);

    //Notificamos a todos los providers
    notifyListeners();

    //Devolvemos el bookState obtenido
    return bookStateInfo;
  }

  //Obtiene la lista de libros con un estado concreto para un usuario
  Future<List<BookState>> getByState(String state, User user) async {
    List<BookState> bookStateList = [];

    //Hacemos la llamada a la base de datos, indicando que recoja los documentos de la colección bookState donde el estado y el usuario sean los que pongamos por parámetro
    QuerySnapshot<Map<String, dynamic>> bookStatesSnapshot =
        await FirebaseFirestore.instance
            .collection('booksStates')
            .where("state", isEqualTo: state)
            .where("userName", isEqualTo: user.userName)
            .get();

    //Si la llamada devuelve algo guardamos los valores en una lista
    if (bookStatesSnapshot.docs.isNotEmpty) {
      //Para cada resultado devuelto por la base de datos creamos un objeto de tipoo BookState
      for (var doc in bookStatesSnapshot.docs) {
        BookState bookState = BookState.fromMap(doc.data(), doc.id);

        //El bookState obtenido lo insertamos en una lista
        bookStateList.add(bookState);
      }
    }

    notifyListeners();

    //Devolvemos la lista con la lista de libros con ese estado para el usuario indicado
    return bookStateList;
  }

  //Crea una nueva entrada en la colección estados, indicando el estado que tiene un libro para un usuario
  Future<BookState?> createBookState(Book book, User user) async {
    //Creamos un nuevo objeto bookState que insertaremos en la base de datos
    BookState bookState = BookState(
      id: Utilities().generateRandomId(20),
      state: "Ningún estado seleccionado",
      userName: user.userName,
      bookId: book.id,
      createdAt: Timestamp.fromDate(DateTime.now()),
    );
    try {
      // Referencia a la colección "booksStates"
      CollectionReference booksStatesCollection =
          FirebaseFirestore.instance.collection('booksStates');

      // Crear un nuevo documento en la colección booksStates
      await booksStatesCollection.doc(bookState.id).set({
        "state": bookState.state,
        "userName": bookState.userName,
        "bookId": bookState.bookId,
        "created_at": Timestamp.fromDate(DateTime.now()),
      });

      print("Documento creado correctamente.");
    } catch (e) {
      print("Error al crear el documento: $e");
    }

    notifyListeners();

    //Devuelve el objeto creado
    return bookState;
  }

  //Actualiza el estado de un libro para un usuario
  void updateBookState(BookState bookState) async {
    try {
      // Llamamos a la base de datos indicanto que actualizaremos el documento con el id del bookState indicado
      DocumentReference bookStateRef = FirebaseFirestore.instance
          .collection('booksStates')
          .doc(bookState.id);

      DocumentSnapshot snapshot = await bookStateRef.get();

      if (snapshot.exists) {
        // Actualización del documento
        await bookStateRef.update({
          "state": bookState.state,
          "userName": bookState.userName,
          "bookId": bookState.bookId,
        });
      } else {
        print("Ningún documento BookStates encontrado");
      }

      print("Documento actualizado correctamente.");
    } catch (e) {
      print("Error al actualizar el documento: $e");
    }

    notifyListeners();
  }

  //Obtiene el estado de un libro para un usuario en concreto
  Future<BookState?> getUserBookState(
      BookUsersInteractions bookInteractiosn, User user) async {
    BookState? bookStateInfo;

    List<BookState> bookStatesList = [];

    final booksStatesRef = FirebaseFirestore.instance.collection('booksStates');

    try {
      // Llamada a la base de datos para que nos devuelva el estado que tiene el libro indicado para el usuario que pedimos
      final bookStatesSnapshot = await booksStatesRef
          .where('userName', isEqualTo: user.userName)
          .where("bookId", isEqualTo: bookInteractiosn.id)
          .get();

      // Verifica si la consulta devolvió resultados
      if (bookStatesSnapshot.docs.isNotEmpty) {
        //Mapeamos el resulltado en un objeto de tipo BookState
        for (var doc in bookStatesSnapshot.docs) {
          BookState bookState = BookState.fromMap(doc.data(), doc.id);

          bookStateInfo = bookState;
        }
      }

      bookStatesList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      print('Error');
    }

    notifyListeners();

    //Devolvemos el estado del libro para el usuario
    return bookStateInfo;
  }
}
