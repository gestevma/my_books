import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_books/models/bookState_model.dart';
import 'package:my_books/models/book_model.dart';
import 'package:my_books/models/post_model.dart';
import 'package:my_books/models/user_model.dart';
import 'package:my_books/providers/bookState_provider.dart';
import 'package:my_books/providers/books_provider.dart';
import 'package:my_books/providers/post_provider.dart';
import 'package:my_books/providers/user_provider.dart';
import 'package:my_books/screens/bookInfo_screen.dart';
import 'package:my_books/widgets/personalizedAppBar.dart';

class ProfileScreen extends StatefulWidget {
  final User user;
  final User connectedUser;

  const ProfileScreen(
      {Key? key, required this.user, required this.connectedUser})
      : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic>? postsCompleteInfoList;
  List<Book>? booksLikedList;
  List<Book>? readBooksList;
  List<Book>? readingBooksList;
  List<Book>? wantReadBooksList;
  bool isFriend = false;

  @override
  void initState() {
    super.initState();
    // Inicializar el TabController
    _tabController = TabController(
        length: widget.user.userName == widget.connectedUser.userName ? 2 : 3,
        vsync: this);

    _loadInitialData();
// Agrega un listener para reconstruir la vista al cambiar de pestaña
    _tabController.addListener(() {
      setState(() {});
    });
  }

  //Carga la información inicial
  void _loadInitialData() async {
    //Carga los posts del usuario
    await _loadPostsList();

    //Carga los libros marcados como me gusta
    await _loadLikedBooksList();

    if (widget.user != widget.connectedUser) {
      //Carga los estados de los libros
      await _loadBookStates();

      //Indica si el usuario que estamos consultando es amigo o no
      await _loadIsFriend();
    }
  }

  _loadPostsList() async {
    PostProvider postProvider = PostProvider();

    List<Post> userPostsListLoad = await postProvider.getUserPosts(widget.user);

    //Ordenamos los posts devueltos por su fecha de creación
    userPostsListLoad.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    List<dynamic> userPostsCompleteInfoLoad =
        await postProvider.getPostsCompleteInfo(userPostsListLoad);

    setState(() {
      postsCompleteInfoList = userPostsCompleteInfoLoad;
    });
  }

  _loadLikedBooksList() async {
    PostProvider postProvider = PostProvider();

    BookProvider bookProvider = BookProvider();

    List<Post> likePostsListLoad = [];
    List<Book> likedBooksListLoad = [];

    likePostsListLoad = await postProvider.getLikedPostst(widget.user);

    //Ordenamos los posts devueltos por su fecha de creación
    likePostsListLoad.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    for (Post likePost in likePostsListLoad) {
      Book? likedBookLoad;

      likedBookLoad = await bookProvider.getBookById(likePost.bookId);

      if (likedBookLoad != null) {
        likedBooksListLoad.add(likedBookLoad);
      }
    }

    setState(() {
      booksLikedList = likedBooksListLoad;
    });
  }

  //Crea una lista de libros leidos por un usuario
  _loadBookStates() async {
    BookstateProvider bookstateProvider = BookstateProvider();
    BookProvider bookProvider = BookProvider();

    List<BookState> booksReadStateListLoad = [];
    List<Book> readBooksListLoad = [];

    List<BookState> booksReadingStateListLoad = [];
    List<Book> readingBooksListLoad = [];

    List<BookState> booksWantReadStateListLoad = [];
    List<Book> wantReadBooksListLoad = [];

    booksReadStateListLoad =
        await bookstateProvider.getByState("Leído", widget.user);
    booksReadingStateListLoad =
        await bookstateProvider.getByState("Leyendo", widget.user);
    booksWantReadStateListLoad =
        await bookstateProvider.getByState("Quiero leer", widget.user);

    //Recogemos la información de los libros devueltos, buscando por id
    for (BookState bookStateRead in booksReadStateListLoad) {
      Book? loadReadBook = await bookProvider.getBookById(bookStateRead.bookId);

      if (loadReadBook != null) {
        readBooksListLoad.add(loadReadBook);
      }
    }

    //Recogemos la información de los libros devueltos, buscando por id
    for (BookState bookStateReading in booksReadingStateListLoad) {
      Book? loadReadingBook =
          await bookProvider.getBookById(bookStateReading.bookId);

      if (loadReadingBook != null) {
        readingBooksListLoad.add(loadReadingBook);
      }
    }

    //Recogemos la información de los libros devueltos, buscando por id
    for (BookState bookStateWantRead in booksWantReadStateListLoad) {
      Book? loadWantReadBook =
          await bookProvider.getBookById(bookStateWantRead.bookId);

      if (loadWantReadBook != null) {
        wantReadBooksListLoad.add(loadWantReadBook);
      }
    }

    //Asignamos el valor a la variable de la clase de libros leidos por los devueltos por la llamada
    setState(() {
      readBooksList = readBooksListLoad;
      readingBooksList = readingBooksListLoad;
      wantReadBooksList = wantReadBooksListLoad;
    });
  }

  //Comprueba si el usuario del que estamos viendo el perfil es amigo o no
  _loadIsFriend() async {
    UserProvider userProvider = UserProvider();

    bool loadIsFriend = false;

    //Cargamos la lista de amigos del usuario
    List<User>? friendsList =
        await userProvider.getFriends(widget.connectedUser);

    for (User friend in friendsList) {
      if (friend.userName == widget.user.userName) {
        loadIsFriend = true;
        break;
      }
    }

    setState(() {
      isFriend = loadIsFriend;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PersonalizedAppbar(
        title: 'Perfil de usuario',
        backRow: widget.user != widget.connectedUser ? true : false,
        connectedUser: widget.connectedUser,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: widget.user.picture != null
                          ? NetworkImage(widget.user.picture!)
                          : null,
                      child: widget.user.picture == null
                          ? Icon(Icons.person,
                              size: 40, color: Colors.grey[700])
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      widget.user.userName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ],
                ),
                widget.user != widget.connectedUser
                    ? OutlinedButton.icon(
                        onPressed: () {
                          UserProvider userProvider = UserProvider();
                          widget.connectedUser.friendsNameList ?? [];

                          if (!isFriend) {
                            widget.connectedUser.friendsNameList!
                                .add(widget.user.userName);
                            setState(() {
                              isFriend = true;
                            });
                          } else {
                            widget.connectedUser.friendsNameList!
                                .remove(widget.user.userName);
                            setState(() {
                              isFriend = false;
                            });
                          }

                          userProvider.updateUser(widget.connectedUser);
                        },
                        icon: Icon(
                          isFriend
                              ? Icons.person_remove
                              : Icons.person_add_alt_rounded,
                          color: isFriend ? Colors.redAccent : Colors.blueGrey,
                        ),
                        label: Text(
                          isFriend ? "Dejar de seguir" : "Seguir",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blueGrey,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Colors.blueGrey, // Color del borde
                            width: 3, // Ancho del borde
                          ),
                          fixedSize: const Size(150, 40), // Tamaño fijo
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                30), // Esquinas redondeadas
                          ),
                          padding: EdgeInsets
                              .zero, // Elimina espaciado interno adicional
                        ),
                      )
                    : Container(),
              ],
            ),
          ),

          // Pestañas para navegación
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.blueGrey[700],
            labelColor: Colors.blueGrey[700],
            unselectedLabelColor: Colors.grey[400],
            tabs: _buildTabs(),
          ),

          // Pantallas de contenido
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Pantalla de Actividad
                _buildActivityView(),
                // Pantalla de Likes
                _buildLikesView(),
                // Pantalla de Libros Guardados
                if (widget.user.userName != widget.connectedUser.userName)
                  _buildSavedBooksView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTabs() {
    if (widget.user.userName == widget.connectedUser.userName) {
      return [
        Tab(icon: Icon(Icons.history), text: "Actividad"),
        Tab(
          icon: Icon(
            Icons.favorite,
            color: _tabController.index == 1 ? Colors.red : Colors.grey[400],
          ),
          text: "Me gustas",
        ),
      ];
    } else {
      return [
        Tab(icon: Icon(Icons.history), text: "Actividad"),
        Tab(
          icon: Icon(
            Icons.favorite,
            color: _tabController.index == 1 ? Colors.red : Colors.grey[400],
          ),
          text: "Me gustas",
        ),
        Tab(icon: Icon(Icons.bookmark), text: "Guardados"),
      ];
    }
  }

  /// Construir vista de Actividad
  Widget _buildActivityView() {
    if (postsCompleteInfoList == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (postsCompleteInfoList!.isEmpty) {
      return Center(
        child: const Text(
          "No se ha realizado ninguna publicación",
          style: TextStyle(fontSize: 16),
        ),
      );
    } else {
      return ListView.separated(
        separatorBuilder: (BuildContext context, int index) =>
            const SizedBox(height: 10),
        padding: const EdgeInsets.all(8),
        itemCount: postsCompleteInfoList!.length,
        itemBuilder: (BuildContext context, int index) {
          final userPostCompleteInfo = postsCompleteInfoList![index];
          final Post? post = userPostCompleteInfo[0];
          final Book? bookPost = userPostCompleteInfo[1];
          final User? userPost = userPostCompleteInfo[2];
          if (post != null && bookPost != null && userPost != null) {
            DateTime createdAt =
                post!.createdAt.toDate(); // Convierte el Timestamp a DateTime
            String formattedDate =
                DateFormat('dd/MM/yyyy HH:mm').format(createdAt);
            return GestureDetector(
              // Cuando se hace clic en cualquier parte del contenedor
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookinfoScreen(
                      connectedUser: widget.connectedUser,
                      book: bookPost!,
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Imagen del usuario
                        CircleAvatar(
                          backgroundImage: NetworkImage(
                              userPost!.picture != null
                                  ? userPost.picture!
                                  : ""),
                          radius: 20,
                        ),
                        const SizedBox(width: 10),
                        // Nombre del usuario
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userPost.userName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.75,
                              child: Text.rich(
                                TextSpan(
                                  text: post.text,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: bookPost!.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                softWrap: true,
                                overflow: TextOverflow.visible,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Imagen de la publicación
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            bookPost.image,
                            width: 125,
                            height: 150,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          // Usamos Expanded para que el texto ocupe el espacio disponible
                          child: Expanded(
                            // Usamos Expanded para que el texto ocupe el espacio disponible
                            child: post.postContentText != null
                                ? post.type == "bookTags"
                                    ? Wrap(
                                        spacing: 8.0,
                                        runSpacing: 4.0,
                                        children: (post.postContentText ?? '')
                                            .split(',')
                                            .map((item) => Chip(
                                                  label: Text(item.trim()),
                                                  backgroundColor:
                                                      Colors.blueGrey[200],
                                                  labelStyle: const TextStyle(
                                                      color: Colors.white),
                                                  shape: const StadiumBorder(),
                                                ))
                                            .toList(),
                                      )
                                    : Text(
                                        post.postContentText!,
                                        style: TextStyle(fontSize: 14),
                                        softWrap: true,
                                        overflow: TextOverflow.visible,
                                      )
                                : Container(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Container();
          }
        },
      );
    }
  }

  /// Construir vista de Likes
  Widget _buildLikesView() {
    if (booksLikedList == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (booksLikedList!.isEmpty) {
      return Center(
        child: const Text(
          "Ningún libro marcado como  \"Me gusta\" ",
          style: TextStyle(fontSize: 16),
        ),
      );
    } else {
      return ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: booksLikedList!.length,
        itemBuilder: (BuildContext context, int index) {
          final likedBook = booksLikedList![index];

          return GestureDetector(
              // Cuando se hace clic en cualquier parte del contenedor
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookinfoScreen(
                      connectedUser: widget.connectedUser,
                      book: likedBook,
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Imagen del usuario
                        CircleAvatar(
                          backgroundImage: NetworkImage(widget.user.picture!),
                          radius: 20,
                        ),
                        const SizedBox(width: 10),
                        // Nombre del usuario
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.user.userName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.75,
                              child: Text.rich(
                                TextSpan(
                                  text: likedBook.title + " ♡",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                softWrap: true,
                                overflow: TextOverflow.visible,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Imagen de la publicación
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            likedBook.image,
                            width: 125,
                            height: 150,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ],
                ),
              ));
        },
        separatorBuilder: (BuildContext context, int index) =>
            const SizedBox(height: 10),
      );
    }
  }

  /// Construir vista de Libros Guardados
  Widget _buildSavedBooksView() {
    if (readBooksList == null ||
        readingBooksList == null ||
        wantReadBooksList == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    children: wantReadBooksList!.isEmpty
                        ? [Text("Ningún libro pendiente")]
                        : wantReadBooksList!.map((book) {
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
                    children: readingBooksList!.isEmpty
                        ? [Text("No estás leyendo ningún libro")]
                        : readingBooksList!.map((book) {
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
                    children: readBooksList!.isEmpty
                        ? [Text("Ningún libro registrado como leído")]
                        : readBooksList!.map((book) {
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
