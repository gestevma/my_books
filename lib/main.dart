import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_books/firebase_options.dart';
import 'package:my_books/providers/bookState_provider.dart';
import 'package:my_books/providers/bookTag_provider.dart';
import 'package:my_books/providers/bookUsersInteractions_provider.dart';
import 'package:my_books/providers/books_provider.dart';
import 'package:my_books/providers/loginForm_provider.dart';
import 'package:my_books/providers/post_provider.dart';
import 'package:my_books/providers/review_provider.dart';
import 'package:my_books/providers/ui_provider.dart';
import 'package:my_books/providers/user_provider.dart';
import 'package:my_books/screens/login_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(AppState());
}

class AppState extends StatelessWidget {
  const AppState();

  //Añadimos todos los providers, para que la app pueda escuchar sus notivicaciones
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (_) => PostProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (_) => BookProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (_) => UIProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (_) => BookUsersInteractionsProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (_) => BooktagProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (_) => ReviewProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (_) => BookstateProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (_) => LoginFormProvider(),
          lazy: false,
        ),
      ],
      child: MyApp(),
    );
  }
}

//Main
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Definimos la ruta principal, que será LoginScreen()
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My books App',
      initialRoute: 'login',
      routes: {
        'login': (_) => LoginScreen(),
      },
      //Principales características del texto para toda la aplicación
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.grey[200],
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.blueGrey,
          selectionColor: Colors.blueGrey.withOpacity(0.4),
          selectionHandleColor: Colors.blueGrey,
        ),
      ),
    );
  }
}
