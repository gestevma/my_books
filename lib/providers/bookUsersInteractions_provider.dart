import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_books/models/bookUsersInteractions_model.dart';
import 'package:my_books/models/book_model.dart';

//Clase que realiza llamadas a la colección BookUsersInteractionsProvider de firebase. Lo que nos permite interactuar con los datos de los libros que no nos devuelve la api, como los likes o su estado
class BookUsersInteractionsProvider extends ChangeNotifier {
  BookUsersInteractions? bookInteractions;

  //Permite obtener un libro por su id
  Future<BookUsersInteractions?> getBookById(String id) async {
    bookInteractions = null;

    try {
      // Intentamos obtener el documento desde Firestore a partir de su id
      DocumentSnapshot<Map<String, dynamic>> bookInteractionsSnapshot =
          await FirebaseFirestore.instance
              .collection('booksUsersInteractions')
              .doc(id)
              .get();

      // Comprobamos si el documento existe
      if (bookInteractionsSnapshot.exists) {
        // Si existe, obtenemos los datos
        Map<String, dynamic>? bookInteractionsData =
            bookInteractionsSnapshot.data();

        // Creamos el objeto FirebaseBook
        BookUsersInteractions bookInteractionsInfo =
            BookUsersInteractions.fromMap(bookInteractionsData!, id);

        bookInteractions = bookInteractionsInfo;

        // Notificamos a los oyentes sobre la actualización
        notifyListeners();
        // Devolvemos el objeto FirebaseBook
        return bookInteractionsInfo;
      } else {
        // Si el documento no existe, puedes devolver null o lanzar un error
        notifyListeners();
        return null;
      }
    } catch (e) {
      // Manejo de errores en caso de que haya problemas con Firestore
      print('Error al obtener el libro: $e');
      notifyListeners();
      return null;
    }
  }

  //Permite crear una nueva entrada en la colección y lo devolvemos
  Future<BookUsersInteractions?> createBookUsersInteractions(Book book) async {
    BookUsersInteractions? bookInteractionsInfo;
    try {
      //Llamamos a la colección
      CollectionReference bookInteractionsCollection =
          FirebaseFirestore.instance.collection('booksUsersInteractions');

      // Crear un nuevo documento en la colección booksUsersInteractions
      await bookInteractionsCollection.doc(book.id).set({
        'likes': 0,
        "reviewsId": [],
        "tagsList": [],
      });

      //Cargamos el libro que acabamos de crear
      bookInteractionsInfo = await getBookById(book.id);

      print("Documento creado correctamente.");
    } catch (e) {
      print("Error al crear el documento: $e");
    }

    notifyListeners();

    //Devolvemos el libro creado
    return bookInteractionsInfo;
  }

  //Actualiza un documento de la colección booksInteractions
  void updateBookInteractions(BookUsersInteractions bookInteractions) async {
    try {
      // Referencia al documento que deseas actualizar
      DocumentReference bookRef = FirebaseFirestore.instance
          .collection('booksUsersInteractions')
          .doc(bookInteractions.id);

      // Actualización del documento
      await bookRef.update({
        "likes": bookInteractions.likes,
        "reviewsId": bookInteractions.reviewsIdList,
        "tagsList": bookInteractions.tagsList,
      });

      print("Documento actualizado correctamente.");
    } catch (e) {
      print("Error al actualizar el documento: $e");
    }

    notifyListeners();
  }
}
