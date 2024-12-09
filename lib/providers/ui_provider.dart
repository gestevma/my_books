import 'package:flutter/material.dart';

//Controla las el homeScreen para permitir la navegación entre pantallas
class UIProvider extends ChangeNotifier {
  int _selectMenuOpt = 0;
  bool isLoading = false;

  UIProvider() {
    isLoading = true;
    notifyListeners();

    isLoading = false;
    notifyListeners();
  }

  //Permite obtener el menú en el que estamos
  int get selectMenuOpt {
    return this._selectMenuOpt;
  }

  //Cambia el valor del menú
  set selectMenuOpt(int index) {
    this._selectMenuOpt = index;
    notifyListeners();
  }

  //Cambia el estado de carga del provider
  void setIsLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}
