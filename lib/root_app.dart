import 'package:expense_tracker/models/home_arguments.dart';
import 'package:flutter/material.dart';

import 'bottom_nav.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';

/// The root widget of the application.
///
/// This widget is responsible for setting up the app's theme, title, and
/// initial routing. It defines the available routes and handles passing
/// arguments to them.
class SmartSpendsApp extends StatelessWidget {
  // The constructor for the SmartSpendsApp widget.
  // The `super.key` is passed to the superclass, StatelessWidget, and is used
  // by Flutter to efficiently update the widget tree.
  const SmartSpendsApp({super.key});

  // The build method describes the part of the user interface represented by this widget.
  @override
  Widget build(BuildContext context) {
    // MaterialApp is a convenience widget that wraps a number of widgets that are
    // commonly required for material design applications.
    return MaterialApp(
      // The title of the application, which is used by the operating system
      // to identify the app.
      title: 'SmartSpends',

      // The theme of the application. This defines the colors, fonts, and other
      // visual properties of the app.
      theme: ThemeData(
        // The default background color for Scaffolds.
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        // The primary color swatch for the app. This is used to generate
        // shades of the primary color, which are used throughout the app.
        primarySwatch: Colors.blue,
      ),

      // Hide the debug banner that appears in the top-right corner of the screen
      // in debug mode.
      debugShowCheckedModeBanner: false,

      // The initial route to display when the app starts.
      // In this case, it's the splash screen.
      initialRoute: '/', // Splash screen

      // The routes table defines the available navigation routes in the app.
      // Each entry in the map corresponds to a named route and a builder function
      // that creates the corresponding widget.
      routes: {
        // The root route, which displays the splash screen.
        '/': (context) => const SplashScreen(),

        // The login route, which displays the sign-in screen.
        '/login': (context) => const SignInScreen(),

        // The home route, which displays the main application interface.
        // This route expects a `HomeArguments` object to be passed to it.
        '/home': (context) {
          // Extract the arguments passed to this route.
          // The `ModalRoute.of(context)!.settings.arguments` expression retrieves
          // the arguments, and we cast them to the `HomeArguments` type.
          final args = ModalRoute.of(context)!.settings.arguments as HomeArguments;

          // Create the `NavBar` widget and pass the user and authService from
          // the arguments to it.
          return NavBar(
            user: args.user,
            authService: args.authService,
          );
        }
      },
    );
  }
}
