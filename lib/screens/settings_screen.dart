import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_books/models/predefinedTags_model.dart';
import 'package:my_books/models/user_model.dart';
import 'package:my_books/providers/loginForm_provider.dart';
import 'package:my_books/providers/user_provider.dart';
import 'package:my_books/screens/home_screen.dart';
import 'package:my_books/services/auth_service.dart';
import 'package:my_books/widgets/personalizedAppBar.dart';

class SettingsScreen extends StatefulWidget {
  final User connectedUser;

  const SettingsScreen({Key? key, required this.connectedUser})
      : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Lista inicial de elementos
  final List<String> predefinedTags = Predefinedtags().predefinedTags;

  // Lista de elementos seleccionados
  final List<String> selectedTags = [];

  String? userName;
  String? currentPassword;
  String? imagePath;

  // Método para manejar la selección
  void toggleSeleccion(String elemento) {
    setState(() {
      if (selectedTags.contains(elemento)) {
        selectedTags.remove(elemento);
      } else {
        selectedTags.add(elemento);
      }
    });
  }

  void _initialUserValues() {
    setState(() {
      userName = widget.connectedUser.userName;
    });
  }

  void _initialTagsSelection() {
    if (widget.connectedUser.interestedTags != null ||
        widget.connectedUser.interestedTags!.isNotEmpty) {
      setState(() {
        for (String tag in widget.connectedUser.interestedTags!) {
          selectedTags.add(tag);
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Inicializar el TabController
    _tabController = TabController(length: 2, vsync: this);
    _initialTagsSelection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PersonalizedAppbar(
        title: 'Ajustes',
        backRow: true,
        returnWidget: HomeScreen(connectedUser: widget.connectedUser),
      ),
      body: Column(
        children: [
          //TabBar maneja las vistas que tenemos
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.blueGrey[700],
            labelColor: Colors.blueGrey[700],
            unselectedLabelColor: Colors.grey[400],
            tabs: [
              Tab(icon: Icon(Icons.person), text: "Configuración personal"),
              Tab(icon: Icon(Icons.history), text: "Etiquetas de interés"),
            ],
          ),
          // Pantallas de contenido
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Función paraa modificar la información de usuario (contraseña o foto de perfil)
                _changeSettingsView(),

                //Función para cambiar las etiquetas de interés
                _changeInterestedTagsView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //Vista cambio de configuración
  Widget _changeSettingsView() {
    AuthService authService = AuthService();
    final loginForm = LoginFormProvider();
    final ImagePicker _picker = ImagePicker();

    return Container(
      child: Form(
        key: loginForm.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Contraseña
            TextFormField(
              autocorrect: false,
              obscureText: true,
              keyboardType: TextInputType.visiblePassword,
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blueGrey,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blueGrey,
                    width: 2,
                  ),
                ),
                labelText: 'Contraseña actual',
                labelStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.lock_outline, color: Colors.blueGrey),
              ),
              onChanged: (value) => loginForm.confirmPassword = value,
            ),

            // Nueva contraseña
            TextFormField(
              autocorrect: false,
              obscureText: true,
              keyboardType: TextInputType.visiblePassword,
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blueGrey,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blueGrey,
                    width: 2,
                  ),
                ),
                labelText: 'Nueva contraseña',
                labelStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.lock_outline, color: Colors.blueGrey),
              ),
              onChanged: (value) => loginForm.password = value,
              validator: (value) {
                if (value == null || value == "") {
                  return null;
                } else {
                  return (value.length >= 6)
                      ? null
                      : 'La contraseña debe tener al menos 6 caracteres';
                }
              },
            ),

            //Imágen
            //Solo se muestra el texto si no hay imágen seleccionada
            if (imagePath == null || imagePath == "")
              TextFormField(
                autocorrect: false,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.blueGrey,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.blueGrey,
                      width: 2,
                    ),
                  ),
                  labelText: 'Imagen',
                  labelStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.image, color: Colors.blueGrey),
                  suffixIcon: TextButton(
                    onPressed: () async {
                      final XFile? photo =
                          await _picker.pickImage(source: ImageSource.gallery);

                      if (photo != null) {
                        setState(() {
                          imagePath = photo.path;
                          loginForm.picture = photo.path;
                        });
                        print('Imagen seleccionada: ${photo.path}');
                      }
                    },
                    child: Text(
                      'Modificar imágen',
                      style: TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

            // Vista previa de la imagen
            if (imagePath != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.image, color: Colors.blueGrey),
                      SizedBox(width: 50),
                      Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(File(imagePath!)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () async {
                      final XFile? photo =
                          await _picker.pickImage(source: ImageSource.gallery);

                      if (photo != null) {
                        setState(() {
                          imagePath = photo.path;
                          loginForm.picture = photo.path;
                        });
                      }
                    },
                    child: Text(
                      'Cambiar imagen',
                      style: TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Divider(color: Colors.blueGrey, thickness: 1),
                ],
              ),

            SizedBox(height: 30),
            MaterialButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              disabledColor: Colors.grey,
              elevation: 0,
              color: Colors.blueGrey,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                child: Text(
                  loginForm.isLoading ? 'Cargando...' : 'Guardar cambios',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              onPressed: loginForm.isLoading
                  ? null
                  : () async {
                      //Comprueba que el formulario es correcto antes de actualizar los datos
                      setState(() {
                        loginForm.isLoading = true;
                        loginForm.correctCredentials = true;
                        if (imagePath != null) {
                          loginForm.picture = imagePath!;
                        }
                      });

                      FocusScope.of(context).unfocus();

                      if (!loginForm.isValidForm()) {
                        setState(() {
                          loginForm.isLoading = false;
                        });
                        return; // Salir si el formulario no es válido
                      }

                      try {
                        UserProvider userProvider = UserProvider();

                        if (loginForm.password != "") {
                          // Intentar registro en AuthService para comprobar que la contraseña es correcta
                          bool correctCredentials = await authService.signIn(
                            widget.connectedUser.email,
                            loginForm.confirmPassword!,
                          );

                          //Si la contraseña es correcta cambiamos la contraseña del usuario
                          if (correctCredentials) {
                            AuthService().changePassword(loginForm.password);
                            loginForm.correctCredentials = true;
                          } else {
                            loginForm.correctCredentials = false;
                          }
                        }

                        if (loginForm.picture != "") {
                          String? picture =
                              await userProvider.uploadImage(loginForm.picture);

                          // Subir imagen y actualizar usuario
                          widget.connectedUser.picture = picture;

                          userProvider.updateUser(widget.connectedUser);
                        }
                      } catch (e) {
                        // Maneja cualquier otro error
                        setState(() {
                          loginForm.correctCredentials = false;
                          loginForm.isLoading = false;
                        });
                      } finally {
                        // Asegura que isLoading vuelva a ser falso
                        setState(() {
                          loginForm.isLoading = false;
                        });
                      }
                    },
            ),

            // Mensaje de error
            Text(
              loginForm.correctCredentials == false
                  ? "Error, al actualizar los datos"
                  : loginForm.picture != "" && loginForm.password == ""
                      ? "Imágen actualizada correctamente"
                      : loginForm.picture == "" && loginForm.password != ""
                          ? "Contraseña actualizada correctamente"
                          : loginForm.picture != "" && loginForm.password != ""
                              ? "Actualizacion de datos correcta"
                              : "",
              style: loginForm.correctCredentials == false
                  ? TextStyle(color: Colors.red)
                  : TextStyle(color: Colors.blueGrey[700]),
            ),
          ],
        ),
      ),
    );
  }

  //Vista para modificar las etiquetas de interés
  Widget _changeInterestedTagsView() {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 16.0),
          Center(
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: predefinedTags.map((elemento) {
                          final isSelected = selectedTags.contains(elemento);

                          return ElevatedButton(
                            onPressed: () => toggleSeleccion(elemento),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isSelected
                                  ? Colors.blueGrey[700]
                                  : Colors.grey[300],
                              foregroundColor:
                                  isSelected ? Colors.white : Colors.black,
                            ),
                            child: Text(elemento),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  MaterialButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      disabledColor: Colors.grey,
                      elevation: 0,
                      color: Colors.blueGrey,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                        child: Text(
                          "Guardar cambios",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),

                      //Al clicar el guardar cambios
                      onPressed: () {
                        UserProvider userProvider = UserProvider();

                        //Actualiza la lista de etiquetas de interés
                        widget.connectedUser.interestedTags ??= [];
                        widget.connectedUser.interestedTags = selectedTags;

                        //Actualiza la información en la base de datos
                        userProvider.updateUser(widget.connectedUser);
                      }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
