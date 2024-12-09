//Almacena los datos de un usuario concreto
class User {
  String userName;
  String email;
  String? picture;
  List<dynamic>? friendsNameList;
  List<dynamic>? postsIdList;
  List<dynamic>? interestedTags;

  User({
    required this.userName,
    required this.email,
    this.picture,
    this.friendsNameList,
    required this.postsIdList,
    this.interestedTags,
  });

  //Mapea los datos devueltos por la base de datos hacia un objeto tipo user
  factory User.fromMap(Map<String, dynamic> docData, String docId) {
    return User(
      userName: docId,
      email: docData['email'] ?? "",
      picture: docData['picture'] ?? "",
      friendsNameList: docData['friendsNameList'] ?? [],
      postsIdList: docData['postsIdList'] ?? [],
      interestedTags: docData['interestedTags'] ?? [],
    );
  }
}
