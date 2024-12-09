import 'package:flutter/material.dart';
import 'package:my_books/models/user_model.dart';
import 'package:my_books/providers/ui_provider.dart';
import 'package:provider/provider.dart';

//Crea el listado de botones que permiten navegar por las diferentes pantallas
class CustomNavigationBar extends StatelessWidget {
  final User connectedUser;
  const CustomNavigationBar({Key? key, required this.connectedUser})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final uiProvider = Provider.of<UIProvider>(context);
    final currentIndex = uiProvider.selectMenuOpt;

    //Este widget crea una barra de navegación para poder acceder a las diferentes pantallas
    return BottomNavigationBar(
      elevation: 0,
      currentIndex: currentIndex,

      //Al clicar sobre un elemento cambiamos el valor de menuOption, según el orden de los elementos.
      onTap: (int i) => uiProvider.selectMenuOpt = i,
      selectedItemColor: Colors.blueGrey[700],
      unselectedItemColor: Colors.grey[400],
      backgroundColor: Colors.white,

      //Definimos los elementos por los que se navegará con un icono y un título
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home_filled),
          label: "Principal",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book),
          label: "Mis libros",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: "Descubre",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: "Amigos",
        ),

        //Perfil
        BottomNavigationBarItem(
          icon: ClipOval(
            child: SizedBox(
              height: 30,
              width: 30,
              child: Image.network(
                connectedUser.picture ?? "",
                fit: BoxFit
                    .cover, // Asegura que la imagen se ajuste dentro del círculo
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.person, // Muestra un ícono si la imagen falla
                  size: 40,
                ),
              ),
            ),
          ),
          label: "Perfil",
        ),
      ],

      //Estilo de los títulos
      selectedLabelStyle: TextStyle(
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: TextStyle(
        fontWeight: FontWeight.normal,
      ),
    );
  }
}
