import 'dart:math';

//clase que utilizaremos para crear funciones de interñes no directamente relacionadas con el proceso de la aplicación pero que nos ayudan en el desarrollo
class Utilities {
  //Permite generar un string aleatorio que utilizaremos como id de los documentos de la base de datos creados
  String generateRandomId(int idLenght) {
    const characters =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();
    String id = List.generate(20, (index) {
      return characters[random.nextInt(characters.length)];
    }).join();

    return id;
  }
}
