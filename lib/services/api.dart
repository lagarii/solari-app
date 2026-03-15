import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String baseUrl = 'https://web-production-a7604.up.railway.app';

class ApiService {
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // Kayıt
  static Future<Map<String, dynamic>> kayitOl(String email, String sifre) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/kayit'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'sifre': sifre}),
    );
    return jsonDecode(utf8.decode(res.bodyBytes));
  }

  // Giriş
  static Future<Map<String, dynamic>> girisYap(String email, String sifre) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/giris'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'sifre': sifre}),
    );
    final data = jsonDecode(utf8.decode(res.bodyBytes));
    if (data['access_token'] != null) {
      await saveToken(data['access_token']);
    }
    return data;
  }

  // Nakshatra hesapla
  static Future<Map<String, dynamic>> nakshatraHesapla({
    required String isim,
    required int yil,
    required int ay,
    required int gun,
    required int saat,
    required int dakika,
    required String sehir,
    required String ulke,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/nakshatra/hesapla'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'isim': isim, 'yil': yil, 'ay': ay, 'gun': gun,
        'saat': saat, 'dakika': dakika, 'sehir': sehir, 'ulke': ulke,
      }),
    );
    return jsonDecode(utf8.decode(res.bodyBytes));
  }

  // Soru sor
  static Future<Map<String, dynamic>> soruSor({
    required String soru,
    required String nakshatra,
    required String dil,
    String dogumTarihi = '',
    String bugun = '',
  }) async {
    final token = await getToken();
    final res = await http.post(
      Uri.parse('$baseUrl/chat/sor'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'soru': soru,
        'nakshatra': nakshatra,
        'dil': dil,
        'dogum_tarihi': dogumTarihi,
        'bugun': bugun,
      }),
    );
    return jsonDecode(utf8.decode(res.bodyBytes));
  }
}
