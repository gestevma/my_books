import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_books/models/book_model.dart';
import 'package:my_books/models/post_model.dart';
import 'package:my_books/models/user_model.dart';
import 'package:my_books/providers/post_provider.dart';
import 'package:my_books/providers/user_provider.dart';
import 'package:my_books/screens/bookInfo_screen.dart';
import 'package:my_books/screens/profile_screen.dart';
import 'package:my_books/widgets/personalizedAppBar.dart';

class TimelineScreen extends StatefulWidget {
  final User connectedUser;
  const TimelineScreen({Key? key, required this.connectedUser})
      : super(key: key);

  @override
  _TimelineScreenState createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  List<dynamic>? friendsPostsList;

  ///Carga la información de los posts de los usuarios amigos del usuario conectado
  Future<void> _loadPostsInfo() async {
    try {
      final userProvider = UserProvider();
      final postProvider = PostProvider();

      //Cargamos la lista de amigos del usuario conectado
      List<User> friendsList =
          await userProvider.getFriends(widget.connectedUser);

      //Recogemos la lista de post de nuestros amigos. Esta lista tiene la información de los posts con
      List<dynamic> loadFriendsPostsList =
          await postProvider.getAllFriendsPosts(friendsList);

      //Actualizamos la lista de posts que se mostrarán
      setState(() {
        friendsPostsList = loadFriendsPostsList;
      });
    } catch (e) {}
  }

  //Definimos el estado inicial de la aplicación, cargamos la lista de posts
  @override
  void initState() {
    super.initState();
    try {
      _loadPostsInfo();
    } catch (e) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              TimelineScreen(connectedUser: widget.connectedUser),
        ),
      );
    }
  }

  //Cargamos el estado inicial de la aplicación. Si la lista de posts es null mostramos una pantalla de carga
  @override
  Widget build(BuildContext context) {
    if (friendsPostsList == null) {
      return Scaffold(
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    //Si ya se ha cargado la lista de amigos mostramos la información de los posts
    return Scaffold(
      appBar: PersonalizedAppbar(
        title: "Última actividad",
        connectedUser: widget.connectedUser,
      ),
      body: _PostsScreenBody(
        friendsPostsList: friendsPostsList!,
        connectedUser: widget.connectedUser,
      ),
    );
  }
}

class _PostsScreenBody extends StatelessWidget {
  final List<dynamic> friendsPostsList;
  final User connectedUser;

  const _PostsScreenBody(
      {Key? key, required this.friendsPostsList, required this.connectedUser})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (friendsPostsList.isNotEmpty) {
      return ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: friendsPostsList.length,
        itemBuilder: (BuildContext context, int index) {
          final friendPost = friendsPostsList[index];
          final Post? post = friendPost[0];
          final Book? bookPost = friendPost[1];
          final User? userPost = friendPost[2];
          if (post != null && bookPost != null && userPost != null) {
            DateTime createdAt = post.createdAt.toDate();
            String formattedDate =
                DateFormat('dd/MM/yyyy HH:mm').format(createdAt);

            return GestureDetector(
              // Cuando se hace clic en cualquier parte del contenedor
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookinfoScreen(
                      connectedUser: connectedUser,
                      book: bookPost,
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
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Imagen de perfil
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfileScreen(
                                  connectedUser: connectedUser,
                                  user: userPost,
                                ),
                              ),
                            );
                          },
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(userPost.picture!),
                            radius: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Nombre de usuariO
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProfileScreen(
                                      connectedUser: connectedUser,
                                      user: userPost,
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                userPost.userName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Muestra la información del post
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
                                      text: bookPost.title,
                                      style: const TextStyle(
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
            Container();
          }
        },
        separatorBuilder: (BuildContext context, int index) =>
            const SizedBox(height: 10),
      );
    } else {
      return Center(
        child: Text(
          "Ninguna actividad disponible",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }
  }
}
