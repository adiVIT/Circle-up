import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/discovery_provider.dart';
import '../../models/user_model.dart';
import '../../widgets/user_card.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  @override
  void initState() {
    super.initState();
    _loadDiscoveryUsers();
  }

  void _loadDiscoveryUsers() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final discoveryProvider =
        Provider.of<DiscoveryProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      userProvider
          .loadDiscoveryUsers(
        currentUserId: authProvider.currentUser!.id,
        city: authProvider.currentUser!.city,
        colleges: authProvider.currentUser!.colleges,
        companies: authProvider.currentUser!.companies,
        interests: authProvider.currentUser!.interests,
      )
          .then((_) {
        // Users are loaded directly in the discovery provider
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.people_outline,
                size: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Discover'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implement filters
            },
          ),
        ],
      ),
      body: Consumer3<AuthProvider, UserProvider, DiscoveryProvider>(
        builder:
            (context, authProvider, userProvider, discoveryProvider, child) {
          if (userProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (userProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Oops! Something went wrong',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    userProvider.errorMessage!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loadDiscoveryUsers,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          if (userProvider.discoveryUsers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: Icon(
                      Icons.people_outline,
                      size: 60,
                      color: AppTheme.primaryColor,
                    ),
                  )
                      .animate()
                      .scale(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.elasticOut,
                      )
                      .fadeIn(duration: const Duration(milliseconds: 400)),
                  const SizedBox(height: 24),
                  Text(
                    'No more people to discover',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  )
                      .animate(delay: const Duration(milliseconds: 200))
                      .fadeIn(duration: const Duration(milliseconds: 600))
                      .slideY(
                        begin: 0.3,
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOut,
                      ),
                  const SizedBox(height: 8),
                  Text(
                    'Check back later for new connections!',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  )
                      .animate(delay: const Duration(milliseconds: 400))
                      .fadeIn(duration: const Duration(milliseconds: 600))
                      .slideY(
                        begin: 0.3,
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOut,
                      ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: _loadDiscoveryUsers,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                  )
                      .animate(delay: const Duration(milliseconds: 600))
                      .fadeIn(duration: const Duration(milliseconds: 600))
                      .slideY(
                        begin: 0.3,
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOut,
                      ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Header with tagline
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Find Your Circle',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Swipe right to connect, left to pass',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(duration: const Duration(milliseconds: 600))
                    .slideY(
                      begin: -0.3,
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOut,
                    ),

                const SizedBox(height: 24),

                // Card Stack
                Expanded(
                  child: Stack(
                    children: userProvider.discoveryUsers
                        .take(3)
                        .toList()
                        .asMap()
                        .entries
                        .map((entry) {
                      final index = entry.key;
                      final user = entry.value;

                      return Positioned.fill(
                        child: Transform.translate(
                          offset: Offset(0, index * 8.0),
                          child: Transform.scale(
                            scale: 1 - (index * 0.05),
                            child: UserCard(
                              user: user,
                              onLike: () => _handleLike(user.id),
                              onPass: () => _handlePass(user.id),
                              // isTopCard removed from UserCard
                            ),
                          ),
                        ),
                      )
                          .animate(delay: Duration(milliseconds: 200 * index))
                          .fadeIn(duration: const Duration(milliseconds: 600))
                          .slideY(
                            begin: 0.3,
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeOut,
                          );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _handleLike(String userId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final discoveryProvider =
        Provider.of<DiscoveryProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      await discoveryProvider.likeUser(userId, authProvider.currentUser!.id);

      // For now, show match dialog randomly (10% chance)
      if (mounted && DateTime.now().millisecond % 10 == 0) {
        _showMatchDialog();
      }
    }
  }

  void _handlePass(String userId) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final discoveryProvider =
        Provider.of<DiscoveryProvider>(context, listen: false);
    discoveryProvider.passUser(userId, authProvider.currentUser!.id);
  }

  void _showMatchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.favorite,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'It\'s a Match! 🎉',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'You can now start chatting!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Keep Swiping'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // TODO: Navigate to chat
                    },
                    child: const Text('Say Hi'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
