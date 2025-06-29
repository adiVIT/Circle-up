import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/profile_setup_screen.dart';
import '../screens/home/main_navigation_screen.dart';
import '../screens/home/discovery_screen.dart';
import '../screens/home/connections_screen.dart';
import '../screens/home/profile_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/chat/chat_list_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/user_detail_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isLoggedIn = authProvider.isAuthenticated;
      final currentPath = state.uri.toString();

      // If user is not logged in, redirect to login (except for splash)
      if (!isLoggedIn && currentPath != '/splash' && currentPath != '/login') {
        return '/login';
      }

      // If user is logged in but has minimal profile, redirect to profile setup
      if (isLoggedIn &&
          (authProvider.currentUser?.bio == null ||
              authProvider.currentUser!.bio!.isEmpty) &&
          currentPath != '/profile-setup') {
        return '/profile-setup';
      }

      // If user is logged in with complete profile and trying to access auth screens, redirect to home
      if (isLoggedIn &&
          authProvider.currentUser?.bio != null &&
          authProvider.currentUser!.bio!.isNotEmpty &&
          (currentPath == '/login' || currentPath == '/splash')) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/profile-setup',
        name: 'profile-setup',
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainNavigationScreen(child: child),
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const DiscoveryScreen(),
          ),
          GoRoute(
            path: '/connections',
            name: 'connections',
            builder: (context, state) => const ConnectionsScreen(),
          ),
          GoRoute(
            path: '/chats',
            name: 'chats',
            builder: (context, state) => const ChatListScreen(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/chat/:userId',
        name: 'chat',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return ChatScreen(userId: userId);
        },
      ),
      GoRoute(
        path: '/user/:userId',
        name: 'user-detail',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return UserDetailScreen(userId: userId);
        },
      ),
      GoRoute(
        path: '/edit-profile',
        name: 'edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
    ],
  );
}
