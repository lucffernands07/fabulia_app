import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';

class StoryService {
  Future<String> generateStory({
    required String childName,
    required String theme,
  }) async {
    final response = await supabase.functions.invoke(
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
