import 'package:flutter/material';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const FabuliaApp());
}

class FabuliaApp extends StatelessWidget {
  const FabuliaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FabuliA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF9EAA),
          primary: const Color(0xFFFF9EAA),
          secondary: const Color(0xFFA2D2FF),
        ),
        textTheme: GoogleFonts.fredokaTextTheme(),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5E4),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.auto_stories_rounded,
                size: 80,
                color: Color(0xFFFF9EAA),
              ),
              const SizedBox(height: 20),
              Text(
                'FabuliA',
                style: GoogleFonts.fredoka(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4A4E69),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Histórias mágicas personalizadas',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF8D99AE),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('Criar Nova História'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9EAA),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
