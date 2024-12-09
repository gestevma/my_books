import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_books/models/review_model.dart';

//Clase que interactua con el documento de reseñas de la base de datos de firebase
class ReviewProvider extends ChangeNotifier {
  //Permite obtener una reseña por su ID
  Future<Review> getReviewById(String id) async {
    //Buscamos el documento de la colección reviews con el id indicado
    DocumentSnapshot<Map<String, dynamic>> reviewSnapshot =
        await FirebaseFirestore.instance.collection('reviews').doc(id).get();

    Review reviewInfo = Review.fromMap(reviewSnapshot.data()!, id);

    notifyListeners();

    return reviewInfo;
  }

  //Creamsos una nueva reseña
  void createReview(Review review) async {
    try {
      // Referencia a la colección "reviews"
      CollectionReference reviewsCollection =
          FirebaseFirestore.instance.collection('reviews');

      // Crear un nuevo documento en la colección reviews
      await reviewsCollection.doc(review.id).set({
        'userName': review.userName,
        'bookId': review.bookId,
        'text': review.text,
        "created_at": review
            .createdAt, // Asegúrate de que `createdAt` sea de tipo Timestamp si es necesario
      });

      print("Documento creado correctamente.");
    } catch (e) {
      print("Error al crear el documento: $e");
    }

    notifyListeners();
  }
}
