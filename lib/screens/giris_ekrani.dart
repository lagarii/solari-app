import 'package:flutter/material.dart';
import '../services/api.dart';
import 'dogum_ekrani.dart';

class GirisEkrani extends StatefulWidget {
  const GirisEkrani({super.key});

  @override
  State<GirisEkrani> createState() => _GirisEkraniState();
}

class _GirisEkraniState extends State<GirisEkrani> {
  final emailCtrl = TextEditingController();
  final sifreCtrl = TextEditingController();
  bool yukleniyor = false;
  bool kayitModu = false;

  Future<void> _girisYap() async {
    setState(() => yukleniyor = true);
    try {
      final fn = kayitModu ? ApiService.kayitOl : ApiService.girisYap;
      final data = await fn(emailCtrl.text, sifreCtrl.text);

      if (!kayitModu && data['access_token'] != null) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DogumEkrani()),
          );
        }
      } else if (kayitModu && data['mesaj'] != null) {
        setState(() => kayitModu = false);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kayıt başarılı! Giriş yapabilirsiniz.')),
        );
      } else {
        final hata = data['detail'] ?? 'Bir hata oluştu';
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(hata), backgroundColor: Colors.red[800]),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    }
    setState(() => yukleniyor = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('✦ SOLARI', style: TextStyle(fontSize: 36, letterSpacing: 8, color: Colors.white)),
                const SizedBox(height: 8),
                const Text('Vedik Yıldız Rehberin', style: TextStyle(color: Colors.white54)),
                const SizedBox(height: 48),
                TextField(
                  controller: emailCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDeco('E-posta'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: sifreCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDeco('Şifre'),
                  obscureText: true,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: yukleniyor ? null : _girisYap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF533483),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: yukleniyor
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(kayitModu ? 'Kayıt Ol' : 'Giriş Yap', style: const TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => kayitModu = !kayitModu),
                  child: Text(
                    kayitModu ? 'Zaten hesabın var mı? Giriş yap' : 'Hesabın yok mu? Kayıt ol',
                    style: const TextStyle(color: Colors.white54),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Colors.white54),
    enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
    focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF533483))),
  );
}
