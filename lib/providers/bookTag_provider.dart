import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_books/models/bookTag_model.dart';
import 'package:my_books/models/book_model.dart';
import 'package:my_books/models/user_model.dart';

//Clase que interactua con la colección de bookTags
class BooktagProvider extends ChangeNotifier {
  //Permite obtener un bookTag por su id
  Future<Booktag?> getBookTagById(String id) async {
    Booktag? bookTagsInfo;
    try {
      //Llamamos a la base de datos, pidiendo que nos devuelva de booksTags el doeumento que tenga la id indicado por parámetro
      DocumentSnapshot<Map<String, dynamic>> bookTagSnapshot =
          await FirebaseFirestore.instance
              .collection('booksTags')
              .doc(id)
              .get();

      //Mapeamos el resultado de la base de datos a un objeto tipo BookTag
      bookTagsInfo = Booktag.fromMap(bookTagSnapshot.data()!, id);
    } catch (e) {
      print("${e}");
    }

    notifyListeners();

    //Devolvemos el Booktag mapeado
    return bookTagsInfo;
  }

  //Permite crear un nuevo registro en el documento bookstags
  Future<void> createBookTag(Booktag bookTag) async {
    try {
      // Referencia a la colección "booksTags"
      CollectionReference reviewsCollection =
          FirebaseFirestore.instance.collection('booksTags');

      // Crear un nuevo documento en la colección reviews
      await reviewsCollection.doc(bookTag.id).set({
        "bookId": bookTag.bookId,
        "addedUsers": bookTag.addedUsers,
        "complaintUsers": [],
        "tagName": bookTag.tagName,
      });

      print("Documento creado correctamente.");
    } catch (e) {
      print("Error al crear el documento: $e");
    }

    notifyListeners();
  }

  //Permite actualizar un documento de booksTags
  Future<void> updateBookTag(Booktag bookTag) async {
    try {
      // Referencia al documento que deseas actualizar
      DocumentReference bookTagRef =
          FirebaseFirestore.instance.collection('booksTags').doc(bookTag.id);

      // Actualización del documento
      await bookTagRef.update({
        "bookId": bookTag.bookId,
        "addedUsers": bookTag.addedUsers,
        "complaintUsers": bookTag.complaintUsers,
        "tagName": bookTag.tagName,
      });

      print("Documento actualizado correctamente.");
    } catch (e) {
      print("Error al actualizar el documento: $e");
    }
  }

  //Elimina un registro de la colección bookTags
  Future<void> deleteBookTag(Booktag bookTag) async {
    List<Booktag> deleteBookTagList = [];

    try {
      // Consulta para encontrar documentos que coincidan con los valores
      DocumentReference bookTagRef = FirebaseFirestore.instance
          .collection('booksTags') // Colección de tags
          .doc(bookTag.id);

      bookTagRef.delete();

      print('Todos los documentos coincidentes han sido eliminados.');
    } catch (e) {
      print('Error al eliminar documentos: $e');
    }
  }

  //Permite obtener una lista de ids de libros recomendados para un usuario
  Future<List<String>> getRecomededBooksIds(User connectedUser) async {
    List<dynamic>? userTags = connectedUser.interestedTags;
    List<String> booksIdList = [];
    try {
      // Realizamos la consulta en Firestore usando 'arrayContainsAny' que devolverá cualquier registro de booksTags donde el tagName esté en userTags (tags de interés para el usuario)
      QuerySnapshot booksSnapshot = await FirebaseFirestore.instance
          .collection('booksTags')
          .where('tagName', whereIn: userTags)
          .get();

      // Mapeamos el resultado de la consulta
      List<Booktag> bookTagsList = booksSnapshot.docs.map((doc) {
        return Booktag.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      //Añadimos solo aquellos documentos donde consideramos que el tag pueda verse
      for (Booktag booktag in bookTagsList) {
        if (!booksIdList.contains(booktag.bookId)) {
          if (booktag.addedUsers.length >= 5 &&
              booktag.addedUsers.length > booktag.complaintUsers.length) {
            //Si el tag puede verse (añadido al menos 5 veces y que no haya sido denunciado por más usuarios)
            booksIdList.add(booktag.bookId);
          }
        }
      }

      //Devolvemos el resultado del mapeo
      return booksIdList;
    } catch (e) {
      print("Error al obtener libros: $e");

      //En caso de error devolvemos una lista vacia
      return [];
    }
  }

  //Devuelve la lista de tags que el usuario haya marcado para un libro en concreto
  Future<List<Booktag>> booksAdded(User user, Book book) async {
    List<Booktag> bookTagsList = [];

    try {
      // Realizamos la consulta en Firestore usando 'arrayContainsAny' para buscar los booksTags donde el usuario haya añadido ese tag
      QuerySnapshot booksSnapshot = await FirebaseFirestore.instance
          .collection('booksTags')
          .where('addedUsers', arrayContains: user.userName)
          .where('bookId', isEqualTo: book.id)
          .get();

//Mapeamos el resultado en un objeto BookTag
      bookTagsList = booksSnapshot.docs.map((doc) {
        return Booktag.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      //Devolvemos el resultado del mapeo, La lista de tags que el usuario haya añadido a un libro
      return bookTagsList;
    } catch (e) {
      print("Error al obtener libros: $e");
      return [];
    }
  }

  //Devuelve la lista de tags que el usuario haya denunciado para un libro
  Future<List<Booktag>> complaintBooks(User user, Book book) async {
    List<Booktag> bookTagsList = [];

    try {
      // Realizamos la consulta en Firestore usando 'arrayContainsAny' que busque los tags donde el usuario haya denunciado el tag para un libro
      QuerySnapshot booksSnapshot = await FirebaseFirestore.instance
          .collection('booksTags')
          .where('complaintUsers', arrayContains: user.userName)
          .where('bookId', isEqualTo: book.id)
          .get();

      // Mapeamos el resultado de la consulta en una lista de objetos tipo BookTags
      bookTagsList = booksSnapshot.docs.map((doc) {
        return Booktag.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      //Devolvemos la lista de tags que el usuario haya denunciado, para un libro concreto
      return bookTagsList;
    } catch (e) {
      print("Error al obtener libros: $e");
      //En caso de error devuelve una lista vacia
      return [];
    }
  }
}
