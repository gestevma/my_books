import 'package:firebase_auth/firebase_auth.dart';

//Clase que controla la conexión con la base de datos de auth
class AuthService {
  AuthService();

  //Permite comprobar está registrado en la aplicación
  Future<bool> signIn(String userEmail, String password) async {
    bool correctCredentials;

    correctCredentials = false;

    //Función de auth para iniciar sesión. Si no da error es porque el usuario está registrado
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: userEmail,
        password: password,
      );

      correctCredentials = true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      } else {
        print(e.code);
        print("Ha passat un error");
      }
    }

    return correctCredentials;
  }

  //Crea un nuevo usuario a la base de datos.
  Future<bool> register(String userEmail, String password) async {
    bool correctCredentials;

    correctCredentials = false;

    //Intenta crear un nuevo usuario con los datos introducidos. Si puede crearlo la función nos ddevolverá true
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: userEmail,
        password: password,
      );

      correctCredentials = true;
    } catch (e) {
      correctCredentials = false;
      print(e.toString());
    }

    return correctCredentials;
  }

  //Permite cambiar la contraseña de un usuario
  Future<bool> changePassword(String newPassword) async {
    try {
      // Obtenemos el usuario que solicita el cambio
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Actualiza la contraseña del usuario
        await user.updatePassword(newPassword);
        print("Contraseña actualizada con éxito.");
        return true;
      } else {
        print("No hay ningún usuario autenticado.");
        return false;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        print(
            "El usuario necesita volver a iniciar sesión para cambiar la contraseña.");
      } else {
        print("Error al actualizar la contraseña: ${e.message}");
      }
      return false;
    } catch (e) {
      print("Error inesperado: $e");
      return false;
    }
  }
}
