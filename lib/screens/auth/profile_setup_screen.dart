import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bioController = TextEditingController();
  final _cityController = TextEditingController();
  final _interestsController = TextEditingController();
  final _ageController = TextEditingController();

  bool _isLoading = false;
  List<String> _selectedInterests = [];

  final List<String> _popularInterests = [
    'Travel',
    'Food',
    'Music',
    'Movies',
    'Sports',
    'Reading',
    'Gaming',
    'Photography',
    'Art',
    'Technology',
    'Fitness',
    'Cooking',
    'Dancing',
    'Hiking',
    'Yoga',
    'Coffee',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user != null) {
      _bioController.text = user.bio ?? '';
      _cityController.text = user.city ?? '';
      _ageController.text = user.age > 0 ? user.age.toString() : '';
      _selectedInterests = List.from(user.interests);
    }
  }

  Future<void> _completeProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;

    if (currentUser != null) {
      final updatedUser = currentUser.copyWith(
        bio: _bioController.text.trim(),
        city: _cityController.text.trim(),
        interests: _selectedInterests,
        age: int.tryParse(_ageController.text) ?? 0,
        updatedAt: DateTime.now(),
      );

      final success = await authProvider.updateUserProfile(updatedUser);

      setState(() {
        _isLoading = false;
      });

      if (success && mounted) {
        context.go('/home');
      } else if (authProvider.errorMessage != null) {
        _showErrorSnackBar(authProvider.errorMessage!);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.accentColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else {
        _selectedInterests.add(interest);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome message
              Text(
                'Hi ${user?.name ?? 'there'}! 👋',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              )
                  .animate()
                  .fadeIn(duration: const Duration(milliseconds: 600))
                  .slideX(
                    begin: -0.3,
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOut,
                  ),

              const SizedBox(height: 8),

              Text(
                'Let\'s set up your profile to help you connect with the right people.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              )
                  .animate(delay: const Duration(milliseconds: 200))
                  .fadeIn(duration: const Duration(milliseconds: 600))
                  .slideX(
                    begin: -0.3,
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOut,
                  ),

              const SizedBox(height: 32),

              // Bio
              Text(
                'Tell us about yourself',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _bioController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Write a short bio about yourself...',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please tell us about yourself';
                  }
                  return null;
                },
              )
                  .animate(delay: const Duration(milliseconds: 400))
                  .fadeIn(duration: const Duration(milliseconds: 600))
                  .slideY(
                    begin: 0.3,
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOut,
                  ),

              const SizedBox(height: 24),

              // Current City
              Text(
                'Current City',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  hintText: 'e.g., San Francisco, CA',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your current city';
                  }
                  return null;
                },
              )
                  .animate(delay: const Duration(milliseconds: 600))
                  .fadeIn(duration: const Duration(milliseconds: 600))
                  .slideY(
                    begin: 0.3,
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOut,
                  ),

              const SizedBox(height: 24),

              // Age
              Text(
                'Age',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Enter your age',
                  prefixIcon: Icon(Icons.cake_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your age';
                  }
                  final age = int.tryParse(value);
                  if (age == null || age < 18 || age > 100) {
                    return 'Please enter a valid age (18-100)';
                  }
                  return null;
                },
              )
                  .animate(delay: const Duration(milliseconds: 800))
                  .fadeIn(duration: const Duration(milliseconds: 600))
                  .slideY(
                    begin: 0.3,
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOut,
                  ),

              const SizedBox(height: 24),

              // Interests
              Text(
                'Interests',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select your interests to connect with like-minded people',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              const SizedBox(height: 16),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _popularInterests.map((interest) {
                  final isSelected = _selectedInterests.contains(interest);
                  return FilterChip(
                    label: Text(interest),
                    selected: isSelected,
                    onSelected: (_) => _toggleInterest(interest),
                    selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                    checkmarkColor: AppTheme.primaryColor,
                  );
                }).toList(),
              )
                  .animate(delay: const Duration(milliseconds: 1000))
                  .fadeIn(duration: const Duration(milliseconds: 600))
                  .slideY(
                    begin: 0.3,
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOut,
                  ),

              const SizedBox(height: 40),

              // Complete Profile Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _completeProfile,
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text('Complete Profile'),
                ),
              )
                  .animate(delay: const Duration(milliseconds: 1200))
                  .fadeIn(duration: const Duration(milliseconds: 600))
                  .slideY(
                    begin: 0.3,
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOut,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bioController.dispose();
    _cityController.dispose();
    _interestsController.dispose();
    _ageController.dispose();
    super.dispose();
  }
}
