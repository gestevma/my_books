import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_books/models/bookTag_model.dart';
import 'package:my_books/models/bookUsersInteractions_model.dart';
import 'package:my_books/models/book_model.dart';
import 'package:my_books/models/post_model.dart';
import 'package:my_books/models/user_model.dart';
import 'package:my_books/providers/bookState_provider.dart';
import 'package:my_books/providers/bookTag_provider.dart';
import 'package:my_books/providers/bookUsersInteractions_provider.dart';
import 'package:my_books/providers/books_provider.dart';
import 'package:my_books/providers/review_provider.dart';
import 'package:my_books/providers/user_provider.dart';
import 'package:my_books/utilities/generateRandomId.dart';

//Clase que interactua con la colección posts de firebase
class PostProvider extends ChangeNotifier {
  bool isLoading = false;

//Permite obtener la lista de posts de una lista de usuarios
  Future<List<List<dynamic>>> getAllFriendsPosts(List<User> userList) async {
    isLoading = true;

    List<Post> friendsPostsList = [];
    List<List<dynamic>> friendsPostListCompleteInfo = [];

    //Para cada usuario obtenermos sus posts
    for (User user in userList) {
      List<Post> userPost = await getUserPosts(user);
      friendsPostsList.addAll(userPost);
    }

    //Ordenamos los posts devueltos por su fecha de creación
    friendsPostsList.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    //Recopilamos la información de los posts para poder mostrarla
    friendsPostListCompleteInfo = await getPostsCompleteInfo(friendsPostsList);

    isLoading = false;
    notifyListeners();

    return friendsPostListCompleteInfo;
  }

  Future<List<Post>> getUserPosts(User user) async {
    List<Post> allPostsList = [];

    try {
//Empezamos recogiendo los Ids de los posts de la lists de amigos
      List<List<dynamic>> subArraysPostsIds = [];

      //frirebase tiene una limitación. Que solo devuelve hasta 10 elementos,
      //Debemos comprobar los elementos que tenemos y si hay más de 10 hacer la
      //llamda por partes
      if (user.postsIdList != null && user.postsIdList!.isNotEmpty) {
        if (user.postsIdList!.length > 10) {
          for (int i = 0; i < user.postsIdList!.length; i += 10) {
            subArraysPostsIds.add(user.postsIdList!.sublist(
                i,
                i + 10 > user.postsIdList!.length
                    ? user.postsIdList!.length
                    : i + 10));
          }

          for (List<dynamic> subArray in subArraysPostsIds) {
            //Realizamos la llamada a la base de datos
            QuerySnapshot<Map<String, dynamic>> postsSnapShots =
                await FirebaseFirestore.instance
                    .collection('posts')
                    .where(FieldPath.documentId, whereIn: subArray)
                    .get();

            List<Post> userPostsList = postsSnapShots.docs.map((doc) {
              return Post.fromMap(doc.data(), doc.id);
            }).toList();

            allPostsList.addAll(userPostsList);
          }
        } else {
          //Caso 2, si tenemos menos de 10 elementos
          QuerySnapshot<Map<String, dynamic>> postsSnapShots =
              await FirebaseFirestore.instance
                  .collection('posts')
                  .where(FieldPath.documentId, whereIn: user.postsIdList)
                  .get();

          List<Post> userPostsList = postsSnapShots.docs.map((doc) {
            return Post.fromMap(doc.data(), doc.id);
          }).toList();

          allPostsList.addAll(userPostsList);
        }
      }
    } catch (e) {
      print("Error al cargar las publicaciones del usuario ${user.userName}");
    }

    return allPostsList;
  }

  //Cargamos un array con la información conpleta para mostrar un post (el post, el libro y el user)
  Future<List<List<dynamic>>> getPostsCompleteInfo(
      List<Post> friendsPostsList) async {
    List<List<dynamic>> friendsPostListCompleteInfo = [];
    List<List<dynamic>> temporalPostInfo = [];
    for (int i = 0; i < friendsPostsList.length; i++) {
      temporalPostInfo.add([]);

      Post post = friendsPostsList[i];

      //Añadimos la información del post
      temporalPostInfo[i].add(post);

      //Añadimos la información del libro
      BookProvider bookProvider = BookProvider();

      Book? bookInteractionsInfo = await bookProvider.getBookById(post.bookId);
      temporalPostInfo[i].add(bookInteractionsInfo);

      //Añadimos la información del usuario que ha creado el post
      UserProvider userProvider = UserProvider();
      User? userInfo = await userProvider.getUserById(post.userName);
      temporalPostInfo[i].add(userInfo);
    }

    //Devolvemos el array con la información del post
    friendsPostListCompleteInfo = temporalPostInfo;

    return friendsPostListCompleteInfo;
  }

  //Nos indica si un libro en concreto ha sido marcado como me gusta
  Future<bool> getIsBookLiked(
      BookUsersInteractions bookInteractions, User user) async {
    bool isLiked = false;

    final postsRef = FirebaseFirestore.instance.collection('posts');

    try {
      // Consulta, comprobamos si en la colección posts devuelve algún documento para un usuario y un libro concreto que se haya marcado como me gusta
      final querySnapshot = await postsRef
          .where('userName', isEqualTo: user.userName)
          .where("type", isEqualTo: "like")
          .where('bookId', isEqualTo: bookInteractions.id)
          .get();

      // Verifica si la consulta devolvió resultados. Si encuentra resultado es que el libro se ha marcado como me gusta
      if (querySnapshot.docs.isNotEmpty) {
        isLiked = true;
        print('El libro está marcado como "liked".');
      } else {
        print('El libro no está marcado como "liked".');
      }
    } catch (e) {
      print('Error');
    }

    notifyListeners();
    return isLiked;
  }

  //Devuelve Una lista con todos los libros marcados como me gusta por el usuario
  Future<List<Post>> getLikedPostst(User user) async {
    List<Post> likedPosts = [];

    try {
      // Consulta para encontrar documentos que coincidan con los valores
      QuerySnapshot<Map<String, dynamic>> postsSnapShots =
          await FirebaseFirestore.instance
              .collection('posts')
              .where(FieldPath.documentId, whereIn: user.postsIdList)
              .where("type", isEqualTo: "like")
              .get();

      //Mapeamos el resultado de la consulta en una lista de objetos tipo post
      likedPosts = postsSnapShots.docs.map((doc) {
        return Post.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      print('Error');
    }

    notifyListeners();
    return likedPosts;
  }

  //Creamos una nueva entrada en la colección posts
  _createPostEntrance(Post post) async {
    try {
      // Referencia a la colección "posts"
      CollectionReference reviewsCollection =
          FirebaseFirestore.instance.collection('posts');

      // Crear un nuevo documento en la colección posts
      await reviewsCollection.doc(post.id).set({
        "userName": post.userName,
        "type": post.type,
        "text": post.text,
        "postContentText": post.postContentText,
        "bookId": post.bookId,
        "created_at": post.createdAt
      });

      print("Documento creado correctamente.");
    } catch (e) {
      print("Error al crear el documento: $e");
    }
  }

  //Crear un nuevo post.
  //La creación de un post implica que se debe actualizar también el documento de usuario añadiendo un nuevo post a la lista
  //También se debe modificar el documento del libro indicando que tiene un nuevo post asociado
  newPost(String type, dynamic postTypeObject, BookUsersInteractions book,
      User user) async {
    BookUsersInteractionsProvider bookusersinteractionsProvider =
        BookUsersInteractionsProvider();
    UserProvider userProvider = UserProvider();
    late Timestamp createdAt;
    String postText = "";
    String? postContentText;

    //Comprobamos el tipo de post
    switch (type) {
      //Tipo Like. Solo añadimos el texto de que se ha marcado como me gusta
      case "like":
        postTypeObject = book;

        postText = "Ha indicado que le gusta ♡ ";
        break;

      //Tipo review. Creamos la nueva review y añadimos la reseña a la lista de reseñas del libro. Finalmente añadimos el texto y el contenido de la reseña
      case "reviews":
        ReviewProvider reviewProvider = ReviewProvider();
        reviewProvider.createReview(postTypeObject);

        // Actualizar el libro con la nueva reseña en su lista de IDs de reseñas
        book.reviewsIdList.add(postTypeObject.id);

        //Texto y contenido de la reseña
        postText = "Ha añadido una nueva reseña a ";
        postContentText = postTypeObject.text;
        break;

      //Cambio de estado de un libro. Actualizamos el estado del libro y añadimos el texto de que se ha cambiado el estado en el post
      case "booksStates":
        BookstateProvider bookStateProvider = BookstateProvider();
        bookStateProvider.updateBookState(postTypeObject);

        postText =
            "Ha cambiado el estado a ${postTypeObject.state.toLowerCase()} ";

        break;

      //Añadimos una o varias etiquetas. En este caso como nos pasan una lista de etiquetas debemos actualuzar la colección para cada etiqueta
      case "bookTags":
        List<String> tagsNames = [];
        BooktagProvider booktagProvider = BooktagProvider();

        //Recorremos la lista de etiquetas que vamos a actualizar
        for (Booktag bookTag in postTypeObject) {
          //Para cada etiqueta intentamos obtener un resultado de la base de datos para ver si ya existe un registro o no
          Booktag? loadBookTag =
              await booktagProvider.getBookTagById(bookTag.id);

          //Si devuelve null es que no existe, entonces crearemos una nueva entrada y añadiremos la etiqueta a la lista de etiquetas del libro
          if (loadBookTag == null) {
            booktagProvider.createBookTag(bookTag);
            book.tagsList.add(bookTag.id);

            //En caso de existir, simplemente actualizaremos el documento
          } else {
            booktagProvider.updateBookTag(bookTag);
          }
          tagsNames.add(bookTag.tagName);
        }

        postText = "Ha modificado las etiquetas de  ";
        postContentText = tagsNames.join(', ');
    }

    //Crearemos el momento en el que se crea el post
    try {
      createdAt = postTypeObject.createdAt;
    } catch (e) {
      createdAt = Timestamp.fromDate(DateTime.now());
    }

    //Actualizamos los libros para añadir el nuevo post is es necesario (añadir reseñas y etiquetas)
    bookusersinteractionsProvider.updateBookInteractions(book);

    //Creamos el post como tal
    Post post = new Post(
      id: Utilities().generateRandomId(20),
      userName: user.userName,
      type: type,
      text: postText,
      postContentText: postContentText,
      bookId: book.id,
      createdAt: createdAt,
    );

    //Insertamos el nuevo post a la base de datos
    _createPostEntrance(post);

    //Añadimos el post a la lista de posts del usuario
    user.postsIdList ??= [];

    //Actualizamos el usuario
    user.postsIdList!.add(post.id);
    userProvider.updateUser(user);

    notifyListeners();
  }

  //Eliminar un post. Esta acción solo la hacemos en caso de que se elimine un like
  Future<List<Post>> _deletePostEntrance(String type, dynamic postTypeObject,
      BookUsersInteractions bookInteractions, User user) async {
    // Referencia a la colección 'posts'
    List<Post> deletePostsList = [];
    final postsRef = FirebaseFirestore.instance.collection('posts');

    try {
      // Consulta para encontrar los posts del usuario, para el libro que queremos y que el tipo de post sea del que queremos
      final postsSnapShots = await postsRef
          .where('userName', isEqualTo: user.userName)
          .where("type", isEqualTo: type)
          .where('bookId', isEqualTo: bookInteractions.id)
          .get();

      deletePostsList = postsSnapShots.docs.map((doc) {
        return Post.fromMap(doc.data(), doc.id);
      }).toList();

      //Para los posts encontrados lanzamos la función delete para eliminarlos
      for (final doc in postsSnapShots.docs) {
        await doc.reference.delete();
        print('Documento con ID ${doc.id} eliminado.');
      }

      print('Todos los documentos coincidentes han sido eliminados.');
    } catch (e) {
      print('Error al eliminar documentos: $e');
    }

    return deletePostsList;
  }

  //Función pública que permite eliminar un post
  deletePost(String type, dynamic postTypeObject,
      BookUsersInteractions bookInteractions, User user) async {
    BookUsersInteractionsProvider bookUsersInteractionsProvider =
        BookUsersInteractionsProvider();
    UserProvider userProvider = UserProvider();

    if (type == "like") {
      postTypeObject = bookInteractions;
    }

    //Llamamos a la función de eliminar un post
    List<Post> postsList =
        await _deletePostEntrance(type, postTypeObject, bookInteractions, user);
    bookUsersInteractionsProvider.updateBookInteractions(bookInteractions);

    //Eliminamos el post de la lista de posts del usuario
    if (user.postsIdList != null) {
      for (Post post in postsList) {
        user.postsIdList!.remove(post.id);
      }
    }

    //Actualizamos el valor en la base de datos
    userProvider.updateUser(user);
  }
}
