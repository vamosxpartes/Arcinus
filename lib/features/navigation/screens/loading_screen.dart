import 'package:flutter/material.dart';

// Pantalla de carga
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                isDarkMode ? 'assets/icons/Logo_white.png' : 'assets/icons/Logo_black.png',
                height: 120,
                errorBuilder: (context, error, stackTrace) => 
                  const Icon(Icons.sports, size: 120),
              ),
              const SizedBox(height: 32),
              // Indicador de carga
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
} 