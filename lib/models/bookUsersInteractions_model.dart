//Objeto con la información de un libro almacenado en la base de datos de firebase
class BookUsersInteractions {
  String id;
  int likes;
  List<dynamic> reviewsIdList;
  List<dynamic> tagsList;

  BookUsersInteractions({
    required this.id,
    required this.likes,
    required this.reviewsIdList,
    required this.tagsList,
  });

  //Mapea los datos devueltos por la base de datos a un objeto tipo BookUsersInteractions
  factory BookUsersInteractions.fromMap(
      Map<String, dynamic> docData, String docId) {
    return BookUsersInteractions(
      id: docId,
      likes: docData['likes'] ?? 0,
      reviewsIdList: docData['reviewsId'] ?? [],
      tagsList: docData['tagsList'] ?? [],
    );
  }
}
