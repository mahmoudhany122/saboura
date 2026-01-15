import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiHelper {
  // Replace with your actual Gemini API Key
  static const String _apiKey = 'AIzaSyBBAT2GZgrM5GP3f1Qfu8oj-nrvvikJbDU';
  static final _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);

  static Future<String> getAiResponse(String prompt, String context) async {
    try {
      final fullPrompt = "You are 'Saboura AI', a friendly and helpful tutor for children. "
          "The student is watching a lesson about: $context. "
          "Answer their question in a simple, encouraging, and clear way. "
          "Student's question: $prompt";

      final content = [Content.text(fullPrompt)];
      final response = await _model.generateContent(content);
      
      return response.text ?? "عذراً يا بطل، لم أستطع فهم السؤال جيداً. هل يمكنك إعادة صياغته؟";
    } catch (e) {
      return "حدث خطأ ما في الاتصال بذكائي الاصطناعي. حاول مرة أخرى لاحقاً!";
    }
  }
}
