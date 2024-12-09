import 'package:flutter/material.dart';
import 'package:my_books/models/bookUsersInteractions_model.dart';
import 'package:my_books/models/book_model.dart';
import 'package:my_books/models/user_model.dart';
import 'package:my_books/providers/bookTag_provider.dart';
import 'package:my_books/providers/bookUsersInteractions_provider.dart';
import 'package:my_books/providers/books_provider.dart';
import 'package:my_books/screens/bookInfo_screen.dart';
import 'package:my_books/widgets/personalizedAppBar.dart';

class DiscoverScreen extends StatefulWidget {
  final User connectedUser;
  const DiscoverScreen({Key? key, required this.connectedUser})
      : super(key: key);

  @override
  _DiscoverScreenState createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final TextEditingController _searchController = TextEditingController();

  //Variables que guardarán la información de los libros
  List<Book>? searchedBooks;
  List<Book>? recommendedBooks;

  // Cargar las recomendaciones del usuario
  _loadRecommendations() async {
    final bookProvider = BookProvider();
    final booktagProvider = BooktagProvider();

    List<Book>? loadBooksList = [];

    //Carga las ids de los libros con tags de interés para el usuario.
    List<String> loadRecommendedBooksId =
        await booktagProvider.getRecomededBooksIds(widget.connectedUser);

    //Guardamos la lista de libros de los ids que nos ha devuelto getRecomededBooksIds(), que seán los libros con las etiquetas de interés
    for (String bookId in loadRecommendedBooksId) {
      Book? loadBook = await bookProvider.getBookById(bookId);
      if (loadBook != null) {
        loadBooksList.add(loadBook);
      }
    }

    if (!mounted) return;
    setState(() {
      recommendedBooks = loadBooksList;
    });
  }

  //Carga los libros que buscamos
  _loadSearchBooks(String bookName) async {
    final bookProvider = BookProvider();

    List<Book>? loadBooksList = [];

    //Cargamos una lista de libros encontrados por la api según el string que le pasemos por parámetro
    loadBooksList = await bookProvider.getBooksByName(bookName);

    setState(() {
      searchedBooks = loadBooksList;
    });
  }

  //Al iniciar la pantalla cargamos la lista de recomendacioens
  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = BookProvider();

    // Si las recomendaciones están siendo cargadas, mostramos un indicador de carga
    if (recommendedBooks == null) {
      return Scaffold(
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: PersonalizedAppbar(
        title: 'Descubre',
        connectedUser: widget.connectedUser,
      ),
      body: Column(
        children: [
          // Parte superior: El buscador
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              height: 40,
              color: Colors.white,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Buscar...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onChanged: (query) {
                  setState(() {
                    if (query.isNotEmpty || query != "") {
                      // Si hay texto, realizamos la búsqueda
                      _loadSearchBooks(query);
                      recommendedBooks = [];
                    } else {
                      // Si el campo está vacío, mostramos las recomendaciones
                      _loadRecommendations();
                      searchedBooks = [];
                    }
                  });
                },
              ),
            ),
          ),
          recommendedBooks != null && recommendedBooks!.isNotEmpty
              ? Text(
                  "Libros recomendados",
                  style: TextStyle(
                    fontSize: 18, // Tamaño de la letra
                    fontWeight: FontWeight.bold, // Texto en negrita
                  ),
                )
              : Container(),
          Expanded(
            child: bookProvider.isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount:
                        recommendedBooks != null && recommendedBooks!.isNotEmpty
                            ? recommendedBooks!.length
                            : searchedBooks != null && searchedBooks!.isNotEmpty
                                ? searchedBooks!.length
                                : 0,
                    itemBuilder: (context, index) {
                      final book =
                          recommendedBooks == null || recommendedBooks!.isEmpty
                              ? searchedBooks![index]
                              : recommendedBooks![index];

                      //Hacemos que al clicar sobre un libro encontrado podamos acceder a la pantalla con su información
                      return GestureDetector(
                        onTap: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookinfoScreen(
                                book: book,
                                connectedUser: widget.connectedUser,
                                returnWidget: DiscoverScreen(
                                    connectedUser: widget.connectedUser),
                              ),
                            ),
                          );
                        },
                        child: Card(
                          color: Colors.white,
                          elevation: 2,
                          margin:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Imagen del libro
                                book.image.isNotEmpty
                                    ? Image.network(
                                        book.image,
                                        width: 60,
                                        height: 90,
                                        fit: BoxFit.cover,
                                      )
                                    : Icon(Icons.book, size: 60),
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
                                      FutureBuilder<BookUsersInteractions?>(
                                        future: BookUsersInteractionsProvider()
                                            .getBookById(book.id),
                                        builder: (context, snapshot) {
                                          if (!mounted)
                                            return SizedBox.shrink();
                                          if (snapshot.hasError) {
                                            return Text('');
                                          } else if (snapshot.hasData) {
                                            final firebaseBook = snapshot.data;
                                            return Text(
                                              'Me gusta ♡: ${firebaseBook?.likes ?? 0}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                            );
                                          } else {
                                            return Text('Me gusta ♡: 0');
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
