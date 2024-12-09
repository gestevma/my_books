import 'package:flutter/material.dart';
import 'package:my_books/models/predefinedTags_model.dart';
import 'package:my_books/models/user_model.dart';
import 'package:my_books/providers/user_provider.dart';
import 'package:my_books/screens/home_screen.dart';
import 'package:my_books/widgets/personalizedAppBar.dart';

class SelectTagsScreen extends StatefulWidget {
  final User connectedUser;

  const SelectTagsScreen({Key? key, required this.connectedUser})
      : super(key: key);

  @override
  _SelectTagsScreenState createState() => _SelectTagsScreenState();
}

class _SelectTagsScreenState extends State<SelectTagsScreen> {
  // Lista inicial de elementos
  final List<String> predefinedTags = Predefinedtags().predefinedTags;

  // Lista de elementos seleccionados
  final List<String> selectedTafs = [];

  // Método para manejar la selección
  void toggleSeleccion(String elemento) {
    setState(() {
      if (selectedTafs.contains(elemento)) {
        selectedTafs.remove(elemento); // Si ya está seleccionado, lo quitamos
      } else {
        selectedTafs.add(elemento); // Si no está seleccionado, lo añadimos
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PersonalizedAppbar(
        title: "Etiquetas de interés",
      ),
      body: Column(
        children: [
          // Separación superior
          SizedBox(height: 16.0),
          // Caja que contiene los botones
          Center(
            child: Container(
              // width: MediaQuery.of(context).size.width * 0.85, // 85% del ancho
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8.0, // Espaciado horizontal entre botones
                        runSpacing: 8.0, // Espaciado vertical entre botones
                        children: predefinedTags.map((elemento) {
                          final isSelected = selectedTafs.contains(elemento);

                          return ElevatedButton(
                            onPressed: () => toggleSeleccion(elemento),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isSelected
                                  ? Colors.blueGrey[700]
                                  : Colors.grey[300],
                              foregroundColor:
                                  isSelected ? Colors.white : Colors.black,
                            ),
                            child: Text(elemento),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  MaterialButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      disabledColor: Colors.grey,
                      elevation: 0,
                      color: Colors.blueGrey,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                        child: Text(
                          "Continuar",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      onPressed: () {
                        UserProvider userProvider = UserProvider();

                        if (widget.connectedUser.interestedTags == null) {
                          widget.connectedUser.interestedTags = [];

                          widget.connectedUser.interestedTags!
                              .addAll(selectedTafs);
                        }

                        userProvider.updateUser(widget.connectedUser);

                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomeScreen(
                                connectedUser: widget.connectedUser,
                              ),
                            ));
                      }),
                ],
              ),
            ),
          ),
          // Separación entre lista y botón
        ],
      ),
    );
  }
}
