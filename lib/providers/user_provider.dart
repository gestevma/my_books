import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_books/models/user_model.dart';

//Clase que realiza llamadas a la base de datos firebase para obtener datos de la colección USERS
class UserProvider extends ChangeNotifier {
  late User connectedUser;
  User? user;
  bool isLoading = false;

  //Obtiene la lista de amigos del usuario pasado por parámetro
  Future<List<User>> getFriends(User user) async {
    List<User> userFriendsList = [];
    List<dynamic> friendsList = user.friendsNameList!;

    try {
      //Para cada nombre de usuario de la lista friendsList del usuario pasado por paramtro, llamamos a la base de datos para obtener los datos de ese usuario
      for (String friendName in friendsList) {
        DocumentSnapshot<Map<String, dynamic>> userSnapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(friendName)
                .get();

        Map<String, dynamic>? friendData = userSnapshot.data();

        //Mapeamos el resultado en un objeto de tipo User
        User userFriend = User.fromMap(friendData!, friendName);

        //Añadimos el usuario obtenido a una lista con la información completa de los usuarios amigos
        if (userFriend.userName != "FALSE_USERt3povQb9M1zY8W3DiaTY") {
          userFriendsList.add(userFriend);
        }
      }
    } catch (e) {
      print("Error al cargar la lista de amigos ${e}");
    }

    notifyListeners();

    return userFriendsList;
  }

  //Devuelve los datos del usuario conectado
  Future<User?> getUserById(String userName) async {
    User? user;

    //Llamada a la base de datos que devuelve el cocumento de la colección users cuya id sea el nombre de usuario
    try {
      DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userName)
              .get();

      Map<String, dynamic>? userData = userSnapshot.data();
      //Mapeamos el resultado de la llamada en un objeto de tipo User
      if (userData != null) {
        user = User.fromMap(userData, userName);
      }
    } catch (e) {
      print("Error al cargar el usuario: $e");
    }

    notifyListeners();

    return user; // Retorna 'null' en caso de error o si no se encuentra el usuario
  }

  //Actualiza la información de un usuario
  updateUser(User user) async {
    try {
      // Referencia al documento que deseas actualizar
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('users').doc(user.userName);

      // Actualización del documento
      await userRef.update({
        "email": user.email,
        "picture": user.picture,
        "friendsNameList": user.friendsNameList,
        "postsIdList": user.postsIdList,
        "interestedTags": user.interestedTags,
      });

      print("Documento actualizado correctamente.");
    } catch (e) {
      print("Error al actualizar el documento: $e");
    }
  }

  //Obtenemos un usuario cuyo nombre contenga el nombre pasado por parámetro
  Future<List<User>> getUserByName(String userName) async {
    List<User> usersList = [];

    try {
      userName = userName.toLowerCase();

      //Registramos la colección de users
      final usersCollection = FirebaseFirestore.instance.collection('users');

      final snapshot = await usersCollection.get();

      //Indicamos que buscamos los documentos cuya id (nombre de usuario) empiece por el valor introducido por parámetro
      final filteredDocs = snapshot.docs.where((doc) {
        return doc.id.toLowerCase().startsWith(
            userName); // Filtra solo aquellos cuyo id empieza con el prefijo
      }).toList();

      for (int i = 0; i < filteredDocs.length; i++) {
        User user = User.fromMap(filteredDocs[i].data(), filteredDocs[i].id);

        usersList.add(user);
      }
    } catch (e) {
      print('Error al buscar usuarios: $e');
    }

    return usersList;
  }

  //Devuelve un usuario cuyo email sea el introcudido por parámetro
  Future<User?> getUserByEmail(String email) async {
    User? user;

    //Buscamos en la colección users todos los documentos cuyo balor email sea igual al email introducido por parámetro
    QuerySnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    // Procesar los resultados
    if (userSnapshot.docs.isNotEmpty) {
      for (var doc in userSnapshot.docs) {
        String docId = doc.id;
        Map<String, dynamic> docData = doc.data() as Map<String, dynamic>;

        // Crear el objeto User desde el documento
        user = User.fromMap(docData, docId);
      }
    }
    notifyListeners();
    return user;
  }

  //Crear un nuevo usuario
  createUser(User user) async {
    try {
      // Referencia a la colección "users"
      CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('users');

      // Crear un nuevo documento en la colección users
      await usersCollection.doc(user.userName).set({
        'email': user.email,
        'picture': user.picture,
        'postsIdList': user.postsIdList,
        'friendsNameList': user.friendsNameList,
      });

      print("Documento creado correctamente.");
    } catch (e) {
      print("Error al crear el documento: $e");
    }
  }

  //Sube una imágen a cloudinary
  Future<String> uploadImage(String? picturePath) async {
    if (picturePath == null) return "";

    try {
      File picture = File.fromUri(Uri(path: picturePath));

      //Creamos la url de cloudinary
      final baseUrl = Uri.parse(
          'https://api.cloudinary.com/v1_1/dbb5r5wvr/image/upload?upload_preset=fpUpload');

      final imageUploadRequest = http.MultipartRequest('POST', baseUrl);

      final file = await http.MultipartFile.fromPath('file', picture.path);

      imageUploadRequest.files.add(file);

      final stramResponse = await imageUploadRequest.send();
      final resp = await http.Response.fromStream(stramResponse);

      if (resp.statusCode != 200 && resp.statusCode != 201) {
        print('Error');
        print(resp.body);
        return "";
      }

      final decodedData = json.decode(resp.body);

      return decodedData['secure_url'];
    } catch (e) {
      print("Error al cargar imágen");
      return "";
    }
  }
}
