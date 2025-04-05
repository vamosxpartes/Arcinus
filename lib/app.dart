import 'package:arcinus/config/firebase/analytics_service.dart';
import 'package:arcinus/ux/features/auth/providers/auth_providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ArcinusApp extends ConsumerWidget {
  const ArcinusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsObserver = AnalyticsService().getAnalyticsObserver();
    
    return MaterialApp(
      title: 'Arcinus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3E7BFA),
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3E7BFA),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', ''), // Español
        Locale('en', ''), // Inglés
      ],
      navigatorObservers: [
        if (analyticsObserver != null) analyticsObserver,
      ],
      home: const FirebaseConnectionTestScreen(),
    );
  }
}

class FirebaseConnectionTestScreen extends ConsumerWidget {
  const FirebaseConnectionTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prueba de Conexión Firebase'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estado de Conexión Firebase:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Firebase Auth Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Firebase Authentication:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    authState.when(
                      data: (user) => Text(
                        user != null 
                          ? 'Conectado: ${user.email} (${user.role})'
                          : 'No hay usuario conectado',
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (error, _) => Text('Error: $error', style: const TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Firestore Status
            FutureBuilder<bool>(
              future: _testFirestoreConnection(),
              builder: (context, snapshot) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Firestore Database:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        if (snapshot.connectionState == ConnectionState.waiting)
                          const CircularProgressIndicator()
                        else if (snapshot.hasError)
                          Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red))
                        else
                          Text(
                            snapshot.data == true 
                              ? 'Conectado correctamente'
                              : 'No se pudo conectar a Firestore',
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // Actions
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    await ref.read(authStateProvider.notifier).signIn(
                      'prueba@arcinus.com',
                      'password123',
                    );
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Inicio de sesión exitoso')),
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                },
                child: const Text('Probar inicio de sesión'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<bool> _testFirestoreConnection() async {
    try {
      // Intentar leer un documento de prueba
      await FirebaseFirestore.instance.collection('test').doc('connection').get();
      return true;
    } catch (e) {
      debugPrint('Error al conectar con Firestore: $e');
      return false;
    }
  }
} 