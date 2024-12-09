import 'package:flutter/material.dart';
import 'package:my_books/models/user_model.dart';
import 'package:my_books/providers/loginForm_provider.dart';
import 'package:my_books/providers/user_provider.dart';
import 'package:my_books/screens/home_screen.dart';
import 'package:my_books/screens/register_screen.dart';
import 'package:my_books/services/auth_service.dart';
import 'package:my_books/widgets/personalizedAppBar.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  //Crea la vista para iniciar sesión
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PersonalizedAppbar(title: "Iniciar sesión"),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 175),

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
                      blurRadius: 20,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                //Definimos el formulario
                child: _LoginForm(),
              ),
            ),
            SizedBox(height: 50),

            //Botón para abrir el formulario para registrarse en la aplicación
            MaterialButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Colors.blueGrey),
              ),
              disabledColor: Colors.grey,
              elevation: 0,
              color: Colors.transparent,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                child: Text(
                  'Registrarse',
                  style: TextStyle(color: Colors.blueGrey[700]),
                ),
              ),

              //Al clicar el botón se nos dirigirá a la pantalla con el formulario de registro
              onPressed: () {
                FocusScope.of(context).unfocus();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider(
                      create: (_) => LoginFormProvider(),
                      child: RegisterScreen(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

//Definimos el formulario
class _LoginForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loginForm = Provider.of<LoginFormProvider>(context);
    AuthService authService = AuthService();

    return Container(
      child: Form(
        key: loginForm.formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          children: [
            //Correo electrónico
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
                prefixIcon: Icons.alternate_email_outlined != null
                    ? Icon(Icons.alternate_email_outlined,
                        color: Colors.blueGrey)
                    : null,
              ),
              onChanged: (value) => loginForm.email = value,
            ),
            SizedBox(height: 30),

            //Contraseña
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
                prefixIcon: Icons.lock_outline != null
                    ? Icon(Icons.lock_outline, color: Colors.blueGrey)
                    : null,
              ),
              onChanged: (value) => loginForm.password = value,
            ),
            SizedBox(height: 30),

            //Botón inicio de sesión
            MaterialButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              disabledColor: Colors.grey,
              elevation: 0,
              color: Colors.blueGrey,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                child: Text(
                  loginForm.isLoading ? 'Cargando...' : 'Iniciar sesión',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              onPressed: loginForm.isLoading
                  ? null
                  : () async {
                      loginForm.isLoading = true;
                      FocusScope.of(context).unfocus();

                      try {
                        //Comprobamos si el formulario es válido
                        if (loginForm.isValidForm()) {
                          //Intentamos iniciar sesión son el usuario y contraseña poroporcionados
                          bool correctCredentials = await authService.signIn(
                            loginForm.email,
                            loginForm.password,
                          );

                          //Caso credenciales correctas_
                          if (correctCredentials) {
                            loginForm.correctCredentials = true;
                            loginForm.updateCorrectCredentials(true);

                            try {
                              //Hacemos una llamada a la base de datos de firebase para obtener el usuario conectado a partir del email
                              UserProvider userProvider = UserProvider();
                              User? connectedUser = await userProvider
                                  .getUserByEmail(loginForm.email);

                              //Si nos devuelve un usuario de manera correcta abriremos la pantalla homeScreen
                              if (connectedUser != null) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HomeScreen(
                                      connectedUser: connectedUser,
                                    ),
                                  ),
                                );
                                //En caso de no encontrar el usuario lanzaremos un mensaje de error
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('Error: Usuario no encontrado.'),
                                  ),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('Error al obtener el usuario: $e'),
                                ),
                              );
                            }

                            //Caso de que las credenciales sean incorrectas, lanzamos un mensaje de error
                          } else {
                            loginForm.correctCredentials = false;
                            loginForm.updateCorrectCredentials(false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Usuario o contraseña incorrecta.'),
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error inesperado: $e'),
                          ),
                        );
                      } finally {
                        loginForm.isLoading = false;
                      }
                    },
            ),

            //Mensaje de error si las credenciasles son incorrectas
            Text(
              loginForm.correctCredentials == false
                  ? "Usuario o contraseña incorrecta"
                  : "",
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
