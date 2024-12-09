import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_books/models/book_model.dart';

//Clase que se encarga de la comunicación con la api de google gooks y mapear los datos en los objetos de interés
class BookProvider extends ChangeNotifier {
  List<Book> booksResultList = [];
  bool isLoading = false;
  Book? book;

  //Obtiene una lista de libros obtenidos al buscar el titulo insertado por parámetro
  Future<List<Book>?> getBooksByName(String bookName) async {
    isLoading = true;
    List<Book> booksList = [];
    notifyListeners();

    //Creamos la url que hará la llamada a la api. Esta url permite obtener libros por su título.
    //Insertamos una variable que es el título del libro
    var url = Uri.https(
        'www.googleapis.com', 'books/v1/volumes', {'q': '${bookName}'});
    try {
      final response = await http.get(url);

      //Recogemos los datos devueltos por la api
      Map<String, dynamic> data = json.decode(response.body);
      List<dynamic> items = data['items'];

      //Mapeamos los datos devueltos por la api a un objeto de tipo book. Cada objeto
      for (int i = 0; i < items.length; i++) {
        final bookResponse = Book.fromRawJsonList(i, response.body);

        //Cada libro mapeado lo insertamos en una lista
        booksList.add(bookResponse);
      }
    } catch (e) {
      //En caso de error en la llamada devolvemos null
      print('Error al obtener los libros (getBooksByName): $e');
      return null;
    }

    isLoading = false;

    notifyListeners();

    //Devolvemos la lista con todos los libros encontrados a partir del título insertado por parámetro
    return booksList;
  }

  //Permite obtener un libro desde la api de google books a partir de su id
  Future<Book?> getBookById(String id) async {
    this.book = null;
    Book? bookResponse;

    try {
      //Configuramos la app de la llamada a la api, insertando la id del libro que buscamos
      final String url = "https://www.googleapis.com/books/v1/volumes/${id}";

      //Guardamos la respuesta de la api
      final response = await http.get(Uri.parse(url));

      //Mapeamos los datos devueltos en un objeto de tipo Book
      bookResponse = Book.fromRawJson(response.body);

      // Notificamos a los oyentes sobre la actualización
      notifyListeners();

      //Devolvemos el libro devuelto
      return bookResponse;
    } catch (e) {
      // En caso de error en la llamada devolvemos null
      print('Error al obtener el libro: $e');
      notifyListeners();
      return null;
    }
  }
}
