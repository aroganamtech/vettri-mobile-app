import 'package:flutter/material.dart';
import '../modules/booking/booking_screen.dart';
import '../modules/chat/chat_screen.dart';
import '../modules/ecommerce/ecommerce_screen.dart';
import '../modules/healthcare/healthcare_screen.dart';
import '../modules/movies/movies_screen.dart';
import '../modules/payment/payment_screen.dart';
import '../modules/social/social_screen.dart';
import '../modules/entertainment/entertainment_screen.dart';


class AppRoutes {
  static const String booking = '/booking';
  static const String chat = '/chat';
  static const String ecommerce = '/ecommerce';
  static const String healthcare = '/healthcare';
  static const String movies = '/movies';
  static const String payment = '/payment';
  static const String social = '/social';
  static const String entertainment = '/entertainment';

  static Map<String, WidgetBuilder> get routes => {
    booking: (context) => const BookingScreen(),
    chat: (context) => const ChatScreen(),
    ecommerce: (context) => const EcommerceScreen(),
    healthcare: (context) => const HealthcareScreen(),
    movies: (context) => const MoviesScreen(),
    payment: (context) => const PaymentScreen(),
    social: (context) => const SocialScreen(),
    entertainment: (context) => const EntertainmentScreen(),
  };

}
