import 'package:supabase_flutter/supabase_flutter.dart';

class StoryService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String> generateStory({
    required String childName,
    required String theme,
  }) async {
    // Chama a Supabase Edge Function ou faz chamada direta via HTTP/Function
    final response = await _supabase.functions.invoke(
      'generate-story',
      body: {
        'child_name': childName,
        'theme': theme,
      },
    );

    if (response.status != 200) {
      throw Exception('Falha ao gerar história: ${response.data}');
    }

    final data = response.data as Map<String, dynamic>;
    return data['story'] as String;
  }
}
