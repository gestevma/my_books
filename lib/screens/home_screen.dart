import 'package:flutter/material.dart';
import 'package:my_books/models/user_model.dart';
import 'package:my_books/providers/ui_provider.dart';
import 'package:my_books/screens/discover_screen.dart';
import 'package:my_books/screens/friends_screen.dart';
import 'package:my_books/screens/myBooks_screen.dart';
import 'package:my_books/screens/profile_screen.dart';
import 'package:my_books/screens/timeLine_screen.dart';
import 'package:my_books/widgets/customNavigationBar.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  final User connectedUser;
  const HomeScreen({Key? key, required this.connectedUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //UIProvider controla la pantalla que debe mostrarse
    final uiProvider = Provider.of<UIProvider>(context);

    //Esperamos a que ui provider no esté cargando, si lo está mostramos un circulo de carga
    if (uiProvider.isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    //Cargamos el cuerpo
    return Scaffold(
      body: _HomeScreenBody(
        uiProvider: uiProvider,
        connectedUser: connectedUser,
      ),
      //Cargamos un bottonNavigationBar, que nos crea una lista de botones que nos permite navegar por las diferentes pantallas de la aplicación
      bottomNavigationBar: CustomNavigationBar(
        connectedUser: connectedUser,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

//Controla que pantalla se muestra según el botón que cliquemos
class _HomeScreenBody extends StatelessWidget {
  final uiProvider;
  final User connectedUser;

  const _HomeScreenBody(
      {Key? key, required this.uiProvider, required this.connectedUser})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    //Cambia de valor al clicar en cada botón
    final currentIndex = uiProvider.selectMenuOpt;

    if (uiProvider.isLoading) {
      return Container();
    }
    //switch-case para navegar entre las diferentes pantallas
    switch (currentIndex) {
      case 0:
        //Muestra la actividad de nuestros usuarios amigos
        return TimelineScreen(
          connectedUser: connectedUser,
        );

      //Muestra nuestra lista de libros
      case 1:
        return MyBooksScreen(connectedUser: connectedUser);

      //Permite buscar nuevos libros
      case 2:
        return DiscoverScreen(connectedUser: connectedUser);

      //Permite buscar usuarios y muestra nuestra lista de amigos
      case 3:
        return FriendsScreen(connectedUser: connectedUser);

      //Muestra nuestro perfil
      case 4:
        return ProfileScreen(user: connectedUser, connectedUser: connectedUser);

      //Por defecto muestra la pantalla de actividad
      default:
        return TimelineScreen(connectedUser: connectedUser);
    }
  }
}
