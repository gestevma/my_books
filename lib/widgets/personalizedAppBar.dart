import 'package:flutter/material.dart';
import 'package:my_books/providers/loginForm_provider.dart';
import 'package:my_books/providers/ui_provider.dart';
import 'package:my_books/screens/login_screen.dart';
import 'package:my_books/screens/settings_screen.dart';
import 'package:provider/provider.dart';

class PersonalizedAppbar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final bool? backRow;
  final Widget? returnWidget;
  final dynamic? connectedUser; // Asegúrate de que este sea el tipo correcto

  const PersonalizedAppbar({
    Key? key,
    required this.title,
    this.backRow,
    this.returnWidget,
    this.connectedUser, // Recibe el connectedUser como parámetro
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final uiProvider = Provider.of<UIProvider>(context);
    return AppBar(
      //Flecha que permite volver a la pantalla anterior. Solo se muestra si backRow es true
      automaticallyImplyLeading:
          backRow == false || backRow == null ? false : true,

      title: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 24,
          ),
        ),
      ),

      //Al clicar sobre la flecha volvemos a la pantalla indicada por parámetro de la clase
      leading: backRow == true
          ? returnWidget != null
              ? IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => returnWidget!),
                    );
                  })

              //En caso de no indicar ninguna ruta simplemente irá a la última (vuelve hacia atrás)
              : IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context); // Volver a la pantalla anterior
                  },
                )
          : null,

      //Botón de menú, solo se mostrará si la pantalla no es inicio de sesión, registro o etiquetas de interés
      actions: title != "Iniciar sesión" &&
              title != "Registrarse" &&
              title != "Etiquetas de interés" &&
              title != "Ajustes"
          ? [
              Padding(
                padding: const EdgeInsets.only(
                    right: 20.0), // Espaciado a la derecha
                child: PopupMenuButton<int>(
                  onSelected: (value) {
                    uiProvider.selectMenuOpt = 0;
                    if (value == 0) {
                      // Acción para "Ajustes"
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SettingsScreen(
                            connectedUser: connectedUser,
                          ),
                        ),
                      );
                    } else if (value == 1) {
                      // Acción para "Cerrar sesión"
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChangeNotifierProvider(
                            create: (_) =>
                                LoginFormProvider(), // Nueva instancia
                            child: LoginScreen(),
                          ),
                        ),
                      );
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<int>(
                      value: 0,
                      child: Row(
                        children: [
                          Icon(Icons.settings, color: Colors.black),
                          const SizedBox(width: 10),
                          const Text("Ajustes",
                              style: TextStyle(color: Colors.black)),
                        ],
                      ),
                    ),
                    PopupMenuItem<int>(
                      value: 1,
                      child: Row(
                        children: [
                          Icon(Icons.exit_to_app, color: Colors.black),
                          const SizedBox(width: 10),
                          const Text("Cerrar sesión",
                              style: TextStyle(color: Colors.black)),
                        ],
                      ),
                    ),
                  ],
                  icon: Icon(Icons.menu,
                      color: Colors.black), // Icono del desplegable
                ),
              )
            ]
          : [],
      toolbarHeight: 80,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
