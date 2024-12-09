import 'package:flutter/material.dart';
import 'package:my_books/models/user_model.dart';
import 'package:my_books/providers/user_provider.dart';
import 'package:my_books/screens/profile_screen.dart';
import 'package:my_books/widgets/personalizedAppBar.dart';

class FriendsScreen extends StatefulWidget {
  final User connectedUser;
  const FriendsScreen({Key? key, required this.connectedUser})
      : super(key: key);

  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  List<User>? friendsList;
  List<User>? searchedUsersList;
  String searchQuery = "";

  //Carga la lista de amigos del usuario
  _loadFriendsList() async {
    UserProvider userProvider = UserProvider();

    //Llamada a la base de datos para cargar la lista de amigos del usuario conectado
    List<User> friendsListLoad =
        await userProvider.getFriends(widget.connectedUser);

    setState(() {
      friendsList = friendsListLoad;
    });
  }

  //Permite cargar los usuarios que coincidan con el nombre indicado por parámetro
  _loadUsersByName(String userName) async {
    UserProvider userProvider = UserProvider();

    //Llamada a la base de datos, devuelve los ususrios que contengan algún elemento del nombre de usuario indicado
    List<User> usersLoaded = await userProvider.getUserByName(userName);

    setState(() {
      friendsList = usersLoaded;
    });
  }

//Estado inicial de la aplicación, carga la lista de amigos del usuario conectado.
  @override
  void initState() {
    try {
      super.initState();
      _loadFriendsList();
    } catch (e) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              FriendsScreen(connectedUser: widget.connectedUser),
        ),
      );
    }
  }

  //Mientras la lista de amigos sea null muestra una pantalla de carga
  @override
  Widget build(BuildContext context) {
    if (friendsList == null) {
      return Scaffold(
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: PersonalizedAppbar(
        title: "Mis amigos",
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
                decoration: InputDecoration(
                  labelText: 'Buscar...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onChanged: (query) {
                  searchQuery = query;
                  //Si el buscador está vacío muestra la lusta de amigos
                  if (query.isNotEmpty) {
                    _loadUsersByName(query);
                    friendsList = [];
                  } else {
                    _loadFriendsList();
                    searchedUsersList = [];
                  }
                },
              ),
            ),
          ),

          //Cambiamos el título, si mostramos los amigos será "Mis amigos" y si buscamos será "Buscar usuarios"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              searchQuery.isEmpty ? 'Mis amigos' : 'Buscar usuarios',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Parte inferior: Lista de amigos
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: friendsList!.length,
              itemBuilder: (BuildContext context, int index) {
                final friend = friendsList![index];

                return GestureDetector(
                    onTap: () async {
                      // Navegar a la página de saludo al hacer clic en la tarjeta
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(
                            user: friend,
                            connectedUser: widget.connectedUser,
                          ),
                        ),
                      );
                    },
                    child: Card(
                        color: Colors.white, // Color blanco para la tarjeta
                        elevation: 2,
                        margin:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              // Imagen del usuario
                              CircleAvatar(
                                backgroundImage: friend.picture != null
                                    ? NetworkImage(friend.picture!)
                                    : null,
                                radius: 20,
                                child: friend.picture == null
                                    ? const Icon(Icons.person, size: 20)
                                    : null,
                              ),
                              const SizedBox(width: 10),
                              // Nombre del usuario
                              Text(
                                friend.userName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )));
              },
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(height: 0),
            ),
          ),
        ],
      ),
    );
  }
}
