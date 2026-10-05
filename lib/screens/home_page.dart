import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../main.dart';
import '../services/story_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _storyService = StoryService();
  final _nameController = TextEditingController();

  bool _isGenerating = false;
  File? _selectedImage;
  String _selectedFable = 'Chapeuzinho Vermelho';

  final List<String> _fablesList = [
    'Chapeuzinho Vermelho',
    'Os Três Porquinhos',
    'Cinderela',
    'O Gato de Botas',
  ];

  // Modal com o formulário de 4 passos
  void _showPersonalizeModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAlignment.stretch,
                children: [
                  Text(
                    'Personalizar Fábula 🪄',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.fredoka(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4A4E69),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 1. Nome do personagem
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: '1. Nome do(a) personagem',
                      hintText: 'Ex: Diana',
                      prefixIcon: const Icon(Icons.face_rounded, color: Color(0xFFFF9EAA)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. Enviar foto do rosto
                  InkWell(
                    onTap: () async {
                      final picker = ImagePicker();
                      final image = await picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        setModalState(() {
                          _selectedImage = File(image.path);
                        });
                        setState(() {});
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          _selectedImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    _selectedImage!,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(
                                  Icons.add_a_photo_rounded,
                                  size: 32,
                                  color: Color(0xFFFF9EAA),
                                ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _selectedImage != null
                                  ? 'Foto carregada com sucesso!'
                                  : '2. Enviar foto do rosto',
                              style: TextStyle(
                                fontSize: 15,
                                color: _selectedImage != null ? Colors.green : Colors.black87,
                                fontWeight: _selectedImage != null ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. Escolher a fábula
                  DropdownButtonFormField<String>(
                    value: _selectedFable,
                    decoration: InputDecoration(
                      labelText: '3. Escolher a fábula',
                      prefixIcon: const Icon(Icons.auto_stories_rounded, color: Color(0xFFFF9EAA)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    items: _fablesList.map((fable) {
                      return DropdownMenuItem(
                        value: fable,
                        child: Text(fable),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setModalState(() => _selectedFable = value);
                        setState(() => _selectedFable = value);
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  // 4. Botão Gerar Fábula
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _generateFable();
                    },
                    icon: const Icon(Icons.auto_awesome, size: 22),
                    label: const Text(
                      '4. Gerar Fábula',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9EAA),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _generateFable() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, digite o nome do personagem.')),
      );
      return;
    }

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione uma foto do rosto.')),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      // Passagem dos parâmetros para o StoryService
      final story = await _storyService.generateStory(
        childName: name,
        theme: _selectedFable,
      );

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(
            '✨ Fábula de $name',
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
        SnackBar(content: Text('Erro ao gerar fábula: ${e.toString()}')),
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
                      Text('Criando a fábula com a personagem... 🪄'),
                    ],
                  )
                else
                  ElevatedButton.icon(
                    onPressed: _showPersonalizeModal,
                    icon: const Icon(Icons.auto_awesome, size: 24),
                    label: const Text(
                      'Personalizar História',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight
                                       
