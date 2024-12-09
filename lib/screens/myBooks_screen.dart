import 'package:flutter/material.dart';
import 'package:my_books/models/bookState_model.dart';
import 'package:my_books/models/book_model.dart';
import 'package:my_books/models/user_model.dart';
import 'package:my_books/providers/bookState_provider.dart';
import 'package:my_books/providers/books_provider.dart';
import 'package:my_books/screens/bookInfo_screen.dart';
import 'package:my_books/widgets/personalizedAppBar.dart';

class MyBooksScreen extends StatefulWidget {
  final User connectedUser; // Reemplaza `User` con tu modelo de usuario.
  const MyBooksScreen({Key? key, required this.connectedUser})
      : super(key: key);

  @override
  _MyBooksScreenState createState() => _MyBooksScreenState();
}

class _MyBooksScreenState extends State<MyBooksScreen> {
  List<Book>? readBooks;
  List<Book>? readingBooks;
  List<Book>? wantReadBooks;

  /**
   * Crea una lista de libros leidos por un usuario
   */
  Future<void> _loadReadBooks() async {
    try {
      BookstateProvider bookstateProvider = BookstateProvider();
      BookProvider bookProvider = BookProvider();

      List<BookState> booksReadStateList = [];
      List<Book> readBooksList = [];

      // Guardamos la información de los libros que ese usuario haya marcado como leídos
      booksReadStateList =
          await bookstateProvider.getByState("Leído", widget.connectedUser);

      // Recogemos la información de los libros devueltos, buscando por ID
      for (BookState bookState in booksReadStateList) {
        Book? loadReadBook = await bookProvider.getBookById(bookState.bookId);

        if (loadReadBook != null) {
          readBooksList.add(loadReadBook);
        }
      }

      // Asignamos el valor a la variable de la clase
      setState(() {
        readBooks = readBooksList;
      });
    } catch (e) {}
  }

  /**
   * Crea una lista con los libros que un usuario está leyendo
   */
  Future<void> _loadReadingBooks() async {
    try {
      BookstateProvider bookstateProvider = BookstateProvider();
      BookProvider bookProvider = BookProvider();

      List<BookState> booksReadingStateList = [];
      List<Book> readingBooksList = [];

      //Guardamos la información de los libros que ese usuario haya marcado como leidos, para obtener la id
      booksReadingStateList =
          await bookstateProvider.getByState("Leyendo", widget.connectedUser);

      //Recogemos la información de los libros devueltos, buscando por id
      for (BookState bookState in booksReadingStateList) {
        Book? loadReadingBook =
            await bookProvider.getBookById(bookState.bookId);

        if (loadReadingBook != null) {
          readingBooksList.add(loadReadingBook);
        }
      }

      //Asignamos el valor a la variable de la clase de libros leidos por los devueltos por la llamada
      setState(() {
        readingBooks = readingBooksList;
      });
    } catch (e) {}
  }

  /**
   * Crea una lista con los libros que un usuario quiere leer
   */
  Future<void> _loadWantReadBooks() async {
    try {
      BookstateProvider bookstateProvider = BookstateProvider();
      BookProvider bookProvider = BookProvider();

      List<BookState> booksWantReadStateList = [];
      List<Book> wantReadBooksList = [];

      //Guardamos la información de los libros que ese usuario haya marcado como leidos, para obtener la id
      booksWantReadStateList = await bookstateProvider.getByState(
          "Quiero leer", widget.connectedUser);

      //Recogemos la información de los libros devueltos, buscando por id
      for (BookState bookState in booksWantReadStateList) {
        Book? wantReadBook = await bookProvider.getBookById(bookState.bookId);

        if (wantReadBook != null) {
          wantReadBooksList.add(wantReadBook);
        }
      }

      //Asignamos el valor a la variable de la clase de libros leidos por los devueltos por la llamada
      setState(() {
        wantReadBooks = wantReadBooksList;
      });
    } catch (e) {}
  }

  /**
   * Creamos el estado inicial, donde cargamos la información de los libros según su estado
   */
  @override
  void initState() {
    super.initState();
    try {
      _loadReadBooks();
      _loadReadingBooks();
      _loadWantReadBooks();
    } catch (e) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MyBooksScreen(
            connectedUser: widget.connectedUser,
          ),
        ),
      );
    }
  }

  @override

  //Inicio, comprobamos si los datos han cargado correctamente, si no mostramos una panatalla de carga
  Widget build(BuildContext context) {
    if (readBooks == null || readingBooks == null || wantReadBooks == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    //cuerpo
    return Scaffold(
      appBar: PersonalizedAppbar(
        title: 'Mis libros',
        connectedUser: widget.connectedUser,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Categorías",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  // Libros leídos
                  ExpansionTile(
                    title: Text(
                      "Quiero leer",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    textColor: Colors.grey,
                    collapsedTextColor: Colors.blueGrey[700],
                    leading: Icon(Icons.bookmark_add),
                    iconColor: Colors.grey,
                    collapsedIconColor: Colors.blueGrey[700],
                    children: wantReadBooks!.isEmpty
                        ? [Text("Ningún libro pendiente")]
                        : wantReadBooks!.map((book) {
                            return GestureDetector(
                              onTap: () async {
                                // Navegar a la página de saludo al hacer clic en la tarjeta
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BookinfoScreen(
                                      book: book,
                                      connectedUser: widget.connectedUser,
                                    ),
                                  ),
                                );
                              },
                              child: Card(
                                color: Colors
                                    .white, // Color blanco para la tarjeta
                                elevation: 2,
                                margin: EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 16),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Imagen del libro
                                      book.image.isNotEmpty
                                          ? Image.network(
                                              book.image,
                                              width: 60,
                                              height: 90,
                                              fit: BoxFit.cover,
                                            )
                                          : Icon(
                                              Icons.book,
                                              size: 60,
                                            ),
                                      SizedBox(width: 16),
                                      // Información del libro
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              book.title,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              book.authors.isNotEmpty
                                                  ? book.authors.length > 1
                                                      ? "Autores: ${book.authors.join(', ')}"
                                                      : "Autor: ${book.authors.join(', ')}"
                                                  : "Autor desconocido",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            // Mostrar los likes
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                  ),
                  const SizedBox(height: 10),
                  // Libros pendientes
                  ExpansionTile(
                    title: Text(
                      "Leyendo ahora",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    textColor: Colors.grey,
                    collapsedTextColor: Colors.blueGrey[700],
                    leading: Icon(Icons.menu_book_outlined),
                    iconColor: Colors.grey,
                    collapsedIconColor: Colors.blueGrey[700],
                    children: readingBooks!.isEmpty
                        ? [Text("No estás leyendo ningún libro")]
                        : readingBooks!.map((book) {
                            return GestureDetector(
                              onTap: () async {
                                // Navegar a la página de saludo al hacer clic en la tarjeta
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BookinfoScreen(
                                      book: book,
                                      connectedUser: widget.connectedUser,
                                    ),
                                  ),
                                );
                              },
                              child: Card(
                                color: Colors
                                    .white, // Color blanco para la tarjeta
                                elevation: 2,
                                margin: EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 16),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Imagen del libro
                                      book.image.isNotEmpty
                                          ? Image.network(
                                              book.image,
                                              width: 60,
                                              height: 90,
                                              fit: BoxFit.cover,
                                            )
                                          : Icon(
                                              Icons.book,
                                              size: 60,
                                            ),
                                      SizedBox(width: 16),
                                      // Información del libro
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              book.title,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              book.authors.isNotEmpty
                                                  ? book.authors.length > 1
                                                      ? "Autores: ${book.authors.join(', ')}"
                                                      : "Autor: ${book.authors.join(', ')}"
                                                  : "Autor desconocido",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            // Mostrar los likes
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                  ),
                  const SizedBox(height: 10),
                  // Libros en lectura
                  ExpansionTile(
                    title: Text(
                      "Leidos",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    textColor: Colors.grey,
                    collapsedTextColor: Colors.blueGrey[700],
                    leading: Icon(Icons.check_circle),
                    iconColor: Colors.grey,
                    collapsedIconColor: Colors.blueGrey[700],
                    children: readBooks!.isEmpty
                        ? [Text("Ningún libro registrado como leído")]
                        : readBooks!.map((book) {
                            return GestureDetector(
                              onTap: () async {
                                // Navegar a la página de saludo al hacer clic en la tarjeta
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BookinfoScreen(
                                      book: book,
                                      connectedUser: widget.connectedUser,
                                    ),
                                  ),
                                );
                              },
                              child: Card(
                                color: Colors
                                    .white, // Color blanco para la tarjeta
                                elevation: 2,
                                margin: EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 16),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Imagen del libro
                                      book.image.isNotEmpty
                                          ? Image.network(
                                              book.image,
                                              width: 60,
                                              height: 90,
                                              fit: BoxFit.cover,
                                            )
                                          : Icon(
                                              Icons.book,
                                              size: 60,
                                            ),
                                      SizedBox(width: 16),
                                      // Información del libro
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              book.title,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              book.authors.isNotEmpty
                                                  ? book.authors.length > 1
                                                      ? "Autores: ${book.authors.join(', ')}"
                                                      : "Autor: ${book.authors.join(', ')}"
                                                  : "Autor desconocido",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            // Mostrar los likes
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
