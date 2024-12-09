//Mapea los datos de una etiqueta para un libro en concreto
class Booktag {
  String id;
  String bookId;
  List<dynamic> addedUsers;
  List<dynamic> complaintUsers;
  String tagName;

  Booktag({
    required this.id,
    required this.bookId,
    required this.addedUsers,
    required this.complaintUsers,
    required this.tagName,
  });

  //Mapea los datos devueltos de la base de datos a un objeto tipo BookTag
  factory Booktag.fromMap(Map<String, dynamic> docData, String docId) {
    return Booktag(
      id: docId,
      bookId: docData['bookId'],
      addedUsers: docData['addedUsers'],
      complaintUsers: docData['complaintUsers'] ?? [],
      tagName: docData['tagName'],
    );
  }
}
