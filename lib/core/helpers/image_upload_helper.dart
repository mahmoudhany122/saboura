import 'dart:io';
import 'package:dio/dio.dart';

class ImageUploadHelper {
  // ملاحظة: يفضل وضع الـ API Key في ملف config أو بيئة آمنة
  // يمكنك الحصول على مفتاح خاص بك مجاناً من https://api.imgbb.com/
  static const String _apiKey = '97bf263eec47803b8ca69110bcef41e6';
  static const String _uploadUrl = 'https://api.imgbb.com/1/upload';

  static Future<String?> uploadImage(File imageFile) async {
    try {
      Dio dio = Dio();
      
      // تحويل الصورة لصيغة MultipartFile
      String fileName = imageFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        "key": _apiKey,
        "image": await MultipartFile.fromFile(imageFile.path, filename: fileName),
      });

      // إرسال الطلب للمنصة
      Response response = await dio.post(_uploadUrl, data: formData);

      if (response.statusCode == 200) {
        // استخراج الرابط المباشر من الرد
        return response.data['data']['url'];
      }
      return null;
    } catch (e) {
      print("Image Upload Error: $e");
      return null;
    }
  }
}
