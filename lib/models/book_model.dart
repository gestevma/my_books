import 'dart:convert';

//Guarda la información del libro devuelto por google books
class Book {
  String id;
  String isbn;
  String title;
  dynamic authors;
  String publisher;
  String publicationDate;
  String description;
  String image;

  Book({
    required this.id,
    required this.isbn,
    required this.title,
    required this.authors,
    required this.publisher,
    required this.publicationDate,
    required this.description,
    required this.image,
  });

  factory Book.fromRawJsonList(int i, String str) =>
      Book.fromJsonList(i, json.decode(str));

  factory Book.fromRawJson(String str) => Book.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  //Función para un libro a partir de una lista de libros, devueltos por la api
  factory Book.fromJsonList(int i, Map<String, dynamic> json) => Book(
        id: json['items'][i]["id"] ?? "",
        isbn: json['items'][i]['volumeInfo']['industryIdentifiers'] != null &&
                json['items'][i]['volumeInfo']['industryIdentifiers'].isNotEmpty
            ? json['items'][i]['volumeInfo']['industryIdentifiers'][0]
                    ['identifier'] ??
                ""
            : "",
        title: json['items'][i]["volumeInfo"]["title"] ?? "",
        authors: json['items'][i]['volumeInfo']['authors'] ?? "",
        publisher: json['items'][i]['volumeInfo']['publisher'] ?? "",
        publicationDate: json['items'][i]['volumeInfo']['publishedDate'] ?? "",
        description: json['items'][i]['volumeInfo']['description'] ?? "",
        image: json['items'][i]['volumeInfo']['imageLinks'] != null &&
                json['items'][i]['volumeInfo']['imageLinks']['thumbnail'] !=
                    null
            ? json['items'][i]['volumeInfo']['imageLinks']['thumbnail']
            : "",
      );

  //Permite crear un libro devuelto por la api
  factory Book.fromJson(Map<String, dynamic> json) => Book(
        id: json["id"] ?? "",
        isbn: json['volumeInfo']['industryIdentifiers'] != null &&
                json['volumeInfo']['industryIdentifiers'].isNotEmpty
            ? json['volumeInfo']['industryIdentifiers'][0]['identifier'] ?? ""
            : "",
        title: json["volumeInfo"]["title"] ?? "",
        authors: json['volumeInfo']['authors'] ?? "",
        publisher: json['volumeInfo']['publisher'] ?? "",
        publicationDate: json['volumeInfo']['publishedDate'] ?? "",
        description: json['volumeInfo']['description'] ?? "",
        image: json['volumeInfo']['imageLinks'] != null &&
                json['volumeInfo']['imageLinks']['thumbnail'] != null
            ? json['volumeInfo']['imageLinks']['thumbnail']
            : "",
      );

  //Pasa los datos de la clase book a json para poder enviar los datos a la api
  Map<String, dynamic> toJson() => {
        'id': id,
        'isbn': isbn,
        'title': title,
        'authors': authors,
        'publisher': publisher,
        'publicationDate': publicationDate,
        'description': description,
        'image': image
      };
}
