import 'package:cvgenius/presentation/screens/screens.dart';
import 'package:go_router/go_router.dart';

final approuter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
      routes: [
      GoRoute(
        path: 'cv-data/:userId',
        builder: (context, state) {
          final String userIdStr = state.pathParameters['userId']??'';
         
          
          return CvDataScreen(
            userId: int.tryParse(userIdStr)?? 0,
          );
        }),
      ]
    ),
    GoRoute(
      path: '/create-cv',
      builder: (context, state) => const CreateCvScreen(),
    ),
    
  ],
);
