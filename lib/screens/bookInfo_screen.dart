import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_books/models/bookState_model.dart';
import 'package:my_books/models/bookTag_model.dart';
import 'package:my_books/models/bookUsersInteractions_model.dart';
import 'package:my_books/models/book_model.dart';
import 'package:my_books/models/review_model.dart';
import 'package:my_books/models/user_model.dart';
import 'package:my_books/providers/bookState_provider.dart';
import 'package:my_books/providers/bookTag_provider.dart';
import 'package:my_books/providers/bookUsersInteractions_provider.dart';
import 'package:my_books/providers/post_provider.dart';
import 'package:my_books/providers/review_provider.dart';
import 'package:my_books/providers/user_provider.dart';
import 'package:my_books/screens/home_screen.dart';
import 'package:my_books/widgets/addReviewDialog.dart';
import 'package:my_books/widgets/configureTagsDialogs.dart';
import 'package:my_books/widgets/personalizedAppBar.dart';

class BookinfoScreen extends StatefulWidget {
  final Book book;
  final User connectedUser;
  final bool? backArrow;
  final Widget? returnWidget;

  const BookinfoScreen(
      {Key? key,
      required this.book,
      required this.connectedUser,
      this.backArrow,
      this.returnWidget})
      : super(key: key);

  @override
  _BookinfoScreenState createState() => _BookinfoScreenState();
}

class _BookinfoScreenState extends State<BookinfoScreen> {
  BookUsersInteractions? bookInteractionsInfo;
  List<List<dynamic>>? reviewsInfoList;
  List<Booktag>? tagsList;
  bool isLiked = false;
  BookState? bookState;
  String state = "Ningún estado seleccionado";

  //Cargamos la información adicional con la información del libro
  @override
  void initState() {
    super.initState();

    //Carga la información del libro
    loadBookInfo(widget.book, widget.connectedUser);
  }

  //Carga la información del libro
  Future<void> loadBookInfo(Book apiBook, User user) async {
    final bookInteractionsProvider = BookUsersInteractionsProvider();
    BookUsersInteractions? loadedBooks =
        await bookInteractionsProvider.getBookById(apiBook.id);

    loadedBooks ??=
        await bookInteractionsProvider.createBookUsersInteractions(widget.book);

    //Registramos si el usuario le a ha dado me gusta al libro o no
    initialLikeState(loadedBooks, user);

    //Registramos el estado del libro para el usuario
    initialBookState(loadedBooks, user);

    setState(() {
      bookInteractionsInfo = loadedBooks;
    });

    //Cargamos las reseñas del libro
    loadReviewsInfo(loadedBooks);

    //Cargamos las etiquetas del libro
    loadTagsInfo(loadedBooks);
  }

  //Carga la las reseñas del libro
  Future<void> loadReviewsInfo(BookUsersInteractions? bookInteractions) async {
    final reviewProvider = ReviewProvider();
    final userProvider = UserProvider();
    List<List<dynamic>> loadedReviewsInfoList = [];

    if (bookInteractions != null && bookInteractions.reviewsIdList.isNotEmpty) {
      //Para cada reseña del libro:
      for (int i = 0; i < bookInteractions.reviewsIdList!.length; i++) {
        //Para cada libro cargamos las ids de las reseñas que tiene
        String reviewId = bookInteractions.reviewsIdList![i];

        loadedReviewsInfoList.add([]);

        //Llamamos a la base de datos paque que nos devuelva la información de la review
        Review review = await reviewProvider.getReviewById(reviewId);

        //Llamamos a la base de datos para que nos devuelva el usuario que ha realizado la reseña
        User? reviewUser = await userProvider.getUserById(review.userName);

        //Cargamos la información en una lista, donde cada registro tendrá la información de la reseña y del usuario.
        loadedReviewsInfoList[i].add(review);
        loadedReviewsInfoList[i].add(reviewUser);
      }

      //Ordenamos las reseñas por orden de creación
      loadedReviewsInfoList
          .sort((a, b) => b[0].createdAt.compareTo(a[0].createdAt));
    }

    setState(() {
      reviewsInfoList = loadedReviewsInfoList;
    });
  }

  //Cargamos la información de las etiquetas del libro
  Future<void> loadTagsInfo(BookUsersInteractions? bookInteractions) async {
    final bookTagProvider = BooktagProvider();
    List<Booktag>? loadedTags = [];

    if (bookInteractions != null && bookInteractions.tagsList.isNotEmpty) {
      //Para cada tag del libro:
      for (dynamic tagId in bookInteractions.tagsList) {
        //Llamamos a la base de datos para que nos devuelva la lista de etiquetas de ese libro
        Booktag? booktag = await bookTagProvider.getBookTagById(tagId);
        loadedTags.add(booktag!);
      }
    }

    setState(() {
      tagsList = loadedTags;
    });
  }

  //Carga el estado de me gusta del libro
  Future<void> initialLikeState(
      BookUsersInteractions? bookInteractions, User user) async {
    PostProvider postProvider = PostProvider();

    bool loadIsLiked = false;

    if (bookInteractions != null) {
      //Llamada a la base de datos para indicar si el usuario ha marcado el libro como me gusta o no
      loadIsLiked = await postProvider.getIsBookLiked(bookInteractions, user);
    }

    setState(() {
      isLiked = loadIsLiked;
    });
  }

  //Carga el estado de un libro
  Future<void> initialBookState(
      BookUsersInteractions? bookInteractions, User user) async {
    BookstateProvider bookstateProvider = BookstateProvider();

    BookState? initialBookStateLoaded;

    //Llamada a la base de datos para traer el estado del libro
    initialBookStateLoaded =
        await bookstateProvider.getUserBookState(bookInteractions!, user);

    //Si no se ha creado ningún estado, se crea uno para la próxima vez que se acceda al libro
    if (initialBookStateLoaded == null) {
      initialBookStateLoaded =
          await bookstateProvider.createBookState(widget.book, user);
    }

    setState(() {
      bookState = initialBookStateLoaded;
    });
  }

  @override
  //Comprobams si la información con las interacciones del usuario con el libro han cargado, si no muestra una pantalla de carga hasta obtener la información
  Widget build(BuildContext context) {
    if (bookInteractionsInfo == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: PersonalizedAppbar(
        title: widget.book.title,
        backRow: true,
        returnWidget: HomeScreen(connectedUser: widget.connectedUser),
        connectedUser: widget.connectedUser,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //Carga la información del libro, asi como el estado y los botones de like, el desplegable de estado y el botón de reseña
            BookInfoHeader(
              book: widget.book,
              bookInteractions: bookInteractionsInfo,
              changePublicationDate: changePublicationDate,
              isLiked: isLiked,
              onLikePressed: _likeClick,
              reviewsInfoList: reviewsInfoList,
              onReviewAdded: _onReviewAdded,
              connectedUser: widget.connectedUser,
              bookState: bookState,
              changeBookState: _changeBookState,
            ),
            const SizedBox(height: 16),
            if (bookInteractionsInfo != null)
              BookTagInfo(
                tagsList: tagsList,
                bookUsersInteractions: bookInteractionsInfo,
                connectedUser: widget.connectedUser,
                book: widget.book,
              ),
            const SizedBox(height: 16),
            if (bookInteractionsInfo != null)
              BookReviews(reviewsInfoList: reviewsInfoList),
          ],
        ),
      ),
    );
  }

  String changePublicationDate(String publicationDate) {
    try {
      List<String> dateParts = publicationDate.split('-');
      return "${dateParts[2]}/${dateParts[1]}/${dateParts[0]}";
    } catch (e) {
      return "Desconocido";
    }
  }

  //Función para cuando demos like a un libro
  void _likeClick() {
    final postProvider = PostProvider();

    if (bookInteractionsInfo != null) {
      setState(() {
        // Actualizar el estado de 'isLiked'
        isLiked = !isLiked;

        //Si se ha dado like aumentamos el valor de like y creamos un nuevo post
        if (isLiked) {
          bookInteractionsInfo!.likes++;
          postProvider.newPost(
              "like", null, bookInteractionsInfo!, widget.connectedUser);

          //En caso de quitar un like, reducimos el valor de likes y eliminamos un post
        } else {
          bookInteractionsInfo!.likes--;
          postProvider.deletePost(
              "like", null, bookInteractionsInfo!, widget.connectedUser);
        }
      });
    }
  }

  //Función para cuando cambiemos el estado de un libro
  void _changeBookState(String newState) {
    final postProvider = PostProvider();

    //Actualiza el estado al introducido por parámetro
    if (bookInteractionsInfo != null) {
      bookState!.state = newState;

      //Cre crea un nuevo post de tio BookState
      postProvider.newPost("booksStates", bookState, bookInteractionsInfo!,
          widget.connectedUser);
    }
  }

  //Acción para cuando se añada una reseña, actualiza la vista para mostrar la nueva reseña
  void _onReviewAdded(Review newReview, User user) {
    setState(() {
      if (reviewsInfoList != null) {
        // Agrega la nueva reseña a la lista de reseñas
        reviewsInfoList!.add([newReview, user]);

        // Ordena las reseñas por fecha (de más reciente a más antiguo)
        reviewsInfoList!
            .sort((a, b) => b[0].createdAt.compareTo(a[0].createdAt));
      }
    });
  }
}

//Carga la vista de la primera parte de la información del libro, con la portada y título, desplegable con el estado, botón de me gusta,
//Botón para añadir reseñas, descripción e información adicional
class BookInfoHeader extends StatefulWidget {
  final Book book;
  final String Function(String) changePublicationDate;
  final BookUsersInteractions? bookInteractions;
  final bool isLiked;
  final VoidCallback onLikePressed;
  final User connectedUser;
  final List<List<dynamic>>? reviewsInfoList;
  final Function(Review, User) onReviewAdded;
  final BookState? bookState;
  final Function(String) changeBookState;

  const BookInfoHeader({
    Key? key,
    required this.book,
    required this.changePublicationDate,
    this.bookInteractions,
    required this.isLiked,
    required this.onLikePressed,
    required this.reviewsInfoList,
    required this.onReviewAdded,
    required this.connectedUser,
    required this.bookState,
    required this.changeBookState,
  }) : super(key: key);

  @override
  _BookInfoHeaderState createState() => _BookInfoHeaderState();
}

class _BookInfoHeaderState extends State<BookInfoHeader> {
  // Posibles estados del libro
  final List<String> _posiblesBookStatus = [
    "Ningún estado seleccionado",
    "Quiero leer",
    "Leyendo",
    "Leído"
  ];

  @override
  Widget build(BuildContext context) {
    if (widget.bookInteractions == null) {
      return Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
        Image.network(
          widget.book.image,
          width: 200,
          height: 300,
          fit: BoxFit.cover,
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            widget.book.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
        if (widget.book.authors.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              widget.book.authors.join(', '),
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: 16),
        // Dropdown para seleccionar el estado del libro
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: DropdownButton<String>(
            value: widget.bookState == null
                ? "Ningún estado seleccionado"
                : widget.bookState!.state,
            onChanged: (String? newValue) {
              if (widget.bookState == null ||
                  widget.bookState!.state != newValue) {
                setState(() {
                  if (newValue != null) {
                    widget.changeBookState(newValue);
                  } else {
                    widget.changeBookState("Ningún estado seleccionado");
                  }
                });
              }
            },
            items: _posiblesBookStatus
                .map<DropdownMenuItem<String>>((String status) {
              return DropdownMenuItem<String>(
                value: status,
                child: Text(status),
              );
            }).toList(),
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down),
            style: const TextStyle(color: Colors.black, fontSize: 16),
            underline: Container(
              height: 1,
              color: Colors.grey,
            ),
          ),
        ),
        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Botón para dar me gusta
            IconButton(
              onPressed: widget

                  //Llama a la función onLikePressed, que añade un like y crea un post de tipo like si se da like.
                  //También quita un like y elimina el post del like que habia, si se quita el like
                  .onLikePressed,
              icon: Icon(
                widget.isLiked ? Icons.favorite : Icons.favorite_border,
                color: widget.isLiked ? Colors.redAccent : Colors.grey,
              ),
              splashRadius: 20,
              splashColor: Colors.redAccent,
            ),
            Text(
              //Muestra la cantidad de likes. Si no existe registro de likes pone 0
              '${widget.bookInteractions?.likes ?? 0}',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: ElevatedButton(
            //Botón para añadir una reseña
            onPressed: () {
              //Abre un dialog, una pantalla sobre la pantalla de información, con un cuadro de texto para añadir la reseña
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AddReviewDialog(
                    bookUsersInteractions: widget.bookInteractions!,
                    onReviewAdded: widget.onReviewAdded,
                    book: widget.book,
                    connectedUser: widget.connectedUser,
                  );
                },
              );
            },
            child: Text("Añadir reseña"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              textStyle: const TextStyle(fontSize: 16),
              iconColor: Colors.blueGrey[200],
            ),
          ),
        ),

        const SizedBox(height: 16),
        // Descripción
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Descripción',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            widget.book.description.isNotEmpty == true
                ? widget.book.description
                : 'Descripción no disponible.',
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.justify,
          ),
        ),
        const SizedBox(height: 16),
        // Información adicional
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Información Adicional',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.book.publicationDate != null ||
                        widget.book.publicationDate != ""
                    ? 'Publicado: ${widget.changePublicationDate(widget.book.publicationDate!)}'
                    : 'Fecha de publicación no disponible.',
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                widget.book.publisher != null
                    ? 'Editorial: ${widget.book.publisher}'
                    : '',
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                widget.book.isbn != null
                    ? 'ISBN: ${widget.book.isbn}'
                    : 'ISBN no disponible.',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

//Segunda parte, que muestra las etiquetas del libro
class BookTagInfo extends StatelessWidget {
  final List<Booktag>? tagsList;
  final BookUsersInteractions? bookUsersInteractions;
  final User connectedUser;
  final Book book;

  const BookTagInfo(
      {Key? key,
      required this.tagsList,
      required this.bookUsersInteractions,
      required this.connectedUser,
      required this.book})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Etiquetas',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: [
              if (tagsList == null)
                CircularProgressIndicator()
              else if (tagsList!.isEmpty)
                Container()
              else
                //Creamos una condición para que solo sean visibles las reseñas añadidas por 5 usuarios o más y que se haya añadido por más personas que las que lo han deninciado
                ...tagsList!.map(
                  (tag) => tag.addedUsers.length >= 5 &&
                          tag.complaintUsers.length < tag.addedUsers.length
                      ? Chip(
                          label: Text(tag.tagName),
                          backgroundColor: Colors.blueGrey[200],
                          labelStyle: const TextStyle(color: Colors.white),
                          shape: const StadiumBorder(),
                        )
                      : Container(),
                ),
              //Al clicar al + se abre un dialog (Pantalla sobre la pantalla de bookInfo) que permite editar las etiquetas de un libro
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return ConfigureTagsDialog(
                        tagsList: tagsList != null ? tagsList : [],
                        bookUsersInteractions: bookUsersInteractions,
                        connectedUser: connectedUser,
                        book: book,
                      );
                    },
                  );
                },
                child: Chip(
                  backgroundColor: Colors.blueGrey[200],
                  label: const Icon(
                    Icons.add,
                    color: Colors.white, // Color del ícono
                  ),
                  shape: const StadiumBorder(
                    side: BorderSide(
                      color: Colors.black,
                      width: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

//Tercera parte, sección de reseñas
class BookReviews extends StatelessWidget {
  final List<List<dynamic>>? reviewsInfoList;
  const BookReviews({Key? key, required this.reviewsInfoList})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (reviewsInfoList == null) ...[
          const Center(
            child: CircularProgressIndicator(),
          ),
        ] else if (reviewsInfoList!.isEmpty) ...[
          Container(),
        ] else ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Reseñas',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Reseñas de usuarios
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reviewsInfoList!.length,
              itemBuilder: (context, index) {
                final review = reviewsInfoList![index][0];
                final user = reviewsInfoList![index][1];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(user.picture),
                              radius: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              user.userName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          review.text,
                          style: const TextStyle(fontSize: 14),
                          textAlign: TextAlign.justify,
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            DateFormat('dd/MM/yyyy HH:mm')
                                .format(review.createdAt.toDate()),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
