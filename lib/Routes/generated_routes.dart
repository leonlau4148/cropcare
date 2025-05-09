import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cropcare/Cropcarebloc/navigation_bloc/navigation_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart ';
import 'package:cropcare/Screens/landing_page.dart';
import 'package:cropcare/Routes/constants/routes.dart';
import 'package:cropcare/Screens/login.dart';
import 'package:cropcare/Screens/verify.dart';
import 'package:cropcare/Screens/register.dart';

class RouteGenerator {
  final NavigationBloc _navigationBloc = NavigationBloc();
   Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case landingPageRoute:
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  if (user.emailVerified) {
                    return MaterialPageRoute(
                      builder: (_) => BlocProvider<NavigationBloc>.value(
                        value: _navigationBloc,
                        child: const LandingPage(),
                      ),
                    );
                  } else {
                    return MaterialPageRoute(
                      builder: (context) => const VerifyEmailView(),
                    );
                  }
                } else {
                  return  MaterialPageRoute(
                    builder: (context) => const LoginView(),
                  );
                }
      case loginRoute:
        return MaterialPageRoute(
          builder: (context) => const LoginView(),
        );
      case verifyEmailRoute:
        return MaterialPageRoute(
          builder: (context) => const VerifyEmailView(),
        );
      case registerRoute:
        return MaterialPageRoute(
          builder: (context) => const RegisterView(),
        );
      default:
        return _errorRoute();
    }
  }

   Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('Error'),
        ),
      );
    });
  }
}
