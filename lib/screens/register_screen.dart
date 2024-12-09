import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_books/models/user_model.dart';
import 'package:my_books/providers/loginForm_provider.dart';
import 'package:my_books/providers/user_provider.dart';
import 'package:my_books/screens/selectTags_screens.dart';
import 'package:my_books/services/auth_service.dart';
import 'package:my_books/widgets/personalizedAppBar.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PersonalizedAppbar(
        title: "Registrarse",
        backRow: true,
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(height: 150),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 15,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: _RegisterForm(),
                  ),
                ),
                SizedBox(height: 50),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RegisterForm extends StatefulWidget {
  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  final loginForm = LoginFormProvider();
  final ImagePicker _picker = ImagePicker();
  String?
      imagePath; // Variable para almacenar la ruta de la imagen seleccionada

  @override
  Widget build(BuildContext context) {
    AuthService authService = AuthService();

    //Formulario de registro
    return Container(
      child: Form(
        key: loginForm.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Nombre de usuario
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
                labelText: 'Nombre de usuario',
                labelStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.person, color: Colors.blueGrey),
              ),
              onChanged: (value) => loginForm.userName = value,
            ),

            // Correo electrónico
            TextFormField(
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
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
                labelText: 'Correo electrónico',
                labelStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.alternate_email_outlined,
                    color: Colors.blueGrey),
              ),
              onChanged: (value) => loginForm.email = value,

              //Creamos un validador que comprobará si el correo se crea en formato correo electrónico mediante un regex. En caso de que el formate no sea de correo derá error
              validator: (value) {
                String pattern =
                    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                RegExp regExp = RegExp(pattern);
                return regExp.hasMatch(value!)
                    ? null
                    : 'No es un correo válido';
              },
            ),

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
                labelText: 'Contraseña',
                labelStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.lock_outline, color: Colors.blueGrey),
              ),
              onChanged: (value) => loginForm.password = value,

              //Validador. Comprobará que la contraseña tenga al menos 6 caracteres.
              //Debe ser así porque lo exige Authentication de Firebase
              validator: (value) {
                return (value != null && value.length >= 6)
                    ? null
                    : 'La contraseña debe tener al menos 6 caracteres';
              },
            ),

            //Imágen
            //Solo se muestra el texto si no hay imágen seleccionada
            if (imagePath == null)
              TextFormField(
                readOnly: true,
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
                    //Acción al clicar en "Añadir imagen"
                    onPressed: () async {
                      //Guardamos la imagen
                      final XFile? photo =
                          await _picker.pickImage(source: ImageSource.gallery);

                      //Seleccionamos la ruta
                      if (photo != null) {
                        setState(() {
                          imagePath = photo.path;
                          loginForm.picture = photo.path;
                        });
                      }
                    },
                    child: Text(
                      'Añadir imagen',
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

                  //Botón de texto para poder cambiar la imágen en caso de que ya haya una
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

            //Botón para enviar los datos
            MaterialButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              disabledColor: Colors.grey,
              elevation: 0,
              color: Colors.blueGrey,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                child: Text(
                  loginForm.isLoading ? 'Cargando...' : 'Crear cuenta',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              onPressed: loginForm.isLoading
                  ? null
                  : () async {
                      setState(() {
                        loginForm.isLoading = true;
                        loginForm.correctCredentials =
                            true; // Resetear estado previo
                      });

                      FocusScope.of(context).unfocus();

                      //Comprobamos si el formulario es válido
                      if (!loginForm.isValidForm()) {
                        setState(() {
                          loginForm.isLoading = false;
                        });
                        return;
                      }

                      try {
                        UserProvider userProvider = UserProvider();

                        // Verificar si el usuario ya existe
                        User? chekIfUserExists =
                            await userProvider.getUserById(loginForm.userName);

                        //Si no da null significa que el usuario existe
                        if (chekIfUserExists != null) {
                          setState(() {
                            loginForm.correctCredentials = false;
                            loginForm.isLoading = false;
                          });
                          return;
                        }

                        // Intentar registro en AuthService
                        bool correctCredentials = await authService.register(
                          loginForm.email,
                          loginForm.password,
                        );

                        //Comprobamos si se ha podido crear el usuario
                        if (!correctCredentials) {
                          //Si no se ha podido crear indicamos que las credenciales no son correctas para poder lanzar un error
                          setState(() {
                            loginForm.correctCredentials = false;
                            loginForm.isLoading = false;
                          });
                          return;
                        }

                        // Subimos la imagen de usuario a la base de datos imágen
                        String? picture =
                            await userProvider.uploadImage(loginForm.picture);

                        //Creamos el nuevo usuario
                        User connectedUser = User(
                          userName: loginForm.userName,
                          email: loginForm.email,
                          picture: picture,
                          postsIdList: [],
                          friendsNameList: [],
                        );

                        //Se crea un usuario falso porque si homeScreen carga un usuario sin amigos lanza error
                        connectedUser.friendsNameList!
                            .add("FALSE_USERt3povQb9M1zY8W3DiaTY");

                        await userProvider.createUser(connectedUser);

                        // Navegar a la pantalla de elección de etiquetas
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SelectTagsScreen(
                              connectedUser: connectedUser,
                            ),
                          ),
                        );
                      } catch (e) {
                        setState(() {
                          loginForm.correctCredentials = false;
                          loginForm.isLoading = false;
                        });
                      } finally {
                        setState(() {
                          loginForm.isLoading = false;
                        });
                      }
                    },
            ),

            // Mensaje de error
            Text(
              loginForm.correctCredentials == false
                  ? "Error, usuario ya registrado"
                  : "",
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
