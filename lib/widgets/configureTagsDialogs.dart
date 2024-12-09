import 'package:flutter/material.dart';
import 'package:my_books/models/bookTag_model.dart';
import 'package:my_books/models/bookUsersInteractions_model.dart';
import 'package:my_books/models/book_model.dart';
import 'package:my_books/models/predefinedTags_model.dart';
import 'package:my_books/models/user_model.dart';
import 'package:my_books/providers/bookTag_provider.dart';
import 'package:my_books/providers/post_provider.dart';
import 'package:my_books/screens/bookInfo_screen.dart';
import 'package:my_books/screens/discover_screen.dart';
import 'package:my_books/utilities/generateRandomId.dart';

class ConfigureTagsDialog extends StatefulWidget {
  final List<Booktag>? tagsList;
  final BookUsersInteractions? bookUsersInteractions;
  final User connectedUser;
  final Book book;

  const ConfigureTagsDialog(
      {Key? key,
      required this.tagsList,
      required this.bookUsersInteractions,
      required this.connectedUser,
      required this.book})
      : super(key: key);

  @override
  _ConfigureTagsDialog createState() => _ConfigureTagsDialog();
}

class _ConfigureTagsDialog extends State<ConfigureTagsDialog> {
  final TextEditingController tagController = TextEditingController();

  // Lista de etiquetas predeterminadas
  final List<String> predefinedTags = Predefinedtags().predefinedTags;

  List<Booktag> newTags = [];
  List<String> newTagsString = [];

  List<Booktag> complaintBookTags = [];
  List<String> complaintBookTagsString = [];

  //Carga las etiquetas denunciadas de el libro por el usuario
  _loadComplaintBooks() async {
    List<Booktag> loadBookTag = [];
    List<String> loadBookTagString = [];

    //Llamada a la base de datos para devolver la lisgta de reseñas denunciadas por el usuario conectado para el libro que se consulta
    loadBookTag = await BooktagProvider()
        .complaintBooks(widget.connectedUser, widget.book);

    for (Booktag booktag in loadBookTag) {
      loadBookTagString.add(booktag.tagName);
    }

    setState(() {
      complaintBookTags = loadBookTag;
      complaintBookTagsString = loadBookTagString;
    });
  }

  //Carga la lista de etiquetas que el usuario ya ha añadido pero que no se muestran como etiquetas del libro
  _loadtagAddedYet() async {
    List<Booktag> loadBookTag = [];
    List<String> loadBookTagString = [];

    //Llamada a la base de datos
    loadBookTag =
        await BooktagProvider().booksAdded(widget.connectedUser, widget.book);

    for (Booktag booktag in loadBookTag) {
      loadBookTagString.add(booktag.tagName);
    }

    setState(() {
      newTags = loadBookTag;
      newTagsString = loadBookTagString;
    });
  }

  //Cargamos la información inicial para general la vista
  @override
  void initState() {
    super.initState();
    //Cargamos la lista de etiquetas ya añadidas por el usuario para ese libro
    _loadtagAddedYet();

    //Cargamos la lista de etiquetas denunciadas por el usuario
    _loadComplaintBooks();
  }

  @override
  Widget build(BuildContext context) {
    //Lista de etiquetas del libro
    List<Booktag> tagOfBooksList = [];

    //Lista de etiquetas que no tiene el libro
    List<Booktag> noBookTagsList = [];

    //Creamos una lista con las etiquetas que no estén en la colección del libro
    final notTagsBookFromPedefined = predefinedTags.where((tag) {
      return !(widget.tagsList?.any((t) => t.tagName == tag) ?? false);
    }).toList();

    //A continuación, miraremos, de las etiquetas que estén en la colección las dividiremos entre las dos listas
    if (widget.tagsList != null && widget.tagsList!.isNotEmpty) {
      for (Booktag tag in widget.tagsList!) {
        //Por una parte cargamos la lista de etiquetas de etiquetas que cumplen las condiciones para verse
        if (tag.complaintUsers.length < tag.addedUsers.length &&
            tag.addedUsers.length >= 5) {
          tagOfBooksList.add(tag);
        } else {
          //Las que no cumplan la condición la cargamos en la lista de etiquetas que no tiene el libro
          noBookTagsList.add(tag);
        }
      }
    }

    //Para el resto de etiquetas, como solo tenemos el nombre, crearemos objetos de tipo BookTag, con la información por si el usuario
    //Quiere añadir la etiqueta al libro
    if (notTagsBookFromPedefined.isNotEmpty) {
      for (String tagName in notTagsBookFromPedefined) {
        Booktag bookTag = Booktag(
            id: Utilities().generateRandomId(20),
            bookId: widget.book.id,
            addedUsers: [],
            complaintUsers: [],
            tagName: tagName);
        noBookTagsList.add(bookTag);
      }
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              //Se crea un icono X que al clicarlo nos devuelve a la pantalla anterior
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookinfoScreen(
                            book: widget.book,
                            connectedUser: widget.connectedUser,
                            returnWidget: DiscoverScreen(
                                connectedUser: widget.connectedUser),
                          ),
                        ));
                  },
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Etiquetas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Sección de etiquetas asociadas
              if (tagOfBooksList.isNotEmpty) ...[
                const Text(
                  'Etiquetas del libro',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: tagOfBooksList.map((tag) {
                    return ElevatedButton(
                      onPressed: () {
                        //Al clicar en una etiqueta podemos:
                        //Quitar denuncias
                        if (complaintBookTagsString.contains(tag.tagName)) {
                          setState(() {
                            complaintBookTagsString.remove(tag.tagName);
                          });
                        } else {
                          //Crear una denuncia de la etiqueta
                          setState(() {
                            complaintBookTagsString.add(tag.tagName);
                            complaintBookTags.add(tag);
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey[600],
                        foregroundColor: Colors.white,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(tag.tagName),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.flag,
                            size: 16,
                            color:
                                !complaintBookTagsString.contains(tag.tagName)
                                    ? Colors.white
                                    : Colors.red,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],
              // Sección de etiquetas no asociadas
              if (noBookTagsList.isNotEmpty) ...[
                const Text(
                  'Añadir etiquetas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: noBookTagsList.map((tag) {
                    return ElevatedButton(
                      onPressed: () {
                        //Al clicar podemos
                        //Si el usuario no habia seleccionado la etiqueta cambia el estado a seleccionada
                        if (!newTagsString.contains(tag.tagName)) {
                          setState(() {
                            newTags.add(tag);
                            newTagsString.add(tag.tagName);
                          });
                          //Si ya estaba seleccionada la pasamos a no seleccionada
                        } else {
                          setState(() {
                            newTags.remove(tag);
                            newTagsString.remove(tag.tagName);
                          });
                        }
                      },
                      style: !newTagsString.contains(tag.tagName)
                          ? ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[300],
                              foregroundColor: Colors.black,
                            )
                          : ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueGrey[400],
                              foregroundColor: Colors.white,
                            ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(tag.tagName),
                          const SizedBox(width: 8),
                          !newTagsString.contains(tag.tagName)
                              ? Icon(
                                  Icons.add,
                                  size: 16,
                                  color: Colors.green,
                                )
                              : Icon(
                                  Icons.remove,
                                  size: 16,
                                  color: Colors.red,
                                ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 16),

              //Botón para de guardar los cambios
              ElevatedButton(
                onPressed: () {
                  //Hcemos dos cosas, añadir las etiquetas marcadas para añadir y crear denuncias
                  if (newTags.isNotEmpty) {
                    //Función para añadir una nueva etiqueta
                    _addTags(newTags, newTagsString);
                  }
                  if (complaintBookTags.isNotEmpty) {
                    //Función para añadir una nueva denuncia
                    _complaintBook(complaintBookTags, complaintBookTagsString);
                  }
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookinfoScreen(
                          book: widget.book,
                          connectedUser: widget.connectedUser,
                          returnWidget: DiscoverScreen(
                              connectedUser: widget.connectedUser),
                        ),
                      ));
                },
                child: const Text('Añadir etiquetas'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size(double.infinity, 40),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //Nueva denuncia
  void _complaintBook(
      List<Booktag> complaintBooks, List<String> complaintBooksString) async {
    List<Booktag> previousComplaintBooks = await BooktagProvider()
        .complaintBooks(widget.connectedUser, widget.book);
    List<String> previousComplaintBooksIds = [];

    for (Booktag tag in previousComplaintBooks) {
      previousComplaintBooksIds.add(tag.id);
    }

    for (Booktag tag in complaintBooks) {
      if (complaintBooksString.contains(tag.tagName)) {
        //Si se ha añadido una nueva denuncia
        if (!previousComplaintBooksIds.contains(tag.id)) {
          tag.complaintUsers.add(widget.connectedUser.userName);

          //Actualizamos la colección bookTag para añadir a la persona que ha denunciado la etiqueta
          BooktagProvider().updateBookTag(tag);
        }
        //Si se elimina una denuncia
      } else {
        //Eliminamos al usuario de la lista de personas que han denunciado la etiqueta
        tag.complaintUsers.remove(widget.connectedUser.userName);
        BooktagProvider().updateBookTag(tag);
      }
    }
  }

  //Añadir etiquetas
  void _addTags(List<Booktag> newTags, List<String> newTagsNames) async {
    PostProvider postProvider = PostProvider();
    List<Booktag> yetAddedTags =
        await BooktagProvider().booksAdded(widget.connectedUser, widget.book);
    List<String> yetAddedTagIdList = [];
    List<Booktag> tagsToAdd = [];
    List<String> tagsToAddNames = [];

    for (Booktag bookTag in yetAddedTags) {
      yetAddedTagIdList.add(bookTag.id);
    }

    for (Booktag tag in newTags) {
      if (newTagsNames.contains(tag.tagName)) {
        if (!yetAddedTagIdList.contains(tag.id)) {
          //Si queremos añadir una etiqueta
          if (!tagsToAddNames.contains(tag.tagName)) {
            //Añadimos las etiquetas que se quieren añadir
            tag.addedUsers.add(widget.connectedUser.userName);
            tagsToAdd.add(tag);
            tagsToAddNames.add(tag.tagName);
          }
        }

        //Si se retira el querer añadir la etiqueta
      } else {
        //Eliminamos al usuario de la lista de users que han añadido la etiqueta
        tag.addedUsers.remove(widget.connectedUser.userName);
        BooktagProvider().updateBookTag(tag);
      }
    }

    //Creamos un nuevo post para las etiquetas que queremos añadir
    postProvider.newPost("bookTags", tagsToAdd, widget.bookUsersInteractions!,
        widget.connectedUser);
  }
}
