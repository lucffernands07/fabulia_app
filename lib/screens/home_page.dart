import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/story_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _storyService = StoryService();
  bool _isGenerating = false;

  Future<void> _testAIGeneration() async {
    setState(() => _isGenerating = true);

    try {
      final story = await _storyService.generateStory(
        childName: 'Lucas',
        theme: 'uma grande aventura na floresta mágica com um dragão amigo',
      );

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(
            '✨ História Mágica',
            style: GoogleFonts.fredoka(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Text(story, style: const TextStyle(fontSize: 16)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro no teste da IA: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5E4),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
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
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4A4E69),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Histórias mágicas personalizadas',
                  style: GoogleFonts.fredoka(
                    fontSize: 18,
                    color: const Color(0xFF8D99AE),
                  ),
                ),
                const SizedBox(height: 40),
                if (_isGenerating)
                  const Column(
                    children: [
                      CircularProgressIndicator(color: Color(0xFFFF9EAA)),
                      SizedBox(height: 15),
                      Text('A IA está criando a história... 🪄'),
                    ],
                  )
                else
                  ElevatedButton.icon(
                    onPressed: _testAIGeneration,
                    icon: const Icon(Icons.auto_awesome, size: 24),
                    label: const Text(
                      'Testar Geração de História',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9EAA),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 2,
                    ),
                  ),
                const SizedBox(height: 30),
                TextButton.icon(
                  onPressed: () async => await Supabase.instance.client.auth.signOut(),
                  icon: const Icon(Icons.logout, color: Colors.grey),
                  label: const Text(
                    'Sair da conta',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
