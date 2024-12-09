import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_books/models/bookUsersInteractions_model.dart';
import 'package:my_books/models/book_model.dart';
import 'package:my_books/models/review_model.dart';
import 'package:my_books/models/user_model.dart';
import 'package:my_books/providers/post_provider.dart';
import 'package:my_books/screens/bookInfo_screen.dart';
import 'package:my_books/screens/home_screen.dart';
import 'package:my_books/utilities/generateRandomId.dart';
import 'package:provider/provider.dart';

class AddReviewDialog extends StatefulWidget {
  final BookUsersInteractions bookUsersInteractions;
  final Function(Review, User) onReviewAdded;
  final Book book;
  final User connectedUser;

  const AddReviewDialog(
      {Key? key,
      required this.bookUsersInteractions,
      required this.onReviewAdded,
      required this.book,
      required this.connectedUser})
      : super(key: key);

  @override
  _AddReviewState createState() => _AddReviewState();
}

class _AddReviewState extends State<AddReviewDialog> {
  final TextEditingController _reviewController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            //Creamos un icono de X que al clicar permite volver a la pantalla del libro
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Añadir una reseña',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            //Cuadro de texto
            const SizedBox(height: 16),
            TextField(
              controller: _reviewController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Escribe tu reseña aquí...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            //Botón para enviar la reseña
            ElevatedButton(
              //Guardamos la reseña en la base de datos
              onPressed: _submitReview,
              child: const Text('Enviar'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: const Size(double.infinity, 40),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //Función de enviar la reseña
  Future<void> _submitReview() async {
    final newPostText = _reviewController.text.trim();
    if (newPostText.isNotEmpty) {
      PostProvider postProvider =
          Provider.of<PostProvider>(context, listen: false);

      Timestamp creationDate = Timestamp.fromDate(DateTime.now());

      // Crear la nueva reseña
      String reviewiId = Utilities().generateRandomId(20);

      //Nueva reseña con la información para subirla a la base de datos
      Review newReview = Review(
        id: reviewiId,
        userName: widget.connectedUser.userName,
        bookId: widget.bookUsersInteractions.id,
        text: newPostText,
        createdAt: creationDate,
      );

      //Creamos un nuevo post con la reseña
      postProvider.newPost("reviews", newReview, widget.bookUsersInteractions,
          widget.connectedUser);

      // Cerrar el diálogo
      Navigator.of(context).pop();

      //Al añadir la reseña recargamos la página de información del libro
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookinfoScreen(
            book: widget.book,
            connectedUser: widget.connectedUser,
            backArrow: true,
            returnWidget: HomeScreen(connectedUser: widget.connectedUser),
          ),
        ),
      );
    }
  }
}
